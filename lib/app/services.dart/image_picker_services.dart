import 'dart:io';

import 'package:enough_giphy_flutter/enough_giphy_flutter.dart';
import 'package:flutter/material.dart';
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

Future<File?> pickVideoFromGallery() async {
  File? video;
  try {
    final pickedVideo =
    await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (pickedVideo != null) {
      video = File(pickedVideo.path);
    }
  } catch (e) {
    Get.snackbar('Image Not Uploaded', e.toString());
  }
  return video;
}

Future<GiphyGif?> pickGIF(BuildContext context) async {
  GiphyGif? gif;
  try {
    gif = await Giphy.getGif(
    
      apiKey: 'UOUCmoVh9wOUEtUFqe4OCs2anDMbw4IR', context: context,
    );
  } catch (e) {
    Get.snackbar('GIF Not Picked', e.toString());
  }
  return gif;
}
}


