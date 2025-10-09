
import 'package:flutter/material.dart';
import 'package:padel_app/data/repositories/auth_repository.dart';
import 'package:padel_app/features/pages/_pages.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:padel_app/features/bloc/bottom_nav_cubit.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:padel_app/firebase_options.dart';
import 'package:padel_app/data/viewmodels/auth_viewmodel.dart';
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
          create: (context) => AuthViewModel(repository: AuthRepository()),
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
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
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