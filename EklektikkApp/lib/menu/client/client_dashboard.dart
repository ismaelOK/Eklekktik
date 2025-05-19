import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClientDashboardPage extends StatefulWidget {
  const ClientDashboardPage({super.key});

  @override
  _ClientDashboardPageState createState() => _ClientDashboardPageState();
}

class _ClientDashboardPageState extends State<ClientDashboardPage> {
  String _userName = "";
  String _subscriptionStatus = "";
  String _userEmail = "";
  List<Map<String, dynamic>> _payments = [];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Fonction pour récupérer les données de l'utilisateur connecté depuis Firestore
  Future<void> _fetchUserData() async {
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
            _userName = userData['name'];
            _subscriptionStatus = userData['subscription'];
            _userEmail = userData['email'];
            _payments = List<Map<String, dynamic>>.from(userData['payments'] ?? []);
          });
        }
      }
    } catch (e) {
      // Gérer l'erreur si la récupération des données échoue
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de la récupération des données : $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de bord Client'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/login'); // Redirige vers la page de connexion après déconnexion
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Afficher les informations de l'utilisateur
            Text(
              "Bienvenue, $_userName",
              style: TextStyle(fontSize: 24, fontFamily: 'MontserratBold'),
            ),
            const SizedBox(height: 20),
            Text(
              "Email: $_userEmail",
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            Text(
              "Abonnement: $_subscriptionStatus",
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 40),

            // Bouton pour gérer l'abonnement
            ElevatedButton(
              onPressed: () {
                _manageSubscription();
              },
              child: const Text("Gérer mon abonnement"),
            ),
            const SizedBox(height: 20),

            // Affichage de l'historique des paiements
            const Text(
              "Historique des paiements",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _payments.isEmpty
                ? Text("Aucun paiement effectué")
                : Column(
              children: _payments.map((payment) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text("Montant: ${payment['amount']}"),
                    subtitle: Text("Date: ${payment['date']}"),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 40),

            // Bouton pour accéder à la page du profil utilisateur
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()), // Page de profil
                );
              },
              child: const Text("Voir mon profil"),
            ),
          ],
        ),
      ),
    );
  }

  // Fonction pour gérer l'abonnement
  Future<void> _manageSubscription() async {
    // Ouvre une fenêtre pour que l'utilisateur puisse gérer son abonnement.
    // Tu peux afficher une boîte de dialogue ou rediriger vers une autre page.
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Gérer l'abonnement"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Actuel: $_subscriptionStatus"),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .update({
                    'subscription': 'actif', // Modifie ici l'abonnement
                  });

                  // Rafraîchit les données
                  _fetchUserData();
                  Navigator.pop(context); // Ferme la boîte de dialogue
                },
                child: Text("Passer à actif"),
              ),
              ElevatedButton(
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .update({
                    'subscription': 'inactif', // Modifie ici l'abonnement
                  });

                  // Rafraîchit les données
                  _fetchUserData();
                  Navigator.pop(context); // Ferme la boîte de dialogue
                },
                child: Text("Passer à inactif"),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Page de profil de l'utilisateur (exemple)
class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  // Fonction pour récupérer les données de profil de l'utilisateur
  Future<void> _fetchProfileData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userSnapshot.exists) {
        final userData = userSnapshot.data() as Map<String, dynamic>;
        setState(() {
          _nameController.text = userData['name'];
          _emailController.text = userData['email'];
        });
      }
    }
  }

  // Fonction pour mettre à jour les données du profil
  Future<void> _updateProfile() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Profil mis à jour")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Mon Profil")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: "Nom"),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: "Email"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateProfile,
              child: Text("Mettre à jour"),
            ),
          ],
        ),
      ),
    );
  }
}
