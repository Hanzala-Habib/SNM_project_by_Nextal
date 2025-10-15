import 'package:crmproject/utils/widgets/custom_input_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'create_packages_controller.dart';

class CreatePackageScreen extends StatelessWidget {
  final PackagesController controller = Get.put(PackagesController());

  CreatePackageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white
        ),
        title: Text("Create Package", style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF0E2A4D),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            spacing: 10,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomInputField(
                label: "Package Name",
                controller: controller.nameController,
              ),
              CustomInputField(
                label: "Price",
                controller: controller.priceController,
              ),
              CustomInputField(
                label: "Duration In Months",
                controller: controller.durationController,
              ),

              Text(
                "Select Services",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              StreamBuilder<QuerySnapshot>(
                stream: controller.fetchAllServices(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return CircularProgressIndicator();

                  var services = snapshot.data!.docs;

                  return Obx(
                    () => Column(
                      children: services.map((doc) {
                        String serviceId = doc.id;
                        String serviceName = doc["title"];

                        return CheckboxListTile(
                          title: Text(serviceName),
                          value: controller.selectedServices.contains(
                            serviceId,
                          ),
                          onChanged: (val) {
                            controller.toggleService(serviceId);
                          },
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
              SizedBox(height: 10),

              Obx(
                () => ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () {
                          controller.createPackage();
                          Get.back();
                        },
                  child: controller.isLoading.value
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text("Create Package"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
