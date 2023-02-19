import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_test/Utils/utils.dart';
import 'package:flutter/material.dart';

class UpdateProfil extends StatefulWidget {
  const UpdateProfil({Key? key}) : super(key: key);

  @override
  _UpdateProfilState createState() => _UpdateProfilState();
}

class _UpdateProfilState extends State<UpdateProfil> {
  late final formKey = GlobalKey<FormState>();
  late final emailController;
  late final pseudoController;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController(text: FirebaseAuth.instance.currentUser!.email);
    pseudoController = TextEditingController(text: FirebaseAuth.instance.currentUser!.displayName);
  }

  @override
  void dispose() {
    emailController.dispose();
    pseudoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Form(
        key: formKey,
        child: Column(
          children: [
            const SizedBox(height: 40),
            TextFormField(
              controller: pseudoController,
              cursorColor: Colors.white,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'Pseudo'),
              validator:  (value) => value != null && value.isEmpty
                  ? 'Le pseudo ne peux pas être vide'
                  : null,
            ),
            const SizedBox(height: 4),
            TextFormField(
              controller: emailController,
              cursorColor: Colors.white,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: (email) =>
              email != null && !EmailValidator.validate(email)
                  ? 'Entrer un email valide'
                  : null,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: updateProfil,
              icon: const Icon(Icons.lock_open, size: 32),
              label:
              const Text('Modifer', style: TextStyle(fontSize: 24)),
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50)),
            ),
          ],
        ),
      ),
    );
  }
  Future updateProfil() async {
    final isValid = formKey.currentState!.validate();
    if (!isValid) return;

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()));

    try {
      await FirebaseAuth.instance.currentUser!.updateEmail(
          emailController.text.trim());
      await FirebaseAuth.instance.currentUser!.updateDisplayName(
          pseudoController.text.trim());

      Utils.showSnackBar('Votre profil a été modifier !', true);
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on FirebaseAuthException catch (e) {
      print(e);
      Utils.showSnackBar(e.message);
    }
  }
}