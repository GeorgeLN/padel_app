// ignore_for_file: prefer_final_fields

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:padel_app/data/models/unified_stats_model.dart';
import 'package:padel_app/data/jugador_stats.dart';
import 'package:padel_app/features/design/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:padel_app/data/models/user_model.dart';
import 'package:padel_app/data/viewmodels/auth_viewmodel.dart';
import 'package:padel_app/features/pages/home_page.dart';
import 'package:padel_app/features/pages/ranking_list_page.dart';
import 'package:padel_app/features/pages/search_persons_page.dart';
import 'package:provider/provider.dart';

import 'edit_profile_data_page.dart';

// Helper class to hold stats with their origin context
class JugadorStatsConContexto {
  final JugadorStats stats;
  final String docId;
  final String collectionName;
  final String mapKey;

  JugadorStatsConContexto({
    required this.stats,
    required this.docId,
    required this.collectionName,
    required this.mapKey,
  });
}

class TablePage extends StatefulWidget {
  const TablePage({super.key});

  @override
  State<TablePage> createState() => _TablePageState();
}

class _TablePageState extends State<TablePage> {
  late Future<List<UnifiedStats>> _bestStatsFuture;

  @override
  void initState() {
    super.initState();
    _bestStatsFuture = _getBestStatsForAllUsers();
  }

  Future<List<UnifiedStats>> _getBestStatsForAllUsers() async {
    final firestore = FirebaseFirestore.instance;
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final currentUserId = authViewModel.currentUser?.uid;

    final results = await Future.wait([
      firestore.collection('usuarios').get(),
      firestore.collection('rank_clubes').get(),
      firestore.collection('rank_ciudades').get(),
      firestore.collection('rank_whatsapp').get(),
    ]);

    final usersSnapshot = results[0];
    final clubesSnapshot = results[1];
    final ciudadesSnapshot = results[2];
    final whatsappSnapshot = results[3];

    Map<String, UnifiedStats> bestStatsMap = {};

    for (var doc in usersSnapshot.docs) {
      var data = doc.data();
      if (data['uid'] == null) {
        data['uid'] = doc.id;
      }
      final usuario = Usuario.fromJson(data);
      bestStatsMap[usuario.uid] = UnifiedStats.fromUsuario(usuario);
    }

    void processRankCollection(
        QuerySnapshot<Map<String, dynamic>> snapshot, String sourceName, String mapKey) {
      for (var doc in snapshot.docs) {
        final rankData = doc.data();
        final statsMap = rankData[mapKey] as Map<String, dynamic>? ?? {};

        statsMap.forEach((uid, statsData) {
          final stats = JugadorStats.fromJson(statsData as Map<String, dynamic>);
          final unified = UnifiedStats.fromJugadorStats(stats, sourceName);

          if (bestStatsMap.containsKey(uid)) {
            if (unified.puntos > bestStatsMap[uid]!.puntos) {
              bestStatsMap[uid] = unified;
            }
          } else {
            bestStatsMap[uid] = unified;
          }
        });
      }
    }

    processRankCollection(clubesSnapshot, 'Clubes', 'jugadores');
    processRankCollection(ciudadesSnapshot, 'Ciudades', 'jugadores');
    processRankCollection(whatsappSnapshot, 'Whatsapp', 'integrantes');

    List<UnifiedStats> finalStatsList = bestStatsMap.values.toList();
    finalStatsList.sort((a, b) => b.puntos.compareTo(a.puntos));

    if (currentUserId != null) {
      final currentUserIndex = finalStatsList.indexWhere((stats) => stats.uid == currentUserId);
      if (currentUserIndex != -1) {
        final currentUserStats = finalStatsList.removeAt(currentUserIndex);
        finalStatsList.insert(0, currentUserStats);
      }
    }

    return finalStatsList;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    return Scaffold(
      backgroundColor: AppColors.primaryWhite,
      appBar: AppBar(
        title: Text('Ranking de Jugadores',
            style: GoogleFonts.lato(color: AppColors.textWhite)),
        centerTitle: true,
        backgroundColor: AppColors.primaryGreen,
        leading: const Icon(Icons.abc_rounded, color: Colors.transparent),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            SearchText(size: size),
            RankingButton(size: size),
            DropButton(
              size: size,
              name: 'General',
              icon: Icons.stadium,
              onPressed: () {},
            ),

            FutureBuilder<List<UnifiedStats>>(
              future: _bestStatsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primaryGreen));
                }
                if (snapshot.hasError) {
                  return Center(
                      child: Text('Error al cargar datos: ${snapshot.error}',
                          style:
                              GoogleFonts.lato(color: AppColors.textWhite)));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                      child: Text('No hay jugadores registrados.',
                          style:
                              GoogleFonts.lato(color: AppColors.textWhite)));
                }

