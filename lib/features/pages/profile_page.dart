import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:padel_app/features/design/app_colors.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../../data/models/user_model.dart';
import '../../data/viewmodels/auth_viewmodel.dart';
import 'auth_wrapper.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Future<ProfileData?>? _profileDataFuture;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
        setState(() {
          _profileDataFuture = authViewModel.getProfileData();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    if (_profileDataFuture == null) {
      return Scaffold(
        backgroundColor: AppColors.primaryBlue,
        appBar: AppBar(
          backgroundColor: AppColors.primaryBlue,
          title: Text('Perfil', style: GoogleFonts.lato(color: AppColors.textWhite, fontSize: size.width * 0.06, fontWeight: FontWeight.bold)),
          centerTitle: true,
          leading: Icon(Icons.abc_rounded, color: Colors.transparent),
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
        leading: Icon(Icons.abc_rounded, color: Colors.transparent),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.textWhite),
            onPressed: () async {
              await authViewModel.cerrarSesion();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AuthWrapper()));
            },
          )
        ],
      ),
      body: FutureBuilder<ProfileData?>(
        future: _profileDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen));
          } else if (snapshot.hasError) {
            return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Error al cargar datos: ${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textWhite, fontSize: size.width * 0.04)),
                ));
          } else if (snapshot.hasData && snapshot.data != null) {
            final profileData = snapshot.data!;
            final bestStats = profileData.bestStats;

            final displayUsuario = Usuario(
              uid: bestStats.uid,
              nombre: profileData.basicInfo.nombre,
              descripcionPerfil: profileData.basicInfo.descripcionPerfil,
              correoElectronico: profileData.basicInfo.correoElectronico,
              puntos: bestStats.puntos,
              asistencias: bestStats.asistencias,
              bonificaciones: bestStats.bonificaciones,
              penalizaciones: bestStats.penalizaciones,
              efectividad: bestStats.efectividad,
              subcategoria: bestStats.subcategoria,
              documento: profileData.basicInfo.documento,
            );

            return RefreshIndicator(
              onRefresh: () async {
                 final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
                 setState(() {
                    _profileDataFuture = authViewModel.getProfileData();
                 });
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                child: Container(
                  width: size.width,
                  padding: EdgeInsets.only(bottom: size.height * 0.02),
                  child: Column(
                    children: [
                      SizedBox(
                        width: size.width * 0.9,
                        height: size.height * 0.455,
                        child: Stack(
                          children: [
                            Positioned(
                              top: size.height * 0.0125,
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
                                        Icons.local_fire_department,
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
                                            text: '${(displayUsuario.efectividad).toStringAsFixed(0)}%',
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
                              child: BlurContainer(size: size, usuario: displayUsuario),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: size.height * 0.02),
                      PlayerDescription(size: size, usuario: displayUsuario),
                      SizedBox(height: size.height * 0.02),
                    ],
                  ),
                ),
              ),
            );
          } else {
            return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('No se encontraron datos del usuario.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textWhite, fontSize: size.width * 0.04)),
                ));
          }
        },
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
          padding: EdgeInsets.symmetric(vertical: size.height * 0.01, horizontal: size.width * 0.025),
          margin: EdgeInsets.only(bottom: size.height * 0.02),
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
                  Container(
                    width: size.width * 0.3,
                    child: _buildStatItem(context, Icons.emoji_events, 'Ranking', '${usuario.puntos}', size)
                  ),
                  Container(
                    width: size.width * 0.3,
                    child: _buildStatItem(context, Icons.check_circle_outline, 'Asistencia', '${usuario.asistencias}', size)
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: size.width * 0.3,
                    child: _buildStatItem(context, Icons.star, 'Bonos     ', '${usuario.bonificaciones}', size)
                  ),
                  Container(
                    width: size.width * 0.3,
                    child: _buildStatItem(context, Icons.warning_amber_rounded, 'Asistencia', '${usuario.penalizaciones}', size)
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, IconData icon, String label, String value, Size size) {
    return Row(
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
                fontWeight: FontWeight.bold,
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
    );
  }
}