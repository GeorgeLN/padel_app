import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:padel_app/data/models/user_model.dart';
import 'package:padel_app/features/design/app_colors.dart';
import 'package:padel_app/data/jugador_stats.dart';

class AddRankingPage extends StatefulWidget {
  final String collectionName;
  final String title;

  const AddRankingPage({
    super.key,
    required this.collectionName,
    required this.title,
  });

  @override
  State<AddRankingPage> createState() => _AddRankingPageState();
}

class _AddRankingPageState extends State<AddRankingPage> {
  final _nameController = TextEditingController();
  List<Usuario> _allUsers = [];
  final List<String> _selectedUserIds = [];

  @override
  void initState() {
    super.initState();
    _getUsers();
  }

  Future<void> _getUsers() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('usuarios').get();
      final users = snapshot.docs.map((doc) => Usuario.fromJson(doc.data())).toList();
      setState(() {
        _allUsers = users;
      });
    } catch (e) {
      // Handle error
    }
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

  Future<void> _saveRanking() async {
    if (_nameController.text.isEmpty || _selectedUserIds.isEmpty) {
      // Show an error message if name is empty or no users are selected
      return;
    }

    final playersMap = <String, dynamic>{};
    for (var userId in _selectedUserIds) {
      final user = _allUsers.firstWhere((u) => u.uid == userId);
      playersMap[userId] = JugadorStats(
        nombre: user.nombre,
        puntos: 0,
        efectividad: 0,
        asistencias: 0,
        subcategoria: 0,
        bonificaciones: 0,
        penalizacion: 0,
        uid: user.uid,
      ).toJson();
    }

    String fieldName;
    switch (widget.collectionName) {
      case 'rank_ciudades':
        fieldName = 'ciudad';
        break;
      case 'rank_clubes':
        fieldName = 'club';
        break;
      case 'rank_whatsapp':
        fieldName = 'nombre_grupo';
        break;
      default:
        fieldName = 'nombre';
    }

    String mapKey;
    switch (widget.collectionName) {
      case 'rank_clubes':
        mapKey = 'jugadores';
        break;
      case 'rank_ciudades':
        mapKey = 'jugadores';
        break;
      case 'rank_whatsapp':
        mapKey = 'integrantes';
      default:
        mapKey = 'jugadores';
    }

    await FirebaseFirestore.instance.collection(widget.collectionName).add({
      fieldName: _nameController.text,
      mapKey: playersMap,
    });

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      appBar: AppBar(
        title: Text('Añadir a ${widget.title}', style: GoogleFonts.lato(color: AppColors.textWhite)),
        centerTitle: true,
        backgroundColor: AppColors.secondBlack,
        iconTheme: const IconThemeData(color: AppColors.textWhite),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _nameController,
              style: GoogleFonts.lato(color: AppColors.textWhite),
              decoration: InputDecoration(
                labelText: 'Nombre',
                labelStyle: GoogleFonts.lato(color: AppColors.textWhite),
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
              child: _allUsers.isEmpty
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
                  : ListView.builder(
                      itemCount: _allUsers.length,
                      itemBuilder: (context, index) {
                        final user = _allUsers[index];
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
              onPressed: _saveRanking,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
              child: Text('Guardar', style: GoogleFonts.lato(color: AppColors.textWhite)),
            ),
          ],
        ),
      ),
    );
  }
}
