import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:yded/Utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:yded/Auth/google_in.dart';

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
    emailController =
        TextEditingController(text: FirebaseAuth.instance.currentUser!.email);
    pseudoController = TextEditingController(
        text: FirebaseAuth.instance.currentUser!.displayName);
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
      appBar: AppBar(
        title: Text("Votre profil"),
      ),
      body: Form(
        key: formKey,
        child: Column(
          children: [
            buildPseudoTextField(),
            buildEmailTextField(),
            buildUpdateButton(),
            buildSignOutButton(),
          ],
        ),
      ),
    );
  }

  Widget buildPseudoTextField() {
    return Padding(
      padding: const EdgeInsets.only(right: 40, left: 40, top: 40),
      child: TextFormField(
        style: const TextStyle(color: Colors.white),
        controller: pseudoController,
        cursorColor: Colors.white,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Colors.blue, width: 2.0),
          ),
          labelText: 'Pseudo',
        ),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (pseudo) =>
            pseudo == null ? 'Entrer un pseudo valide' : null,
      ),
    );
  }

  Widget buildEmailTextField() {
    return Padding(
      padding: const EdgeInsets.only(right: 40, left: 40, top: 4),
      child: TextFormField(
        style: const TextStyle(color: Colors.white),
        controller: emailController,
        cursorColor: Colors.white,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Colors.blue, width: 2.0),
          ),
          labelText: 'Email',
        ),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (email) => email != null && !EmailValidator.validate(email)
            ? 'Entrer un email valide'
            : null,
      ),
    );
  }

  Widget buildUpdateButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 120, left: 120, top: 20),
      child: ElevatedButton.icon(
        onPressed: updateProfil,
        icon: const Icon(Icons.edit, size: 32),
        label: const Text('Modifier', style: TextStyle(fontSize: 20)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.indigo,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          minimumSize: const Size.fromHeight(40),
        ),
      ),
    );
  }

  Widget buildSignOutButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 80, left: 80, top: 20),
      child: ElevatedButton.icon(
        onPressed: () => GoogleTest().signOut(),
        icon: const Icon(Icons.edit, size: 32),
        label: const Text('Se déconnecter', style: TextStyle(fontSize: 20)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          minimumSize: const Size.fromHeight(40),
        ),
      ),
    );
  }

  Future<void> updateProfil() async {
    final isValid = formKey.currentState!.validate();
    if (!isValid) return;

    showLoadingDialog(context);

    try {
      await updateEmailAndDisplayName();
      await updateFirestoreName();

      Utils.showSnackBar('Votre profil a été modifié !', true);
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on FirebaseAuthException catch (e) {
      print(e);
      Utils.showSnackBar(e.message);
    }
  }

  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
  }

  Future<void> updateEmailAndDisplayName() async {
    final user = FirebaseAuth.instance.currentUser!;
    await user.updateEmail(emailController.text.trim());
    await user.updateDisplayName(pseudoController.text.trim());
  }

  Future<void> updateFirestoreName() async {
    final user = FirebaseAuth.instance.currentUser!;
    if (user != null) {
      final personnageSnapshot = await FirebaseFirestore.instance
          .collection('User')
          .where('email', isEqualTo: user.email)
          .get();
      final personnageDoc = personnageSnapshot.docs.first;
      await personnageDoc.reference
          .update({'name': pseudoController.text.trim()});
    }
  }
}
