from django.contrib import admin
from .models import Tenant, TenantUser

@admin.register(Tenant)
class TenantAdmin(admin.ModelAdmin):
    list_display = ('name', 'domain', 'created_at')
    search_fields = ('name', 'domain')
    ordering = ('-created_at',)

@admin.register(TenantUser)
class TenantUserAdmin(admin.ModelAdmin):
    list_display = ('user', 'tenant', 'role', 'is_active')
    list_filter = ('role', 'is_active')
    search_fields = ('user__username', 'tenant__name')
