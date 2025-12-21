from django.urls import path
from . import views

urlpatterns = [
    # Ruta vacía = Lista de Menús (Home)
    path('menus/', views.lista_menus, name='lista_menus'),
    path('', views.home, name='home'),
    
    # Crear un menú nuevo
    path('menu/nuevo/', views.crear_menu, name='crear_menu'),
    
    # Ver el detalle de un menú (y sus platos)
    path('menu/<int:id>/', views.detalle_menu, name='detalle_menu'),
    
    # Agregar plato a un menú específico
    path('menu/<int:menu_id>/agregar-plato/', views.agregar_plato, name='agregar_plato'),

    #Eliminar menu especifico
    path('menu/eliminar/<int:id>/', views.eliminar_menu, name='eliminar_menu'),

    # Ruta para borrar plato
    path('plato/eliminar/<int:id>/', views.eliminar_plato, name='eliminar_plato'),

    # Ruta para editar menú
    path('menu/editar/<int:id>/', views.editar_menu, name='editar_menu'),
    
    # Ruta para editar plato
    path('plato/editar/<int:id>/', views.editar_plato, name='editar_plato'),
    
    path('pedidos/', views.lista_pedidos, name='lista_pedidos'),
    path('pedidos/finalizar/<int:pedido_id>/', views.finalizar_pedido, name='finalizar_pedido'),
    path('pedidos/cancelar/<int:pedido_id>/', views.cancelar_pedido, name='cancelar_pedido'),
    path('pedidos/tomar/<int:pedido_id>/', views.tomar_pedido, name='tomar_pedido'),
]