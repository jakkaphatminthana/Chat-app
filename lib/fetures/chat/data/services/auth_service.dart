import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;

  //TODO 1: User Register Email
  Future<UserCredential> registerWithEmail({
    required email,
    required pass,
  }) async {
    final result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: pass,
    );

    return result;
  }

  //TODO 2: User Login Email
  Future<UserCredential> loginWithEmail({
    required email,
    required pass,
  }) async {
    final result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: pass,
    );
    return result;
  }

  //TODO 3: User Login by Google
  Future<UserCredential> loginWIthGoogle() async {
    //1. begin interactive sign in process
    final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();

    //2. obtaiin auth details from request
    final GoogleSignInAuthentication gAuth = await gUser!.authentication;

    //3. create a new credential for user
    final credential = GoogleAuthProvider.credential(
      accessToken: gAuth.accessToken,
      idToken: gAuth.idToken,
    );

    return await _auth.signInWithCredential(credential);
  }
}
