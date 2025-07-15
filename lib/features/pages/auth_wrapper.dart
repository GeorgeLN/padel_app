
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:padel_app/data/viewmodels/auth_viewmodel.dart';

import '../design/app_colors.dart';
import '_pages.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Escucha los cambios de estado de autenticación
    final authViewModel = Provider.of<AuthViewModel>(context);

    return StreamBuilder<User?>(
      stream: authViewModel.authStateChanges,
      builder: (context, snapshot) {
        // Muestra un indicador de carga mientras se verifica el estado
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppColors.primaryBlack, // Usa tus colores
            body: Center(child: CircularProgressIndicator(color: AppColors.primaryGreen)),
          );
        }

        // Si el usuario está autenticado, muestra la pantalla principal
        if (snapshot.hasData && snapshot.data != null) {
          return StartPage(); // O la ruta '/table'
        }

        // Si no está autenticado, muestra la pantalla de login
        return const LoginPage();
      },
    );
  }
}