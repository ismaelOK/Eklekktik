import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:eklektikk/services/firestore_service.dart';
import 'package:eklektikk/models/user.dart';  // Assurez-vous que vous utilisez AppUser et pas User.

class UserProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<AppUser> _users = [];  // Modifié ici : Utilisation de AppUser au lieu de User
  String _searchQuery = '';

  // Liste des utilisateurs filtrée par la recherche
  List<AppUser> get users {
    return _users
        .where((user) => user.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  // Fonction pour obtenir la liste des utilisateurs en temps réel
  Stream<List<AppUser>> getUsersStream() {
    return _firestoreService.getUsers();
  }

  // Mettre à jour la liste des utilisateurs
  void updateUsers(List<AppUser> users) {
    _users = users;
    notifyListeners(); // Notifie les écouteurs que les données ont changé
  }

  // Mettre à jour la requête de recherche
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Fonction pour ajouter un utilisateur
  void addUser(String name, String email, String subscription) async {
    try {
      await _firestoreService.addUser(AppUser(
        id: '', // L'id sera généré automatiquement par Firestore
        name: name,
        email: email,
        type: 'user',
        verified: false,
        subscription: subscription,
        payments: [], // Historique des paiements vide
      ));
      // Recharge les utilisateurs après l'ajout
      _loadUsers();
    } catch (e) {
      print("Erreur lors de l'ajout de l'utilisateur : $e");
    }
  }

  // Méthode pour charger les utilisateurs
  Future<void> _loadUsers() async {
    var usersStream = _firestoreService.getUsers();
    usersStream.listen((users) {
      _users = users;
      notifyListeners(); // Notifie l'interface pour mettre à jour l'état
    });
  }

  // Variables et méthodes pour l'email utilisateur
  String? _userEmail;

  String? get userEmail => _userEmail;

  void setUserEmail(String email) {
    _userEmail = email;
    notifyListeners();
  }
}
