import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class UpdatePage extends StatefulWidget {
  late final String _name;
  int life;
  bool dead;
  late final String _poster;
  late final String _docId;
  late List<String> _categories = [];

  UpdatePage(
      {Key? key,
      required String name,
      required this.life,
      required this.dead,
      required String poster,
      required List<dynamic> categories,
      required String docId})
      : super(key: key) {
    _name = name;
    _poster = poster;
    _docId = docId;
    _categories = List<String>.from(categories);
  }
  @override
  _UpdatePageState createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
  final _user = FirebaseAuth.instance.currentUser!;
  late Stream<DocumentSnapshot> _personnageStream;

  @override
  void initState() {
    super.initState();
    _personnageStream = FirebaseFirestore.instance
        .collection('User')
        .where('email', isEqualTo: _user.email)
        .snapshots()
        .map((event) => event.docs.first);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: _personnageStream,
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Une erreur est survenue : ${snapshot.error}');
          }
          // Récupère le premier document du QuerySnapshot
          final personnage = snapshot.data;

          // Récupère la propriété "level" du personnage
          var level = personnage?.get('level');
          var money = personnage?.get('money');
          var energy = personnage?.get('energy');
          var percent = personnage?.get('percent').toDouble() ?? 0.0;

          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.black87,
              actions: [
                Row(
                  children: [
                    const Icon(
                      Icons.flash_on,
                      size: 12,
                    ),
                    Text(
                      " : $energy/50",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Padding(padding: EdgeInsets.symmetric(horizontal: 4)),
                    Text(
                      "Niv. $level",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    LinearPercentIndicator(
                      width: 60.0,
                      percent: percent,
                      lineHeight: 14.0,
                      backgroundColor: Colors.grey,
                      progressColor: Colors.red,
                    ),
                    Text(
                      money.toString(),
                      style: const TextStyle(fontSize: 12),
                    ),
                    const Icon(
                      Icons.attach_money,
                      size: 12,
                    ),
                    const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16)),
                  ],
                ),
              ],
              title: Text(
                _user.displayName!,
                style: const TextStyle(fontSize: 14),
              ),
              leading: CircleAvatar(
                  backgroundColor: Colors.black,
                  child: Image.network(
                      'https://www.eddy-weber.fr/aventuriers.png',
                      fit: BoxFit.cover)),
            ),
            body: Stack(
              children: [
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  (widget.dead == false && widget.life != 0)
                      ? Text(widget._name,
                          style:
                              const TextStyle(fontSize: 35, color: Colors.red))
                      : Text(''),
                  (widget.dead == false && widget.life != 0)
                      ? Text('HP: ${widget.life}',
                          style: const TextStyle(fontSize: 35))
                      : const Icon(
                          Icons.access_time_rounded,
                          size: 32,
                        ),
                  const SizedBox(height: 10),
                  Center(
                    child: (widget.dead == false && widget.life != 0)
                        ? GestureDetector(
                            onTap: () {
                              setState(() {
                                if (energy == 0) {
                                } else {
                                  energy--;
                                  _decreaseLife();
                                  if (percent >= 0.99) {
                                    percent = 0;
                                    level++;
                                    money + 10;
                                  } else {
                                    percent = percent + 0.01;
                                  }
                                }
                              });

                              FirebaseFirestore.instance
                                  .collection('User')
                                  .doc(personnage?.id)
                                  .update({'level': level});

                              FirebaseFirestore.instance
                                  .collection('User')
                                  .doc(personnage?.id)
                                  .update({'percent': percent});

                              FirebaseFirestore.instance
                                  .collection('User')
                                  .doc(personnage?.id)
                                  .update({'energy': energy});
                            },
                            child: Image.network(widget._poster,
                                fit: BoxFit.cover,
                                height: MediaQuery.of(context).size.height / 3),
                          )
                        : Image.network('https://www.eddy-weber.fr/mort.gif',
                            fit: BoxFit.cover,
                            height: MediaQuery.of(context).size.height / 3),
                  ),
                  const SizedBox(height: 50),
                  (widget.dead == false && widget.life != 0)
                      ? ElevatedButton.icon(
                          style: const ButtonStyle(
                              backgroundColor:
                                  MaterialStatePropertyAll(Colors.red)),
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back),
                          label: const Text("Revenir à l'accueil"),
                        )
                      : ElevatedButton.icon(
                          style: const ButtonStyle(
                              backgroundColor:
                                  MaterialStatePropertyAll(Colors.green)),
                          onPressed: () async {
                            Random random = Random();
                            int newMoney = random.nextInt(100) + 1;
                            money = money + newMoney;

                            await FirebaseFirestore.instance
                                .collection('User')
                                .doc(personnage?.id)
                                .update({'money': money});

                            Navigator.pop(context);
                          },
                          icon: const Icon(
                            Icons.card_giftcard,
                            color: Colors.black,
                          ),
                          label: const Text(
                            "Récupére ta récompense",
                            style: TextStyle(color: Colors.black),
                          ),
                        )
                ])
              ],
            ),
          );
        });
  }

  void _decreaseLife() {
    if (widget.life == 1) {
      setState(() {
        widget.life--;
      });

      FirebaseFirestore.instance
          .collection('Monsters')
          .doc(widget._docId)
          .update({'dead': true});
    } else {
      setState(() {
        widget.life--;
      });

      FirebaseFirestore.instance
          .collection('Monsters')
          .doc(widget._docId)
          .update({'life': widget.life});
    }
  }
}
