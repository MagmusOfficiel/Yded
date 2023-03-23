import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
    print(userRole);
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
            itemBuilder: (context, index) {
              final data = documents[index].data() as Map<String, dynamic>;
              final name = data['name'] ?? 'Inconnu';
              final specialisation = data['specialisation'];
              final level = data['level'];
              final stats = data['stats'];
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
                              height: 100,width: 100,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(height: 8.0),
                            const SizedBox(height: 8.0),
                            Column(
                              children: [
                                buildStatRow(
                                    Icons
                                        .add_circle_outline,
                                    'Attaque',
                                    stats
                                    ['attaque'],
                                    Colors.grey),
                                buildStatRow(
                                    Icons.flash_on,
                                    'Energy',
                                    data
                                    ['energy'],
                                    Colors.indigo),
                                buildStatRow(
                                    Icons
                                        .local_fire_department_sharp,
                                    'Feu',
                                    stats['feu'],
                                    Colors.red),
                                buildStatRow(
                                    Icons.water_drop,
                                    'Eau',
                                    stats['eau'],
                                    Colors.cyan),
                                buildStatRow(
                                    Icons.landscape,
                                    'Terre',
                                    stats
                                    ['terre'],
                                    Colors.brown),
                              ],
                            ),
                            Column(
                              children: [
                                buildStatRow(
                                    Icons.stars_outlined,
                                    'Chance',
                                    stats
                                    ['chance'],
                                    Colors.white),
                                buildStatRow(
                                    Icons.cloud,
                                    'Air',
                                    stats['air'],
                                    Colors.white),
                                buildStatRow(
                                    Icons.light_mode,
                                    'Lumière',
                                    stats
                                    ['lumière'],
                                    Colors.yellowAccent),
                                buildStatRow(
                                    Icons.dark_mode,
                                    'Ténébre',
                                    stats
                                    ['ténébre'],
                                    Colors.deepPurple),
                              ],
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Icon(Icons.close)),
                          (userRole == 'admin')
                              ? TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    _showEditDialog(data, id);
                                  },
                                  child: const Text('Modifier'),
                                )
                              : SizedBox(),
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
                        "https://www.eddy-weber.fr/$specialisation.png",fit: BoxFit.cover,width: 60,height: 60,
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
        TextEditingController(text: userData['stats']['attaque'].toString());
    final TextEditingController chanceController =
        TextEditingController(text: userData['stats']['chance'].toString());
    final TextEditingController feuController =
    TextEditingController(text: userData['stats']['feu'].toString());
    final TextEditingController eauController =
    TextEditingController(text: userData['stats']['eau'].toString());
    final TextEditingController terreController =
    TextEditingController(text: userData['stats']['terre'].toString());
    final TextEditingController airController =
    TextEditingController(text: userData['stats']['air'].toString());
    final TextEditingController lumiereController =
    TextEditingController(text: userData['stats']['lumière'].toString());
    final TextEditingController tenebreController =
    TextEditingController(text: userData['stats']['ténébre'].toString());
    final TextEditingController moneyController =
        TextEditingController(text: userData['money'].toString());
    final TextEditingController energyController =
        TextEditingController(text: userData['energy'].toString());
    final TextEditingController pointsController =
        TextEditingController(text: userData['points'].toString());

    showDialog(
      context: context,
      builder: (context) {
        return SingleChildScrollView( child : AlertDialog(
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
                controller: feuController,
                decoration: const InputDecoration(
                  labelText: 'Feu',
                ),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: eauController,
                decoration: const InputDecoration(
                  labelText: 'Eau',
                ),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: terreController,
                decoration: const InputDecoration(
                  labelText: 'terre',
                ),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: airController,
                decoration: const InputDecoration(
                  labelText: 'Air',
                ),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: lumiereController,
                decoration: const InputDecoration(
                  labelText: 'Lumière',
                ),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: tenebreController,
                decoration: const InputDecoration(
                  labelText: 'Ténébre',
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
                  'stats': {
                    'attaque': int.parse(attackController.text),
                    'chance': int.parse(chanceController.text),
                    'feu': int.parse(feuController.text),
                    'eau': int.parse(eauController.text),
                    'terre': int.parse(terreController.text),
                    'air': int.parse(airController.text),
                    'lumière': int.parse(lumiereController.text),
                    'ténébre': int.parse(tenebreController.text)
                  },
                  'energy': int.parse(energyController.text),
                  'name': nameController.text,
                  'level': int.parse(levelController.text),
                  'points': int.parse(pointsController.text),
                  'money': int.parse(moneyController.text)
                });
                Navigator.of(context).pop();
              },
              child: const Text('Enregistrer'),
            ),
          ],
        ));
      },
    );
  }

// Helper functions
  Widget buildStatRow(IconData icon, String label, int value, Color color) {
    return Row(
      children: [
        Icon(icon, color: color),
        Text('$label : $value'),
      ],
    );
  }

}
