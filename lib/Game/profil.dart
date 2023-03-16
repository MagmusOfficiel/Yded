import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
          var energy = personnage.get('energy');
          // Récupère la référence de la collection Boutique dans le document de l'utilisateur
          var inventoryRef = personnage.reference.collection('Inventory');
          var equipmentsRef = personnage.reference.collection('Equipements');
          // Retrieve equipment collection and loop through each document to add its stats to the user's stats
          return FutureBuilder<QuerySnapshot>(
              future: equipmentsRef.get(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> equipmentsSnapshot) {
                if (equipmentsSnapshot.hasError) {
                  return Text(
                      'Une erreur est survenue lors de la récupération des équipements : ${equipmentsSnapshot.error}');
                }
                if (equipmentsSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                // Traiter les équipements
                equipmentsSnapshot.data!.docs.forEach((equipmentDoc) {
                  // Retrieve equipment stats
                  var equipmentStats = equipmentDoc.get('stats');
                  // Add equipment stats to user's stats
                  stats['attaque'] += equipmentStats['attaque'];
                  stats['chance'] += equipmentStats['chance'];
                  stats['feu'] += equipmentStats['feu'];
                  stats['eau'] += equipmentStats['eau'];
                  stats['air'] += equipmentStats['air'];
                  stats['terre'] += equipmentStats['terre'];
                  stats['lumière'] += equipmentStats['lumière'];
                  stats['ténébre'] += equipmentStats['ténébre'];
                  energy += equipmentStats['energy'];
                });
                // Récupère les données de la collection Inventory liée à la collection Boutique
                final Stream<QuerySnapshot> _inventory =
                    inventoryRef.snapshots();
                return SingleChildScrollView(
                    child: Column(children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(children: [
                        _buildEquipmentWidget('Casque', equipmentsRef),
                        _buildEquipmentWidget('Collier', equipmentsRef),
                        _buildEquipmentWidget('Epaule', equipmentsRef),
                        _buildEquipmentWidget('Cape', equipmentsRef),
                        _buildEquipmentWidget('Torse', equipmentsRef),
                        _buildEquipmentWidget('Chemise', equipmentsRef),
                        _buildEquipmentWidget('Brassard', equipmentsRef),
                        _buildEquipmentWidget('Arme', equipmentsRef),
                      ]),
                      Container(
                        width: MediaQuery.of(context).size.width / 1.5,
                        height: MediaQuery.of(context).size.height / 1.7,
                        color: Colors.black,
                        child: Column(
                          children: [
                            (level < 10)
                                ? Text(
                                    "Disponible à partir du Nv.10"
                                        .toUpperCase(),
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
                                    icon: const Icon(
                                        Icons.stacked_line_chart_rounded),
                                    style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStatePropertyAll(Colors
                                                .indigo
                                                .withOpacity(0.1))),
                                  )
                                : ElevatedButton.icon(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const Text(
                                                  'Choisissez une spécialisation',
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                const SizedBox(height: 10),
                                                Row(
                                                  children: [
                                                    const SizedBox(width: 15),
                                                    GestureDetector(
                                                      onTap: () {
                                                        FirebaseFirestore
                                                            .instance
                                                            .collection('User')
                                                            .doc(personnage.id)
                                                            .update({
                                                          'specialisation':
                                                              'archer'
                                                        });
                                                        FirebaseFirestore
                                                            .instance
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
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height /
                                                            3,
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width /
                                                            3.5,
                                                        color: Colors.black,
                                                        child: Card(
                                                          shadowColor:
                                                              Colors.green,
                                                          elevation: 30,
                                                          color: Colors.green
                                                              .withOpacity(0.5),
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
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
                                                          FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  'User')
                                                              .doc(
                                                                  personnage.id)
                                                              .update({
                                                            'specialisation':
                                                                'sorcier'
                                                          });

                                                          FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  'User')
                                                              .doc(
                                                                  personnage.id)
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
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height /
                                                              3,
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width /
                                                              3.5,
                                                          color: Colors.black,
                                                          child: Card(
                                                            shadowColor:
                                                                Colors.blue,
                                                            elevation: 30,
                                                            color: Colors.blue
                                                                .withOpacity(
                                                                    0.5),
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: const [
                                                                Text("Sorcier"),
                                                                Icon(Icons
                                                                    .ac_unit_rounded)
                                                              ],
                                                            ),
                                                          ),
                                                        )),
                                                    const SizedBox(width: 10),
                                                    GestureDetector(
                                                        onTap: () {
                                                          FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  'User')
                                                              .doc(
                                                                  personnage.id)
                                                              .update({
                                                            'specialisation':
                                                                'guerrier'
                                                          });

                                                          FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  'User')
                                                              .doc(
                                                                  personnage.id)
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
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height /
                                                              3,
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width /
                                                              3.5,
                                                          color: Colors.black,
                                                          child: Card(
                                                            shadowColor:
                                                                Colors.red,
                                                            elevation: 30,
                                                            color: Colors.red
                                                                .withOpacity(
                                                                    0.5),
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: const [
                                                                Text(
                                                                    "Guerrier"),
                                                                Icon(Icons
                                                                    .balcony_sharp)
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
                                    icon: const Icon(
                                        Icons.stacked_line_chart_rounded),
                                    style: const ButtonStyle(
                                      backgroundColor: MaterialStatePropertyAll(
                                          Colors.indigo),
                                    ),
                                  ),
                            const SizedBox(height: 16.0),
                            Column(
                              children: [
                                Text(
                                  'Points restants : $points',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                Row(
                                  children: [
                                    Text("Attaque : ${stats['attaque']}",
                                        style: TextStyle(fontSize: 16)),
                                    ElevatedButton(
                                      style: ButtonStyle(
                                          backgroundColor:
                                              const MaterialStatePropertyAll(
                                                  Colors.transparent),
                                          minimumSize:
                                              MaterialStateProperty.all(
                                                  const Size(5, 5))),
                                      onPressed: () async {
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
                                                "chance": stats['chance'],
                                                'feu': stats['feu'],
                                                'eau': stats['eau'],
                                                'terre': stats['terre'],
                                                'air': stats['air'],
                                                'lumière': stats['lumière'],
                                                'ténébre': stats['ténébre']
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
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "Chance : ${stats['chance']}",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    ElevatedButton(
                                      style: ButtonStyle(
                                          backgroundColor:
                                              const MaterialStatePropertyAll(
                                                  Colors.transparent),
                                          minimumSize:
                                              MaterialStateProperty.all(
                                                  const Size(15, 15))),
                                      onPressed: () async {
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
                                                "chance": stats['chance'],
                                                'feu': stats['feu'],
                                                'eau': stats['eau'],
                                                'terre': stats['terre'],
                                                'air': stats['air'],
                                                'lumière': stats['lumière'],
                                                'ténébre': stats['ténébre']
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
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Column(
                                      children: [
                                        buildStatRow(
                                            Icons.local_fire_department_sharp,
                                            'Feu',
                                            stats['feu'],
                                            Colors.red),
                                        buildStatRow(Icons.water_drop, 'Eau',
                                            stats['eau'], Colors.cyan),
                                        buildStatRow(Icons.landscape, 'Terre',
                                            stats['terre'], Colors.brown),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        buildStatRow(Icons.cloud, 'Air',
                                            stats['air'], Colors.white),
                                        buildStatRow(
                                            Icons.light_mode,
                                            'Lumière',
                                            stats['lumière'],
                                            Colors.yellowAccent),
                                        buildStatRow(
                                            Icons.dark_mode,
                                            'Ténébre',
                                            stats['ténébre'],
                                            Colors.deepPurple),
                                      ],
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(children: [
                        _buildEquipmentWidget('Gants', equipmentsRef),
                        _buildEquipmentWidget('Ceinture', equipmentsRef),
                        _buildEquipmentWidget('Jambière', equipmentsRef),
                        _buildEquipmentWidget('Bottes', equipmentsRef),
                        _buildEquipmentWidget('Bijoux', equipmentsRef),
                        _buildEquipmentWidget('Pet', equipmentsRef),
                        _buildEquipmentWidget('Bouclier', equipmentsRef),
                        _buildEquipmentWidget('Arme2', equipmentsRef),
                      ]),
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
                      if (snapshot.data == null ||
                          snapshot.data!.docs.isEmpty) {
                        return Text('Aucun item trouvé dans l\'inventaire.');
                      }

                      final List<DocumentSnapshot> itemList =
                          snapshot.data!.docs;
                      final List<DocumentSnapshot> stuffList = itemList
                          .where((item) => item['categories'].contains('Stuff'))
                          .toList();
                      final List<DocumentSnapshot> potionList = itemList
                          .where(
                              (item) => item['categories'].contains('Unique'))
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
                                                fit: BoxFit.contain,
                                                width: 40,
                                                height: 55,
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
                                                onPressed: () async {
                                                  if (int.parse(quantity) > 0) {
                                                    final Map<String, dynamic>
                                                        potionData =
                                                        data['stats'] as Map<
                                                            String, dynamic>;
                                                    final int energyPotion =
                                                        data['stats']['energy'];
                                                    final Map<String, dynamic>
                                                        newStats = {
                                                      'feu': stats['feu'] +=
                                                          potionData['feu'],
                                                      'eau': stats['eau'] +=
                                                          potionData['eau'],
                                                      'terre': stats['terre'] +=
                                                          potionData['terre'],
                                                      'air': stats['air'] +=
                                                          potionData['air'],
                                                      'lumière': stats[
                                                              'lumière'] +=
                                                          potionData['lumière'],
                                                      'ténébre': stats[
                                                              'ténébre'] +=
                                                          potionData['ténébre'],
                                                      'attaque': stats[
                                                              'attaque'] +=
                                                          potionData['attaque'],
                                                      'chance': stats[
                                                              'chance'] +=
                                                          potionData['chance']
                                                    };
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection('User')
                                                        .doc(personnage.id)
                                                        .update({
                                                      'stats': newStats,
                                                      'energy':
                                                          energy + energyPotion
                                                    });
                                                    final int newQuantity =
                                                        int.parse(quantity) - 1;
                                                    if (newQuantity == 0) {
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection('User')
                                                          .doc(personnage.id)
                                                          .collection(
                                                              'Inventory')
                                                          .doc(document.id)
                                                          .delete();
                                                    } else {
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection('User')
                                                          .doc(personnage.id)
                                                          .collection(
                                                              'Inventory')
                                                          .doc(document.id)
                                                          .update({
                                                        'quantity': newQuantity
                                                      });
                                                    }
                                                  }
                                                },
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
                                                fit: BoxFit.contain,
                                                width: 40,
                                                height: 55,
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
                                                onPressed: () async {
                                                  bool hasEquippedItem = false;
                                                  QuerySnapshot
                                                      equipmentSnapshot =
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection('User')
                                                          .doc(personnage.id)
                                                          .collection(
                                                              'Equipements')
                                                          .where('types',
                                                              isEqualTo:
                                                                  data['types'])
                                                          .get();
                                                  if (equipmentSnapshot
                                                      .docs.isNotEmpty) {
                                                    hasEquippedItem = true;
                                                  }

                                                  // Si l'utilisateur a déjà équipé un objet du même type, remplacez simplement ses données
                                                  if (hasEquippedItem) {
                                                    CollectionReference
                                                        equipmentCollection =
                                                        FirebaseFirestore
                                                            .instance
                                                            .collection('User')
                                                            .doc(personnage.id)
                                                            .collection(
                                                                'Equipements');
                                                    QuerySnapshot
                                                        equippedSnapshot =
                                                        await equipmentCollection
                                                            .where('types',
                                                                isEqualTo: data[
                                                                    'types'])
                                                            .get();
                                                    if (equippedSnapshot
                                                        .docs.isNotEmpty) {
                                                      DocumentSnapshot
                                                          equippedItem =
                                                          equippedSnapshot
                                                              .docs.first;
                                                      String equippedItemId =
                                                          equippedItem.id;
                                                      await equipmentCollection
                                                          .doc(equippedItemId)
                                                          .delete();

                                                      CollectionReference
                                                          inventoryCollection =
                                                          FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  'User')
                                                              .doc(
                                                                  personnage.id)
                                                              .collection(
                                                                  'Inventory');
                                                      await inventoryCollection
                                                          .doc(stuffList[index]
                                                              .id)
                                                          .delete();
                                                      await inventoryCollection
                                                          .doc(equippedItemId)
                                                          .set(equippedItem
                                                              .data());
                                                    }
                                                    await equipmentCollection
                                                        .doc(
                                                            stuffList[index].id)
                                                        .set(data);
                                                  }
// Sinon, créez une nouvelle entrée dans la collection "Equipements"
                                                  else {
                                                    CollectionReference
                                                        equipmentCollection =
                                                        FirebaseFirestore
                                                            .instance
                                                            .collection('User')
                                                            .doc(personnage.id)
                                                            .collection(
                                                                'Equipements');
                                                    await equipmentCollection
                                                        .doc(
                                                            stuffList[index].id)
                                                        .set(data);

                                                    CollectionReference
                                                        inventoryCollection =
                                                        FirebaseFirestore
                                                            .instance
                                                            .collection('User')
                                                            .doc(personnage.id)
                                                            .collection(
                                                                'Inventory');
                                                    await inventoryCollection
                                                        .doc(
                                                            stuffList[index].id)
                                                        .delete();
                                                  }
                                                },
                                                child: const Text(
                                                  "Equiper",
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
                ]));
              });
        });
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

  Widget _buildEquipmentWidget(String equipmentType, equipmentsRef) {
    return StreamBuilder<QuerySnapshot>(
      stream: equipmentsRef
          .where('types', isEqualTo: equipmentType)
          .limit(1)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Une erreur est survenue : ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final List<DocumentSnapshot> equipmentList = snapshot.data!.docs;
        if (equipmentList.isEmpty) {
          return Container(
            width: 50,
            height: 50,
            margin: EdgeInsets.all(7),
            color: Colors.black,
          );
        } else {
          return Container(
            width: 50,
            height: 50,
            margin: EdgeInsets.all(7),
            color: Colors.black,
            child: Image.network(equipmentList[0]['poster']),
          );
        }
      },
    );
  }
}
