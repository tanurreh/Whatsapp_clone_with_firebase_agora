
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:whatsapp_clone/app/auth/controller/user_controller.dart';
import 'package:whatsapp_clone/app/data/constants.dart';
import 'package:whatsapp_clone/app/status/controller/status_conntroller.dart';

class ConfirmStatusScreen extends StatelessWidget {
  final File file;
 ConfirmStatusScreen({
    Key? key,
    required this.file,
  }) : super(key: key);

   final  UserController _userController = Get.find();
   final  StatusController _statusController = Get.put(StatusController());

 

  @override
  Widget build(
    BuildContext context,
  ) {
 
    var user = _userController.user;
    return Scaffold(
      body: Center(
        child: AspectRatio(
          aspectRatio: 9 / 16,
          child: Image.file(file),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(
          Icons.done,
          color: Colors.white,
        ),
        onPressed: () {
          _statusController.uploadStatus(
              username: user.name,
              statusImage: file,
              profilePic: user.profilePic,
              phoneNumber: user.phoneNumber);
        },
        backgroundColor: CustomColor.tabColor,
      ),
    );
  }
}
