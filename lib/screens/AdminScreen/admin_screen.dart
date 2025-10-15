import 'package:crmproject/screens/AdminScreen/admin_screen_controller.dart';
import 'package:crmproject/screens/AdminServiceManagementScreen/admin_service_management_screen.dart';
import 'package:crmproject/screens/CreatePackagesScreen/create_packages_screen.dart';
import 'package:crmproject/screens/EmployeeManagement/employee_management_screen.dart';
import 'package:crmproject/screens/LoginScreen/login_screen.dart';
import 'package:crmproject/screens/UserServiceRequestManagement/user_service_request_screen.dart';
import 'package:crmproject/utils/widgets/admin_services_card.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../UserManagementScreen/user_management_screen.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AdminController controller = Get.put(AdminController());

    controller.fetchUsers();
    controller.fetchEmployees();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Admin Panel", style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF0E2A4D),
        actions: [
          IconButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Get.to(()=>LoginScreen());
                Get.snackbar("Logged Out", "You are logged out");
              },
              icon: const Icon(Icons.logout,color: Colors.white,))
        ],
      ),
      body:SingleChildScrollView(
          child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                spacing: 10,
                children: [
                  AdminServicesCard(onPressed: (){
                    Get.to(()=>UserServiceRequestScreen());
                  },
                    cardtext: "Manage Requests",),
                  AdminServicesCard(onPressed: (){
                    Get.to(()=>AdminServiceManagementScreen());
                  },
                  cardtext: "Create and manage Services",),
                  AdminServicesCard(onPressed: (){
                    Get.to(()=>CreatePackageScreen());
                  },
                    cardtext: "Create Packages for users",),



                  AdminServicesCard(onPressed: (){
                    Get.to(()=>EmployeeManagementScreen());
                  },
                    cardtext: "Manage Employees",),

                  AdminServicesCard(onPressed: (){
                    Get.to(()=>UserManagementScreen());
                  },
                    cardtext: "Client Management",),

                ],
              ),
            ),
          ),

    );
  }
}
