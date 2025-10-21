import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crmproject/screens/AdminScreen/admin_screen_controller.dart';
import 'package:crmproject/screens/orderConfirmScreen/order_confirm_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:get/get.dart';

import '../Service Details Screen/service_details_screen.dart';
import '../UserSubscriptionScreen/user_subscription_controller.dart';
import 'client_screen_controller.dart';

class ClientScreen extends StatelessWidget {
  final String title;
  final AdminController controller = Get.put(AdminController());
  final subController = Get.put(SubscriptionController());
  final clientController = Get.put(ClientProfileController());

  ClientScreen({super.key, this.title = 'SNM Services'});

  @override
  Widget build(BuildContext context) {

    // final user = FirebaseAuth.instance.currentUser;
    // if (user != null) {
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     RatingService.checkAndShowRatingDialog(context, user.uid);
    //   });
    // }
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),

        backgroundColor: Color(0xFF0E2A4D),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child:  FirebaseAuth.instance.currentUser == null
            ? const Center(child: CircularProgressIndicator())
            :StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('services').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final services = snapshot.data!.docs;

            if (services.isEmpty) {
              return const Center(child: Text("No services available"));
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text("Featured Services",style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20
                ),),

                CarouselSlider(
                  options: CarouselOptions(
                    height: 150,
                    autoPlay: true,
                    enableInfiniteScroll: true,
                    autoPlayCurve: Curves.fastOutSlowIn,
                    viewportFraction: 0.8,
                  ),
                  items: services.asMap().entries.map((entry){
                    final index=entry.key;
                    final service=clientController.services[index];
                    return Builder(
                      builder: (BuildContext context) {
                        return GestureDetector(
                          onTap: () {

                            subController.showBottomSheet.value=true;

                            Get.to(
                              () => ServiceDetailsScreen(
                                serviceData: service.toMap(),

                              ),
                            );
                          },
                          child: Card(
                            color: Colors.blueGrey[100],
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 80,
                                    width: 300,

                                    decoration: BoxDecoration(
                                      borderRadius:  BorderRadius.only(
                                        topLeft: Radius.circular(12),
                                        topRight: Radius.circular(12),
                                      ),
                                      image: DecorationImage(
                                        image: NetworkImage(service.imageUrl),
                                        fit: BoxFit.cover, // makes it fill the box nicely
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          service.title,
                                          style: const TextStyle(
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.deepPurple,
                                          ),
                                          softWrap: true,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Rs. ${service.price.toInt()}',
                                        style: const TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.pink,
                                        ),
                                      ),
                                    ],
                                  )

                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),

                Text("All Services",style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20
                ),),
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8.0,
                          mainAxisSpacing: 8.0,
                          childAspectRatio: 1.0,
                        ),
                    itemCount: services.length,
                    itemBuilder: (BuildContext context, int index) {
                      final service =clientController.services[index];
                      final name = service.title;

                      return GestureDetector(
                        onTap: () {
                          subController.showBottomSheet.value=true;
                          Get.to(
                            () => ServiceDetailsScreen(
                              serviceData:clientController.services[index].toMap(),



                            ),
                          );
                        },
                        child: Card(
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
                                      image: NetworkImage(service.imageUrl ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Column(
                                  crossAxisAlignment:CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: const TextStyle(
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      softWrap: true,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                    ' Rs. ${service.price.toInt()}',
                                      style: const TextStyle(
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.pink
                                      ),
                                      softWrap: true,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),


    );
  }
}


