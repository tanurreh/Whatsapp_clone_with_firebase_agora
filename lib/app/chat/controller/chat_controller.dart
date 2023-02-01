import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:whatsapp_clone/app/auth/controller/auth_controller.dart';
import 'package:whatsapp_clone/app/auth/controller/user_controller.dart';
import 'package:whatsapp_clone/app/chat/chat_enum.dart';
import 'package:whatsapp_clone/app/chat/model/chat_contact_model.dart';
import 'package:whatsapp_clone/app/chat/model/message_model.dart';
import 'package:whatsapp_clone/app/group/model/grou_model.dart';
import 'package:whatsapp_clone/app/model/user_model.dart';
import 'package:whatsapp_clone/app/services.dart/database_services.dart';

import '../../group/model/grou_model.dart';

class ChatController extends GetxController {
  DatabaseServices db = DatabaseServices();
  final AuthController _authController = Get.find();
  final UserController _userController = Get.find();

  void _saveDataToContactsSubcollection(
    UserModel senderUserData,
    UserModel? recieverUserData,
    String text,
    DateTime timeSent,
    String recieverUserId,
    bool isGroupChat,
  ) async {
    if (isGroupChat) {
      await db.groupCollection.doc(recieverUserId).update({
        'lastMessage': text,
        'timeSent': DateTime.now().millisecondsSinceEpoch,
      });
    } else {
      //reciver
      var recieverChatContact = ChatContact(
          name: senderUserData.name,
          profilePic: senderUserData.profilePic,
          contactId: senderUserData.uid,
          timeSent: timeSent,
          lastMessage: text);
      await db.userCollection
          .doc(recieverUserId)
          .collection('chats')
          .doc(_authController.user.uid)
          .set(recieverChatContact.toMap());

      //sender
      var senderChatContact = ChatContact(
          name: recieverUserData!.name,
          profilePic: recieverUserData.profilePic,
          contactId: recieverUserData.uid,
          timeSent: timeSent,
          lastMessage: text);
      await db.userCollection
          .doc(_authController.user.uid)
          .collection('chats')
          .doc(recieverUserId)
          .set(senderChatContact.toMap());
    }
  }

  void _saveMessageToMessageSubCollection({
    required String text,
    required String recieverUserId,
    required DateTime timeSent,
    required String messageId,
    required String username,
    required String? reciverUsername,
    required MessageEnum messageType,
    required bool isGroupChat,
  }) async {
    print(isGroupChat);
    var message = Message(
      senderId: _authController.user.uid,
      recieverid: recieverUserId,
      text: text,
      type: messageType,
      timeSent: timeSent,
      messageId: messageId,
      isSeen: false,
    );

    if (isGroupChat) {
      await db.groupCollection
          .doc(recieverUserId)
          .collection('chats')
          .doc(messageId)
          .set(
            message.toMap(),
          );
    } else {
      ///sender
      await db.userCollection//collection name ha
          .doc(_authController.user.uid)// document ha
          .collection('chats')// sub collection ha
          .doc(recieverUserId)
          .collection('message')
          .doc(messageId)
          .set(message.toMap());

      /// reciever
      await db.userCollection
          .doc(recieverUserId)
          .collection('chats')
          .doc(_authController.user.uid)
          .collection('message')
          .doc(messageId)
          .set(message.toMap());
    }
  }

  void sendTextMessage({
    required String text,
    required String recieverUserId,
    required UserModel senderUser,
    required bool isGroupChat,
  }) async {
    try {
      var timeSent = DateTime.now();
      UserModel? reciverUserData;

      if (!isGroupChat) {
        var userDataMap = await db.userCollection.doc(recieverUserId).get();
        reciverUserData =
            UserModel.fromMap(userDataMap.data() as Map<String, dynamic>);
      }
      var messageId = Uuid().v1();
      _saveDataToContactsSubcollection(senderUser, reciverUserData, text,
          timeSent, recieverUserId, isGroupChat);

      _saveMessageToMessageSubCollection(
        username: senderUser.name,
        recieverUserId: recieverUserId,
        text: text,
        timeSent: timeSent,
        messageId: messageId,
        messageType: MessageEnum.text,
        reciverUsername: reciverUserData?.name,
        isGroupChat: isGroupChat,
      );
    } on FirebaseException catch (e) {
      Get.snackbar("Message Not Sent", e.toString());
    }
  }

  // Streaming Functions
  Stream<List<ChatContact>> getChatContacts() {
    return db.userCollection
        .doc(_userController.user.uid)
        .collection('chats')
        .snapshots()
        .asyncMap((event) async {
      List<ChatContact> contacts = [];
      for (var document in event.docs) {
        var chatContact = ChatContact.fromMap(document.data());
        var userData = await db.userCollection.doc(chatContact.contactId).get();
        var user = UserModel.fromMap(userData.data() as Map<String, dynamic>);

        contacts.add(
          ChatContact(
            name: user.name,
            profilePic: user.profilePic,
            contactId: chatContact.contactId,
            timeSent: chatContact.timeSent,
            lastMessage: chatContact.lastMessage,
          ),
        );
      }
      return contacts;
    });
  }

