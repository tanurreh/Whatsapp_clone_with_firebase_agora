import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:whatsapp_clone/app/auth/controller/auth_controller.dart';
import 'package:whatsapp_clone/app/auth/controller/user_controller.dart';
import 'package:whatsapp_clone/app/chat/widgets/contact_list.dart';
import 'package:whatsapp_clone/app/data/constants.dart';
import 'package:whatsapp_clone/app/group/screen/create_group_screen.dart';
import 'package:whatsapp_clone/app/select_contacts/screen/contact_screen.dart';
import 'package:whatsapp_clone/app/services.dart/image_picker_services.dart';
import 'package:whatsapp_clone/app/status/screens/confirm_status_screen.dart';
import 'package:whatsapp_clone/app/status/screens/status_contact_screen.dart';

class MobileLayoutScreen extends StatefulWidget {
  const MobileLayoutScreen({Key? key}) : super(key: key);

  @override
  State<MobileLayoutScreen> createState() => _MobileLayoutScreenState();
}

class _MobileLayoutScreenState extends State<MobileLayoutScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  final UserController _userController = Get.put(UserController());
  late TabController tabBarController;
  @override
  void initState() {
    super.initState();
    tabBarController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        AuthController.instance.getUserStatus(_userController.user.uid, true);
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.paused:
        AuthController.instance.getUserStatus(_userController.user.uid, false);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: CustomColor.appBarColor,
          centerTitle: false,
          title: const Text(
            'WhatsApp',
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search, color: Colors.grey),
              onPressed: () {},
            ),
            PopupMenuButton(
              icon: const Icon(
                Icons.more_vert,
                color: Colors.grey,
              ),
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: const Text(
                    'Create Group',
                  ),
                  onTap: () {
                    Future(()=> Get.to(() => CreateGroupScreen()));
                  },
                )
              ],
            ),
          ],
          bottom: TabBar(
            controller: tabBarController,
            indicatorColor: CustomColor.tabColor,
            indicatorWeight: 4,
            labelColor: CustomColor.tabColor,
            unselectedLabelColor: Colors.grey,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
            tabs: const [
              Tab(
                text: 'CHATS',
              ),
              Tab(
                text: 'STATUS',
              ),
              Tab(
                text: 'CALLS',
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: tabBarController,
          children:  [
            ContactsList(),
            StatusContactsScreen(),
            Text('Calls')
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            if (tabBarController.index == 0) {
              Get.to(() => SelectContactsScreen());
            } else {
              File? pickedImage = await PickerServices().pickImageFromGallery();
              if (pickedImage != null) {
                Get.to(() => ConfirmStatusScreen(
                      file: pickedImage,
                    ));
              }
            }
          },
          backgroundColor: CustomColor.tabColor,
          child: const Icon(
            Icons.comment,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
