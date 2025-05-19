import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_details_page.dart'; // Pour accéder aux détails client

class AdminClientListPage extends StatefulWidget {
  const AdminClientListPage({super.key});

  @override
  _AdminClientListPageState createState() => _AdminClientListPageState();
}

class _AdminClientListPageState extends State<AdminClientListPage> {
  String searchQuery = '';

  // Fonction pour filtrer les clients en fonction de la recherche
  List<QueryDocumentSnapshot> filterClients(List<QueryDocumentSnapshot> clients, String query) {
    return clients.where((client) {
      final name = client['name'].toString().toLowerCase();
      final email = client['email'].toString().toLowerCase();
      return name.contains(query) || email.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Liste des Clients",
          style: TextStyle(
            fontFamily: 'MontserratBold',
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: 200,
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Rechercher...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                  border: InputBorder.none,
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.3),
                  prefixIcon: Icon(Icons.search, color: Colors.white),
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value.toLowerCase();
                  });
                },
              ),
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('type', isEqualTo: 'client') // filtre uniquement les clients
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Erreur: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Aucun client trouvé"));
          }

          final clients = snapshot.data!.docs;

          // Utilisation de la fonction de filtrage
          final filteredClients = filterClients(clients, searchQuery);

          if (filteredClients.isEmpty) {
            return const Center(child: Text("Aucun client trouvé"));
          }

          return ListView.builder(
            itemCount: filteredClients.length,
            itemBuilder: (context, index) {
              final client = filteredClients[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.person, color: Colors.blue),
                  title: Text(client['name'], style: const TextStyle(fontFamily: 'MontserratBold')),
                  subtitle: Text(client['email'], style: const TextStyle(fontFamily: 'Montserrat')),
                  trailing: IconButton(
                    icon: const Icon(Icons.arrow_forward, color: Colors.blue),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserDetailsPage(userId: client.id),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}