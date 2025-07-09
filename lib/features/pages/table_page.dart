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
  String _searchTerm = '';
  // TODO: Implementar lógica de filtros si es necesario para 'General' y 'Mensual'
  // String _filterType = 'General';

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      appBar: AppBar(
        title: Text('Ranking de Jugadores', style: GoogleFonts.lato(color: AppColors.textWhite, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.secondBlack,
        elevation: 0, // Sin sombra para un look más plano
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.textWhite),
            tooltip: 'Cerrar Sesión',
            onPressed: () async {
              await authViewModel.cerrarSesion();
              // AuthWrapper debería manejar la navegación a LoginScreen
            },
          )
        ],
      ),
      body: Column( // Usar Column en lugar de SingleChildScrollView directo para mejor estructura
        children: [
          SearchWidget( // Widget de búsqueda renombrado y estilizado
            size: size,
            onChanged: (value) {
              setState(() {
                _searchTerm = value.toLowerCase();
              });
            },
          ),
          // TODO: Considerar si estos botones son filtros o acciones separadas
          // Por ahora, se mantienen visualmente pero sin funcionalidad de filtrado de datos de Firestore
          Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.05, vertical: size.height * 0.01),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RankingFilterChip( // Botón de Ranking estilizado
                  size: size,
                  label: 'Ranking Global',
                  isSelected: true, // Ejemplo, manejar estado si es un filtro
                  onTap: () { /* Lógica de filtro */ },
                ),
                // Puedes añadir más filtros aquí si es necesario
              ],
            ),
          ),
          Expanded( // Expanded para que StreamBuilder ocupe el espacio restante
            child: StreamBuilder<QuerySnapshot>(
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

                // Filtrar por término de búsqueda (nombre)
                if (_searchTerm.isNotEmpty) {
                  usuarios = usuarios.where((user) => user.nombre.toLowerCase().contains(_searchTerm)).toList();
                }

                // Reordenar para el usuario actual
                if (currentUserUid != null) {
                  usuarios.sort((a, b) {
                    if (a.uid == currentUserUid) return -1;
                    if (b.uid == currentUserUid) return 1;
                    return b.puntos.compareTo(a.puntos); // Mantener orden por puntos para los demás
                  });
                }

                if (usuarios.isEmpty && _searchTerm.isNotEmpty) {
                   return Center(child: Text('No se encontraron jugadores con "$_searchTerm".', style: GoogleFonts.lato(color: AppColors.textWhite)));
                }


                return TablaDatosJugador(
                  usuarios: usuarios,
                  currentUserUid: currentUserUid,
                  size: size, // Pasar size
                );
              },
            ),
          ),
          // Los DropButton podrían ser reemplazados por filtros o eliminados si no son necesarios
          // _buildFilterSection(size),
        ],
      ),
    );
  }

  // Widget _buildFilterSection(Size size) { // Ejemplo si se quieren mantener los DropButton como filtros
  //   return Padding(
  //     padding: EdgeInsets.symmetric(horizontal: size.width * 0.05, vertical: size.height * 0.02),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceAround,
  //       children: [
  //         DropButton(size: size, name: 'General', icon: Icons.stadium, onTap: () => setState(() => _filterType = 'General')),
  //         DropButton(size: size, name: 'Mensual', icon: Icons.calendar_today, onTap: () => setState(() => _filterType = 'Mensual')),
  //       ],
  //     ),
  //   );
  // }
}

class SearchWidget extends StatelessWidget { // Renombrado de SearchText
  const SearchWidget({
    super.key,
    required this.size,
    required this.onChanged,
  });

  final Size size;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.05, vertical: size.height * 0.02),
      child: TextFormField(
        onChanged: onChanged,
        style: GoogleFonts.lato(color: AppColors.textWhite, fontSize: size.width * 0.04),
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search, color: AppColors.textLightGray.withOpacity(0.7), size: size.width * 0.055),
          filled: true,
          fillColor: AppColors.secondBlack,
          hintText: 'Buscar jugador...',
          hintStyle: GoogleFonts.lato(color: AppColors.textLightGray.withOpacity(0.7), fontSize: size.width * 0.04),
          contentPadding: EdgeInsets.symmetric(vertical: size.height * 0.018, horizontal: size.width * 0.04),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.textLightGray.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
          ),
        ),
      ),
    );
  }
}

class RankingFilterChip extends StatelessWidget { // Renombrado de RankingButton
  const RankingFilterChip({
    super.key,
    required this.size,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final Size size;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) => onTap(),
      backgroundColor: AppColors.secondBlack,
      selectedColor: AppColors.primaryGreen,
      labelStyle: GoogleFonts.lato(
        color: isSelected ? AppColors.textBlack : AppColors.textWhite,
        fontSize: size.width * 0.038,
        fontWeight: FontWeight.bold,
      ),
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.03, vertical: size.height * 0.01),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: isSelected ? AppColors.primaryGreen : AppColors.textLightGray.withOpacity(0.5))
      ),
    );
  }
}


