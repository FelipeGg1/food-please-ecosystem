from django.urls import path
from django.contrib.auth import views as auth_views
from .views import CustomAuthToken

urlpatterns = [
    # Usamos la vista 'LoginView' que ya trae Django, pero le decimos qué HTML usar
    path('login/', auth_views.LoginView.as_view(template_name='usuarios/login.html'), name='login'),
    
    # Vista para cerrar sesión (logout)
    path('logout/', auth_views.LogoutView.as_view(), name='logout'),

    # Login para la APP MÓVIL (Devuelve Token + Rol)
    path('api-token-auth/', CustomAuthToken.as_view(), name='api_token_auth'),
]