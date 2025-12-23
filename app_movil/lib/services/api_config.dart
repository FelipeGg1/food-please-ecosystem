import 'package:flutter/foundation.dart'; // Necesario para kReleaseMode

class ApiConfig {
  // Lógica centralizada:
  // Si es Release (APK generado) -> Usa Railway
  // Si es Debug (Emulador) -> Usa 10.0.2.2
  static String get baseUrl {
    if (kReleaseMode) {
      return 'https://food-please-ecosystem-production.up.railway.app/'; //
    } else {
      return 'http://10.0.2.2:8000';
    }
  }

  // 2. Rutas Fijas
  static String get pedidos => '$baseUrl/api/pedidos/';
  static String get login => '$baseUrl/api/login/'; 
  static String get menu => '$baseUrl/api/menu/';   
  static String get menus => '$baseUrl/api/menus/';
  static String get misEntregas => '$baseUrl/api/pedidos/mis_entregas/';
  static String get disponibles => '$baseUrl/api/pedidos/disponibles/';
  static String get loginAuth => '$baseUrl/usuarios/api-token-auth/';

  // 3. Rutas Dinámicas
  static String finalizarEntrega(int id) => '$baseUrl/api/pedidos/$id/finalizar_entrega/';
  static String tomarPedido(int id) => '$baseUrl/api/pedidos/$id/tomar/';

  // import '../services/api_config.dart'; 
}