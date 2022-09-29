import 'dart:io';

import 'package:flutter/material.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:get/get.dart';
import 'package:whatsapp_clone/app/auth/controller/user_controller.dart';
import 'package:whatsapp_clone/app/chat/chat_enum.dart';
import 'package:whatsapp_clone/app/chat/controller/chat_controller.dart';
import 'package:whatsapp_clone/app/data/constants.dart';
import 'package:whatsapp_clone/app/services.dart/image_picker_services.dart';

class BottomChatField extends StatefulWidget {
  final String recieverUserId;
  //final bool isGroupChat;
  const BottomChatField({
    Key? key,
    required this.recieverUserId,
    //required this.isGroupChat,
  }) : super(key: key);

  @override
  State<BottomChatField> createState() => _BottomChatFieldState();
}

class _BottomChatFieldState extends State<BottomChatField> {
  final ChatController _chatController = Get.put(ChatController());
   final UserController _userController = Get.put(UserController());
   
  bool isShowSendButton = false;
  final TextEditingController _messageController = TextEditingController();
  //FlutterSoundRecorder? _soundRecorder;
  bool isRecorderInit = false;
  bool isShowEmojiContainer = false;
  bool isRecording = false;
  FocusNode focusNode = FocusNode();
  

  @override
  void initState() {
    super.initState();
    // _soundRecorder = FlutterSoundRecorder();
    //openAudio();
  }

  // void openAudio() async {
  //   final status = await Permission.microphone.request();
  //   if (status != PermissionStatus.granted) {
  //     throw RecordingPermissionException('Mic permission not allowed!');
  //   }
  //   await _soundRecorder!.openRecorder();
  //   isRecorderInit = true;
  // }

  void sendTextMessage() async {
    if (isShowSendButton) {
      _chatController.sendTextMessage(
         text: _messageController.text.trim(), 
         recieverUserId: widget.recieverUserId,
         senderUser:  _userController.currentUser,
      );
      setState(() {
        _messageController.text = '';
      });
    }
     //else {
      // var tempDir = await getTemporaryDirectory();
      // var path = '${tempDir.path}/flutter_sound.aac';
      // if (!isRecorderInit) {
      //   return;
      // }
      // if (isRecording) {
      //   await _soundRecorder!.stopRecorder();
      //   sendFileMessage(File(path), MessageEnum.audio);
      // } else {
      //   await _soundRecorder!.startRecorder(
      //     toFile: path,
      //   );
      // }

      // setState(() {
      //   isRecording = !isRecording;
      // });
    //}
  }


  void selectImage() async {
    File? image = await PickerServices().pickImageFromGallery();
    if (image != null) {
      _chatController.sendFileMessage(  file: image, messageEnum:MessageEnum.image, recieverUserId: widget.recieverUserId, senderUserData: _userController.currentUser,);
    }
  }

  void selectVideo() async {
    File? video = await PickerServices().pickVideoFromGallery();
    if (video != null) {
      _chatController.sendFileMessage(  file: video, messageEnum:MessageEnum.video, recieverUserId: widget.recieverUserId, senderUserData: _userController.currentUser,);
    }
  }

  void selectGIF() async {
    final gif = await PickerServices().pickGIF(context);
    
    if (gif != null) {
       int gifUrlPartIndex = gif.url.lastIndexOf('-') + 1;
    String gifUrlPart = gif.url.substring(gifUrlPartIndex);
    String newgifUrl = 'https://i.giphy.com/media/$gifUrlPart/200.gif';
    _chatController.sendGIFMessage(gifUrl: newgifUrl, recieverUserId: widget.recieverUserId, senderUserData: _userController.currentUser);
    }
  }

  void hideEmojiContainer() {
    setState(() {
      isShowEmojiContainer = false;
    });
  }

  void showEmojiContainer() {
    setState(() {
      isShowEmojiContainer = true;
    });
  }

  void showKeyboard() => focusNode.requestFocus();
  void hideKeyboard() => focusNode.unfocus();

  void toggleEmojiKeyboardContainer() {
    if (isShowEmojiContainer) {
      showKeyboard();
      hideEmojiContainer();
    } else {
      hideKeyboard();
      showEmojiContainer();
    }
  }

  @override
  void dispose() {
    super.dispose();
     _messageController.dispose();
    // _soundRecorder!.closeRecorder();
    // isRecorderInit = false;
  }

  @override
  Widget build(BuildContext context) {
    // final messageReply = ref.watch(messageReplyProvider);
    // final isShowMessageReply = messageReply != null;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                focusNode: focusNode,
                controller: _messageController,
                onChanged: (val) {
                  if (val.isNotEmpty) {
                    setState(() {
                      isShowSendButton = true;
                    });
                  } else {
                    setState(() {
                      isShowSendButton = false;
                    });
                  }
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: CustomColor.mobileChatBoxColor,
                  prefixIcon: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          IconButton(
                            onPressed:  toggleEmojiKeyboardContainer,
                            icon: const Icon(
                              Icons.emoji_emotions,
                              color: Colors.grey,
                            ),
                          ),
                          IconButton(
                            onPressed: selectGIF,
                            icon: const Icon(
                              Icons.gif,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  suffixIcon: SizedBox(
                    width: 100,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          onPressed:  selectImage,
                          icon: const Icon(
                            Icons.camera_alt,
                            color: Colors.grey,
                          ),
                        ),
                        IconButton(
                          onPressed:  selectVideo,
                          icon: const Icon(
                            Icons.attach_file,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  hintText: 'Type a message!',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: const BorderSide(
                      width: 0,
                      style: BorderStyle.none,
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(10),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                bottom: 8,
                right: 2,
                left: 2,
              ),
              child: CircleAvatar(
                backgroundColor: const Color(0xFF128C7E),
                radius: 25,
                child: GestureDetector(
                  child: Icon(
                    isShowSendButton
                        ? Icons.send
                        : isRecording
                            ? Icons.close
                            : Icons.mic,
                    color: Colors.white,
                  ),
                  onTap: sendTextMessage,
                ),
              ),
            ),
          ],
        ),
         isShowEmojiContainer
            ? SizedBox(
                height: 310,
                child: EmojiPicker(
                  onEmojiSelected: ((category, emoji) {
                    setState(() {
                      _messageController.text =
                          _messageController.text + emoji.emoji;
                    });

                    if (!isShowSendButton) {
                      setState(() {
                        isShowSendButton = true;
                      });
                    }
                  }),
                ),
              )
            : const SizedBox(),
      ],
    );
  }
}
