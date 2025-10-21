import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:padel_app/data/models/user_model.dart';
import '../design/app_colors.dart';
import 'package:padel_app/data/jugador_stats.dart';

class AddPlayerToRankingPage extends StatefulWidget {
  final String collectionName;
  final String docId;

  const AddPlayerToRankingPage({
    super.key,
    required this.collectionName,
    required this.docId,
    
  });

  @override
  State<AddPlayerToRankingPage> createState() => _AddPlayerToRankingPageState();
}

class _AddPlayerToRankingPageState extends State<AddPlayerToRankingPage> {
  final _searchController = TextEditingController();
  List<Usuario> _allUsers = [];
  List<Usuario> _filteredUsers = [];
  final List<String> _selectedUserIds = [];
  List<String> _existingPlayerIds = [];

  @override
  void initState() {
    super.initState();
    _getUsersAndPlayers();
    _searchController.addListener(_filterUsers);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterUsers);
    _searchController.dispose();
    super.dispose();
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

  Future<void> _getUsersAndPlayers() async {
    try {
      // Get existing players
      final docSnapshot = await FirebaseFirestore.instance
          .collection(widget.collectionName)
          .doc(widget.docId)
          .get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        final playersMap = data?[mapKey] as Map<String, dynamic>? ?? {};
        _existingPlayerIds = playersMap.keys.toList();
      }

      // Get all users and filter out existing ones
      final snapshot = await FirebaseFirestore.instance.collection('usuarios').get();
      final users = snapshot.docs
          .map((doc) => Usuario.fromJson(doc.data()))
          .where((user) => !_existingPlayerIds.contains(user.uid))
          .toList();

      setState(() {
        _allUsers = users;
        _filteredUsers = users;
      });
    } catch (e) {
      // Handle error
    }
  }

  void _filterUsers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredUsers = _allUsers.where((user) {
        final nameMatches = user.nombre.toLowerCase().contains(query);
        final documentMatches = user.documento.toLowerCase().contains(query);
        return nameMatches || documentMatches;
      }).toList();
    });
  }

  void _toggleUserSelection(String userId) {
    setState(() {
      if (_selectedUserIds.contains(userId)) {
        _selectedUserIds.remove(userId);
      } else {
        _selectedUserIds.add(userId);
      }
    });
  }

  Future<void> _savePlayers() async {
    if (_selectedUserIds.isEmpty) {
      return;
    }

    final playersMap = <String, dynamic>{};
    for (var userId in _selectedUserIds) {
      final user = _allUsers.firstWhere((u) => u.uid == userId);
      playersMap['$mapKey.$userId'] = JugadorStats(
        nombre: user.nombre,
        puntos: 0,
        asistencias: 0,
        subcategoria: 0,
        bonificaciones: 0,
        penalizacion: 0,
        uid: user.uid,
      ).toJson();
    }

    await FirebaseFirestore.instance
        .collection(widget.collectionName)
        .doc(widget.docId)
        .update(playersMap);

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      appBar: AppBar(
        title: Text('Añadir Jugador', style: GoogleFonts.lato(color: AppColors.textWhite)),
        centerTitle: true,
        backgroundColor: AppColors.secondBlack,
        iconTheme: const IconThemeData(color: AppColors.textWhite),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _searchController,
              style: GoogleFonts.lato(color: AppColors.textWhite),
              decoration: InputDecoration(
                labelText: 'Buscar jugador por nombre o documento',
                labelStyle: GoogleFonts.lato(color: AppColors.textWhite),
                prefixIcon: const Icon(Icons.search, color: AppColors.primaryGreen),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primaryGreen),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primaryGreen),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _filteredUsers.isEmpty
                ? Center(child: Text('No se encontraron jugadores o ya todos están en el ranking.', textAlign: TextAlign.center, style: GoogleFonts.lato(color: AppColors.textWhite)))
                : ListView.builder(
                    itemCount: _filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = _filteredUsers[index];
                      final isSelected = _selectedUserIds.contains(user.uid);
                      return ListTile(
                        title: Text(user.nombre, style: GoogleFonts.lato(color: AppColors.textWhite)),
                        subtitle: Text(user.documento, style: GoogleFonts.lato(color: AppColors.textLightGray)),
                        trailing: IconButton(
                          icon: Icon(
                            isSelected ? Icons.remove_circle : Icons.add_circle,
                            color: isSelected ? Colors.red : AppColors.primaryGreen,
                          ),
                          onPressed: () => _toggleUserSelection(user.uid),
                        ),
                      );
                    },
                  ),
            ),
            ElevatedButton(
              onPressed: _savePlayers,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
              child: Text('Guardar', style: GoogleFonts.lato(color: AppColors.textWhite)),
            ),
          ],
        ),
      ),
    );
  }
}
