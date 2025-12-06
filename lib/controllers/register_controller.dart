import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  Future<String?> registerUser({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    try {
      
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = result.user;
      if (user == null) return "Error inesperado al registrar usuario.";

      
      await user.updateDisplayName(name);

      
      await _firestore.collection("users").doc(user.uid).set({
        "name": name,
        "email": email,
        "phone": phone,
        "photoUrl": "",
        "createdAt": FieldValue.serverTimestamp(),
      });

      return null; 
    } on FirebaseAuthException catch (e) {
      if (e.code == "email-already-in-use") return "El correo ya está registrado.";
      if (e.code == "weak-password") return "La contraseña es demasiado débil.";
      if (e.code == "invalid-email") return "Correo inválido.";
      return "Error al registrar: ${e.message}";
    } catch (e) {
      return "Error inesperado: $e";
    }
  }
}