                final List<UnifiedStats> bestStats = snapshot.data!;
                final List<Map<String, dynamic>> datosParaTabla =
                    bestStats.map((stats) {
                  return {
                    'JUGADOR': stats.nombre,
                    '%': '${stats.efectividad.toStringAsFixed(1)}%',
                    'ASIST': stats.asistencias,
                    'PTS': stats.puntos,
                    'SUB CTG': stats.subcategoria,
                    'BON': stats.bonificaciones,
                    'PEN': stats.penalizaciones,
                    'id': stats.uid,
                    'isCurrentUser': authViewModel.currentUser?.uid == stats.uid,
                  };
                }).toList();

                return TablaDatosJugador(datos: datosParaTabla);
              },
            ),

            const SizedBox(height: 10),

            DropButton(
              size: size,
              name: 'Clubes',
              icon: Icons.shield,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RankingListPage(
                      collectionName: 'rank_clubes',
                      title: 'Clubes',
                    ),
                  ),
                );
              },
            ),

            DropButton(
              size: size,
              name: 'Ciudades',
              icon: Icons.location_city,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RankingListPage(
                      collectionName: 'rank_ciudades',
                      title: 'Ciudades',
                    ),
                  ),
                );
              },
            ),

            DropButton(
              size: size,
              name: 'WhatsApp',
              icon: Icons.chat,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RankingListPage(
                      collectionName: 'rank_whatsapp',
                      title: 'Grupos de WhatsApp',
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class SearchText extends StatelessWidget {
  const SearchText({
    super.key,
    required this.size,
  });

  final Size size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: size.width * 0.9,
        margin: EdgeInsets.only(top: size.height * 0.02, bottom: size.height * 0.02),
        child: TextFormField(
          style: GoogleFonts.lato(color: AppColors.textBlack),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search, color: AppColors.textBlack,),
            filled: true,
            fillColor: AppColors.secondLightGray.withValues(alpha: 0.4),
            hintText: 'Busca una competición',
            hintStyle: GoogleFonts.lato(color: AppColors.textBlack),
    
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: AppColors.primaryBlack),
            ),
    
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: AppColors.textBlack),
            ),
          ),
        ),
      ),
    );
  }
}

class DropButton extends StatelessWidget {
  const DropButton({
    super.key,
    required this.size,
    required this.name,
    required this.icon,
    this.onPressed,
  });

  final Size size;
  final String name;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.width * 0.9,
      height: size.height * 0.1,
      margin: EdgeInsets.only(bottom: size.height * 0.02),

      
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircleAvatar(
            radius: size.width * 0.075,
            backgroundColor: AppColors.primaryGreen,
            child: Icon(icon, color: AppColors.textWhite, size: size.width * 0.08),
          ),
    
          Container(
            margin: EdgeInsets.only(right: size.width * 0.4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
            
              children: [
                Text(
                  name,
                  style: GoogleFonts.lato(
                    color: AppColors.textBlack,
                    fontSize: size.width * 0.04,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Torneo',
                  style: GoogleFonts.lato(
                    color: AppColors.textLightGray,
                    fontSize: size.width * 0.04,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
    
          IconButton(
            onPressed: onPressed,
            icon: Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textBlack, size: size.width * 0.05),
          ),
        ],
      ),
    );
  }
}

class RankingButton extends StatelessWidget {
  const RankingButton({
    super.key,
    required this.size,
  });

