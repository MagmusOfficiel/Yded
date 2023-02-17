import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatelessWidget {
  final User user;
  final VoidCallback onSignOut;

  const ProfilePage({Key? key, required this.user, required this.onSignOut})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          backgroundImage: NetworkImage(user.photoURL!),
          radius: 50,
        ),
        SizedBox(height: 16),
        Text(
          user.displayName!,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Text(
          user.email!,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 24),
        ElevatedButton(
          onPressed: onSignOut,
          child: Text('Sign out'),
        ),
      ],
    );
  }
}