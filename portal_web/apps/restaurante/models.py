from django.db import models
from django.conf import settings

# 1. El Menú
class Menu(models.Model):
    nombre = models.CharField(max_length=100)
    activo = models.BooleanField(default=True)

    def __str__(self):
        return self.nombre

# 2. El Plato
class Plato(models.Model):
    menu = models.ForeignKey(Menu, on_delete=models.CASCADE, related_name='platos')
    nombre = models.CharField(max_length=100)
    descripcion = models.TextField(blank=True, help_text="Ingredientes o detalles")
    precio = models.IntegerField()
    available = models.BooleanField(default=True)
    
    def __str__(self):
        return f"{self.nombre} - ${self.precio}"
def cantidad_platos(self):
        return self.platos.count()

def costo_total(self):
    # Usamos 'platos' para sumar los precios
    # El 'or 0' es para que si no hay platos, devuelva 0 en vez de error
    return sum(plato.precio for plato in self.platos.all()) or 0


cantidad_platos.short_description = "N° Platos"
costo_total.short_description = "Costo Total"


# 3. El Pedido (COMPLETO)
class Pedido(models.Model):
    platos = models.ManyToManyField(Plato)
    total = models.IntegerField(default=0)
    
    # --- LOS NUEVOS CAMPOS DE ESTADO ---
    PENDIENTE = 'PENDIENTE'           # Cliente pide
    COCINANDO = 'COCINANDO'           # Restaurante acepta y cocina
    LISTO = 'LISTO'                   # Comida empacada (Visible para Repartidor)
    EN_CAMINO = 'EN_CAMINO'           # Repartidor recogió
    ENTREGADO = 'ENTREGADO'           # Fin
    CANCELADO = 'CANCELADO'

    ESTADO_CHOICES = [
        (PENDIENTE, 'Pendiente (Esperando confirmación)'),
        (COCINANDO, 'En Preparación (Cocinando)'),
        (LISTO, 'Listo para Recogida (Esperando Repartidor)'), 
        (EN_CAMINO, 'En Camino'),
        (ENTREGADO, 'Entregado'),
        (CANCELADO, 'Cancelado'),
    ]

    SIN_INSUMOS = 'SIN_INSUMOS'
    FUERZA_MAYOR = 'FUERZA_MAYOR'
    CLIENTE_NO_APARECIO = 'CLIENTE_NO_APARECIO'
    OTRO = 'OTRO'

    MOTIVOS_CHOICES = [
        (SIN_INSUMOS, 'Falta de Insumos'),
        (FUERZA_MAYOR, 'Motivos de Fuerza Mayor'),
        (CLIENTE_NO_APARECIO, 'Cliente no se presentó'),
        (OTRO, 'Otros'),
    ]

    # Campos de relación y estado
    cliente = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='pedidos_cliente')
    fecha = models.DateTimeField(auto_now_add=True)
    estado = models.CharField(max_length=20, choices=ESTADO_CHOICES, default=PENDIENTE)
    motivo_cancelacion = models.CharField(max_length=50, choices=MOTIVOS_CHOICES, blank=True, null=True)

    repartidor = models.ForeignKey(
        settings.AUTH_USER_MODEL, 
        on_delete=models.SET_NULL, 
        null=True, 
        blank=True,
        related_name='pedidos_repartidor'
    )

    def __str__(self):
        return f"Pedido #{self.id} - {self.cliente}"