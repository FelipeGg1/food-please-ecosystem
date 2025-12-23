import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';
import '../widgets/app_drawer.dart';
import '../services/api_config.dart'; 

class RepartidorHomeScreen extends StatefulWidget {
  const RepartidorHomeScreen({super.key});

  @override
  State<RepartidorHomeScreen> createState() => _RepartidorHomeScreenState();
}

class _RepartidorHomeScreenState extends State<RepartidorHomeScreen> {
  List<dynamic> misEntregas = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMisEntregas();
  }

  // 1. Obtener los pedidos que estoy llevando (EN_CAMINO)
  Future<void> fetchMisEntregas() async {
    final token = await AuthService().getToken();
    // final url = Uri.parse('http://10.0.2.2:8000/api/pedidos/mis_entregas/');
    final url = Uri.parse(ApiConfig.misEntregas);

    try {
      final response = await http.get(url, headers: {
        'Authorization': 'Token $token',
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        setState(() {
          misEntregas = json.decode(response.body);
          isLoading = false;
        });
      } else {
        print("Error Server: ${response.body}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Error Conexión: $e");
      setState(() => isLoading = false);
    }
  }

  // 2. Acción para marcar como FINALIZADO
  Future<void> finalizarEntrega(int idPedido) async {
    final token = await AuthService().getToken();
    // final url = Uri.parse('http://10.0.2.2:8000/api/pedidos/$idPedido/finalizar_entrega/');
    final url = Uri.parse(ApiConfig.finalizarEntrega(idPedido));
    
    try {
      final response = await http.post(url, headers: {
        'Authorization': 'Token $token',
        'Content-Type': 'application/json',
      });

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("¡Entrega completada! 💰"), backgroundColor: Colors.green),
        );
        // Recargamos la lista para que desaparezca el pedido finalizado
        fetchMisEntregas();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error al finalizar entrega"), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  // Confirmación visual antes de finalizar
  void confirmarFinalizacion(int idPedido) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("¿Confirmar entrega?"),
        content: const Text("El pedido se marcará como entregado y finalizado."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () {
              Navigator.of(ctx).pop(); // Cierra el diálogo
              finalizarEntrega(idPedido); // Ejecuta la acción
            },
            child: const Text("ENTREGADO", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mis Entregas Activas", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueGrey,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: fetchMisEntregas)
        ],
      ),
      drawer: const AppDrawer(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : misEntregas.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.moped, size: 80, color: Colors.blueGrey),
                      const SizedBox(height: 20),
                      const Text("No tienes entregas en curso.", style: TextStyle(fontSize: 18)),
                      TextButton.icon(
                        icon: const Icon(Icons.search),
                        label: const Text("Buscar pedidos disponibles"),
                        onPressed: () {
                          // Navegación rápida a disponibles si no tiene trabajo
                          Navigator.pushNamed(context, '/pedidos_disponibles'); 
                          // Si no tienes esta ruta nombrada, usa push MaterialPageRoute
                        },
                      )
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: misEntregas.length,
                  itemBuilder: (context, index) {
                    final pedido = misEntregas[index];
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: Column(
                        children: [
                          // Cabecera de la tarjeta
                          Container(
                            padding: const EdgeInsets.all(15),
                            decoration: const BoxDecoration(
                              color: Colors.blueGrey,
                              borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Pedido #${pedido['id']}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                                const Icon(Icons.access_time, color: Colors.white70),
                              ],
                            ),
                          ),
                          // Cuerpo de la tarjeta
                          Padding(
                            padding: const EdgeInsets.all(15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.person, color: Colors.grey),
                                    const SizedBox(width: 10),
                                    Text("Cliente: ${pedido['cliente'] ?? 'Desconocido'}", style: const TextStyle(fontSize: 16)),
                                  ],
                                ),
                                const SizedBox(height: 10),

                                const Divider(), // Separador visual
                                const Text("Detalle del Pedido:", style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 5),

                                // --- INICIO DEL CAMBIO: LISTA DE PRODUCTOS ---
                                // Verificamos si Django envió el campo 'contenido'
                                if (pedido['contenido'] != null)
                                  ...((pedido['contenido'] as List).map((item) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                                      child: Row(
                                        children: [
                                          // Cantidad en un badge visual
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.blueGrey.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              "${item['cantidad']}x", 
                                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          // Nombre del plato
                                          Expanded(
                                            child: Text(
                                              item['nombre'], 
                                              style: const TextStyle(fontSize: 16),
                                              overflow: TextOverflow.ellipsis, // Corta con "..." si es muy largo
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList())
                                else
                                  const Text("Cargando detalle...", style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
                                // --- FIN DEL CAMBIO ---

                                const SizedBox(height: 10),
                                const Divider(), 

                                
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    const Text("Total Pedido: ", style: TextStyle(fontSize: 16)),
                                    Text(
                                      "\$${pedido['total']}", 
                                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)
                                    ),
                                  ],
                                ),
                                
                                const SizedBox(height: 15),
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                    ),
                                    icon: const Icon(Icons.check_circle),
                                    label: const Text("MARCAR COMO ENTREGADO"),
                                    onPressed: () => confirmarFinalizacion(pedido['id']),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}