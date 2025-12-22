import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'menu_screen.dart';
import 'repartidor_screen.dart';
// import 'home_screen.dart'; // Descomenta cuando tengas tu Home

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  void _iniciarSesion() async {
    setState(() => _isLoading = true);
    
    // Ahora 'data' contiene el mapa con {token, is_repartidor, ...}
    final data = await _authService.login(
      _emailController.text, 
      _passController.text
    );

    setState(() => _isLoading = false);

    if (data != null) {
      // Extraemos el rol que viene desde Django
      print("LLAVES RECIBIDAS: ${data.keys.toList()}"); // <--- ESTO NOS DIRÁ LA VERDAD
  
      final bool esRepartidor = data['is_repartidor'] == true;
      print("¿Flutter reconoce al repartidor?: $esRepartidor");
      print("¿Flutter reconoce al repartidor?: $esRepartidor");
      if (!mounted) return;

      // 1. Mostramos el mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Bienvenido! Login exitoso')),
      );

      // 2. NAVEGACIÓN INTELIGENTE:
      // Si es staff en Django, va a la pantalla de repartidor, sino al menú de clientes.
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(
          builder: (_) => esRepartidor 
              ? const RepartidorHomeScreen() 
              : const MenuScreen()
        )
      );
      
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Credenciales incorrectas'), 
          backgroundColor: Colors.red
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fastfood, size: 80, color: Colors.orange),
            SizedBox(height: 20),
            Text("FoodPlease", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            SizedBox(height: 40),
            
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _passController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Contraseña",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            SizedBox(height: 30),
            
            _isLoading 
              ? CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: _iniciarSesion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    minimumSize: Size(double.infinity, 50),
                  ),
                  child: Text("INGRESAR", style: TextStyle(color: Colors.white)),
                ),
          ],
        ),
      ),
    );
  }
}