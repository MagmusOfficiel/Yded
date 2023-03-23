import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:yded/Profil/update_profil.dart';

class MonsterFight extends StatefulWidget {
  late final String _name;
  int life;
  int maxLife;
  int nbrUser;
  bool dead;
  bool bloque;
  late final String _poster;
  late final String _docId;
  late List<String> _categories = [];
  late Stream<DocumentSnapshot> _monsterStream;
  MonsterFight(
      {Key? key,
      required String name,
      required this.life,
      required this.dead,
      required this.nbrUser,
      required this.bloque,
      required this.maxLife,
      required String poster,
      required List<dynamic> categories,
      required String docId})
      : super(key: key) {
    _name = name;
    _poster = poster;
    _docId = docId;
    _categories = List<String>.from(categories);
    _monsterStream = FirebaseFirestore.instance
        .collection('Monsters')
        .doc(_docId)
        .snapshots();
  }
  @override
  _MonsterFightState createState() => _MonsterFightState();
}

class _MonsterFightState extends State<MonsterFight>
    with WidgetsBindingObserver {
  final _user = FirebaseAuth.instance.currentUser!;

  final ValueNotifier<Duration> _remainingTime =
      ValueNotifier(const Duration(minutes: 1));
  final _showDamagesNotifier = ValueNotifier(false);
  // Déclarez la variable degatsCauses dans l'état de votre widget
  int degatsCauses = 0;
  bool get showDamages => _showDamagesNotifier.value;

  set showDamages(bool value) {
    _showDamagesNotifier.value = value;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    FirebaseFirestore.instance
        .collection('Monsters')
        .doc(widget._docId)
        .update({'bloque': widget.bloque, 'nbrUser': widget.nbrUser + 1});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.detached) {
      // L'application est deconnecter
      if (widget.nbrUser == 0) {
        FirebaseFirestore.instance
            .collection('Monsters')
            .doc(widget._docId)
            .update({
          'bloque': false,
        });
      } else {
        FirebaseFirestore.instance
            .collection('Monsters')
            .doc(widget._docId)
            .update({
          'nbrUser': widget.nbrUser - 1,
        });
      }
    }
  }

  // Ajoutez un état local pour stocker les données des sorts.
  List<Map<String, dynamic>> _sortsData = [];

