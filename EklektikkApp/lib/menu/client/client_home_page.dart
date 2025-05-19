import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widjets/shared_drawer.dart';
import 'client_profile_page.dart';
import 'client_dashboard.dart';

class ClientHomePage extends StatelessWidget {
  const ClientHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return LayoutBuilder(
      builder: (context, constraints) {
        bool isTablet = constraints.maxWidth >= 600;

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              "Accueil Client",
              style: TextStyle(
                fontFamily: 'MontserratBold',
                fontSize: 24,
                color: Colors.white,
              ),
            ),
            backgroundColor: Colors.pink,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          drawer: isTablet ? null : SharedDrawer(user: user, isClientHomePage: true),
          body: Row(
            children: [
              if (isTablet)
                SizedBox(
                  width: 250,
                  child: SharedDrawer(user: user, isClientHomePage: true),
                ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          "Bienvenue sur votre espace Client",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'MontserratBold',
                            fontSize: 30,
                          ),
                        ),
                        Image.asset("lib/assets/images/logo.png"),
                        const SizedBox(height: 20),
                        const Text(
                          "Explorez vos options et gérez votre profil et votre tableau de bord.",
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
                              MaterialPageRoute(builder: (_) => const ClientProfilePage()),
                            );
                          },
                          child: const Text("Accéder à mon profil", style: TextStyle(color: Colors.white)),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pink,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ClientDashboardPage()),
                            );
                          },
                          child: const Text("Accéder au Tableau de bord", style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}