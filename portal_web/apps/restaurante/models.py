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
    available = models.BooleanField(default=True) # Agregué esto por si lo usas en el form
    
    def __str__(self):
        return f"{self.nombre} - ${self.precio}"

# 3. El Pedido (COMPLETO)
class Pedido(models.Model):
    # --- TUS CAMPOS ORIGINALES ---
    platos = models.ManyToManyField(Plato)
    total = models.IntegerField(default=0)
    
    # --- LOS NUEVOS CAMPOS DE ESTADO ---
    PENDIENTE = 'PENDIENTE'
    EN_CAMINO = 'EN_CAMINO'
    FINALIZADO = 'FINALIZADO'
    CANCELADO = 'CANCELADO'
    
    ESTADOS_CHOICES = [
        (PENDIENTE, 'Pendiente'),
        (FINALIZADO, 'Finalizado'),
        (EN_CAMINO, 'En Camino (Repartidor asignado)'),
        (CANCELADO, 'Cancelado (No Finalizado)'),
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
    estado = models.CharField(max_length=20, choices=ESTADOS_CHOICES, default=PENDIENTE)
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