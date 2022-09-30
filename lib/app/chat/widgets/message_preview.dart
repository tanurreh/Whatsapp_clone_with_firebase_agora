import 'package:flutter/material.dart';
import 'package:whatsapp_clone/app/chat/chat_enum.dart';
import 'package:whatsapp_clone/app/chat/model/message_reply.dart';
import 'package:whatsapp_clone/app/chat/widgets/display_test_image.dart';

class MessageReplyPreview extends StatelessWidget {
  const MessageReplyPreview({Key? key}) : super(key: key);

  // void cancelReply(WidgetRef ref) {
  //   ref.read(messageReplyProvider.state).update((state) => null);

  @override
  Widget build(
    BuildContext context,
  ) {
    final messageReply = MessageReply("message", true, MessageEnum.text);

    return Container(
      width: 350,
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  messageReply.isMe ? 'Me' : 'Opposite',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              GestureDetector(
                child: const Icon(
                  Icons.close,
                  size: 16,
                ),
                onTap: (){}
              ),
            ],
          ),
          const SizedBox(height: 8),
          DisplayTextImageGIF(
            message: messageReply.message,
            type: messageReply.messageEnum,
          ),
        ],
      ),
    );
  }
}
