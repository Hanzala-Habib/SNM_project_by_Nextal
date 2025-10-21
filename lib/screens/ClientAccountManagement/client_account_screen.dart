import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../AdminScreen/admin_screen_controller.dart';
import '../ClientScreen/client_profile_screen.dart';
import '../LoginScreen/login_screen.dart';
import 'client_account_controller.dart';

class ClientAccountScreen extends StatelessWidget {
  const ClientAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final clientController = Get.put(ClientAccountController());
    final  controller = Get.put(AdminController());
    final email = FirebaseAuth.instance.currentUser?.email;
    final name = FirebaseAuth.instance.currentUser?.displayName;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Account',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),

        backgroundColor: Color(0xFF0E2A4D),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.settings, color: Colors.white),
            onSelected: (value) async {
              if (value == 'logout') {
                await FirebaseAuth.instance.signOut();
                Get.offAll(() => LoginScreen());
              } else if (value == 'reset') {
                controller.resetPassword(email!);
              } else if (value == 'address') {
                Get.to(() => ClientProfileScreen(name: name!));
              }else{
                Get.to(()=>ClientProfileScreen(name: FirebaseAuth.instance.currentUser!.uid,dbname:'users',));
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
        ],),
      body: Obx(() {
        final requests=clientController.requests;
        if (clientController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButton<String>(
                value: clientController.selectedStatus.value,
                items: ["All", "pending", "Approved"]
                    .map((status) => DropdownMenuItem(
                  value: status,
                  child: Text(status.capitalizeFirst ?? status),
                ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    clientController.setFilter(value);
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
                            final allRequests = clientController.requests;
                            final filter = clientController.selectedStatus.value;

                            final filteredRequests = filter == "All"
                                ? allRequests
                                : allRequests
                                .where((r) => r['status'] == filter)
                                .toList();

                            if (filteredRequests.isEmpty) {
                              return const Center(child: Text("No services found"));
                            }

                            return ListView.builder(
                              itemCount:requests.length,
                              itemBuilder: (context, index) {
                                final service =clientController.requests[index];
                                final status = service['status'];
                                final date = (service['scheduledDate'] as Timestamp).toDate();
                                return Card(
                                  margin: const EdgeInsets.all(10),
                                  child: ListTile(
                                    title: Text(
                                      "Service: ${service['title']}",
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Column(
                                      spacing: 4,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Status: $status",
                                          style: TextStyle(fontWeight: FontWeight.w600),
                                        ),
                                        Text(
                                          "Date: ${date.toString().split(' ')[0]}",
                                          style: TextStyle(fontWeight: FontWeight.w600),
                                        ),
                                        if(status=='Approved')
                                          Text("Service is in progress",style: TextStyle(color: Colors.green),),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [

                                            if(status=='pending')
                                              ElevatedButton(
                                                onPressed: () async {
                                                  final newDate = await showDatePicker(
                                                    context: context,
                                                    initialDate: date,
                                                    firstDate: DateTime.now(),
                                                    lastDate: DateTime.now().add(
                                                      const Duration(days: 30),
                                                    ),
                                                  );
                                                  if (newDate != null) {
                                                    clientController.updateServiceDate(
                                                      service['id'],
                                                      newDate,
                                                    );
                                                  }
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.white,

                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                ),
                                                child: Row(
                                                  spacing: 4,
                                                  children: [
                                                    Text(
                                                      "Edit Date",
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                    Icon(Icons.edit, color: Colors.blue),
                                                  ],
                                                ),
                                              ),
                                            if(status=='pending')
                                              ElevatedButton(
                                                onPressed: () =>
                                                    clientController.showCancelDialog(service['id'],"requests"),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                ),
                                                child: Row(
                                                  spacing: 6,
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: const [
                                                    Text(
                                                      "Cancel Service",
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.w600,
                                                        color: Colors.red,
                                                      ),
                                                    ),
                                                    Icon(Icons.cancel, color: Colors.red),
                                                  ],
                                                ),
                                              ),
                                            if(status=='claimed'|| status=='started' )
                                              Text("Service is in progress",style: TextStyle(fontWeight: FontWeight.w600,color: Colors.green),),
                                            if(status=='completed')
                                              Text("Service is Completed",style: TextStyle(fontWeight: FontWeight.w600,color: Colors.green),),

                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          }),

                          // -------- SUBSCRIPTIONS TAB --------
                          Obx(() {
                            final allSubs = clientController.subscriptions;
                            final filter = clientController.selectedStatus.value;

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

                                return Card(
                                  margin: const EdgeInsets.all(10),
                                  child: ListTile(
                                    title: Text(
                                      "Subscription: ${sub['title']}",
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Status: $status"),
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
                                              children: const [
                                                Text(
                                                  "Cancel Service",
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
                                          Text("Service is Expired",style: TextStyle(fontWeight: FontWeight.w600,color: Colors.green),),
                                      ],
                                    ),
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

            // Expanded(
            //   child:  requests.isEmpty
            //       ? const Center(child: Text("No requests available"))
            //       : StreamBuilder<QuerySnapshot>(
            //     stream:FirebaseFirestore.instance.collection('requests').snapshots(),
            //     builder: (context, asyncSnapshot) {
            //       return ListView.builder(
            //         itemCount:requests.length,
            //         itemBuilder: (context, index) {
            //           final service =clientController.requests[index];
            //           final status = service['status'];
            //           final date = (service['scheduledDate'] as Timestamp).toDate();
            //           return Card(
            //             margin: const EdgeInsets.all(10),
            //             child: ListTile(
            //               title: Text(
            //                 "Service: ${service['title']}",
            //                 style: TextStyle(fontWeight: FontWeight.bold),
            //               ),
            //               subtitle: Column(
            //                 spacing: 4,
            //                 crossAxisAlignment: CrossAxisAlignment.start,
            //                 children: [
            //                   Text(
            //                     "Status: $status",
            //                     style: TextStyle(fontWeight: FontWeight.w600),
            //                   ),
            //                   Text(
            //                     "Date: ${date.toString().split(' ')[0]}",
            //                     style: TextStyle(fontWeight: FontWeight.w600),
            //                   ),
            //                   if(status=='Approved')
            //                     Text("Service is in progress",style: TextStyle(color: Colors.green),),
            //                   Row(
            //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //                     children: [
            //
            //                       if(status=='pending')
            //                         ElevatedButton(
            //                           onPressed: () async {
            //                             final newDate = await showDatePicker(
            //                               context: context,
            //                               initialDate: date,
            //                               firstDate: DateTime.now(),
            //                               lastDate: DateTime.now().add(
            //                                 const Duration(days: 30),
            //                               ),
            //                             );
            //                             if (newDate != null) {
            //                               clientController.updateServiceDate(
            //                                 service['id'],
            //                                 newDate,
            //                               );
            //                             }
            //                           },
            //                           style: ElevatedButton.styleFrom(
            //                             backgroundColor: Colors.white,
            //
            //                             shape: RoundedRectangleBorder(
            //                               borderRadius: BorderRadius.circular(12),
            //                             ),
            //                           ),
            //                           child: Row(
            //                             spacing: 4,
            //                             children: [
            //                               Text(
            //                                 "Edit Date",
            //                                 style: TextStyle(
            //                                   fontWeight: FontWeight.w600,
            //                                 ),
            //                               ),
            //                               Icon(Icons.edit, color: Colors.blue),
            //                             ],
            //                           ),
            //                         ),
            //                       if(status=='pending')
            //                         ElevatedButton(
            //                           onPressed: () =>
            //                               clientController.showCancelDialog(service['id'],"requests"),
            //                           style: ElevatedButton.styleFrom(
            //                             backgroundColor: Colors.white,
            //                             shape: RoundedRectangleBorder(
            //                               borderRadius: BorderRadius.circular(12),
            //                             ),
            //                           ),
            //                           child: Row(
            //                             spacing: 6,
            //                             mainAxisSize: MainAxisSize.min,
            //                             children: const [
            //                               Text(
            //                                 "Cancel Service",
            //                                 style: TextStyle(
            //                                   fontWeight: FontWeight.w600,
            //                                   color: Colors.red,
            //                                 ),
            //                               ),
            //                               Icon(Icons.cancel, color: Colors.red),
            //                             ],
            //                           ),
            //                         ),
            //                       if(status=='claimed'|| status=='started' )
            //                         Text("Service is in progress",style: TextStyle(fontWeight: FontWeight.w600,color: Colors.green),),
            //                       if(status=='completed')
            //                         Text("Service is Completed",style: TextStyle(fontWeight: FontWeight.w600,color: Colors.green),),
            //
            //                     ],
            //                   ),
            //                 ],
            //               ),
            //             ),
            //           );
            //         },
            //       );
            //     }
            //   ),
            // ),
          ],
        );
      }),
    );
  }
}
