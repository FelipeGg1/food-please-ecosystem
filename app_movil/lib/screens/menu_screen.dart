import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/carrito.dart';
import '../widgets/app_drawer.dart';
import 'platos_screen.dart';
import 'resumen_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  List<dynamic> menus = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMenus();
  }

  void refrescar() {
    setState(() {});
  }

  Future<void> fetchMenus() async {
    final url = Uri.parse('http://10.0.2.2:8000/api/menus/');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          menus = jsonDecode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(), // <--- AQUÍ AGREGAMOS EL MENÚ LATERAL
      appBar: AppBar(
        title: const Text('FoodPlease', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepOrange,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ResumenPedidoScreen()),
                  ).then((_) => refrescar());
                },
              ),
              if (Carrito.productos.isNotEmpty)
                Positioned(
                  right: 5,
                  top: 5,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${Carrito.productos.length}',
                      style: const TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                )
            ],
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: menus.length,
              itemBuilder: (context, index) {
                final item = menus[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    leading: const Icon(Icons.restaurant_menu, color: Colors.orange),
                    title: Text(item['nombre'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PlatosScreen(
                            menuNombre: item['nombre'],
                            platos: item['platos'],
                          ),
                        ),
                      ).then((_) => refrescar());
                    },
                  ),
                );
              },
            ),
      floatingActionButton: Carrito.productos.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ResumenPedidoScreen()),
                ).then((_) => refrescar());
              },
              label: Text('Ver Carrito (\$${Carrito.obtenerTotal()})'),
              icon: const Icon(Icons.shopping_cart_checkout),
              backgroundColor: Colors.green,
            )
          : null,
    );
  }
}