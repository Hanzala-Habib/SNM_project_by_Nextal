import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crmproject/screens/AdminScreen/admin_screen_controller.dart';
import 'package:crmproject/screens/SignUpScreen/sign_up_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/widgets/custom_list_card.dart';

class EmployeeManagementScreen extends StatelessWidget {
  final AdminController adminController = Get.put(AdminController());

  EmployeeManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color(0xFF0E2A4D),
        title: Text(
          "Employees",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Employees')
              .snapshots(),
          builder:(context,snapshot){
            if (snapshot.connectionState==ConnectionState.waiting){
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError){
              return Center(
                child: Text("Error fetching employees"),
              );
            }
            final employees=snapshot.data!.docs;

            return Column(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount:employees.length,
                  itemBuilder: (context, index) {
                    final employee = employees[index];
                    return CustomListCard(user: employee,controller: adminController,);
                  },
                ),

              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.off(() => SignUpScreen(buttonText: 'Add Employee'));
        },
        backgroundColor: Colors.deepPurple,
        child: const Icon(
          Icons.add,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
