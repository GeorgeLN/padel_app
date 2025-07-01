import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:padel_app/features/design/app_colors.dart';
import 'package:padel_app/features/pages/_pages.dart';

class StartPage extends StatelessWidget {
   
  const StartPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return Scaffold(
      //backgroundColor: Colors.red,
      body: Column(
        children: [
          Stack(
            children: [
              Container(
                width: width,
                height: height * 0.65,
                child: Image.asset(
                  'assets/images/padel_player.png',
                  fit: BoxFit.fill,
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  width: width,
                  height: height * 0.9, // Ajusta la altura del degradado según lo que necesites
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.white,
                      ],
                      stops: [0.55, 0.95],
                    ),
                  ),
                ),
              ),
            ],
          ),

          Container(
            width: width,
            color: Colors.white,
            
            child: Column(
              children: [
                Text(
                  'Tu Juego, Tu Comunidad,\nTu Ranking',
                  textAlign: TextAlign.center,

                  style: GoogleFonts.lato(
                    fontSize: width * 0.07,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textBlack,
                  ),
                ),

                Container(
                  width: width * 0.3,
                  height: height * 0.006,
                  
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.primaryBlack,
                      width: 1,
                    ),

                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        AppColors.primaryGreen,
                        AppColors.primaryBlack,
                      ],
                      stops: [0.5, 0.5],
                    ),
                  ),
                ),

                SizedBox(height: height * 0.015),

                Text(
                  'Juega, sube en el ranking y vive\nel padel como nunca antes.',
                  textAlign: TextAlign.center,

                  style: GoogleFonts.lato(
                    fontSize: width * 0.04,
                    color: AppColors.textLightGray,
                    fontWeight: FontWeight.w400,
                  ),
                ),

                SizedBox(height: height * 0.02),

                Container(
                  width: width * 0.9,

                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LandingPage(),
                        ),
                      );
                    },
                  
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlack,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      'Empecemos',
                      style: GoogleFonts.lato(
                        fontSize: width * 0.045,
                        color: AppColors.textWhite,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}