
import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:whatsapp_clone/app/auth/controller/user_controller.dart';


import 'package:whatsapp_clone/app/call/model/call_model.dart';
import 'package:whatsapp_clone/app/call/screens/call_screen.dart';
import 'package:whatsapp_clone/app/group/model/grou_model.dart';
import 'package:whatsapp_clone/app/services.dart/database_services.dart';


class CallController extends GetxController {
    DatabaseServices db = DatabaseServices();
    final UserController _userController = Get.find();

  Stream<DocumentSnapshot> get callStream =>
      db.callCollection.doc(_userController.user.uid).snapshots();



  void  dialCall(
   String receiverName, 
   String receiverUid,
   String receiverProfilePic, 
   bool isGroupChat
  ){
     String callId = const Uuid().v1();
      Call senderCallData = Call(
        callerId: _userController.user.uid,
        callerName: _userController.user.name,
        callerPic: _userController.user.profilePic,
        receiverId: receiverUid,
        receiverName: receiverName,
        receiverPic: receiverProfilePic,
        callId: callId,
        hasDialled: true,
      );

      Call recieverCallData = Call(
        callerId:  _userController.user.uid,
        callerName: _userController.user.name,
        callerPic: _userController.user.profilePic,
        receiverId: receiverUid,
        receiverName: receiverName,
        receiverPic: receiverProfilePic,
        callId: callId,
        hasDialled: false,
      );
      if (isGroupChat) {
        makeGroupCall(senderCallData,  recieverCallData);
      } else {
       makeCall(senderCallData,  recieverCallData);
      }

  }

    void makeCall(
    Call senderCallData,
    Call receiverCallData,
   
  ) async {
    try {
      
      
      await db.callCollection
          .doc(senderCallData.callerId)
          .set(senderCallData.toMap());
      await db.callCollection
          .doc(senderCallData.receiverId)
          .set(receiverCallData.toMap());

     Get.to(()=> CallScreen(
            channelId: senderCallData.callId,
            call: senderCallData,
            isGroupChat: false,
          )); 
    } catch (e) {
       Get.snackbar("Call Not Dial", e.toString());
    }
  }

  void makeGroupCall(
    Call senderCallData,
    Call receiverCallData,
  ) async {
    try {
      await db.callCollection
          .doc(senderCallData.callerId)
          .set(senderCallData.toMap());

      var groupSnapshot = await db.groupCollection
          .doc(senderCallData.receiverId)
          .get();
     GroupModel group =  GroupModel.fromMap(groupSnapshot.data() as Map<String, dynamic>);

      for (var id in group.membersUid) {
        await db.callCollection
            .doc(id)
            .set(receiverCallData.toMap());
      }
     

      Get.to(()=> 
 CallScreen(
            channelId: senderCallData.callId,
            call: senderCallData,
            isGroupChat: true,
          )
      );
    } catch (e) {
      Get.snackbar("Call Not Dial", e.toString());
    }
  }

  void endCall(
    String callerId,
    String receiverId,
  ) async {
    try {
      await db.callCollection.doc(callerId).delete();
      await db.callCollection.doc(receiverId).delete();
    } catch (e) {
      Get.snackbar("Call Not Deleted", e.toString());
    }
  }

  void endGroupCall(
    String callerId,
    String receiverId,
  ) async {
    try {
      await db.callCollection.doc(callerId).delete();
      var groupSnapshot =
          await db.groupCollection.doc(receiverId).get();
     GroupModel group = GroupModel.fromMap(groupSnapshot.data() as Map<String, dynamic>);
      for (var id in group.membersUid) {
        await db.callCollection.doc(id).delete();
      }
    } catch (e) {
         Get.snackbar("Call Not Deleted", e.toString());
    }
  }
}