// ignore_for_file: prefer_final_fields

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:padel_app/features/design/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:padel_app/features/widgets/add_data_form.dart'; // Comentado ya que su funcionalidad cambia
import 'package:padel_app/data/models/user_model.dart'; // Importar el modelo Usuario
import 'package:padel_app/data/viewmodels/auth_viewmodel.dart'; // Para el botón de cerrar sesión
import 'package:padel_app/features/pages/_pages.dart';
import 'package:provider/provider.dart';

import 'edit_profile_data_page.dart'; // Para acceder al AuthViewModel

class TablePage extends StatefulWidget {
  const TablePage({super.key});

  @override
  State<TablePage> createState() => _TablePageState();
}

class _TablePageState extends State<TablePage> {
  Stream<List<QuerySnapshot>> _getUsersStream(String? currentUserId) {
    final firestore = FirebaseFirestore.instance;
    Stream<QuerySnapshot> loggedInUserStream;
    Stream<QuerySnapshot> otherUsersStream;

    if (currentUserId != null) {
      loggedInUserStream = firestore
          .collection('usuarios')
          .where(FieldPath.documentId, isEqualTo: currentUserId)
          .snapshots();
      otherUsersStream = firestore
          .collection('usuarios')
          .where(FieldPath.documentId, isNotEqualTo: currentUserId)
          .orderBy('puntos', descending: true)
          .snapshots();
    } else {
      // Si no hay usuario logueado, devuelve todos ordenados por puntos
      loggedInUserStream = Stream.value(EmptyQuerySnapshot());
      otherUsersStream = firestore
          .collection('usuarios')
          .orderBy('puntos', descending: true)
          .snapshots();
    }

    return loggedInUserStream.asyncMap((loggedInUserSnap) async {
      final otherUsersSnap = await otherUsersStream.first; // Espera el primer evento de los otros usuarios
      return [loggedInUserSnap, otherUsersSnap];
    });
  }


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      appBar: AppBar( // AppBar agregada para el título y botón de logout
        title: Text('Ranking de Jugadores', style: GoogleFonts.lato(color: AppColors.textWhite)),
        centerTitle: true,
        backgroundColor: AppColors.secondBlack,
        leading: Icon(Icons.abc_rounded, color: Colors.transparent),
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
            StreamBuilder<List<QuerySnapshot>>( // Cambiado a List<QuerySnapshot>
              stream: _getUsersStream(authViewModel.currentUser?.uid), // Usar la nueva función de stream
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen));
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error al cargar datos: ${snapshot.error}', style: GoogleFonts.lato(color: AppColors.textWhite)));
                }
                // Comprobar si hay datos y si las listas internas no son nulas.
                if (!snapshot.hasData || snapshot.data == null || snapshot.data!.length < 2) {
                    return Center(child: Text('Cargando datos de jugadores...', style: GoogleFonts.lato(color: AppColors.textWhite)));
                }

                final List<Usuario> usuarios = [];
                final loggedInUserSnapshot = snapshot.data![0];
                final otherUsersSnapshot = snapshot.data![1];

                // Procesar usuario logueado primero
                if (loggedInUserSnapshot.docs.isNotEmpty) {
                  final loggedInUserDoc = loggedInUserSnapshot.docs.first;
                  // Asegurarse de que el ID se está pasando correctamente al modelo Usuario
                  var data = loggedInUserDoc.data() as Map<String, dynamic>;
                  if (data['uid'] == null) {
                    data['uid'] = loggedInUserDoc.id;
                  }
                  usuarios.add(Usuario.fromJson(data));
                }

                // Procesar otros usuarios
                for (var doc in otherUsersSnapshot.docs) {
                   // Asegurarse de que el ID se está pasando correctamente al modelo Usuario
                  var data = doc.data() as Map<String, dynamic>;
                  if (data['uid'] == null) {
                    data['uid'] = doc.id;
                  }
                  // Evitar duplicados si el usuario logueado también aparece aquí (aunque no debería por la consulta)
                  if (authViewModel.currentUser?.uid == null || doc.id != authViewModel.currentUser!.uid) {
                    usuarios.add(Usuario.fromJson(data));
                  }
                }

                if (usuarios.isEmpty) {
                  return Center(child: Text('No hay jugadores registrados.', style: GoogleFonts.lato(color: AppColors.textWhite)));
                }

                // Mapear List<Usuario> al formato que espera TablaDatosJugador
                final List<Map<String, dynamic>> datosParaTabla = usuarios.map((user) {
                  return {
                    'TEAM': user.nombre,
                    'PTS POS': user.puntos_pos,
                    '%': '${user.efectividad.toStringAsFixed(1)}%',
                    'ASIST': user.asistencias,
                    'PTS': user.puntos,
                    'SUB CTG': user.subcategoria,
                    'BON': user.bonificaciones,
                    'PEN': user.penalizaciones,
                    // Campos necesarios para la lógica de edición
                    'id': user.uid, // Usar user.uid que debe estar asignado
                    'isCurrentUser': authViewModel.currentUser?.uid == user.uid,
                  };
                }).toList();

                return TablaDatosJugador(datos: datosParaTabla);
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

