import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:padel_app/features/design/app_colors.dart';
import 'package:padel_app/models/user_model.dart';
import 'package:padel_app/viewmodels/auth_viewmodel.dart';
import 'package:provider/provider.dart';
import 'dart:async';

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
            'Torneos Principales',
            style: GoogleFonts.lato(
              fontSize: size.width * 0.05,
              color: AppColors.textBlack,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: size.height * 0.015),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(), // Efecto de rebote
            child: Row(
              children: List.generate(3, (index) => Padding( // Generar 3 tarjetas de ejemplo
                padding: EdgeInsets.only(right: size.width * 0.04), // Espacio entre tarjetas
                child: TournamentCard(size: size, index: index),
              )),
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
    required this.index, // Para diferenciar las tarjetas de ejemplo
  });

  final Size size;
  final int index;

  @override
  Widget build(BuildContext context) {
    // Datos de ejemplo para las tarjetas
    final tournamentNames = ['Torneo de Verano', 'Copa Invierno', 'Liga Master'];
    final tournamentImages = [
      'assets/images/tournament_image1.png', // Asegúrate que estas imágenes existan
      'assets/images/padel_player.png',     // o usa placeholders
      'assets/images/profile_image.png',
    ];

    return Container(
      width: size.width * 0.8,
      height: size.height * 0.22, // Ligeramente más alto
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        image: DecorationImage(
          image: AssetImage(tournamentImages[index % tournamentImages.length]),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode( // Filtro para oscurecer un poco la imagen
            Colors.black.withOpacity(0.3),
            BlendMode.darken,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(size.width * 0.04),
        child: Column( // Cambiado a Column para mejor distribución vertical
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Espacio entre elementos principales
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tournamentNames[index % tournamentNames.length],
              style: GoogleFonts.lato(
                fontSize: size.width * 0.055,
                color: AppColors.textWhite,
                fontWeight: FontWeight.w900,
                shadows: [
                  Shadow(blurRadius: 3.0, color: Colors.black.withOpacity(0.6), offset: const Offset(1.5, 1.5)),
                ],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTournamentInfoChip(size, Icons.calendar_today_outlined, '15-20 Julio'), // Info de ejemplo
                    SizedBox(height: size.height * 0.008),
                    _buildTournamentInfoChip(size, Icons.groups_rounded, 'Equipos de 2'), // Info de ejemplo
                  ],
                ),
                GestureDetector(
                  onTap: () { /* Acción al presionar */ },
                  child: Container(
                    width: size.width * 0.13,
                    height: size.width * 0.13,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryGreen,
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded, // Icono cambiado
                      color: AppColors.textBlack,
                      size: size.width * 0.06,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTournamentInfoChip(Size size, IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.02, vertical: size.height * 0.006),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: AppColors.textWhite.withOpacity(0.85),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.textBlack, size: size.width * 0.035),
          SizedBox(width: size.width * 0.015),
          Text(
            text,
            style: GoogleFonts.lato(
              fontSize: size.width * 0.028,
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