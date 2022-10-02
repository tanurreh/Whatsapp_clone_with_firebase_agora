import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:whatsapp_clone/app/auth/controller/auth_controller.dart';
import 'package:whatsapp_clone/app/call/controller/call_controller.dart';
import 'package:whatsapp_clone/app/chat/widgets/bottom_text_feild.dart';
import 'package:whatsapp_clone/app/chat/widgets/chat_list.dart';
import 'package:whatsapp_clone/app/data/constants.dart';
import 'package:whatsapp_clone/app/model/user_model.dart';

class MobileChatScreen extends StatelessWidget {

  final String name;
  final String uid;
   final bool isGroupChat;
   final String profilePic;
  const MobileChatScreen({
    Key? key,
    required this.name,
    required this.uid,
    required this.isGroupChat,
    required this.profilePic,
  }) : super(key: key);

  void makeCall() {
    Get.put(CallController()).dialCall(
          name,
          uid,
          profilePic,
          isGroupChat,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: CustomColor.appBarColor,
         title: isGroupChat
            ? Text(name)
            : StreamBuilder<UserModel>(
            stream: AuthController.instance.getCurrentUser(uid),
            builder: ((context, snapshot) {
              UserModel _user = snapshot.data!;
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_user.name),
                  Text(
                    _user.isOnline ? 'online' : 'offline',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              );
            })),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed:makeCall,
            icon: const Icon(Icons.video_call),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.call),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ChatList(
              recieverUserId: uid,
              isGroupChat: isGroupChat,
            ),
          ),
          BottomChatField(
            recieverUserId: uid,
            isGroupChat: isGroupChat,
          ),
        ],
      ),
    );
  }
}
