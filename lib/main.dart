import 'dart:developer';
import 'package:crmproject/screens/AdminScreen/admin_screen.dart';
import 'package:crmproject/screens/EmployeeScreen/employee_screen.dart';
import 'package:crmproject/screens/FullClientManagement/full_client_management_screen.dart';
import 'package:crmproject/screens/LoginScreen/login_screen.dart';
import 'package:crmproject/screens/SignUpScreen/sign_up_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'data/services/local_notification_service.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log("Background/Terminated message: ${message.notification?.title}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  LocalNotificationService.init();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
    _initFCM();
  }


  Future<void> _initFCM() async {
    await FirebaseMessaging.instance.requestPermission();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      if (notification != null) {
        LocalNotificationService.showInstantNotification(
          notification.title ?? 'No Title',
          notification.body ?? 'No Body',
        );
      }
    });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        _showPage("Opened from background: ${message.notification?.title}");
      });


    RemoteMessage? initialMessage =
    await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _showPage(
          "Opened from terminated: ${initialMessage.notification?.title}");
    }
  }

  void _showPage(String text) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: const Text("Notification Clicked")),
          body: Center(child: Text(text)),
        ),
      ),
    );
  }

  Widget _getInitialScreen() {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 🔹 If not logged in
        if (!snapshot.hasData) return LoginScreen();

        final user = snapshot.data!;

        // 🔹 Fetch user role
        return FutureBuilder<DocumentSnapshot>(
          future: _getUserDocument(user.uid),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final data = userSnapshot.data?.data() as Map<String, dynamic>?;
            final role = data?["role"];

            if (role == "Admin") return const AdminScreen();
            if (role == "Employee") return EmployeeServicesScreen();
            if (role == "Client") return FullClientManagementScreen();

            return LoginScreen();
          },
        );
      },
    );
  }



  Future<DocumentSnapshot> _getUserDocument(String uid) async {
    final userDoc =
    await FirebaseFirestore.instance.collection("users").doc(uid).get();
    if (userDoc.exists) return userDoc;

    final employeeDoc =
    await FirebaseFirestore.instance.collection("employees").doc(uid).get();
    return employeeDoc;
  }


  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      home: _getInitialScreen(),
      getPages: [
        GetPage(name: "/signup", page: () => const SignUpScreen()),
        GetPage(name: "/login", page: () => LoginScreen()),
        GetPage(name: "/ClientScreen", page: () =>FullClientManagementScreen()),
        GetPage(name: "/adminScreen", page: () => const AdminScreen()),
        GetPage(name: "/EmployeeScreen", page: () =>  EmployeeServicesScreen()),
      ],
      debugShowCheckedModeBanner: false,
    );
  }
}
