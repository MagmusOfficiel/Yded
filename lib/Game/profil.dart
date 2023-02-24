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
          var attack = personnage.get('attack');
          var chance = personnage.get('chance');
          var energy = personnage.get('energy');
          var level = personnage.get('level');
          var specialisation = personnage.get('specialisation');

          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  (level == 10) ?
                  Text("Disponible à partir du Nv.10".toUpperCase(),style: TextStyle(),): Text("Disponible".toUpperCase(),style: TextStyle(),),
                  ElevatedButton.icon(
                    onPressed: () {},
                    label: Text("SPÉCIALISATION"),
                    icon: const Icon(Icons.stacked_line_chart_rounded),
                    style: const ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(Colors.indigo)),
                  ),
                ],
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
                        trailing: attack == 100
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
                                      attack++;
                                      points--;
                                      FirebaseFirestore.instance
                                          .collection('User')
                                          .doc(personnage.id)
                                          .update({'attack': attack});

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
                        percent: attack / 100,
                        center: Text('Attaque : ${(attack).round()}'),
                        backgroundColor: Colors.grey,
                        progressColor: Colors.red,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      LinearPercentIndicator(
                        trailing: chance == 100
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
                                      chance++;
                                      points--;
                                      FirebaseFirestore.instance
                                          .collection('User')
                                          .doc(personnage.id)
                                          .update({'chance': chance});

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
                        percent: chance / 100,
                        center: Text('Chance : ${(chance).round()}'),
                        backgroundColor: Colors.grey,
                        progressColor: Colors.cyan,
                      ),
                    ],
                  ),
                ],
              ),
              ElevatedButton.icon(
                style: ButtonStyle(
                    backgroundColor:
                        const MaterialStatePropertyAll(Colors.indigo),
                    minimumSize: MaterialStateProperty.all(const Size(30, 30))),
                onPressed: () {
                  if (energy < 50) {
                    setState(() {
                      energy++;
                      FirebaseFirestore.instance
                          .collection('User')
                          .doc(personnage.id)
                          .update({'energy': energy});
                    });
                  }
                },
                label: const Text(
                  "Boost",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                icon: const Icon(Icons.flash_on),
              ),
            ],
          );
        });
  }
}
