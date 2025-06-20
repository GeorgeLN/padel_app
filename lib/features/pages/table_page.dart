import 'package:flutter/material.dart';
import 'package:padel_app/features/design/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:padel_app/features/widgets/add_data_form.dart';

class TablaEstadisticasWidget extends StatefulWidget {

  const TablaEstadisticasWidget({super.key});

  @override
  State<TablaEstadisticasWidget> createState() => _TablaEstadisticasWidgetState();
}

class _TablaEstadisticasWidgetState extends State<TablaEstadisticasWidget> {
  void _showAddDataForm(BuildContext context) {
    // Verifying AddDataForm usage
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: AddDataForm(
            onSave: (data) {
              _addTableData(data);
              Navigator.of(context).pop(); // Close the bottom sheet
            },
          ),
        );
      },
    );
  }

  List<Map<String, dynamic>> _dynamicTableData = [
    {
      'Team': 'Jugador Inicial',
      'Puntos POS': 100,
      '%': '6%',
      'Asist': 23,
      'Pts': 30,
    }
  ];

  void _addTableData(Map<String, dynamic> newData) {
    setState(() {
      _dynamicTableData.add(newData);
    });
  }

  final List<Map<String, dynamic>> datos = [
    {
      'nombre': 'Jugador 1',
      'icono': Icons.sports_soccer,
      'pos': 6,
      'porcentaje': 23,
      'asistencias': 36,
    },
    {
      'nombre': 'Jugador 2',
      'icono': Icons.sports_soccer,
      'pos': 7,
      'porcentaje': 15,
      'asistencias': 33,
    },
    {
      'nombre': 'Team 3',
      'icono': Icons.sports_soccer,
      'pos': 9,
      'porcentaje': 20,
      'asistencias': 30,
    },
    {
      'nombre': 'Team 4',
      'icono': Icons.sports_soccer,
      'pos': 10,
      'porcentaje': 16,
      'asistencias': 27,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      
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
        
            TablaDatosJugador(datos: _dynamicTableData),

            // Container(
            //   width: size.width * 0.9,
            //   height: size.height * 0.35,
            //   margin: EdgeInsets.only(bottom: size.height * 0.02),
            //   decoration: BoxDecoration(
            //     color: Colors.transparent,
            //     borderRadius: BorderRadius.circular(18),
            //   ),

            //   child: Row(
            //     children: [
            //       Container(
            //         width: size.width * 0.35,
            //         decoration: BoxDecoration(
            //           color: AppColors.secondBlack,
            //           borderRadius: BorderRadius.only(
            //             topLeft: Radius.circular(18),
            //             bottomLeft: Radius.circular(18),
            //           ),
            //         ),

            //         child: Column(
            //           crossAxisAlignment: CrossAxisAlignment.center,
            //           children: [
            //             Padding(
            //               padding: EdgeInsets.only(top: size.height * 0.01),
            //               child: Text(
            //                 'Team',
            //                 style: GoogleFonts.lato(
            //                   color: AppColors.textWhite,
            //                   fontSize: size.width * 0.04,
            //                   fontWeight: FontWeight.bold,
            //                 ),
            //               ),
            //             ),

            //             Row(
            //               children: [
            //                 Padding(
            //                   padding: EdgeInsets.all(size.width * 0.03),
            //                   child: Icon(Icons.groups, color: AppColors.textWhite, size: size.width * 0.05),
            //                 ),
            //                 Expanded(
            //                   child: TextField(
            //                     style: GoogleFonts.lato(color: AppColors.textWhite),
            //                     decoration: InputDecoration(
            //                       border: InputBorder.none,
                                  
            //                     ),
            //                   ),
            //                 ),
            //               ],
            //             ),

            //             Row(
            //               children: [
            //                 Padding(
            //                   padding: EdgeInsets.all(size.width * 0.03),
            //                   child: Icon(Icons.groups, color: AppColors.textWhite, size: size.width * 0.05),
            //                 ),
            //                 Expanded(
            //                   child: TextField(
            //                     style: GoogleFonts.lato(color: AppColors.textWhite),
            //                     decoration: InputDecoration(
            //                       border: InputBorder.none,
                                  
            //                     ),
            //                   ),
            //                 ),
            //               ],
            //             ),

            //             Row(
            //               children: [
            //                 Padding(
            //                   padding: EdgeInsets.all(size.width * 0.03),
            //                   child: Icon(Icons.groups, color: AppColors.textWhite, size: size.width * 0.05),
            //                 ),
            //                 Expanded(
            //                   child: TextField(
            //                     style: GoogleFonts.lato(color: AppColors.textWhite),
            //                     decoration: InputDecoration(
            //                       border: InputBorder.none,
                                  
            //                     ),
            //                   ),
            //                 ),
            //               ],
            //             ),

            //             Row(
            //               children: [
            //                 Padding(
            //                   padding: EdgeInsets.all(size.width * 0.03),
            //                   child: Icon(Icons.groups, color: AppColors.textWhite, size: size.width * 0.05),
            //                 ),
            //                 Expanded(
            //                   child: TextField(
            //                     style: GoogleFonts.lato(color: AppColors.textWhite),
            //                     decoration: InputDecoration(
            //                       border: InputBorder.none,
                                  
            //                     ),
            //                   ),
            //                 ),
            //               ],
            //             ),

            //             Row(
            //               children: [
            //                 Padding(
            //                   padding: EdgeInsets.all(size.width * 0.03),
            //                   child: Icon(Icons.groups, color: AppColors.textWhite, size: size.width * 0.05),
            //                 ),
            //                 Expanded(
            //                   child: TextField(
            //                     style: GoogleFonts.lato(color: AppColors.textWhite),
            //                     decoration: InputDecoration(
            //                       border: InputBorder.none,
                                  
            //                     ),
            //                   ),
            //                 ),
            //               ],
            //             ),
            //           ],
            //         ),
            //       ),

            //       Container(
            //         width: size.width * 0.55,
            //         decoration: BoxDecoration(
            //           color: AppColors.secondBlack,
            //           borderRadius: BorderRadius.only(
            //             topRight: Radius.circular(18),
            //             bottomRight: Radius.circular(18),
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),

            DropButton(
              size: size,
              name: 'Mensual',
              icon: Icons.numbers,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddDataForm(context);
        },
        backgroundColor: AppColors.primaryGreen,
        child: const Icon(Icons.add, color: AppColors.textBlack),
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
      height: size.height * 0.08,
      margin: EdgeInsets.only(bottom: size.height * 0.02),
      
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircleAvatar(
            radius: size.width * 0.075,
            backgroundColor: AppColors.secondBlack,
            child: Icon(icon, color: AppColors.textWhite, size: size.width * 0.05),
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

  const TablaDatosJugador({Key? key, required this.datos}) : super(key: key);

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
      margin: EdgeInsets.only(bottom: size.height * 0.02),
      padding: EdgeInsets.symmetric(vertical: size.height * 0.01), // Padding interno
      decoration: BoxDecoration(
        color: AppColors.secondBlack,
        borderRadius: BorderRadius.circular(18),
      ),
      child: DataTable(
        headingRowColor: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
            return AppColors.secondBlack; // Color de fondo para la fila de encabezados
          },
        ),
        dataRowColor: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
            return AppColors.secondBlack; // Color de fondo para las filas de datos
          },
        ),
        columns: <DataColumn>[
          DataColumn(label: Text('Team', style: headerTextStyle)),
          DataColumn(label: Text('Puntos POS', style: headerTextStyle)),
          DataColumn(label: Text('%', style: headerTextStyle)),
          DataColumn(label: Text('Asist', style: headerTextStyle)),
          DataColumn(label: Text('Pts', style: headerTextStyle)),
        ],
        rows: datos.map((fila) {
          return DataRow(
            cells: <DataCell>[
              DataCell(Text(fila['Team'].toString(), style: cellTextStyle)),
              DataCell(Text(fila['Puntos POS'].toString(), style: cellTextStyle)),
              DataCell(Text(fila['%'].toString(), style: cellTextStyle)),
              DataCell(Text(fila['Asist'].toString(), style: cellTextStyle)),
              DataCell(Text(fila['Pts'].toString(), style: cellTextStyle)),
            ],
          );
        }).toList(),
      ),
    );
  }
}
