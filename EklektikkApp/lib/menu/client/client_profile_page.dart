import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eklektikk/pages/login_page.dart';

class ClientProfilePage extends StatefulWidget {
  const ClientProfilePage({super.key});

  @override
  _ClientProfilePageState createState() => _ClientProfilePageState();
}

class _ClientProfilePageState extends State<ClientProfilePage> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userSnapshot.exists) {
          final userData = userSnapshot.data() as Map<String, dynamic>;
          setState(() {
            _nameController.text = userData['name'] ?? '';
            _phoneController.text = userData['phone'] ?? '';
            _emailController.text = user.email ?? '';
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors du chargement des données : $e")),
      );
    }
  }

  Future<void> _updateUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Handle email change
        if (_emailController.text.trim() != user.email) {
          await user.updateEmail(_emailController.text.trim());
          await user.sendEmailVerification();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Un email de vérification a été envoyé. Veuillez vérifier votre email.")),
          );
        }

        // Handle phone number change (you can implement phone verification here)
        if (_phoneController.text.trim() != user.phoneNumber) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Veuillez vérifier votre numéro de téléphone.")),
          );
          // Add phone verification logic here if needed
        }

        // Update Firestore data
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'name': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Informations mises à jour avec succès.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de la mise à jour des données : $e")),
      );
    } finally {
      setState(() {
        _isLoading = false;
        _isEditing = false;
      });
    }
  }

  Future<void> _resetPassword() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: user.email!);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Email de réinitialisation envoyé.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de la réinitialisation du mot de passe : $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
            child: const Text("Veuillez vous connecter"),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mon Profil"),
        backgroundColor: Colors.pink,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text(
              "Nom",
              style: TextStyle(fontSize: 16),
            ),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: "Entrez votre nom",
              ),
              readOnly: !_isEditing,
            ),
            const SizedBox(height: 16),
            const Text(
              "Email",
              style: TextStyle(fontSize: 16),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                hintText: "Entrez votre email",
              ),
              readOnly: !_isEditing,
            ),
            const SizedBox(height: 16),
            const Text(
              "Téléphone",
              style: TextStyle(fontSize: 16),
            ),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                hintText: "Entrez votre numéro de téléphone",
              ),
              readOnly: !_isEditing,
            ),
            const SizedBox(height: 24),
            if (_isEditing)
              ElevatedButton(
                onPressed: _isLoading ? null : _updateUserData,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Enregistrer les modifications"),
              )
            else
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isEditing = true;
                  });
                },
                child: const Text("Modifier les informations"),
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _resetPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text("Réinitialiser le mot de passe"),
            ),
          ],
        ),
      ),
    );
  }
}