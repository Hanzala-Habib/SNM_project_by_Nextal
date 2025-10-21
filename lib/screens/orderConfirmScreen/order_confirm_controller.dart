import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderController extends GetxController {
  final timeController = TextEditingController();
  final dateController = TextEditingController();
  final secondDateController = TextEditingController();
  final mobileNumber = TextEditingController();
  RxBool isLoading=false.obs;

  DateTime? scheduledDate;
  DateTime? secondDate;
  final RxString imageUrl = ''.obs;
  final Rx<File?> selectedImage = Rx<File?>(null);
  final picker = ImagePicker();

  void setDate(DateTime date) {
    scheduledDate = date;
  }

  void setSecondDate(DateTime date) {
    secondDate = date;
  }


  /// pick image from gallery or camera
  Future<void> pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      selectedImage.value = File(picked.path);
      isLoading.value=false;
    }
  }

  /// upload image to Firebase Storage and return the download URL
  Future<String?> uploadImage(String userId) async {
    try {
      if (selectedImage.value == null) {
        Get.snackbar("No Image", "Please select an image before confirming");
        return null;
      }

      final file = selectedImage.value!;
      final ref = FirebaseStorage.instance
          .ref()
          .child('order_images')
          .child('${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg');

      final uploadTask = await ref.putFile(file);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      imageUrl.value = downloadUrl;
      return downloadUrl;
    } catch (e) {
      Get.snackbar("Upload Failed", e.toString());
      return null;
    }
  }
}
