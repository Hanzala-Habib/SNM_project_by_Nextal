import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class UserServiceRequestController extends GetxController {
  final _db = FirebaseFirestore.instance;
  final userId = FirebaseAuth.instance.currentUser!.uid;

  RxList<Map<String, dynamic>> allRequests = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> requests = <Map<String, dynamic>>[].obs;
  RxString selectedStatus = "All".obs;

  @override
  void onInit() {
    super.onInit();
    fetchServices();
  }

  void fetchServices() {
    _db
        .collection("requests")
        .where("status", whereIn: ["pending", "Approved",])
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
