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
        title: const Text('Partidos de la Quedada'),
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

          return ListView.builder(
            itemCount: quedada.partidos.length,
            itemBuilder: (context, index) {
              return PartidoCard(partido: quedada.partidos[index], quedadaId: quedadaId, partidoIndex: index);
            },
          );
        },
      ),
    );
  }
}

class PartidoCard extends StatelessWidget {
  final Partido partido;
  final String quedadaId;
  final int partidoIndex;

  const PartidoCard({Key? key, required this.partido, required this.quedadaId, required this.partidoIndex}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Partido ${partidoIndex + 1}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildEquipo(context, 'Equipo 1', partido.equipo1),
                const Text('VS'),
                _buildEquipo(context, 'Equipo 2', partido.equipo2),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => _unirseAPartido(context),
                  child: const Text('Unirse'),
                ),
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

    final quedadaRef = FirebaseFirestore.instance.collection('quedadas').doc(quedadaId);

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final freshSnapshot = await transaction.get(quedadaRef);
        final quedada = Quedada.fromFirestore(freshSnapshot);

        final partido = quedada.partidos[partidoIndex];

        // Comprobar si el usuario ya está en el partido
        if (partido.equipo1.contains(currentUser.uid) || partido.equipo2.contains(currentUser.uid)) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ya estás en este partido.')));
          return;
        }

        // Lógica para encontrar un hueco y añadir al jugador
        if (partido.equipo1.length < 2) {
          partido.equipo1.add(currentUser.uid);
        } else if (partido.equipo2.length < 2) {
          partido.equipo2.add(currentUser.uid);
        } else {
          // No hay hueco
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Este partido ya está lleno.')));
          return;
        }

        transaction.update(quedadaRef, {'partidos': quedada.partidos.map((p) => p.toMap()).toList()});
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
