class Carrito {
  static List<dynamic> productos = [];

  static void agregar(dynamic plato) {
    productos.add(plato);
  }

  static void remover(int index) {
    productos.removeAt(index);
  }

  static void limpiar() {
    productos.clear();
  }

  static int obtenerTotal() {
    int total = 0;
    for (var item in productos) {
      total += (item['precio'] as int);
    }
    return total;
  }
}