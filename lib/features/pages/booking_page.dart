import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:padel_app/data/models/quedada_model.dart';
import 'package:padel_app/features/design/app_colors.dart';
import 'package:padel_app/features/pages/home_page.dart';
import 'package:padel_app/features/pages/landing_page.dart';

class BookingPage extends StatefulWidget {
  final String canchaNombre;
  final String fecha;
  final String hora;

  const BookingPage({
    Key? key,
    required this.canchaNombre,
    required this.fecha,
    required this.hora,
  }) : super(key: key);

  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservar Pista'),
        centerTitle: true,
        backgroundColor: AppColors.primaryBlue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Tu Nombre'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, introduce tu nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _reservarPista();
                  }
                },
                child: const Text('Confirmar Reserva'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _reservarPista() {
    final nuevaQuedada = Quedada(
      id: '', // Firestore will generate the ID
      lugar: widget.canchaNombre,
      fecha: widget.fecha,
      hora: widget.hora,
      equipo1: [_nombreController.text, ''],
      equipo2: ['', ''],
      estado: 'En espera',
      ganador: 'Por definir',
      set1: 'No disponible',
      set2: 'No disponible',
      set3: 'No disponible',
    );

    FirebaseFirestore.instance
        .collection('quedadas')
        .add(nuevaQuedada.toFirestore())
        .then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reserva confirmada')),
      );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LandingPage()),
        (Route<dynamic> route) => false,
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al reservar: $error')),
      );
    });
  }
}
