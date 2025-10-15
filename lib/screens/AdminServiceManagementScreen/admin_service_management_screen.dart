import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crmproject/screens/AdminScreen/admin_screen.dart';
import 'package:crmproject/screens/Service%20Screen/create_service_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Service Screen/service_screen_controller.dart';

class AdminServiceManagementScreen extends StatelessWidget {
  final serviceController = ServiceController();

  AdminServiceManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          "Services Management",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
    leading: IconButton(onPressed: (){
      Get.off(()=>AdminScreen());
    }, icon: Icon(Icons.arrow_back,color: Colors.white,),),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('services').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text("Error fetching services"));
            }

            final services = snapshot.data!.docs;

            if (services.isEmpty) {
              return const Center(child: Text("No services available"));
            }
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
                childAspectRatio: 1.0,
              ),
              itemCount: services.length,
              itemBuilder: (BuildContext context, int index) {
                final service = services[index];
                final name = service['title'] ?? 'Unnamed Service';

                return Card(
                  color: Colors.blueGrey[100],
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          height: 70,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                            image: DecorationImage(
                              image: NetworkImage(service['imageUrl'] ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width:100,
                                    child: Text(
                                      name,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      softWrap: true,

                                    ),
                                  ),
                                  Text(
                                    ' Rs. ${service['price'].toInt()}',
                                    style: const TextStyle(
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.pink,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                width: 30,
                                child: PopupMenuButton<String>(
                                  icon: const Icon(
                                    Icons.more_vert,
                                    color: Colors.black,
                                  ),
                                  onSelected: (value) async {
                                    if (value == 'Delete') {
                                      serviceController.deleteService(
                                        service.id,
                                      );
                                    } else if (value == 'Edit') {
                                      Get.to(() => CreateServiceScreen());
                                    }
                                  },
                                  itemBuilder: (BuildContext context) => [
                                    PopupMenuItem(
                                      value: 'Delete',
                                      child: Text("Delete"),
                                    ),
                                    PopupMenuItem(
                                      value: 'Edit',
                                      child: Text("Edit"),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => CreateServiceScreen());
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
