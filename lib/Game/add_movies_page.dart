import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:multiselect/multiselect.dart';

class AddPage extends StatefulWidget {
  const AddPage({Key? key}) : super(key: key);

  @override
  _AddPageState createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final nameController = TextEditingController();
  final yearController = TextEditingController();
  final posterController = TextEditingController();
  List<String> categories = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add movies'),
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            ListTile(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                  side: const BorderSide(color: Colors.white30, width: 1.5)),
              title: Row(
                children: [
                  const Text('Nom: '),
                  Expanded(
                      child: TextField(
                    decoration: InputDecoration(border: InputBorder.none),
                    controller: nameController,
                  ))
                ],
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                  side: const BorderSide(color: Colors.white30, width: 1.5)),
              title: Row(
                children: [
                  const Text('Année: '),
                  Expanded(
                      child: TextField(
                    decoration: InputDecoration(border: InputBorder.none),
                    controller: yearController,
                  ))
                ],
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                  side: const BorderSide(color: Colors.white30, width: 1.5)),
              title: Row(
                children: [
                  const Text('Poster: '),
                  Expanded(
                      child: TextField(
                    decoration: InputDecoration(border: InputBorder.none),
                    controller: posterController,
                  ))
                ],
              ),
            ),
            DropDownMultiSelect(
              onChanged: (List<String> x) {
                setState(() {
                  categories = x;
                });
              },
              options: ['Action', 'Science-fiction', 'Aventure', 'Comédie'],
              selectedValues: categories,
              whenEmpty: 'Catégorie',
            ),
            ElevatedButton(
                onPressed: () {
                  FirebaseFirestore.instance.collection('Movies').add({
                    'name': nameController.value.text,
                    'year': yearController.value.text,
                    'poster': posterController.value.text,
                    'categories': categories,
                    'likes': 0
                  });
                  Navigator.pop(context);
                },
                child: const Text('Ajouter'))
          ],
        ),
      ),
    );
  }
}
