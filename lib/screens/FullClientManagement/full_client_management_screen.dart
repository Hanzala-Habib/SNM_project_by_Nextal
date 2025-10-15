import 'package:crmproject/screens/ClientAccountManagement/client_account_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../ClientScreen/client_screen.dart';
import 'client_nav_controller.dart';

class FullClientManagementScreen extends StatelessWidget {
  FullClientManagementScreen({super.key});

  final List<Widget> _screens = [
    ClientScreen(),
    ClientAccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ClientNavController());

    return Obx(() => Scaffold(
      body: _screens[controller.selectedIndex.value],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: controller.selectedIndex.value,
        onTap: controller.changeTab,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Color(0xFF0E2A4D),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined,size: 22,fontWeight: FontWeight.bold),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_2_outlined,size: 22,fontWeight: FontWeight.bold,),
            label: 'My Account',

          ),
        ],
      ),
    ));
  }
}
