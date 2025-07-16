import 'package:cloud_firestore/cloud_firestore.dart';

class Cancha {
  final String id;
  final String nombre;
  final String direccion;
  final int cantidad;
  final int disponibles;

  Cancha({
    required this.id,
    required this.nombre,
    required this.direccion,
    required this.cantidad,
    required this.disponibles,
  });

  factory Cancha.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Cancha(
      id: doc.id,
      nombre: data['nombre'] ?? '',
      direccion: data['direccion'] ?? '',
      cantidad: data['cantidad'] ?? 0,
      disponibles: data['disponibles'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nombre': nombre,
      'direccion': direccion,
      'cantidad': cantidad,
      'disponibles': disponibles,
    };
  }
}
