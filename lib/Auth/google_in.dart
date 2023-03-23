import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:yded/Model/UserYded.dart';
import 'package:yded/main.dart';

class GoogleTest {
  final _auth = FirebaseAuth.instance;
  final _googleSignIn = GoogleSignIn();
  final _firestore = FirebaseFirestore.instance;

  static const String _userCollection = 'User';
  static const String _playerRole = 'joueur';
  static const String _playerSpe = 'aventurier';

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
        final String email = googleSignInAccount.email;
        final String? name = googleSignInAccount.displayName;
        final currentUser = _auth.currentUser;
        // Vérifier si l'utilisateur existe déjà
        final querySnapshot = await _firestore
            .collection('User')
            .where('email', isEqualTo: email)
            .get();
        if (querySnapshot.docs.isNotEmpty) {
          print("Utilisateur $email existe déjà");
          return;
        }

        // Si l'utilisateur n'existe pas, créer une nouvelle collection
        await _firestore
            .collection(_userCollection)
            .doc(currentUser?.uid)
            .set(UserYded(
                email: email,
                name: name!,
                energy: 50,
                stats: {
                  'attaque': 1,
                  'chance': 1,
                  'energy':0,
                  'feu': 0,
                  'eau': 0,
                  'terre': 0,
                  'air': 0,
                  'lumière': 0,
                  'ténébre': 0,
                },
                specialisation: _playerSpe,
                level: 1,
                money: 0,
                percent: 0,
                points: 0,
                ultime: 0,
                role: _playerRole).toMap());

        FirebaseFirestore.instance
            .collection('User')
            .doc(currentUser?.uid)
            .collection('Sorts')
            .add({
          'nom': 'Coup de poing',
          'type': 'air',
          'degats': 1,
          'position': 1,
          'acquis': true,
          'level': 1,
        });

        FirebaseFirestore.instance
            .collection('User')
            .doc(currentUser?.uid)
            .collection('Sorts')
            .add({
          'nom': 'Lance caillou',
          'type': 'terre',
          'degats': 5,
          'position': 2,
          'acquis': true,
          'level': 1,
        });

        FirebaseFirestore.instance
            .collection('User')
            .doc(currentUser?.uid)
            .collection('Sorts')
            .add({
          'nom': 'Rage',
          'type': 'feu',
          'degats': 3,
          'position': 3,
          'acquis': true,
          'level': 1,
        });

        FirebaseFirestore.instance
            .collection('User')
            .doc(currentUser?.uid)
            .collection('Sorts')
            .add({
          'nom': "Jet d'eau",
          'type': 'eau',
          'degats': 4,
          'position': 4,
          'acquis': true,
          'level': 1,
        });
        navigatorKey.currentState!.popUntil((route) => route.isFirst);
      }
    } on FirebaseAuthException catch (e) {
      print("Erreur d'authentification Google : ${e.message}");
      rethrow;
    } catch (e) {
      print("Erreur lors de l'authentification Google : $e");
      rethrow;
    }
  }

  void signOut() async {
    _auth.signOut();
    _googleSignIn.signOut();
    navigatorKey.currentState!.popUntil((route) => route.isFirst);
  }
}
