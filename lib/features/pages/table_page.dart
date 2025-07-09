import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:padel_app/features/design/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:padel_app/models/user_model.dart';
import 'package:padel_app/viewmodels/auth_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:padel_app/features/pages/edit_profile_data_page.dart';

class TablePage extends StatefulWidget {
  const TablePage({super.key});

  @override
  State<TablePage> createState() => _TablePageState();
}

class _TablePageState extends State<TablePage> {
  // String _searchTerm = ''; // Descomentar si se implementa búsqueda

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      appBar: AppBar(
        title: Text('Ranking de Jugadores', style: GoogleFonts.lato(color: AppColors.textWhite, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.secondBlack,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.textWhite),
            tooltip: 'Cerrar Sesión',
            onPressed: () async {
              await authViewModel.cerrarSesion();
            },
          )
        ],
      ),
      body: SingleChildScrollView( // Se mantiene SingleChildScrollView para la estructura general
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            SearchText( // Widget de búsqueda original
              size: size,
              // onChanged: (value) { // Descomentar si se implementa búsqueda
              //   setState(() {
              //     _searchTerm = value.toLowerCase();
              //   });
              // },
            ),
            RankingButton(size: size), // Botón de Ranking original
            DropButton( // DropButton original
              size: size,
              name: 'General',
              icon: Icons.stadium,
              // onTap: () { /* Lógica filtro */ },
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('usuarios').orderBy('puntos', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen));
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}', style: GoogleFonts.lato(color: AppColors.textWhite)));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No hay jugadores registrados.', style: GoogleFonts.lato(color: AppColors.textWhite)));
                }

                List<Usuario> usuarios = snapshot.data!.docs.map((doc) {
                  return Usuario.fromJson(doc.data() as Map<String, dynamic>);
                }).toList();

                final String? currentUserUid = authViewModel.currentUser?.uid;

                // if (_searchTerm.isNotEmpty) { // Descomentar si se implementa búsqueda
                //   usuarios = usuarios.where((user) => user.nombre.toLowerCase().contains(_searchTerm)).toList();
                // }

                if (currentUserUid != null) {
                  usuarios.sort((a, b) {
                    if (a.uid == currentUserUid) return -1;
                    if (b.uid == currentUserUid) return 1;
                    return b.puntos.compareTo(a.puntos);
                  });
                }

                // if (usuarios.isEmpty && _searchTerm.isNotEmpty) { // Descomentar si se implementa búsqueda
                //    return Center(child: Text('No se encontraron jugadores con "$_searchTerm".', style: GoogleFonts.lato(color: AppColors.textWhite)));
                // }

                return TablaDatosJugador(
                  usuarios: usuarios,
                  currentUserUid: currentUserUid,
                  // size: size, // TablaDatosJugador original no toma size
                );
              },
            ),
            DropButton( // DropButton original
              size: size,
              name: 'Mensual',
              icon: Icons.numbers, // Cambiado de calendar_today a numbers como estaba antes
              // onTap: () { /* Lógica filtro */ },
            ),
          ],
        ),
      ),
    );
  }
}

class SearchText extends StatelessWidget { // Widget de búsqueda original
  const SearchText({
    super.key,
    required this.size,
    // required this.onChanged, // Descomentar si se implementa búsqueda
  });

  final Size size;
  // final ValueChanged<String> onChanged; // Descomentar si se implementa búsqueda

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: size.width * 0.9,
        margin: EdgeInsets.only(top: size.height * 0.02, bottom: size.height * 0.02),
        child: TextFormField(
          // onChanged: onChanged, // Descomentar si se implementa búsqueda
          style: GoogleFonts.lato(color: AppColors.textLightGray),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search, color: AppColors.textLightGray,),
            filled: true,
            fillColor: AppColors.secondBlack,
            hintText: 'Busca una competición', // Texto original
            hintStyle: GoogleFonts.lato(color: AppColors.textLightGray),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: AppColors.primaryBlack), // Color original
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: AppColors.textLightGray), // Color original
            ),
          ),
        ),
      ),
    );
  }
}

class RankingButton extends StatelessWidget { // Botón de Ranking original
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


class DropButton extends StatelessWidget { // DropButton original
  const DropButton({
    super.key,
    required this.size,
    required this.name,
    required this.icon,
    // this.onTap, // Descomentar si se implementa acción
  });

