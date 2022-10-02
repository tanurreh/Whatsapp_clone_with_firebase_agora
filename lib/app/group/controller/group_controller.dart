import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:whatsapp_clone/app/auth/controller/user_controller.dart';
import 'package:whatsapp_clone/app/group/model/grou_model.dart';
import 'package:whatsapp_clone/app/services.dart/database_services.dart';

   


class GroupController extends GetxController {
   DatabaseServices db = DatabaseServices();
  final UserController _userController = Get.find();
   FirebaseFirestore firestore = FirebaseFirestore.instance;
   
  void createGroup(
      String name, File profilePic, List<Contact> selectedContact) async {
    try {
      List<String> uids = [];
      for (int i = 0; i < selectedContact.length; i++) {
        var userCollection = await firestore
            .collection('Users')
            .where(
              'phoneNumber',
              isEqualTo: selectedContact[i].phones[0].number.replaceAll(
                    ' ',
                    '',
                  ),
            )
            .get();
        if (userCollection.docs.isNotEmpty && userCollection.docs[0].exists) {
          uids.add(userCollection.docs[0].data()['uid'] as String);
        }
      }
      var groupId = const Uuid().v1();
       String profileUrl =
      await  _userController.storeFileToFirebase('group/$groupId', profilePic);
      GroupModel group = GroupModel(
        senderId: _userController.user.uid,
        name: name,
        groupId: groupId,
        lastMessage: '',
        groupPic: profileUrl,
        membersUid: [_userController.user.uid, ...uids],
        timeSent: DateTime.now(),
      );
      await db.groupCollection.doc(groupId).set(group.toMap());
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }
}