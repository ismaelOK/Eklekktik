import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Adhesion extends StatefulWidget {
  const Adhesion({super.key});

  @override
  State<Adhesion> createState() => _AdhesionState();
}

class _AdhesionState extends State<Adhesion> {
  String? userCategory;
  String? adhesionPrice;
  List<Map<String, String>> abonnementOptions = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchUserCategory();
  }

  Future<void> _fetchUserCategory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data();
        setState(() {
          userCategory = data?['category'] as String?;
          if (userCategory != null) {
            _setPricing(userCategory);
          }
        });
      }
    }
  }

  void _setPricing(String? category) {
    switch (category) {
      case "Étudiant":
        adhesionPrice = "Gratuit";
        abonnementOptions = [
          {"label": "Étudiants", "price": "Gratuit"},
        ];
        break;
      case "Travailleur":
        adhesionPrice = "50€";
        abonnementOptions = [
          {"label": "Travailleurs", "price": "56€/mois"},
        ];
        break;
      case "Entreprise":
        adhesionPrice = "200€";
        abonnementOptions = [
          {"label": "Petites entreprises (< 50 salariés)", "price": "1200€/mois"},
          {"label": "Grandes entreprises (50+ salariés)", "price": "2000€/mois"},
        ];
        break;
      default:
        adhesionPrice = "Non défini";
        abonnementOptions = [
          {"label": "Non défini", "price": "Non défini"},
        ];
    }
  }

  Future<void> _handleMembership({required bool isSubscription}) async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      await _updateMembershipStatus(isSubscription: isSubscription);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isSubscription ? 'Abonnement enregistré!' : 'Adhésion enregistrée!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateMembershipStatus({required bool isSubscription}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final now = DateTime.now();

    if (isSubscription) {
      await userRef.update({
        'subscriptionStatus': 'active',
        'subscriptionStartDate': now,
        'subscriptionEndDate': now.add(const Duration(days: 30)),
        'lastPaymentDate': now,
        'subscriptionType': userCategory,
      });
    } else {
      await userRef.update({
        'membershipStatus': 'active',
        'membershipStartDate': now,
        'membershipEndDate': now.add(const Duration(days: 365)),
        'lastPaymentDate': now,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Adhésion et Abonnement"),
      ),
      body: userCategory == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Catégorie de compte : $userCategory",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Tarification de l'adhésion",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Prix : $adhesionPrice",
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "L'association Eklektikk a pour mission de fournir des services d'accompagnement général en fonction de la situation et des besoins de ses adhérents.",
                            style: TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _isLoading 
                              ? null 
                              : () => _handleMembership(isSubscription: false),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                            child: _isLoading 
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(color: Colors.white)
                                )
                              : const Text("Rejoindre"),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Tarification des abonnements mensuels",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ...abonnementOptions.map((option) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                "${option['label']} : ${option['price']}",
                                style: const TextStyle(fontSize: 14),
                              ),
                            );
                          }).toList(),
                          const SizedBox(height: 10),
                          const Text(
                            "L'objectif du projet est de développer une application mobile permettant à l'association de gérer ses adhérents, de gérer les abonnements, et de fournir des services d'accompagnement virtuel adaptés à chaque catégorie d'adhérent.",
                            style: TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _isLoading 
                              ? null 
                              : () => _handleMembership(isSubscription: true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                            child: _isLoading 
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(color: Colors.white)
                                )
                              : const Text("S'abonner"),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}