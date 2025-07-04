// ignore_for_file: prefer_final_fields

import 'package:flutter/material.dart';
import 'package:padel_app/features/design/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:padel_app/features/widgets/add_data_form.dart';

class TablePage extends StatefulWidget {

  const TablePage({super.key});

  @override
  State<TablePage> createState() => _TablePageState();
}

class _TablePageState extends State<TablePage> {
  void _showAddDataForm(BuildContext context) {
    // Verifying AddDataForm usage
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.primaryBlack,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(18),
        ),
      ),
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
      'JUGADOR': 'Jugador 1',
      'PTS POS': 100,
      'PTS ANT': 100,
      'VAR': '+',
      'PTS': 30,
      'ASIST': 23,
      'PTOS POS': 23,
      'EFEC': '63%',
      'SUB CTG': 10,
      'BON': 5,
      'PEN': 2,
    }
  ];

  void _addTableData(Map<String, dynamic> newData) {
    setState(() {
      _dynamicTableData.add(newData);
    });
  }

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
