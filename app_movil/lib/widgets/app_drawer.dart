import 'package:flutter/material.dart';
import '../services/auth_service.dart';
// Asegúrate de que estas rutas sean correctas en tu proyecto:
import '../screens/menu_screen.dart';
import '../screens/historial_screen.dart';
import '../screens/login_screen.dart';
import '../screens/repartidor_screen.dart';
import '../screens/pedidos_disponibles_screen.dart'; 

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: AuthService().esRepartidor(), // Consulta el rol guardado en el celular
      builder: (context, snapshot) {
        // Mientras carga, muestra un círculo de espera
        if (!snapshot.hasData) {
          return const Drawer(child: Center(child: CircularProgressIndicator()));
        }

        final bool esRepartidor = snapshot.data!;
        
        
        // --- COLORES Y TEXTOS DINÁMICOS ---
        // Si es repartidor: Azul Gris. Si es cliente: Naranja.
        final Color headerColor = esRepartidor ? Colors.blueGrey : Colors.deepOrange;
        final String titulo = esRepartidor ? "Panel Repartidor" : "FoodPlease";
        
        // CORRECCIÓN: Usamos 'local_shipping' para evitar el error rojo
        final IconData iconoPrincipal = esRepartidor ? Icons.local_shipping : Icons.fastfood;

        return Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              // 1. CABECERA (HEADER)
              DrawerHeader(
                decoration: BoxDecoration(color: headerColor),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(iconoPrincipal, color: Colors.white, size: 40),
                    const SizedBox(height: 10),
                    Text(titulo, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    Text(
                      esRepartidor ? "Modo Trabajo" : "Bienvenido",
                      style: const TextStyle(color: Colors.white70, fontSize: 14)
                    ),
                  ],
                ),
              ),

              // 2. BOTÓN INICIO (Inteligente)
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Inicio'),
                onTap: () {
                  Navigator.pop(context); 
                  // Redirige a la pantalla correcta según quién sea
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => esRepartidor 
                        ? const RepartidorHomeScreen() 
                        : const MenuScreen()
                    ),
                  );
                },
              ),

              // 3. OPCIONES ESPECÍFICAS (Según Rol)
              if (esRepartidor) ...[
                // === SOLO REPARTIDOR ===
                ListTile(
                  leading: const Icon(Icons.list_alt, color: Colors.blueGrey),
                  title: const Text('Pedidos Disponibles'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PedidosDisponiblesScreen())
                    );
                  },
                ),
              ] else ...[
                // === SOLO CLIENTE ===
                ListTile(
                  leading: const Icon(Icons.history),
                  title: const Text('Mis Pedidos'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const HistorialPedidosScreen())
                    );
                  },
                ),
              ],

              const Divider(),

              // 4. CERRAR SESIÓN
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
                onTap: () async {
                  await AuthService().logout();
                  if (!context.mounted) return;

                  // Navegación limpia al Login
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}