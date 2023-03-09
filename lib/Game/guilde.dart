import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class Guilde extends StatefulWidget {
  const Guilde({Key? key}) : super(key: key);

  @override
  _GuildeState createState() => _GuildeState();
}

class _GuildeState extends State<Guilde> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final User? user = FirebaseAuth.instance.currentUser;
  late String userRole = '';

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    final docRef = FirebaseFirestore.instance.collection('User').doc(user?.uid);
    final docSnapshot = await docRef.get();
    final userData = docSnapshot.data();
    if (userData != null) {
        userRole = userData['role'];
    }
  }
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('User')
            .orderBy('level', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Erreur: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text('Chargement des utilisateurs...');
          }

          final documents = snapshot.data!.docs;
          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 8.0,
              crossAxisSpacing: 8.0,
              childAspectRatio: 1.0,
            ),
            itemCount: documents.length,
            itemBuilder: (context, index)  {
              final data = documents[index].data() as Map<String, dynamic>;
              final name = data['name'] ?? 'Inconnu';
              final specialisation = data['specialisation'];
              final level = data['level'];
              final attack = data['attack'];
              final chance = data['chance'];
              final id = documents[index].id;
              return InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        elevation: 5,
                        backgroundColor: Colors.black,
                        title: Text(name + ' - Nv.' + level.toString()),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.network(
                              "https://www.eddy-weber.fr/$specialisation.png",
                              height: MediaQuery.of(context).size.height / 6,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(height: 8.0),
                            const SizedBox(height: 8.0),
                            LinearPercentIndicator(
                              animateFromLastPercent: true,
                              animation: true,
                              width: MediaQuery.of(context).size.width / 1.5,
                              lineHeight: 20.0,
                              percent: attack / 100,
                              center: Text('Attaque : ${(attack).round()}'),
                              backgroundColor: Colors.grey,
                              progressColor: Colors.red,
                            ),
                            const SizedBox(height: 8.0),
                            LinearPercentIndicator(
                              animation: true,
                              animateFromLastPercent: true,
                              width: MediaQuery.of(context).size.width / 1.5,
                              lineHeight: 20.0,
                              percent: chance / 100,
                              center: Text('Chance : ${(chance).round()}'),
                              backgroundColor: Colors.grey,
                              progressColor: Colors.cyan,
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Icon(Icons.close)),
                          (userRole == 'admin') ?
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              _showEditDialog(data, id);
                            },
                            child: const Text('Modifier'),
                          ): SizedBox(),
                        ],
                      );
                    },
                  );
                },
                child: Card(
                  color: Colors.black,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network(
                        "https://www.eddy-weber.fr/$specialisation.png",
                      ),
                      const SizedBox(height: 8.0),
                      Text(name,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4.0),
                      Text(level.toString())
                    ],
                  ),
                ),
              );
            },
          );
        });
  }

  void _showEditDialog(Map<String, dynamic> userData, id) {
    final TextEditingController nameController =
        TextEditingController(text: userData['name']);
    final TextEditingController levelController =
        TextEditingController(text: userData['level'].toString());
    final TextEditingController attackController =
        TextEditingController(text: userData['attack'].toString());
    final TextEditingController chanceController =
        TextEditingController(text: userData['chance'].toString());
    final TextEditingController moneyController =
        TextEditingController(text: userData['money'].toString());
    final TextEditingController energyController =
        TextEditingController(text: userData['energy'].toString());
    final TextEditingController pointsController =
        TextEditingController(text: userData['points'].toString());
    final TextEditingController specialisationController =
        TextEditingController(text: userData['specialisation'].toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Modifier utilisateur'),
          content: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom',
                ),
              ),
              TextField(
                controller: levelController,
                decoration: const InputDecoration(
                  labelText: 'Niveau',
                ),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: moneyController,
                decoration: const InputDecoration(
                  labelText: 'Money',
                ),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: attackController,
                decoration: const InputDecoration(
                  labelText: 'Attaque',
                ),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: chanceController,
                decoration: const InputDecoration(
                  labelText: 'Chance',
                ),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: pointsController,
                decoration: const InputDecoration(
                  labelText: 'Points',
                ),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: energyController,
                decoration: const InputDecoration(
                  labelText: 'Energy',
                ),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: specialisationController,
                decoration: const InputDecoration(
                  labelText: 'Specialisation',
                ),
                keyboardType: TextInputType.text,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                FirebaseFirestore.instance.collection('User').doc(id).update({
                  'name': nameController.text,
                  'level': int.parse(levelController.text),
                  'attack': int.parse(attackController.text),
                  'chance': int.parse(chanceController.text),
                  'energy': int.parse(energyController.text),
                  'points': int.parse(pointsController.text),
                  'specialisation': int.parse(specialisationController.text),
                  'money': int.parse(moneyController.text)
                });
                Navigator.of(context).pop();
              },
              child: const Text('Enregistrer'),
            ),
          ],
        );
      },
    );
  }
}
