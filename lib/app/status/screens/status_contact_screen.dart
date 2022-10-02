import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:whatsapp_clone/app/data/constants.dart';
import 'package:whatsapp_clone/app/status/controller/status_conntroller.dart';
import 'package:whatsapp_clone/app/status/model/status_model.dart';

class StatusContactsScreen extends StatelessWidget {
  const StatusContactsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StatusController>(
        init: StatusController(),
        builder: (controller) {
          return FutureBuilder<List<Status>>(
              future: controller.getStatus(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    var statusData = snapshot.data![index];
                    return Column(
                      children: [
                        InkWell(
                          onTap: () {
                            // Navigator.pushNamed(
                            //   context,
                            //   StatusScreen.routeName,
                            //   arguments: statusData,
                            // );
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: ListTile(
                              title: Text(
                                statusData.username,
                              ),
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(
                                  statusData.profilePic,
                                ),
                                radius: 30,
                              ),
                            ),
                          ),
                        ),
                        Divider(color: CustomColor.dividerColor, indent: 85),
                      ],
                    );
                  },
                );
              });
        });
  }
}
