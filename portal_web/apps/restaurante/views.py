from django.shortcuts import render, redirect, get_object_or_404
from .models import Menu, Plato, Pedido
from .forms import MenuForm, PlatoForm
from rest_framework import viewsets
from .serializers import MenuSerializer, PlatoSerializer, PedidoSerializer


# 1. Listar todos los menús (Inicio)
def lista_menus(request):
    menus = Menu.objects.all()
    return render(request, 'restaurante/lista_menus.html', {'menus': menus})

# 2. Crear un Menú nuevo
def crear_menu(request):
    if request.method == 'POST':
        form = MenuForm(request.POST)
        if form.is_valid():
            menu = form.save()
            # Al guardar, vamos directo al detalle para empezar a agregar platos
            return redirect('detalle_menu', id=menu.id)
    else:
        form = MenuForm()
    
    return render(request, 'restaurante/form_generico.html', {
        'form': form, 
        'titulo': 'Crear Nuevo Menú'
    })

#3. Eliminar menú
def eliminar_menu(request, id):
    menu = get_object_or_404(Menu, id=id)

    if request.method == 'POST':
        menu.delete()
        return redirect('lista_menus')

    # Si es GET, mostramos la página de confirmación
    return render(request, 'restaurante/confirmar_borrado.html', {'item': menu.nombre})


# 4. Ver detalle del Menú y sus Platos
def detalle_menu(request, id):
    menu = get_object_or_404(Menu, id=id)
    # Gracias al 'related_name' del modelo, podemos acceder a los platos así:
    platos = menu.platos.all()
    return render(request, 'restaurante/detalle_menu.html', {'menu': menu, 'platos': platos})

# 5. Agregar plato a un menú específico
def agregar_plato(request, menu_id):
    menu_padre = get_object_or_404(Menu, id=menu_id)
    
    if request.method == 'POST':
        form = PlatoForm(request.POST)
        if form.is_valid():
            # Guardamos el plato en memoria pero SIN subirlo a la BD aún
            plato = form.save(commit=False)
            # Le asignamos el menú padre manualmente
            plato.menu = menu_padre
            #lo guardamos en la BD
            plato.save()
            return redirect('detalle_menu', id=menu_id)
    else:
        form = PlatoForm()

    return render(request, 'restaurante/form_generico.html', {
        'form': form, 
        'titulo': f'Agregar plato a: {menu_padre.nombre}'
    })


# 6. Vista para eliminar un Plato
def eliminar_plato(request, id):
    plato = get_object_or_404(Plato, id=id)
    
    # Guardamos el ID del menú antes de borrar el plato para poder volver ahí
    menu_id = plato.menu.id 
    
    if request.method == 'POST':
        plato.delete()
        # Redirigimos de vuelta al detalle del menú padre
        return redirect('detalle_menu', id=menu_id)
    
    # Usamos la misma plantilla de confirmación, es reutilizable
    return render(request, 'restaurante/confirmar_borrado.html', {'item': plato.nombre})

# 7. Editar un Menú
def editar_menu(request, id):
    menu = get_object_or_404(Menu, id=id)
    
    if request.method == 'POST':
        # Pasamos 'instance=menu' para decirle que actualice ESTE menú, no cree uno nuevo
        form = MenuForm(request.POST, instance=menu)
        if form.is_valid():
            form.save()
            return redirect('lista_menus')
    else:
        # Cargamos el formulario con los datos actuales del menú
        form = MenuForm(instance=menu)

    return render(request, 'restaurante/form_generico.html', {
        'form': form, 
        'titulo': f'Editar Menú: {menu.nombre}'
    })

# 8. Editar un Plato
def editar_plato(request, id):
    plato = get_object_or_404(Plato, id=id)
    menu_id = plato.menu.id # Guardamos el ID para volver al menú correcto
    
    if request.method == 'POST':
        form = PlatoForm(request.POST, instance=plato)
        if form.is_valid():
            form.save()
            return redirect('detalle_menu', id=menu_id)
    else:
        form = PlatoForm(instance=plato)

    return render(request, 'restaurante/form_generico.html', {
        'form': form, 
        'titulo': f'Editar Plato: {plato.nombre}'
    })


class MenuViewSet(viewsets.ModelViewSet):
    queryset = Menu.objects.all()
    serializer_class = MenuSerializer

class PlatoViewSet(viewsets.ModelViewSet):
    queryset = Plato.objects.all()
    serializer_class = PlatoSerializer


class PedidoViewSet(viewsets.ModelViewSet):
    queryset = Pedido.objects.all()
    serializer_class = PedidoSerializer