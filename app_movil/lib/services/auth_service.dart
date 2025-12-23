import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_config.dart'; 

class AuthService {
  // final String baseUrl = 'http://10.0.2.2:8000';
  final url = Uri.parse(ApiConfig.loginAuth);
  Future<Map<String, dynamic>?> login(String email, String password) async {

    // final url = Uri.parse('$baseUrl/usuarios/api-token-auth/');
    
    try {
      final response = await http.post(
        url,
        body: {
          'username': email, 
          'password': password,
        },
      );
      print("Status Login: ${response.statusCode}");
      print("Cuerpo Login: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', data['token']);
        
        // Guardamos el valor
        bool esRep = data['is_repartidor'] ?? false;
        await prefs.setBool('is_repartidor', esRep);

        return data;
      }
      return null;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  // Método para consultar el rol guardado
  Future<bool> esRepartidor() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_repartidor') ?? false;
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('is_repartidor');
  }
}