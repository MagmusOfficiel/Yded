import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'add_items.dart';

class Boutique extends StatefulWidget {
  const Boutique({Key? key}) : super(key: key);

  @override
  _BoutiqueState createState() => _BoutiqueState();
}

class _BoutiqueState extends State<Boutique> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final User? user = FirebaseAuth.instance.currentUser;
  late String userRole = '';
  late String? userId = '';
  late int userMoney;
  late Map<String, dynamic> userData = {};

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    final docRef = FirebaseFirestore.instance.collection('User').doc(user?.uid);
    final docSnapshot = await docRef.get();
    userData = docSnapshot.data() ?? {};
    setState(() {
      userRole = userData['role'] ?? '';
      userMoney = userData['money'] ?? 0;
    });
    userId = user?.uid;
  }

  Future<void> addToInventory(String itemName) async {
    final userRef = FirebaseFirestore.instance.collection('User').doc(userId);
    final inventoryRef = userRef.collection('Inventory');
    final itemDoc = await inventoryRef.doc(itemName).get();

    if (itemDoc.exists) {
      // L'article existe déjà dans l'inventaire, mettre à jour sa quantité
      final itemData = itemDoc.data()!;
      final quantity = itemData['quantity'] + 1;
      await inventoryRef
          .doc(itemName)
          .update({...itemData, 'quantity': quantity});
    } else {
      // L'article n'existe pas encore dans l'inventaire, ajouter un nouveau document
      final itemSnapshot = await FirebaseFirestore.instance
          .collection('Boutique')
          .doc(itemName)
          .get();
      final itemData = itemSnapshot.data()!;
      await inventoryRef.doc(itemName).set({...itemData, 'quantity': 1});
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Boutique')
            .orderBy('cout', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Erreur: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text('Chargement da la boutique...');
          }

          final List<DocumentSnapshot> itemList = snapshot.data!.docs;
          final List<DocumentSnapshot> stuffList = itemList
              .where((item) => item['categories'].contains('Stuff'))
              .toList();
          final List<DocumentSnapshot> potionList = itemList
              .where((item) => item['categories'].contains('Unique'))
              .toList();
          return Scaffold(
              body: Column(children: [
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
                            itemBuilder: (BuildContext context, int index) {
                              final DocumentSnapshot document =
                                  potionList[index];
                              final Map<String, dynamic> data =
                                  document.data()! as Map<String, dynamic>;
                              var cout = data['cout'];
                              return InkWell(
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          elevation: 5,
                                          backgroundColor: Colors.black,
                                          title: Text(data['name']),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Image.network(data['poster']),
                                              SizedBox(height: 8),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  Column(
                                                    children: [
                                                      buildStatRow(
                                                          Icons.flash_on,
                                                          'Energy',
                                                          data['stats']
                                                              ['energy'],
                                                          Colors.indigo),
                                                      buildStatRow(
                                                          Icons
                                                              .local_fire_department_sharp,
                                                          'Feu',
                                                          data['stats']['feu'],
                                                          Colors.red),
                                                      buildStatRow(
                                                          Icons.water_drop,
                                                          'Eau',
                                                          data['stats']['eau'],
                                                          Colors.cyan),
                                                      buildStatRow(
                                                          Icons.landscape,
                                                          'Terre',
                                                          data['stats']
                                                              ['terre'],
                                                          Colors.brown),
                                                    ],
                                                  ),
                                                  Column(
                                                    children: [
                                                      buildStatRow(
                                                          Icons.cloud,
                                                          'Air',
                                                          data['stats']['air'],
                                                          Colors.white),
                                                      buildStatRow(
                                                          Icons.light_mode,
                                                          'Lumière',
                                                          data['stats']
                                                              ['lumière'],
                                                          Colors.yellowAccent),
                                                      buildStatRow(
                                                          Icons.dark_mode,
                                                          'Ténébre',
                                                          data['stats']
                                                              ['ténébre'],
                                                          Colors.deepPurple),
                                                    ],
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        );
                                      });
                                },
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
                                        data['name'],
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
                                          if (userMoney >= cout) {
                                            // Afficher un spinner pendant le traitement de la commande
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return const Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                );
                                              },
                                            );

                                            // Effectuer l'achat
                                            await addToInventory(
                                                potionList[index].id);
                                            await FirebaseFirestore.instance
                                                .collection('User')
                                                .doc(userId!)
                                                .update({
                                              'money': userMoney - cout,
                                            });
                                            await getData();

                                            // Fermer la boîte de dialogue et afficher un SnackBar pour informer l'utilisateur que l'achat a été effectué avec succès
                                            Navigator.pop(context);
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                backgroundColor: Colors.green,
                                                content: Text(
                                                    'Achat effectué avec succès'),
                                                duration: Duration(seconds: 2),
                                              ),
                                            );
                                          }
                                        },
                                        child: Text(
                                          "${cout.toString()} or",
                                          style: const TextStyle(
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
                            itemBuilder: (BuildContext context, int index) {
                              final DocumentSnapshot document =
                                  stuffList[index];
                              final Map<String, dynamic> data =
                                  document.data()! as Map<String, dynamic>;
                              var cout = data['cout'];
                              return InkWell(
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          elevation: 5,
                                          backgroundColor: Colors.black,
                                          title: Text(data['name']),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Image.network(
                                                data['poster'],
                                                fit: BoxFit.cover,
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height /
                                                    4,
                                              ),
                                              SizedBox(height: 8),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  Column(
                                                    children: [
                                                      buildStatRow(
                                                          Icons.flash_on,
                                                          'Energy',
                                                          data['stats']
                                                              ['energy'],
                                                          Colors.indigo),
                                                      buildStatRow(
                                                          Icons
                                                              .local_fire_department_sharp,
                                                          'Feu',
                                                          data['stats']['feu'],
                                                          Colors.red),
                                                      buildStatRow(
                                                          Icons.water_drop,
                                                          'Eau',
                                                          data['stats']['eau'],
                                                          Colors.cyan),
                                                      buildStatRow(
                                                          Icons.landscape,
                                                          'Terre',
                                                          data['stats']
                                                              ['terre'],
                                                          Colors.brown),
                                                    ],
                                                  ),
                                                  Column(
                                                    children: [
                                                      buildStatRow(
                                                          Icons.cloud,
                                                          'Air',
                                                          data['stats']['air'],
                                                          Colors.white),
                                                      buildStatRow(
                                                          Icons.light_mode,
                                                          'Lumière',
                                                          data['stats']
                                                              ['lumière'],
                                                          Colors.yellowAccent),
                                                      buildStatRow(
                                                          Icons.dark_mode,
                                                          'Ténébre',
                                                          data['stats']
                                                              ['ténébre'],
                                                          Colors.deepPurple),
                                                    ],
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        );
                                      });
                                },
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
                                        data['name'],
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
                                          if (userMoney >= cout) {
                                            // Afficher un spinner pendant le traitement de la commande
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return const Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                );
                                              },
                                            );
                                            await addToInventory(
                                                stuffList[index].id);
                                            await FirebaseFirestore.instance
                                                .collection('User')
                                                .doc(userId!)
                                                .update({
                                              'money': userMoney - cout,
                                            });
                                            await getData();
                                            // Fermer la boîte de dialogue et afficher un SnackBar pour informer l'utilisateur que l'achat a été effectué avec succès
                                            Navigator.pop(context);
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                backgroundColor: Colors.green,
                                                content: Text(
                                                    'Achat effectué avec succès'),
                                                duration: Duration(seconds: 2),
                                              ),
                                            );
                                          }
                                        },
                                        child: Text(
                                          "${cout.toString()} or",
                                          style: const TextStyle(
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
              ]),
              floatingActionButton: (userRole == "admin")
                  ? Center(
                      child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (BuildContext context) {
                                  return AddItem();
                                },
                                fullscreenDialog: true));
                          },
                          style: const ButtonStyle(
                              backgroundColor:
                                  MaterialStatePropertyAll(Colors.white)),
                          child: const Icon(Icons.add, color: Colors.black)))
                  : const SizedBox());
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
}
