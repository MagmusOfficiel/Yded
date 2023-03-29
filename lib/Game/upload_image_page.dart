import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../Service/firebase_storage_service.dart';

class UploadImagePage extends StatefulWidget {
  @override
  _UploadImagePageState createState() => _UploadImagePageState();
}

class _UploadImagePageState extends State<UploadImagePage> {
  String? _imageUrl;
  final _firebaseStorageService = FirebaseStorageService();
  final _picker = ImagePicker();

  Future<void> _selectAndUploadImage() async {

    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) {
      return;
    }

    setState(() {
      _imageUrl = null;
    });

    final File file = File(pickedFile.path);
    final String? imageUrl = await _firebaseStorageService.uploadImageToFirebaseStorage(file);

    setState(() {
      _imageUrl = imageUrl;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Image'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_imageUrl != null)
              Image.network(_imageUrl!,height: 200,width: 200,)
            else
              const Text('No image selected.'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _selectAndUploadImage,
              child: const Text('Select and Upload Image'),
            ),
          ],
        ),
      ),
    );
  }
}
