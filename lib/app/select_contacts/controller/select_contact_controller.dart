import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';
import 'package:whatsapp_clone/app/chat/screen.dart/mobile_chat_screen.dart';
import 'package:whatsapp_clone/app/model/user_model.dart';
import 'package:whatsapp_clone/app/services.dart/database_services.dart';

class SelectContactController extends GetxController {
  DatabaseServices db = DatabaseServices();
  final Rx<List<Contact>> _contacts = Rx<List<Contact>>([]);

  List<Contact> get contact => _contacts.value;

  @override
  Future<void> onReady() async {
    _contacts.value = await getContacts();
    super.onReady();
  }

  Future<List<Contact>> getContacts() async {
    List<Contact> contacts = [];
    try {
      if (await FlutterContacts.requestPermission()) {
        contacts = await FlutterContacts.getContacts(withProperties: true);
        print(contacts.length);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return contacts;
  }

  void selectContact(Contact selectedContact) async {
    try {
      var userCollection = await db.userCollection.get();
      bool isFound = false;

      for (var document in userCollection.docs) {
        var userData =
            UserModel.fromMap(document.data() as Map<String, dynamic>);
        String selectedPhoneNum = selectedContact.phones[0].number.replaceAll(
          ' ',
          '',
        );
        if (selectedPhoneNum == userData.phoneNumber) {
          isFound = true;
          Get.to(() => MobileChatScreen());
          // Navigator.pushNamed(
          //   context,
          //   MobileChatScreen.routeName,
          //   arguments: {
          //     'name': userData.name,
          //     'uid': userData.uid,
          //   },
          // );
        }
      }

      if (!isFound) {
        Get.snackbar('No User', 'This number does not exist on this app');
      }
    } catch (e) {
      Get.snackbar('error', e.toString());
    }
  }
}
