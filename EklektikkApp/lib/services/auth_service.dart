import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Connexion admin
  Future<void> loginAdmin(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw e.message ?? "Erreur de connexion";
    }
  }

  // Déconnexion
  Future<void> logout() async {
    await _auth.signOut();
  }
}