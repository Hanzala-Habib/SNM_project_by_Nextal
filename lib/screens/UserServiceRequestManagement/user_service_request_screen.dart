import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crmproject/screens/ClientAccountManagement/client_account_controller.dart';
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
  final clientController=Get.put(ClientAccountController());

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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButton<String>(
                value: userServiceController.selectedStatus.value,
                items: ["All", "pending", "Approved",]
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

            Expanded(
              child: DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    const TabBar(
                      labelColor: Color(0xFF0E2A4D),
                      unselectedLabelColor: Colors.grey,
                      indicatorColor:  Color(0xFF0E2A4D),
                      tabs: [
                        Tab(text: "Services"),
                        Tab(text: "Subscriptions"),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          // -------- SERVICES TAB --------
                          Obx(() {
                            final allRequests = userServiceController.allRequests;
                            final filter =userServiceController.selectedStatus.value;

                            final filteredRequests = filter == "All"
                                ? allRequests
                                : allRequests
                                .where((r) => r['status'] == filter)
                                .toList();

                            if (filteredRequests.isEmpty) {
                              return const Center(child: Text("No services found"));
                            }

                            return ListView.builder(
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
                                        if (request['isFromSubscription'] == true)
                                          Text("Subscription Month: ${request['month']}"),

                                        Text("Status: ${request['status']}",style: TextStyle(
                                            color:  request['status']=='Approved' ? Colors.green: Colors.red,
                                            fontWeight: FontWeight.bold
                                        ),),
                                        if (request['price'] != null)
                                          Text("Rs: ${request['price'].toInt()}",style: TextStyle(fontWeight: FontWeight.bold)),
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
                            );
                          }),

                          // -------- SUBSCRIPTIONS TAB --------
                          Obx(() {
                            final allSubs = userServiceController.subscriptions;

                            final filter = userServiceController.selectedStatus.value;

                            final filteredSubs = filter == "All"
                                ? allSubs
                                : allSubs.where((s) => s['status'] == filter).toList();

                            if (filteredSubs.isEmpty) {
                              return const Center(child: Text("No subscriptions found"));
                            }

                            return ListView.builder(
                              itemCount: filteredSubs.length,
                              itemBuilder: (context, index) {
                                final sub = filteredSubs[index];
                                final status = sub['status'];
                                final start =
                                (sub['startDate'] as Timestamp).toDate().toString().split(' ')[0];
                                final end =
                                (sub['endDate'] as Timestamp).toDate().toString().split(' ')[0];
                                final price=sub['price'].toInt();

                                return Card(
                                  margin: const EdgeInsets.all(10),
                                  child: ListTile(
                                    title: Text(
                                      "Subscription Name:  ${sub['title']}",
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if(status=="pending")
                                        Text("Status: $status",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.red),),
                                        if (price!= null)
                                          Text("Rs:${price}",style: TextStyle(fontWeight: FontWeight.bold),),

                                        Text("Start: $start"),
                                        Text("End: $end"),
                                        if(status=='Approved')
                                          Text("Subscription is in progress",style: TextStyle(color: Colors.green),),
                                        ElevatedButton(
                                          onPressed: () =>
                                              clientController.showCancelDialog(sub['id'],"subscriptions"),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: Row(
                                            spacing: 6,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                "Cancel Subscription",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.red,
                                                ),
                                              ),
                                              Icon(Icons.cancel, color: Colors.red),
                                            ],
                                          ),
                                        ),
                                        if(status=='Expired')
                                          Text("Subscription is Expired",style: TextStyle(fontWeight: FontWeight.w600,color: Colors.green),),
                                      ],
                                    ),
                                    trailing: const Icon(Icons.arrow_forward_ios),
                                    onTap: () {
                                      Get.to(() => ReviewRequestScreen(
                                        requestId: sub['id'],
                                        subscription:true,
                                        requestData: sub,
                                        title: sub['title'],
                                        price: sub['price'],

                                      ));
                                    },
                                  ),
                                );
                              },
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),


    );
  }
}
