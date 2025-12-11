import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
    // Consultamos al Backend por todos los pedidos
    final url = Uri.parse('http://10.0.2.2:8000/api/pedidos/');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        // Ordenamos para ver el más reciente primero (reversed)
        List<dynamic> datos = jsonDecode(response.body);
        setState(() {
          pedidos = datos.reversed.toList(); 
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  // Pequeña función para limpiar la fecha fea de Django (2025-12-10T22:00:00Z)
  String formatearFecha(String fechaRaw) {
    try {
      return fechaRaw.split('T')[0]; // Toma solo la parte 'YYYY-MM-DD'
    } catch (e) {
      return fechaRaw;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mis Pedidos"), backgroundColor: Colors.deepOrange, foregroundColor: Colors.white),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : pedidos.isEmpty
              ? const Center(child: Text("Aún no has realizado pedidos."))
              : ListView.builder(
                  itemCount: pedidos.length,
                  itemBuilder: (context, index) {
                    final pedido = pedidos[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.blueGrey,
                          child: Icon(Icons.receipt_long, color: Colors.white),
                        ),
                        title: Text("Pedido #${pedido['id']}"),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Fecha: ${formatearFecha(pedido['fecha'])}"),
                            Text("Cliente: ${pedido['cliente']}"),
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