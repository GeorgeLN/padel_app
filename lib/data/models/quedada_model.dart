import 'package:cloud_firestore/cloud_firestore.dart';

class Partido {
  final List<String> equipo1;
  final List<String> equipo2;
  final String estado; // e.g., 'disponible', 'en juego', 'finalizado'
  final Map<String, int>? resultado;

  Partido({
    required this.equipo1,
    required this.equipo2,
    this.estado = 'disponible',
    this.resultado,
  });

  factory Partido.fromMap(Map<String, dynamic> map) {
    return Partido(
      equipo1: List<String>.from(map['equipo1'] ?? []),
      equipo2: List<String>.from(map['equipo2'] ?? []),
      estado: map['estado'] ?? 'disponible',
      resultado: Map<String, int>.from(map['resultado'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'equipo1': equipo1,
      'equipo2': equipo2,
      'estado': estado,
      'resultado': resultado,
    };
  }
}

class Quedada {
  final String id;
  final String lugar;
  final DateTime fecha;
  final String hora;
  final List<Partido> partidos;

  Quedada({
    required this.id,
    required this.lugar,
    required this.fecha,
    required this.hora,
    required this.partidos,
  });

  factory Quedada.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    var partidosData = data['partidos'] as List<dynamic>? ?? [];
    List<Partido> partidos = partidosData.map((partidoData) => Partido.fromMap(partidoData)).toList();

    return Quedada(
      id: doc.id,
      lugar: data['lugar'] ?? '',
      fecha: (data['fecha'] as Timestamp).toDate(),
      hora: data['hora'] ?? '',
      partidos: partidos,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'lugar': lugar,
      'fecha': fecha,
      'hora': hora,
      'partidos': partidos.map((p) => p.toMap()).toList(),
    };
  }
}
