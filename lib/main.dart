import 'package:flutter/material.dart';
import 'package:padel_app/features/pages/table_page.dart';

void main() => runApp(const MyApp());

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
          'table': (context) => TablaEstadisticasWidget(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == 'table') {
            return MaterialPageRoute(
              builder: (context) => TablaEstadisticasWidget(),
            );
          }
          return null;
        },
      ),
    );
  }
}