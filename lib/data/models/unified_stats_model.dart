import 'package:padel_app/data/jugador_stats.dart';
import 'package:padel_app/data/models/user_model.dart';

// Esta clase sirve como un modelo unificado para las estadísticas de un jugador,
// permitiendo normalizar los datos que provienen de diferentes fuentes (Usuario o JugadorStats).
class UnifiedStats {
  final String uid;
  final String nombre;
  final int asistencias;
  final int bonificaciones;
  final double efectividad;
  final int penalizaciones;
  final int puntos;
  final int subcategoria;
  final String source; // Para identificar la fuente de los datos (ej. 'General', 'Clubes')

  UnifiedStats({
    required this.uid,
    required this.nombre,
    this.asistencias = 0,
    this.bonificaciones = 0,
    this.efectividad = 0.0,
    this.penalizaciones = 0,
    this.puntos = 0,
    this.subcategoria = 0,
    required this.source,
  });

  // Factory constructor para crear UnifiedStats a partir de un objeto Usuario.
  factory UnifiedStats.fromUsuario(Usuario usuario) {
    return UnifiedStats(
      uid: usuario.uid,
      nombre: usuario.nombre,
      asistencias: usuario.asistencias,
      bonificaciones: usuario.bonificaciones,
      efectividad: usuario.efectividad, // Es double
      penalizaciones: usuario.penalizaciones,
      puntos: usuario.puntos,
      subcategoria: usuario.subcategoria,
      source: 'General', // La fuente es la tabla principal
    );
  }

  // Factory constructor para crear UnifiedStats a partir de un objeto JugadorStats.
  factory UnifiedStats.fromJugadorStats(JugadorStats stats, String sourceName) {
    return UnifiedStats(
      uid: stats.uid,
      nombre: stats.nombre,
      asistencias: stats.asistencias,
      bonificaciones: stats.bonificaciones,
      efectividad: stats.efectividad.toDouble(), // Convertir int a double
      penalizaciones: stats.penalizacion, // Normalizar nombre del campo
      puntos: stats.puntos,
      subcategoria: stats.subcategoria,
      source: sourceName, // La fuente puede ser 'Clubes', 'Ciudades', etc.
    );
  }
}
