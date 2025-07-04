import 'package:flutter/material.dart';
import 'package:padel_app/features/pages/_pages.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:padel_app/features/bloc/bottom_nav_cubit.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:padel_app/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => BottomNavCubit(),
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
    return SafeArea(
      child: MaterialApp(
        title: 'Padel App',
        debugShowCheckedModeBanner: false,
      
        initialRoute: 'table',
        routes: {
          'table': (context) => StartPage(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == 'table') {
            return MaterialPageRoute(
              builder: (context) => StartPage(),
            );
          }
          return null;
        },
      ),
    );
  }
}