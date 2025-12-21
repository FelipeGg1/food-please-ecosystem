from django.shortcuts import render
from django.contrib.auth.decorators import login_required
# IMPORTANTE: Importamos el modelo desde la otra app 'restaurante'
from restaurante.models import Pedido 

@login_required
def home(request):
    if request.user.is_superuser:
        pedidos = Pedido.objects.all().order_by('-fecha_creacion')
        titulo = "Panel de Administrador"
    else:
        pedidos = Pedido.objects.filter(repartidor=request.user, estado='FINALIZADO')
        titulo = f"Entregas de {request.user.username}"

    return render(request, 'core/home.html', {'pedidos': pedidos, 'titulo': titulo})