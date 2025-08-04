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

class RankingTable extends StatefulWidget {
  final String title;
  final String collectionName;
  final String mapKey;
  final IconData icon;

  const RankingTable({
    super.key,
    required this.title,
    required this.collectionName,
    required this.mapKey,
    required this.icon,
  });

  @override
  State<RankingTable> createState() => _RankingTableState();
}

class _RankingTableState extends State<RankingTable> {
  late Stream<List<JugadorStatsConContexto>> _rankStatsStream;

  @override
  void initState() {
    super.initState();
    _rankStatsStream = _getRankStatsStream();
  }

  Stream<List<JugadorStatsConContexto>> _getRankStatsStream() {
    return FirebaseFirestore.instance
        .collection(widget.collectionName)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return <JugadorStatsConContexto>[];
      }

      List<JugadorStatsConContexto> allStats = [];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final statsMap = data[widget.mapKey] as Map<String, dynamic>? ?? {};

        statsMap.forEach((uid, statsData) {
          var statsWithUid = Map<String, dynamic>.from(statsData);
          // Se asigna el UID desde la clave del mapa para asegurar consistencia.
          // Esto evita problemas si el UID dentro del objeto no coincide con la clave.
          statsWithUid['uid'] = uid;
          final stats = JugadorStats.fromJson(statsWithUid);
          allStats.add(JugadorStatsConContexto(
            stats: stats,
            docId: doc.id,
            collectionName: widget.collectionName,
            mapKey: widget.mapKey,
          ));
        });
      }

      allStats.sort((a, b) => b.stats.puntos.compareTo(a.stats.puntos));
      return allStats;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // Escuchar cambios en AuthViewModel para reconstruir si el usuario cambia
    final authViewModel = Provider.of<AuthViewModel>(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        DropButton(
          size: size,
          name: widget.title,
          icon: widget.icon,
        ),
        StreamBuilder<List<JugadorStatsConContexto>>(
          stream: _rankStatsStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen));
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}', style: GoogleFonts.lato(color: AppColors.textWhite)));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text('No hay datos en este ranking.', style: GoogleFonts.lato(color: AppColors.textWhite)),
              ));
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

            return TablaDatosJugador(datos: tableData);
          },
        ),
      ],
    );
  }
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

    final usersSnapshot = results[0] as QuerySnapshot<Map<String, dynamic>>;
    final clubesSnapshot = results[1] as QuerySnapshot<Map<String, dynamic>>;
    final ciudadesSnapshot = results[2] as QuerySnapshot<Map<String, dynamic>>;
    final whatsappSnapshot = results[3] as QuerySnapshot<Map<String, dynamic>>;

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
      backgroundColor: AppColors.primaryBlack,
      appBar: AppBar(
        title: Text('Ranking de Jugadores',
            style: GoogleFonts.lato(color: AppColors.textWhite)),
        centerTitle: true,
        backgroundColor: AppColors.secondBlack,
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

            RankingTable(
              title: 'Clubes',
              collectionName: 'rank_clubes',
              mapKey: 'jugadores',
              icon: Icons.shield,
            ),

            RankingTable(
              title: 'Ciudades',
              collectionName: 'rank_ciudades',
              mapKey: 'jugadores',
              icon: Icons.location_city,
            ),

            RankingTable(
              title: 'WhatsApp',
              collectionName: 'rank_whatsapp',
              mapKey: 'integrantes',
              icon: Icons.chat,
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
          style: GoogleFonts.lato(color: AppColors.textLightGray),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search, color: AppColors.textLightGray,),
            filled: true,
            fillColor: AppColors.secondBlack,
            hintText: 'Busca una competición',
            hintStyle: GoogleFonts.lato(color: AppColors.textLightGray),
    
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: AppColors.primaryBlack),
            ),
    
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: AppColors.textLightGray),
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
  });

  final Size size;
  final String name;
  final IconData icon;

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
            backgroundColor: AppColors.secondBlack,
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
                    color: AppColors.textWhite,
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
            onPressed: (){
              //ACTIONS HERE
            },
            icon: Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textWhite, size: size.width * 0.05),
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
      width: size.width * 0.3,
      height: size.height * 0.05,
      margin: EdgeInsets.only(right: size.width * 0.6, bottom: size.height * 0.02),
      child: OutlinedButton(
        onPressed: (){
          //ACTIONS HERE
        },
    
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          side: const BorderSide(color: AppColors.primaryGreen),
        ),
        child: Text(
          'Ranking',
          style: GoogleFonts.lato(
            color: AppColors.textBlack,
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
    final size = MediaQuery.of(context).size;

    TextStyle headerTextStyle = GoogleFonts.lato(
      color: AppColors.textWhite,
      fontWeight: FontWeight.bold,
    );

    TextStyle cellTextStyle = GoogleFonts.lato(
      color: AppColors.textWhite,
    );

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
            columns: <DataColumn>[
              DataColumn(label: Text('JUGADOR', style: headerTextStyle)),
              DataColumn(label: Text('EFEC', style: headerTextStyle)),
              DataColumn(label: Text('ASIST', style: headerTextStyle)),
              DataColumn(label: Text('PTS', style: headerTextStyle)),
              DataColumn(label: Text('SUB CTG', style: headerTextStyle)),
              DataColumn(label: Text('BON', style: headerTextStyle)),
              DataColumn(label: Text('PEN', style: headerTextStyle)),
              DataColumn(label: Text('ACCIONES', style: headerTextStyle)),
            ],
            rows: datos.map((fila) {
              bool isCurrentUser = fila['isCurrentUser'] ?? false;
              String userId = fila['id']?.toString() ?? '';
              bool isEditable = fila['docId'] != null; // La fila es editable si tiene contexto

              return DataRow(
                cells: <DataCell>[
                  DataCell(Text(fila['JUGADOR'].toString(), style: cellTextStyle)),
                  DataCell(Text(fila['%'].toString(), style: cellTextStyle)),
                  DataCell(Text(fila['ASIST'].toString(), style: cellTextStyle)),
                  DataCell(Text(fila['PTS'].toString(), style: cellTextStyle)),
                  DataCell(Text(fila['SUB CTG'].toString(), style: cellTextStyle)),
                  DataCell(Text(fila['BON'].toString(), style: cellTextStyle)),
                  DataCell(Text(fila['PEN'].toString(), style: cellTextStyle)),
                  DataCell(
                    (isCurrentUser && userId.isNotEmpty && isEditable)
                        ? IconButton(
                            icon: const Icon(Icons.edit, color: AppColors.primaryGreen),
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
                              ).then((_) {
                                // Opcional: recargar datos si es necesario tras la edición.
                                // Por ejemplo, si la página no se actualiza automáticamente.
                              });
                            },
                          )
                        : Container(),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
