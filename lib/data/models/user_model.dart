class Usuario {
  final String uid;
  final String correoElectronico;
  final String nombre;
  final String descripcionPerfil;
  final int asistencias;
  final int bonificaciones;
  final double efectividad; // Usamos double por si se necesita precisión decimal
  final int penalizaciones;
  final int puntos;
  final int puntos_pos; // Puntos de posición
  final int ranking;
  final int subcategoria; // Podría ser String si representa un nombre, pero se inicializa en 0
  final String estado;

  Usuario({
    required this.uid,
    required this.correoElectronico,
    required this.nombre,
    required this.descripcionPerfil,
    this.asistencias = 0,
    this.bonificaciones = 0,
    this.efectividad = 0.0,
    this.penalizaciones = 0,
    this.puntos = 0,
    this.puntos_pos = 0,
    this.ranking = 0,
    this.subcategoria = 0, // Asumiendo que 0 es un valor inicial válido
    this.estado = 'disponible',
  });

  // Método para convertir un objeto Usuario a un Map (para Firestore)
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'correoElectronico': correoElectronico,
      'nombre': nombre,
      'descripcionPerfil': descripcionPerfil,
      'asistencias': asistencias,
      'bonificaciones': bonificaciones,
      'efectividad': efectividad,
      'penalizaciones': penalizaciones,
      'puntos': puntos,
      'puntos_pos': puntos_pos,
      'ranking': ranking,
      'subcategoria': subcategoria,
      'estado': estado,
    };
  }

  // Método factory para crear un objeto Usuario desde un Map (de Firestore)
  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      uid: json['uid'] as String? ?? "",
      correoElectronico: json['correoElectronico'] as String,
      nombre: json['nombre'] as String,
      descripcionPerfil: json['descripcionPerfil'] as String,
      asistencias: json['asistencias'] as int? ?? 0,
      bonificaciones: json['bonificaciones'] as int? ?? 0,
      efectividad: (json['efectividad'] as num?)?.toDouble() ?? 0.0,
      penalizaciones: json['penalizaciones'] as int? ?? 0,
      puntos: json['puntos'] as int? ?? 0,
      puntos_pos: json['puntos_pos'] as int? ?? 0,
      ranking: json['ranking'] as int? ?? 0,
      subcategoria: json['subcategoria'] as int? ?? 0,
      estado: json['estado'] as String? ?? 'disponible',
    );
  }

  // Opcional: Un método copyWith para crear una copia del objeto con algunos campos modificados
  Usuario copyWith({
    String? uid,
    String? correoElectronico,
    String? nombre,
    String? descripcionPerfil,
    int? asistencias,
    int? bonificaciones,
    double? efectividad,
    int? penalizaciones,
    int? puntos,
    int? puntos_pos,
    int? ranking,
    int? subcategoria,
    String? estado,
  }) {
    return Usuario(
      uid: uid ?? this.uid,
      correoElectronico: correoElectronico ?? this.correoElectronico,
      nombre: nombre ?? this.nombre,
      descripcionPerfil: descripcionPerfil ?? this.descripcionPerfil,
      asistencias: asistencias ?? this.asistencias,
      bonificaciones: bonificaciones ?? this.bonificaciones,
      efectividad: efectividad ?? this.efectividad,
      penalizaciones: penalizaciones ?? this.penalizaciones,
      puntos: puntos ?? this.puntos,
      puntos_pos: puntos_pos ?? this.puntos_pos,
      ranking: ranking ?? this.ranking,
      subcategoria: subcategoria ?? this.subcategoria,
      estado: estado ?? this.estado,
    );
  }
}
