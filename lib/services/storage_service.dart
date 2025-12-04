import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage storage = FirebaseStorage.instance;

  Future<String?> uploadImage(File imageFile, String folder) async {
    try {
      final String nameFile = imageFile.path.split('/').last;
      final Reference ref = storage.ref().child(folder).child(nameFile);

      final UploadTask uploadTask = ref.putFile(imageFile);
      final TaskSnapshot snapshot = await uploadTask.whenComplete(() => true);

      final String urlImage = await snapshot.ref.getDownloadURL();
      return urlImage;
    } catch (e) {
      print('Error uploading file to Firebase Storage: $e');
      return null;
    }
  }
}
