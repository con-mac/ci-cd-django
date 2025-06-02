# apps/tenants/helpers.py
def get_current_tenant(request):
    return getattr(request, 'tenant', None)
