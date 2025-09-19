import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:padel_app/data/models/user_model.dart';
import 'package:padel_app/features/design/app_colors.dart';

class SearchPersonsPage extends StatefulWidget {
  const SearchPersonsPage({super.key});

  @override
  State<SearchPersonsPage> createState() => _SearchPersonsPageState();
}

class _SearchPersonsPageState extends State<SearchPersonsPage> {
  final _searchController = TextEditingController();
  List<Usuario> _allUsers = [];
  List<Usuario> _filteredUsers = [];
  String? _currentUserProfession;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  void _initialize() async {
    await _getCurrentUserProfession();
    if (_currentUserProfession != null) {
      await _getUsers();
    }
    setState(() {
      _isLoading = false;
    });
    _searchController.addListener(_filterUsers);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterUsers);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentUserProfession() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user.uid)
            .get();
        if (userDoc.exists) {
          setState(() {
            _currentUserProfession = userDoc.data()!['profesion'];
          });
        }
      }
    } catch (e) {
      print('Error getting user profession: $e');
    }
  }

  Future<void> _getUsers() async {
    if (_currentUserProfession == null) return;
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('usuarios').get();
      final users = snapshot.docs
          .map((doc) => Usuario.fromJson(doc.data()))
          .where((user) => user.profesion == _currentUserProfession && user.uid != FirebaseAuth.instance.currentUser!.uid)
          .toList();

      setState(() {
        _allUsers = users;
        _filteredUsers = users;
      });
    } catch (e) {
      print('Error getting users: $e');
    }
  }

  void _filterUsers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredUsers = _allUsers.where((user) {
        final nameMatches = user.nombre.toLowerCase().contains(query);
        return nameMatches;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryWhite,
      appBar: AppBar(
        title: Text('Buscar Compañeros', style: GoogleFonts.lato(color: AppColors.textWhite)),
        centerTitle: true,
        backgroundColor: AppColors.primaryGreen,
        iconTheme: const IconThemeData(color: AppColors.textWhite),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _searchController,
              style: GoogleFonts.lato(color: AppColors.textBlack),
              decoration: InputDecoration(
                labelText: 'Buscar por nombre',
                labelStyle: GoogleFonts.lato(color: AppColors.textBlack),
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
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredUsers.isEmpty
                      ? Center(child: Text('No se encontraron compañeros con tu misma profesión.', textAlign: TextAlign.center, style: GoogleFonts.lato(color: AppColors.textBlack)))
                      : ListView.builder(
                          itemCount: _filteredUsers.length,
                          itemBuilder: (context, index) {
                            final user = _filteredUsers[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppColors.primaryGreen,
                                child: Text(user.nombre.substring(0, 2).toUpperCase(), style: GoogleFonts.lato(color: AppColors.textWhite, fontWeight: FontWeight.bold)),
                              ),
                              title: Text(user.nombre, style: GoogleFonts.lato(color: AppColors.textBlack)),
                              subtitle: Text(user.profesion, style: GoogleFonts.lato(color: AppColors.textLightGray)),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}