import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widjets/shared_drawer.dart';
import 'infos.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "EKLEKTIKK",
          style: TextStyle(
            fontFamily: 'MontserratBold',
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.pink,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: SharedDrawer(user: user),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Bienvenue sur l'application EKLEKTIKK",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'MontserratBold',
                  fontSize: 30,
                ),
              ),
              Image.asset("lib/assets/images/logo.png"),
              const SizedBox(height: 20),
              const Text(
                "EKLEKTIKK est une plateforme qui aide les demandeurs d'emploi et les créateurs d'entreprises à se connecter efficacement.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, fontFamily: 'Montserrat'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const Infos()),
                  );
                },
                child: const Text("En savoir plus", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}