import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:padel_app/data/models/cancha_model.dart';
import 'package:padel_app/data/models/quedada_model.dart';
import 'package:padel_app/features/design/app_colors.dart';
import 'package:padel_app/features/pages/booking_page.dart';
import 'package:padel_app/features/pages/canchas_page.dart';

class RoomPage extends StatefulWidget {
  final String canchaId;

  const RoomPage({Key? key, required this.canchaId}) : super(key: key);

  @override
  _RoomPageState createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Horarios de la Cancha'),
        centerTitle: true,
        backgroundColor: AppColors.primaryBlue,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('canchas').doc(widget.canchaId).get(),
        builder: (context, canchaSnapshot) {
          if (canchaSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!canchaSnapshot.hasData || !canchaSnapshot.data!.exists) {
            return const Center(child: Text('Cancha no encontrada.'));
          }

          final cancha = Cancha.fromFirestore(canchaSnapshot.data!);
          final formattedDate = DateFormat('dd/MM/yyyy').format(_selectedDate);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Fecha seleccionada: $formattedDate',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('quedadas')
                      .where('lugar', isEqualTo: cancha.nombre)
                      .where('fecha', isEqualTo: formattedDate)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final quedadas = snapshot.hasData
                        ? snapshot.data!.docs
                            .map((doc) => Quedada.fromFirestore(doc))
                            .toList()
                        : <Quedada>[];

                    return ListView.builder(
                      itemCount: 18, // De 6:00 a 23:00 hay 18 horas
                      itemBuilder: (context, index) {
                        final hora = 6 + index;
                        final horaString = '${hora.toString().padLeft(2, '0')}:00';
                        final quedadaExistente = quedadas.firstWhere(
                          (q) => q.hora == horaString,
                          orElse: () => Quedada(id: '', lugar: '', fecha: '', hora: '', equipo1: [], equipo2: [], estado: '', ganador: '', set1: '', set2: '', set3: ''),
                        );

                        String estado = 'Disponible';
                        Color color = Colors.green;

                        if (quedadaExistente.id.isNotEmpty) {
                          if (quedadaExistente.estado == 'En transcurso') {
                            estado = 'Ocupado';
                            color = Colors.blue;
                          } else {
                            DateTime now = DateTime.now();
                            DateTime quedadaTime = DateFormat('HH:mm').parse(quedadaExistente.hora);
                            DateTime quedadaDateTime = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, quedadaTime.hour, quedadaTime.minute);

                            if (!now.isAfter(quedadaDateTime)) {
                              estado = 'Finalizado';
                              color = Colors.red;
                            } else {
                              estado = 'En espera';
                              color = Colors.orange;
                            }
                          }
                        }

                        return ListTile(
                          title: Text(horaString),
                          subtitle: Text(estado),
                          trailing: Icon(Icons.circle, color: color),
                          onTap: () {
                            if (quedadaExistente.id.isEmpty) {
                              // Disponible
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BookingPage(
                                    canchaNombre: cancha.nombre,
                                    fecha: formattedDate,
                                    hora: horaString,
                                  ),
                                ),
                              );
                            } else if (quedadaExistente.estado == 'En transcurso') {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Horario no disponible'),
                                  content: const Text(
                                      'Esta hora ya está reservada y el partido está en transcurso.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(),
                                      child: const Text('Aceptar'),
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              // Navegar a los detalles de la quedada si no está en transcurso
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      CanchasPage(quedadaId: quedadaExistente.id),
                                ),
                              );
                            }
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
