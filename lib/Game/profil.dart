import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class Profil extends StatefulWidget {
  const Profil({Key? key}) : super(key: key);

  @override
  _ProfilState createState() => _ProfilState();
}

class _ProfilState extends State<Profil> {
  final _user = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> _personnage = FirebaseFirestore.instance
        .collection('User')
        .where('email', isEqualTo: _user.email)
        .snapshots();
    return StreamBuilder<QuerySnapshot>(
        stream: _personnage,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Une erreur est survenue : ${snapshot.error}');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return Text('Aucun personnage trouvé pour cet utilisateur.');
          }

          // Récupère le premier document du QuerySnapshot
          final personnage = snapshot.data!.docs.first;
          // Récupère la propriété "level" du personnage
          var points = personnage.get('points');
          var stats = personnage.get('stats');
          var level = personnage.get('level');
          // Récupère la référence de la collection Boutique dans le document de l'utilisateur
          var inventoryRef = personnage.reference.collection('Inventory');
          // Récupère les données de la collection Inventory liée à la collection Boutique
          final Stream<QuerySnapshot> _inventory = inventoryRef.snapshots();

          return Column(children: [
            (level < 10)
                ? Text(
                    "Disponible à partir du Nv.10".toUpperCase(),
                    style: TextStyle(),
                  )
                : Text(
                    "Disponible".toUpperCase(),
                    style: const TextStyle(),
                  ),
            (level < 10)
                ? ElevatedButton.icon(
                    onPressed: () {},
                    label: const Text("SPÉCIALISATION"),
                    icon: const Icon(Icons.stacked_line_chart_rounded),
                    style: ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(
                            Colors.indigo.withOpacity(0.1))),
                  )
                : ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Choisissez une spécialisation',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    const SizedBox(width: 15),
                                    GestureDetector(
                                      onTap: () {
                                        FirebaseFirestore.instance
                                            .collection('User')
                                            .doc(personnage.id)
                                            .update(
                                                {'specialisation': 'archer'});
                                        FirebaseFirestore.instance
                                            .collection('User')
                                            .doc(personnage.id)
                                            .update({
                                          'sorts': [
                                            'Flèche rapide',
                                            'Précision',
                                            'Tir prècis',
                                            'Triple flèches'
                                          ]
                                        });
                                      },
                                      child: Container(
                                        height:
                                            MediaQuery.of(context).size.height /
                                                3,
                                        width:
                                            MediaQuery.of(context).size.width /
                                                3.5,
                                        color: Colors.black,
                                        child: Card(
                                          shadowColor: Colors.green,
                                          elevation: 30,
                                          color: Colors.green.withOpacity(0.5),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: const [
                                              Text("Archer"),
                                              Icon(Icons.eco)
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    GestureDetector(
                                        onTap: () {
                                          FirebaseFirestore.instance
                                              .collection('User')
                                              .doc(personnage.id)
                                              .update({
                                            'specialisation': 'sorcier'
                                          });

                                          FirebaseFirestore.instance
                                              .collection('User')
                                              .doc(personnage.id)
                                              .update({
                                            'sorts': [
                                              'Boule de feu',
                                              'Concentration',
                                              'Laser glace',
                                              'Tonnerre'
                                            ]
                                          });
                                        },
                                        child: Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              3,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              3.5,
                                          color: Colors.black,
                                          child: Card(
                                            shadowColor: Colors.blue,
                                            elevation: 30,
                                            color: Colors.blue.withOpacity(0.5),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: const [
                                                Text("Sorcier"),
                                                Icon(Icons.ac_unit_rounded)
                                              ],
                                            ),
                                          ),
                                        )),
                                    const SizedBox(width: 10),
                                    GestureDetector(
                                        onTap: () {
                                          FirebaseFirestore.instance
                                              .collection('User')
                                              .doc(personnage.id)
                                              .update({
                                            'specialisation': 'guerrier'
                                          });

                                          FirebaseFirestore.instance
                                              .collection('User')
                                              .doc(personnage.id)
                                              .update({
                                            'sorts': [
                                              'Tranche',
                                              'Berserk',
                                              'Coupe sang',
                                              'Fulgurance'
                                            ]
                                          });
                                        },
                                        child: Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              3,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              3.5,
                                          color: Colors.black,
                                          child: Card(
                                            shadowColor: Colors.red,
                                            elevation: 30,
                                            color: Colors.red.withOpacity(0.5),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: const [
                                                Text("Guerrier"),
                                                Icon(Icons.balcony_sharp)
                                              ],
                                            ),
                                          ),
                                        )),
                                  ],
                                )
                              ]);
                        },
                      );
                    },
                    label: const Text("SPÉCIALISATION"),
                    icon: const Icon(Icons.stacked_line_chart_rounded),
                    style: const ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(Colors.indigo),
                    ),
                  ),
            const SizedBox(height: 16.0),
            Text(
              'Nombre de points à attribué : $points',
              style: const TextStyle(fontSize: 20),
            ),
            Column(
              children: [
                Row(
                  children: [
                    LinearPercentIndicator(
                      trailing: stats['attack'] == 100
                          ? const Text(
                              "MAX",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            )
                          : ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor:
                                      const MaterialStatePropertyAll(
                                          Colors.red),
                                  minimumSize: MaterialStateProperty.all(
                                      const Size(15, 15))),
                              onPressed: () {
                                if (points != 0) {
                                  setState(() {
                                    stats['attaque']++;
                                    points--;
                                    FirebaseFirestore.instance
                                        .collection('User')
                                        .doc(personnage.id)
                                        .update({
                                      'stats': {
                                        "attaque": stats['attaque'],
                                        "chance": stats['chance']
                                      }
                                    });

                                    FirebaseFirestore.instance
                                        .collection('User')
                                        .doc(personnage.id)
                                        .update({'points': points});
                                  });
                                }
                              },
                              child: const Icon(
                                Icons.add,
                                size: 20,
                              ),
                            ),
                      animateFromLastPercent: true,
                      animation: true,
                      width: MediaQuery.of(context).size.width / 1.5,
                      lineHeight: 20.0,
                      percent: stats['attaque'] / 100,
                      center: Text('Attaque : ${(stats['attaque']).round()}'),
                      backgroundColor: Colors.grey,
                      progressColor: Colors.red,
                    ),
                  ],
                ),
                Row(
                  children: [
                    LinearPercentIndicator(
                      trailing: stats['chance'] == 100
                          ? const Text(
                              "MAX",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            )
                          : ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor:
                                      const MaterialStatePropertyAll(
                                          Colors.cyan),
                                  minimumSize: MaterialStateProperty.all(
                                      const Size(15, 15))),
                              onPressed: () {
                                if (points != 0) {
                                  setState(() {
                                    stats['chance']++;
                                    points--;
                                    FirebaseFirestore.instance
                                        .collection('User')
                                        .doc(personnage.id)
                                        .update({
                                      'stats': {
                                        "attaque": stats['attaque'],
                                        "chance": stats['chance']
                                      }
                                    });

                                    FirebaseFirestore.instance
                                        .collection('User')
                                        .doc(personnage.id)
                                        .update({'points': points});
                                  });
                                }
                              },
                              child: const Icon(
                                Icons.add,
                                size: 20,
                              ),
                            ),
                      animation: true,
                      animateFromLastPercent: true,
                      width: MediaQuery.of(context).size.width / 1.5,
                      lineHeight: 20.0,
                      percent: stats['chance'] / 100,
                      center: Text('Chance : ${(stats['chance']).round()}'),
                      backgroundColor: Colors.grey,
                      progressColor: Colors.cyan,
                    ),
                  ],
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: _inventory,
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return Text(
                          'Une erreur est survenue : ${snapshot.error}');
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
                      return Text('Aucun item trouvé dans l\'inventaire.');
                    }

                    final List<DocumentSnapshot> itemList = snapshot.data!.docs;
                    final List<DocumentSnapshot> stuffList = itemList
                        .where((item) => item['categories'].contains('Stuff'))
                        .toList();
                    final List<DocumentSnapshot> potionList = itemList
                        .where((item) => item['categories'].contains('Unique'))
                        .toList();
                    return Column(children: [
                      (potionList.isNotEmpty)
                          ? Column(children: [
                              Text("Utilisable"),
                              GridView.builder(
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    mainAxisSpacing: 15.0,
                                    crossAxisSpacing: 15.0,
                                    childAspectRatio: 1.0,
                                  ),
                                  shrinkWrap: true,
                                  itemCount: potionList.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    final DocumentSnapshot document =
                                        potionList[index];
                                    final Map<String, dynamic> data = document
                                        .data()! as Map<String, dynamic>;
                                    final String quantity =
                                        data['quantity'].toString();
                                    return Container(
                                      width: double.infinity,
                                      child: Card(
                                        color: Colors.black,
                                        child: Column(
                                          children: [
                                            const SizedBox(height: 8.0),
                                            Image.network(
                                              data['poster'],
                                              fit: BoxFit.cover,
                                              width: 35,
                                            ),
                                            const SizedBox(height: 7.0),
                                            Text(
                                              data['name'] +
                                                  ' x' +
                                                  quantity.toString(),
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12),
                                            ),
                                            const SizedBox(height: 7.0),
                                            Expanded(
                                                child: ElevatedButton(
                                              style: ButtonStyle(
                                                backgroundColor:
                                                    MaterialStateProperty.all(
                                                        Colors.indigo),
                                                minimumSize:
                                                    MaterialStateProperty.all(
                                                        const Size(120, 15)),
                                              ),
                                              onPressed: () async {},
                                              child: const Text(
                                                "Utiliser",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            )),
                                          ],
                                        ),
                                      ),
                                    );
                                  })
                            ])
                          : SizedBox(),
                      (stuffList.isNotEmpty)
                          ? Column(children: [
                              Text("Equipements"),
                              GridView.builder(
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    mainAxisSpacing: 15.0,
                                    crossAxisSpacing: 15.0,
                                    childAspectRatio: 1.0,
                                  ),
                                  shrinkWrap: true,
                                  itemCount: stuffList.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    final DocumentSnapshot document =
                                        stuffList[index];
                                    final Map<String, dynamic> data = document
                                        .data()! as Map<String, dynamic>;
                                    final String quantity =
                                        data['quantity'].toString();
                                    return Container(
                                      width: double.infinity,
                                      child: Card(
                                        color: Colors.black,
                                        child: Column(
                                          children: [
                                            const SizedBox(height: 8.0),
                                            Image.network(
                                              data['poster'],
                                              fit: BoxFit.cover,
                                              width: 35,
                                            ),
                                            const SizedBox(height: 7.0),
                                            Text(
                                              data['name'] +
                                                  ' x' +
                                                  quantity.toString(),
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12),
                                            ),
                                            const SizedBox(height: 7.0),
                                            Expanded(
                                                child: ElevatedButton(
                                              style: ButtonStyle(
                                                backgroundColor:
                                                    MaterialStateProperty.all(
                                                        Colors.indigo),
                                                minimumSize:
                                                    MaterialStateProperty.all(
                                                        const Size(120, 15)),
                                              ),
                                              onPressed: () async {},
                                              child: const Text(
                                                "Equipé",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            )),
                                          ],
                                        ),
                                      ),
                                    );
                                  })
                            ])
                          : SizedBox()
                    ]);
                  },
                ),
              ],
            )
          ]);
        });
  }
}
