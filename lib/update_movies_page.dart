import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:multiselect/multiselect.dart';

class UpdatePage extends StatefulWidget {
  late final String _name;
  late final String _year;
  late final String _poster;
  late final String _docId;
  late List<String> _categories = [];

   UpdatePage({Key? key, required String name, required String year, required String poster,required List<dynamic> categories, required String docId}) : super(key: key){
    _name = name;
    _year = year;
    _poster = poster;
    _docId = docId;
    _categories = List<String>.from(categories);
  }
  @override
  _UpdatePageState createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
  late final TextEditingController nameController;
  late final TextEditingController yearController;
  late final TextEditingController posterController;
  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget._name);
    yearController = TextEditingController(text: widget._year);
    posterController = TextEditingController(text: widget._poster);
  }

  @override
  void dispose() {
    nameController.dispose();
    yearController.dispose();
    posterController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update movies'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
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
                  const Text('Année: '),
                  Expanded(
                      child: TextField(
                        decoration: const InputDecoration(border: InputBorder.none),
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
                        decoration: const InputDecoration(border: InputBorder.none),
                        controller: posterController,
                      ))
                ],
              ),
            ),
            DropDownMultiSelect(
              onChanged: (List<String> x) {
                setState(() {
                  widget._categories = x;
                });
              },
              options: ['Action', 'Science-fiction', 'Aventure', 'Comédie'],
              selectedValues: widget._categories.toList().cast<String>(),
              whenEmpty: 'Catégorie',
            ),
            ElevatedButton(
                onPressed: () {
                  FirebaseFirestore.instance.collection('Movies').doc(widget._docId).update({
                    'name': nameController.value.text,
                    'year': yearController.value.text,
                    'poster': posterController.value.text,
                    'categories': widget._categories,
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
