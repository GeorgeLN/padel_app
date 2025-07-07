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

                // Mapear List<Usuario> al formato que espera TablaDatosJugador
                // O idealmente, modificar TablaDatosJugador para que acepte List<Usuario>
                final List<Map<String, dynamic>> datosParaTabla = usuarios.map((user) {
                  return {
                    // Columnas de la tabla: 'TEAM', 'PTS POS', '%', 'ASIST', 'PTS', 'SUB CTG', 'BON', 'PEN'
                    'TEAM': user.nombre, // 'nombre' del modelo Usuario
                    'PTS POS': user.puntos_pos,
                    '%': user.efectividad.toStringAsFixed(1) + '%', // Formatear efectividad
                    'ASIST': user.asistencias,
                    'PTS': user.puntos,
                    'SUB CTG': user.subcategoria,
                    'BON': user.bonificaciones,
                    'PEN': user.penalizaciones,
                    // Campos extra de _dynamicTableData que no están en el modelo Usuario:
                    // 'PTS ANT': 0, // Si necesitas estos, considera añadirlos al modelo o manejar por defecto
                    // 'VAR': '+',
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
              DataColumn(label: Text('%', style: headerTextStyle)),
              DataColumn(label: Text('ASIST', style: headerTextStyle)),
              DataColumn(label: Text('PTS', style: headerTextStyle)),
              DataColumn(label: Text('SUB CTG', style: headerTextStyle)),
              DataColumn(label: Text('BON', style: headerTextStyle)),
              DataColumn(label: Text('PEN', style: headerTextStyle)),
            ],
            rows: datos.map((fila) {
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
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
