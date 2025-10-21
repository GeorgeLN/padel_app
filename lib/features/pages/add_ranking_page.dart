import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:padel_app/data/repositories/ranking_repository.dart';
import 'package:padel_app/data/viewmodels/ranking_viewmodel.dart';
import 'package:padel_app/features/design/app_colors.dart';
import 'package:provider/provider.dart';

class AddRankingPage extends StatelessWidget {
  final String collectionName;
  final String title;

  const AddRankingPage({
    super.key,
    required this.collectionName,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RankingViewModel(
        repository: Provider.of<RankingRepository>(context, listen: false),
      )..getUsers(),
      child: _AddRankingPageContent(
        collectionName: collectionName,
        title: title,
      ),
    );
  }
}

class _AddRankingPageContent extends StatefulWidget {
  final String collectionName;
  final String title;

  const _AddRankingPageContent({
    required this.collectionName,
    required this.title,
  });

  @override
  State<_AddRankingPageContent> createState() => _AddRankingPageContentState();
}

class _AddRankingPageContentState extends State<_AddRankingPageContent> {
  final _nameController = TextEditingController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      Provider.of<RankingViewModel>(context, listen: false)
          .filterUsers(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<RankingViewModel>(context);

    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      appBar: AppBar(
        title: Text('Añadir a ${widget.title}',
            style: GoogleFonts.lato(color: AppColors.textWhite)),
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
                labelText: 'Nombre del Club / Ciudad / Grupo de WhatsApp',
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
            TextFormField(
              controller: _searchController,
              style: GoogleFonts.lato(color: AppColors.textWhite),
              decoration: InputDecoration(
                labelText: 'Buscar jugador por nombre o documento',
                labelStyle: GoogleFonts.lato(color: AppColors.textWhite),
                prefixIcon:
                    const Icon(Icons.search, color: AppColors.primaryGreen),
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
              child: viewModel.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primaryGreen))
                  : ListView.builder(
                      itemCount: viewModel.filteredUsers.length,
                      itemBuilder: (context, index) {
                        final user = viewModel.filteredUsers[index];
                        final isSelected =
                            viewModel.selectedUserIds.contains(user.uid);
                        return ListTile(
                          title: Text(user.nombre,
                              style:
                                  GoogleFonts.lato(color: AppColors.textWhite)),
                          subtitle: Text(user.documento,
                              style: GoogleFonts.lato(
                                  color: AppColors.textLightGray)),
                          trailing: IconButton(
                            icon: Icon(
                              isSelected
                                  ? Icons.remove_circle
                                  : Icons.add_circle,
                              color: isSelected
                                  ? Colors.red
                                  : AppColors.primaryGreen,
                            ),
                            onPressed: () =>
                                viewModel.toggleUserSelection(user.uid),
                          ),
                        );
                      },
                    ),
            ),
            if (viewModel.errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  viewModel.errorMessage!,
                  style: GoogleFonts.lato(color: Colors.red),
                ),
              ),
            ElevatedButton(
              onPressed: () async {
                final success = await viewModel.saveRanking(
                  name: _nameController.text,
                  collectionName: widget.collectionName,
                );
                if (success && mounted) {
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen),
              child: Text('Guardar',
                  style: GoogleFonts.lato(color: AppColors.textWhite)),
            ),
          ],
        ),
      ),
    );
  }
}
