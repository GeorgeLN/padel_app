
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:padel_app/features/design/app_colors.dart';

class HomePage extends StatelessWidget {
   
  const HomePage({super.key});
  
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: const Color.fromARGB(234, 255, 255, 255),
      body: Column(
        children: [
          PlayerAppBar(size: size),

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
      margin: EdgeInsets.only(top: size.height * 0.02, left: size.width * 0.05),
      
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
      ),
    
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
    
            children: [
              Text(
                'Torneo 1',
                style: GoogleFonts.lato(
                  fontSize: size.width * 0.08,
                  color: AppColors.textWhite,
                  fontWeight: FontWeight.w900,
                ),
              ),
    
              Container(
                width: size.width * 0.5,
                height: size.height * 0.04,
                margin: EdgeInsets.only(top: size.height * 0.025),

                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color.fromARGB(255, 186, 193, 199),
                ),
    
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  
                  children: [
                    Icon(
                      Icons.local_fire_department_outlined,
                      color: AppColors.textBlack,
                      size: size.width * 0.05,
                    ),
    
                    SizedBox(width: size.width * 0.02),
    
                    Text(
                      'Inscripciones abiertas',
                      style: GoogleFonts.lato(
                        fontSize: size.width * 0.04,
                        color: AppColors.textBlack,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
    
              Container(
                width: size.width * 0.4,
                height: size.height * 0.04,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color.fromARGB(255, 186, 193, 199),
                ),
    
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      color: AppColors.textBlack,
                      size: size.width * 0.05,
                    ),
    
                    SizedBox(width: size.width * 0.02),
    
                    Text(
                      '2 horas de juego',
                      style: GoogleFonts.lato(
                        fontSize: size.width * 0.04,
                        color: AppColors.textBlack,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
    
          GestureDetector(
            onTap: () {},
    
            child: Container(
              width: size.width * 0.2,
              height: size.height * 0.06,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryGreen,
              ),
    
              child: Icon(
                Icons.play_arrow_rounded,
                color: AppColors.textBlack,
                size: size.width * 0.1,
              ),
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
      margin: EdgeInsets.only(top: size.height * 0.02, left: size.width * 0.05),
    
      child: TextFormField(
        style: GoogleFonts.lato(color: AppColors.textBlack),
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search, color: AppColors.textBlack,),
          filled: true,
          fillColor: Colors.white,
          hintText: 'Buscar',
          hintStyle: GoogleFonts.lato(color: AppColors.textBlack),
            
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Colors.white, width: 1),
          ),
            
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Colors.white, width: 1),
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
  });

  final Size size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.width * 0.9,
      margin: EdgeInsets.only(top: size.height * 0.025, left: size.width * 0.05),
    
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hola!',
                style: GoogleFonts.lato(
                  fontSize: size.width * 0.05,
                  color: AppColors.textBlack,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '_playerName',
                style: GoogleFonts.lato(
                  fontSize: size.width * 0.06,
                  color: AppColors.textBlack,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Icon(
            Icons.notifications_active_outlined,
            color: AppColors.textBlack,
            size: size.width * 0.08,
          ),
        ],
      ),
    );
  }
}