import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_test/Utils/utils.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../Profil/forgot_password_page.dart';
import '../main.dart';
import 'google_in.dart';

class LoginWidget extends StatefulWidget {
  final VoidCallback onClickedSignUp;

  const LoginWidget({Key? key, required this.onClickedSignUp})
      : super(key: key);

  @override
  _LoginWidgetState createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          TextFormField(
            controller: emailController,
            cursorColor: Colors.white,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(labelText: 'Email'),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (email) =>
                email != null && !EmailValidator.validate(email)
                    ? 'Entrer un email valide'
                    : null,
          ),
          const SizedBox(height: 4),
          TextFormField(
            controller: passwordController,
            obscureText: true,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(labelText: 'Mot de passe'),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) => value != null && value.length < 8
                ? 'Le mot de passe doit contenir au minimum 8 caractères'
                : null,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: signIn,
            icon: const Icon(Icons.lock_open, size: 32),
            label: const Text('Connexion', style: TextStyle(fontSize: 24)),
            style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50)),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            child: const Text(
              'Mot de passe oublié?',
              style: TextStyle(
                  decoration: TextDecoration.underline,
                  color: Colors.white,
                  fontSize: 20),
            ),
            onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => ForgotPasswordPage())),
          ),
          const SizedBox(height: 24),
          RichText(
              text: TextSpan(
                  children: [
                TextSpan(
                    recognizer: TapGestureRecognizer()
                      ..onTap = widget.onClickedSignUp,
                    text: 'Inscription',
                    style: const TextStyle(
                        decoration: TextDecoration.underline,
                        color: Colors.white,
                        fontWeight: FontWeight.bold))
              ],
                  style: TextStyle(color: Colors.white, fontSize: 20),
                  text: 'Pas de compte ?')),
          ElevatedButton.icon(
            onPressed: () async {
                await GoogleTest().signInWithGoogle();
            },
            icon: const Icon(Icons.g_mobiledata_outlined, size: 32),
            label: const Text('Connexion avec Google', style: TextStyle(fontSize: 24)),
            style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50)),
          ),
        ],
      ),
    );
  }

  Future signIn() async {
    final isValid = formKey.currentState!.validate();
    if (!isValid) return;

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()));

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim());

    } on FirebaseAuthException catch (e) {
      print(e);
      Utils.showSnackBar(e.message);
    }

    navigatorKey.currentState!.popUntil((route) => route.isFirst);
  }
}
