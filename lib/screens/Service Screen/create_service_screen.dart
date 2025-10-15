import 'package:crmproject/screens/AdminServiceManagementScreen/admin_service_management_screen.dart';
import 'package:crmproject/screens/Service%20Screen/service_screen_controller.dart';
import 'package:crmproject/utils/widgets/save_button.dart';
import 'package:crmproject/utils/widgets/custom_input_field.dart';
import 'package:crmproject/utils/widgets/description_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreateServiceScreen extends StatelessWidget {
  final ServiceController serviceController = Get.put(ServiceController());
  CreateServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Create Service",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFF0E2A4D),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            spacing: 10,
            children: [
              CustomInputField(
                  label: 'Service Title',
                  controller: serviceController.titleController),
              CustomInputField(
                  label: 'Price',
                  keyboardType: TextInputType.number,
                  controller: serviceController.priceController),
              DescriptionField(
                hintText:
                'Enter the service description which helps users to better understand...',
                descriptionController:
                serviceController.descriptionController,
              ),

              Obx(() => Column(
                children: [
                  GestureDetector(
                    onTap: serviceController.pickImage,
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: serviceController.selectedImage.value != null
                          ? Image.file(
                        serviceController.selectedImage.value!,
                        fit: BoxFit.cover,
                      )
                          : const Center(
                        child: Text("Tap to upload service image"),
                      ),
                    ),
                  ),
                  if (serviceController.isUploading.value)
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    ),
                ],
              )),

              SaveButton(onPressed: () async {
                await serviceController.saveService();
                Get.off(() => AdminServiceManagementScreen());
              }),
            ],
          ),
        ),
      ),
    );
  }
}
