import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'EditAdminProfilePage.dart';

class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({super.key});

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  final User? user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic> adminData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAdminData();
  }

  Future<void> _loadAdminData() async {
    if (user == null) return;

    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('admins')  // Utilisez 'users' si vous préférez
          .doc(user!.uid)
          .get();

      if (doc.exists) {
        setState(() {
          adminData = doc.data() as Map<String, dynamic>;
        });
      } else {
        // Créer un profil admin par défaut si inexistant
        await _createDefaultAdminProfile();
      }
    } catch (e) {
      debugPrint("Erreur de chargement: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _createDefaultAdminProfile() async {
    final defaultData = {
      'name': 'Administrateur',
      'email': user!.email,
      'phone': '',
      'role': 'admin',
      'createdAt': FieldValue.serverTimestamp(),
      'lastLogin': FieldValue.serverTimestamp(),
    };

    await FirebaseFirestore.instance
        .collection('admins')
        .doc(user!.uid)
        .set(defaultData);

    setState(() {
      adminData = defaultData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Profil Administrateur",
          style: TextStyle(
            fontFamily: 'MontserratBold',
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue,
              backgroundImage: adminData['photoUrl'] != null
                  ? NetworkImage(adminData['photoUrl'])
                  : null,
              child: adminData['photoUrl'] == null
                  ? const Icon(Icons.admin_panel_settings,
                  size: 50, color: Colors.white)
                  : null,
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                adminData['name'] ?? 'Administrateur',
                style: const TextStyle(
                  fontSize: 22,
                  fontFamily: 'MontserratBold',
                ),
              ),
            ),
            Center(
              child: Text(
                user?.email ?? '',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const Text(
              "Informations du compte",
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'MontserratBold',
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 10),
            _buildInfoTile(
              Icons.phone,
              'Téléphone',
              adminData['phone']?.isNotEmpty == true
                  ? adminData['phone']
                  : 'Non renseigné',
            ),
            _buildInfoTile(
              Icons.email,
              'Email',
              user?.email ?? 'Non renseigné',
            ),
            _buildInfoTile(
              Icons.admin_panel_settings,
              'Rôle',
              adminData['role']?.toString().toUpperCase() ?? 'ADMIN',
            ),
            _buildInfoTile(
              Icons.calendar_today,
              'Membre depuis',
              adminData['createdAt'] != null
                  ? _formatDate(adminData['createdAt'])
                  : 'Date inconnue',
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditAdminProfilePage(
                      adminData: adminData,
                      onProfileUpdated: _loadAdminData,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.edit),
              label: const Text("Modifier le profil"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title, style: const TextStyle(fontFamily: 'Montserrat')),
      subtitle: Text(subtitle,
          style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'Inconnu';
    if (date is Timestamp) {
      return DateFormat('dd/MM/yyyy').format(date.toDate());
    }
    return 'Inconnu';
  }
}