import 'package:padel_app/data/jugador_stats.dart';

class RankWhatsapp {
  final String nombre_grupo;
  final Map<String, JugadorStats> integrantes;

  RankWhatsapp({
    required this.nombre_grupo,
    required this.integrantes,
  });

  factory RankWhatsapp.fromJson(Map<String, dynamic> json) {
    var integrantesMap = <String, JugadorStats>{};
    if (json['integrantes'] != null) {
      (json['integrantes'] as Map<String, dynamic>).forEach((key, value) {
        integrantesMap[key] = JugadorStats.fromJson(value as Map<String, dynamic>);
      });
    }

    return RankWhatsapp(
      nombre_grupo: json['nombre_grupo'] as String? ?? '',
      integrantes: integrantesMap,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre_grupo': nombre_grupo,
      'integrantes': integrantes.map((key, value) => MapEntry(key, value.toJson())),
    };
  }
}
