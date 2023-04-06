import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:yded/Game/combat.dart';
import 'package:yded/Game/profil.dart';
import 'package:yded/Game/pvp.dart';
import 'package:yded/Profil/update_profil.dart';
import 'boutique.dart';
import 'guilde.dart';

class Accueil extends StatefulWidget {
  const Accueil({Key? key}) : super(key: key);

  @override
  _AccueilState createState() => _AccueilState();
}

class _AccueilState extends State<Accueil> {
  final _user = FirebaseAuth.instance.currentUser!;
  int _selectedIndex = 2;
  final ValueNotifier<Duration> _remainingTime =
      ValueNotifier(const Duration(minutes: 1));
  static const List<Widget> _pages = <Widget>[
    Boutique(),
    Profil(),
    Combat(),
    Guilde(),
    PvP(),
  ];

  @override
  void initState() {
    super.initState();
    _startEnergyTimer();
  }

  @override
  void dispose() {
    _energyTimer?.cancel();
    super.dispose();
  }

  Timer? _energyTimer;

  void _startEnergyTimer() {
    DateTime _lastUpdateTime = DateTime.now();
    _energyTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      DateTime currentTime = DateTime.now();
      Duration timeSinceLastUpdate = currentTime.difference(_lastUpdateTime);
      _remainingTime.value -= timeSinceLastUpdate;
      if (_remainingTime.value <= Duration.zero) {
        _remainingTime.value = const Duration(minutes: 1);
        // Mettez à jour l'énergie ici si nécessaire.
        FirebaseFirestore.instance.collection('User').doc(_user.uid).update({
          'energy': 50,
        });
      }
      _lastUpdateTime = currentTime;
    });
  }

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
          final level = personnage.get('level');
          final name = personnage.get('name');
          final money = personnage.get('money');
          final specialisation = personnage.get('specialisation');
          var energy = personnage.get('energy');
          var percent = personnage.get('percent').toDouble();

          return Scaffold(
              backgroundColor: Colors.transparent,
              extendBody: true,
              appBar: _buildAppBar(
                  specialisation, energy, level, percent, money.toDouble(), name),
              body: Center(
                child: _pages.elementAt(_selectedIndex),
              ),
              bottomNavigationBar: _buildBottomNavigationBar(specialisation));
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
            child: Image.asset(
                'assets/images/$specialisation.png',
                fit: BoxFit.cover,width: 45,height: 45,)),
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

  ClipRRect _buildBottomNavigationBar(String specialisation) {
    return ClipRRect(
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(24),
          topLeft: Radius.circular(24),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 15,
          selectedIconTheme: const IconThemeData(color: Colors.white, size: 30),
          selectedItemColor: Colors.white,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: _colorSPr(specialisation: specialisation),
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.shopping_bag), label: "Boutique"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
            BottomNavigationBarItem(icon: Icon(Icons.gamepad), label: "Combat"),
            BottomNavigationBarItem(icon: Icon(Icons.flag), label: "Guilde"),
            BottomNavigationBarItem(
                icon: Icon(Icons.vertical_shades_sharp), label: "PvP"),
          ],
        ));
  }

  dynamic _colorSPr({required String specialisation}) {
    Object colorSp = {
      "archer": const Color(0xFF0b1f16),
      "sorcier": const Color(0xFF213759),
      "guerrier": const Color(0xFF560404),
    }.putIfAbsent(specialisation, () => const Color(0xFF3e2518));
    return colorSp;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
