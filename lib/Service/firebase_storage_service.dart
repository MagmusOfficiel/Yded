import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class FirebaseStorageService {
  final _picker = ImagePicker();

  Future<String?> uploadImageToFirebaseStorage(File file) async {
    // Sélectionnez une image à partir de la galerie du téléphone
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) {
      return null;
    }

    final File file = File(pickedFile.path);

    // Définissez l'emplacement où vous souhaitez stocker l'image dans Firebase Storage
    final Reference ref = FirebaseStorage.instance.ref().child('images/${file.path.split('/').last}');

    // Envoyez l'image dans Firebase Storage
    final UploadTask uploadTask = ref.putFile(file);

    // Attendez la fin de l'envoi
    await uploadTask.whenComplete(() => null);

    // Récupérez l'URL de téléchargement de l'image
    final String downloadUrl = await ref.getDownloadURL();

    // Retournez l'URL de téléchargement de l'image
    return downloadUrl;
  }
}