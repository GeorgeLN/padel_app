import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:padel_app/features/design/app_colors.dart';
import 'package:padel_app/models/user_model.dart'; // Importar el modelo de usuario
import 'package:padel_app/viewmodels/auth_viewmodel.dart'; // Importar AuthViewModel
import 'package:provider/provider.dart'; // Importar Provider
import 'dart:async'; // Importar dart:async para Future.microtask

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
    // Usar Future.microtask para asegurar que el contexto esté disponible
    // y Provider.of se llame después de que el widget esté completamente inicializado.
    Future.microtask(() {
      if (mounted) { // Comprobar si el widget sigue montado
        final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
        // Comprobar si _userDataFuture ya ha sido asignado para evitar reasignaciones
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

    // Si _userDataFuture es null (aún no se ha llamado a initState o microtask),
    // muestra un indicador de carga. Esto evita un error de null en FutureBuilder.
    if (_userDataFuture == null) {
      return Scaffold(
        backgroundColor: AppColors.primaryBlue,
        appBar: AppBar(
          backgroundColor: AppColors.primaryBlue,
          title: Text('Perfil'),
          titleTextStyle: GoogleFonts.lato(
            color: AppColors.textWhite,
            fontSize: size.width * 0.06,
            fontWeight: FontWeight.bold,
          ),
          centerTitle: true,
        ),
        body: Center(child: CircularProgressIndicator(color: AppColors.primaryGreen)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: Text('Perfil'),
        titleTextStyle: GoogleFonts.lato(
          color: AppColors.textWhite,
          fontSize: size.width * 0.06,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<Usuario?>(
        future: _userDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: AppColors.primaryGreen));
          } else if (snapshot.hasError) {
            return Center(
                child: Text('Error al cargar datos: ${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textWhite, fontSize: size.width * 0.04)));
          } else if (snapshot.hasData && snapshot.data != null) {
            final usuario = snapshot.data!;
            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Container(
                width: size.width,
                padding: EdgeInsets.only(bottom: size.height * 0.02), // Padding inferior general
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
                                image: DecorationImage(
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
                                      size: size.width * 0.08, // Ajustado
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
                                            fontSize: size.width * 0.04, // Ajustado
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        TextSpan(
                                          text: '${(usuario.efectividad * 100).toStringAsFixed(0)}%',
                                          style: GoogleFonts.lato(
                                            color: AppColors.primaryGreen,
                                            fontSize: size.width * 0.04, // Ajustado
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
                    ConfigurationButton(size: size),
                  ],
                ),
              ),
            );
          } else {
            final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
            String errorMessage = authViewModel.errorMessage ?? 'No se encontraron datos del usuario.';
            return Center(
                child: Text(errorMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textWhite, fontSize: size.width * 0.04)));
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
  });

  final Size size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.width * 0.9,
      height: size.height * 0.06,
      margin: EdgeInsets.only(bottom: size.height * 0.01), // Margen inferior ajustado
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          shape: RoundedRectangleBorder( // Bordes redondeados
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: () {
          // Lógica para configuración de perfil
        },
        child: Text(
          'Configurar Perfil', // Texto cambiado
          style: GoogleFonts.lato(
            color: AppColors.textBlack,
            fontSize: size.width * 0.045, // Ajustado
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
    return Container( // Envuelto en Container para padding
      width: size.width * 0.9, // Ancho igual al de ConfigurationButton
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.025), // Padding horizontal
      child: RichText(
        textAlign: TextAlign.start,
        text: TextSpan(
          style: GoogleFonts.lato( // Estilo base
            color: AppColors.textWhite,
            fontSize: size.width * 0.04, // Tamaño base ajustado
          ),
          children: [
            TextSpan(
              text: '${usuario.nombre}\n',
              style: TextStyle(
                fontSize: size.width * 0.05, // Más grande para el nombre
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(
              text: '${usuario.descripcionPerfil}\n', // Solo un \n
              style: TextStyle(
                fontWeight: FontWeight.w400,
                height: 1.4, // Interlineado
              ),
            ),
            // Puedes añadir más información si es necesario, por ejemplo:
            // TextSpan(text: '\nCorreo: ${usuario.correoElectronico}\n'),
            // TextSpan(text: 'Puntos Totales: ${usuario.puntos}'),
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
      borderRadius: BorderRadius.circular(15), // Radio de borde ajustado
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          width: size.width * 0.8,
          height: size.height * 0.14, // Altura ligeramente ajustada
          padding: EdgeInsets.symmetric(vertical: size.height * 0.01, horizontal: size.width * 0.02),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withOpacity(0.5), // Color con opacidad
            borderRadius: BorderRadius.circular(15), // Consistente con ClipRRect
            border: Border.all(color: AppColors.primaryGreen.withOpacity(0.5), width: 1), // Borde sutil
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
    return Expanded( // Para que los items ocupen espacio equitativamente
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center, // Centrar contenido del item
        children: [
          Container(
            padding: EdgeInsets.all(size.width * 0.015),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8), // Borde más suave
              color: AppColors.primaryGreen,
            ),
            child: Icon(
              icon,
              color: AppColors.textBlack,
              size: size.width * 0.055, // Icono ligeramente más pequeño
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
                  fontSize: size.width * 0.032, // Fuente más pequeña
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.lato(
                  color: AppColors.primaryGreen,
                  fontSize: size.width * 0.032, // Fuente más pequeña
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
      width: 1.5, // Ancho del divisor
      height: size.height * 0.035, // Altura ajustada
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: AppColors.primaryGreen.withOpacity(0.7), // Opacidad
      ),
    );
  }

  Widget _buildBottomStatItem(BuildContext context, IconData icon, String value, String label, Size size) {
    return Expanded( // Para que los items ocupen espacio equitativamente
      child: Container(
        padding: EdgeInsets.symmetric(vertical: size.width * 0.01, horizontal: size.width * 0.015),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8), // Borde más suave
          color: AppColors.primaryBlue.withOpacity(0.7), // Color con más opacidad
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center, // Centrar contenido del item
          children: [
            Icon(
              icon,
              color: AppColors.primaryGreen,
              size: size.width * 0.055, // Icono ligeramente más pequeño
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
                    fontSize: size.width * 0.032, // Fuente más pequeña
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  label,
                  style: GoogleFonts.lato(
                    color: AppColors.primaryGreen,
                    fontSize: size.width * 0.032, // Fuente más pequeña
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