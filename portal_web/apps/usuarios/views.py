from rest_framework.authtoken.views import ObtainAuthToken
from rest_framework.authtoken.models import Token
from rest_framework.response import Response

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