import 'package:flutter/material.dart';
import '../utils/carrito.dart';

class PlatosScreen extends StatefulWidget {
  final String menuNombre;
  final List<dynamic> platos;

  const PlatosScreen({super.key, required this.menuNombre, required this.platos});

  @override
  State<PlatosScreen> createState() => _PlatosScreenState();
}

class _PlatosScreenState extends State<PlatosScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.menuNombre), backgroundColor: Colors.deepOrange, foregroundColor: Colors.white),
      body: ListView.builder(
        itemCount: widget.platos.length,
        itemBuilder: (context, index) {
          final plato = widget.platos[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              title: Text(plato['nombre'], style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(plato['descripcion'] ?? ''),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("\$${plato['precio']}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange, foregroundColor: Colors.white),
                    onPressed: () {
                      Carrito.agregar(plato);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${plato['nombre']} agregado!'), duration: const Duration(milliseconds: 500)));
                      setState(() {});
                    },
                    child: const Text("Agregar"),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}