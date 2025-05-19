import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddClientPage extends StatefulWidget {
  @override
  _AddClientPageState createState() => _AddClientPageState();
}

class _AddClientPageState extends State<AddClientPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _smsCodeController = TextEditingController();

  bool _isLoading = false;
  bool _isPhoneVerified = false;
  String _errorMessage = '';
  String _verificationId = '';

  // Dropdown for user type
  String? _selectedUserType;
  final List<String> _userTypes = ["Étudiant", "Travailleur", "Entreprise"];

  final _formKey = GlobalKey<FormState>();

  Future<void> _sendPhoneVerification() async {
    // Placeholder for sending SMS verification
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Code de vérification envoyé (placeholder).")),
    );
  }

  Future<void> _verifySmsCode() async {
    // Placeholder for verifying SMS code
    setState(() {
      _isPhoneVerified = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Numéro de téléphone vérifié (placeholder).")),
    );
  }

  Future<void> addClient(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_isPhoneVerified) {
      setState(() {
        _errorMessage = "Veuillez vérifier votre numéro de téléphone avant de continuer.";
      });
      return;
    }

    if (_selectedUserType == null) {
      setState(() {
        _errorMessage = "Veuillez sélectionner un type d'utilisateur.";
      });
      return;
    }

    // Vérification de la correspondance des mots de passe
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = "Les mots de passe ne correspondent pas";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Check if the email already exists
      List<String> methods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(_emailController.text.trim());
      if (methods.isNotEmpty) {
        setState(() {
          _errorMessage = "Cet email est déjà utilisé.";
        });
        return;
      }

      // Create the user in Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Save user data to Firestore
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'type': 'client',
        'category': _selectedUserType,
        'verified': false,
        'subscription': 'inactif',
        'payments': [],
      });

      // Send verification email
      await userCredential.user!.sendEmailVerification();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Client ajouté avec succès")),
      );

      // Clear all fields
      _emailController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
      _nameController.clear();
      _phoneController.clear();
      _smsCodeController.clear();
      setState(() {
        _selectedUserType = null;
        _isPhoneVerified = false;
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = "Erreur : ${e.message}";
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Une erreur s'est produite";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ajouter un Client"),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Ajouter un nouveau client",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                SizedBox(height: 24),

                // Nom
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: "Nom",
                    labelStyle: TextStyle(color: Colors.blueAccent),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Veuillez entrer votre nom.";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Email
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: "Email",
                    labelStyle: TextStyle(color: Colors.blueAccent),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Veuillez entrer un email.";
                    }
                    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                    if (!emailRegex.hasMatch(value)) {
                      return "Veuillez entrer un email valide.";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Téléphone
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: "Numéro de téléphone (+33XXXXXXXXX)",
                    labelStyle: TextStyle(color: Colors.blueAccent),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Veuillez entrer un numéro de téléphone.";
                    }
                    final phoneRegex = RegExp(r'^\+33\d{9}$');
                    if (!phoneRegex.hasMatch(value)) {
                      return "Veuillez entrer un numéro de téléphone valide.";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _sendPhoneVerification,
                  child: Text("Envoyer le code de vérification"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                  ),
                ),
                SizedBox(height: 8),
                TextFormField(
                  controller: _smsCodeController,
                  decoration: InputDecoration(
                    labelText: "Code de vérification",
                    hintText: "Vérification par SMS en travail",
                    labelStyle: TextStyle(color: Colors.blueAccent),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                    ),
                  ),
                ),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _verifySmsCode,
                  child: Text("Vérifier le code"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                  ),
                ),
                SizedBox(height: 16),

                // Type d'utilisateur
                DropdownButtonFormField<String>(
                  value: _selectedUserType,
                  items: _userTypes.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedUserType = value;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: "Type d'utilisateur",
                    labelStyle: TextStyle(color: Colors.blueAccent),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null) {
                      return "Veuillez sélectionner un type d'utilisateur.";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Mot de passe
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: "Mot de passe",
                    labelStyle: TextStyle(color: Colors.blueAccent),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                    ),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Veuillez entrer un mot de passe.";
                    }
                    if (value.length < 6) {
                      return "Le mot de passe doit contenir au moins 6 caractères.";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Confirmation mot de passe
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: "Confirmer le mot de passe",
                    labelStyle: TextStyle(color: Colors.blueAccent),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                    ),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 24),

                // Affichage des erreurs
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      _errorMessage,
                      style: TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  ),

                // Bouton d'ajout
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                  onPressed: () => addClient(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    "Ajouter Client",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}