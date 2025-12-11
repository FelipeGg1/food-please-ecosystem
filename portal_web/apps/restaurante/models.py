from django.db import models

# 1. El Menú ej: "Desayunos", "Promociones", "Carta Principal"
class Menu(models.Model):
    nombre = models.CharField(max_length=100)
    activo = models.BooleanField(default=True)

    def __str__(self):
        return self.nombre

# 2. El Plato Ej: "huevos con ketchup", "Completo Italiano"
class Plato(models.Model):
    # Relación: Un plato pertenece a un Menú.
    # on_delete=models.CASCADE al borrar el menú, se borran sus platos.
    menu = models.ForeignKey(Menu, on_delete=models.CASCADE, related_name='platos')
    
    nombre = models.CharField(max_length=100)
    descripcion = models.TextField(blank=True, help_text="Ingredientes o detalles")
    precio = models.IntegerField()
    
    def __str__(self):
        return f"{self.nombre} - ${self.precio}"

class Pedido(models.Model):
    # Un pedido puede tener muchos platos, y un plato estar en muchos pedidos
    # Uso ManyToManyField para esto.
    platos = models.ManyToManyField(Plato)
    
    fecha = models.DateTimeField(auto_now_add=True)
    total = models.IntegerField(default=0)
    
    # Opcional: Nombre del cliente o mesa
    cliente = models.CharField(max_length=100, default="Cliente App")

    def __str__(self):
        return f"Pedido #{self.id} - {self.cliente}"