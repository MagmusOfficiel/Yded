import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Méthode pour choisir l'image à partir de la galerie
  Future<File?> pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      return File(image.path);
    } else {
      print('Aucune image sélectionnée');
      return null;
    }
  }

  // Méthode pour uploader l'image sur Firebase Storage
  Future<String> uploadImage(File imageFile, String imagePath) async {
    try {
      await _storage.ref(imagePath).putFile(imageFile);
      String downloadUrl = await _storage.ref(imagePath).getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print(e);
      return '';
    }
  }
}