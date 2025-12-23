from django.urls import path, include
from rest_framework.routers import DefaultRouter
from . import views

# 1. Configuración del Router para la API (Para Flutter)
router = DefaultRouter()
router.register(r'api/menus', views.MenuViewSet, basename='api-menus')
router.register(r'api/platos', views.PlatoViewSet, basename='api-platos')
router.register(r'api/pedidos', views.PedidoViewSet, basename='api-pedidos')

urlpatterns = [

    # --- RUTAS WEB (Las que tú definiste para el Restaurante) ---
    # Home y Lista de Menús
    path('menus/', views.lista_menus, name='lista_menus'),
    path('', views.home, name='home'),

    # --- RUTAS DE LA API (Agregadas para que funcione Flutter) ---
    path('', include(router.urls)),
    
    # Gestión de Menús y Platos (CRUD)
    path('menu/nuevo/', views.crear_menu, name='crear_menu'),
    path('menu/<int:id>/', views.detalle_menu, name='detalle_menu'),
    path('menu/<int:menu_id>/agregar-plato/', views.agregar_plato, name='agregar_plato'),
    path('menu/eliminar/<int:id>/', views.eliminar_menu, name='eliminar_menu'),
    path('plato/eliminar/<int:id>/', views.eliminar_plato, name='eliminar_plato'),
    path('menu/editar/<int:id>/', views.editar_menu, name='editar_menu'),
    path('plato/editar/<int:id>/', views.editar_plato, name='editar_plato'),
    
    # Gestión de Pedidos (Flujo de Estados)
    path('pedidos/', views.lista_pedidos, name='lista_pedidos'),
    path('pedidos/<int:pedido_id>/empezar/', views.empezar_pedido, name='empezar_pedido'),
    path('pedidos/<int:pedido_id>/listo/', views.marcar_listo, name='marcar_listo'),
    path('pedidos/cancelar/<int:pedido_id>/', views.cancelar_pedido, name='cancelar_pedido'),
]