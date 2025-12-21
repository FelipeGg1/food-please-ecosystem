from django.shortcuts import render, redirect, get_object_or_404
from .models import Menu, Plato, Pedido
# AGREGADO: Importamos el formulario de cancelación
from .forms import MenuForm, PlatoForm, CancelarPedidoForm 
from rest_framework import viewsets
from .serializers import MenuSerializer, PlatoSerializer, PedidoSerializer
from django.contrib.auth.decorators import login_required

# ==========================================
# GESTIÓN DE MENÚS Y PLATOS (TU CÓDIGO)
# ==========================================

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
            return redirect('detalle_menu', id=menu.id)
    else:
        form = MenuForm()
    
    return render(request, 'restaurante/form_generico.html', {
        'form': form, 
        'titulo': 'Crear Nuevo Menú'
    })

# 3. Eliminar menú
def eliminar_menu(request, id):
    menu = get_object_or_404(Menu, id=id)

    if request.method == 'POST':
        menu.delete()
        return redirect('lista_menus')

    return render(request, 'restaurante/confirmar_borrado.html', {'item': menu.nombre})


# 4. Ver detalle del Menú y sus Platos
def detalle_menu(request, id):
    menu = get_object_or_404(Menu, id=id)
    platos = menu.platos.all()
    return render(request, 'restaurante/detalle_menu.html', {'menu': menu, 'platos': platos})

# 5. Agregar plato a un menú específico
def agregar_plato(request, menu_id):
    menu_padre = get_object_or_404(Menu, id=menu_id)
    
    if request.method == 'POST':
        form = PlatoForm(request.POST)
        if form.is_valid():
            plato = form.save(commit=False)
            plato.menu = menu_padre
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
    menu_id = plato.menu.id 
    
    if request.method == 'POST':
        plato.delete()
        return redirect('detalle_menu', id=menu_id)
    
    return render(request, 'restaurante/confirmar_borrado.html', {'item': plato.nombre})

# 7. Editar un Menú
def editar_menu(request, id):
    menu = get_object_or_404(Menu, id=id)
    
    if request.method == 'POST':
        form = MenuForm(request.POST, instance=menu)
        if form.is_valid():
            form.save()
            return redirect('lista_menus')
    else:
        form = MenuForm(instance=menu)

    return render(request, 'restaurante/form_generico.html', {
        'form': form, 
        'titulo': f'Editar Menú: {menu.nombre}'
    })

# 8. Editar un Plato
def editar_plato(request, id):
    plato = get_object_or_404(Plato, id=id)
    menu_id = plato.menu.id 
    
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


# ==========================================
# GESTIÓN DE PEDIDOS (LO NUEVO QUE FALTABA)
# ==========================================

@login_required
def lista_pedidos(request):
    # Listar pedidos del más reciente al más antiguo
    pedidos = Pedido.objects.all().order_by('-fecha')
    return render(request, 'restaurante/lista_pedidos.html', {'pedidos': pedidos})

@login_required
def finalizar_pedido(request, pedido_id):
    pedido = get_object_or_404(Pedido, id=pedido_id)
    
    if request.method == 'POST':
        pedido.estado = Pedido.FINALIZADO
        pedido.save()
        return redirect('lista_pedidos')
    
    # Si intentan entrar por GET, los devolvemos a la lista
    return redirect('lista_pedidos')

@login_required
def cancelar_pedido(request, pedido_id):
    pedido = get_object_or_404(Pedido, id=pedido_id)
    
    if request.method == 'POST':
        form = CancelarPedidoForm(request.POST, instance=pedido)
        if form.is_valid():
            # Al guardar el form, se actualiza el motivo_cancelacion en el objeto
            pedido.estado = Pedido.CANCELADO
            pedido.save() 
            return redirect('lista_pedidos')
    else:
        form = CancelarPedidoForm(instance=pedido)

    return render(request, 'restaurante/cancelar_pedido.html', {'form': form, 'pedido': pedido})

@login_required
def tomar_pedido(request, pedido_id):
    pedido = get_object_or_404(Pedido, id=pedido_id)
    
    # Solo permitimos tomarlo si está Pendiente y no tiene dueño
    if pedido.estado == Pedido.PENDIENTE and not pedido.repartidor:
        pedido.repartidor = request.user # Asignamos al usuario actual (Repartidor)
        pedido.estado = Pedido.EN_CAMINO # Cambiamos estado
        pedido.save()
    
    return redirect('lista_pedidos')

@login_required
def home(request):
    if request.user.is_superuser:
        # CORREGIDO: Usamos 'fecha'
        pedidos = Pedido.objects.all().order_by('-fecha')
        titulo = "Panel de Administrador"
    else:
        # CORREGIDO: Usamos 'fecha'
        pedidos = Pedido.objects.filter(repartidor=request.user, estado='FINALIZADO').order_by('-fecha')
        titulo = f"Entregas de {request.user.username}"

    context = {
        'pedidos': pedidos,
        'titulo': titulo
    }
    return render(request, 'restaurante/home.html', context)

# ==========================================
# API VIEWSETS
# ==========================================

class MenuViewSet(viewsets.ModelViewSet):
    queryset = Menu.objects.all()
    serializer_class = MenuSerializer

class PlatoViewSet(viewsets.ModelViewSet):
    queryset = Plato.objects.all()
    serializer_class = PlatoSerializer

class PedidoViewSet(viewsets.ModelViewSet):
    queryset = Pedido.objects.all()
    serializer_class = PedidoSerializer