import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:yded/main.dart';
import 'package:yded/Utils/utils.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class SignUpWidget extends StatefulWidget {
  final Function() onClickedSignIn;

  const SignUpWidget({Key? key, required this.onClickedSignIn})
      : super(key: key);

  @override
  _SignUpWidgetState createState() => _SignUpWidgetState();
}

class _SignUpWidgetState extends State<SignUpWidget> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final pseudoController = TextEditingController();
  bool isSelected = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    pseudoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Image.network(
            (isSelected == true)
                ? 'https://www.eddy-weber.fr/YddeF.gif'
                : 'https://www.eddy-weber.fr/Ydde.gif',
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }
          return CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                : null,
          );
        }),
      ),
      Form(
        key: formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(padding: EdgeInsets.only(top: 20)),
            ElevatedButton(
                onPressed: () {
                  setState(() {
                    isSelected = !isSelected;
                  });
                },
                style: ButtonStyle(
                    backgroundColor: (isSelected == true)
                        ? const MaterialStatePropertyAll(Colors.purpleAccent)
                        : const MaterialStatePropertyAll(Colors.indigo)),
                child: const Icon(
                  Icons.switch_access_shortcut,
                  size: 20,
                )),
            const SizedBox(height: 20),
            Padding(
                padding: const EdgeInsets.only(right: 40, left: 40),
                child: TextFormField(
                  controller: pseudoController,
                  cursorColor: Colors.white,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Pseudo'),
                  validator: (value) => value != null && value.isEmpty
                      ? 'Le pseudo ne peux pas être vide'
                      : null,
                )),
            const SizedBox(height: 4),
            Padding(
                padding: const EdgeInsets.only(right: 40, left: 40),
                child: TextFormField(
                  style: const TextStyle(color: Colors.white),
                  controller: emailController,
                  cursorColor: Colors.white,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide:
                            const BorderSide(color: Colors.blue, width: 2.0),
                      ),
                      labelText: 'Email'),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (email) =>
                      email != null && !EmailValidator.validate(email)
                          ? 'Entrer un email valide'
                          : null,
                )),
            const SizedBox(height: 4),
            Padding(
                padding: const EdgeInsets.only(right: 40, left: 40),
                child: TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide:
                            const BorderSide(color: Colors.blue, width: 2.0),
                      ),
                      labelText: 'Mot de passe'),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) => value != null && value.length < 8
                      ? 'Le mot de passe doit contenir au minimum 8 caractères'
                      : null,
                )),
            const SizedBox(height: 20),
            Padding(
                padding: const EdgeInsets.only(right: 100, left: 100),
                child: ElevatedButton.icon(
                  onPressed: signUp,
                  icon: const Icon(Icons.play_arrow, size: 32),
                  label:
                      const Text('Inscription', style: TextStyle(fontSize: 20)),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: (isSelected == true)
                          ? Colors.purpleAccent
                          : Colors.indigo,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0)),
                      minimumSize: const Size.fromHeight(40)),
                )),
            const SizedBox(height: 24),
            RichText(
                text: TextSpan(
                    children: [
                  TextSpan(
                      recognizer: TapGestureRecognizer()
                        ..onTap = widget.onClickedSignIn,
                      text: 'Connexion',
                      style: const TextStyle(
                          decoration: TextDecoration.underline,
                          color: Colors.white,
                          fontWeight: FontWeight.bold))
                ],
                    style: TextStyle(color: Colors.white, fontSize: 14),
                    text: 'Déjà un compte?  '))
          ],
        ),
      )
    ]);
  }

  Future signUp() async {
    final isValid = formKey.currentState!.validate();
    if (!isValid) return;

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()));

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim());
      await FirebaseAuth.instance.currentUser!
          .updateDisplayName(pseudoController.text.trim());
      final currentUser = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance.collection('User').doc(currentUser?.uid).set({
        'email': emailController.value.text,
        'name': pseudoController.value.text,
        'specialisation': "aventurier",
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
        'level': 1,
        'money': 0,
        'percent': 0,
        'points': 0,
        'ultime': 0,
        'sorts': ["Coup de poing", "Rage", "Jet d'eau", "Lance pierre"],
        'role': "joueur"
      });
    } on FirebaseAuthException catch (e) {
      print(e);

      Utils.showSnackBar(e.message);
    }
    navigatorKey.currentState!.popUntil((route) => route.isFirst);
  }
}
