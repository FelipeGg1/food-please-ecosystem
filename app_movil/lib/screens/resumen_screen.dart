import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/carrito.dart';

class ResumenPedidoScreen extends StatefulWidget {
  const ResumenPedidoScreen({super.key});

  @override
  State<ResumenPedidoScreen> createState() => _ResumenPedidoScreenState();
}

class _ResumenPedidoScreenState extends State<ResumenPedidoScreen> {
  bool isSending = false;

  Future<void> confirmarPedido() async {
    setState(() => isSending = true);
    final url = Uri.parse('http://10.0.2.2:8000/api/pedidos/');
    
    List<int> idsPlatos = Carrito.productos.map((e) => e['id'] as int).toList();
    final body = jsonEncode({
      "platos": idsPlatos,
      "total": Carrito.obtenerTotal(),
      "cliente": "Cliente Móvil"
    });

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (response.statusCode == 201) {
        Carrito.limpiar(); 
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("¡Éxito!"),
            content: const Text("Pedido guardado en historial."),
            actions: [
              TextButton(onPressed: () { Navigator.of(ctx).pop(); Navigator.of(context).pop(); }, child: const Text("Genial"))
            ],
          ),
        );
      } else {
        throw Exception('Error ${response.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
    } finally {
      setState(() => isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tu Carrito"), backgroundColor: Colors.deepOrange, foregroundColor: Colors.white),
      body: Carrito.productos.isEmpty
          ? const Center(child: Text("Tu carrito está vacío ☹️", style: TextStyle(fontSize: 18)))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: Carrito.productos.length,
                    itemBuilder: (context, index) {
                      final item = Carrito.productos[index];
                      return ListTile(
                        leading: const Icon(Icons.fastfood, color: Colors.grey),
                        title: Text(item['nombre']),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () { setState(() { Carrito.remover(index); }); },
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  color: Colors.grey.shade100,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("TOTAL:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          Text("\$${Carrito.obtenerTotal()}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                        ],
                      ),
                      const SizedBox(height: 15),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                          onPressed: isSending ? null : confirmarPedido,
                          child: isSending ? const CircularProgressIndicator(color: Colors.white) : const Text("CONFIRMAR PEDIDO", style: TextStyle(fontSize: 18)),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
    );
  }
}