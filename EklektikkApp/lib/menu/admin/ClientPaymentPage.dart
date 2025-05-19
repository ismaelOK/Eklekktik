import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ClientPaymentPage extends StatefulWidget {
  final String userId;

  const ClientPaymentPage({Key? key, required this.userId}) : super(key: key);

  @override
  _ClientPaymentPageState createState() => _ClientPaymentPageState();
}

class _ClientPaymentPageState extends State<ClientPaymentPage> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedPaymentMethod = 'Carte Bancaire';
  final List<String> _paymentMethods = [
    'Carte Bancaire',
    'Virement',
    'Espèces',
    'Chèque',
    'PayPal'
  ];
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _recordPayment() async {
    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer un montant')),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Montant invalide')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final paymentData = {
        'amount': amount,
        'method': _selectedPaymentMethod,
        'description': _descriptionController.text.isNotEmpty
            ? _descriptionController.text
            : 'Paiement administrateur',
        'date': FieldValue.serverTimestamp(),
        'processedBy': 'admin',
        'status': 'completed',
      };

      // Batch write pour les opérations atomiques
      final batch = FirebaseFirestore.instance.batch();

      // Mise à jour de l'utilisateur
      final userRef = FirebaseFirestore.instance.collection('users').doc(widget.userId);
      batch.update(userRef, {
        'payments': FieldValue.arrayUnion([paymentData]),
        'lastPaymentDate': FieldValue.serverTimestamp(),
        'subscription': 'actif',
      });

      // Mise à jour de l'abonnement
      final subscriptionRef = FirebaseFirestore.instance.collection('subscriptions').doc(widget.userId);
      batch.set(subscriptionRef, {
        'userId': widget.userId,
        'plan': _getPlanFromAmount(amount),
        'status': 'actif',
        'startDate': FieldValue.serverTimestamp(),
        'endDate': _calculateEndDate(amount),
        'lastPayment': paymentData,
        'autoRenew': false,
      }, SetOptions(merge: true));

      await batch.commit();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Paiement enregistré avec succès!')),
      );

      _amountController.clear();
      _descriptionController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _getPlanFromAmount(double amount) {
    if (amount >= 50) return 'premium';
    if (amount >= 25) return 'standard';
    return 'basic';
  }

  Timestamp _calculateEndDate(double amount) {
    final duration = Duration(days: amount >= 50 ? 365 : 30);
    return Timestamp.fromDate(DateTime.now().add(duration));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Paiements'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => _showPaymentHistory(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildUserInfoCard(),
            const SizedBox(height: 20),
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      'Nouveau Paiement',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _amountController,
                      decoration: const InputDecoration(
                        labelText: 'Montant (€)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.euro),
                      ),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 15),
                    DropdownButtonFormField<String>(
                      value: _selectedPaymentMethod,
                      items: _paymentMethods
                          .map((method) => DropdownMenuItem(
                        value: method,
                        child: Text(method),
                      ))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _selectedPaymentMethod = value!),
                      decoration: const InputDecoration(
                        labelText: 'Méthode de paiement',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.payment),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description (optionnel)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _recordPayment,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : const Text('ENREGISTRER LE PAIEMENT'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildUserInfoCard() {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        final user = snapshot.data!;
        final userData = user.data() as Map<String, dynamic>? ?? {};

        return Card(
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userData['name']?.toString() ?? 'Nom non renseigné',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text('Email: ${userData['email']?.toString() ?? 'Non renseigné'}'),
                Text('Téléphone: ${userData['phone']?.toString() ?? 'Non renseigné'}'),
                const SizedBox(height: 8),
     
              ],
            ),
          ),
        );
      },
    );
  }
  void _showPaymentHistory(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Historique des paiements',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(widget.userId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final payments = snapshot.data!['payments'] as List? ?? [];

                    if (payments.isEmpty) {
                      return const Center(
                        child: Text('Aucun paiement enregistré'),
                      );
                    }

                    // Trier par date (du plus récent)
                    payments.sort((a, b) {
                      final aDate = a['date'] is Timestamp
                          ? (a['date'] as Timestamp).toDate()
                          : DateTime.now();
                      final bDate = b['date'] is Timestamp
                          ? (b['date'] as Timestamp).toDate()
                          : DateTime.now();
                      return bDate.compareTo(aDate);
                    });

                    return ListView.builder(
                      itemCount: payments.length,
                      itemBuilder: (context, index) {
                        final payment = payments[index];
                        final date = payment['date'] is Timestamp
                            ? (payment['date'] as Timestamp).toDate()
                            : DateTime.now();
                        final formattedDate =
                        DateFormat('dd/MM/yyyy HH:mm').format(date);

                        return ListTile(
                          leading: const Icon(Icons.payment, color: Colors.green),
                          title: Text('${payment['amount']}€ - ${payment['method']}'),
                          subtitle: Text(formattedDate),
                          trailing: Text(payment['description'] ?? ''),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}