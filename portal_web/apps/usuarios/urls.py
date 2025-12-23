from django.urls import path
from django.contrib.auth import views as auth_views
from .views import CustomAuthToken
from .views import CustomAuthToken, WebLoginView
urlpatterns = [
    # Usamos WebLoginView en lugar de auth_views.LoginView
    path('login/', WebLoginView.as_view(), name='login'),
    
    # Vista para cerrar sesión (logout)
    path('logout/', auth_views.LogoutView.as_view(), name='logout'),

    # Login para la APP MÓVIL (Devuelve Token + Rol)
    path('api-token-auth/', CustomAuthToken.as_view(), name='api_token_auth'),
]