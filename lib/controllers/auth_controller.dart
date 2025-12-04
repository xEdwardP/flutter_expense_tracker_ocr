import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_expense_tracker_ocr/data/firebase_config.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> loginWithEmail(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user;
  }

  Future<User?> loginWithGoogle() async {
    const webClientId = webClientToken;

    final GoogleSignIn googleSignIn = GoogleSignIn(clientId: webClientId);
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    if (googleUser == null) return null;

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    return userCredential.user;
  }
}
