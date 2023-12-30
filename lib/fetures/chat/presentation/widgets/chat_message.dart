import 'package:chat_app/fetures/chat/presentation/widgets/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    final authenticatedUser = FirebaseAuth.instance.currentUser!;

    //=============================================================================================================
    return StreamBuilder(
      //TODO 1: ติดตามการเปลี่ยนแปลงของ doc chat
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (ctx, chatSnapshot) {

        //TODO 2: ตรวจสอบ snapshot
        //case 1: โหลดยังไม่เสร็จ
        if (chatSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        //case 2: มีข้อมูลนะ แต่ว่างเปล่า
        if (!chatSnapshot.hasData || chatSnapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('No messages found!'),
          );
        }

        //case 3: Error
        if (chatSnapshot.hasError) {
          return const Center(
            child: Text('Something went wrong...'),
          );
        }

        //case ok: data found
        final loadedMessages = chatSnapshot.data!.docs;

        //TODO 3: Show Chat Messages
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(13, 0, 13, 40),
          reverse: true, //ทำให้อยู่ด้านล่างสุด
          itemCount: loadedMessages.length,
          itemBuilder: (ctx, index) {
            //Message
            final chatMessage = loadedMessages[index].data();
            final nextChatMessage = (index + 1 < loadedMessages.length)
                ? loadedMessages[index + 1].data()
                : null;

            //UserId owner message
            final currentMessageUserId = chatMessage['userId'];
            final nextMessageUserId =
                (nextChatMessage != null) ? nextChatMessage['userId'] : null;
            final nextUserIsSame = (nextMessageUserId == currentMessageUserId);

            //Case 1: User is same Id
            if (nextUserIsSame) {
              //TODO 3.1: MessageBubble Next
              return MessageBubble.next(
                message: chatMessage['text'],
                isMe: authenticatedUser.uid == currentMessageUserId,
              );

              //Case 2: User is not same Id
            } else {
              //TODo 3.2: MessageBubble First
              return MessageBubble.first(
                userImage: chatMessage['userImage'],
                username: chatMessage['username'],
                message: chatMessage['text'],
                isMe: authenticatedUser.uid == currentMessageUserId,
              );
            }
          },
        );
      },
    );
  }
}
