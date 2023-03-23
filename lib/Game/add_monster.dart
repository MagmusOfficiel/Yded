import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:multiselect/multiselect.dart';

class AddPage extends StatefulWidget {
  const AddPage({Key? key}) : super(key: key);

  @override
  _AddPageState createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final List<TextEditingController> _textControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];
  List<String> _categories = [];

  Widget _buildTextField(
      String labelText, TextInputType keyboardType, int index) {
    return ListTile(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(color: Colors.white30, width: 1.5)),
      title: Row(
        children: [
          Text(labelText),
          Expanded(
            child: TextField(
              keyboardType: keyboardType,
              decoration: const InputDecoration(border: InputBorder.none),
              controller: _textControllers[index],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un monstre'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            _buildTextField('Nom: ', TextInputType.text, 0),
            const SizedBox(height: 20),
            _buildTextField('Vie: ', TextInputType.number, 1),
            const SizedBox(height: 20),
            _buildTextField('Image: ', TextInputType.text, 2),
            const SizedBox(height: 20),
            DropDownMultiSelect(
              onChanged: (List<String> x) {
                setState(() {
                  _categories = x;
                });
              },
              options: const [
                'Feu',
                'Eau',
                'Terre',
                'Air',
                'Lumière',
                'Ténébre'
              ],
              selectedValues: _categories,
              whenEmpty: 'Éléments',
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                FirebaseFirestore.instance.collection('Monsters').add({
                  'maxLife': int.parse(_textControllers[1].value.text),
                  'name': _textControllers[0].value.text,
                  'life': int.parse(_textControllers[1].value.text),
                  'poster': _textControllers[2].value.text,
                  'categories': _categories,
                  'dead': false,
                  'bloque': false,
                  'nbrUser' : 0
                });
                Navigator.pop(context);
              },
              child: const Text('Ajouter'),
            ),
          ],
        ),
      ),
    );
  }
}
