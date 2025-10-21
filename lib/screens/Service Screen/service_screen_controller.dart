import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ServiceController extends GetxController {
  final titleController = TextEditingController();
  final priceController = TextEditingController();
  final descriptionController = TextEditingController();
  final annualPriceController = TextEditingController();

  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  final Rx<File?> selectedImage = Rx<File?>(null);
  final RxBool isUploading = false.obs;


  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      selectedImage.value = File(image.path);
    }
  }

  Future<void> saveService() async {
    try {
      isUploading.value = true;
      String? imageUrl;

      // Upload image if selected
      if (selectedImage.value != null) {
        final ref = _storage
            .ref()
            .child('service_images')
            .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

        await ref.putFile(selectedImage.value!);
        imageUrl = await ref.getDownloadURL();
      }

      await _firestore.collection("services").add({
        "title": titleController.text.trim(),
        "price": double.tryParse(priceController.text.trim()) ?? 0.0,
        "annualPrice":double.tryParse(annualPriceController.text.trim())??0.0,
        "description": descriptionController.text.trim(),
        "imageUrl": imageUrl ?? "",
        "createdAt": FieldValue.serverTimestamp(),
      });

      Get.snackbar("Success", "Service saved successfully");
      clearFields();
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isUploading.value = false;
    }
  }

  Future<void> deleteService(String id) async {
    await _firestore.collection('services').doc(id).delete();
    Get.snackbar("Deleted", "Service removed successfully");
  }

  void clearFields() {
    titleController.clear();
    priceController.clear();
    descriptionController.clear();
    selectedImage.value = null;
  }
}
