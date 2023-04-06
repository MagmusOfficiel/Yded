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
  late FirebaseAuth _auth;
  late User? user;
  late String userId;
  late Map<String, dynamic> userData = {};
  late String userRole = '';

  @override
  void initState() {
    super.initState();
    _auth = FirebaseAuth.instance;
    user = _auth.currentUser;
    userId = user?.uid ?? '';
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

  Future<void> addToInventory(String itemName) async {
    final userRef = FirebaseFirestore.instance.collection('User').doc(userId);
    final inventoryRef = userRef.collection('Inventory');
    final itemDoc = await inventoryRef.doc(itemName).get();

    final batch = FirebaseFirestore.instance.batch();

    if (itemDoc.exists) {
      final itemData = itemDoc.data()!;
      final quantity = itemData['quantity'] + 1;
      batch.update(
        inventoryRef.doc(itemName),
        {...itemData, 'quantity': quantity},
      );
    } else {
      final itemSnapshot = await FirebaseFirestore.instance
          .collection('Boutique')
          .doc(itemName)
          .get();
      final itemData = itemSnapshot.data()!;
      batch.set(
        inventoryRef.doc(itemName),
        {...itemData, 'quantity': 1},
      );
    }

    await batch.commit();
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
            return const Text('Chargement da la boutique...');
          }

          final List<DocumentSnapshot> itemList = snapshot.data!.docs;
          final List<DocumentSnapshot> stuffList = itemList
              .where((item) => item['categories'].contains('Stuff'))
              .toList();
          final List<DocumentSnapshot> potionList = itemList
              .where((item) => item['categories'].contains('Unique'))
              .toList();
          return Stack(children: [
            SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Image.asset(
                "assets/images/boutique.png",
                fit: BoxFit.cover,
              ),
            ),
            SingleChildScrollView(
                child: Column(children: [
              (potionList.isNotEmpty)
                  ? Column(children: [
                      const SizedBox(height: 8),
                      const Text("Utilisable",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.white)),
                      const SizedBox(height: 8),
                      GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 15.0,
                            crossAxisSpacing: 15.0,
                            childAspectRatio: 1.0,
                          ),
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: potionList.length,
                          itemBuilder: (BuildContext context, int index) {
                            final DocumentSnapshot document = potionList[index];
                            final Map<String, dynamic> data =
                                document.data()! as Map<String, dynamic>;
                            final int cout = data['cout'] as int;
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
                                              fit: BoxFit.contain,
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Column(
                                                  children: [
                                                    buildStatRow(
                                                        Icons
                                                            .add_circle_outline,
                                                        'Attaque',
                                                        data['stats']
                                                            ['attaque'],
                                                        Colors.grey),
                                                    buildStatRow(
                                                        Icons.flash_on,
                                                        'Energy',
                                                        data['stats']['energy'],
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
                                                        data['stats']['terre'],
                                                        Colors.brown),
                                                  ],
                                                ),
                                                Column(
                                                  children: [
                                                    buildStatRow(
                                                        Icons.stars_outlined,
                                                        'Chance',
                                                        data['stats']['chance'],
                                                        Colors.white),
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
                                color: Colors.brown.shade900.withOpacity(0.5),
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
                                                Colors.brown.shade900),
                                        minimumSize: MaterialStateProperty.all(
                                            const Size(120, 15)),
                                      ),
                                      onPressed: () async {
                                        if (userData['money'] >= cout) {
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
                                              .doc(user?.uid)
                                              .update({
                                            'money': userData['money'] - cout,
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
                  : const SizedBox(),
              (stuffList.isNotEmpty)
                  ? Column(children: [
                (userRole == 'admin')
                    ? ElevatedButton(
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
                    child: const Icon(Icons.add, color: Colors.black))
                    : const SizedBox(),
                      const SizedBox(height: 8),
                      const Text(
                        "Equipements",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 5.0,
                            crossAxisSpacing: 5.0,
                            childAspectRatio: 1.0,
                          ),
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: stuffList.length,
                          itemBuilder: (BuildContext context, int index) {
                            final DocumentSnapshot document = stuffList[index];
                            final Map<String, dynamic> data =
                                document.data()! as Map<String, dynamic>;
                            final int cout = data['cout'] as int;
                            return InkWell(
                              onTap: () {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        actions: [
                                          (userRole == 'admin')
                                              ? ElevatedButton(
                                                  onPressed: () {
                                                    FirebaseFirestore.instance
                                                        .collection('Boutique')
                                                        .doc(document.id)
                                                        .delete();
                                                    Navigator.pop(context);
                                                  },
                                                  child:
                                                      const Text('Supprimer'))
                                              : const SizedBox()
                                        ],
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
                                                  4.4,
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Column(
                                                  children: [
                                                    buildStatRow(
                                                        Icons
                                                            .add_circle_outline,
                                                        'Attaque',
                                                        data['stats']
                                                            ['attaque'],
                                                        Colors.grey),
                                                    buildStatRow(
                                                        Icons.flash_on,
                                                        'Energy',
                                                        data['stats']['energy'],
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
                                                        data['stats']['terre'],
                                                        Colors.brown),
                                                  ],
                                                ),
                                                Column(
                                                  children: [
                                                    buildStatRow(
                                                        Icons.stars_outlined,
                                                        'Chance',
                                                        data['stats']['chance'],
                                                        Colors.white),
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
                                color: Colors.brown.shade900.withOpacity(0.5),
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
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 7.0),
                                    Expanded(
                                        child: ElevatedButton(
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                Colors.brown.shade900),
                                        minimumSize: MaterialStateProperty.all(
                                            const Size(120, 15)),
                                      ),
                                      onPressed: () async {
                                        if (userData['money'] >= cout) {
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
                                              .doc(user?.uid)
                                              .update({
                                            'money': userData['money'] - cout,
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
                          }),
                    ])
                  : const SizedBox()
            ]))
          ]);
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
