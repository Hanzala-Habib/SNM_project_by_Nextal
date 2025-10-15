
import 'package:crmproject/screens/UserServiceRequestManagement/user_service_request_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:get/get.dart';
import 'package:crmproject/screens/AdminScreen/admin_screen_controller.dart';

import '../ReviewRequestScreen/review_request_screen.dart';

class UserServiceRequestScreen extends StatelessWidget {
  final email = FirebaseAuth.instance.currentUser?.email;
  final adminController = Get.put(AdminController());
  final userServiceController = Get.put(UserServiceRequestController());

  UserServiceRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white
        ),
        title: Text('Service Requests',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFF0E2A4D),

      ),
      body: Obx(() {
        final requests = userServiceController.requests;

        return Column(
          children: [
            // 🔽 Dropdown for filtering
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButton<String>(
                value: userServiceController.selectedStatus.value,
                items: ["All", "pending", "Approved"]
                    .map((status) => DropdownMenuItem(
                  value: status,
                  child: Text(status.capitalizeFirst ?? status),
                ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    userServiceController.setFilter(value);
                  }
                },
                isExpanded: true,
              ),
            ),

            // 📋 Request list
            Expanded(
              child: requests.isEmpty
                  ? const Center(child: Text("No requests available"))
                  : ListView.builder(
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  final request = requests[index];
                  return Card(
                    margin: const EdgeInsets.all(10),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: Text(
                        request['title'] ?? 'Untitled Service',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Text("Status: ${request['status']}",style: TextStyle(
                            color:  request['status']=='Approved' ? Colors.green: Colors.red,
                            fontWeight: FontWeight.bold
                          ),),
                          if (request['price'] != null)
                            Text("Rs: ${request['price'].toInt()}"),
                          if (request['scheduledDate'] != null)
                            Text(
                              "Date: ${request['scheduledDate'].toDate().toString().split(' ')[0]}",
                            ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Icon(Icons.call,
                                    size: 24, color: Colors.green),
                                const SizedBox(width: 5),
                                GestureDetector(
                                  onTap: () async {
                                    await FlutterPhoneDirectCaller.callNumber(
                                        request['ClientNumber']);
                                  },
                                  child: Text(
                                    request['ClientNumber'] ?? '',
                                    style: TextStyle(
                                      color: Colors.blue[800],
                                      fontWeight: FontWeight.w600,
                                      fontSize: 22,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Get.to(() => ReviewRequestScreen(
                          requestId: request['id'],
                          requestData: request,
                          title: request['title'],
                          price: request['price'],
                        ));
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }),


    );
  }
}
