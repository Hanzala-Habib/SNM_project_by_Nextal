import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../orderConfirmScreen/order_confirm_screen.dart';


class ServiceDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> serviceData;

  const ServiceDetailsScreen({super.key, required this.serviceData});

  @override
  Widget build(BuildContext context) {
    print("ServiceData received: $serviceData");
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white
        ),
        title: Text('Service Details',style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold
        ),),
        backgroundColor:Color(0xFF0E2A4D),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              Text(

                serviceData['title'] ?? 'no id found',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 10),

              Text(
                serviceData['description'] ?? 'No description available.',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),

              if (serviceData['price'] != null)
                Container(
                  color: Colors.grey.withValues(alpha: 0.5),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "RS: ${serviceData['price'].toInt()} PKR",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Get.to(() => OrderScreen(serviceData: serviceData));
            },
            child: Text("Buy Service", style: TextStyle(fontSize: 18,color: Colors.white)),
          ),
        ),
      ),
    );

  }
}
