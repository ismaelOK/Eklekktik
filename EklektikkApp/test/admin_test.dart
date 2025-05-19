import 'package:eklektikk/pages/login_page.dart';
import 'package:eklektikk/pages/payement_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:eklektikk/menu/admin/addAdminPage.dart';

void main() {
  // Initialise Firebase avant de lancer les tests
  setUpAll(() async {
    await Firebase.initializeApp();
  });

  // Test de la connexion admin
  testWidgets('Connexion admin réussie', (WidgetTester tester) async {
    // Créer une instance de la page Login
    await tester.pumpWidget(MaterialApp(home: LoginPage()));

    // Chercher les champs de texte pour l'email et le mot de passe
    final emailField = find.byKey(Key('email_field'));
    final passwordField = find.byKey(Key('password_field'));
    final loginButton = find.byKey(Key('login_button'));

    // Vérifier que les champs sont présents
    expect(emailField, findsOneWidget);
    expect(passwordField, findsOneWidget);
    expect(loginButton, findsOneWidget);

    // Simuler la saisie de l'email et du mot de passe
    await tester.enterText(emailField, 'admin@example.com');
    await tester.enterText(passwordField, 'password123');

    // Simuler le clic sur le bouton de connexion
    await tester.tap(loginButton);
    await tester.pumpAndSettle(); // Attendre que l'animation de navigation se termine

    // Vérifier que la navigation vers la page admin a eu lieu (par exemple, un titre spécifique)
    expect(find.text('Tableau de bord Admin'), findsOneWidget);
  });

  // Test de l'ajout d'un utilisateur
  testWidgets('Ajout d\'un utilisateur', (WidgetTester tester) async {
    // Créer une instance de la page AddUser

    // Chercher les champs de texte pour le nom et l'email
    final nameField = find.byKey(Key('name_field'));
    final emailField = find.byKey(Key('email_field'));
    final addButton = find.byKey(Key('add_button'));

    // Vérifier que les champs et le bouton sont présents
    expect(nameField, findsOneWidget);
    expect(emailField, findsOneWidget);
    expect(addButton, findsOneWidget);

    // Simuler la saisie du nom et de l'email
    await tester.enterText(nameField, 'Jean Dupont');
    await tester.enterText(emailField, 'jean.dupont@email.com');

    // Simuler le clic sur le bouton "Ajouter"
    await tester.tap(addButton);
    await tester.pumpAndSettle(); // Attendre que l'animation se termine

    // Vérifier que le message de succès est affiché
    expect(find.text('Utilisateur ajouté'), findsOneWidget);
  });

  // Test de l'accès à la page de paiement
  testWidgets('Accès à la page de paiement', (WidgetTester tester) async {
    // Créer une instance de la page de paiement
    //await tester.pumpWidget(MaterialApp(home: PaymentPage(amount: 50.0, currency: 'EUR')));

    // Vérifier que le montant et la devise sont bien affichés
    expect(find.text('Montant: 50.0 EUR'), findsOneWidget);

    // Simuler le clic sur un bouton de paiement (s'il existe)
    final payButton = find.byKey(Key('pay_button'));
    if (payButton != null) {
      await tester.tap(payButton);
      await tester.pumpAndSettle();

      // Vérifier que le paiement a été effectué
      expect(find.text('Paiement réussi'), findsOneWidget);
    }
  });
}
