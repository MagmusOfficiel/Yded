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
            return const Text('Aucun personnage trouvé pour cet utilisateur.');
          }

          // Récupère le premier document du QuerySnapshot
          final personnage = snapshot.data!.docs.first;
          // Récupère la propriété "level" du personnage
          var money = personnage.get('money');
          var stats = personnage.get('stats');
          var level = personnage.get('level');
          var energy = personnage.get('energy');
          final specialisation = personnage.get('specialisation');
          // Récupère la référence de la collection Boutique dans le document de l'utilisateur
          var inventoryRef = personnage.reference.collection('Inventory');
          var equipmentsRef = personnage.reference.collection('Equipements');
          // Récupère les données de la collection Inventory liée à la collection Boutique
          final Stream<QuerySnapshot> _inventory = inventoryRef.snapshots();
          return Stack(children: [
            SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Image.asset(
                "assets/images/forge.png",
                fit: BoxFit.cover,
              ),
            ),
            SingleChildScrollView(
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
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.brown,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        (level < 10)
                            ? Text(
                                "Disponible à partir du Nv.10".toUpperCase(),
                                style: const TextStyle(),
                              )
                            : (specialisation == "aventurier")
                                ? Text(
                                    "Disponible".toUpperCase(),
                                    style: const TextStyle(),
                                  )
                                : const SizedBox(),
                        (level < 10)
                            ? ElevatedButton.icon(
                                onPressed: () {},
                                label: const Text("SPÉCIALISATION"),
                                icon: const Icon(
                                    Icons.stacked_line_chart_rounded),
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
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
                                                  onTap: () async {
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection('User')
                                                        .doc(personnage.id)
                                                        .update({
                                                      'specialisation': 'archer'
                                                    });
                                                  },
                                                  child: Container(
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height /
                                                            3,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            3.5,
                                                    color: Colors.black,
                                                    child: Card(
                                                      shadowColor: Colors.green,
                                                      elevation: 30,
                                                      color: Colors.green
                                                          .withOpacity(0.5),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          const Text("Archer"),
                                                          const SizedBox(
                                                              height: 8),
                                                          Image.asset(
                                                            'assets/images/archer.png',
                                                            fit: BoxFit.contain,
                                                            width: 50,
                                                            height: 50,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                GestureDetector(
                                                  onTap: () async {
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection('User')
                                                        .doc(personnage.id)
                                                        .update({
                                                      'specialisation':
                                                          'sorcier'
                                                    });
                                                  },
                                                  child: Container(
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height /
                                                            3,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            3.5,
                                                    color: Colors.black,
                                                    child: Card(
                                                      shadowColor: Colors.blue,
                                                      elevation: 30,
                                                      color: Colors.blue
                                                          .withOpacity(0.5),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          const Text("Sorcier"),
                                                          const SizedBox(
                                                              height: 8),
                                                          Image.asset(
                                                            'assets/images/sorcier.png',
                                                            fit: BoxFit.contain,
                                                            width: 50,
                                                            height: 50,
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                GestureDetector(
                                                  onTap: () async {
                                                    final userDoc =
                                                        FirebaseFirestore
                                                            .instance
                                                            .collection('User')
                                                            .doc(personnage.id);
                                                    await userDoc.update({
                                                      'specialisation':
                                                          'guerrier'
                                                    });
                                                  },
                                                  child: Container(
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height /
                                                            3,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            3.5,
                                                    color: Colors.black,
                                                    child: Card(
                                                      shadowColor: Colors.red,
                                                      elevation: 30,
                                                      color: Colors.red
                                                          .withOpacity(0.5),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          const Text(
                                                              "Guerrier"),
                                                          const SizedBox(
                                                              height: 8),
                                                          Image.asset(
                                                            'assets/images/$specialisation.png',
                                                            fit: BoxFit.contain,
                                                            width: 50,
                                                            height: 50,
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ]);
                                    },
                                  );
                                },
                                label: const Text("SPÉCIALISATION"),
                                icon: const Icon(
                                    Icons.stacked_line_chart_rounded),
                                style: const ButtonStyle(
                                  backgroundColor:
                                      MaterialStatePropertyAll(Colors.indigo),
                                ),
                              ),
                        (level < 10)
                            ? ElevatedButton.icon(
                                onPressed: () {},
                                label: const Text("SPÉCIALISATION"),
                                icon: const Icon(
                                    Icons.stacked_line_chart_rounded),
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const SizedBox(width: 10),
                                            const Text(
                                              'Choisissez votre élément',
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            SizedBox(
                                                height:
                                                    300, // ou toute autre valeur appropriée
                                                child: GridView.count(
                                                  primary: false,
                                                  padding:
                                                      const EdgeInsets.all(20),
                                                  crossAxisSpacing: 10,
                                                  mainAxisSpacing: 10,
                                                  crossAxisCount: 3,
                                                  children: <Widget>[
                                                    buildElementCard(
                                                        'feu', specialisation),
                                                    buildElementCard(
                                                        'eau', specialisation),
                                                    buildElementCard('terre',
                                                        specialisation),
                                                    buildElementCard(
                                                        'air', specialisation),
                                                    buildElementCard('ténébre',
                                                        specialisation),
                                                    buildElementCard('lumière',
                                                        specialisation),
                                                  ],
                                                ))
                                          ]);
                                    },
                                  );
                                },
                                label: const Text(
                                  "ELEMENTS",
                                  style: TextStyle(color: Colors.black),
                                ),
                                icon: const Icon(Icons.accessibility_rounded,
                                    color: Colors.black),
                                style: const ButtonStyle(
                                  backgroundColor:
                                      MaterialStatePropertyAll(Colors.yellow),
                                ),
                              ),
                        const SizedBox(height: 16.0),
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Column(
                                  children: [
                                    buildStatRow(
                                        Icons.add_circle_outline,
                                        'Attaque',
                                        stats['attaque'],
                                        Colors.grey),
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
                                    buildStatRow(Icons.stars_outlined, 'Chance',
                                        stats['chance'], Colors.white),
                                    buildStatRow(Icons.cloud, 'Air',
                                        stats['air'], Colors.white),
                                    buildStatRow(Icons.light_mode, 'Lumière',
                                        stats['lumière'], Colors.yellowAccent),
                                    buildStatRow(Icons.dark_mode, 'Ténébre',
                                        stats['ténébre'], Colors.deepPurple),
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
                    return Text('Une erreur est survenue : ${snapshot.error}');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final List<QueryDocumentSnapshot> itemList =
                      snapshot.data!.docs;
                  final stuffList = itemList
                      .where((item) => item['categories'].contains('Stuff'))
                      .toList();
                  final potionList = itemList
                      .where((item) => item['categories'].contains('Unique'))
                      .toList();

                  return Column(children: [
                    if (potionList.isNotEmpty)
                      Column(children: [
                        const Text("Utilisable"),
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
                              final document = potionList[index];
                              final data =
                                  document.data()! as Map<String, dynamic>;
                              final quantity = data['quantity'].toString();
                              final potionData =
                                  data['stats'] as Map<String, dynamic>;
                              final energyPotion = data['stats']['energy'];
                              final newStats = {
                                'feu': stats['feu'] + potionData['feu'],
                                'eau': stats['eau'] + potionData['eau'],
                                'terre': stats['terre'] + potionData['terre'],
                                'air': stats['air'] + potionData['air'],
                                'energy': stats['energy'],
                                'lumière':
                                    stats['lumière'] + potionData['lumière'],
                                'ténébre':
                                    stats['ténébre'] + potionData['ténébre'],
                                'attaque':
                                    stats['attaque'] + potionData['attaque'],
                                'chance': stats['chance'] + potionData['chance']
                              };

                              return SizedBox(
                                width: double.infinity,
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
                                        '${data['name']} x$quantity',
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
                                          minimumSize:
                                              MaterialStateProperty.all(
                                                  const Size(120, 15)),
                                        ),
                                        onPressed: () async {
                                          if (int.parse(quantity) > 0) {
                                            await FirebaseFirestore.instance
                                                .collection('User')
                                                .doc(personnage.id)
                                                .update({
                                              'stats': newStats,
                                              'energy': energy + energyPotion
                                            });

                                            final newQuantity =
                                                int.parse(quantity) - 1;
                                            if (newQuantity == 0) {
                                              await FirebaseFirestore.instance
                                                  .collection('User')
                                                  .doc(personnage.id)
                                                  .collection('Inventory')
                                                  .doc(document.id)
                                                  .delete();
                                            } else {
                                              await FirebaseFirestore.instance
                                                  .collection('User')
                                                  .doc(personnage.id)
                                                  .collection('Inventory')
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
                      ]),
                    if (potionList.isEmpty)
                      const Text("Aucun utilisable trouvé dans l'inventaire."),
                    (stuffList.isNotEmpty)
                        ? Column(children: [
                            const Text("Equipements"),
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
                                itemCount: stuffList.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final DocumentSnapshot document =
                                      stuffList[index];
                                  final Map<String, dynamic> data =
                                      document.data()! as Map<String, dynamic>;
                                  final String quantity =
                                      data['quantity'].toString();
                                  return GestureDetector(
                                      onTap: () {
                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                elevation: 5,
                                                backgroundColor: Colors.black,
                                                title: Text(data['name']),
                                                content: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Image.network(
                                                      data['poster'],
                                                      fit: BoxFit.cover,
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height /
                                                              4,
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceEvenly,
                                                      mainAxisSize:
                                                          MainAxisSize.max,
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
                                                                data['stats']
                                                                    ['energy'],
                                                                Colors.indigo),
                                                            buildStatRow(
                                                                Icons
                                                                    .local_fire_department_sharp,
                                                                'Feu',
                                                                data['stats']
                                                                    ['feu'],
                                                                Colors.red),
                                                            buildStatRow(
                                                                Icons
                                                                    .water_drop,
                                                                'Eau',
                                                                data['stats']
                                                                    ['eau'],
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
                                                                Icons
                                                                    .stars_outlined,
                                                                'Chance',
                                                                data['stats']
                                                                    ['chance'],
                                                                Colors.white),
                                                            buildStatRow(
                                                                Icons.cloud,
                                                                'Air',
                                                                data['stats']
                                                                    ['air'],
                                                                Colors.white),
                                                            buildStatRow(
                                                                Icons
                                                                    .light_mode,
                                                                'Lumière',
                                                                data['stats']
                                                                    ['lumière'],
                                                                Colors
                                                                    .yellowAccent),
                                                            buildStatRow(
                                                                Icons.dark_mode,
                                                                'Ténébre',
                                                                data['stats']
                                                                    ['ténébre'],
                                                                Colors
                                                                    .deepPurple),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () async {
                                                        await FirebaseFirestore
                                                            .instance
                                                            .collection('User')
                                                            .doc(personnage.id)
                                                            .collection(
                                                                'Inventory')
                                                            .doc(document.id)
                                                            .delete();
                                                        await FirebaseFirestore
                                                            .instance
                                                            .collection("User")
                                                            .doc(personnage.id)
                                                            .update({
                                                          'money': money +
                                                              data['cout'] / 2
                                                        });
                                                        Navigator.pop(context);
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                                const SnackBar(
                                                          backgroundColor:
                                                              Colors.green,
                                                          content: Text(
                                                              'Vente réussis'),
                                                          duration: Duration(
                                                              seconds: 2),
                                                        ));
                                                      },
                                                      style: const ButtonStyle(
                                                          backgroundColor:
                                                              MaterialStatePropertyAll(
                                                                  Colors
                                                                      .indigo)),
                                                      child: Text(
                                                          "Vendre ${(data['cout'] / 2).toStringAsFixed(0)} or"),
                                                    )
                                                  ],
                                                ),
                                              );
                                            });
                                      },
                                      child: SizedBox(
                                        width: double.infinity,
                                        child: Card(
                                          color: Colors.brown.shade900
                                              .withOpacity(0.5),
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
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 7.0),
                                              Expanded(
                                                  child: ElevatedButton(
                                                style: ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStateProperty.all(
                                                          Colors
                                                              .brown.shade900),
                                                  minimumSize:
                                                      MaterialStateProperty.all(
                                                          const Size(120, 30)),
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

                                                  // Obtenir les statistiques actuelles de l'utilisateur
                                                  DocumentSnapshot userDoc =
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection('User')
                                                          .doc(personnage.id)
                                                          .get();
                                                  Map<String, dynamic>
                                                      userStats =
                                                      userDoc['stats'];

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

                                                      // Retirer les statistiques de l'ancien équipement
                                                      equippedItem['stats']
                                                          .forEach(
                                                              (key, value) {
                                                        userStats[key] =
                                                            userStats[key] -
                                                                value;
                                                      });

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

                                                    // Ajouter les statistiques du nouvel équipement
                                                    data['stats']
                                                        .forEach((key, value) {
                                                      userStats[key] =
                                                          userStats[key] +
                                                              value;
                                                    });

                                                    await equipmentCollection
                                                        .doc(
                                                            stuffList[index].id)
                                                        .set(data);
                                                  } else {
                                                    // Ajouter les statistiques de l'équipement nouvellement équipé
                                                    data['stats']
                                                        .forEach((key, value) {
                                                      userStats[key] =
                                                          userStats[key] +
                                                              value;
                                                    });

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

                                                  // Mettre à jour les statistiques de l'utilisateur dans la base de données
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection('User')
                                                      .doc(personnage.id)
                                                      .update(
                                                          {'stats': userStats});
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
                                      ));
                                })
                          ])
                        : const SizedBox()
                  ]);
                },
              ),
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
            margin: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.brown,
                width: 2,
              ),
            ),
          );
        } else {
          return GestureDetector(
              onTap: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        elevation: 5,
                        backgroundColor: Colors.black,
                        title: Text(equipmentList[0]['name']),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.network(
                              equipmentList[0]['poster'],
                              fit: BoxFit.cover,
                              height: MediaQuery.of(context).size.height / 4,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Column(
                                  children: [
                                    buildStatRow(
                                        Icons.add_circle_outline,
                                        'Attaque',
                                        equipmentList[0]['stats']['attaque'],
                                        Colors.grey),
                                    buildStatRow(
                                        Icons.flash_on,
                                        'Energy',
                                        equipmentList[0]['stats']['energy'],
                                        Colors.indigo),
                                    buildStatRow(
                                        Icons.local_fire_department_sharp,
                                        'Feu',
                                        equipmentList[0]['stats']['feu'],
                                        Colors.red),
                                    buildStatRow(
                                        Icons.water_drop,
                                        'Eau',
                                        equipmentList[0]['stats']['eau'],
                                        Colors.cyan),
                                    buildStatRow(
                                        Icons.landscape,
                                        'Terre',
                                        equipmentList[0]['stats']['terre'],
                                        Colors.brown),
                                  ],
                                ),
                                Column(
                                  children: [
                                    buildStatRow(
                                        Icons.stars_outlined,
                                        'Chance',
                                        equipmentList[0]['stats']['chance'],
                                        Colors.white),
                                    buildStatRow(
                                        Icons.cloud,
                                        'Air',
                                        equipmentList[0]['stats']['air'],
                                        Colors.white),
                                    buildStatRow(
                                        Icons.light_mode,
                                        'Lumière',
                                        equipmentList[0]['stats']['lumière'],
                                        Colors.yellowAccent),
                                    buildStatRow(
                                        Icons.dark_mode,
                                        'Ténébre',
                                        equipmentList[0]['stats']['ténébre'],
                                        Colors.deepPurple),
                                  ],
                                ),
                              ],
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                DocumentSnapshot userDoc =
                                    await FirebaseFirestore.instance
                                        .collection('User')
                                        .doc(_user.uid)
                                        .get();
                                Map<String, dynamic> userStats =
                                    userDoc['stats'];

                                final document = equipmentList[0];
                                final data =
                                    document.data()! as Map<String, dynamic>;
                                // Soustraire les statistiques de l'équipement nouvellement équipé
                                equipmentList[0]['stats'].forEach((key, value) {
                                  userStats[key] = userStats[key] - value;
                                });

                                CollectionReference inventoryCollection =
                                    FirebaseFirestore.instance
                                        .collection('User')
                                        .doc(_user.uid)
                                        .collection('Inventory');
                                await inventoryCollection
                                    .doc(equipmentList[0].id)
                                    .set(data);

                                CollectionReference equipmentCollection =
                                    FirebaseFirestore.instance
                                        .collection('User')
                                        .doc(_user.uid)
                                        .collection('Equipements');
                                await equipmentCollection
                                    .doc(equipmentList[0].id)
                                    .delete();

                                // Mettre à jour les statistiques de l'utilisateur dans la base de données
                                await FirebaseFirestore.instance
                                    .collection('User')
                                    .doc(_user.uid)
                                    .update({'stats': userStats});
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  backgroundColor: Colors.green,
                                  content: Text('Déséquiper'),
                                  duration: Duration(seconds: 2),
                                ));
                              },
                              style: const ButtonStyle(
                                  backgroundColor:
                                      MaterialStatePropertyAll(Colors.indigo)),
                              child: const Text("Déséquipper"),
                            )
                          ],
                        ),
                      );
                    });
              },
              child: Container(
                width: 50,
                height: 50,
                margin: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.brown,
                    width: 2,
                  ),
                ),
                child: Image.network(equipmentList[0]['poster']),
              ));
        }
      },
    );
  }

  GestureDetector buildElementCard(String element, String specialisation) {
    return GestureDetector(
      onTap: () async {
        final userDoc =
            FirebaseFirestore.instance.collection('User').doc(_user.uid);
        final idSort = userDoc.collection('Sorts');

        final querySnapshot = await idSort.get();
        String nomSort;

        if (querySnapshot.docs.isNotEmpty) {
          // Si la collection "Sorts" existe déjà, mettre à jour les données du premier document
          switch (specialisation) {
            case "guerrier":
              nomSort = "Coup";
              break;
            case "sorcier":
              nomSort = "Boule";
              break;
            case "archer":
              nomSort = "Flèche";
              break;
            default:
              nomSort = "Sort";
              break;
          }
          switch (element) {
            case "feu":
              nomSort += " de flamme";
              break;
            case "terre":
              nomSort += " de roche";
              break;
            case "air":
              nomSort += " de vent";
              break;
            case "eau":
              nomSort += " d'eau glacée";
              break;
            case "lumière":
              nomSort += " de lumière";
              break;
            case "ténébre":
              nomSort += " sombre";
              break;
            default:
              nomSort += " de magie";
              break;
          }
          await querySnapshot.docs.first.reference.update({
            'nom': nomSort,
            'degats': 10,
            'element': element
          });
        } else {
          // Si la collection "Sorts" n'existe pas encore, ajouter un nouveau document avec ces données
          switch (specialisation) {
            case "guerrier":
              nomSort = "Coup";
              break;
            case "sorcier":
              nomSort = "Boule";
              break;
            case "archer":
              nomSort = "Flèche";
              break;
            default:
              nomSort = "Sort";
              break;
          }
          switch (element) {
            case "feu":
              nomSort += " de flamme";
              break;
            case "terre":
              nomSort += " de roche";
              break;
            case "air":
              nomSort += " de vent";
              break;
            case "eau":
              nomSort += " d'eau glacée";
              break;
            case "lumière":
              nomSort += " de lumière";
              break;
            case "ténébre":
              nomSort += " sombre";
              break;
            default:
              nomSort += " de magie";
              break;
          }
          await idSort.add({'nom': nomSort, 'degats': 10, 'element': element});
        }

        // Mettre à jour les statistiques de l'utilisateur dans la base de données
        await userDoc.update({'element': element});
      },
      child: Card(
          color: element == 'feu'
              ? Colors.red.shade900
              : element == 'eau'
                  ? Colors.blue.shade900
                  : element == 'terre'
                      ? Colors.brown.shade900
                      : element == 'air'
                          ? Colors.grey
                          : element == 'ténébre'
                              ? Colors.purple.shade900
                              : element == 'lumière'
                                  ? Colors.yellow.shade900
                                  : Colors.grey.shade900,
          child: Center(
              child: Text(
            element.substring(0, 1).toUpperCase() + element.substring(1),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ))),
    );
  }
}
