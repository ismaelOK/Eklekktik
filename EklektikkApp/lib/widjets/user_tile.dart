// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import '../models/user.dart';
//
// class UserTile extends StatelessWidget {
//   final User user;
//   final VoidCallback onTap;
//
//   UserTile({required this.user, required this.onTap});
//
//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//       title: Text(user.name),
//       subtitle: Text(user.email),
//       trailing: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text(
//             user.subscription,
//             style: TextStyle(
//               color: user.subscription == 'actif' ? Colors.green : Colors.red,
//             ),
//           ),
//           if (user.verified)
//             Icon(Icons.verified, color: Colors.green)
//           else
//             Icon(Icons.warning, color: Colors.orange),
//         ],
//       ),
//       onTap: onTap,
//     );
//   }
// }