import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';



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
        .where("status", isEqualTo: 'active')
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
    String? packageId,
    List<dynamic> serviceId = const [],
    required String type,
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
      "packageId": packageId,
      "serviceId": serviceId,
      "type": type,
      "startDate": startDate,
      "endDate": endDate,
      "status": "active", // subscription status
      "monthlyTracking": monthlyTracking,
      "createdAt": DateTime.now(),
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



  Future<void> createRequest({
    required String serviceId,
    required String userId,
    DateTime? scheduledDate,
  }) async {
    // final requestDate = scheduledDate ?? DateTime.now();
    //
    // final docRef=
    await _firestore.collection("requests").add({
      "serviceId": serviceId,
      "userId": userId,
      "technicianId": null,
      "status": "pending",
      "scheduledDate": scheduledDate ?? DateTime.now(),
      "startTime": null,
      "endTime": null,
      "scheduledTime":scheduledTime,
      "reason": null,
      "rating": null,
      "location": selectedLocation,
    });

    // await LocalNotificationService.scheduleNotification(
    //   id: docRef.id.hashCode,
    //   title: "Upcoming Service",
    //   body: "Your service is scheduled tomorrow!",
    //   scheduledDate: requestDate.subtract(const Duration(days: 1)),
    // );
    //
    // await LocalNotificationService.scheduleNotification(
    //   id: docRef.id.hashCode + 1,
    //   title: "Service Reminder",
    //   body: "Your service starts in 1 hour!",
    //   scheduledDate: requestDate.subtract(const Duration(hours: 1)),
    // );
  }

  Future<void> acceptRequest(String requestId, String technicianId) async {
    await _firestore.collection("requests").doc(requestId).update({
      "status": "accepted",
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
