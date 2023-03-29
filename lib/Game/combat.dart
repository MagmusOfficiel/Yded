import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
      setState(() {
        userRole = userData['role'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: _monstersStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return Stack(children: [
            SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Image.asset(
                "assets/images/tour.png",
                fit: BoxFit.cover,
              ),
            ),
            ListView(
                children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> monstre =
                  document.data()! as Map<String, dynamic>;
              return GestureDetector(
                  onTap: () => (monstre['dead'] == false)
                      ? Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) {
                            return MonsterFight(
                              maxLife: monstre['maxLife'],
                              name: monstre['name'],
                              dead: monstre['dead'],
                              life: monstre['life'],
                              poster: monstre['poster'],
                              docId: document.id,
                              categories: monstre['categories'],
                              bloque: true,
                              nbrUser: monstre['nbrUser']
                            );

                          },

                        ))
                      : null,
                  child: Card(
                    margin: const EdgeInsets.all(10),
                    color: (monstre['dead'] == false && monstre['bloque'] == false)
                        ? Colors.black.withOpacity(0.8)
                        : Colors.black.withOpacity(0.5),
                    shadowColor:
                        (monstre['dead'] == false) ? Colors.green : Colors.red,
                    elevation: 50,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        ListTile(
                          leading: SizedBox(
                            child: (monstre['dead'] == false)
                                ? Image.network(
                                    monstre['poster'],
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) {
                                        return child;
                                      }
                                      return CircularProgressIndicator(
                                        value: loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!
                                            : null,
                                      );
                                    },
                                    errorBuilder: (BuildContext context,
                                        Object exception,
                                        StackTrace? starcktrace) {
                                      return Image.network(
                                          "https://www.eddy-weber.fr/monstre-inconnu.png");
                                    },
                                  )
                                : Image.network(
                                    "https://www.eddy-weber.fr/mort.gif"),
                          ),
                          trailing: (monstre['dead'] == true)
                              ? (userRole == "admin")
                                  ? ElevatedButton(
                                      onPressed: () =>
                                          _showEditDialog(monstre, document.id),
                                      style: const ButtonStyle(
                                          backgroundColor:
                                              MaterialStatePropertyAll(
                                                  Colors.transparent)),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.red,
                                      ),
                                    )
                                  : const SizedBox()
                              : ElevatedButton(
                                  onPressed: () => {
                                        (userRole == 'admin')
                                            ? _showEditDialog(
                                                monstre, document.id)
                                            : null
                                      },
                                  style: const ButtonStyle(
                                      backgroundColor: MaterialStatePropertyAll(
                                          Colors.transparent)),
                                  child: const Icon(
                                    Icons.grade,
                                    color: Colors.yellow,
                                  )),
                          title: (monstre['dead'] == false)
                              ? Text(
                                  '${monstre['name'].toString().toUpperCase()} - VIE : ${monstre['life']}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FontStyle.italic),
                                )
                              : Text(
                                  '${monstre['name'].toString().toUpperCase()} - MORT',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FontStyle.italic),
                                ),
                          subtitle: (monstre['bloque'] == false) ? Text(
                            'Niveau : ${getDifficultyLevel(maxLife: monstre['maxLife'])}',
                            textAlign: TextAlign.center,
                          ) : const Text("Combat en cours...",textAlign: TextAlign.center,),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
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
                        )
                      ],
                    ),
                  ));
            }).toList()),
            (userRole == "admin")
                ? Positioned(
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
                            backgroundColor:
                                MaterialStatePropertyAll(Colors.white)),
                        child: const Icon(Icons.add, color: Colors.black)))
                : const SizedBox()
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
  String getDifficultyLevel({required int maxLife}) {
    String level;
    if (maxLife <= 500) {
      level = "Débutant";
    } else if (maxLife <= 1000) {
      level = "Survivant";
    } else if (maxLife <= 5000) {
      level = "Némésis";
    } else if (maxLife <= 10000) {
      level = "Monstrueux";
    } else {
      level = "Apocalypse";
    }
    return level;
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

  void _showEditDialog(Map<String, dynamic> userData, String id) {
    final TextEditingController nameController =
    TextEditingController(text: userData['name']);
    bool mortController = userData['dead'] ?? true;
    final TextEditingController lifeController =
    TextEditingController(text: userData['life'].toString());
    final TextEditingController maxLifeController =
    TextEditingController(text: userData['maxLife'].toString());
    final TextEditingController imageController =
    TextEditingController(text: userData['poster'].toString());
    final TextEditingController categoriesController =
    TextEditingController(text: userData['categories'].join(', '));

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Modifier utilisateur'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom',
                ),
              ),
              Switch(
                value: mortController,
                onChanged: (newValue) {
                  setState(() {
                    mortController = newValue;
                  });
                },
                activeTrackColor: Colors.lightGreenAccent,
                activeColor: Colors.green,
              ),
              TextField(
                controller: imageController,
                decoration: const InputDecoration(
                  labelText: 'Image',
                ),
                keyboardType: TextInputType.text,
              ),
              TextField(
                controller: lifeController,
                decoration: const InputDecoration(
                  labelText: 'Vie',
                ),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: maxLifeController,
                decoration: const InputDecoration(
                  labelText: 'Vie max',
                ),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: categoriesController,
                decoration: const InputDecoration(
                  labelText: 'Categories',
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
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance
                      .collection('Monsters')
                      .doc(id)
                      .update({
                    'name': nameController.text,
                    'dead': mortController,
                    'life': int.parse(lifeController.text),
                    'maxLife': int.parse(maxLifeController.text),
                    'poster': imageController.text,
                    'categories': categoriesController.text.split(', ')
                  });
                  Navigator.of(context).pop();
                } catch (error) {
                  print('Erreur lors de la mise à jour des données : $error');
                }
              },
              child: const Text('Enregistrer'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance
                      .collection("Monsters")
                      .doc(id)
                      .delete();
                  Navigator.of(context).pop();
                } catch (error) {
                  print('Erreur lors de la suppression des données : $error');
                }
              },
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }
}
