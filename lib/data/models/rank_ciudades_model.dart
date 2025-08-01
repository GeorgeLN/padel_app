import 'package:padel_app/data/jugador_stats.dart';

class RankCiudad {
  final String ciudad;
  final Map<String, JugadorStats> jugadores;

  RankCiudad({
    required this.ciudad,
    required this.jugadores,
  });

  factory RankCiudad.fromJson(Map<String, dynamic> json) {
    var jugadoresMap = <String, JugadorStats>{};
    if (json['jugadores'] != null) {
      (json['jugadores'] as Map<String, dynamic>).forEach((key, value) {
        jugadoresMap[key] = JugadorStats.fromJson(value as Map<String, dynamic>);
      });
    }

    return RankCiudad(
      ciudad: json['ciudad'] as String? ?? '',
      jugadores: jugadoresMap,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ciudad': ciudad,
      'jugadores': jugadores.map((key, value) => MapEntry(key, value.toJson())),
    };
  }
}
