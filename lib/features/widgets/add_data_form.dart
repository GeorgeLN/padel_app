import 'package:flutter/material.dart';

class AddDataForm extends StatefulWidget {
  final void Function(Map<String, dynamic> data) onSave;

  const AddDataForm({Key? key, required this.onSave}) : super(key: key);

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

  @override
  void dispose() {
    _teamController.dispose();
    _puntosPosController.dispose();
    _percentageController.dispose();
    _asistController.dispose();
    _ptsController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final data = {
        'Team': _teamController.text,
        'Puntos POS': int.parse(_puntosPosController.text),
        '%': _percentageController.text,
        'Asist': int.parse(_asistController.text),
        'Pts': int.parse(_ptsController.text),
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
            controller: _teamController,
            decoration: const InputDecoration(labelText: 'Team'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a team name';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _puntosPosController,
            decoration: const InputDecoration(labelText: 'Puntos POS'),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter Puntos POS';
              }
              if (int.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _percentageController,
            decoration: const InputDecoration(labelText: '%'),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter %';
              }
              // Basic validation for a number, could be more complex
              if (double.tryParse(value.replaceAll(',', '.')) == null) {
                return 'Please enter a valid number for %';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _asistController,
            decoration: const InputDecoration(labelText: 'Asist'),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter Asist';
              }
              if (int.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _ptsController,
            decoration: const InputDecoration(labelText: 'Pts'),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter Pts';
              }
              if (int.tryParse(value) == null) {
                return 'Please enter a valid number';
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
