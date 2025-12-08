import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> loginWithEmail(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user;
  }

  Future<User?> loginWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email']);
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

  Future<String?> registerWithEmail(
    String name,
    String email,
    String phone,
    String password,
  ) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = result.user;
      if (user == null) return "No se pudo crear el usuario.";

      await user.updateDisplayName(name);
      await user.reload();

      await _firestore.collection("users").doc(user.uid).set({
        "name": name,
        "email": email,
        "phone": phone,
        "photoUrl": "",
        "createdAt": FieldValue.serverTimestamp(),
      });

      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "email-already-in-use":
          return "El correo ya está registrado.";
        case "weak-password":
          return "La contraseña es demasiado débil.";
        case "invalid-email":
          return "Correo inválido.";
        case "operation-not-allowed":
          return "El registro con correo está deshabilitado.";
        default:
          return "Error al registrar: ${e.message}";
      }
    } catch (e) {
      return "Error inesperado: $e";
    }
  }
}
