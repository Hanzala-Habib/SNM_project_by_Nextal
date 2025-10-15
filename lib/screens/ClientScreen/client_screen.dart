import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crmproject/screens/AdminScreen/admin_screen_controller.dart';
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
      bottomSheet:Obx(() {
        if (subController.hasActiveSubscription.value==false &&
            subController.showBottomSheet.value==true && clientController.services.isNotEmpty) {

      final uid = FirebaseAuth.instance.currentUser!.uid;
      final firestore = FirebaseFirestore.instance;
      Future<Map<String, dynamic>?> loadPackageWithServiceNames() async {
        final snap = await firestore.collection('packages').limit(1).get();
        if (snap.docs.isEmpty) return null;
        final doc = snap.docs.first;
        final Map<String, dynamic> data = Map<String, dynamic>.from(doc.data() as Map);

        // Normalize services -> try to convert ids to names if needed
        final servicesField = data['services'];
        final List<String> serviceNames = [];
        final List<int> servicePrice=[];

        if (servicesField is List) {
          for (var item in servicesField) {
            if (item is String) {
              // item might be a serviceId, attempt to fetch the service doc
              try {
                final serviceDoc = await firestore.collection('services').doc(item).get();
                if (serviceDoc.exists) {
                  final sdata = serviceDoc.data() as Map<String, dynamic>;
                  serviceNames.add(sdata['title']?.toString() ?? item);
                  servicePrice.add(sdata['price']?.toInt()?? item);
                } else {
                  // if no doc, treat the string as a human-friendly name
                  serviceNames.add(item);
                }
              } catch (e) {
                serviceNames.add(item);
              }
            } else if (item is Map) {
              // if you stored full objects in array
              serviceNames.add(item['name']?.toString() ?? item.toString());
            } else {
              serviceNames.add(item.toString());
            }
          }
        }

        data['serviceNames'] = serviceNames;
        data['id'] = doc.id;
        return data;
      }

      return FutureBuilder<Map<String, dynamic>?>(
        future: loadPackageWithServiceNames(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return Container(
              height: 120,
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            );
          }

          if (!snap.hasData || snap.data == null) {
            return SizedBox.shrink();
          }

          final packageData = snap.data!;
          final packageId = packageData['id'] as String? ?? '';
          final serviceNames = List<String>.from(packageData['serviceNames'] ?? []);
          final pkgName = packageData['name'] ?? 'Package';
          final pkgPrice = packageData['price']?.toString() ?? '-';
          final pkgDuration = packageData['durationMonths']?.toString() ?? '-';

          return Container(
            height: 300,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(35),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  pkgName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Duration: $pkgDuration months",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600
                  ),
                ),
                const SizedBox(height: 12),

                // show service list
                if (serviceNames.isNotEmpty) ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Services included:",
                      style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    height: 90,
                    child: ListView(
                      shrinkWrap: true,
                      children: serviceNames
                          .map((s) => Text("• $s", style: const TextStyle(fontSize: 14)))
                          .toList(),
                    ),
                  ),
                ] else
                  const Text("No services listed"),

                const Spacer(),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.close, color: Colors.white),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.withValues(alpha: 0.8), // CHANGED: valid opacity
                      ),
                      onPressed: () {
                        // CHANGED: hide the persistent bottom sheet using controller flag
                        subController.showBottomSheet.value = false;
                      },
                      label: const Text("Close", style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 18)),
                    ),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                      ),
                      onPressed: () async {
                        // CHANGED: pass the real packageId (string) to createSubscription
                        await subController.createSubscription(
                          userId: uid,
                          packageId: packageId,
                          serviceId:packageData['services'],
                          type: "package",
                          durationMonths: packageData['durationMonths'],
                        );
                        subController.hasActiveSubscription.value = true;
                        subController.showBottomSheet.value = false;
                        Get.snackbar("Subscribed", "$pkgName subscribed successfully");
                      },
                      child: Text("Buy : $pkgPrice", style: const TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 18)),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    }
        return SizedBox.shrink();
      }
      ),

    );
  }
}


