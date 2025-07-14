import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:padel_app/features/design/app_colors.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:padel_app/data/models/quedada_model.dart';
import 'package:padel_app/features/pages/room_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:padel_app/features/widgets/tournament_card.dart';

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
    _crearQuedadasDeEjemplo();
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

  void _crearQuedadasDeEjemplo() async {
    final quedadasRef = FirebaseFirestore.instance.collection('quedadas');
    final snapshot = await quedadasRef.limit(1).get();
    if (snapshot.docs.isEmpty) {
      await quedadasRef.add({
        'lugar': 'Padel Club Indoor',
        'fecha': Timestamp.now(),
        'hora': '18:00',
        'jugadores': [],
        'equipo1': [],
        'equipo2': [],
      });
      await quedadasRef.add({
        'lugar': 'Club de Tenis y Padel',
        'fecha': Timestamp.fromDate(DateTime.now().add(const Duration(days: 1))),
        'hora': '20:00',
        'jugadores': [],
        'equipo1': [],
        'equipo2': [],
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
    if (usuario != null && usuario.nombre.isNotEmpty) {
      primerNombre = usuario.nombre.split(' ').first;
    }

    return SafeArea( // Envolver con SafeArea
      child: SingleChildScrollView(
        child: Column(
          children: [
            PlayerAppBar(size: size, playerName: primerNombre),
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
      width: size.width, // Ocupar todo el ancho disponible
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.05), // Padding horizontal
      margin: EdgeInsets.only(top: size.height * 0.02),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Partidas Disponibles',
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
              stream: FirebaseFirestore.instance.collection('quedadas').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No hay quedadas disponibles.'));
                }

                final quedadas = snapshot.data!.docs.map((doc) => Quedada.fromFirestore(doc)).toList();

                final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: quedadas.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(right: size.width * 0.04),
                      child: TournamentCard(size: size, quedada: quedadas[index], authViewModel: authViewModel),
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
          prefixIcon: Icon(Icons.search, color: AppColors.textBlack.withOpacity(0.7), size: size.width * 0.055),
          filled: true,
          fillColor: Colors.white,
          hintText: 'Buscar torneos, jugadores...',
          hintStyle: GoogleFonts.lato(color: AppColors.textBlack.withOpacity(0.5), fontSize: size.width * 0.04),
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
  });

  final Size size;
  final String? playerName;

  @override
  Widget build(BuildContext context) {
    String displayName = playerName ?? 'Jugador';

    return Container(
      width: size.width,
      padding: EdgeInsets.only(
        top: size.height * 0.015, // Reducido, SafeArea se encarga del padding superior del sistema
        bottom: size.height * 0.015,
        left: size.width * 0.05,
        right: size.width * 0.05,
      ),
      // No añadir BoxDecoration aquí si quieres que sea transparente y se vea el fondo del Scaffold
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded( // Para que la columna del nombre pueda expandirse y elipsis funcione
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hola,',
                  style: GoogleFonts.lato(
                    fontSize: size.width * 0.045,
                    color: AppColors.textBlack.withOpacity(0.8), // Ligeramente más visible
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
          IconButton(
            icon: Icon(
              Icons.notifications_none_outlined, // Icono cambiado a la versión no activa
              color: AppColors.textBlack,
              size: size.width * 0.07,
            ),
            onPressed: () { /* Lógica para notificaciones */ },
          ),
        ],
      ),
    );
  }
}