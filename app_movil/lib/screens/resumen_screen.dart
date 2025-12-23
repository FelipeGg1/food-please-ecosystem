import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/carrito.dart';
import '../services/auth_service.dart'; // Importante para obtener el token
import '../services/api_config.dart'; //Archivo de configuracion api

class ResumenPedidoScreen extends StatefulWidget {
  const ResumenPedidoScreen({super.key});

  @override
  State<ResumenPedidoScreen> createState() => _ResumenPedidoScreenState();
}

class _ResumenPedidoScreenState extends State<ResumenPedidoScreen> {
  bool isSending = false;

  Future<void> confirmarPedido() async {
    setState(() => isSending = true);

    // 1. Obtener el token de seguridad
    final authService = AuthService();
    final token = await authService.getToken();

    if (token == null) {
      setState(() => isSending = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error: No se encontró sesión activa"), backgroundColor: Colors.red),
      );
      return;
    }

    final url = Uri.parse(ApiConfig.pedidos);
    
    List<int> idsPlatos = Carrito.productos.map((e) => e['id'] as int).toList();
    
    // 2. Body limpio (Sin enviar 'cliente' manualmente)
    final body = jsonEncode({
      "platos": idsPlatos,
      "total": Carrito.obtenerTotal(),
      // "cliente": "Cliente Móvil" <-- Eliminado para evitar error 400
    });

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Token $token" // 3. Enviamos la credencial
        },
        body: jsonEncode({
          "platos": idsPlatos,
          "total": Carrito.obtenerTotal(),
        }),
      );

      // Diagnóstico en consola
      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 201) {
        Carrito.limpiar(); 
        if (!mounted) return;
        
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("¡Éxito!"),
            content: const Text("Pedido enviado correctamente."),
            actions: [
              TextButton(
                onPressed: () { 
                  Navigator.of(ctx).pop(); // Cierra Dialog
                  Navigator.of(context).pop(); // Cierra Pantalla Resumen
                }, 
                child: const Text("Genial")
              )
            ],
          ),
        );
      } else {
        // Mostrar error real del servidor en la pantalla
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error del servidor: ${response.body}"), backgroundColor: Colors.red)
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error de conexión: $e"), backgroundColor: Colors.red)
      );
    } finally {
      if (mounted) {
        setState(() => isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tu Carrito"), backgroundColor: Colors.deepOrange, foregroundColor: Colors.white),
      body: Carrito.productos.isEmpty
          ? const Center(child: Text("Tu carrito está vacío", style: TextStyle(fontSize: 18)))
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
                          child: isSending 
                            ? const CircularProgressIndicator(color: Colors.white) 
                            : const Text("CONFIRMAR PEDIDO", style: TextStyle(fontSize: 18)),
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