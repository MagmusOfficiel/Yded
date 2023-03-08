import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class Guilde extends StatefulWidget {
  const Guilde({Key? key}) : super(key: key);

  @override
  _GuildeState createState() => _GuildeState();
}

class _GuildeState extends State<Guilde> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('User').orderBy('level', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Erreur: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text('Chargement des utilisateurs...');
          }

          final documents = snapshot.data!.docs;

          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 8.0,
              crossAxisSpacing: 8.0,
              childAspectRatio: 1.0,
            ),
            itemCount: documents.length,
            itemBuilder: (context, index) {
              final data = documents[index].data() as Map<String, dynamic>;
              final name = data['name'] ?? 'Inconnu';
              final specialisation = data['specialisation'];
              final level = data['level'];
              final attack = data['attack'];
              final chance = data['chance'];
              return InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        elevation: 5,
                        backgroundColor: Colors.black,
                        title: Text(name + ' - Nv.' + level.toString()),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.network(
                                "https://www.eddy-weber.fr/$specialisation.png",height: MediaQuery.of(context).size.height /6,fit: BoxFit.contain,),
                            const SizedBox(height: 8.0),
                            const SizedBox(height: 8.0),
                            LinearPercentIndicator(
                              animateFromLastPercent: true,
                              animation: true,
                              width: MediaQuery.of(context).size.width / 1.5,
                              lineHeight: 20.0,
                              percent: attack / 100,
                              center: Text('Attaque : ${(attack).round()}'),
                              backgroundColor: Colors.grey,
                              progressColor: Colors.red,
                            ),
                            const SizedBox(height: 8.0),
                            LinearPercentIndicator(
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
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Icon(Icons.close))
                        ],
                      );
                    },
                  );
                },
                child: Card(
                  color: Colors.black,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network(
                        "https://www.eddy-weber.fr/$specialisation.png",
                      ),
                      const SizedBox(height: 8.0),
                      Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4.0),
                      Text(level.toString())
                    ],
                  ),
                ),
              );
            },
          );
        });
  }
}
