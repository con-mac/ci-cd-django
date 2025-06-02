from django.utils.deprecation import MiddlewareMixin
from .models import TenantUser

class TenantMiddleware(MiddlewareMixin):
    def process_request(self, request):
        user = request.user
        if user.is_authenticated:
            try:
                # For now, assume one user → one tenant
                tenant_user = TenantUser.objects.filter(user=user).first()
                if tenant_user:
                    request.tenant = tenant_user.tenant
                else:
                    request.tenant = None
            except TenantUser.DoesNotExist:
                request.tenant = None
        else:
            request.tenant = None
