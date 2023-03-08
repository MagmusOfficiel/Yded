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
  final lifeController = TextEditingController();
  final posterController = TextEditingController();
  List<String> categories = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un monstre'),
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
                    decoration: const InputDecoration(border: InputBorder.none),
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
                  const Text('Vie: '),
                  Expanded(
                      child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(border: InputBorder.none),
                    controller: lifeController,
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
                  const Text('Image: '),
                  Expanded(
                      child: TextField(
                    decoration: InputDecoration(border: InputBorder.none),
                    controller: posterController,
                  ))
                ],
              ),
            ),
            const SizedBox(height: 20),
            DropDownMultiSelect(
              onChanged: (List<String> x) {
                setState(() {
                  categories = x;
                });
              },
              options: ['Feu', 'Eau', 'Terre', 'Air', 'Lumière', 'Ténébre'],
              selectedValues: categories,
              whenEmpty: 'Éléments',
            ),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: () {
                  FirebaseFirestore.instance.collection('Monsters').add({
                    'maxLife' : int.parse(lifeController.value.text),
                    'name': nameController.value.text,
                    'life': int.parse(lifeController.value.text),
                    'poster': posterController.value.text,
                    'categories': categories,
                    'dead': false
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
