import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:padel_app/data/models/cancha_model.dart';
import 'package:padel_app/data/models/quedada_model.dart';
import 'package:padel_app/features/design/app_colors.dart';
import 'package:padel_app/features/pages/canchas_page.dart';

class RoomPage extends StatelessWidget {
  final String canchaId;

  const RoomPage({Key? key, required this.canchaId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Horarios de la Cancha'),
        backgroundColor: AppColors.primaryGreen,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('canchas').doc(canchaId).get(),
        builder: (context, canchaSnapshot) {
          if (canchaSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!canchaSnapshot.hasData || !canchaSnapshot.data!.exists) {
            return const Center(child: Text('Cancha no encontrada.'));
          }

          final cancha = Cancha.fromFirestore(canchaSnapshot.data!);

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('quedadas')
                .where('lugar', isEqualTo: cancha.nombre)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final quedadas = snapshot.hasData
                  ? snapshot.data!.docs
                      .map((doc) => Quedada.fromFirestore(doc))
                      .toList()
                  : <Quedada>[];

              return ListView.builder(
                itemCount: 18, // De 6:00 a 23:00 hay 18 horas
                itemBuilder: (context, index) {
                  final hora = 6 + index;
                  final horaString = '${hora.toString().padLeft(2, '0')}:00';
                  final quedadaExistente = quedadas.firstWhere(
                    (q) => q.hora == horaString,
                    orElse: () => Quedada(id: '', lugar: '', fecha: '', hora: '', equipo1: [], equipo2: [], estado: '', ganador: '', set1: '', set2: '', set3: ''),
                  );

                  String estado = 'Disponible';
                  Color color = Colors.green;

                  if (quedadaExistente.id.isNotEmpty) {
                    DateTime now = DateTime.now();
                    DateTime quedadaTime = DateFormat('HH:mm').parse(quedadaExistente.hora);
                    DateTime quedadaDateTime = DateTime(now.year, now.month, now.day, quedadaTime.hour, quedadaTime.minute);

                    if (now.isAfter(quedadaDateTime)) {
                      estado = 'Finalizado';
                      color = Colors.red;
                    } else {
                      estado = 'En espera';
                      color = Colors.orange;
                    }
                  }

                  return ListTile(
                    title: Text(horaString),
                    subtitle: Text(estado),
                    trailing: Icon(Icons.circle, color: color),
                    onTap: () {
                      if (quedadaExistente.id.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                CanchasPage(quedadaId: quedadaExistente.id),
                          ),
                        );
                      }
                    },
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
