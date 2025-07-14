import 'package:cloud_firestore/cloud_firestore.dart';

class Quedada {
  final String id;
  final String lugar;
  final DateTime fecha;
  final String hora;
  final List<String> jugadores;
  final List<String> equipo1;
  final List<String> equipo2;
  final String estadoQuedada;

  Quedada({
    required this.id,
    required this.lugar,
    required this.fecha,
    required this.hora,
    required this.jugadores,
    required this.equipo1,
    required this.equipo2,
    this.estadoQuedada = 'disponible',
  });

  factory Quedada.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Quedada(
      id: doc.id,
      lugar: data['lugar'] ?? '',
      fecha: (data['fecha'] as Timestamp).toDate(),
      hora: data['hora'] ?? '',
      jugadores: List<String>.from(data['jugadores'] ?? []),
      equipo1: List<String>.from(data['equipo1'] ?? []),
      equipo2: List<String>.from(data['equipo2'] ?? []),
      estadoQuedada: data['estadoQuedada'] ?? 'disponible',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'lugar': lugar,
      'fecha': fecha,
      'hora': hora,
      'jugadores': jugadores,
      'equipo1': equipo1,
      'equipo2': equipo2,
      'estadoQuedada': estadoQuedada,
    };
  }
}
