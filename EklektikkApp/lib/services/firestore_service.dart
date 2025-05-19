import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Récupérer tous les utilisateurs
  Stream<List<AppUser>> getUsers() {
    return _db.collection('users').snapshots().map(
          (snapshot) => snapshot.docs.map((doc) => AppUser.fromFirestore(doc)).toList(),
    );
  }

  // Ajouter un paiement à un utilisateur
  Future<void> addPayment(String userId, Map<String, dynamic> payment) async {
    final userRef = _db.collection('users').doc(userId);
    await userRef.update({
      'payments': FieldValue.arrayUnion([payment]),
    });
  }

  // Mettre à jour un utilisateur
  Future<void> updateUser(String userId, Map<String, dynamic> updates) async {
    final userRef = _db.collection('users').doc(userId);
    await userRef.update(updates);
  }

  // Marquer un paiement comme payé
  Future<void> markPaymentAsPaid(String userId) async {
    final userRef = _db.collection('users').doc(userId);
    await userRef.update({
      'subscription': 'actif', 
    });
  }



  // Ajouter un utilisateur dans Firestore
  Future<void> addUser(AppUser user) async {
  try {
  final userRef = _db.collection('users').doc();  
  await userRef.set(user.toFirestore());  
  } catch (e) {
  print("Erreur lors de l'ajout de l'utilisateur dans Firestore : $e");
  }
  }

  


}