// Ajoutez cette fonction pour charger les données des sorts lors de l'initialisation de l'écran.
  Future<void> _loadSortsData(DocumentReference personnageRef) async {
    final sortsCollection = personnageRef.collection('Sorts');
    final sortsSnapshot = await sortsCollection.orderBy('position').get();

    _sortsData = sortsSnapshot.docs.map((doc) => doc.data()).toList();
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    // Mettre à jour la variable "bloque" dans Firestore
    if (widget.nbrUser == 0) {
      FirebaseFirestore.instance
          .collection('Monsters')
          .doc(widget._docId)
          .update({
        'bloque': false,
      });
    } else {
      FirebaseFirestore.instance
          .collection('Monsters')
          .doc(widget._docId)
          .update({
        'nbrUser': widget.nbrUser - 1,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> _personnageStream = FirebaseFirestore.instance
        .collection('User')
        .where('email', isEqualTo: _user.email)
        .snapshots();
    return StreamBuilder<QuerySnapshot>(
        stream: _personnageStream,
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

          final name = personnage.get('name');
          final specialisation = personnage.get('specialisation');
          var ultime = personnage.get('ultime').toDouble() ?? 00;
          final stats = personnage.get('stats');
          var energy = personnage.get('energy');
          var level = personnage.get('level');
          var money = personnage.get('money');
          var percent = personnage.get('percent').toDouble() ?? 0.0;
          var points = personnage.get('points');
          // Récupère les sorts du personnage
          return FutureBuilder(
            future: _loadSortsData(personnage.reference),
            builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
              if (_sortsData.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              Random random = Random();

              // Crée une liste de Widgets pour afficher les sorts
              final sortWidgets = _sortsData.map((sort) {
                final sortsNom = sort['nom'];
                final sortsType = sort['type'];
                int degats = sort['degats'];
                num damage = random.nextInt(degats) + stats['attaque'];
                if (sortsType == 'feu') {
                  damage += stats['feu'];
                }
                return SizedBox(
                  height: MediaQuery.of(context).size.height / 15,
                  width: MediaQuery.of(context).size.width / 2.2,
                  child: InkWell(
                    onTap: () {
                      _attackBoss(
                        energy: energy,
                        ultime: ultime,
                        percent: percent,
                        attack: damage,
                        level: level,
                        money: money,
                        points: points,
                        chance: stats['chance'],
                        personnage: personnage,
                        degats: damage,
                      );
                    },
                    child: Card(
                      color: _colorSorts(type: sortsType),
                      elevation: 10,
                      borderOnForeground: true,
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(color: Colors.black, width: 3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          sortsNom,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList();

              return StreamBuilder<DocumentSnapshot>(
                  stream: widget._monsterStream,
                  builder: (BuildContext context,
                      AsyncSnapshot<DocumentSnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return Text(
                          'Une erreur est survenue : ${snapshot.error}');
                    }
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final monster = snapshot.data;
                    widget.life = monster?.get('life') ?? 0;
                    widget.dead = monster?.get('dead') ?? false;
                    widget.nbrUser = monster?.get('nbrUser') ?? 0;
                    return Scaffold(
                      appBar: _buildAppBar(specialisation, energy, level,
                          percent, money.toDouble(), name),
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
                          Positioned(
                              child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                width: 10.0,
                                height: 10.0,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(width: 4.0),
                              Text(
                                'En ligne : ${widget.nbrUser}',
                                style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          )),
                          Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                (widget.dead == false && widget.life >= 1)
                                    ? Text(widget._name,
                                        style: const TextStyle(
                                            fontSize: 35, color: Colors.white))
                                    : const Text(''),
                                const SizedBox(
                                  height: 10,
                                ),
                                (widget.dead == false && widget.life >= 1)
                                    ? Container(
                                        width: 200,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Stack(
                                          children: [
                                            Positioned.fill(
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.red,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                width: widget.life.toDouble() *
                                                    200,
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
                                    : const Icon(Icons.calendar_view_week),
                                const SizedBox(height: 10),
                                Center(
                                    child: (widget.dead == false &&
                                            widget.life >= 1)
                                        ? Image.network(widget._poster,
                                            errorBuilder: (BuildContext context,
                                                Object exception,
                                                StackTrace? starcktrace) {
                                            return Image.network(
                                                "https://www.eddy-weber.fr/monstre-inconnu.png",
                                                fit: BoxFit.cover,
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height /
                                                    3,
                                                loadingBuilder: (context, child,
                                                    loadingProgress) {
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
                                            });
                                          },
                                            fit: BoxFit.cover,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                3)
                                        : Image.network(
                                            'https://www.eddy-weber.fr/mort.gif',
                                            fit: BoxFit.cover,
                                            height:
                                                MediaQuery.of(context).size.height / 3,
                                            loadingBuilder: (context, child,
                                                loadingProgress) {
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
                                          })),
                                const SizedBox(height: 50),
                                // Affiche les sorts
                                Column(children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: sortWidgets.sublist(0, 2),
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
                                          critique: true,
                                          degats: null,
                                        );
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
                                        width: 50,
                                        height: 50,
                                      ),
                                      progressColor: _colorSPr(
                                          specialisation: specialisation),
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: sortWidgets.sublist(2, 4),
                                  ),
                                ]),
                                const SizedBox(height: 50),
                                (widget.dead == false && widget.life >= 1)
                                    ? ElevatedButton.icon(
                                        style: const ButtonStyle(
                                            backgroundColor:
                                                MaterialStatePropertyAll(
                                                    Colors.black)),
                                        onPressed: () => {
                                          if (widget.nbrUser == 0)
                                            {
                                              FirebaseFirestore.instance
                                                  .collection('Monsters')
                                                  .doc(widget._docId)
                                                  .update({
                                                'bloque': false,
                                                'nbrUser': widget.nbrUser - 1
                                              }),
                                            }
                                          else
                                            {
                                              FirebaseFirestore.instance
                                                  .collection('Monsters')
                                                  .doc(widget._docId)
                                                  .update({
                                                'nbrUser': widget.nbrUser - 1
                                              }),
                                            },
                                          Navigator.pop(context)
                                        },
                                        icon: const Icon(Icons.home),
                                        label: const Text("Sortir"),
                                      )
                                    : ElevatedButton.icon(
                                        style: const ButtonStyle(
                                            backgroundColor:
                                                MaterialStatePropertyAll(
                                                    Colors.green)),
                                        onPressed: () {
                                          Random random = Random();
                                          int newMoney = random.nextInt(100);
                                          money = money +
                                              (newMoney * stats['chance']) +
                                              (monster!['maxLife'] / 10);
                                          FirebaseFirestore.instance
                                              .collection('User')
                                              .doc(personnage.id)
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
                          ValueListenableBuilder(
                            valueListenable: _showDamagesNotifier,
                            builder: (context, value, child) {
                              return Positioned(
                                  top: MediaQuery.of(context).size.height / 5,
                                  right:
                                      MediaQuery.of(context).size.width / 2.2,
                                  child: AnimatedOpacity(
                                    opacity:
                                        _showDamagesNotifier.value ? 1.0 : 0.0,
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.easeInOut,
                                    child: Text(
                                      '-${degatsCauses.toString()}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ));
                            },
                          )
                        ],
                      ),
                    );
                  });
            },
          );
        });
  }

  AppBar _buildAppBar(String specialisation, int energy, int level,
      double percent, double money, String name) {
    return AppBar(
      backgroundColor: _colorSPr(specialisation: specialisation),
      actions: [
        Row(
          children: [
            _buildEnergyIndicator(energy, _remainingTime),
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
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            LinearPercentIndicator(
              width: 60.0,
              percent: percent,
              lineHeight: 14.0,
              backgroundColor: Colors.grey,
              progressColor: Colors.red,
            ),
            Text(
              money.toStringAsFixed(0),
              style: const TextStyle(fontSize: 12),
            ),
            const Icon(
              Icons.attach_money,
              size: 12,
            ),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 16)),
          ],
        ),
      ],
      title: Text(
        name,
        style: const TextStyle(fontSize: 14),
      ),
      leading: CircleAvatar(
        backgroundColor: Colors.transparent,
        child: GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) {
                  return const UpdateProfil();
                },
              ));
            },
            child: Image.network(
              'https://www.eddy-weber.fr/$specialisation.png',
              fit: BoxFit.cover,
              width: 45,
              height: 45,
            )),
      ),
    );
  }

  Widget _buildEnergyIndicator(
      int energy, ValueNotifier<Duration> remainingTime) {
    return (energy < 50)
        ? ValueListenableBuilder<Duration>(
            valueListenable: remainingTime,
            builder: (context, value, child) {
              return Text(
                '${value.inSeconds}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          )
        : const SizedBox();
  }

  void _attackBoss({
    required energy,
    required ultime,
    required percent,
    required attack,
    required level,
    required money,
    required points,
    required chance,
    required personnage,
    bool critique = false,
    required degats,
  }) {
    if (energy <= 0 && critique == false) {
      return;
    }
    ultime = (ultime < 0.99) ? ultime + 0.01 : 1;
    if (ultime == 1 && critique) {
      ultime = 0;
    }

    energy--;
    money = money + attack;
    if (percent >= 0.99) {
      percent = 0;
      level++;
      money += 10 * chance;
      points++;
    } else {
      percent += 0.01;
    }

    // Mise à jour des données du personnage dans Firestore
    FirebaseFirestore.instance.collection('User').doc(personnage.id).update({
      'money': money,
      'ultime': ultime,
      'level': level,
      'points': points,
      'percent': percent,
      'energy': energy,
    });
    _decreaseLife(
      attack: attack,
      critique: critique,
    );
  }

  void _decreaseLife({
    required int attack,
    required bool critique,
  }) {
    if (critique) {
      attack = attack * 2;
    }
    int newLife = widget.life - attack;
    if (newLife <= 0) {
      FirebaseFirestore.instance
          .collection('Monsters')
          .doc(widget._docId)
          .update({
        'dead': true,
        'life': 0,
      });
    } else {
      degatsCauses = attack;
      _showDamagesNotifier.value = true;
      Timer(const Duration(milliseconds: 500), () {
        _showDamagesNotifier.value = false;
      });
      FirebaseFirestore.instance
          .collection('Monsters')
          .doc(widget._docId)
          .update({
        'life': newLife,
      });
    }
  }

  /// Permet de déterminer quel state est appelé.
  dynamic _colorSPr({required String specialisation}) {
    Object colorSp = {
      "archer": Colors.green.withOpacity(0.2),
      "sorcier": Colors.blue.withOpacity(0.2),
      "guerrier": Colors.red.withOpacity(0.2),
    }.putIfAbsent(specialisation, () => Colors.black);
    return colorSp;
  }

  /// Permet de déterminer quel state est appelé.
  dynamic _colorSorts({required String type}) {
    Object colorSp = {
      "feu": Colors.red,
      "eau": Colors.blue,
      "terre": Colors.brown,
      "tenebre": Colors.purple,
      "air": Colors.white,
      "lumiere": Colors.yellow,
    }.putIfAbsent(type, () => Colors.grey);
    return colorSp;
  }
}
