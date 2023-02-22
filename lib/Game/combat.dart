import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:yded/Game/monster_fight.dart';
import 'add_monster.dart';

class Combat extends StatefulWidget {
  const Combat({Key? key}) : super(key: key);

  @override
  _CombatState createState() => _CombatState();
}

class _CombatState extends State<Combat> {
  final Stream<QuerySnapshot> _monstersStream = FirebaseFirestore.instance
      .collection('Monsters')
      .orderBy('life', descending: true)
      .snapshots();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: _monstersStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return Stack(children: [
            ListView(
                children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> monstre =
                  document.data()! as Map<String, dynamic>;
              return GestureDetector(
                  onTap: () => (monstre['dead'] == false) ? Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) {
                          return UpdatePage(
                            name: monstre['name'],
                            dead: monstre['dead'],
                            life: monstre['life'],
                            poster: monstre['poster'],
                            docId: document.id,
                            categories: monstre['categories'],
                          );
                        },
                      )) : null,
                  child: Card(
                    margin: const EdgeInsets.all(10),
                    color:  (monstre['dead'] == false) ? Colors.black : Colors.black.withOpacity(0.5),
                    shadowColor:(monstre['dead'] == false) ? Colors.green : Colors.red,
                    elevation: 50,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        ListTile(
                          leading: SizedBox(
                            child: (monstre['dead'] == false)
                                ? Image.network(monstre['poster'])
                                : Image.network(
                                    "https://www.eddy-weber.fr/mort.gif"),
                          ),
                          title: (monstre['dead'] == false) ? Text(
                            '${monstre['name'].toString().toUpperCase()} - VIE : ${monstre['life']}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic),
                          ) : Text(
                            '${monstre['name'].toString().toUpperCase()} - MORT',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic),
                          ),
                          subtitle: const Text(
                            'Niveau de difficulté : Difficile',
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  for (final categorie in monstre['categories'])
                                    Padding(
                                      padding: const EdgeInsets.only(right: 5),
                                      child: Icon(
                                        _bgChip(categorie: categorie),
                                        color: _colorChip(categorie: categorie),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ));
            }).toList()),
            Positioned(
                bottom: MediaQuery.of(context).size.height / 35,
                right: MediaQuery.of(context).size.width / 2.5,
                child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) {
                            return const AddPage();
                          },
                          fullscreenDialog: true));
                    },
                    style: const ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(Colors.red)),
                    child: const Icon(Icons.add, color: Colors.white)))
          ]);
        });
  }

  /// Permet de déterminer quel state est appelé.
  dynamic _bgChip({required String categorie}) {
    Object bgChip = {
      "Feu": Icons.local_fire_department_sharp,
      "Eau": Icons.water_drop,
      "Terre": Icons.landscape,
      "Air": Icons.cloud,
      "Lumière": Icons.light_mode,
      "Ténébre": Icons.dark_mode
    }.putIfAbsent(
        categorie,
        () => const IconData(
              0xFF181861,
            ));
    return bgChip;
  }

  /// Permet de déterminer quel state est appelé.
  dynamic _colorChip({required String categorie}) {
    Object colorChip = {
      "Feu": Colors.red,
      "Eau": Colors.cyan,
      "Terre": Colors.brown,
      "Air": Colors.white,
      "Lumière": Colors.yellow,
      "Ténébre": Colors.purple
    }.putIfAbsent(
        categorie,
        () => const MaterialColor(
              0xFF181861,
              <int, Color>{
                50: Color(0xFFA4A4BF),
              },
            ));
    return colorChip;
  }
}