from django.contrib import admin
from .models import Menu, Plato, Pedido

# Configuración para ver los Menús
class MenuAdmin(admin.ModelAdmin):
    list_display = ('nombre', 'activo')

# Configuración para ver los Platos
class PlatoAdmin(admin.ModelAdmin):
    list_display = ('nombre', 'menu', 'precio', 'available')
    list_filter = ('menu', 'available') # Filtros laterales

# Configuración AVANZADA para los Pedidos
class PedidoAdmin(admin.ModelAdmin):
    # Qué columnas ver en la lista
    list_display = ('id', 'cliente', 'fecha', 'estado', 'total')
    
    # Filtros laterales útiles
    list_filter = ('estado', 'fecha')
    
    # Permitir buscar por email del cliente
    search_fields = ('cliente__email', 'cliente__username')

# Registramos todo
admin.site.register(Menu, MenuAdmin)
admin.site.register(Plato, PlatoAdmin)
admin.site.register(Pedido, PedidoAdmin)