import 'package:cloud_firestore/cloud_firestore.dart';

class Club {
  final String id;
  final String nombre;
  final String direccion;
  final String ciudad;

  Club({
    required this.id,
    required this.nombre,
    required this.direccion,
    required this.ciudad,
  });

  factory Club.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Club(
      id: doc.id,
      nombre: data['nombre'] ?? '',
      direccion: data['direccion'] ?? '',
      ciudad: data['ciudad'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nombre': nombre,
      'direccion': direccion,
      'ciudad': ciudad,
    };
  }
}
