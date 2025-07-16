import 'package:cloud_firestore/cloud_firestore.dart';

class Quedada {
  final String id;
  final String lugar;
  final String fecha;
  final String hora;
  final List<String> equipo1;
  final List<String> equipo2;
  final String estado;
  final String ganador;
  final String set1;
  final String set2;
  final String set3;

  Quedada({
    required this.id,
    required this.lugar,
    required this.fecha,
    required this.hora,
    required this.equipo1,
    required this.equipo2,
    required this.estado,
    required this.ganador,
    required this.set1,
    required this.set2,
    required this.set3,
  });

  factory Quedada.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Quedada(
      id: doc.id,
      lugar: data['lugar'] ?? '',
      fecha: data['fecha'] ?? '',
      hora: data['hora'] ?? '',
      equipo1: List<String>.from(data['equipo1'] ?? []),
      equipo2: List<String>.from(data['equipo2'] ?? []),
      estado: data['estado'] ?? 'Disponible',
      ganador: data['ganador'] ?? 'Por definir',
      set1: data['set1'] ?? 'No disponible',
      set2: data['set2'] ?? 'No disponible',
      set3: data['set3'] ?? 'No disponible',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'lugar': lugar,
      'fecha': fecha,
      'hora': hora,
      'equipo1': equipo1,
      'equipo2': equipo2,
      'estado': estado,
      'ganador': ganador,
      'set1': set1,
      'set2': set2,
      'set3': set3,
    };
  }
}
