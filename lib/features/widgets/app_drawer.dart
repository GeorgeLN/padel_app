import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:padel_app/features/pages/_pages.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  void _showComingSoonSnackBar(BuildContext context) {
    Navigator.pop(context); // Close the drawer
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Próximamente...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.green,
            ),
            child: Text(
              'Padel Manager',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(IconlyLight.graph),
            title: const Text('Torneos'),
            onTap: () {
              _showComingSoonSnackBar(context);
            },
          ),
          ListTile(
            leading: const Icon(IconlyLight.chart),
            title: const Text('Ranking'),
            onTap: () {
               Navigator.pop(context);
               Navigator.push(context, MaterialPageRoute(builder: (context) => const TablePage()));
            },
          ),
          ListTile(
            leading: const Icon(IconlyLight.calendar),
            title: const Text('Ligas'),
            onTap: () {
              _showComingSoonSnackBar(context);
            },
          ),
          ListTile(
            leading: const Icon(IconlyLight.user_1),
            title: const Text('Jugadores'),
            onTap: () {
              _showComingSoonSnackBar(context);
            },
          ),
          ListTile(
            leading: const Icon(IconlyLight.document),
            title: const Text('Resultados'),
            onTap: () {
              _showComingSoonSnackBar(context);
            },
          ),
           ListTile(
            leading: const Icon(Icons.table_chart_outlined),
            title: const Text('Tablas'),
            onTap: () {
               Navigator.pop(context);
               Navigator.push(context, MaterialPageRoute(builder: (context) => const TablePage()));
            },
          ),
        ],
      ),
    );
  }
}