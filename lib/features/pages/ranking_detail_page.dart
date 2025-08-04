import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:padel_app/data/jugador_stats.dart';
import 'package:padel_app/features/design/app_colors.dart';
import 'package:padel_app/features/pages/table_page.dart';
import 'package:provider/provider.dart';
import 'package:padel_app/data/viewmodels/auth_viewmodel.dart';

class RankingDetailPage extends StatefulWidget {
  final String collectionName;
  final String docId;
  final String title;

  const RankingDetailPage({
    super.key,
    required this.collectionName,
    required this.docId,
    required this.title,
  });

  @override
  State<RankingDetailPage> createState() => _RankingDetailPageState();
}

class _RankingDetailPageState extends State<RankingDetailPage> {
  late Stream<List<JugadorStatsConContexto>> _rankStatsStream;

  @override
  void initState() {
    super.initState();
    _rankStatsStream = _getRankStatsStream();
  }

  String get mapKey {
    switch (widget.collectionName) {
      case 'rank_clubes':
        return 'jugadores';
      case 'rank_ciudades':
        return 'jugadores';
      case 'rank_whatsapp':
        return 'integrantes';
      default:
        return 'jugadores';
    }
  }

  Stream<List<JugadorStatsConContexto>> _getRankStatsStream() {
    return FirebaseFirestore.instance
        .collection(widget.collectionName)
        .doc(widget.docId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) {
        return <JugadorStatsConContexto>[];
      }

      List<JugadorStatsConContexto> allStats = [];
      final data = doc.data();
      final statsMap = data?[mapKey] as Map<String, dynamic>? ?? {};

      statsMap.forEach((uid, statsData) {
        var statsWithUid = Map<String, dynamic>.from(statsData);
        if (statsWithUid['uid'] == null || statsWithUid['uid'] == '') {
          statsWithUid['uid'] = uid;
        }
        final stats = JugadorStats.fromJson(statsWithUid);
        allStats.add(JugadorStatsConContexto(
          stats: stats,
          docId: doc.id,
          collectionName: widget.collectionName,
          mapKey: mapKey,
        ));
      });

      allStats.sort((a, b) => b.stats.puntos.compareTo(a.stats.puntos));
      return allStats;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      appBar: AppBar(
        title: Text(widget.title, style: GoogleFonts.lato(color: AppColors.textWhite)),
        centerTitle: true,
        backgroundColor: AppColors.secondBlack,
        iconTheme: const IconThemeData(color: AppColors.textWhite),
      ),
      body: StreamBuilder<List<JugadorStatsConContexto>>(
        stream: _rankStatsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: GoogleFonts.lato(color: AppColors.textWhite)));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No hay datos en esta tabla.', style: GoogleFonts.lato(color: AppColors.textWhite)));
          }

          final List<JugadorStatsConContexto> statsList = snapshot.data!;
          final List<Map<String, dynamic>> tableData = statsList.map((statsConContexto) {
            final stats = statsConContexto.stats;
            return {
              'JUGADOR': stats.nombre,
              '%': '${stats.efectividad}%',
              'ASIST': stats.asistencias,
              'PTS': stats.puntos,
              'SUB CTG': stats.subcategoria,
              'BON': stats.bonificaciones,
              'PEN': stats.penalizacion,
              'id': stats.uid,
              'isCurrentUser': authViewModel.currentUser?.uid == stats.uid,
              'docId': statsConContexto.docId,
              'collectionName': statsConContexto.collectionName,
              'mapKey': statsConContexto.mapKey,
            };
          }).toList();

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TablaDatosJugador(datos: tableData),
            ),
          );
        },
      ),
    );
  }
}
