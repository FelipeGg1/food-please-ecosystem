import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';
import '../widgets/app_drawer.dart';

class PedidosDisponiblesScreen extends StatefulWidget {
  const PedidosDisponiblesScreen({super.key});

  @override
  State<PedidosDisponiblesScreen> createState() => _PedidosDisponiblesScreenState();
}

class _PedidosDisponiblesScreenState extends State<PedidosDisponiblesScreen> {
  // Variable para forzar refresco de la lista
  Future<List<dynamic>>? _futurePedidos;

  @override
  void initState() {
    super.initState();
    _futurePedidos = fetchPedidosDisponibles(); // Carga inicial
  }

  Future<List<dynamic>> fetchPedidosDisponibles() async {
    final token = await AuthService().getToken();
    final url = Uri.parse('http://10.0.2.2:8000/api/pedidos/disponibles/');

    final response = await http.get(url, headers: {
      'Authorization': 'Token $token',
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al cargar pedidos');
    }
  }

  // --- NUEVA LÓGICA PARA TOMAR PEDIDO ---
  Future<void> tomarPedido(int idPedido) async {
    final token = await AuthService().getToken();
    // Llamamos al nuevo endpoint que creamos en Django
    final url = Uri.parse('http://10.0.2.2:8000/api/pedidos/$idPedido/tomar/'); 

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        // ÉXITO: Mostramos mensaje y recargamos la lista
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("¡Pedido tomado con éxito! 🛵"), backgroundColor: Colors.green),
        );
        setState(() {
          // Esto hará que el FutureBuilder se ejecute de nuevo
          _futurePedidos = fetchPedidosDisponibles(); 
        });
      } else {
        // ERROR (Ej: Ya lo tomó otro)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error: No se pudo tomar el pedido"), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error de conexión: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pedidos Disponibles", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueGrey,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Botón extra para recargar manualmente si se quiere
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _futurePedidos = fetchPedidosDisponibles();
              });
            },
          )
        ],
      ),
      drawer: const AppDrawer(),
      body: FutureBuilder<List<dynamic>>(
        future: _futurePedidos, // Usamos la variable de estado
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 60, color: Colors.grey),
                  SizedBox(height: 10),
                  Text("¡Todo al día! No hay pedidos pendientes."),
                ],
              ),
            );
          }

          final pedidos = snapshot.data!;

          return ListView.builder(
            itemCount: pedidos.length,
            itemBuilder: (context, index) {
              final pedido = pedidos[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.blueGrey,
                    child: Icon(Icons.shopping_bag, color: Colors.white),
                  ),
                  title: Text("Pedido #${pedido['id']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Total: \$${pedido['total']}\nCliente: ${pedido['cliente'] ?? 'App'}"), // Asegúrate que tu serializer envíe info del cliente si quieres mostrarla
                  isThreeLine: true,
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white
                    ),
                    onPressed: () {
                      // Llamamos a la función pasando el ID
                      tomarPedido(pedido['id']);
                    },
                    child: const Text("TOMAR"),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}