  final Size size;
  final String name;
  final IconData icon;
  // final VoidCallback? onTap; // Descomentar si se implementa acción


  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.width * 0.9,
      height: size.height * 0.08,
      margin: EdgeInsets.only(bottom: size.height * 0.02),
      // No InkWell o GestureDetector en la versión original que estoy restaurando
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircleAvatar(
            radius: size.width * 0.075,
            backgroundColor: AppColors.secondBlack,
            child: Icon(icon, color: AppColors.textWhite, size: size.width * 0.08),
          ),
          Container(
            margin: EdgeInsets.only(right: size.width * 0.4), // Margen original
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
                  'Torneo', // Texto original
                  style: GoogleFonts.lato(
                    color: AppColors.textLightGray,
                    fontSize: size.width * 0.04,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton( // IconButton original
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


class TablaDatosJugador extends StatelessWidget {
  final List<Usuario> usuarios;
  final String? currentUserUid;

  const TablaDatosJugador({super.key, required this.usuarios, this.currentUserUid});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    TextStyle headerTextStyle = GoogleFonts.lato(
      color: AppColors.textWhite,
      fontWeight: FontWeight.bold,
      fontSize: size.width * 0.03, // Manteniendo el tamaño de la versión anterior que funcionó
    );

    TextStyle cellTextStyle = GoogleFonts.lato(
      color: AppColors.textWhite,
      fontSize: size.width * 0.03, // Manteniendo el tamaño
    );

    // Columnas originales que se mostraron en el primer submit exitoso
    // 'TEAM', 'PTS POS', '%', 'ASIST', 'PTS', 'SUB CTG', 'BON', 'PEN'
    // Y la columna de Acción.
    // Las columnas 'SUB CTG', 'BON', 'PEN' se comentaron en el proceso de añadir Acción.
    // Para la versión original, las restauraré si estaban, o las mantendré comentadas si así fue.
    // Revisando el diff del primer submit exitoso a feat/userchanges (que fue el que funcionó y pediste restaurar)
    // las columnas comentadas eran: SUB CTG, BON, PEN. Así que las mantendré comentadas.

    return Container(
      width: size.width * 0.95,
      margin: EdgeInsets.only(bottom: size.height * 0.06, left: size.width * 0.025, right: size.width * 0.025),
      padding: EdgeInsets.symmetric(vertical: size.height * 0.01),
      decoration: BoxDecoration(
        color: AppColors.secondBlack,
        borderRadius: BorderRadius.circular(18),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.02, vertical: size.height * 0.01),
          child: DataTable(
            columnSpacing: size.width * 0.03,
            headingRowHeight: size.height * 0.05,
            dataRowMinHeight: size.height * 0.05,
            dataRowMaxHeight: size.height * 0.06,
            headingRowColor: WidgetStateProperty.resolveWith<Color?>((_) => AppColors.secondBlack),
            dataRowColor: WidgetStateProperty.resolveWith<Color?>((_) => AppColors.secondBlack),
            columns: <DataColumn>[
              DataColumn(label: Text('JUGADOR', style: headerTextStyle)), // TEAM
              DataColumn(label: Text('PUNTOS', style: headerTextStyle)), // PTS
              DataColumn(label: Text('EFECT %', style: headerTextStyle)), // %
              DataColumn(label: Text('ASIST.', style: headerTextStyle)), // ASIST
              DataColumn(label: Text('P. POS', style: headerTextStyle)), // PTS POS
              // DataColumn(label: Text('SUB CTG', style: headerTextStyle)),
              // DataColumn(label: Text('BON', style: headerTextStyle)),
              // DataColumn(label: Text('PEN', style: headerTextStyle)),
              DataColumn(label: Text('ACCIÓN', style: headerTextStyle)),
            ],
            rows: usuarios.map((usuario) {
              bool isCurrentUser = usuario.uid == currentUserUid;
              return DataRow(
                color: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
                  if (isCurrentUser) return AppColors.primaryGreen.withOpacity(0.2);
                  return AppColors.secondBlack;
                }),
                cells: <DataCell>[
                  DataCell(Text(usuario.nombre, style: cellTextStyle)), // TEAM
                  DataCell(Text(usuario.puntos.toString(), style: cellTextStyle)), // PTS
                  DataCell(Text('${(usuario.efectividad * 100).toStringAsFixed(0)}%', style: cellTextStyle)), // %
                  DataCell(Text(usuario.asistencias.toString(), style: cellTextStyle)), // ASIST
                  DataCell(Text(usuario.puntos_pos.toString(), style: cellTextStyle)), // PTS POS
                  // DataCell(Text(usuario.subcategoria.toString(), style: cellTextStyle)),
                  // DataCell(Text(usuario.bonificaciones.toString(), style: cellTextStyle)),
                  // DataCell(Text(usuario.penalizaciones.toString(), style: cellTextStyle)),
                  DataCell(
                    isCurrentUser
                        ? IconButton(
                            icon: Icon(Icons.edit_note_rounded, color: AppColors.primaryGreen, size: size.width * 0.055),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditProfileDataPage(usuario: usuario),
                                ),
                              );
                            },
                          )
                        : const SizedBox.shrink(),
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
