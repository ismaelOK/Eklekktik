import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'ClientPaymentPage.dart';

class UserDetailsPage extends StatelessWidget {
  final String userId;

  UserDetailsPage({required this.userId});

  Future<void> _deleteUser(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmer la suppression"),
        content: const Text("Êtes-vous sûr de vouloir supprimer définitivement ce client ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Supprimer", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // Supprimer d'abord le compte d'authentification (si existant)
        try {
          await FirebaseAuth.instance.deleteUser(userId);
        } catch (e) {
          debugPrint("Pas de compte auth à supprimer ou erreur: $e");
        }

        // Supprimer le document Firestore
        await FirebaseFirestore.instance.collection('users').doc(userId).delete();

        // Afficher un message de succès
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Client supprimé avec succès")),
        );

        // Retourner à la page précédente
        Navigator.pop(context);
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur lors de la suppression: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Détails de l'utilisateur"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => UserDetailsPage(userId: userId),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _deleteUser(context),
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Erreur: ${snapshot.error}"));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Utilisateur non trouvé"));
          }

          var user = snapshot.data!;
          var userData = user.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Carte d'information principale
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userData['name'] ?? 'Non spécifié',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(Icons.email, userData['email'] ?? 'Non spécifié'),
                        _buildInfoRow(Icons.phone, userData['phone'] ?? 'Non spécifié'),
                        _buildInfoRow(Icons.person, "Type: ${userData['category'] ?? 'Non spécifié'}"),
                        _buildInfoRow(Icons.verified_user,
                            "Vérifié: ${userData['verified'] == true ? 'Oui' : 'Non'}",
                            color: userData['verified'] == true ? Colors.green : Colors.orange),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Carte d'abonnement
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Abonnement",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        _buildInfoRow(Icons.subscriptions,
                            "Statut: ${userData['subscription']?.toString().toUpperCase() ?? 'INACTIF'}",
                            color: _getSubscriptionColor(userData['subscription'])),
                        if (userData['subscriptionStart'] != null)
                          _buildInfoRow(Icons.calendar_today,
                              "Début: ${DateFormat('dd/MM/yyyy').format(userData['subscriptionStart'].toDate())}"),
                        if (userData['subscriptionEnd'] != null)
                          _buildInfoRow(Icons.event_available,
                              "Fin: ${DateFormat('dd/MM/yyyy').format(userData['subscriptionEnd'].toDate())}"),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Carte de paiement
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Paiements",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ClientPaymentPage(userId: userId),
                                  ),
                                );
                              },
                              child: const Text("Gérer"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        if (userData['payments'] != null && (userData['payments'] as List).isNotEmpty)
                          ..._buildPaymentList(userData['payments']),
                        if (userData['payments'] == null || (userData['payments'] as List).isEmpty)
                          const Text("Aucun paiement enregistré", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, {Color color = Colors.black}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: TextStyle(color: color))),
        ],
      ),
    );
  }

  List<Widget> _buildPaymentList(List<dynamic> payments) {
    return payments.map<Widget>((payment) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            Icon(
              payment['status'] == 'paid' ? Icons.check_circle : Icons.pending,
              color: payment['status'] == 'paid' ? Colors.green : Colors.orange,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("${payment['amount']}€ - ${payment['description'] ?? ''}"),
                  if (payment['date'] != null)
                    Text(
                      DateFormat('dd/MM/yyyy').format(payment['date'].toDate()),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Color _getSubscriptionColor(String? subscription) {
    switch (subscription?.toLowerCase()) {
      case 'actif':
        return Colors.green;
      case 'inactif':
        return Colors.red;
      case 'en attente':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}

extension on FirebaseAuth {
  deleteUser(String userId) {}
}