import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class MonsterFight extends StatefulWidget {
  late final String _name;
  int life;
  int maxLife;
  bool dead;
  late final String _poster;
  late final String _docId;
  late List<String> _categories = [];
  MonsterFight(
      {Key? key,
      required String name,
      required this.life,
      required this.dead,
      required this.maxLife,
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
  _MonsterFightState createState() => _MonsterFightState();
}

class _MonsterFightState extends State<MonsterFight> {
  final _user = FirebaseAuth.instance.currentUser!;
  late Stream<DocumentSnapshot> _personnageStream;
  bool _showDamages = false;

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
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          // Récupère le premier document du QuerySnapshot
          final personnage = snapshot.data;

          // Récupère les propriétés du personnage
          final name = personnage?.get('name');
          final specialisation = personnage?.get('specialisation');
          final sorts = personnage?.get('sorts');
          var ultime = personnage?.get('ultime').toDouble() ?? 00;
          final stats = personnage?.get('stats');
          var energy = personnage?.get('energy');
          var level = personnage?.get('level');
          var money = personnage?.get('money');
          var percent = personnage?.get('percent').toDouble() ?? 0.0;
          var points = personnage?.get('points');
          return Scaffold(
            appBar: AppBar(
              backgroundColor: _colorSPr(specialisation: specialisation),
              actions: [
                Row(
                  children: [
                    const Icon(
                      Icons.flash_on,
                      size: 12,
                    ),
                    Text(
                      " : ${energy}/50",
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
                      style: TextStyle(fontSize: 12),
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
                name,
                style: const TextStyle(fontSize: 14),
              ),
              leading: CircleAvatar(
                  backgroundColor: Colors.transparent,
                  child: Image.network(
                      'https://www.eddy-weber.fr/$specialisation.png',
                      fit: BoxFit.cover)),
            ),
            body: Stack(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: Image.network(
                    "https://www.eddy-weber.fr/donjon.png",
                    fit: BoxFit.cover,
                  ),
                ),
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  (widget.dead == false && widget.life >= 1)
                      ? Text(widget._name,
                          style: const TextStyle(
                              fontSize: 35, color: Colors.white))
                      : Text(''),
                  const SizedBox(
                    height: 10,
                  ),
                  (widget.dead == false && widget.life >= 1)
                      ? Container(
                          width: 200,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  width: widget.life.toDouble() * 200,
                                ),
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: Text(
                                  '${widget.life.toString()} / ${widget.maxLife.toString()}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Icon(Icons.calendar_view_week),
                  const SizedBox(height: 10),
                  Center(
                      child: (widget.dead == false && widget.life >= 1)
                          ? Image.network(widget._poster, errorBuilder:
                                  (BuildContext context, Object exception,
                                      StackTrace? starcktrace) {
                              return Image.network(
                                  "https://www.eddy-weber.fr/monstre-inconnu.png",
                                  fit: BoxFit.cover,
                                  height:
                                      MediaQuery.of(context).size.height / 3,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                if (loadingProgress == null) {
                                  return child;
                                }
                                return CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                );
                              });
                            },
                              fit: BoxFit.cover,
                              height: MediaQuery.of(context).size.height / 3)
                          : Image.network('https://www.eddy-weber.fr/mort.gif',
                              fit: BoxFit.cover,
                              height: MediaQuery.of(context).size.height / 3,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                              if (loadingProgress == null) {
                                return child;
                              }
                              return CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              );
                            })),
                  const SizedBox(height: 50),
                  (widget.dead == false && widget.life >= 1)
                      ? Column(children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width / 2.2,
                                height: 50,
                                child: ElevatedButton(
                                  style: ButtonStyle(
                                    elevation: MaterialStateProperty.all(50),
                                    side: MaterialStatePropertyAll(BorderSide(
                                        color: _colorSPr(
                                            specialisation: specialisation),
                                        width: 2)),
                                    shape: MaterialStateProperty.all(
                                        RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20.0))),
                                    backgroundColor:
                                        MaterialStateProperty.all(Colors.black),
                                  ),
                                  onPressed: () {
                                    _attackBoss(
                                        energy: energy,
                                        ultime: ultime,
                                        percent: percent,
                                        attack: stats['attaque'],
                                        level: level,
                                        money: money,
                                        points: points,
                                        chance: stats['chance'],
                                        personnage: personnage);
                                  },
                                  child: Text(
                                    sorts[0],
                                    style: TextStyle(
                                        color: _colorSPr(
                                            specialisation: specialisation)),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width / 2.2,
                                height: 50,
                                child: ElevatedButton(
                                  style: ButtonStyle(
                                    elevation: MaterialStateProperty.all(50),
                                    side: MaterialStatePropertyAll(BorderSide(
                                        color: _colorSPr(
                                            specialisation: specialisation),
                                        width: 2)),
                                    shape: MaterialStateProperty.all(
                                        RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20.0))),
                                    backgroundColor:
                                        MaterialStateProperty.all(Colors.black),
                                  ),
                                  onPressed: () {
                                    _attackBoss(
                                        energy: energy,
                                        ultime: ultime,
                                        percent: percent,
                                        attack: stats['attaque'],
                                        level: level,
                                        money: money,
                                        points: points,
                                        chance: stats['chance'],
                                        personnage: personnage);
                                  },
                                  child: Text(
                                    sorts[1],
                                    style: TextStyle(
                                        color: _colorSPr(
                                            specialisation: specialisation)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              if (ultime >= 1) {
                                _attackBoss(
                                    energy: energy,
                                    ultime: ultime,
                                    percent: percent,
                                    attack: stats['attaque'],
                                    level: level,
                                    money: money,
                                    points: points,
                                    chance: stats['chance'],
                                    personnage: personnage,
                                    critique: true);
                              }
                            },
                            child: CircularPercentIndicator(
                              backgroundColor: Colors.black,
                              radius: 30.0,
                              lineWidth: 30.0,
                              percent: ultime,
                              center: Image.network(
                                'https://www.eddy-weber.fr/$specialisation.png',
                                fit: BoxFit.contain,
                              ),
                              progressColor:
                                  _colorSPr(specialisation: specialisation),
                            ),
                          ),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width / 2.2,
                                  height: 50,
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                      elevation: MaterialStateProperty.all(50),
                                      side: MaterialStatePropertyAll(BorderSide(
                                          color: _colorSPr(
                                              specialisation: specialisation),
                                          width: 2)),
                                      shape: MaterialStateProperty.all(
                                          RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20.0))),
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              Colors.black),
                                    ),
                                    onPressed: () {
                                      _attackBoss(
                                          energy: energy,
                                          ultime: ultime,
                                          percent: percent,
                                          attack: stats['attaque'],
                                          level: level,
                                          money: money,
                                          points: points,
                                          chance: stats['chance'],
                                          personnage: personnage);
                                    },
                                    child: Text(
                                      sorts[2],
                                      style: TextStyle(
                                          color: _colorSPr(
                                              specialisation: specialisation)),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width / 2.2,
                                  height: 50,
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                      elevation: MaterialStateProperty.all(50),
                                      side: MaterialStatePropertyAll(BorderSide(
                                          color: _colorSPr(
                                              specialisation: specialisation),
                                          width: 2)),
                                      shape: MaterialStateProperty.all(
                                          RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20.0))),
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              Colors.black),
                                    ),
                                    onPressed: () {
                                      _attackBoss(
                                          energy: energy,
                                          ultime: ultime,
                                          percent: percent,
                                          attack: stats['attaque'],
                                          level: level,
                                          money: money,
                                          points: points,
                                          chance: stats['chance'],
                                          personnage: personnage);
                                    },
                                    child: Text(
                                      sorts[3],
                                      style: TextStyle(
                                          color: _colorSPr(
                                              specialisation: specialisation)),
                                    ),
                                  ),
                                )
                              ]),
                        ])
                      : const SizedBox(height: 0),
                  const SizedBox(height: 50),
                  (widget.dead == false && widget.life >= 1)
                      ? ElevatedButton.icon(
                          style: const ButtonStyle(
                              backgroundColor:
                                  MaterialStatePropertyAll(Colors.black)),
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.home),
                          label: const Text("Sortir"),
                        )
                      : ElevatedButton.icon(
                          style: const ButtonStyle(
                              backgroundColor:
                                  MaterialStatePropertyAll(Colors.green)),
                          onPressed: () async {
                            Random random = Random();
                            int newMoney = random.nextInt(100) + 1;
                            money = money + (newMoney * stats['chance']);

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
                        ),
                ]),
                Positioned(
                    top: MediaQuery.of(context).size.height / 5,
                    right: MediaQuery.of(context).size.width / 2.2,
                    child: AnimatedOpacity(
                      opacity: _showDamages ? 1.0 : 0.0,
                      duration: Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                      child: Text(
                        '-${stats['attaque']}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )),
              ],
            ),
          );
        });
  }

  void _attackBoss(
      {required energy,
      required ultime,
      required percent,
      required attack,
      required level,
      required money,
      required points,
      required chance,
      required personnage,
      bool critique = false}) {
    setState(() {
      if (energy <= 0) {
        energy = 0;
      } else {
        if (ultime < 0.99) {
          ultime = ultime + 0.01.toDouble();
        } else {
          ultime = 1;
          if (critique == true) {
            ultime = 0;
          }
        }
        _decreaseLife(attack: attack);
        energy--;
        if (percent >= 0.99) {
          percent = 0;
          level++;
          money = money + (10 * chance);
          points++;
        } else {
          percent = percent + 0.01.toDouble();
        }
      }

      FirebaseFirestore.instance.collection('User').doc(personnage?.id).update({
        'money': money,
        'ultime': ultime,
        'level': level,
        'points': points,
        'percent': percent,
        'energy' : energy
      });
    });
  }

  /// Permet de déterminer quel state est appelé.
  dynamic _colorSPr({required String specialisation}) {
    Object colorSp = {
      "archer": Colors.green.withOpacity(0.5),
      "sorcier": Colors.blue.withOpacity(0.5),
      "guerrier": Colors.red.withOpacity(0.5),
    }.putIfAbsent(specialisation, () => Colors.white24);
    return colorSp;
  }

  void _decreaseLife({required int attack}) {
    if (widget.life <= attack) {
      setState(() {
        widget.life -= attack;
      });
      FirebaseFirestore.instance
          .collection('Monsters')
          .doc(widget._docId)
          .update({'dead': true});
    } else {
      setState(() {
        widget.life -= attack;
        _showDamages = true;
        Future.delayed(Duration(milliseconds: 500), () {
          setState(() {
            _showDamages =
                false; // cacher le nombre d'attaques infligées après 2 secondes
          });
        });
      });

      FirebaseFirestore.instance
          .collection('Monsters')
          .doc(widget._docId)
          .update({'life': widget.life});
    }
  }
}
