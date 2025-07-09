import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:padel_app/features/design/app_colors.dart';
import 'package:padel_app/models/user_model.dart';
import 'package:padel_app/viewmodels/auth_viewmodel.dart';
import 'package:provider/provider.dart';
import 'dart:async';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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
        backgroundColor: AppColors.primaryBlue,
        appBar: AppBar(
          backgroundColor: AppColors.primaryBlue,
          title: Text('Perfil', style: GoogleFonts.lato(color: AppColors.textWhite, fontSize: size.width * 0.06, fontWeight: FontWeight.bold)),
          centerTitle: true,
          iconTheme: const IconThemeData(color: AppColors.textWhite),
        ),
        body: Center(child: CircularProgressIndicator(color: AppColors.primaryGreen)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: Text('Perfil', style: GoogleFonts.lato(color: AppColors.textWhite, fontSize: size.width * 0.06, fontWeight: FontWeight.bold)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textWhite),
      ),
      body: FutureBuilder<Usuario?>(
        future: _userDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: AppColors.primaryGreen));
          } else if (snapshot.hasError) {
            return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Error al cargar datos: ${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textWhite, fontSize: size.width * 0.04)),
                ));
          } else if (snapshot.hasData && snapshot.data != null) {
            final usuario = snapshot.data!;
            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Container(
                width: size.width,
                padding: EdgeInsets.only(bottom: size.height * 0.02),
                child: Column(
                  children: [
                    Container(
                      width: size.width * 0.9,
                      height: size.height * 0.44,
                      child: Stack(
                        children: [
                          Positioned(
                            top: 0,
                            child: Container(
                              width: size.width * 0.9,
                              height: size.height * 0.35,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                image: const DecorationImage(
                                  image: AssetImage('assets/images/profile_image.png'),
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: size.height * 0.01,
                            left: size.width * 0.065,
                            child: Container(
                              width: size.width * 0.7,
                              height: size.height * 0.05,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: size.width * 0.12,
                                    height: size.height * 0.05,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: AppColors.primaryGreen,
                                    ),
                                    child: Icon(
                                      Icons.show_chart_rounded,
                                      color: AppColors.textBlack,
                                      size: size.width * 0.08,
                                    ),
                                  ),
                                  SizedBox(width: size.width * 0.02),
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'Eficiencia ',
                                          style: GoogleFonts.lato(
                                            color: AppColors.textWhite,
                                            fontSize: size.width * 0.04,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        TextSpan(
                                          text: '${(usuario.efectividad * 100).toStringAsFixed(0)}%',
                                          style: GoogleFonts.lato(
                                            color: AppColors.primaryGreen,
                                            fontSize: size.width * 0.04,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: size.width * 0.05,
                            child: BlurContainer(size: size, usuario: usuario),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: size.height * 0.02),
                    PlayerDescription(size: size, usuario: usuario),
                    SizedBox(height: size.height * 0.02),
                    ConfigurationButton(size: size, usuario: usuario), // Pasar usuario para la navegación
                  ],
                ),
              ),
            );
          } else {
            final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
            String errorMessage = authViewModel.errorMessage ?? 'No se encontraron datos del usuario.';
            return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(errorMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textWhite, fontSize: size.width * 0.04)),
                ));
          }
        },
      ),
    );
  }
}

class ConfigurationButton extends StatelessWidget {
  const ConfigurationButton({
    super.key,
    required this.size,
    required this.usuario, // Recibir el usuario
  });

  final Size size;
  final Usuario usuario; // Usuario para pasar a la página de edición

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.width * 0.9,
      height: size.height * 0.06,
      margin: EdgeInsets.only(bottom: size.height * 0.01),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditProfileDataPage(userId: ''),
            ),
          );
        },
        child: Text(
          'Editar Perfil', // Cambiado de 'Configurar'
          style: GoogleFonts.lato(
            color: AppColors.textBlack,
            fontSize: size.width * 0.045,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class PlayerDescription extends StatelessWidget {
  const PlayerDescription({
    super.key,
    required this.size,
    required this.usuario,
  });

  final Size size;
  final Usuario usuario;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.width * 0.9,
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.025),
      child: RichText(
        textAlign: TextAlign.start,
        text: TextSpan(
          style: GoogleFonts.lato(
            color: AppColors.textWhite,
            fontSize: size.width * 0.04,
          ),
          children: [
            TextSpan(
              text: '${usuario.nombre}\n',
              style: TextStyle(
                fontSize: size.width * 0.05,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(
              text: usuario.descripcionPerfil.isNotEmpty ? '${usuario.descripcionPerfil}\n' : 'Sin descripción disponible.\n',
              style: TextStyle(
                fontWeight: FontWeight.w400,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BlurContainer extends StatelessWidget {
  const BlurContainer({
    super.key,
    required this.size,
    required this.usuario,
  });

  final Size size;
  final Usuario usuario;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          width: size.width * 0.8,
          height: size.height * 0.14,
          padding: EdgeInsets.symmetric(vertical: size.height * 0.01, horizontal: size.width * 0.02),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withOpacity(0.5),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppColors.primaryGreen.withOpacity(0.5), width: 1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildStatItem(context, Icons.stars_rounded, 'Ranking', '${usuario.ranking}', size),
                  _buildDivider(size),
                  _buildStatItem(context, Icons.event_available_rounded, 'Asistencias', '${usuario.asistencias}', size),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildBottomStatItem(context, Icons.control_point_duplicate_rounded, '${usuario.puntos}', 'Puntos', size),
                  _buildBottomStatItem(context, Icons.add_reaction_rounded, '${usuario.bonificaciones}', 'Bonos', size),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, IconData icon, String label, String value, Size size) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(size.width * 0.015),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: AppColors.primaryGreen,
            ),
            child: Icon(
              icon,
              color: AppColors.textBlack,
              size: size.width * 0.055,
            ),
          ),
          SizedBox(width: size.width * 0.02),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: GoogleFonts.lato(
                  color: AppColors.textWhite,
                  fontSize: size.width * 0.032,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.lato(
                  color: AppColors.primaryGreen,
                  fontSize: size.width * 0.032,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildDivider(Size size) {
    return Container(
      width: 1.5,
      height: size.height * 0.035,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: AppColors.primaryGreen.withOpacity(0.7),
      ),
    );
  }

  Widget _buildBottomStatItem(BuildContext context, IconData icon, String value, String label, Size size) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: size.width * 0.01, horizontal: size.width * 0.015),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: AppColors.primaryBlue.withOpacity(0.7),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: AppColors.primaryGreen,
              size: size.width * 0.055,
            ),
            SizedBox(width: size.width * 0.02),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: GoogleFonts.lato(
                    color: AppColors.textWhite,
                    fontSize: size.width * 0.032,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  label,
                  style: GoogleFonts.lato(
                    color: AppColors.primaryGreen,
                    fontSize: size.width * 0.032,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}