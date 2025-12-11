from rest_framework import serializers
from .models import Menu, Plato
from .models import Menu, Plato, Pedido # Importa Pedido

class PlatoSerializer(serializers.ModelSerializer):
    class Meta:
        model = Plato
        fields = '__all__'

class MenuSerializer(serializers.ModelSerializer):
    platos = PlatoSerializer(many=True, read_only=True)

    class Meta:
        model = Menu
        fields = ['id', 'nombre', 'activo', 'platos']

class PedidoSerializer(serializers.ModelSerializer):
    # Para crear un pedido, Flutter enviará una lista de IDs de platos: [1, 5, 8]
    # PrimaryKeyRelatedField maneja esto automáticamente.
    platos = serializers.PrimaryKeyRelatedField(
        many=True, 
        queryset=Plato.objects.all()
    )

    class Meta:
        model = Pedido
        fields = ['id', 'platos', 'total', 'fecha', 'cliente']