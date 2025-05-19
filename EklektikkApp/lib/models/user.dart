import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String id;
  final String name;
  final String email;
  final String type;
  final bool verified;
  final String subscription;
  final List<Map<String, dynamic>> payments;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.type,
    this.verified = false,
    this.subscription = 'inactif',
    this.payments = const [],
  });

  // Création d'un utilisateur depuis Firestore
  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppUser(
      id: doc.id,
      name: data['name'],
      email: data['email'],
      type: data['type'],
      verified: data['verified'] ?? false,
      subscription: data['subscription'] ?? 'inactif',
      payments: List<Map<String, dynamic>>.from(data['payments'] ?? []),
    );
  }

  // Conversion d'un utilisateur en format Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'type': type,
      'verified': verified,
      'subscription': subscription,
      'payments': payments,
    };
  }
}
