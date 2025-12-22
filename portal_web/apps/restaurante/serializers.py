from rest_framework import serializers
from .models import Menu, Plato, Pedido
from collections import Counter 

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
    
    platos = serializers.PrimaryKeyRelatedField(
        many=True, 
        queryset=Plato.objects.all()
    )
    cliente = serializers.ReadOnlyField(source='cliente.email')
    estado = serializers.ReadOnlyField() 
    
    # 2. NUEVO CAMPO CALCULADO: Solo para lectura, envía el detalle
    contenido = serializers.SerializerMethodField()

    class Meta:
        model = Pedido
        # 3. Agregamos 'contenido' a la lista de fields
        fields = ['id', 'platos', 'contenido', 'total', 'fecha', 'cliente', 'estado']

    # 4. Lógica para agrupar platos y contarlos
    def get_contenido(self, obj):
        # Obtenemos los nombres de los platos de este pedido
        nombres = [p.nombre for p in obj.platos.all()]
        # Counter crea un diccionario tipo: {'Hamburguesa': 2, 'Coca Cola': 1}
        conteo = Counter(nombres)
        # Lo transformamos a una lista limpia para Flutter
        return [{"nombre": k, "cantidad": v} for k, v in conteo.items()]