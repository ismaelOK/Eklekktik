import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'verify_email_page.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _isLoading = false;
  bool _showPassword = false;

  final _formKey = GlobalKey<FormState>();

  // Dropdown for user category
  String? _selectedUserCategory;
  final List<String> _userCategories = ["Étudiant", "Travailleur", "Entreprise"];

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedUserCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Veuillez sélectionner une catégorie")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Vérification de l'email existant
      List<String> methods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(_emailController.text.trim());
      if (methods.isNotEmpty) {
        throw FirebaseAuthException(code: 'email-already-in-use');
      }

      // Création de l'utilisateur
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Création des documents dans Firestore
      final batch = FirebaseFirestore.instance.batch();
      final userRef = FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid);
      final subscriptionRef = FirebaseFirestore.instance.collection('subscriptions').doc(userCredential.user!.uid);

      // Document utilisateur
      batch.set(userRef, {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'type': 'client', // Tous les utilisateurs sont des clients
        'category': _selectedUserCategory, // Conserve la catégorie choisie
        'verified': false,
        'phoneVerified': false,
        'subscription': 'inactif',
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
        'profileCompleted': false,
        'payments': [],
      });

      // Document abonnement
      batch.set(subscriptionRef, {
        'userId': userCredential.user!.uid,
        'plan': 'none',
        'startDate': null,
        'endDate': null,
        'status': 'inactif',
        'autoRenew': false,
      });

      await batch.commit();

      // Envoyer l'email de vérification
      await userCredential.user!.sendEmailVerification();

      // Redirection
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => VerifyEmailPage(user: userCredential.user!)),
      );

    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_getErrorMessage(e.code))),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de l'inscription: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use': return "Cet email est déjà utilisé";
      case 'weak-password': return "Mot de passe trop faible";
      default: return "Erreur lors de l'inscription";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Inscription")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Nom complet",
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return "Veuillez entrer votre nom";
                  return null;
                },
              ),
              SizedBox(height: 16),

              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) return "Veuillez entrer un email";
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value)) return "Email invalide";
                  return null;
                },
              ),
              SizedBox(height: 16),

              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: "Téléphone (+33XXXXXXXXX)",
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) return "Veuillez entrer un numéro";
                  if (!RegExp(r'^\+33\d{9}$').hasMatch(value)) return "Format: +33XXXXXXXXX";
                  return null;
                },
              ),
              SizedBox(height: 8),
              Text(
                "La vérification SMS sera ajoutée ultérieurement",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _selectedUserCategory,
                items: _userCategories.map((category) => DropdownMenuItem(
                  value: category,
                  child: Text(category),
                )).toList(),
                onChanged: (value) => setState(() => _selectedUserCategory = value),
                decoration: InputDecoration(
                  labelText: "Catégorie d'utilisateur",
                  prefixIcon: Icon(Icons.category),
                ),
                validator: (value) => value == null ? "Sélectionnez une catégorie" : null,
              ),
              SizedBox(height: 16),

              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: "Mot de passe",
                  prefixIcon: Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(_showPassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _showPassword = !_showPassword),
                  ),
                ),
                obscureText: !_showPassword,
                validator: (value) {
                  if (value == null || value.isEmpty) return "Veuillez entrer un mot de passe";
                  if (value.length < 6) return "6 caractères minimum";
                  return null;
                },
              ),
              SizedBox(height: 24),

              if (_isLoading)
                CircularProgressIndicator()
              else
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _signup,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text("S'INSCRIRE", style: TextStyle(fontSize: 16)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}