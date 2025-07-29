import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:padel_app/features/design/app_colors.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:padel_app/data/models/cancha_model.dart';
import 'package:padel_app/features/widgets/cancha_card.dart';

import '../../data/models/user_model.dart';
import '../../data/viewmodels/auth_viewmodel.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<Usuario?>? _userDataFuture;

  @override
  void initState() {
    super.initState();
    _crearCanchasDeEjemplo();
    Future.microtask(() {
      if (mounted) {
        final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
        if (_userDataFuture == null) {
          setState(() {
            _userDataFuture = authViewModel.obtenerDatosUsuarioActual();
          });
        }
      }
    });
  }

  void _crearCanchasDeEjemplo() async {
    final canchasRef = FirebaseFirestore.instance.collection('canchas');
    final snapshot = await canchasRef.limit(1).get();
    if (snapshot.docs.isEmpty) {
      await canchasRef.add({
        'nombre': 'El Maracaná',
        'direccion': 'Calle Falsa 123',
        'cantidad': 6,
        'disponibles': 6,
      });
      await canchasRef.add({
        'nombre': 'La Bombonera',
        'direccion': 'Avenida Siempreviva 742',
        'cantidad': 4,
        'disponibles': 4,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    if (_userDataFuture == null) {
      return const Scaffold(
        backgroundColor: Color.fromARGB(234, 255, 255, 255),
        body: Center(child: CircularProgressIndicator(color: AppColors.primaryGreen)),
      );
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(234, 255, 255, 255), // Fondo blanco para HomePage
      body: FutureBuilder<Usuario?>(
        future: _userDataFuture,
        builder: (context, snapshot) {
          // Siempre construir la estructura base de la página
          // y pasar el usuario (o null) a PlayerAppBar.
          Usuario? usuario;
          if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
            usuario = snapshot.data;
          } else if (snapshot.connectionState == ConnectionState.done && snapshot.hasError) {
            // Puedes loggear el error si quieres: print('Error cargando datos de usuario en HomePage: ${snapshot.error}');
            usuario = null; // Continuar con usuario null si hay error
          }
          // Si está esperando, usuario será null y PlayerAppBar mostrará el nombre por defecto.

          return _buildHomePageContent(size, context, usuario);
        },
      ),
    );
  }

  Widget _buildHomePageContent(Size size, BuildContext context, Usuario? usuario) {
    String? primerNombre;
    String? estado;
    if (usuario != null && usuario.nombre.isNotEmpty) {
      primerNombre = usuario.nombre.split(' ').first;
      estado = usuario.estado;
    }

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            PlayerAppBar(size: size, playerName: primerNombre, playerStatus: estado),
            SearchWhiteText(size: size),
            MajorTournaments(size: size),
          ],
        ),
      ),
    );
  }
}

class MajorTournaments extends StatelessWidget {
  const MajorTournaments({
    super.key,
    required this.size,
  });

  final Size size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.width, // Ocupar el ancho disponible
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.05), // Padding horizontal
      margin: EdgeInsets.only(top: size.height * 0.02),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Clubes Disponibles',
            style: GoogleFonts.lato(
              fontSize: size.width * 0.05,
              color: AppColors.textBlack,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: size.height * 0.015),
          SizedBox(
            height: size.height * 0.25,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('canchas').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No hay canchas disponibles.'));
                }

                final canchas = snapshot.data!.docs.map((doc) => Cancha.fromFirestore(doc)).toList();

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: canchas.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(right: size.width * 0.04),
                      child: CanchaCard(size: size, cancha: canchas[index]),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SearchWhiteText extends StatelessWidget {
  const SearchWhiteText({
    super.key,
    required this.size,
  });

  final Size size;

  @override
  Widget build(BuildContext context) {
    return Padding( // Usar Padding en lugar de Container con margin
      padding: EdgeInsets.symmetric(vertical: size.height * 0.02, horizontal: size.width * 0.05),
      child: TextFormField(
        style: GoogleFonts.lato(color: AppColors.textBlack, fontSize: size.width * 0.04),
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search, color: AppColors.textBlack.withValues(alpha: 0.7), size: size.width * 0.055),
          filled: true,
          fillColor: Colors.white,
          hintText: 'Buscar torneos, jugadores...',
          hintStyle: GoogleFonts.lato(color: AppColors.textBlack.withValues(alpha: 0.5), fontSize: size.width * 0.04),
          contentPadding: EdgeInsets.symmetric(vertical: size.height * 0.018, horizontal: size.width * 0.04), // Ajustado
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
        ),
      ),
    );
  }
}

class PlayerAppBar extends StatelessWidget {
  const PlayerAppBar({
    super.key,
    required this.size,
    this.playerName,
    this.playerStatus,
  });

  final Size size;
  final String? playerName;
  final String? playerStatus;

  @override
  Widget build(BuildContext context) {
    String displayName = playerName ?? 'Jugador';
    // Color statusColor = _getStatusColor(playerStatus);

    return Container(
      width: size.width,
      padding: EdgeInsets.only(
        top: size.height * 0.015,
        bottom: size.height * 0.015,
        left: size.width * 0.05,
        right: size.width * 0.05,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                /*Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),*/
                // const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hola,',
                        style: GoogleFonts.lato(
                          fontSize: size.width * 0.045,
                          color: AppColors.textBlack.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        displayName,
                        style: GoogleFonts.lato(
                          fontSize: size.width * 0.055,
                          color: AppColors.textBlack,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.notifications_none_outlined,
              color: AppColors.textBlack,
              size: size.width * 0.07,
            ),
            onPressed: () { /* Lógica para notificaciones */ },
          ),
        ],
      ),
    );
  }

/*  Color _getStatusColor(String? status) {
    switch (status) {
      case 'disponible':
        return Colors.green;
      case 'en cola':
        return Colors.yellow;
      case 'en partida':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }*/
}