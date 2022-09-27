import 'dart:io';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class PickerServices{
    Future<File?> pickImageFromGallery() async {
  File? image;
  try {
    final pickedImage =
    await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      image = File(pickedImage.path);
    }
  } catch (e) {
    Get.snackbar('Image Not Uploaded', e.toString());
  }
  return image;
}
}


