// ignore_for_file: prefer_final_fields

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:padel_app/features/design/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:padel_app/features/widgets/add_data_form.dart'; // Comentado ya que su funcionalidad cambia
import 'package:padel_app/models/user_model.dart'; // Importar el modelo Usuario
import 'package:padel_app/viewmodels/auth_viewmodel.dart'; // Para el botón de cerrar sesión
import 'package:provider/provider.dart'; // Para acceder al AuthViewModel

class TablePage extends StatefulWidget {
  const TablePage({super.key});

  @override
  State<TablePage> createState() => _TablePageState();
}

class _TablePageState extends State<TablePage> {
  // void _showAddDataForm(BuildContext context) { // Comentado o redefinir su propósito
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     backgroundColor: AppColors.primaryBlack,
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(
  //         top: Radius.circular(18),
  //       ),
  //     ),
  //     builder: (_) {
  //       return Padding(
  //         padding: EdgeInsets.only(
  //           bottom: MediaQuery.of(context).viewInsets.bottom,
  //           top: 20,
  //           left: 20,
  //           right: 20,
  //         ),
  //         // child: AddDataForm( // AddDataForm necesitaría ser adaptado o eliminado si ya no se usa
  //         //   onSave: (data) {
  //         //     // _addTableData(data); // Ya no se usa de esta forma
  //         //     Navigator.of(context).pop();
  //         //   },
  //         // ),
  //       );
  //     },
  //   );
  // }

  // _dynamicTableData ya no se usa, los datos vendrán de Firestore
  // List<Map<String, dynamic>> _dynamicTableData = [ ... ];
  // void _addTableData(Map<String, dynamic> newData) { ... }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      appBar: AppBar( // AppBar agregada para el título y botón de logout
        title: Text('Ranking de Jugadores', style: GoogleFonts.lato(color: AppColors.textWhite)),
        backgroundColor: AppColors.secondBlack,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.textWhite),
            onPressed: () async {
              await authViewModel.cerrarSesion();
              // AuthWrapper se encargará de redirigir a LoginScreen
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            SearchText(size: size), // Se mantiene si es para filtrar la tabla visualmente
            RankingButton(size: size), // Se mantiene
            DropButton(
              size: size,
              name: 'General',
              icon: Icons.stadium,
            ),

            // StreamBuilder para cargar datos de Firestore
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('usuarios').orderBy('puntos', descending: true).snapshots(), // Ordenar por puntos
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen));
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error al cargar datos: ${snapshot.error}', style: GoogleFonts.lato(color: AppColors.textWhite)));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No hay jugadores registrados.', style: GoogleFonts.lato(color: AppColors.textWhite)));
                }

                // Convertir QuerySnapshot a List<Usuario>
                final List<Usuario> usuarios = snapshot.data!.docs.map((doc) {
                  return Usuario.fromJson(doc.data() as Map<String, dynamic>);
                }).toList();

                // Convertir QuerySnapshot a List<Usuario>
                List<Usuario> usuarios = snapshot.data!.docs.map((doc) {
                  return Usuario.fromJson(doc.data() as Map<String, dynamic>);
                }).toList();

                // Obtener el UID del usuario actual
                final String? currentUserUid = authViewModel.currentUser?.uid;

                // Reordenar la lista para poner al usuario actual primero
                if (currentUserUid != null) {
                  usuarios.sort((a, b) {
                    if (a.uid == currentUserUid) return -1; // a viene primero si es el usuario actual
                    if (b.uid == currentUserUid) return 1;  // b viene primero si es el usuario actual
                    // Mantener el orden original por puntos para los demás
                    return b.puntos.compareTo(a.puntos); // Orden descendente por puntos
                  });
                }

                // No es necesario mapear a List<Map<String, dynamic>> si TablaDatosJugador puede manejar List<Usuario>
                // Simplemente pasamos la lista de usuarios reordenada y el UID del usuario actual.
                return TablaDatosJugador(usuarios: usuarios, currentUserUid: currentUserUid);
              },
            ),

            DropButton(
              size: size,
              name: 'Mensual',
              icon: Icons.numbers,
            ),
          ],
        ),
      ),
      // FloatingActionButton ahora podría tener otro propósito o ser eliminado
      // si la adición de usuarios es solo mediante el registro.
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     // _showAddDataForm(context); // Su funcionalidad original cambió
      //   },
      //   backgroundColor: AppColors.primaryGreen,
      //   child: const Icon(Icons.add, color: AppColors.textBlack),
      // ),
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
      height: size.height * 0.08,
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

import 'package:padel_app/features/pages/edit_profile_data_page.dart'; // Importar la nueva página

class TablaDatosJugador extends StatelessWidget {
  final List<Usuario> usuarios; // Cambiado de List<Map<String, dynamic>> a List<Usuario>
  final String? currentUserUid;

  const TablaDatosJugador({super.key, required this.usuarios, this.currentUserUid});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    TextStyle headerTextStyle = GoogleFonts.lato(
      color: AppColors.textWhite,
      fontWeight: FontWeight.bold,
      fontSize: size.width * 0.03,
    );

    TextStyle cellTextStyle = GoogleFonts.lato(
      color: AppColors.textWhite,
      fontSize: size.width * 0.03,
    );

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
            headingRowColor: WidgetStateProperty.resolveWith<Color?>(
              (Set<WidgetState> states) => AppColors.secondBlack,
            ),
            dataRowColor: WidgetStateProperty.resolveWith<Color?>(
              (Set<WidgetState> states) => AppColors.secondBlack,
            ),
            columns: <DataColumn>[
              DataColumn(label: Text('JUGADOR', style: headerTextStyle)),
              DataColumn(label: Text('PUNTOS', style: headerTextStyle)),
              DataColumn(label: Text('EFECT %', style: headerTextStyle)),
              DataColumn(label: Text('ASIST.', style: headerTextStyle)),
              DataColumn(label: Text('P. POS', style: headerTextStyle)),
              DataColumn(label: Text('ACCIÓN', style: headerTextStyle)),
            ],
            rows: usuarios.map((usuario) { // Iterar sobre List<Usuario>
              bool isCurrentUser = usuario.uid == currentUserUid;
              return DataRow(
                color: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
                  if (isCurrentUser) {
                    return AppColors.primaryGreen.withOpacity(0.2);
                  }
                  return AppColors.secondBlack;
                }),
                cells: <DataCell>[
                  DataCell(Text(usuario.nombre, style: cellTextStyle)),
                  DataCell(Text(usuario.puntos.toString(), style: cellTextStyle)),
                  DataCell(Text('${(usuario.efectividad * 100).toStringAsFixed(0)}%', style: cellTextStyle)), // Ajustado para mostrar %
                  DataCell(Text(usuario.asistencias.toString(), style: cellTextStyle)),
                  DataCell(Text(usuario.puntos_pos.toString(), style: cellTextStyle)),
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
                        : SizedBox.shrink(),
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