// class DropButton extends StatelessWidget { // Mantenido por si se reutiliza para filtros
//   const DropButton({
//     super.key,
//     required this.size,
//     required this.name,
//     required this.icon,
//     required this.onTap,
//   });

//   final Size size;
//   final String name;
//   final IconData icon;
//   final VoidCallback onTap;

//   @override
//   Widget build(BuildContext context) {
//     return InkWell( // Para efecto ripple
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(12),
//       child: Container(
//         padding: EdgeInsets.symmetric(horizontal: size.width * 0.03, vertical: size.height * 0.01),
//         decoration: BoxDecoration(
//           color: AppColors.secondBlack,
//           borderRadius: BorderRadius.circular(12),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.2),
//               blurRadius: 4,
//               offset: Offset(0,2),
//             )
//           ]
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(icon, color: AppColors.textWhite, size: size.width * 0.055),
//             SizedBox(width: size.width * 0.02),
//             Text(
//               name,
//               style: GoogleFonts.lato(
//                 color: AppColors.textWhite,
//                 fontSize: size.width * 0.04,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             SizedBox(width: size.width * 0.01),
//             Icon(Icons.arrow_drop_down, color: AppColors.textWhite, size: size.width * 0.05),
//           ],
//         ),
//       ),
//     );
//   }
// }


class TablaDatosJugador extends StatelessWidget {
  final List<Usuario> usuarios;
  final String? currentUserUid;
  final Size size; // Recibir size

  const TablaDatosJugador({super.key, required this.usuarios, this.currentUserUid, required this.size});

  @override
  Widget build(BuildContext context) {
    TextStyle headerTextStyle = GoogleFonts.lato(
      color: AppColors.textWhite,
      fontWeight: FontWeight.bold,
      fontSize: size.width * 0.028, // Ligeramente más pequeño para más columnas
    );

    TextStyle cellTextStyle = GoogleFonts.lato(
      color: AppColors.textWhite,
      fontSize: size.width * 0.028,
    );

    return Container(
      width: size.width, // Ocupar todo el ancho disponible
      margin: EdgeInsets.only(bottom: size.height * 0.02), // Margen inferior
      child: SingleChildScrollView( // Scroll horizontal para la tabla
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: ConstrainedBox( // Asegurar que DataTable tenga un ancho mínimo si no hay suficientes datos
            constraints: BoxConstraints(minWidth: size.width),
            child: DataTable(
            columnSpacing: size.width * 0.035, // Espacio entre columnas ajustado
            headingRowHeight: size.height * 0.055,
            dataRowMinHeight: size.height * 0.05,
            dataRowMaxHeight: size.height * 0.065, // Ligeramente más alto para el botón
            headingRowColor: WidgetStateProperty.resolveWith<Color?>((_) => AppColors.primaryBlack.withOpacity(0.5)), // Fondo oscuro para encabezado
            columns: <DataColumn>[
              DataColumn(label: Text('JUGADOR', style: headerTextStyle)),
              DataColumn(label: Text('PUNTOS', style: headerTextStyle)),
              DataColumn(label: Text('EFECT %', style: headerTextStyle)),
              DataColumn(label: Text('ASIST.', style: headerTextStyle)),
              DataColumn(label: Text('P. POS', style: headerTextStyle)),
              DataColumn(label: Text('ACCIÓN', style: headerTextStyle)),
            ],
            rows: usuarios.map((usuario) {
              bool isCurrentUser = usuario.uid == currentUserUid;
              return DataRow(
                color: WidgetStateProperty.resolveWith<Color?>((_) {
                  if (isCurrentUser) return AppColors.primaryGreen.withOpacity(0.15);
                  return Colors.transparent; // Fondo transparente para filas normales
                }),
                cells: <DataCell>[
                  DataCell(
                    Tooltip( // Tooltip para nombres largos
                      message: usuario.nombre,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: size.width * 0.25), // Ancho máximo para nombre
                        child: Text(usuario.nombre, style: cellTextStyle, overflow: TextOverflow.ellipsis),
                      ),
                    )
                  ),
                  DataCell(Text(usuario.puntos.toString(), style: cellTextStyle)),
                  DataCell(Text('${(usuario.efectividad * 100).toStringAsFixed(0)}%', style: cellTextStyle)),
                  DataCell(Text(usuario.asistencias.toString(), style: cellTextStyle)),
                  DataCell(Text(usuario.puntos_pos.toString(), style: cellTextStyle)),
                  DataCell(
                    isCurrentUser
                        ? Center( // Centrar el botón
                            child: IconButton(
                              padding: EdgeInsets.zero, // Quitar padding extra
                              constraints: const BoxConstraints(), // Quitar constraints extra
                              icon: Icon(Icons.edit_note_rounded, color: AppColors.primaryGreen, size: size.width * 0.05),
                              tooltip: 'Editar Perfil',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditProfileDataPage(usuario: usuario),
                                  ),
                                );
                              },
                            ),
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
