import 'package:padel_app/data/jugador_stats.dart';

class RankClub {
  final String club;
  final Map<String, JugadorStats> jugadores;

  RankClub({
    required this.club,
    required this.jugadores,
  });

  factory RankClub.fromJson(Map<String, dynamic> json) {
    var jugadoresMap = <String, JugadorStats>{};
    if (json['jugadores'] != null) {
      (json['jugadores'] as Map<String, dynamic>).forEach((key, value) {
        jugadoresMap[key] = JugadorStats.fromJson(value as Map<String, dynamic>);
      });
    }

    return RankClub(
      club: json['club'] as String? ?? '',
      jugadores: jugadoresMap,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'club': club,
      'jugadores': jugadores.map((key, value) => MapEntry(key, value.toJson())),
    };
  }
}
