from django import forms
from .models import Menu, Plato, Pedido

class MenuForm(forms.ModelForm):
    class Meta:
        model = Menu
        fields = ['nombre', 'activo']

class PlatoForm(forms.ModelForm):
    class Meta:
        model = Plato
        # NOTA: No pedimos el 'menu' aquí porque se asignará automáticamente
        # según el menú que el usuario esté viendo en ese momento.
        fields = ['nombre', 'descripcion', 'precio']

class CancelarPedidoForm(forms.ModelForm):
    class Meta:
        model = Pedido
        fields = ['motivo_cancelacion']
        widgets = {
            'motivo_cancelacion': forms.Select(attrs={'class': 'form-control'}),
        }
        labels = {
            'motivo_cancelacion': 'Seleccione la razón del rechazo',
        }