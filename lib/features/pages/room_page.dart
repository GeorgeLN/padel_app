import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:padel_app/data/models/quedada_model.dart';
import 'package:padel_app/features/design/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RoomPage extends StatelessWidget {
  final String quedadaId;

  const RoomPage({Key? key, required this.quedadaId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sala de Espera'),
        backgroundColor: AppColors.primaryGreen,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('quedadas').doc(quedadaId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Esta quedada ya no está disponible.'));
          }

          final quedada = Quedada.fromFirestore(snapshot.data!);

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Lugar: ${quedada.lugar}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Fecha: ${quedada.fecha.day}/${quedada.fecha.month}/${quedada.fecha.year}', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                Text('Hora: ${quedada.hora}', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 24),
                const Text('Jugadores en la sala:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: quedada.jugadores.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(quedada.jugadores[index]),
                      );
                    },
                  ),
                ),
                if (quedada.jugadores.length < 4)
                  Center(
                    child: Column(
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text('Esperando a ${4 - quedada.jugadores.length} jugador(es) más...'),
                      ],
                    ),
                  ),
                if (quedada.jugadores.length == 4)
                  const Center(
                    child: Text('¡Listos para jugar!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
                  ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    final User? currentUser = FirebaseAuth.instance.currentUser;
                    if (currentUser == null) return;

                    final quedadaRef = FirebaseFirestore.instance.collection('quedadas').doc(quedadaId);
                    final userRef = FirebaseFirestore.instance.collection('usuarios').doc(currentUser.uid);

                    await FirebaseFirestore.instance.runTransaction((transaction) async {
                      final freshQuedadaSnapshot = await transaction.get(quedadaRef);
                      final freshQuedada = Quedada.fromFirestore(freshQuedadaSnapshot);

                      if (freshQuedada.jugadores.contains(currentUser.uid)) {
                        final newJugadores = List<String>.from(freshQuedada.jugadores)..remove(currentUser.uid);
                        transaction.update(quedadaRef, {'jugadores': newJugadores});
                        transaction.update(userRef, {'estado': 'disponible'});
                      }
                    });

                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Cancelar Espera', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
