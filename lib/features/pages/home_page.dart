import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:padel_app/features/design/app_colors.dart';
import 'package:padel_app/features/widgets/app_drawer.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:padel_app/data/models/club_model.dart';
import '../../data/models/user_model.dart';
import '../../data/viewmodels/auth_viewmodel.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<Usuario?>? _userDataFuture;
  String _searchQuery = '';
  String? _selectedCity;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
        if (_userDataFuture == null) {
          setState(() {
            _userDataFuture = authViewModel.obtenerDatosUsuarioActual();
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    if (_userDataFuture == null) {
      return const Scaffold(
        backgroundColor: Color.fromARGB(234, 255, 255, 255),
        body: Center(child: CircularProgressIndicator(color: AppColors.primaryGreen)),
      );
    }

    return FutureBuilder<Usuario?>(
      future: _userDataFuture,
      builder: (context, snapshot) {
        Usuario? usuario;
        if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
          usuario = snapshot.data;
        } else if (snapshot.connectionState == ConnectionState.done && snapshot.hasError) {
          usuario = null;
        }

        String? primerNombre;
        if (usuario != null && usuario.nombre.isNotEmpty) {
          primerNombre = usuario.nombre.split(' ').first;
        }
        String displayName = primerNombre ?? 'Jugador';

        return Scaffold(
          backgroundColor: const Color.fromARGB(234, 255, 255, 255),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: AppColors.primaryBlack),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Hola,',
                  style: GoogleFonts.lato(
                    fontSize: size.width * 0.045,
                    color: AppColors.textBlack.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  displayName,
                  style: GoogleFonts.lato(
                    fontSize: size.width * 0.055,
                    color: AppColors.textBlack,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.notifications_none_outlined,
                  color: AppColors.textBlack,
                  size: size.width * 0.07,
                ),
                onPressed: () { /* Lógica para notificaciones */ },
              ),
            ],
          ),
          drawer: const AppDrawer(),
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
                  child: Column(
                    children: [
                      TextField(
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                        style: GoogleFonts.lato(
                          color: AppColors.textBlack,
                          fontSize: size.width * 0.04,
                        ),
                        cursorColor: AppColors.primaryBlack,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.primaryBlack, width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.primaryBlack, width: 1),
                          ),
                          hintText: 'Ingrese el nombre del club',
                          hintStyle: GoogleFonts.lato(
                            color: AppColors.textBlack.withValues(alpha: 0.5),
                            fontSize: 16,
                          ),
                          labelText: 'Buscar nombre de club',
                          labelStyle: GoogleFonts.lato(
                            color: AppColors.textBlack,
                            fontSize: 16,
                          ),
                          prefixIcon: Icon(Icons.search, color: AppColors.primaryBlack),
                        ),
                      ),
                      const SizedBox(height: 10),
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance.collection('clubes').snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const SizedBox.shrink();
                          }
                          final cities = snapshot.data!.docs.map((doc) => doc['ciudad'] as String).toSet().toList();
                          return Container(
                            padding: EdgeInsets.all(size.width * 0.01),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.primaryBlack, width: 1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: DropdownButton<String>(
                              value: _selectedCity,
                              dropdownColor: Colors.white,
                              icon: const Icon(Icons.arrow_drop_down, color: AppColors.primaryBlack),
                              style: GoogleFonts.lato(
                                color: AppColors.textBlack,
                                fontSize: size.width * 0.04,
                              ),
                              underline: Container(
                                height: 1,
                                color: Colors.transparent,
                              ),
                              isExpanded: true,
                              items: [
                                DropdownMenuItem(
                                  value: null,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'Buscar ciudad...',
                                      style: GoogleFonts.lato(
                                        color: AppColors.textBlack,
                                        fontSize: size.width * 0.04,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                ...cities.map((city) => DropdownMenuItem(
                                      value: city,
                                      child: Text(city),
                                    )),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedCity = value;
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('clubes').snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text('No hay clubes disponibles.'));
                      }

                      var clubes = snapshot.data!.docs.map((doc) => Club.fromFirestore(doc)).toList();

                      if (_searchQuery.isNotEmpty) {
                        clubes = clubes.where((club) => club.nombre.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
                      }

                      if (_selectedCity != null) {
                        clubes = clubes.where((club) => club.ciudad == _selectedCity).toList();
                      }

                      return Padding(
                        padding: const EdgeInsets.all(9.0),
                        child: ListView.builder(
                          itemCount: clubes.length,
                          itemBuilder: (context, index) {
                            final club = clubes[index];
                            return ListTile(
                              title: Text(
                                club.nombre,
                                style: GoogleFonts.lato(
                                  color: AppColors.textBlack,
                                  fontSize: size.width * 0.045,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                '${club.ciudad} - ${club.direccion}',
                                style: GoogleFonts.lato(
                                  color: AppColors.textBlack.withValues(alpha: 0.7),
                                  fontSize: size.width * 0.04,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}