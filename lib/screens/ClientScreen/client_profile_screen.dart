import 'package:crmproject/screens/AdminScreen/admin_screen_controller.dart';

import 'package:crmproject/screens/ClientScreen/client_screen_controller.dart';
import 'package:crmproject/screens/LoginScreen/login_screen.dart';
import 'package:crmproject/utils/widgets/save_button.dart';
import 'package:crmproject/utils/widgets/custom_input_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ClientProfileScreen extends StatelessWidget {
  final ClientProfileController clientProfileController=Get.put(ClientProfileController());
  final AdminController adminController=Get.put(AdminController());
  final String name;
  final String dbname;
 ClientProfileScreen({super.key,this.name='SNM Products', this.dbname='users'});
  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
        title: const Text("Client Details", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(onPressed: (){
            Get.to(()=>LoginScreen());
            Get.snackbar("Logged Out", "You are logged out");
          }, icon: Icon(Icons.logout,color: Colors.white,))
        ],
        leading: IconButton(onPressed: (){
          Get.back();
        }, icon: Icon(Icons.arrow_back,color: Colors.white,)),

      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(

          spacing: 15,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Enter your Details",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            CustomInputField(
              label: 'Address',
              controller: clientProfileController.addressController,
            ),
            CustomInputField(
              label: "Mobile Number",
              controller: clientProfileController.mobileController,
            ),
            SaveButton(
              onPressed: () async {
                await clientProfileController.saveClientDetails(dbname);
                // Get.offAll(() =>  ClientScreen(title: 'Client Products',));
              },
            ),
          ],
        ),
      ),
    );
  }
}

