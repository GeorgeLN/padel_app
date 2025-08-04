import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:padel_app/features/design/app_colors.dart';
import 'package:padel_app/features/pages/ranking_detail_page.dart';

class RankingListPage extends StatelessWidget {
  final String collectionName;
  final String title;

  const RankingListPage({
    super.key,
    required this.collectionName,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      appBar: AppBar(
        title: Text(title, style: GoogleFonts.lato(color: AppColors.textWhite)),
        centerTitle: true,
        backgroundColor: AppColors.secondBlack,
        iconTheme: const IconThemeData(color: AppColors.textWhite),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection(collectionName).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: GoogleFonts.lato(color: AppColors.textWhite)));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No hay tablas en esta categoría.', style: GoogleFonts.lato(color: AppColors.textWhite)));
          }

          final documents = snapshot.data!.docs;

          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (context, index) {
              final doc = documents[index];
              final data = doc.data() as Map<String, dynamic>;
              String name;
              switch (collectionName) {
                case 'rank_ciudades':
                  name = data['ciudad'] ?? doc.id;
                  break;
                case 'rank_clubes':
                  name = data['club'] ?? doc.id;
                  break;
                case 'rank_whatsapp':
                  name = data['nombre_grupo'] ?? doc.id;
                  break;
                default:
                  name = doc.id;
              }

              return ListTile(
                title: Text(name, style: GoogleFonts.lato(color: AppColors.textWhite)),
                trailing: const Icon(Icons.arrow_forward_ios, color: AppColors.textWhite),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RankingDetailPage(
                        collectionName: collectionName,
                        docId: doc.id,
                        title: name,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
