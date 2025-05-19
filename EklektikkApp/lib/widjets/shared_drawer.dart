import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../menu/admin/adminHomePage.dart';
import '../menu/admin/admin_client_list.dart';
import '../menu/admin/admin_profile_page.dart';
import '../menu/client/client_home_page.dart';
import '../menu/client/client_dashboard.dart';
import '../menu/client/client_profile_page.dart';
import '../menu/client/client_subscription_page.dart';
import '../pages/infos.dart';
import '../pages/login_page.dart';
import '../pages/signup_page.dart';

class SharedDrawer extends StatelessWidget {
  final User? user;
  final bool isClientHomePage;
  
  const SharedDrawer({
    super.key, 
    required this.user,
    this.isClientHomePage = false,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.pink,
            ),
            child: Text(
              'Menu',
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontFamily: 'MontserratBold',
              ),
            ),
          ),
          if (!isClientHomePage) ...[
            _buildDrawerItem(
              context: context,
              icon: Icons.info,
              text: 'En savoir plus',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const Infos())),
            ),
          ],
          if (user == null && !isClientHomePage) ...[
            _buildDrawerItem(
              context: context,
              icon: Icons.login,
              text: 'Connexion',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LoginPage())),
            ),
            _buildDrawerItem(
              context: context,
              icon: Icons.person_add,
              text: 'Inscription',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SignupPage())),
            ),
          ] else if (user != null) ...[
            FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              future: FirebaseFirestore.instance.collection('users').doc(user?.uid).get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                
                final userData = snapshot.data?.data();
                final isAdmin = userData?['type'] == 'admin';

                if (isAdmin && !isClientHomePage) {
                  return Column(
                    children: [
                      _buildDrawerItem(
                        context: context,
                        icon: Icons.home,
                        text: 'Accueil Admin',
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminHomePage())),
                      ),
                      _buildDrawerItem(
                        context: context,
                        icon: Icons.person,
                        text: 'Profil Admin',
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminProfilePage())),
                      ),
                      _buildDrawerItem(
                        context: context,
                        icon: Icons.group,
                        text: 'Gérer les Clients',
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminClientListPage())),
                      ),
                    ],
                  );
                } else if (!isAdmin) {
                  return Column(
                    children: [
                      if (!isClientHomePage) _buildDrawerItem(
                        context: context,
                        icon: Icons.home,
                        text: 'Accueil Client',
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ClientHomePage())),
                      ),
                      _buildDrawerItem(
                        context: context,
                        icon: Icons.person,
                        text: 'Mon Profil',
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ClientProfilePage())),
                      ),
                      _buildDrawerItem(
                        context: context,
                        icon: Icons.dashboard,
                        text: 'Tableau de bord',
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ClientDashboardPage())),
                      ),
                      _buildDrawerItem(
                        context: context,
                        icon: Icons.card_membership,
                        text: 'Mon Abonnement',
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const Adhesion())),
                      ),
                    ],
                  );
                }
                return const SizedBox();
              },
            ),
            _buildDrawerItem(
              context: context,
              icon: Icons.exit_to_app,
              text: 'Se déconnecter',
              onTap: () => _showLogoutDialog(context),
            ),
          ],
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
      leading: Icon(icon, color: Colors.pink),
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