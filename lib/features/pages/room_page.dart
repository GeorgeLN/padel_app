import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:padel_app/data/models/quedada_model.dart';
import 'package:padel_app/features/design/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RoomPage extends StatefulWidget {
  final String quedadaId;

  const RoomPage({Key? key, required this.quedadaId}) : super(key: key);

  @override
  _RoomPageState createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  int setActual = 1;
  int? ganadorSet1;
  int? ganadorSet2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sala de Juego'),
        backgroundColor: AppColors.primaryGreen,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('quedadas').doc(widget.quedadaId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Esta quedada ya no está disponible.'));
          }

          final quedada = Quedada.fromFirestore(snapshot.data!);

          if (quedada.estadoQuedada == 'disponible') {
            return _buildSalaDeEspera(context, quedada);
          } else {
            return _buildCuadroDeClasificacion(context, quedada);
          }
        },
      ),
    );
  }

  Widget _buildSalaDeEspera(BuildContext context, Quedada quedada) {
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
                  title: _buildPlayerName(quedada.jugadores[index]),
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
            onPressed: () => _cancelarEspera(context, quedada),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text('Cancelar Espera', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildCuadroDeClasificacion(BuildContext context, Quedada quedada) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildEquipo(context, 'Equipo 1', quedada.equipo1),
              Padding(
                padding: const EdgeInsets.only(top: 50.0),
                child: Text('VS', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
              ),
              _buildEquipo(context, 'Equipo 2', quedada.equipo2),
            ],
          ),
          const Spacer(),
          _buildBotonesDeSet(context, quedada),
        ],
      ),
    );
  }

  Widget _buildEquipo(BuildContext context, String nombreEquipo, List<String> jugadores) {
    return Column(
      children: [
        Text(nombreEquipo, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...jugadores.map((uid) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: _buildPlayerName(uid),
            )),
      ],
    );
  }

  Widget _buildBotonesDeSet(BuildContext context, Quedada quedada) {
    if (setActual == 1 || setActual == 2) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ElevatedButton(onPressed: () => _ganarSet(1), child: Text('Gana Set $setActual Equipo 1')),
          ElevatedButton(onPressed: () => _ganarSet(2), child: Text('Gana Set $setActual Equipo 2')),
        ],
      );
    } else if (setActual == 3) {
      if (ganadorSet1 != ganadorSet2) {
        // Alguien ganó 2-0
        return ElevatedButton(onPressed: _finalizarJuego, child: const Text('Finalizar Juego'));
      } else {
        // Empate 1-1, vamos al tercer set
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(onPressed: () => _ganarSet(1), child: const Text('Gana Set 3 Equipo 1')),
            ElevatedButton(onPressed: () => _ganarSet(2), child: const Text('Gana Set 3 Equipo 2')),
          ],
        );
      }
    } else {
      // setActual > 3, el juego terminó
      return Column(
        children: [
          Text('Juego Finalizado. Ganador: Equipo ${ganadorSet1 == ganadorSet2 ? ganadorSet2 : ganadorSet1}'),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _finalizarJuego, child: const Text('Ver Resultados')),
        ],
      );
    }
  }

  void _ganarSet(int equipo) {
    setState(() {
      if (setActual == 1) {
        ganadorSet1 = equipo;
      } else if (setActual == 2) {
        ganadorSet2 = equipo;
      }
      setActual++;
    });
  }

  void _finalizarJuego() {
    // Lógica para finalizar el juego, actualizar estadísticas, etc.
    Navigator.pop(context);
  }

  void _cancelarEspera(BuildContext context, Quedada quedada) async {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final quedadaRef = FirebaseFirestore.instance.collection('quedadas').doc(widget.quedadaId);
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
  }

  Widget _buildPlayerName(String uid) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('usuarios').doc(uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Cargando...');
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Text('Jugador no encontrado');
        }
        final userData = snapshot.data!.data() as Map<String, dynamic>;
        return Text(userData['nombre'] ?? 'Nombre no disponible');
      },
    );
  }
}
