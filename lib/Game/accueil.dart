import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:yded/Game/combat.dart';
import 'package:flutter/material.dart';
import 'package:yded/Game/profil.dart';
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

  static const List<Widget> _pages = <Widget>[
    Boutique(),
    Profil(),
    Combat(),
    Guilde(),
    UpdateProfil(),
  ];

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
          final money = personnage.get('money');
          var energy = personnage.get('energy');
          var percent = personnage.get('percent').toDouble();
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
                        style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,),
                      ),

                      const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4)),
                      Text(
                        "Niv. $level",
                        style: TextStyle(
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
                  _user.displayName!,
                  style: TextStyle(fontSize: 14),
                ),
                leading: CircleAvatar(
                    backgroundColor: Colors.black,
                    child: Image.network(
                        'https://www.eddy-weber.fr/aventuriers.png',
                        fit: BoxFit.cover)),
              ),
              body: Center(
                child: _pages.elementAt(_selectedIndex),
              ),
              bottomNavigationBar: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(24),
                    topLeft: Radius.circular(24),
                  ),
                  child: BottomNavigationBar(
                    type: BottomNavigationBarType.fixed,
                    selectedFontSize: 15,
                    selectedIconTheme:
                        const IconThemeData(color: Colors.red, size: 30),
                    selectedItemColor: Colors.red,
                    selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
                    currentIndex: _selectedIndex,
                    onTap: _onItemTapped,
                    backgroundColor: Colors.black,
                    items: const [
                      BottomNavigationBarItem(
                          icon: Icon(Icons.shopping_bag), label: "Boutique"),
                      BottomNavigationBarItem(
                          icon: Icon(Icons.person), label: "Profil"),
                      BottomNavigationBarItem(
                          icon: Icon(Icons.gamepad), label: "Combat"),
                      BottomNavigationBarItem(
                          icon: Icon(Icons.flag), label: "Guilde"),
                      BottomNavigationBarItem(
                          icon: Icon(Icons.settings), label: "Options"),
                    ],
                  )));
        });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