// Clase auxiliar para el caso de Stream vacío
class EmptyQuerySnapshot implements QuerySnapshot {
  @override
  List<DocumentChange> get docChanges => [];

  @override
  List<QueryDocumentSnapshot> get docs => [];

  @override
  SnapshotMetadata get metadata => throw UnimplementedError('metadata_unimplemented'); // Proporcionar un mensaje

  @override
  int get size => 0;
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

class TablaDatosJugador extends StatelessWidget {
  final List<Map<String, dynamic>> datos;

  const TablaDatosJugador({super.key, required this.datos});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size; // Obtener size para el margin

    TextStyle headerTextStyle = GoogleFonts.lato(
      color: AppColors.textWhite,
      fontWeight: FontWeight.bold,
    );

    TextStyle cellTextStyle = GoogleFonts.lato(
      color: AppColors.textWhite, // O AppColors.textLightGray si se prefiere
    );

    return Container(
      width: size.width * 0.9, // Ancho similar a otros elementos
      margin: EdgeInsets.only(bottom: size.height * 0.06),
      padding: EdgeInsets.symmetric(vertical: size.height * 0.02), // Padding interno
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
              (Set<WidgetState> states) {
                return AppColors.secondBlack; // Color de fondo para la fila de encabezados
              },
            ),
            dataRowColor: WidgetStateProperty.resolveWith<Color?>(
              (Set<WidgetState> states) {
                return AppColors.secondBlack; // Color de fondo para las filas de datos
              },
            ),
            columns: <DataColumn>[
              DataColumn(label: Text('TEAM', style: headerTextStyle)),
              DataColumn(label: Text('PTS POS', style: headerTextStyle)),
              DataColumn(label: Text('EFEC', style: headerTextStyle)),
              DataColumn(label: Text('ASIST', style: headerTextStyle)),
              DataColumn(label: Text('PTS', style: headerTextStyle)),
              DataColumn(label: Text('SUB CTG', style: headerTextStyle)),
              DataColumn(label: Text('BON', style: headerTextStyle)),
              DataColumn(label: Text('PEN', style: headerTextStyle)),
              DataColumn(label: Text('ACCIONES', style: headerTextStyle)), // Nueva columna para el botón
            ],
            rows: datos.map((fila) {
              bool isCurrentUser = fila['isCurrentUser'] ?? false;
              String userId = fila['id']?.toString() ?? ''; // Asegurarse que el id sea String y no nulo

              return DataRow(
                cells: <DataCell>[
                  DataCell(Text(fila['TEAM'].toString(), style: cellTextStyle)),
                  DataCell(Text(fila['PTS POS'].toString(), style: cellTextStyle)),
                  DataCell(Text(fila['%'].toString(), style: cellTextStyle)),
                  DataCell(Text(fila['ASIST'].toString(), style: cellTextStyle)),
                  DataCell(Text(fila['PTS'].toString(), style: cellTextStyle)),
                  DataCell(Text(fila['SUB CTG'].toString(), style: cellTextStyle)),
                  DataCell(Text(fila['BON'].toString(), style: cellTextStyle)),
                  DataCell(Text(fila['PEN'].toString(), style: cellTextStyle)),
                  DataCell(
                    (isCurrentUser && userId.isNotEmpty) // Solo mostrar si es el usuario y hay ID
                        ? IconButton(
                            icon: const Icon(Icons.edit, color: AppColors.primaryGreen),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditProfileDataPage(userId: userId),
                                ),
                              );
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
