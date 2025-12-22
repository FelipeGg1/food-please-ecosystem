from django.contrib import admin
from django.urls import path, include 
from rest_framework.routers import DefaultRouter
from restaurante.views import MenuViewSet, PlatoViewSet, PedidoViewSet 
from rest_framework.authtoken import views as token_views

# Configuración de rutas para la API (Flutter consume esto)
router = DefaultRouter()
router.register(r'menus', MenuViewSet)
router.register(r'platos', PlatoViewSet)
router.register(r'pedidos', PedidoViewSet) 

urlpatterns = [
    path('admin/', admin.site.urls),
    
    # 1. Rutas WEB (HTML para el Restaurante)
    # Envía todo lo que no sea admin/api a tu archivo restaurante/urls.py
    path('', include('restaurante.urls')), 
    
    # 2. Rutas API (Datos JSON para Flutter)
    # Ejemplo: localhost:8000/api/pedidos/
    path('api/', include(router.urls)), 
    
    # 3. Rutas Login Web
    path('usuarios/', include('usuarios.urls')), 
    
    # 4. RUTA CRÍTICA 
    # Esto permite que Flutter envíe usuario/pass y reciba el Token
    path('api-token-auth/', token_views.obtain_auth_token), 
]