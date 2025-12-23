from rest_framework.authtoken.views import ObtainAuthToken
from rest_framework.authtoken.models import Token
from rest_framework.response import Response
from django.contrib.auth.views import LoginView
from django.contrib import messages
from django.shortcuts import redirect

class CustomAuthToken(ObtainAuthToken):
    def post(self, request, *args, **kwargs):
        serializer = self.serializer_class(data=request.data,
                                           context={'request': request})
        serializer.is_valid(raise_exception=True)
        user = serializer.validated_data['user']
        token, created = Token.objects.get_or_create(user=user)
        

        es_repartidor = False
        if hasattr(user, 'rol') and user.rol:
            es_repartidor = (user.rol.upper() == 'REPARTIDOR')
        
        return Response({
            'token': token.key,
            'user_id': user.pk,
            'email': user.email,
            'is_repartidor': es_repartidor 
        })
class WebLoginView(LoginView):
    template_name = 'usuarios/login.html' # Definimos el template aquí

    def form_valid(self, form):
        """
        Este método se ejecuta cuando usuario y contraseña son correctos.
        Aquí validamos si es ADMIN antes de dejarlo pasar.
        """
        user = form.get_user()
        
        # Validación de seguridad: ¿Es ADMIN?
        # Usamos .upper() para evitar problemas con 'admin', 'Admin', 'ADMIN'
        if hasattr(user, 'rol') and user.rol and user.rol.upper() == 'ADMIN':
            # Si es Admin, dejamos que Django haga el login normal
            return super().form_valid(form)
        else:
            # Si NO es Admin (es Repartidor o Cliente), lo echamos
            messages.error(self.request, "Acceso denegado: Plataforma exclusiva para Administradores.")
            return redirect('login')