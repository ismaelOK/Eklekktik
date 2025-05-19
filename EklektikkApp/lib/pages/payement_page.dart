// import 'package:flutter/material.dart';
// import 'package:flutter_stripe/flutter_stripe.dart';
//
// class PaymentPage extends StatefulWidget {
//   final double amount;
//   final String currency;
//
//   PaymentPage({required this.amount, required this.currency});
//
//   @override
//   _PaymentPageState createState() => _PaymentPageState();
// }
//
// class _PaymentPageState extends State<PaymentPage> {
//   final _formKey = GlobalKey<FormState>();
//   final _cardController = CardEditController();
//
//   Future<void> _processPayment() async {
//     if (_formKey.currentState!.validate()) {
//       try {
//         // Créer un paiement avec Stripe
//         final paymentMethod = await Stripe.instance.createPaymentMethod(
//           params: PaymentMethodParams.card(
//             paymentMethodData: PaymentMethodData(
//               billingDetails: BillingDetails(
//                 email: 'user@gmail.com', // Remplace par l'email de l'utilisateur
//               ),
//             ),
//           ),
//         );
//
//         // Envoyer le paiement à ton backend (ou directement à Stripe)
//         // Exemple : utiliser Firebase Functions pour gérer le paiement
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Paiement réussi !")),
//         );
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Erreur de paiement: $e")),
//         );
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Paiement"),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               CardField(
//                 controller: _cardController,
//                 decoration: InputDecoration(
//                   labelText: "Carte de crédit",
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//               ),
//               SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: _processPayment,
//                 child: Text("Payer ${widget.amount} ${widget.currency}"),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }