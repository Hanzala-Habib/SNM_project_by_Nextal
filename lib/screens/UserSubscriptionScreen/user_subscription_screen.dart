import 'package:crmproject/screens/UserSubscriptionScreen/user_subscription_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';





class UserSubscriptionsScreen extends StatelessWidget {
  final   controller = Get.put(SubscriptionController());
  final String userId;

  UserSubscriptionsScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    controller.fetchUserSubscriptions(userId);

    return Scaffold(
      appBar: AppBar(title: Text("My Subscriptions")),
      body: Obx(() {
        if (controller.userSubscriptions.isEmpty) {
          return Center(child: Text("No subscriptions found"));
        }
        return ListView.builder(
          itemCount: controller.userSubscriptions.length,
          itemBuilder: (context, index) {
            final sub = controller.userSubscriptions[index];
            return ListTile(
              title: Text(sub["type"] == "package"
                  ? "Package: ${sub['packageId']}"
                  : "Service: ${sub['serviceId']}"),
              subtitle: Text("Status: ${sub['status']}"),
              trailing: ElevatedButton(
                child: Text("Request"),
                onPressed: () {
                  controller.createRequest(
                    serviceId: sub["serviceId"] ?? "choose-service-id",
                    userId: userId, mobileNumber: '',
                  );
                },
              ),
            );
          },
        );
      }),
    );
  }
}
