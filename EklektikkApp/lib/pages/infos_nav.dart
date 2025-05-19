import 'package:flutter/material.dart';
import '../menu/client/client_home_page.dart';
import 'HomePage.dart';
import '../menu/client/client_profile_page.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:eklektikk/pages/infos.dart';

class InfosNav extends StatefulWidget {
  static const String title = 'Eklektikk';
  final bool isConnected = false;

  @override
  State<InfosNav> createState() => _InfosNavState();
}

class _InfosNavState extends State<InfosNav> {
  var _currentIndex = 1;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: InfosNav.title,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text(InfosNav.title),
        ),
        body: IndexedStack(
          index: _currentIndex,
          children: [
            HomePage(),
            Infos(),

          ],
        ),
        bottomNavigationBar: SalomonBottomBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          items: [
            SalomonBottomBarItem(
              icon: const Icon(Icons.home),
              title: const Text("Accueil"),
              selectedColor: Colors.pink,
            ),
            SalomonBottomBarItem(
              icon: const Icon(Icons.info),
              title: const Text("Infos"),
              selectedColor: Colors.blueAccent,
            ),

          ],
        ),
      ),
    );
  }
}