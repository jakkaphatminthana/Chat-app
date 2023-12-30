import 'package:chat_app/fetures/chat/presentation/pages/auth_screen.dart';
import 'package:chat_app/fetures/chat/presentation/pages/chat_screen.dart';
import 'package:chat_app/fetures/chat/presentation/pages/splash_screen.dart';
import 'package:chat_app/resources/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App',
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(), //ติดตามสถานะของผู้ใช้
        builder: (ctx, snapshot) {
          //Loading Page
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          }

          //Have account token
          if (snapshot.hasData) {
            return const ChatScreen();
          }

          //Not have account token
          return const AuthScreen();
        },
      ),
    );
  }
}
