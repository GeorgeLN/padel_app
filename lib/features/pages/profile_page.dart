
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:padel_app/features/design/app_colors.dart';

class ProfilePage extends StatelessWidget {
   
  const ProfilePage({super.key});
  
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

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

      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,

        child: Container(
          width: size.width,

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
                      top: 0,
          
                      child: Container(
                        width: size.width * 0.47,
                        height: size.height * 0.05,
                        margin: EdgeInsets.only(left: size.width * 0.065),
          
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: size.width * 0.12,
                              height: size.height * 0.05,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: AppColors.primaryGreen,
                              ),
                              child: Icon(
                                Icons.local_fire_department_outlined,
                                color: AppColors.textBlack,
                                size: size.width * 0.1,
                              ),
                            ),
          
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Eficiencia ',
                                    style: GoogleFonts.lato(
                                      color: AppColors.textWhite,
                                      fontSize: size.width * 0.05,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '68%',
                                    style: GoogleFonts.lato(
                                      color: AppColors.primaryGreen,
                                      fontSize: size.width * 0.05,
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

                      //Blur con estadísticas.
                      child: BlurContainer(size: size),
                    ),
                  ],
                ),
              ),
          
              SizedBox(height: size.height * 0.02),

              //Descripción de los jugadores.
              PlayerDescription(size: size),

              SizedBox(height: size.height * 0.02),

              //Botón de configuración de perfil.
              ConfigurationButton(size: size),
            ],
          ),
        ),
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
      margin: EdgeInsets.only(bottom: size.height * 0.03),
    
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
        ),
    
        onPressed: () {},
    
        child: Text(
          'Configurar',
          style: GoogleFonts.lato(
            color: AppColors.textBlack,
            fontSize: size.width * 0.05,
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
  });

  final Size size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size.width * 0.95,
      child: RichText(
        textAlign: TextAlign.start,
              
        text: TextSpan(
          children: [
            //Descripción.
            TextSpan(
              text: 'Jugadora activa de Pádel desde 2022.\n',
              style: GoogleFonts.lato(
                color: AppColors.textWhite,
                fontSize: size.width * 0.045,
                fontWeight: FontWeight.w400,
              ),
            ),
            TextSpan(
              text: 'Juega principalmente los fines de semana (viernes a domingo) en horario de 7am a 11am.\n\n',
              style: GoogleFonts.lato(
                color: AppColors.textWhite,
                fontSize: size.width * 0.045,
                fontWeight: FontWeight.w400,
              ),
            ),
              
            //Nivel
            TextSpan(
              text: 'Nivel: ',
              style: GoogleFonts.lato(
                color: AppColors.textWhite,
                fontSize: size.width * 0.045,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(
              text: 'Intermedio | Frecuencia: 2-3 veces por semana.\n\n',
              style: GoogleFonts.lato(
                color: AppColors.textWhite,
                fontSize: size.width * 0.045,
                fontWeight: FontWeight.w400,
              ),
            ),
              
            //Ocupación.
            TextSpan(
              text: 'Ocupación: ',
              style: GoogleFonts.lato(
                color: AppColors.textWhite,
                fontSize: size.width * 0.045,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(
              text: 'Dueña de un negocio de ropa deportiva.\n\n',
              style: GoogleFonts.lato(
                color: AppColors.textWhite,
                fontSize: size.width * 0.045,
                fontWeight: FontWeight.w400,
              ),
            ),
              
            //Hobbies.
            TextSpan(
              text: 'Hobbies: ',
              style: GoogleFonts.lato(
                color: AppColors.textWhite,
                fontSize: size.width * 0.045,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(
              text: 'Le gusta participar en torneos recreativos y está abierta a unirse a nuevos grupos.\n\n',
              style: GoogleFonts.lato(
                color: AppColors.textWhite,
                fontSize: size.width * 0.045,
                fontWeight: FontWeight.w400,
              ),
            ),
    
            //Última participación.
            TextSpan(
              text: 'Última participación: ',
              style: GoogleFonts.lato(
                color: AppColors.textWhite,
                fontSize: size.width * 0.045,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(
              text: 'Torneo Copa 2 - Abril 2025',
              style: GoogleFonts.lato(
                color: AppColors.textWhite,
                fontSize: size.width * 0.045,
                fontWeight: FontWeight.w400,
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
  });

  final Size size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      
        child: Container(
          width: size.width * 0.8,
          height: size.height * 0.15,
          color: Colors.black.withValues(alpha: 0.25), //alpha equivale a la Opacidad.
        
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly, //Separación entre secciones.
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly, //Separación entre primeros elementos.
        
                children: [
                  //Primer elemento.
                  Row(
                    children: [
                      Container(
                        width: size.width * 0.1,
                        height: size.height * 0.05,
                        
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: AppColors.primaryGreen,
                        ),
                        child: Icon(
                          Icons.local_fire_department_outlined,
                          color: AppColors.textBlack,
                          size: size.width * 0.08,
                        ),
                      ),
                          
                      SizedBox(width: size.width * 0.01),
                          
                      Column(
                        children: [
                          Text(
                            'Ranking',
                            style: GoogleFonts.lato(
                              color: AppColors.textWhite,
                              fontSize: size.width * 0.04,	
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '45',
                            style: GoogleFonts.lato(
                              color: AppColors.primaryGreen,
                              fontSize: size.width * 0.04,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
        
                  //División.
                  Container(
                    width: size.width * 0.003,
                    height: size.height * 0.05,
                    margin: EdgeInsets.only(left: size.width * 0.035),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: AppColors.primaryGreen,
                    ),
                  ),
        
                  //Segundo elemento.
                  Row(
                    children: [
                      Container(
                        width: size.width * 0.1,
                        height: size.height * 0.05,

                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: AppColors.primaryGreen,
                        ),
                        child: Icon(
                          Icons.timer_outlined,
                          color: AppColors.textBlack,
                          size: size.width * 0.08,
                        ),
                      ),
                          
                      SizedBox(width: size.width * 0.01),
                          
                      Column(
                        children: [
                          Text(
                            'Asistencia',
                            style: GoogleFonts.lato(
                              color: AppColors.textWhite,
                              fontSize: size.width * 0.04,	
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '45%',
                            style: GoogleFonts.lato(
                              color: AppColors.primaryGreen,
                              fontSize: size.width * 0.04,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    width: size.width * 0.35,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: const Color.fromARGB(255, 43, 100, 45),
                    ) ,
                    padding: EdgeInsets.all(size.width * 0.01),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Icon(
                          Icons.balance_sharp,
                          color: AppColors.primaryGreen,
                          size: size.width * 0.08,
                        ),
        
                        SizedBox(width: size.width * 0.01),
        
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Intermedio',
                              style: GoogleFonts.lato(
                                color: AppColors.textWhite,
                                fontSize: size.width * 0.04,	
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'Nivel',
                              style: GoogleFonts.lato(
                                color: AppColors.primaryGreen,
                                fontSize: size.width * 0.04,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
        
                  Container(
                    width: size.width * 0.35,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: const Color.fromARGB(255, 43, 100, 45),
                    ) ,
                    padding: EdgeInsets.all(size.width * 0.01),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Icon(
                          Icons.group_sharp,
                          color: AppColors.primaryGreen,
                          size: size.width * 0.08,
                        ),
        
                        SizedBox(width: size.width * 0.01),
        
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '2-3 veces',
                              style: GoogleFonts.lato(
                                color: AppColors.textWhite,
                                fontSize: size.width * 0.04,	
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'por semana',
                              style: GoogleFonts.lato(
                                color: AppColors.textWhite,
                                fontSize: size.width * 0.04,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ) 
            ],
          ),
        ),
      ),
    );
  }
}