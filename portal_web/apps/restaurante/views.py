from django.shortcuts import render, redirect, get_object_or_404
from .models import Menu, Plato, Pedido
# AGREGADO: Importamos el formulario de cancelación
from .forms import MenuForm, PlatoForm, CancelarPedidoForm 
from rest_framework import viewsets
from rest_framework.authentication import TokenAuthentication
from rest_framework.permissions import IsAuthenticated
from rest_framework.decorators import action
from rest_framework.response import Response
from .serializers import MenuSerializer, PlatoSerializer, PedidoSerializer
from django.contrib.auth.decorators import login_required
from django.db.models import Count, Sum
from django.db.models.functions import Coalesce

# ==========================================
# GESTIÓN DE MENÚS Y PLATOS
# ==========================================

# 1. Listar todos los menús (Inicio)
def lista_menus(request):
    menus = Menu.objects.annotate(
        total_platos=Count('platos'), 
        total_costo=Coalesce(Sum('platos__precio'), 0) 
    ).order_by('-activo', 'nombre')
    
    return render(request, 'restaurante/lista_menus.html', {
        'menus': menus
    })

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
# GESTIÓN DE PEDIDOS
# ==========================================

@login_required
def lista_pedidos(request):
    pedidos = Pedido.objects.annotate(
        cantidad_items=Count('platos'),
        total_vivo=Coalesce(Sum('platos__precio'), 0)
    ).order_by('-fecha')

    return render(request, 'restaurante/lista_pedidos.html', {
        'pedidos': pedidos
    })

# --- NUEVAS FUNCIONES PARA EL FLUJO (ADMINISTRADOR) ---

@login_required
def empezar_pedido(request, pedido_id):
    """Pasa de PENDIENTE a COCINANDO"""
    pedido = get_object_or_404(Pedido, id=pedido_id)
    if pedido.estado == Pedido.PENDIENTE:
        pedido.estado = Pedido.COCINANDO
        pedido.save()
    return redirect('lista_pedidos')

@login_required
def marcar_listo(request, pedido_id):
    """Pasa de COCINANDO a LISTO (Aquí aparece en la App del Repartidor)"""
    pedido = get_object_or_404(Pedido, id=pedido_id)
    if pedido.estado == Pedido.COCINANDO:
        pedido.estado = Pedido.LISTO
        pedido.save()
    return redirect('lista_pedidos')

# ----------------------------------------------------------

@login_required
def finalizar_pedido(request, pedido_id):
    # Esta función es para finalización manual desde el panel admin
    pedido = get_object_or_404(Pedido, id=pedido_id)
    
    if request.method == 'POST':
        # ACTUALIZADO: Usamos 'ENTREGADO' en lugar de FINALIZADO
        pedido.estado = Pedido.ENTREGADO
        pedido.save()
        return redirect('lista_pedidos')
    
    return redirect('lista_pedidos')

@login_required
def cancelar_pedido(request, pedido_id):
    pedido = get_object_or_404(Pedido, id=pedido_id)
    
    if request.method == 'POST':
        form = CancelarPedidoForm(request.POST, instance=pedido)
        if form.is_valid():
            pedido.estado = Pedido.CANCELADO
            pedido.save() 
            return redirect('lista_pedidos')
    else:
        form = CancelarPedidoForm(instance=pedido)

    return render(request, 'restaurante/cancelar_pedido.html', {'form': form, 'pedido': pedido})

@login_required
def tomar_pedido(request, pedido_id):
    # Lógica antigua de Admin, adaptada por si se usa manualmente
    pedido = get_object_or_404(Pedido, id=pedido_id)
    
    if not pedido.repartidor:
        pedido.repartidor = request.user 
        pedido.estado = Pedido.EN_CAMINO
        pedido.save()
    
    return redirect('lista_pedidos')

@login_required
def home(request):
    if request.user.is_superuser:
        pedidos = Pedido.objects.all().order_by('-fecha')
        titulo = "Panel de Administrador"
    else:
        # ACTUALIZADO: Filtramos por ENTREGADO
        pedidos = Pedido.objects.filter(repartidor=request.user, estado='ENTREGADO').order_by('-fecha')
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
    
    authentication_classes = [TokenAuthentication]
    permission_classes = [IsAuthenticated]

    def perform_create(self, serializer):
        serializer.save(cliente=self.request.user)

    def get_queryset(self):
        user = self.request.user
        if user.is_staff or getattr(user, 'rol', None) == 'REPARTIDOR':
            return Pedido.objects.all()
            
        return Pedido.objects.filter(cliente=user)

    @action(detail=False, methods=['get'])
    def disponibles(self, request):
        # ACTUALIZADO: El repartidor busca pedidos en estado LISTO
        pedidos = Pedido.objects.filter(estado='LISTO', repartidor__isnull=True)
        
        serializer = self.get_serializer(pedidos, many=True)
        return Response(serializer.data)

    @action(detail=True, methods=['post'])
    def tomar(self, request, pk=None):
        pedido = self.get_object()
        
        # ACTUALIZADO: Solo se toma si está LISTO
        if pedido.repartidor is None and pedido.estado == 'LISTO':
            pedido.repartidor = request.user
            pedido.estado = 'EN_CAMINO'
            pedido.save()
            return Response({'status': 'Pedido asignado correctamente'})
        else:
            return Response(
                {'error': 'El pedido no está listo para entrega'}, 
                status=400
            )

    @action(detail=False, methods=['get'])
    def mis_entregas(self, request):
        pedidos = Pedido.objects.filter(repartidor=request.user, estado='EN_CAMINO')
        serializer = self.get_serializer(pedidos, many=True)
        return Response(serializer.data)

    @action(detail=True, methods=['post'])
    def finalizar_entrega(self, request, pk=None):
        pedido = self.get_object()
        
        if pedido.repartidor == request.user and pedido.estado == 'EN_CAMINO':
            # ACTUALIZADO: Usamos 'ENTREGADO'
            pedido.estado = 'ENTREGADO' 
            pedido.save()
            return Response({'status': 'Pedido entregado correctamente'})
        else:
            return Response({'error': 'No puedes finalizar este pedido'}, status=400)