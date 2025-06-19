import 'package:flutter/material.dart';

class JugadorStats {
  final TextEditingController nombreController;
  final String logoUrl;
  final TextEditingController puntosPosController;
  final TextEditingController porcentajeController;
  final TextEditingController asistenciasController;
  final TextEditingController ptsController;

  JugadorStats({
    required String nombre,
    required this.logoUrl,
    required String puntosPos,
    required String porcentaje,
    required String asistencias,
    required String pts,
  })  : nombreController = TextEditingController(text: nombre),
        puntosPosController = TextEditingController(text: puntosPos),
        porcentajeController = TextEditingController(text: porcentaje),
        asistenciasController = TextEditingController(text: asistencias),
        ptsController = TextEditingController(text: pts);
}