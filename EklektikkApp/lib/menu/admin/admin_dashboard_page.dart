import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'addAdminPage.dart'; // Ajouter un admin
import 'addClientPage.dart'; // Ajouter un client
import 'admin_list_page.dart'; // Gérer les admins
import 'admin_client_list.dart'; // Liste des clients

class AdminDashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tableau de bord Admin"),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Titre principal
            Text(
              "Bienvenue dans votre tableau de bord",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            SizedBox(height: 30),

            // Card pour chaque option (ajouter un client, ajouter un admin)
            _buildCard(
              context,
              "Ajouter un client",
              Icons.person_add,
              AddClientPage(),
            ),
            SizedBox(height: 15),
            _buildCard(
              context,
              "Ajouter un admin",
              Icons.admin_panel_settings,
              AddAdminPage(),
            ),
            SizedBox(height: 15),
            _buildCard(
              context,
              "Gérer les admins",
              Icons.supervised_user_circle,
              AdminListPage(),
            ),
            SizedBox(height: 15),
            _buildCard(
              context,
              "Gérer les clients",
              Icons.group,
              AdminClientListPage(),
            ),
          ],
        ),
      ),
    );
  }

  // Méthode pour construire chaque Card avec animation de transition
  Widget _buildCard(BuildContext context, String title, IconData icon, Widget page) {
    return GestureDetector(
      onTap: () {
        // Animation de transition fluide
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => page,
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              var begin = Offset(1.0, 0.0);
              var end = Offset.zero;
              var curve = Curves.easeInOut;
              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              var offsetAnimation = animation.drive(tween);

              return SlideTransition(position: offsetAnimation, child: child);
            },
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 5,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 10,
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: Colors.blueAccent,
                size: 30,
              ),
              SizedBox(width: 15),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.blueAccent,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
