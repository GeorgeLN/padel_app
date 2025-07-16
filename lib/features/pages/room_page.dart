import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:padel_app/data/models/quedada_model.dart';
import 'package:padel_app/features/design/app_colors.dart';
import 'package:padel_app/features/pages/canchas_page.dart';

class RoomPage extends StatelessWidget {
  final String quedadaId;

  const RoomPage({Key? key, required this.quedadaId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Horarios de la Quedada'),
        backgroundColor: AppColors.primaryGreen,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('quedadas')
            .where('fecha', isGreaterThanOrEqualTo: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day))
            .where('fecha', isLessThan: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day + 1))
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No hay quedadas para hoy.'));
          }

          final quedadas = snapshot.data!.docs
              .map((doc) => Quedada.fromFirestore(doc))
              .toList();

          return ListView.builder(
            itemCount: quedadas.length,
            itemBuilder: (context, index) {
              final quedada = quedadas[index];
              return ListTile(
                title: Text(quedada.hora),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CanchasPage(quedadaId: quedada.id),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
