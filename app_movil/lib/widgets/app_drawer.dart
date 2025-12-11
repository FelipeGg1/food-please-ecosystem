import 'package:flutter/material.dart';
import '../screens/menu_screen.dart';
import '../screens/historial_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.deepOrange),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.fastfood, color: Colors.white, size: 40),
                SizedBox(height: 10),
                Text('FoodPlease', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Inicio'),
            onTap: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MenuScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Mis Pedidos'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const HistorialPedidosScreen()));
            },
          ),
        ],
      ),
    );
  }
}