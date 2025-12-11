from django import forms
from .models import Menu, Plato

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