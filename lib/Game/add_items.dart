import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:multiselect/multiselect.dart';

class AddItem extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AddItemState();
}

class _AddItemState extends State<AddItem> {
  final nameController = TextEditingController();
  final lifeController = TextEditingController();
  final posterController = TextEditingController();
  final energyController = TextEditingController();
  final coutController = TextEditingController();
  final chanceController = TextEditingController();
  final attController = TextEditingController();
  final feuController = TextEditingController();
  final eauController = TextEditingController();
  final terreController = TextEditingController();
  final airController = TextEditingController();
  final lumiereController = TextEditingController();
  final tenebreController = TextEditingController();

  String? types;
  String? selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un item'),
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
                  const Text('Energy: '),
                  Expanded(
                      child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(border: InputBorder.none),
                    controller: energyController,
                  )),
                  const Text('Att: '),
                  Expanded(
                      child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(border: InputBorder.none),
                    controller: attController,
                  )),
                  const Text('Ch: '),
                  Expanded(
                      child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(border: InputBorder.none),
                    controller: chanceController,
                  )),
                ],
              ),
            ),
            ListTile(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                  side: const BorderSide(color: Colors.white30, width: 1.5)),
              title: Row(
                children: [
                  const Text('Feu: '),
                  Expanded(
                      child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(border: InputBorder.none),
                    controller: feuController,
                  )),
                  const Text('Eau: '),
                  Expanded(
                      child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(border: InputBorder.none),
                    controller: eauController,
                  )),
                  const Text('Terre: '),
                  Expanded(
                      child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(border: InputBorder.none),
                    controller: terreController,
                  )),
                ],
              ),
            ),
            ListTile(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                  side: const BorderSide(color: Colors.white30, width: 1.5)),
              title: Row(
                children: [
                  const Text('Air: '),
                  Expanded(
                      child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(border: InputBorder.none),
                    controller: airController,
                  )),
                  const Text('Lumière: '),
                  Expanded(
                      child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(border: InputBorder.none),
                    controller: lumiereController,
                  )),
                  const Text('Ténébre: '),
                  Expanded(
                      child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(border: InputBorder.none),
                    controller: tenebreController,
                  )),
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
            ListTile(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                  side: const BorderSide(color: Colors.white30, width: 1.5)),
              title: Row(
                children: [
                  const Text('Coût: '),
                  Expanded(
                      child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(border: InputBorder.none),
                    controller: coutController,
                  ))
                ],
              ),
            ),
            const SizedBox(height: 20),
            DropdownButton<String?>(
              value: selectedCategory,
              onChanged: (String? newValue) {
                setState(() {
                  selectedCategory = newValue;
                });
              },
              items: <String>['Unique', 'Stuff']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            DropdownButton<String?>(
              value: types,
              onChanged: (String? newValue) {
                setState(() {
                  types = newValue;
                });
              },
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
                'Utilisable'
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: () {
                  FirebaseFirestore.instance.collection('Boutique').add({
                    'stats': {
                      'energy': int.parse(energyController.value.text),
                      'attaque': int.parse(attController.value.text),
                      'chance': int.parse(chanceController.value.text),
                      'feu': int.parse(feuController.value.text),
                      'eau': int.parse(eauController.value.text),
                      'terre': int.parse(terreController.value.text),
                      'air': int.parse(airController.value.text),
                      'lumière': int.parse(lumiereController.value.text),
                      'ténébre': int.parse(tenebreController.value.text)
                    },
                    'cout': int.parse(coutController.value.text),
                    'name': nameController.value.text,
                    'categories': selectedCategory,
                    'types': types,
                    'poster': posterController.value.text
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
