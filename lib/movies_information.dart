import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_test/google_in.dart';
import 'package:firebase_test/update_movies_page.dart';
import 'package:flutter/material.dart';
import 'add_movies_page.dart';

class MoviesInformation extends StatefulWidget {
  const MoviesInformation({Key? key}) : super(key: key);

  @override
  _MoviesInformationState createState() => _MoviesInformationState();
}

class _MoviesInformationState extends State<MoviesInformation> {
  final Stream<QuerySnapshot> _moviesStream =
      FirebaseFirestore.instance.collection('Movies').snapshots();
  final _user = FirebaseAuth.instance.currentUser!;
  void addLike(String docID, int likes) {
    var newLikes = likes + 1;
    try {
      FirebaseFirestore.instance.collection('Movies').doc(docID).update({
        'likes': newLikes,
      }).then((value) => print('Données à jour'));
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    print(_user);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black87,
        actions: [
          IconButton(
              onPressed: () {
                GoogleTest().signOut();
              },
              icon: Icon(Icons.logout))
        ],
        title: Text(
          'Bienvenue : ${_user.displayName}',
          style: TextStyle(fontSize: 14),
        ),
        leading: IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) {
                  return const AddPage();
                },
                fullscreenDialog: true));
          },
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: _moviesStream,
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Text('Something went wrong');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text("Loading");
            }
            return ListView(
                children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> movie =
                  document.data()! as Map<String, dynamic>;
              return Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 3,
                      child: Image.network(movie['poster']),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            movie['name'].toString().toUpperCase(),
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic),
                          ),
                          const Text('Année de production'),
                          Text(movie['year'].toString()),
                          Row(
                            children: [
                              for (final categorie in movie['categories'])
                                Padding(
                                  padding: const EdgeInsets.only(right: 5),
                                  child: Chip(
                                    backgroundColor: Colors.red,
                                    label: Text(categorie),
                                  ),
                                ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton(
                                onPressed: () {
                                  addLike(document.id, movie['likes']);
                                },
                                icon: const Icon(Icons.favorite),
                                iconSize: 20,
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                              ),
                              Text(movie['likes'].toString()),
                              Padding(padding: EdgeInsets.all(10)),
                              IconButton(
                                onPressed: () {
                                  FirebaseFirestore.instance
                                      .collection('Movies')
                                      .doc(document.id)
                                      .delete();
                                },
                                icon: const Icon(Icons.delete),
                                iconSize: 20,
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                              ),
                              Padding(padding: EdgeInsets.all(10)),
                              IconButton(
                                onPressed: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (BuildContext context) {
                                        return UpdatePage(
                                          name: movie['name'],
                                          year: movie['year'],
                                          poster: movie['poster'],
                                          docId: document.id,
                                          categories: movie['categories'],
                                        );
                                      },
                                      fullscreenDialog: true));
                                },
                                icon: const Icon(Icons.update),
                                iconSize: 20,
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              );
            }).toList());
          }),
    );
  }
}
