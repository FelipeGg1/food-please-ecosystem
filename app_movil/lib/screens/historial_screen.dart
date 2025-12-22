import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';

class HistorialPedidosScreen extends StatefulWidget {
  const HistorialPedidosScreen({super.key});

  @override
  State<HistorialPedidosScreen> createState() => _HistorialPedidosScreenState();
}

class _HistorialPedidosScreenState extends State<HistorialPedidosScreen> {
  List<dynamic> pedidos = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPedidos();
  }

  Future<void> fetchPedidos() async {
    final url = Uri.parse('http://10.0.2.2:8000/api/pedidos/');
    final authService = AuthService();
    final token = await authService.getToken();
    
    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Token $token",
        },
      );
      if (response.statusCode == 200) {
        List<dynamic> datos = jsonDecode(response.body);
        setState(() {
          pedidos = datos.reversed.toList(); 
          isLoading = false;
        });
      } else {
        print("Error del servidor: ${response.statusCode}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Error de conexión: $e");
      setState(() => isLoading = false);
    }
  }

  String formatearFecha(String fechaRaw) {
    try {
      return fechaRaw.split('T')[0];
    } catch (e) {
      return fechaRaw;
    }
  }

  // --- NUEVA FUNCIÓN: Define el color según el estado ---
  Color _getColorEstado(String? estado) {
    switch (estado) {
      case 'PENDIENTE':
        return Colors.orange; // Naranja para espera
      case 'EN_CAMINO':
        return Colors.blue;   // Azul para transporte
      case 'FINALIZADO':
      case 'ENTREGADO':
        return Colors.green;  // Verde para éxito
      case 'CANCELADO':
        return Colors.red;    // Rojo para cancelado
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mis Pedidos"), 
        backgroundColor: Colors.deepOrange, 
        foregroundColor: Colors.white
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : pedidos.isEmpty
              ? const Center(child: Text("Aún no has realizado pedidos."))
              : ListView.builder(
                  itemCount: pedidos.length,
                  itemBuilder: (context, index) {
                    final pedido = pedidos[index];
                    final estado = pedido['estado'] ?? 'DESCONOCIDO';

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getColorEstado(estado).withOpacity(0.2), // Fondo suave
                          child: Icon(Icons.receipt_long, color: _getColorEstado(estado)), // Icono del color del estado
                        ),
                        title: Text("Pedido #${pedido['id']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                        
                        // AQUÍ ES DONDE AGREGAMOS EL ESTADO ENCIMA DE LA FECHA
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 5),
                            // 1. ESTADO (Negrita y con color)
                            Row(
                              children: [
                                const Text("Estado: ", style: TextStyle(fontWeight: FontWeight.w500)),
                                Text(
                                  estado, 
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold, 
                                    color: _getColorEstado(estado)
                                  )
                                ),
                              ],
                            ),
                            // 2. FECHA (Debajo)
                            Text("Fecha: ${formatearFecha(pedido['fecha'])}"),
                          ],
                        ),
                        trailing: Text(
                          "\$${pedido['total']}",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}