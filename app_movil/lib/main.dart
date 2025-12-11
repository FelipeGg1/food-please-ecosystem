import 'package:flutter/material.dart';
// Importamos la pantalla inicial desde su carpeta
import 'screens/menu_screen.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FoodPlease',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      // Aquí simplemente llamamos a la pantalla que moviste
      home: const MenuScreen(),
    );
  }
}