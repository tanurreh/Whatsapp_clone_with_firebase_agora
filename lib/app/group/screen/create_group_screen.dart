import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';

import 'package:whatsapp_clone/app/data/constants.dart';
import 'package:whatsapp_clone/app/group/controller/group_controller.dart';
import 'package:whatsapp_clone/app/select_contacts/controller/select_contact_controller.dart';
import 'package:whatsapp_clone/app/services.dart/image_picker_services.dart';

import '../widgets/select_contact_group.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({Key? key}) : super(key: key);

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final TextEditingController groupNameController = TextEditingController();
  final SelectContactController _selectContactController =
      Get.put(SelectContactController());
  final GroupController _groupContactController =
      Get.put(GroupController());


  File? image;

  void selectImage() async {
    image = await PickerServices().pickImageFromGallery();
    setState(() {});
  }

  List<int> selectedContactsIndex = [];
  List<Contact> contactlist = [];

  void selectContact(int index, Contact contact) {
    if (selectedContactsIndex.contains(index)) {
      selectedContactsIndex.removeAt(index);
    } else {
      selectedContactsIndex.add(index);
    }
    if (selectedContactsIndex.contains(contact)) {
      contactlist.remove(contact);
    } else {
      contactlist.add(contact);
    }
    setState(() {});
  }

  void createGroup() {
    if (groupNameController.text.trim().isNotEmpty && image != null) {
      _groupContactController.createGroup(groupNameController.text.trim(), image!, contactlist);
    }
  }

  @override
  void dispose() {
    super.dispose();
    groupNameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Group'),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Stack(
              children: [
                image == null
                    ? const CircleAvatar(
                        backgroundImage: NetworkImage(
                          'https://png.pngitem.com/pimgs/s/649-6490124_katie-notopoulos-katienotopoulos-i-write-about-tech-round.png',
                        ),
                        radius: 64,
                      )
                    : CircleAvatar(
                        backgroundImage: FileImage(
                          image!,
                        ),
                        radius: 64,
                      ),
                Positioned(
                  bottom: -10,
                  left: 80,
                  child: IconButton(
                    onPressed: selectImage,
                    icon: const Icon(
                      Icons.add_a_photo,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextField(
                controller: groupNameController,
                decoration: const InputDecoration(
                  hintText: 'Enter Group Name',
                ),
              ),
            ),
            Container(
              alignment: Alignment.topLeft,
              padding: const EdgeInsets.all(8),
              child: const Text(
                'Select Contacts',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Obx(
             () {
                return Expanded(
                  child: ListView.builder(
                      itemCount: _selectContactController.contact.length,
                      itemBuilder: (context, index) {
                        final contact = _selectContactController.contact[index];
                        print(_selectContactController.contact.length);
            
                        if (_selectContactController.contact.isEmpty) {
                          return Center(child: CircularProgressIndicator());
                        }
                        return InkWell(
                          onTap: () => selectContact(index, contact),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              title: Text(
                                contact.displayName,
                                style: const TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                              leading: selectedContactsIndex.contains(index)
                                  ? IconButton(
                                      onPressed: () {},
                                      icon: const Icon(Icons.done),
                                    )
                                  : null,
                            ),
                          ),
                        );
                      }),
                );
              }
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: createGroup,
        backgroundColor: CustomColor.tabColor,
        child: const Icon(
          Icons.done,
          color: Colors.white,
        ),
      ),
    );
  }
}
