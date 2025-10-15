import 'package:crmproject/screens/FullClientManagement/full_client_management_screen.dart';
import 'package:crmproject/screens/UserSubscriptionScreen/user_subscription_controller.dart';
import 'package:crmproject/utils/widgets/save_button.dart';
import 'package:crmproject/utils/widgets/custom_date_time_field.dart';
import 'package:crmproject/utils/widgets/custom_input_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'order_confirm_controller.dart';


class OrderScreen extends StatelessWidget {
  final Map<String, dynamic> serviceData;
  final controller = Get.put(OrderController());
  final subscribeController = Get.put(SubscriptionController());

  OrderScreen({super.key, required this.serviceData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          "Order ${serviceData['title']}",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Color(0xFF0E2A4D),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            spacing: 10,
            children: [
              CustomInputField(
                controller: controller.mobileNumber,
                label: "Mobile Number",
                keyboardType: TextInputType.phone,
              ),
              CustomDateField(
                label: "Select Date",
                controller: controller.dateController,
                onChanged: (val) {
                  controller.setDate(val!);
                },
              ),
        
        
              Obx(() => Column(
                children: [
                  // Image upload UI
                  controller.selectedImage.value != null
                      ? Image.file(
                    controller.selectedImage.value!,
                    height: 150,
                    width: 300,
                    fit: BoxFit.cover,
                  )
                      : Container(
                    height: 150,
                    width: 300,
                    color: Colors.grey[300],
                    alignment: Alignment.center,
                    child: Text("No Image Selected"),
                  ),
                  SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: controller.pickImage,
                    icon: Icon(Icons.upload),
                    label: Text("Upload Image"),
                  ),
        
                  // 👇 Spinner above button when loading
                  if (controller.isLoading.value) ...[
                    SizedBox(height: 20),
                    CircularProgressIndicator(),
                    SizedBox(height: 10),
                    Text("Processing your request..."),
                  ],
        
                  // Confirm Button
                  SaveButton(
                    buttonText: "Confirm",
                    onPressed: () async {
                      controller.isLoading.value = true;
                      try {
                        final userId = subscribeController.auth.currentUser!.uid;
                        final imageUrl = await controller.uploadImage(userId);
        
                         subscribeController.createRequest(
                          userId: userId,
                          serviceId: serviceData['id'],
                          scheduledDate: controller.scheduledDate,
                          mobileNumber: controller.mobileNumber.text.trim(),
                          paymentReceiptUrl: imageUrl,
                        );
        
                        Get.offAll(() => FullClientManagementScreen());
        
                        Get.snackbar(
                          "Order Confirmed!",
                          "Technician will contact you one hour before the scheduled time.",
                        );
                      } catch (e) {
                       print(e.toString());
                      } finally {
                        controller.isLoading.value = false;
                      }
                    },
                  ),
                ],
              ))
        
            ],
          ),
        ),
      ),
    );
  }
}
