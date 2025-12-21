from django.db import models
from django.contrib.auth.models import AbstractUser

class Usuario(AbstractUser):
    # Definimos los ROLES como constantes para evitar errores de dedo
    ADMIN = 'ADMIN'
    CLIENTE = 'CLIENTE'
    REPARTIDOR = 'REPARTIDOR'

    ROLES_CHOICES = [
        (ADMIN, 'Administrador'),
        (CLIENTE, 'Cliente'),
        (REPARTIDOR, 'Repartidor'),
    ]

    # Campos adicionales a los que ya trae Django por defecto
    email = models.EmailField(unique=True) # Hacemos el email obligatorio y único
    rol = models.CharField(max_length=20, choices=ROLES_CHOICES, default=CLIENTE)
    telefono = models.CharField(max_length=15, blank=True, null=True)
    direccion = models.TextField(blank=True, null=True)

    # Opcional: Usar el email como login principal en lugar del username
    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['username', 'rol'] # Campos que te pedirá al crear superuser por consola

    def __str__(self):
        return f"{self.username} ({self.rol})"