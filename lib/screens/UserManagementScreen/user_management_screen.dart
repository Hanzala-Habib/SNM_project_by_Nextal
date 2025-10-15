
import 'package:crmproject/screens/AdminScreen/admin_screen_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/widgets/custom_list_card.dart';
import '../SignUpScreen/sign_up_screen.dart';

class UserManagementScreen extends StatelessWidget {
  final AdminController adminController=Get.put(AdminController());
  UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color(0xFF0E2A4D),
        title: Text("User",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
    
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount:adminController.users.length,
              itemBuilder: (context, index) {
                final user = adminController.users[index];
                return CustomListCard(user: user, controller: adminController);
              },
            ),
            
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(onPressed: (){
        Get.to(()=>SignUpScreen(buttonText: 'Add Employee',));
      },
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add, color: Colors.white,fontWeight:FontWeight.bold,),
      ),
    );
  }
}
