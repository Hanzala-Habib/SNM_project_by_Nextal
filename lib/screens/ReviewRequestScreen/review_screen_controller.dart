import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class ReviewScreenController extends GetxController{

  final RxList<String> selectedEmployeeIds = <String>[].obs;



  Future<void> assignEmployeesAndApprove(
      String requestId) async {
    await FirebaseFirestore.instance.collection('requests').doc(requestId).update({
      'assignedEmployees': selectedEmployeeIds,
      'status': 'Approved',
    });

    Get.back();
    Get.snackbar("Success", "Employees assigned and request approved");
  }
}