  final Size size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.width * 0.5,
      height: size.height * 0.05,
      margin: EdgeInsets.only(bottom: size.height * 0.02),
      child: OutlinedButton(
        onPressed: (){
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SearchPersonsPage(),
            ),
          );
        },
    
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          side: const BorderSide(color: AppColors.primaryGreen),
        ),
        child: Text(
          'Buscar personas',
          style: GoogleFonts.lato(
            color: AppColors.textWhite,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class TablaDatosJugador extends StatelessWidget {
  final List<Map<String, dynamic>> datos;

  const TablaDatosJugador({super.key, required this.datos});

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final size = MediaQuery.of(context).size;

    TextStyle headerTextStyle = GoogleFonts.lato(
      color: AppColors.textWhite,
      fontWeight: FontWeight.bold,
    );

    TextStyle cellTextStyle = GoogleFonts.lato(
      color: AppColors.textWhite,
    );

    List<DataColumn> columns = [
      DataColumn(label: Text('JUGADOR', style: headerTextStyle)),
      DataColumn(label: Text('EFEC', style: headerTextStyle)),
      DataColumn(label: Text('ASIST', style: headerTextStyle)),
      DataColumn(label: Text('PTS', style: headerTextStyle)),
      DataColumn(label: Text('SUB CTG', style: headerTextStyle)),
      DataColumn(label: Text('BON', style: headerTextStyle)),
      DataColumn(label: Text('PEN', style: headerTextStyle)),
    ];

    if (authViewModel.isAdmin) {
      columns.add(DataColumn(label: Text('ACCIONES', style: headerTextStyle)));
    }

    return Container(
      width: size.width * 0.9,
      margin: EdgeInsets.only(bottom: size.height * 0.06),
      padding: EdgeInsets.symmetric(vertical: size.height * 0.02),
      decoration: BoxDecoration(
        color: AppColors.secondBlack,
        borderRadius: BorderRadius.circular(18),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: size.height * 0.02),
          child: DataTable(
            headingRowColor: WidgetStateProperty.resolveWith<Color?>(
              (Set<WidgetState> states) => AppColors.secondBlack,
            ),
            dataRowColor: WidgetStateProperty.resolveWith<Color?>(
              (Set<WidgetState> states) => AppColors.secondBlack,
            ),
            columns: columns,
            rows: datos.map((fila) {
              String userId = fila['id']?.toString() ?? '';
              bool isEditable = fila['docId'] != null;

              List<DataCell> cells = [
                DataCell(Text(fila['JUGADOR'].toString(), style: cellTextStyle)),
                DataCell(Text(fila['%'].toString(), style: cellTextStyle)),
                DataCell(Text(fila['ASIST'].toString(), style: cellTextStyle)),
                DataCell(Text(fila['PTS'].toString(), style: cellTextStyle)),
                DataCell(
                    Text(fila['SUB CTG'].toString(), style: cellTextStyle)),
                DataCell(Text(fila['BON'].toString(), style: cellTextStyle)),
                DataCell(Text(fila['PEN'].toString(), style: cellTextStyle)),
              ];

              if (authViewModel.isAdmin) {
                cells.add(
                  DataCell(
                    (userId.isNotEmpty && isEditable)
                        ? IconButton(
                            icon: const Icon(Icons.edit,
                                color: AppColors.primaryGreen),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditProfileDataPage(
                                    userId: userId,
                                    sourceCollection: fila['collectionName'],
                                    docId: fila['docId'],
                                    mapKey: fila['mapKey'],
                                  ),
                                ),
                              );
                            },
                          )
                        : Container(),
                  ),
                );
              }
              return DataRow(cells: cells);
            }).toList(),
          ),
        ),
      ),
    );
  }
}
