import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:whatsapp_clone/app/auth/controller/auth_controller.dart';
import 'package:whatsapp_clone/app/auth/controller/user_controller.dart';
import 'package:whatsapp_clone/app/chat/chat_enum.dart';
import 'package:whatsapp_clone/app/chat/model/chat_contact_model.dart';
import 'package:whatsapp_clone/app/chat/model/message_model.dart';
import 'package:whatsapp_clone/app/model/user_model.dart';
import 'package:whatsapp_clone/app/services.dart/database_services.dart';

class ChatController extends GetxController {
  DatabaseServices db = DatabaseServices();
  final AuthController _authController = Get.find();
  final UserController _userController = Get.find();

  void _saveDataToContactsSubcollection(
    UserModel senderUserData,
    UserModel recieverUserData,
    String text,
    DateTime timeSent,
    String recieverUserId,
  ) async {
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
        name: recieverUserData.name,
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

  void _saveMessageToMessageSubCollection({
    required String text,
    required String recieverUserId,
    required DateTime timeSent,
    required String messageId,
    required String username,
    required String reciverUsername,
    required MessageEnum messageType,
  }) async {
    var message = Message(
      senderId: _authController.user.uid,
      recieverid: recieverUserId,
      text: text,
      type: messageType,
      timeSent: timeSent,
      messageId: messageId,
      isSeen: false,
    );

    ///sender
    await db.userCollection
        .doc(_authController.user.uid)
        .collection('chats')
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

  void sendTextMessage({
    required String text,
    required String recieverUserId,
    required UserModel senderUser,
  }) async {
    try {
      var timeSent = DateTime.now();
      UserModel reciverUserData;

      var UserDataMap = await db.userCollection.doc(recieverUserId).get();
      reciverUserData =
          UserModel.fromMap(UserDataMap.data() as Map<String, dynamic>);
      var messageId = Uuid().v1();
      _saveDataToContactsSubcollection(
          senderUser, reciverUserData, text, timeSent, recieverUserId);
      _saveMessageToMessageSubCollection(
        username: senderUser.name,
        recieverUserId: recieverUserId,
        text: text,
        timeSent: timeSent,
        messageId: messageId,
        messageType: MessageEnum.text,
        reciverUsername: reciverUserData.name,
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
        var userData = await db.userCollection
            .doc(chatContact.contactId)
            .get();
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
}
