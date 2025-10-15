
import 'package:crmproject/screens/LoginScreen/login_screen_controller.dart';
import 'package:crmproject/screens/SignUpScreen/sign_up_screen.dart';
import 'package:crmproject/utils/widgets/custom_input_field.dart';
import 'package:crmproject/utils/widgets/custom_password_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:get/get.dart';

import '../../data/services/fcm_service.dart';
import '../AdminScreen/admin_screen_controller.dart';

class LoginScreen extends StatelessWidget {
  final LoginScreenController loginScreenController = Get.put(
    LoginScreenController(),
  );
  final adminResetPasswordController=Get.put(AdminController());

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final number = '+923091678178';
    final _formKey = GlobalKey<FormState>();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 20,

                children: [
                  SizedBox(height: 100),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 110,
                        width: 100,
                        child: Image.asset('assets/images/snm-logo.png'),
                      ),
                      SizedBox(
                        height: 50,
                        child: Image.asset('assets/images/Untitled-3.png'),
                      ),
                    ],
                  ),
                  if(loginScreenController.emailController.text.isNotEmpty)
                  Container(
                    alignment: Alignment.centerRight,
                    child: RichText(
                      textAlign: TextAlign.end,
                      text: TextSpan(
                        text: "Forget Password",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: Colors.blue,
                        ),
                     recognizer: TapGestureRecognizer()
                     ..onTap = () {
                          adminResetPasswordController.resetPassword(loginScreenController.emailController.text.trim());
                       }

                      ),
                    ),
                  ),
                  CustomInputField(
                    label: "Email",
                    controller: loginScreenController.emailController,
                  ),
                  Obx(
                    () => CustomPasswordField(
                      label: "Password",
                      controller: loginScreenController.passwordController,
                      isHidden: loginScreenController.isPasswordHidden.value,
                      onToggle: loginScreenController.togglePasswordVisibility,
                    ),
                  ),

                  Obx(
                    () => ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            await loginScreenController.login();  // wait for login
                            final user = FirebaseAuth.instance.currentUser;
                            if (user != null) {
                              await FCMService.saveTokenToFirestore(user.uid,);

                            } else {
                             Get.snackbar("Token is null", "missing fcm token");
                            }


                            loginScreenController.clear();
                          }
                        },
                      style: ElevatedButton.styleFrom(fixedSize: Size(300, 50)),
                      child: loginScreenController.isLoading.value
                          ? CircularProgressIndicator()
                          : Text(
                              "Sign In",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      text: "Don't have an account",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color: Colors.black,
                      ),
                      children: [
                        WidgetSpan(child: SizedBox(width: 10)),
                        TextSpan(
                          text: "Sign Up",
                          style: TextStyle(
                            color: Colors.purple,
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Get.to(SignUpScreen());
                            },
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.call, size: 22),
                      SizedBox(width: 5),
                      RichText(
                        text: TextSpan(
                          text: "0321-8783630",
                          style: TextStyle(
                            color: Colors.blue[800],
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () async {
                              await FlutterPhoneDirectCaller.callNumber(number);
                              Get.snackbar(
                                "Calling to SNM solutions",
                                "Please wait out support agent will get to you soon",
                              );
                            },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
