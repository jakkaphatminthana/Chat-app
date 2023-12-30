import 'dart:io';

import 'package:chat_app/fetures/chat/data/services/auth_service.dart';
import 'package:chat_app/fetures/chat/data/services/firestore_service.dart';
import 'package:chat_app/fetures/chat/data/services/storage_service.dart';
import 'package:chat_app/fetures/chat/presentation/widgets/user_image_picker.dart';
import 'package:chat_app/resources/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

final GoogleSignIn _googleSignIn = GoogleSignIn();

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final AuthService _auth = AuthService();
  final StorageServices _storage = StorageServices();
  final FirestoreService _firestore = FirestoreService();
  final _formKey = GlobalKey<FormState>();

  var _isLogin = true;
  var _isAuthenticating = false;

  var _enterEmail = '';
  var _enterPassword = '';
  var _enterUsername = '';
  File? _selectedImage;

  //TODO 1: Submit Form
  void _onSubmit() async {
    final isValid = _formKey.currentState!.validate();

    //Check valid input, image isNull
    if (!isValid || (!_isLogin && _selectedImage == null)) {
      return;
    }
    _formKey.currentState!.save();

    try {
      setState(() {
        _isAuthenticating = true;
      });

      //TODO 1.1: Login Mode
      if (_isLogin) {
        await _auth.loginWithEmail(
          email: _enterEmail,
          pass: _enterPassword,
        );

        //TODO 1.2: Signup Mode
      } else {
        //TODO 1.2.1: Authentication
        final userCredential = await _auth.registerWithEmail(
          email: _enterEmail,
          pass: _enterPassword,
        );

        //TODO 1.2.2: Storage file
        //1. upload file to storage
        final storageRef = await _storage.uploadImageProfile(
          userId: userCredential.user!.uid,
          image: _selectedImage!,
        );
        //2. get Url image
        final imageUrl = await storageRef.getDownloadURL();

        //TODO 1.2.3 Firestore
        await _firestore.createUserProfile(
          userId: userCredential.user!.uid,
          username: _enterUsername,
          email: _enterEmail,
          imageUrl: imageUrl,
        );
      }
      //TODO 1.3: Catch Error Message
    } on FirebaseAuthException catch (error) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message ?? 'Authentication failed.'),
        ),
      );
    }
    setState(() {
      _isAuthenticating = false;
    });
  }

  //TODO 2: Google Login
  void _loginWithGoogle() async {
    //1.Login by Google system
    final userCredential = await _auth.loginWIthGoogle();

    //2.get user data is already?
    final documentSnapshot = await _firestore.getUserDataById(
      userId: userCredential.user!.uid,
    );

    //Case 1: มีข้อมูลใน Firestore อยู่แล้ว
    if (documentSnapshot.exists) {
      print('User data already exists in Firestore');

      //Case 2: ยังไม่มีข้อมูลใน Firestore
    } else {
      User user = userCredential.user!;
      await _firestore.createUserProfile(
        userId: user.uid,
        username: user.displayName!,
        email: user.email!,
        imageUrl: user.photoURL!,
      );
    }
  }

//==========================================================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //TODO 1: Image logo app
              Container(
                margin: const EdgeInsets.fromLTRB(20, 30, 20, 20),
                width: 200,
                child: Image.asset('assets/images/chat.png'),
              ),
              Card(
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          //TODO 2: Pick Image
                          if (!_isLogin)
                            UserImagePicker(
                              onPickImage: (pickedImage) {
                                _selectedImage = pickedImage;
                              },
                            ),

                          //TODO 3: Email Input
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Email Address',
                            ),
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            textCapitalization:
                                TextCapitalization.none, //ไม่พิมพ์ใหญ่
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  !value.contains('@')) {
                                return 'Please enter a vaild email address.';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _enterEmail = value!;
                            },
                          ),

                          //TODO 4: Username Input
                          if (!_isLogin)
                            TextFormField(
                              decoration:
                                  const InputDecoration(labelText: 'Username'),
                              enableSuggestions: false,
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    value.trim().length < 4) {
                                  return 'Please enter at least 4 characters.';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _enterUsername = value!;
                              },
                            ),

                          //TODO 5: Password Input
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Password',
                            ),
                            keyboardType: TextInputType.emailAddress,
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.trim().length < 6) {
                                return 'Password must be at least 6 characters long.';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _enterPassword = value!;
                            },
                          ),
                          const SizedBox(height: 12),

                          if (_isAuthenticating)
                            const CircularProgressIndicator(),

                          //TODO 6: Button Action
                          if (!_isAuthenticating)
                            ElevatedButton(
                              onPressed: _onSubmit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    theme.colorScheme.primaryContainer,
                              ),
                              child: Text(
                                (_isLogin ? 'Login' : 'Signup'),
                              ),
                            ),

                          //TODO 7: Create Button
                          if (!_isAuthenticating)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _isLogin = !_isLogin;
                                });
                              },
                              child: Text(
                                (_isLogin)
                                    ? 'Create an anccount'
                                    : 'I already have an account',
                              ),
                            ),

                          //TODO 8: Google
                          GestureDetector(
                            onTap: _loginWithGoogle,
                            child: Image.asset(
                              'assets/images/google.png',
                              width: 30,
                              height: 30,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
