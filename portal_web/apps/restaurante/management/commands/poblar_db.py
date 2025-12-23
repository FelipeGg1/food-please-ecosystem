from django.core.management.base import BaseCommand
from django.apps import apps
from django.contrib.auth import get_user_model

class Command(BaseCommand):
    help = 'Puebla la base de datos con Admin y datos de prueba (Ajustado a tus modelos)'

    def handle(self, *args, **kwargs):
        self.stdout.write("Iniciando sembrado de datos...")

        # --- 0. Obtener modelos dinámicamente ---
        try:
            Menu = apps.get_model('restaurante', 'Menu')
            Plato = apps.get_model('restaurante', 'Plato')
        except LookupError:
            self.stdout.write(self.style.ERROR("Error: No encuentro la app 'restaurante'. Verifica el nombre."))
            return

        # --- 1. Crear Superusuario (Admin) ---
        User = get_user_model()
        User = get_user_model()

        # 1. ADMIN (Superusuario)
        if not User.objects.filter(username='admin').exists():
            User.objects.create_superuser('admin', 'admin@foodplease.com', 'admin123', rol='ADMIN')
            self.stdout.write(self.style.SUCCESS("Usuario 'admin' (rol=ADMIN) creado."))

        # 2. CLIENTE (Usuario normal)
        if not User.objects.filter(username='cliente').exists():
            User.objects.create_user('cliente', 'cliente@foodplease.com', 'cliente123', rol='CLIENTE')
            self.stdout.write(self.style.SUCCESS("Usuario 'cliente' (rol=CLIENTE) creado."))

        # 3. REPARTIDOR (Usuario normal)
        if not User.objects.filter(username='repartidor').exists():
            User.objects.create_user('repartidor', 'repartidor@foodplease.com', 'repartidor123', rol='REPARTIDOR')
            self.stdout.write(self.style.SUCCESS("Usuario 'repartidor' (rol=REPARTIDOR) creado."))

        # --- 2. Crear Menú ---
        menu_nombre = "Menú Ejecutivo"
        menu, created = Menu.objects.get_or_create(
            nombre=menu_nombre,
            defaults={
                'activo': True
            }
        )
        
        if created:
            self.stdout.write(self.style.SUCCESS(f"Menú '{menu_nombre}' creado."))
        else:
            self.stdout.write(f"El menú '{menu_nombre}' ya existe.")

        # --- 3. Crear Platos ---
        platos_data = [
            {'nombre': 'Lomo Saltado', 'precio': 8500, 'desc': 'Clásico peruano con carne y papas.'},
            {'nombre': 'Ensalada César', 'precio': 6500, 'desc': 'Lechuga fresca, crutones y aderezo.'},
            {'nombre': 'Jugo Natural', 'precio': 2500, 'desc': 'Fruta de la estación.'}
        ]

        for data in platos_data:
            Plato.objects.get_or_create(
                nombre=data['nombre'],
                menu=menu,
                defaults={
                    'descripcion': data['desc'],
                    'precio': data['precio'],
                    'available': True  
                }
            )
        
        self.stdout.write(self.style.SUCCESS(f"Platos verificados/creados."))
        self.stdout.write(self.style.SUCCESS("¡Todo listo! Base de datos poblada."))