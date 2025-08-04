class JugadorStats {
  final int asistencias;
  final int bonificaciones;
  final int efectividad;
  final int penalizacion;
  final int puntos;
  final int subcategoria;
  final String nombre;
  final String uid;

  JugadorStats({
    this.asistencias = 0,
    this.bonificaciones = 0,
    this.efectividad = 0,
    this.penalizacion = 0,
    this.puntos = 0,
    this.subcategoria = 0,
    this.nombre = '',
    this.uid = '',
  });

  factory JugadorStats.fromJson(Map<String, dynamic> json) {
    return JugadorStats(
      asistencias: json['asistencias'] as int? ?? 0,
      bonificaciones: json['bonificaciones'] as int? ?? 0,
      efectividad: json['efectividad'] as int? ?? 0,
      penalizacion: json['penalizacion'] as int? ?? 0,
      puntos: json['puntos'] as int? ?? 0,
      subcategoria: json['subcategoria'] as int? ?? 0,
      nombre: json['nombre'] as String? ?? '',
      uid: json['uid'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'asistencias': asistencias,
      'bonificaciones': bonificaciones,
      'efectividad': efectividad,
      'penalizacion': penalizacion,
      'puntos': puntos,
      'subcategoria': subcategoria,
      'nombre': nombre,
      'uid': uid,
    };
  }

  JugadorStats copyWith({
    int? asistencias,
    int? bonificaciones,
    int? efectividad,
    int? penalizacion,
    int? puntos,
    int? subcategoria,
    String? nombre,
    String? uid,
  }) {
    return JugadorStats(
      asistencias: asistencias ?? this.asistencias,
      bonificaciones: bonificaciones ?? this.bonificaciones,
      efectividad: efectividad ?? this.efectividad,
      penalizacion: penalizacion ?? this.penalizacion,
      puntos: puntos ?? this.puntos,
      subcategoria: subcategoria ?? this.subcategoria,
      nombre: nombre ?? this.nombre,
      uid: uid ?? this.uid,
    );
  }
}