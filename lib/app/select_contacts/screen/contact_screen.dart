import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:whatsapp_clone/app/select_contacts/controller/select_contact_controller.dart';

class SelectContactsScreen extends StatelessWidget {
  SelectContactsScreen({Key? key}) : super(key: key);

  final SelectContactController _selectContactController =
      Get.put(SelectContactController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select contact'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.search,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.more_vert,
            ),
          ),
        ],
      ),
      body: Obx(() {
        print(_selectContactController.contact.length);
        return ListView.builder(
            itemCount: _selectContactController.contact.length,
            itemBuilder: (context, index) {
              final contact = _selectContactController.contact[index];
              return InkWell(
                onTap: () {
                  _selectContactController.selectContact(contact);
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: ListTile(
                    title: Text(
                      contact.displayName,
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    leading:
                    contact.photo == null
                        ? null
                        : CircleAvatar(
                            backgroundImage: MemoryImage(contact.photo!),
                            radius: 30,
                          ),
                  ),
                ),
              );
            });
      }),
    );
  }
}
