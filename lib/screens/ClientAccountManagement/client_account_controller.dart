import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../utils/widgets/custom_dialogue.dart';

class ClientAccountController extends GetxController {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  RxString selectedStatus = "All".obs;
  var subscriptions = <Map<String, dynamic>>[].obs;

  RxList<Map<String, dynamic>>  activeServices = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> requests = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    applyFilter();
    listenToActiveServices();
    fetchSubscriptions();
    super.onInit();
  }

  void listenToActiveServices() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    isLoading.value = true;

    _firestore
        .collection('requests')
        .where('userId', isEqualTo: userId)
        .where('status', whereIn: ['pending', 'started',"Approved",'end'])
        .snapshots()
        .listen((snapshot) async {
      List<Map<String, dynamic>> tempRequests = [];

      for (var doc in snapshot.docs) {
        var data = doc.data();
        data['id'] = doc.id;

        // Fetch service details
        if (data['serviceId'] != null) {
          final serviceSnap = await _firestore
              .collection('services')
              .doc(data['serviceId'])
              .get();

          if (serviceSnap.exists) {
            var serviceData = serviceSnap.data()!;
            data['title'] = serviceData['title'];
            data['price'] = serviceData['price'];
            data['description'] = serviceData['description'];
          }
        }

        // exclude cancelled
        if (data['status'] != 'cancelled') {
          tempRequests.add(data);
        }
      }

      activeServices.value = tempRequests;
      isLoading.value = false;
    });
  }
  void fetchSubscriptions() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    isLoading.value = true;

    _firestore
        .collection('subscriptions')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .listen((snapshot) async {
      List<Map<String, dynamic>> tempSubs = [];

      for (var doc in snapshot.docs) {
        var data = doc.data();
        data['id'] = doc.id;

        // fetch service details
        if (data['serviceId'] != null) {
          final serviceSnap = await _firestore
              .collection('services')
              .doc(data['serviceId'])
              .get();

          if (serviceSnap.exists) {
            var serviceData = serviceSnap.data()!;
            data['title'] = serviceData['title'];
            data['price'] = serviceData['price'];
            data['description'] = serviceData['description'];
          }
        }

        // exclude expired/cancelled if you want
        if (data['status'] != 'cancelled') {
          tempSubs.add(data);
        }
      }

      subscriptions.value = tempSubs; // create an RxList in your controller
      isLoading.value = false;
    });
  }







  Future<void> updateServiceDate(String docId, DateTime newDate) async {
    try {
      await _firestore.collection('requests').doc(docId).update({
        'scheduledDate': newDate,
      });
      Get.snackbar('Success', 'Service date updated');
      listenToActiveServices(); // refresh list
    } catch (e) {
      Get.snackbar('Error', 'Failed to update date: $e');
    }
  }


  void showCancelDialog(String serviceId,String collections) {
    CustomCancelDialog.show(onConfirm: () => cancelService(serviceId,collections));
  }

  Future<void> cancelService(String serviceId,String collections) async {
    try {
      await FirebaseFirestore.instance
          .collection(collections)
          .doc(serviceId)
          .delete();

      Get.snackbar(
        "Service Cancelled",
        "Your service has been cancelled successfully.",
        backgroundColor: Colors.white,
        colorText: Colors.redAccent,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar("Error", "Failed to cancel service: $e",
          backgroundColor: Colors.redAccent.withValues(alpha: 0.1),
          colorText: Colors.redAccent);
    }
  }

  void applyFilter() {
    if (selectedStatus.value == "All") {
      requests.value = activeServices;
    } else {
      requests.value = activeServices
          .where((data) => data["status"] == selectedStatus.value)
          .toList();
    }
  }

  void setFilter(String status) {
    selectedStatus.value = status;
    applyFilter();
  }
}


