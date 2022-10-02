import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:whatsapp_clone/app/auth/controller/user_controller.dart';
import 'package:whatsapp_clone/app/model/user_model.dart';
import 'package:whatsapp_clone/app/services.dart/database_services.dart';
import 'package:whatsapp_clone/app/status/model/status_model.dart';

class StatusController extends GetxController {
  DatabaseServices db = DatabaseServices();
  final UserController _userController = Get.find();

  void uploadStatus({
    required String username,
    required String profilePic,
    required String phoneNumber,
    required File statusImage,
  }) async {
    try {
      var statusId = Uuid().v1();
      String uid = _userController.user.uid;
      String imageUrl = await _userController.storeFileToFirebase(
          '/status/$statusId$uid', statusImage);
      List<Contact> contacts = [];
      if (await FlutterContacts.requestPermission()) {
        contacts = await FlutterContacts.getContacts(withProperties: true);
      }

      List<String> uidWhoCanSee = [];
      for (int i = 0; i < contacts.length; i++) {
        var userDataFirebase = await db.userCollection
            .where(
              'phoneNumber',
              isEqualTo: contacts[i].phones[0].number.replaceAll(
                    ' ',
                    '',
                  ),
            )
            .get();

        if (userDataFirebase.docs.isNotEmpty) {
          var userData = UserModel.fromMap(
              userDataFirebase.docs[0].data() as Map<String, dynamic>);
          uidWhoCanSee.add(userData.uid);
        }
      }
      List<String> statusImageUrls = [];
      var statusesSnapshot = await db.statusCollection
          .where(
            'uid',
            isEqualTo: _userController.currentUser.uid,
          )
          .get();
      if (statusesSnapshot.docs.isNotEmpty) {
        Status status = Status.fromMap(
            statusesSnapshot.docs[0].data() as Map<String, dynamic>);
        statusImageUrls = status.photoUrl;
        statusImageUrls.add(imageUrl);
        await db.statusCollection.doc(statusesSnapshot.docs[0].id).update({
          'photoUrl': statusImageUrls,
        });
        return;
      } else {
        statusImageUrls = [imageUrl];
      }

      Status status = Status(
        uid: uid,
        username: username,
        phoneNumber: phoneNumber,
        photoUrl: statusImageUrls,
        createdAt: DateTime.now(),
        profilePic: profilePic,
        statusId: statusId,
        whoCanSee: uidWhoCanSee,
      );

      await db.statusCollection.doc(statusId).set(status.toMap());
    } on FirebaseException catch (e) {
      Get.snackbar("Status Not Uploaded", e.toString());
    }
  }

  Future<List<Status>> getStatus() async {
    List<Status> statusData = [];
    try {
      List<Contact> contacts = [];
      if (await FlutterContacts.requestPermission()) {
        contacts = await FlutterContacts.getContacts(withProperties: true);
      }
      for (int i = 0; i < contacts.length; i++) {
        var statusesSnapshot = await db.statusCollection
            .where(
              'phoneNumber',
              isEqualTo: contacts[i].phones[0].number.replaceAll(
                    ' ',
                    '',
                  ),
            )
            .where(
              'createdAt',
              isGreaterThan: DateTime.now()
                  .subtract(const Duration(hours: 24))
                  .millisecondsSinceEpoch,
            )
            .get();
        for (var tempData in statusesSnapshot.docs) {
          Status tempStatus =
              Status.fromMap(tempData.data() as Map<String, dynamic>);
          if (tempStatus.whoCanSee.contains(_userController.user.uid)) {
            statusData.add(tempStatus);
          }
        }
        for (int i = 0; i < contacts.length; i++) {
          var statusesSnapshot = await db.statusCollection
              .where(
                'phoneNumber',
                isEqualTo: contacts[i].phones[0].number.replaceAll(
                      ' ',
                      '',
                    ),
              )
              .where(
                'createdAt',
                isGreaterThan: DateTime.now()
                    .subtract(const Duration(hours: 24))
                    .millisecondsSinceEpoch,
              )
              .get();
          for (var tempData in statusesSnapshot.docs) {
            Status tempStatus =
                Status.fromMap(tempData.data() as Map<String, dynamic>);
            if (tempStatus.whoCanSee.contains(_userController.user.uid)) {
              statusData.add(tempStatus);
            }
          }
        }
      }
    } catch (e) {
       if (kDebugMode) print(e);
      Get.snackbar("Status Not Uploaded", e.toString());
    }
    return statusData;
  }
}
