import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../data/services/local_notification_service.dart';



class SubscriptionController extends GetxController {
  final _firestore = FirebaseFirestore.instance;

  var userSubscriptions = <Map<String, dynamic>>[].obs;
  var userRequests = <Map<String, dynamic>>[].obs;
  var hasActiveSubscription = false.obs;
  final auth = FirebaseAuth.instance;
  var showBottomSheet = true.obs;
  String? selectedLocation;
  var scheduledTime;

  @override
  void onClose() {
    print("MyController closed!");
    super.onClose();
  }
  @override
  void onInit() {
    super.onInit();
    checkSubscription();
  }

  Future<void> checkSubscription() async {
    final uid = auth.currentUser?.uid;
    if (uid == null) return;

    final subSnap = await _firestore
        .collection("subscriptions")
        .where("userId", isEqualTo: uid)
        .where("status", isEqualTo: 'pending')
        .get();

    hasActiveSubscription.value = subSnap.docs.isNotEmpty;
    if (hasActiveSubscription.value) {
      showBottomSheet.value = false;
    }
  }

  Future<void> fetchUserSubscriptions(String userId) async {
    final snapshot = await _firestore
        .collection("subscriptions")
        .where("userId", isEqualTo: userId)
        .get();

    userSubscriptions.value =
        snapshot.docs.map((doc) => {...doc.data(), "id": doc.id}).toList();
  }

  Future<void> createSubscription({
    required String userId,
    required scheduledDate,
    required secondScheduledDate,
    required String mobileNumber,
    required String paymentReceipt,
    // String? packageId,
    required String serviceId,
    // required String type,
    required int durationMonths,
  }) async {
    final startDate = DateTime.now();


    final endDate = DateTime(
      startDate.year,
      startDate.month + durationMonths,
      startDate.day,
    );

    final List<Map<String, dynamic>> monthlyTracking = List.generate(durationMonths, (index) {
      final monthStart = DateTime(startDate.year, startDate.month + index, startDate.day);
      final monthEnd = DateTime(startDate.year, startDate.month + index + 1, startDate.day)
          .subtract(const Duration(days: 1));

      return {
        "month": index + 1,
        "startDate": monthStart,
        "endDate": monthEnd,
        "status": "pending", // can be "pending", "completed", "expired"
      };
    });

    await _firestore.collection("subscriptions").add({
      "userId": userId,
      // "packageId": packageId,
      "serviceId": serviceId,
      // "type": type,
      "startDate": startDate,
      "endDate": endDate,
      "scheduledDate":scheduledDate,
      "secondScheduledDate":secondScheduledDate,
      "status": "pending", // subscription status
      "monthlyTracking": monthlyTracking,
      "createdAt": DateTime.now(),
      "mobileNumber":mobileNumber,
      "paymentReceiptUrl":paymentReceipt
    });
  }

  Future<void> checkAndUpdateSubscriptions() async {
    final now = DateTime.now();

    final snapshot = await _firestore
        .collection("subscriptions")
        .where("status", isEqualTo: "active")
        .get();

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final endDate = (data["endDate"] as Timestamp).toDate();
      final monthlyTracking = List<Map<String, dynamic>>.from(data["monthlyTracking"]);


      if (now.isAfter(endDate)) {
        await doc.reference.update({"status": "expired"});
        continue;
      }


      for (int i = 0; i < monthlyTracking.length; i++) {
        final monthStart = (monthlyTracking[i]["startDate"] as Timestamp).toDate();
        final monthEnd = (monthlyTracking[i]["endDate"] as Timestamp).toDate();

        if (now.isAfter(monthEnd) && monthlyTracking[i]["status"] == "pending") {

          monthlyTracking[i]["status"] = "month passed without service";
        } else if (now.isAfter(monthStart) && now.isBefore(monthEnd)) {

          monthlyTracking[i]["status"] = "active";
        }
      }

      await doc.reference.update({"monthlyTracking": monthlyTracking});
    }
  }

  Future<void> generateMonthlyRequests() async {
    final now = DateTime.now();
    final snapshot = await _firestore
        .collection('subscriptions')
        .where('status', isEqualTo: 'active')
        .get();

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final monthlyTracking = List<Map<String, dynamic>>.from(data['monthlyTracking']);
      final userId = data['userId'];
      final serviceId = data['serviceId'];
      final mobileNumber = data['mobileNumber'];

      for (var month in monthlyTracking) {
        final monthStart = (month['startDate'] as Timestamp).toDate();
        final monthEnd = (month['endDate'] as Timestamp).toDate();

        // Only create a request if we are inside this month and it's still pending
        if (now.isAfter(monthStart) && now.isBefore(monthEnd) && month['status'] == 'pending') {
          // Check if this month's request already exists
          final existing = await _firestore
              .collection('requests')
              .where('subscriptionId', isEqualTo: doc.id)
              .where('month', isEqualTo: month['month'])
              .get();

          if (existing.docs.isEmpty) {
            await _firestore.collection('requests').add({
              'subscriptionId': doc.id,
              'month': month['month'],
              'serviceId': serviceId,
              'userId': userId,
              'ClientNumber': mobileNumber,
              'status': 'pending',
              'scheduledDate': now,
              'createdAt': now,
              'isFromSubscription': true,
            });

            month['status'] = 'created';
          }
        }
      }

      await doc.reference.update({'monthlyTracking': monthlyTracking});
    }
  }


  Future<void> createRequest({
    required String serviceId,
    required String userId,
    DateTime? secondScheduledDate,
    String? paymentReceiptUrl,
    DateTime? scheduledDate,
    required String mobileNumber,
  }) async {
    final requestDate = scheduledDate ?? DateTime.now();

    final docRef= await _firestore.collection("requests").add({
      "serviceId": serviceId,
      "userId": userId,
      "technicianId": null,
      "ClientNumber":mobileNumber,
      "status": "pending",
      "scheduledDate": scheduledDate ?? DateTime.now(),
      "secondScheduledDate":secondScheduledDate,
      "startTime": null,
      "endTime": null,
      "scheduledTime":scheduledTime,
      "reason": null,
      "rating": null,
      "isFromSubscription": false,
      "location": selectedLocation,
      "paymentReceiptUrl": paymentReceiptUrl,
    });

    await LocalNotificationService.scheduleNotification(
      id: docRef.id.hashCode,
      title: "Upcoming Service",
      body: "Your service is scheduled tomorrow!",
      scheduledDate: requestDate.subtract(const Duration(days: 1)),
    );

    await LocalNotificationService.scheduleNotification(
      id: docRef.id.hashCode + 1,
      title: "Service Reminder",
      body: "Your service starts in 1 hour!",
      scheduledDate: requestDate.subtract(const Duration(hours: 1)),
    );
  }

  Future<void> approveRequest(String requestId, String technicianId) async {
    await _firestore.collection("requests").doc(requestId).update({
      "status": "Approved",
      "technicianId": technicianId,
      "startTime": DateTime.now(),
    });
  }


  Future<void> completeRequest(String requestId) async {
    await _firestore.collection("requests").doc(requestId).update({
      "status": "completed",
      "endTime": DateTime.now(),
    });
  }


  Future<void> addReason(String requestId, String reason) async {
    await _firestore.collection("requests").doc(requestId).update({
      "status": "cancelled",
      "reason": reason,
    });
  }

  Future<void> addRating(String requestId, int rating) async {
    await _firestore.collection("requests").doc(requestId).update({
      "rating": rating,
    });
  }
}
