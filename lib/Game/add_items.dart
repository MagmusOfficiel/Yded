import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:yded/Service/firebase_storage_service.dart';
import 'dart:io';

class AddItem extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AddItemState();
}

class _AddItemState extends State<AddItem> {
  final _textControllers =
  List<TextEditingController>.generate(12, (_) => TextEditingController());
  final _textInputTypes = [
    TextInputType.text,
    TextInputType.number,
    TextInputType.number,
    TextInputType.number,
    TextInputType.number,
    TextInputType.number,
    TextInputType.number,
    TextInputType.number,
    TextInputType.number,
    TextInputType.number,
    TextInputType.text,
    TextInputType.text,
    TextInputType.number,
  ];
  final _fieldLabels = [
    'Nom',
    'Energy',
    'Att',
    'Ch',
    'Feu',
    'Eau',
    'Terre',
    'Air',
    'Lumière',
    'Ténébre',
    'Image',
    'Coût',
  ];

  String? _selectedCategory;
  String? _selectedType;
  File? _image;
  final _firebaseStorageService = FirebaseStorageService();

  @override
  Widget build(BuildContext context) {
    print(FirebaseAuth.instance.currentUser);
    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter un item')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              for (int i = 0; i < _textControllers.length; i++)
                _buildTextField(i),
              const SizedBox(height: 20),
              _buildDropdownMenu(),
              const SizedBox(height: 20),
              _buildTypeDropdown(),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _addItem, child: const Text('Ajouter')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(int index) {
    if (index == 10) {
      return ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(color: Colors.white30, width: 1.5),
        ),
        title: Row(
          children: [
            Text('${_fieldLabels[index]}: '),
            Expanded(
              child: TextField(
                keyboardType: _textInputTypes[index],
                decoration: const InputDecoration(border: InputBorder.none),
                controller: _textControllers[index],
                readOnly: true,
              ),
            ),
            IconButton(
              icon: Icon(Icons.file_upload),
              onPressed: _pickAndUploadImage,
            ),
          ],
        ),
      );
    } else {
      return ListTile(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
            side: const BorderSide(color: Colors.white30, width: 1.5)),
        title: Row(
          children: [
            Text('${_fieldLabels[index]}: '),
            Expanded(
              child: TextField(
                keyboardType: _textInputTypes[index],
                decoration: const InputDecoration(border: InputBorder.none),
                controller: _textControllers[index],
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildDropdownMenu() {
    return DropdownButton<String?>(
      value: _selectedCategory,
      onChanged: (String? newValue) =>
          setState(() => _selectedCategory = newValue),
      items: <String>['Unique', 'Stuff']
          .map<DropdownMenuItem<String>>(
            (String value) =>
            DropdownMenuItem<String>(value: value, child: Text(value)),
      )
          .toList(),
    );
  }

  Widget _buildTypeDropdown() {
    return DropdownButton<String?>(
      value: _selectedType,
      onChanged: (String? newValue) => setState(() => _selectedType = newValue),
      items: <String>[
        'Casque',
        'Collier',
        'Epaule',
        'Cape',
        'Torse',
        'Chemise',
        'Brassard',
        'Arme',
        'Arme2',
        'Gants',
        'Ceinture',
        'Jambière',
        'Bottes',
        'Bijoux',
        'Pet',
        'Bouclier',
        'Utilisable',
      ]
          .map<DropdownMenuItem<String>>(
            (String value) =>
            DropdownMenuItem<String>(value: value, child: Text(value)),
      )
          .toList(),
    );
  }

  Future<void> _pickAndUploadImage() async {
    File? image = await _firebaseStorageService.pickImage();
    if (image != null) {
      setState(() {
        _image = image;
      });
      String imagePath = 'images/${DateTime.now().toString()}.png';
      String imageUrl = await _firebaseStorageService.uploadImage(
          _image!, imagePath);
      _textControllers[10].text = imageUrl;
    }
  }

  void _addItem() {
    FirebaseFirestore.instance.collection('Boutique').add({
      'stats': {
        'energy': int.parse(_textControllers[1].value.text),
        'attaque': int.parse(_textControllers[2].value.text),
        'chance': int.parse(_textControllers[3].value.text),
        'feu': int.parse(_textControllers[4].value.text),
        'eau': int.parse(_textControllers[5].value.text),
        'terre': int.parse(_textControllers[6].value.text),
        'air': int.parse(_textControllers[7].value.text),
        'lumière': int.parse(_textControllers[8].value.text),
        'ténébre': int.parse(_textControllers[9].value.text),
      },
      'cout': int.parse(_textControllers[11].value.text),
      'name': _textControllers[0].value.text,
      'categories': _selectedCategory,
      'types': _selectedType,
      'poster': _textControllers[10].value.text,
    });
    Navigator.pop(context);
  }
}
