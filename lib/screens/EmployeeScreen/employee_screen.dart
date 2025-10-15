
import 'package:crmproject/screens/AdminScreen/admin_screen_controller.dart';
import 'package:crmproject/screens/EmployeeScreen/employee_service_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:get/get.dart';
import '../LoginScreen/login_screen.dart';

class EmployeeServicesScreen extends StatelessWidget {
  final email = FirebaseAuth.instance.currentUser?.email;
  final name = FirebaseAuth.instance.currentUser?.displayName;
  final employeeServiceController = Get.put(EmployeeServiceController());
  final adminController = Get.put(AdminController());

  EmployeeServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    print('request${employeeServiceController.requests}');
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          name ?? 'Snm Employee',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.settings, color: Colors.white),
            onSelected: (value) async {
              if (value == 'logout') {
                await FirebaseAuth.instance.signOut();
                Get.to(() => LoginScreen());
              } else if (value == 'reset') {
                adminController.resetPassword(email ?? '');
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: const [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text("Logout"),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'reset',
                child: Row(
                  children: const [
                    Icon(Icons.lock_reset, color: Colors.blue),
                    SizedBox(width: 8),
                    Text("Reset Password"),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'address',
                child: Row(
                  children: const [
                    Icon(Icons.home, color: Colors.green),
                    SizedBox(width: 8),
                    Text("Update Address"),
                  ],
                ),
              ),
            ],
          ),
        ],
        backgroundColor:Color(0xFF0F3565),
      ),
      body: Obx(() {
        if (employeeServiceController.requests.isEmpty) {
          return Center(child: Text("No services available"));
        }
        return ListView.builder(
          itemCount: employeeServiceController.requests.length,
          itemBuilder: (context, index) {
            var request = employeeServiceController.requests[index];
            return Card(
              margin: EdgeInsets.all(10),
              child: ListTile(
                title: Text(
                  request["title"] ?? 'no title in requests',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Price: ${request["price"] ?? 'N/A'} "),
                    Text(" Status: ${request["status"]}"),
                    if (request["scheduledDate"] != null)
                      Text(
                        "Scheduled Date: ${request["scheduledDate"].toDate().toLocal().toString().split(" ")[0]}",
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(Icons.call, size: 22, color: Colors.green),
                          SizedBox(width: 5),
                          RichText(
                            text: TextSpan(
                              text: request['ClientNumber'],
                              style: TextStyle(
                                color: Colors.blue[800],
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () async {
                                  await FlutterPhoneDirectCaller.callNumber(
                                    request['ClientNumber'],
                                  );
                                  Get.snackbar(
                                    "Calling to Client",
                                    "Please wait ",
                                  );
                                },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (request["status"] == "Approved" &&
                    (request["assignedEmployees"] != null &&
                        (request["assignedEmployees"] as List ).contains(employeeServiceController.userId)))
                      ElevatedButton(
                        onPressed: () => employeeServiceController
                            .startService(request["id"]),
                        child: Text("Start",style: TextStyle(color: Colors.green,fontWeight: FontWeight.bold),),
                      ),
                    if (request["status"] == "started" &&
            (request["assignedEmployees"] != null &&
                        (request["assignedEmployees"] as List ).contains(employeeServiceController.userId)))
                      ElevatedButton(
                        onPressed: () => employeeServiceController
                            .endService(request["id"]),
                        child: Text("End",style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold),),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
