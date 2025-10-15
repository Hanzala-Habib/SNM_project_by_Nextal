import 'package:crmproject/data/repository/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginScreenController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();

  var isLoading = false.obs;
  var isPasswordHidden = true.obs;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();


  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  Future<void> login() async {
    try {
      isLoading.value = true;
      final userData = await _authRepository.loginWithEmail(
        emailController.text.trim(),
        passwordController.text.trim(),

      );

      if (userData != null) {
        String role = userData["role"] ?? "Client";
        bool access=userData["access"] ?? true;

       if(access==true){
        if (role == "Admin"){
           Get.offAllNamed("/adminScreen");
         }else if(role=="Employee"){
           Get.offAllNamed("/EmployeeScreen");
         }else{
           Get.offAllNamed("/ClientScreen");
       }
       }else{
         await FirebaseAuth.instance.signOut();
         Get.snackbar("Access Denied", "Your access is blocked by Admin.");
       }
      }
    } catch (e) {
      Get.snackbar("Login Error",""
          "Login Failed please check password and email again");
    } finally {
      isLoading.value = false;
    }
  }
  void clear(){
    emailController.clear();
    passwordController.clear();
  }
}
