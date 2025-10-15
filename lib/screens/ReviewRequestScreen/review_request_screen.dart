
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crmproject/screens/EmployeeScreen/employee_service_controller.dart';
import 'package:crmproject/screens/ReviewRequestScreen/review_screen_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReviewRequestScreen extends StatelessWidget {
  final String requestId;
  final Map<String, dynamic> requestData;
  final double price;
  final String title;
  final reviewController=Get.put(ReviewScreenController());
final employeeScreenController=Get.put(EmployeeServiceController());
 ReviewRequestScreen({
    super.key,
    required this.requestId,
    required this.requestData,
    required this.title, required this.price,
  });



  @override
  Widget build(BuildContext context) {
print(title);
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white
        ),
        title: const Text("Review Request",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
        backgroundColor:Color(0xFF0E2A4D),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: Color(0xFF0E2A4D)),
            ),
            const SizedBox(height: 10),
            Text("Client Number: ${requestData['ClientNumber'] ?? 'N/A'}",style: TextStyle(fontWeight: FontWeight.w600)),
            Text("Status: ${requestData['status']}",style: TextStyle(fontWeight: FontWeight.w600),),
            Text("Price: ${price.toInt()}",style: TextStyle(fontWeight: FontWeight.w600),),
            const SizedBox(height: 20),

            // 🔹 Show Payment Receipt
            if (requestData['paymentReceiptUrl'] != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Payment Receipt:",
                      style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Image.network(
                    requestData['paymentReceiptUrl'],
                    height: 250,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) =>
                    const Text("Error loading image"),
                  ),
                ],
              )
            else
              const Text("No payment receipt uploaded."),

            const SizedBox(height: 20),
            if (requestData['status'] == 'pending')
              const Text(
                "Assign Employees:",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF0E2A4D)),
              ),
              const SizedBox(height: 8),
            if (requestData['status'] == 'pending')
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("Employees")
                    .where("role", isEqualTo: "Employee")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final employees = snapshot.data!.docs;

                  return Obx(() => Wrap(
                    spacing: 6.0,
                    children: employees.map((emp) {
                      final empId = emp.id;
                      final empName = emp['name'] ?? 'Unnamed';
                      final isSelected = reviewController.selectedEmployeeIds.contains(empId);

                      return FilterChip(
                        label: Text(empName),
                        selected: isSelected,
                        selectedColor: Colors.green[100],
                        onSelected: (selected) {
                          if (selected) {
                            reviewController.selectedEmployeeIds.add(empId);
                          } else {
                            reviewController.selectedEmployeeIds.remove(empId);
                          }
                        },
                      );
                    }).toList(),
                  ));
                },
              ),
              const SizedBox(height: 20),
            if (requestData['status'] == 'pending')
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => reviewController.assignEmployeesAndApprove(requestId),
                    icon: const Icon(Icons.check_circle, color: Colors.white),
                    label: const Text("Approve",style: TextStyle(color: Colors.white),),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => reviewController.assignEmployeesAndApprove('rejected'),
                    icon: const Icon(Icons.cancel, color: Colors.white),
                    label: const Text("Reject",style: TextStyle(color: Colors.white),),
                    style:
                    ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
