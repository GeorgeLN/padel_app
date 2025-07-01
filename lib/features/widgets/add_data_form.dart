// ignore_for_file: library_private_types_in_public_api, equal_keys_in_map

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:padel_app/features/design/app_colors.dart';

class AddDataForm extends StatefulWidget {
  final void Function(Map<String, dynamic> data) onSave;

  const AddDataForm({super.key, required this.onSave});

  @override
  _AddDataFormState createState() => _AddDataFormState();
}

class _AddDataFormState extends State<AddDataForm> {
  final _formKey = GlobalKey<FormState>();
  final _teamController = TextEditingController();
  final _puntosPosController = TextEditingController();
  final _percentageController = TextEditingController();
  final _asistController = TextEditingController();
  final _ptsController = TextEditingController();
  final _subCtgController = TextEditingController();
  final _bonController = TextEditingController();
  final _penController = TextEditingController();

  @override
  void dispose() {
    _teamController.dispose();
    _puntosPosController.dispose();
    _percentageController.dispose();
    _asistController.dispose();
    _ptsController.dispose();
    _subCtgController.dispose();
    _bonController.dispose();
    _penController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      //Cálculo del porcentaje de efectividad
      final efect = int.parse(_ptsController.text) / (int.parse(_asistController.text) * 3);
      efect.toStringAsFixed(2);

      final data = {
        'TEAM': _teamController.text,
        'PTS POS': int.parse(_puntosPosController.text),
        '%': efect,
        'ASIST': int.parse(_asistController.text),
        'PTS': int.parse(_ptsController.text),
        'SUB CTG': int.parse(_subCtgController.text),
        'BON': int.parse(_bonController.text),
        'PEN': int.parse(_penController.text),
      };
      widget.onSave(data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          TextFormField(
            style: GoogleFonts.lato(color: AppColors.textLightGray),
            controller: _teamController,
            decoration: const InputDecoration(labelText: 'Team'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Nombre de jugador o equipo';
              }
              return null;
            },
          ),
          TextFormField(
            style: GoogleFonts.lato(color: AppColors.textLightGray),
            controller: _puntosPosController,
            decoration: const InputDecoration(labelText: 'Puntos POS'),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Puntos POS';
              }
              if (int.tryParse(value) == null) {
                return 'Ingrese un número válido';
              }
              return null;
            },
          ),
          // TextFormField(
          //   controller: _percentageController,
          //   decoration: const InputDecoration(labelText: '%'),
          //   keyboardType: TextInputType.numberWithOptions(decimal: true),
          //   validator: (value) {
          //     if (value == null || value.isEmpty) {
          //       return 'Ingrese el porcentaje %';
          //     }
          //     // Basic validation for a number, could be more complex
          //     if (double.tryParse(value.replaceAll(',', '.')) == null) {
          //       return 'Ingrese un número válido';
          //     }
          //     return null;
          //   },
          // ),
          TextFormField(
            style: GoogleFonts.lato(color: AppColors.textLightGray),
            controller: _asistController,
            decoration: const InputDecoration(labelText: 'Asist'),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Ingrese el número de asistencias';
              }
              if (int.tryParse(value) == null) {
                return 'Ingrese un número válido';
              }
              return null;
            },
          ),
          TextFormField(
            style: GoogleFonts.lato(color: AppColors.textLightGray),
            controller: _ptsController,
            decoration: const InputDecoration(labelText: 'Pts'),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Ingrese el número de puntos';
              }
              if (int.tryParse(value) == null) {
                return 'Ingrese un número válido';
              }
              return null;
            },
          ),
          TextFormField(
            style: GoogleFonts.lato(color: AppColors.textLightGray),
            controller: _subCtgController,
            decoration: const InputDecoration(labelText: 'Sub CTG'),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Ingrese el número de sub categorías';
              }
              if (int.tryParse(value) == null) {
                return 'Ingrese un número válido';
              }
              return null;
            },
          ),
          TextFormField(
            style: GoogleFonts.lato(color: AppColors.textLightGray),
            controller: _bonController,
            decoration: const InputDecoration(labelText: 'Bon'),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Ingrese el número de bonificaciones';
              }
              if (int.tryParse(value) == null) {
                return 'Ingrese un número válido';
              }
              return null;
            },
          ),
          TextFormField(
            style: GoogleFonts.lato(color: AppColors.textLightGray),
            controller: _penController,
            decoration: const InputDecoration(labelText: 'Pen'),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Ingrese el número de penalizaciones';
              }
              if (int.tryParse(value) == null) {
                return 'Ingrese un número válido';
              }
              return null;
            },
          ),
          ElevatedButton(
            onPressed: _submitForm,
            child: const Text('Agregar Datos'),
          ),
        ],
      ),
    );
  }
}
