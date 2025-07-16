import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:padel_app/features/design/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:padel_app/data/models/quedada_model.dart';
import 'package:padel_app/features/pages/room_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:padel_app/data/viewmodels/auth_viewmodel.dart';

class TournamentCard extends StatelessWidget {
  const TournamentCard({
    super.key,
    required this.size,
    required this.quedada,
    required this.authViewModel,
  });

  final Size size;
  final Quedada quedada;
  final AuthViewModel authViewModel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.width * 0.8,
      height: size.height * 0.22,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        image: DecorationImage(
          image: const AssetImage('assets/images/tournament_image1.png'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              quedada.lugar,
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
                    _buildTournamentInfoChip(size, Icons.calendar_today_outlined, '${quedada.fecha} - ${quedada.hora}'),
                    SizedBox(height: size.height * 0.008),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RoomPage(quedadaId: quedada.id)),
                    );
                  },
                  child: Container(
                    width: size.width * 0.13,
                    height: size.width * 0.13,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryGreen,
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
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
