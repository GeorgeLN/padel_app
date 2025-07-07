import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:padel_app/features/pages/_pages.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:padel_app/features/bloc/bottom_nav_cubit.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:padel_app/firebase_options.dart';
import 'package:padel_app/viewmodels/auth_viewmodel.dart';
import 'package:padel_app/views/login_screen.dart';
import 'package:padel_app/views/register_screen.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider( // Cambiado a MultiProvider para incluir AuthViewModel
      providers: [
        BlocProvider(
          create: (context) => BottomNavCubit(),
        ),
        ChangeNotifierProvider( // Proveedor para AuthViewModel
          create: (context) => AuthViewModel(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp( // SafeArea se puede aplicar dentro de las pantallas si es necesario
      title: 'Padel App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData( // Considera definir un tema base si no lo has hecho
        brightness: Brightness.dark, // Asumiendo tema oscuro por AppColors
        // Puedes añadir más personalización de tema aquí
      ),
      // initialRoute se manejará por el AuthWrapper
      // routes ya no se usará initialRoute directamente así
      home: AuthWrapper(), // Widget que decide qué pantalla mostrar
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/table': (context) => StartPage(), // Asumiendo que StartPage contiene TablePage
        // Podrías tener '/home': (context) => StartPage(),
      },
      // onGenerateRoute podría no ser necesario si todas las rutas principales están definidas
      // pero lo mantenemos por si acaso o para rutas dinámicas.
      onGenerateRoute: (settings) {
        if (settings.name == '/table') { // Asegúrate que las rutas aquí coincidan
          return MaterialPageRoute(
            builder: (context) => StartPage(),
          );
        }
        // Puedes añadir más lógica de onGenerateRoute si es necesario
        return null;
      },
    );
  }
}

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
        return const LoginScreen();
      },
    );
  }
}