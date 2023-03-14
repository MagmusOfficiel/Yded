import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:yded/main.dart';

class GoogleTest {
  final _auth = FirebaseAuth.instance;
  final _googleSignIn = GoogleSignIn();

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
      await _googleSignIn.signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;
        final AuthCredential authCredential = GoogleAuthProvider.credential(
            accessToken: googleSignInAuthentication.accessToken,
            idToken: googleSignInAuthentication.idToken);
        await _auth.signInWithCredential(authCredential);
        final email = googleSignInAccount.email;
        final name = googleSignInAccount.displayName;
        final currentUser = _auth.currentUser;
        // Vérifier si l'utilisateur existe déjà
        final querySnapshot = await FirebaseFirestore.instance
            .collection('User')
            .where('email', isEqualTo: email)
            .get();
        if (querySnapshot.docs.isNotEmpty) {
          print('Utilisateur existe déjà');
          return;
        }

        // Si l'utilisateur n'existe pas, créer une nouvelle collection
        await FirebaseFirestore.instance.collection('User').doc(currentUser?.uid).set({
          'email': email,
          'name' : name,
          'energy': 50,
          'stats': {
            'attaque': 1,
            'chance': 1,
            'feu': 0,
            'eau': 0,
            'terre': 0,
            'air': 0,
            'lumière': 0,
            'ténébre': 0
          },
          'specialisation': "aventurier",
          'level': 1,
          'money': 0,
          'percent' : 0,
          'points' : 0,
          'ultime' : 0,
          'sorts' : ["Coup de poing","Rage","Jet d'eau","Lance pierre"],
          'role' : "joueur"
        });
        navigatorKey.currentState!.popUntil((route) => route.isFirst);
      }
    } on FirebaseAuthException catch (e) {
      print(e.message);
      throw e;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }
}
