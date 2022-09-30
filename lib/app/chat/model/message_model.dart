import 'dart:convert';

import 'package:whatsapp_clone/app/chat/chat_enum.dart';

class Message {
  final String senderId;
  final String recieverid;
  final String text;
  final MessageEnum type;
  final DateTime timeSent;
  final String messageId;
  final bool isSeen;
  final String repliedMessage;
  final String repliedTo;
  final MessageEnum repliedMessageType;

  Message({
    required this.senderId,
    required this.recieverid,
    required this.text,
    required this.type,
    required this.timeSent,
    required this.messageId,
    required this.isSeen,
    required this.repliedMessage,
    required this.repliedTo,
    required this.repliedMessageType,
  });


  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};
  
    result.addAll({'senderId': senderId});
    result.addAll({'recieverid': recieverid});
    result.addAll({'text': text});
    result.addAll({'type': type.type});
    result.addAll({'timeSent': timeSent.millisecondsSinceEpoch});
    result.addAll({'messageId': messageId});
    result.addAll({'isSeen': isSeen});
    result.addAll({'repliedMessage': repliedMessage});
    result.addAll({'repliedTo': repliedTo});
    result.addAll({'repliedMessageType': repliedMessageType.type});
  
    return result;
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      senderId: map['senderId'] ?? '',
      recieverid: map['recieverid'] ?? '',
      text: map['text'] ?? '',
      type:(map['type']as String).toEnum(),
      timeSent: DateTime.fromMillisecondsSinceEpoch(map['timeSent']),
      messageId: map['messageId'] ?? '',
      isSeen: map['isSeen'] ?? false,
      repliedMessage: map['repliedMessage'] ?? '',
      repliedTo: map['repliedTo'] ?? '',
      repliedMessageType: (map['repliedMessageType'] as String).toEnum(),
    );
  }

  String toJson() => json.encode(toMap());

  factory Message.fromJson(String source) => Message.fromMap(json.decode(source));
}

  // Map<String, dynamic> toMap() {
  //   final result = <String, dynamic>{};
  
  //   result.addAll({'senderId': senderId});
  //   result.addAll({'recieverid': recieverid});
  //   result.addAll({'text': text});
  //   result.addAll({'type': type.type});
  //   result.addAll({'timeSent': timeSent.millisecondsSinceEpoch});
  //   result.addAll({'messageId': messageId});
  //   result.addAll({'isSeen': isSeen});
  
  //   return result;
  // }

  // factory Message.fromMap(Map<String, dynamic> map) {
  //   return Message(
  //     senderId: map['senderId'] ?? '',
  //     recieverid: map['recieverid'] ?? '',
  //     text: map['text'] ?? '',
  //     type: (map['type']as String).toEnum(),
  //     timeSent: DateTime.fromMillisecondsSinceEpoch(map['timeSent']),
  //     messageId: map['messageId'] ?? '',
  //     isSeen: map['isSeen'] ?? false,
  //   );
  // }

