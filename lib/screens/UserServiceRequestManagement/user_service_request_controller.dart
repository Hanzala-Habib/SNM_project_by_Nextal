import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class UserServiceRequestController extends GetxController {
  final _db = FirebaseFirestore.instance;
  final userId = FirebaseAuth.instance.currentUser!.uid;

  RxList<Map<String, dynamic>> allRequests = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> requests = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> subscriptions = <Map<String, dynamic>>[].obs;
  RxString selectedStatus = "All".obs;
  RxBool isLoading=true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchServices();
    fetchSubscriptions();
  }

  void fetchServices() {
    _db
        .collection("requests")
        .where("status", whereIn: ["pending", "Approved"])
        // .where("isFromSubscription", isEqualTo: true)
        .snapshots()
        .listen((snapshot) async {
      if (snapshot.docs.isEmpty) {
        requests.value = [];
        return;
      }

      final futures = snapshot.docs.map((doc) async {
        var data = doc.data();
        data["id"] = doc.id;

        if (data["serviceId"] != null) {
          var serviceSnap =
          await _db.collection("services").doc(data["serviceId"]).get();
          if (serviceSnap.exists) {
            var serviceData = serviceSnap.data()!;
            data["title"] = serviceData["title"];
            data["price"] = serviceData["price"];
          }
        }
        return data;
      }).toList();

      final results = await Future.wait(futures);
      allRequests.value = results;
      applyFilter();
    });
  }
  void fetchSubscriptions() {
    final _firestore = FirebaseFirestore.instance;

    _firestore.collection('subscriptions').snapshots().listen((snapshot) async {
      List<Map<String, dynamic>> tempSubs = [];

      for (var doc in snapshot.docs) {
        var data = doc.data();
        data['id'] = doc.id;


        if (data['serviceId'] != null) {
          final serviceSnap =
          await _firestore.collection('services').doc(data['serviceId']).get();

          if (serviceSnap.exists) {
            var serviceData = serviceSnap.data()!;
            data['title'] = serviceData['title'];
            data['price'] = serviceData['annualPrice'];
            data['description'] = serviceData['description'];
          }
        }

        // 🔹 Add all (you can remove condition if you want *all*)
        tempSubs.add(data);
      }

      // ✅ Update reactive list
      subscriptions.value = tempSubs;
      isLoading.value = false;
    });
  }

  void applyFilter() {
    if (selectedStatus.value == "All") {
      requests.value = allRequests;
    } else {
      requests.value = allRequests
          .where((data) => data["status"] == selectedStatus.value)
          .toList();
    }
  }

  void setFilter(String status) {
    selectedStatus.value = status;
    applyFilter();
  }
}
