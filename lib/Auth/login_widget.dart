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
        buildBackgroundImage(),
        buildForm(context),
      ],
    );
  }

  Widget buildBackgroundImage() {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Image.asset(
        isSelected ? 'assets/images/YddeF.gif' : 'assets/images/Ydde.gif',
        fit: BoxFit.cover,
      ),
    );
  }

  Widget buildForm(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          buildSwitchThemeButton(),
          const SizedBox(height: 20),
          buildEmailField(),
          const SizedBox(height: 10),
          buildPasswordField(),
          const SizedBox(height: 20),
          buildSignInButton(),
          const SizedBox(height: 24),
          buildGoogleSignInButton(),
          const SizedBox(height: 24),
          buildForgotPasswordText(context),
          const SizedBox(height: 24),
          buildSignUpText(),
        ],
      ),
    );
  }

  Widget buildSwitchThemeButton() {
    return ElevatedButton(
      onPressed: () => setState(() => isSelected = !isSelected),
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(
            isSelected ? Colors.purpleAccent : Colors.indigo),
      ),
      child: const Icon(Icons.switch_access_shortcut, size: 20),
    );
  }

  Widget buildEmailField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
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

  Widget buildPasswordField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: TextFormField(
        controller: passwordController,
        obscureText: true,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Colors.blue, width: 2.0),
          ),
          labelText: 'Mot de passe',
        ),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (value) => value != null && value.length < 8
            ? 'Le mot de passe doit contenir au minimum 8 caractères'
            : null,
      ),
    );
  }

  Widget buildSignInButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 120),
      child: ElevatedButton.icon(
        onPressed: _signIn,
        icon: const Icon(Icons.play_arrow, size: 32),
        label: const Text('Jouer', style: TextStyle(fontSize: 24)),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Colors.purpleAccent : Colors.indigo,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          minimumSize: const Size.fromHeight(40),
        ),
      ),
    );
  }

  Widget buildGoogleSignInButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 90),
      child: ElevatedButton.icon(
        onPressed: () async => await GoogleTest().signInWithGoogle(),
        icon: const Icon(
          Icons.g_mobiledata_outlined,
          size: 32,
          color: Colors.black,
        ),
        label: const Text('Connexion Google',
            style: TextStyle(fontSize: 16, color: Colors.black)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          minimumSize: const Size.fromHeight(20),
        ),
      ),
    );
  }

  Widget buildForgotPasswordText(BuildContext context) {
    return GestureDetector(
      child: const Text(
        'Mot de passe oublié?',
        style: TextStyle(
            decoration: TextDecoration.underline,
            color: Colors.white,
            fontSize: 14),
      ),
      onTap: () => Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => ForgotPasswordPage())),
    );
  }

  Widget buildSignUpText() {
    return RichText(
      text: TextSpan(
        children: [
          const TextSpan(
            text: 'Pas de compte ?   ',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          TextSpan(
            recognizer: TapGestureRecognizer()..onTap = widget.onClickedSignUp,
            text: 'Inscription',
            style: const TextStyle(
                decoration: TextDecoration.underline,
                color: Colors.white,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Future _signIn() async {
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
