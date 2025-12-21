from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from .models import Usuario

class CustomUsuarioAdmin(UserAdmin):
    model = Usuario
    
    # Columnas que ves en la lista principal de usuarios
    list_display = ('email', 'username', 'rol', 'is_staff')
    
    def get_fieldsets(self, request, obj=None):
        # Obtenemos los campos básicos de Django (User, Pass, etc.)
        fieldsets = super().get_fieldsets(request, obj)
        
        if obj: # MODO EDICIÓN (Cuando ya existe el usuario)
            # Aquí mostramos el Rol y Teléfono para poder verlos/editarlos
            return fieldsets + (
                ('Información Extra', {'fields': ('rol', 'telefono')}),
            )
        
        # MODO CREACIÓN (Cuando estás añadiendo uno nuevo)
        # ⚠️ He quitado 'direccion' de aquí como pediste
        return fieldsets + (
            ('Datos Iniciales', {'fields': ('email', 'rol', 'telefono')}),
        )

# Registramos el modelo
admin.site.register(Usuario, CustomUsuarioAdmin)