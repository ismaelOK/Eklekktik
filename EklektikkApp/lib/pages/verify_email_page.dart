import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eklektikk/menu/client/client_home_page.dart';

class VerifyEmailPage extends StatefulWidget {
  final User user; // Pass the User object, not UserCredential

  const VerifyEmailPage({required this.user, Key? key}) : super(key: key);

  @override
  _VerifyEmailPageState createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  bool _isLoading = false;

  Future<void> _checkEmailVerified() async {
  setState(() => _isLoading = true);

  try {
    // Reload the user to check if the email is verified
    await widget.user.reload();
    final updatedUser = FirebaseAuth.instance.currentUser;

    if (updatedUser != null && updatedUser.emailVerified) {
      // Update Firestore to mark user as verified
      await FirebaseFirestore.instance
          .collection('users')
          .doc(updatedUser.uid)
          .update({'verified': true});

      // Redirect to the main page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ClientHomePage(), // Redirect to ClientHomePage
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("L'email n'est pas encore vérifié. Veuillez réessayer.")),
      );
    }
  } catch (e) {
    print("Erreur: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Erreur: $e")),
    );
  } finally {
    setState(() => _isLoading = false);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Vérification Email")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Vérifiez votre email et cliquez ci-dessous."),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _checkEmailVerified,
                    child: Text("J'ai vérifié mon email"),
                  ),
          ],
        ),
      ),
    );
  }
}