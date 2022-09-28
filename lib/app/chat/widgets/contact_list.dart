import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:whatsapp_clone/app/chat/controller/chat_controller.dart';
import 'package:whatsapp_clone/app/chat/model/chat_contact_model.dart';
import 'package:whatsapp_clone/app/data/constants.dart';

class ContactsList extends StatelessWidget {
  const ContactsList({Key? key}) : super(key: key);

  @override
  Widget build(
    BuildContext context,
  ) {
    final ChatController _chatController = Get.put(ChatController());
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // StreamBuilder<List<Group>>(
            //     stream: ref.watch(chatControllerProvider).chatGroups(),
            //     builder: (context, snapshot) {
            //       if (snapshot.connectionState == ConnectionState.waiting) {
            //         return const Loader();
            //       }

            //       return ListView.builder(
            //         shrinkWrap: true,
            //         itemCount: snapshot.data!.length,
            //         itemBuilder: (context, index) {
            //           var groupData = snapshot.data![index];

            //           return Column(
            //             children: [
            //               InkWell(
            //                 onTap: () {
            //                   Navigator.pushNamed(
            //                     context,
            //                     MobileChatScreen.routeName,
            //                     arguments: {
            //                       'name': groupData.name,
            //                       'uid': groupData.groupId,
            //                       'isGroupChat': true,
            //                       'profilePic': groupData.groupPic,
            //                     },
            //                   );
            //                 },
            //                 child: Padding(
            //                   padding: const EdgeInsets.only(bottom: 8.0),
            //                   child: ListTile(
            //                     title: Text(
            //                       groupData.name,
            //                       style: const TextStyle(
            //                         fontSize: 18,
            //                       ),
            //                     ),
            //                     subtitle: Padding(
            //                       padding: const EdgeInsets.only(top: 6.0),
            //                       child: Text(
            //                         groupData.lastMessage,
            //                         style: const TextStyle(fontSize: 15),
            //                       ),
            //                     ),
            //                     leading: CircleAvatar(
            //                       backgroundImage: NetworkImage(
            //                         groupData.groupPic,
            //                       ),
            //                       radius: 30,
            //                     ),
            //                     trailing: Text(
            //                       DateFormat.Hm().format(groupData.timeSent),
            //                       style: const TextStyle(
            //                         color: Colors.grey,
            //                         fontSize: 13,
            //                       ),
            //                     ),
            //                   ),
            //                 ),
            //               ),
            //               const Divider(color: dividerColor, indent: 85),
            //             ],
            //           );
            //         },
            //       );
            //     }),
            StreamBuilder<List<ChatContact>>(
                stream: _chatController.getChatContacts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      var chatContactData = snapshot.data![index];
                      print(snapshot.data!.length);

                      return Column(
                        children: [
                          InkWell(
                            onTap: () {
                              // Navigator.pushNamed(
                              //   context,
                              //   MobileChatScreen.routeName,
                              //   arguments: {
                              //     'name': chatContactData.name,
                              //     'uid': chatContactData.contactId,
                              //     'isGroupChat': false,
                              //     'profilePic': chatContactData.profilePic,
                              //   },
                              // );
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: ListTile(
                                title: Text(
                                  chatContactData.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 6.0),
                                  child: Text(
                                    chatContactData.lastMessage,
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                ),
                                leading: CircleAvatar(
                                  backgroundImage: NetworkImage(
                                    chatContactData.profilePic,
                                  ),
                                  radius: 30,
                                ),
                                trailing: Text(
                                  DateFormat.Hm()
                                      .format(chatContactData.timeSent),
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Divider(color: CustomColor.dividerColor, indent: 85),
                        ],
                      );
                    },
                  );
                }),
          ],
        ),
      ),
    );
  }
}
