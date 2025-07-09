
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:padel_app/features/design/app_colors.dart';
import 'package:padel_app/models/user_model.dart'; // Importar el modelo de usuario
import 'package:padel_app/viewmodels/auth_viewmodel.dart'; // Importar AuthViewModel
import 'package:provider/provider.dart'; // Importar Provider
import 'dart:async'; // Para Future.microtask

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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    if (_userDataFuture == null) {
      return Scaffold(
        backgroundColor: const Color.fromARGB(234, 255, 255, 255),
        body: Center(child: CircularProgressIndicator(color: AppColors.primaryGreen)),
      );
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(234, 255, 255, 255),
      body: FutureBuilder<Usuario?>(
        future: _userDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: AppColors.primaryGreen));
          } else if (snapshot.hasError) {
            // Muestra un PlayerAppBar genérico si hay error o no hay datos aún
            return _buildHomePageContent(size, context, null);
          } else if (snapshot.hasData && snapshot.data != null) {
            final usuario = snapshot.data!;
            return _buildHomePageContent(size, context, usuario);
          } else {
            // Muestra un PlayerAppBar genérico si no hay datos del usuario
            return _buildHomePageContent(size, context, null);
          }
        },
      ),
    );
  }

  Widget _buildHomePageContent(Size size, BuildContext context, Usuario? usuario) {
    // Extraer el primer nombre si el usuario existe
    String? primerNombre;
    if (usuario != null && usuario.nombre.isNotEmpty) {
      primerNombre = usuario.nombre.split(' ').first;
    }

    return SingleChildScrollView( // Añadido SingleChildScrollView para evitar overflow si el contenido es largo
      child: Column(
        children: [
          PlayerAppBar(size: size, playerName: primerNombre), // Pasar el primer nombre
          SearchWhiteText(size: size),
          MajorTournaments(size: size),
        ],
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
      width: size.width * 0.9,
      margin: EdgeInsets.only(top: size.height * 0.02, left: size.width * 0.05, right: size.width * 0.05), // Añadido margen derecho
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Torneos Principales',
            style: GoogleFonts.lato(
              fontSize: size.width * 0.05,
              color: AppColors.textBlack,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: size.height * 0.01), // Espacio añadido
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                TournamentCard(size: size),
                SizedBox(width: size.width * 0.05),
                TournamentCard(size: size),
                SizedBox(width: size.width * 0.05),
                TournamentCard(size: size),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TournamentCard extends StatelessWidget {
  const TournamentCard({
    super.key,
    required this.size,
  });

  final Size size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.width * 0.8,
      height: size.height * 0.2,
      margin: EdgeInsets.only(top: size.height * 0.005),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        image: DecorationImage(
          image: AssetImage('assets/images/tournament_image1.png'),
          fit: BoxFit.cover,
        ),
        boxShadow: [ // Sombra añadida para profundidad
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding( // Padding interno para el contenido de la tarjeta
        padding: EdgeInsets.all(size.width * 0.03),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Ajustado para espacio entre elementos
          children: [
            Expanded( // Para que la columna ocupe el espacio disponible
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround, // Distribución del espacio
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Torneo de Verano', // Nombre de ejemplo
                    style: GoogleFonts.lato(
                      fontSize: size.width * 0.06, // Tamaño ajustado
                      color: AppColors.textWhite,
                      fontWeight: FontWeight.w900,
                      shadows: [ // Sombra para el texto para mejor legibilidad
                        Shadow(
                          blurRadius: 2.0,
                          color: Colors.black.withOpacity(0.5),
                          offset: Offset(1.0, 1.0),
                        ),
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  _buildTournamentInfoChip(size, Icons.local_fire_department_outlined, 'Inscripciones abiertas'),
                  _buildTournamentInfoChip(size, Icons.timer_outlined, '2 horas de juego'),
                ],
              ),
            ),
            SizedBox(width: size.width * 0.02), // Espacio antes del botón
            GestureDetector(
              onTap: () {
                // Lógica al presionar el botón
              },
              child: Container(
                width: size.width * 0.15, // Tamaño ajustado
                height: size.width * 0.15, // Tamaño ajustado para hacerlo circular
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryGreen,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.play_arrow_rounded,
                  color: AppColors.textBlack,
                  size: size.width * 0.08, // Tamaño ajustado
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTournamentInfoChip(Size size, IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.02, vertical: size.height * 0.005),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: AppColors.textWhite.withOpacity(0.8), // Color con opacidad
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // Para que el Row no ocupe más de lo necesario
        children: [
          Icon(
            icon,
            color: AppColors.textBlack,
            size: size.width * 0.04, // Tamaño ajustado
          ),
          SizedBox(width: size.width * 0.015),
          Text(
            text,
            style: GoogleFonts.lato(
              fontSize: size.width * 0.03, // Tamaño ajustado
              color: AppColors.textBlack,
              fontWeight: FontWeight.bold,
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
    return Container(
      width: size.width * 0.9,
      margin: EdgeInsets.symmetric(vertical: size.height * 0.02, horizontal: size.width * 0.05), // Margen simétrico
      child: TextFormField(
        style: GoogleFonts.lato(color: AppColors.textBlack, fontSize: size.width * 0.04),
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search, color: AppColors.textBlack.withOpacity(0.7), size: size.width * 0.055),
          filled: true,
          fillColor: Colors.white,
          hintText: 'Buscar torneos, jugadores...', // Texto de ejemplo más descriptivo
          hintStyle: GoogleFonts.lato(color: AppColors.textBlack.withOpacity(0.5), fontSize: size.width * 0.04),
          contentPadding: EdgeInsets.symmetric(vertical: size.height * 0.015, horizontal: size.width * 0.04), // Padding interno
          enabledBorder: OutlineInputBorder( // Borde cuando no está enfocado
            borderRadius: BorderRadius.circular(12), // Radio de borde ajustado
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primaryGreen, width: 1.5), // Borde cuando está enfocado
          ),
          border: OutlineInputBorder( // Borde por defecto
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
    this.playerName, // Hacer el nombre opcional
  });

  final Size size;
  final String? playerName;

  @override
  Widget build(BuildContext context) {
    String displayName = playerName ?? 'Jugador'; // Nombre por defecto si es null o vacío

    return Container(
      width: size.width, // Ocupar todo el ancho
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + size.height * 0.015, // Padding superior seguro + margen
        bottom: size.height * 0.015,
        left: size.width * 0.05,
        right: size.width * 0.05,
      ),
      decoration: BoxDecoration( // Fondo y sombra para el AppBar personalizado
        color: const Color.fromARGB(234, 255, 255, 255), // O el color de fondo que prefieras
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hola,', // Cambiado el texto
                style: GoogleFonts.lato(
                  fontSize: size.width * 0.045, // Tamaño ajustado
                  color: AppColors.textBlack.withOpacity(0.7), // Color más suave
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                displayName, // Mostrar el primer nombre o 'Jugador'
                style: GoogleFonts.lato(
                  fontSize: size.width * 0.055, // Tamaño ajustado
                  color: AppColors.textBlack,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis, // Evitar overflow del nombre
              ),
            ],
          ),
          IconButton( // Cambiado a IconButton para mejor accesibilidad
            icon: Icon(
              Icons.notifications_active_outlined,
              color: AppColors.textBlack,
              size: size.width * 0.07, // Tamaño ajustado
            ),
            onPressed: () {
              // Lógica para notificaciones
            },
          ),
        ],
      ),
    );
  }
}