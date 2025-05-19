import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// import 'admin_client_list.dart';
import 'admin_client_list.dart';
import 'admin_dashboard_page.dart';
import 'admin_profile_page.dart';
// import 'admin_profile_page.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return LayoutBuilder(
      builder: (context, constraints) {
        bool isTablet = constraints.maxWidth >= 600;

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              "Accueil Administrateur",
              style: TextStyle(
                fontFamily: 'MontserratBold',
                fontSize: 24,
                color: Colors.white,
              ),
            ),
            backgroundColor: Colors.blue,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          drawer: isTablet ? null : AppDrawer(user: user),
          body: Row(
            children: [
              if (isTablet)
                SizedBox(
                  width: 250,
                  child: AppDrawer(user: user),
                ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          "Bienvenue sur votre espace Administrateur",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'MontserratBold',
                            fontSize: 30,
                          ),
                        ),
                        Image.asset("lib/assets/images/logo.png"),
                        const SizedBox(height: 20),
                        const Text(
                          "Gérez vos clients, votre profil et accédez au tableau de bord.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 15, fontFamily: 'Montserrat'),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => AdminProfilePage()),
                            );
                          },
                          child: const Text("Mon Profil Administrateur", style: TextStyle(color: Colors.white)),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => AdminDashboardPage()),
                            );
                          },
                          child: const Text("Tableau de bord", style: TextStyle(color: Colors.white)),
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

class AppDrawer extends StatelessWidget {
  final User? user;
  const AppDrawer({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Menu Admin',
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontFamily: 'MontserratBold',
              ),
            ),
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.account_circle,
            text: 'Mon Profil',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AdminProfilePage())),
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.dashboard,
            text: 'Tableau de bord',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AdminDashboardPage())),
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.group,
            text: 'Gérer les Clients',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AdminClientListPage())),
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.exit_to_app,
            text: 'Se déconnecter',
            onTap: () => _showLogoutDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(text, style: const TextStyle(fontFamily: 'Montserrat')),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmation'),
        content: const Text('Voulez-vous vraiment vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
            },
            child: const Text('Oui'),
          ),
        ],
      ),
    );
  }
}