  Stream<List<Message>> getChatStream(String recieverUserId) {
    return db.userCollection
        .doc(_userController.user.uid)
        .collection('chats')
        .doc(recieverUserId)
        .collection('message')
        .orderBy('timeSent')
        .snapshots()
        .map((event) {
      List<Message> messages = [];
      for (var element in event.docs) {
        messages.add(Message.fromMap(element.data()));
      }
      return messages;
    });
  }

  void sendFileMessage({
    required File file,
    required MessageEnum messageEnum,
    required String recieverUserId,
    required UserModel senderUserData,
    required bool isGroupChat,
  }) async {
    try {
      var timeSent = DateTime.now();
      var messageId = Uuid().v1();
      String imageUrl = await _userController.storeFileToFirebase(
          "chat/${messageEnum.type}/${senderUserData.uid}/$recieverUserId/$messageId",
          file);

      UserModel? reciverUserData;

      if (!isGroupChat) {
        var userDataMap = await db.userCollection.doc(recieverUserId).get();
        reciverUserData =
            UserModel.fromMap(userDataMap.data() as Map<String, dynamic>);
      }

      String contactMsg;

      switch (messageEnum) {
        case MessageEnum.image:
          contactMsg = '📷 Photo';
          break;
        case MessageEnum.video:
          contactMsg = '📸 Video';
          break;
        case MessageEnum.audio:
          contactMsg = '🎵 Audio';
          break;
        case MessageEnum.gif:
          contactMsg = 'GIF';
          break;
        default:
          contactMsg = 'GIF';
      }

      _saveDataToContactsSubcollection(senderUserData, reciverUserData!,
          contactMsg, timeSent, recieverUserId, isGroupChat);
      _saveMessageToMessageSubCollection(
        username: senderUserData.name,
        recieverUserId: recieverUserId,
        text: imageUrl,
        timeSent: timeSent,
        messageId: messageId,
        messageType: messageEnum,
        reciverUsername: reciverUserData.name,
        isGroupChat: isGroupChat,
      );
    } on FirebaseException catch (e) {
      Get.snackbar("File Not Sent", e.toString());
    }
  }

  void sendGIFMessage({
    required String gifUrl,
    required String recieverUserId,
    required UserModel senderUserData,
    required bool isGroupChat,
  }) async {
    try {
      var timeSent = DateTime.now();
      UserModel? reciverUserData;

     
      if (!isGroupChat) {
        var userDataMap = await db.userCollection.doc(recieverUserId).get();
        reciverUserData =
            UserModel.fromMap(userDataMap.data() as Map<String, dynamic>);
      }

      var messageId = const Uuid().v1();
      _saveDataToContactsSubcollection(senderUserData, reciverUserData, 'GIF',
          timeSent, recieverUserId, isGroupChat);
      _saveMessageToMessageSubCollection(
        username: senderUserData.name,
        recieverUserId: recieverUserId,
        text: gifUrl,
        timeSent: timeSent,
        messageId: messageId,
        messageType: MessageEnum.gif,
        reciverUsername: reciverUserData!.name,
        isGroupChat: isGroupChat,
      );
    } catch (e) {
      Get.snackbar("GIF Not Sent", e.toString());
    }
  }

  void setChatMessageSeen(
    String recieverUserId,
    String messageId,
  ) async {
    try {
      await db.userCollection
          .doc(_authController.user.uid)
          .collection('chats')
          .doc(recieverUserId)
          .collection('message')
          .doc(messageId)
          .update({'isSeen': true});

      await db.userCollection
          .doc(recieverUserId)
          .collection('chats')
          .doc(_authController.user.uid)
          .collection('message')
          .doc(messageId)
          .update({'isSeen': true});
    } catch (e) {
      Get.snackbar("Message Not Seen", e.toString());
    }
  }

  Stream<List<GroupModel>> getGroupData() {
    return db.groupCollection.snapshots().map((event) {
      List<GroupModel> groupList = [];
      for (var element in event.docs) {
        var group = GroupModel.fromMap(element.data() as Map<String, dynamic>);
        if (group.membersUid.contains(_userController.user.uid)) {
          groupList.add(group);
        }
      }
      return groupList;
    });
  }

  Stream<List<Message>> getGroupChatStream(String groudId) {
    return db.groupCollection
        .doc(groudId)
        .collection('chats')
        .orderBy('timeSent')
        .snapshots()
        .map((event) {
      List<Message> messages = [];
      for (var document in event.docs) {
        messages.add(Message.fromMap(document.data()));
      }
      return messages;
    });
  }
}
