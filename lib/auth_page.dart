import 'package:firebase_test/login_widget.dart';
import 'package:firebase_test/signup_widget.dart';
import 'package:flutter/material.dart';

class AuthPage extends StatefulWidget{
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage>{
  bool isLogin = true;

  @override
  Widget build(BuildContext context) =>
    isLogin ? LoginWidget(onClickedSignUp: toggle) : SignUpWidget(onClickedSignIn: toggle);

  void toggle() => setState(() {
    isLogin = !isLogin;
  });
}