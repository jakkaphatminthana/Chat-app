import 'package:chat_app/fetures/chat/presentation/widgets/chat_message.dart';
import 'package:chat_app/fetures/chat/presentation/widgets/new_message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  //TODO : Permission Token
  void setupPushNotification() async {
    final fcm = FirebaseMessaging.instance;
    await fcm.requestPermission();

    //token = มักใช้สำหรับส่งแนบกับ http หรือ firestore sdk ให้กับ backend
    //ใช้บอกเลขเครื่อง
    final token = await fcm.getToken();
    print(token);

    fcm.subscribeToTopic('chat');
  }

  @override
  void initState() {
    super.initState();
    // setupPushNotification();
  }

  //=============================================================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FlutterChat'),
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: Icon(
              Icons.exit_to_app,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
      body: Column(
        children: const [
          Expanded(
            child: ChatMessages(),
          ),
          NewMessage(),
        ],
      ),
    );
  }
}
