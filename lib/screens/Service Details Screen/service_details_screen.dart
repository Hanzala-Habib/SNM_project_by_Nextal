
import 'package:crmproject/screens/UserSubscriptionScreen/user_subscription_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../orderConfirmScreen/order_confirm_screen.dart';


class ServiceDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> serviceData;

  const ServiceDetailsScreen({super.key, required this.serviceData});

  @override
  Widget build(BuildContext context) {
    // final price = serviceData['annualPrice'].toDouble();

    final subController=Get.put(SubscriptionController())
;    return Scaffold(
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

              SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Get.to(() => OrderScreen(serviceData: serviceData));
                        },
                        child: Text("Buy:  ${serviceData['price'].toInt()}/Month", style: TextStyle(fontSize: 18,color: Colors.white)),
                      ),

                    ],
                  )
              ),


            ],
          ),
        ),
      ),

      bottomSheet: Obx(() {
        if (
            subController.showBottomSheet.value == true) {
          final price = serviceData['annualPrice'].toDouble();
          final discountedPrice = price - (price * 0.02);

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
                  "Annual subscription",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Duration: 12 months",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Annual: Rs ${price.toStringAsFixed(0)}",
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                      style: const TextStyle(
                        decoration: TextDecoration.lineThrough,
                        fontSize: 18,
                        color: Colors.red,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    Text(
                      " Buy Now and Get this only in ",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    Text(
                      "Rs:${discountedPrice.toStringAsFixed(0)}\n with (2% OFF)",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    )
                  ],
                ),

               const Spacer(),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.close, color: Colors.white),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        subController.showBottomSheet.value = false;
                      },
                      label: const Text(
                        "Close",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Get.to(() => OrderScreen(
                          serviceData: serviceData,
                          subscription: true,
                        ));
                      },
                      child: Text(
                        " Rs ${discountedPrice.toStringAsFixed(0)}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        } else {
          return const SizedBox.shrink(); // return nothing if condition false
        }
      }),

    );}
}
