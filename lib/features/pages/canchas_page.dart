import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:padel_app/data/models/quedada_model.dart';
import 'package:padel_app/data/models/club_model.dart';
import 'package:padel_app/features/pages/detalles_partido_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:padel_app/features/design/app_colors.dart';

class CanchasPage extends StatelessWidget {
  final String quedadaId;

  const CanchasPage({Key? key, required this.quedadaId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Canchas'),
        centerTitle: true,
        backgroundColor: AppColors.primaryBlue,
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

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('canchas').snapshots(),
            builder: (context, canchaSnapshot) {
              if (canchaSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!canchaSnapshot.hasData || canchaSnapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No hay canchas disponibles.'));
              }

              final clubes = canchaSnapshot.data!.docs.map((doc) => Club.fromFirestore(doc)).toList();
              final cancha = clubes.firstWhere((c) => c.nombre == quedada.lugar, orElse: () => Club(id: '0', nombre: '', direccion: '', ciudad: ''));

              return ListView.builder(
                itemBuilder: (context, index) {
                  return CanchaCard(
                    canchaIndex: index,
                    quedada: quedada,
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

class CanchaCard extends StatelessWidget {
  final int canchaIndex;
  final Quedada quedada;

  const CanchaCard({
    Key? key,
    required this.canchaIndex,
    required this.quedada,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cancha ${canchaIndex + 1}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildEquipo(context, 'Equipo 1', quedada.equipo1),
                const Text('VS'),
                _buildEquipo(context, 'Equipo 2', quedada.equipo2),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetallesPartidoPage(quedadaId: quedada.id),
                    ),
                  );
                },
                child: const Text('Ver Partido'),
              ),
            ),
            if (quedada.equipo1.length + quedada.equipo2.length < 4)
              Center(
                child: ElevatedButton(
                  onPressed: () => _unirseAPartido(context),
                  child: const Text('Unirse'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEquipo(BuildContext context, String nombreEquipo, List<String> jugadores) {
    return Column(
      children: [
        Text(nombreEquipo, style: const TextStyle(fontWeight: FontWeight.bold)),
        ...jugadores.map((uid) => _buildPlayerName(uid)).toList(),
        if (jugadores.length < 2)
          ...List.generate(2 - jugadores.length, (index) => const Text('Disponible')),
      ],
    );
  }

  Future<void> _unirseAPartido(BuildContext context) async {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final quedadaRef = FirebaseFirestore.instance.collection('quedadas').doc(quedada.id);

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final freshSnapshot = await transaction.get(quedadaRef);
        final freshQuedada = Quedada.fromFirestore(freshSnapshot);

        if (freshQuedada.equipo1.contains(currentUser.uid) || freshQuedada.equipo2.contains(currentUser.uid)) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ya estás en este partido.')));
          return;
        }

        if (freshQuedada.equipo1.length < 2) {
          freshQuedada.equipo1.add(currentUser.uid);
        } else if (freshQuedada.equipo2.length < 2) {
          freshQuedada.equipo2.add(currentUser.uid);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Este partido ya está lleno.')));
          return;
        }

        transaction.update(quedadaRef, {'equipo1': freshQuedada.equipo1, 'equipo2': freshQuedada.equipo2});
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al unirse: $e')));
    }
  }

  Widget _buildPlayerName(String uid) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('usuarios').doc(uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('...');
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Text('Desconocido');
        }
        final userData = snapshot.data!.data() as Map<String, dynamic>;
        return Text(userData['nombre'] ?? 'N/A');
      },
    );
  }
}
