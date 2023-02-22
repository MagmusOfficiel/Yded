import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:yded/Utils/utils.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:yded/Profil/forgot_password_page.dart';
import 'package:yded/main.dart';
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
  bool isSelected = false;
  late final _fond1;
  late final _fond2;

  @override
  void initState() {
    super.initState();
    _fond1 = 'https://www.eddy-weber.fr/Ydde.gif';
    _fond2 = 'https://www.eddy-weber.fr/YddeF.gif';
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Image.network(
            (isSelected == false) ? _fond1 : _fond2,
            fit: BoxFit.cover,
          ),
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
              const SizedBox(height: 10),
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
                  padding: const EdgeInsets.only(right: 120, left: 120),
                  child: ElevatedButton.icon(
                    onPressed: signIn,
                    icon: const Icon(Icons.play_arrow, size: 32),
                    label: const Text('Jouer', style: TextStyle(fontSize: 24)),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: (isSelected == true)
                            ? Colors.purpleAccent
                            : Colors.indigo,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0)),
                        minimumSize: const Size.fromHeight(40)),
                  )),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.only(right: 90, left: 90),
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await GoogleTest().signInWithGoogle();
                  },
                  icon: const Icon(
                    Icons.g_mobiledata_outlined,
                    size: 32,
                    color: Colors.black,
                  ),
                  label: const Text('Connexion Google',
                      style: TextStyle(fontSize: 16, color: Colors.black)),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(20)),
                ),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                child: const Text(
                  'Mot de passe oublié?',
                  style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: Colors.white,
                      fontSize: 14),
                ),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ForgotPasswordPage())),
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
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      text: 'Pas de compte ?   ')),
            ],
          ),
        )
      ],
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
