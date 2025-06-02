from django.contrib import admin
from .models import Tenant, TenantUser

@admin.register(Tenant)
class TenantAdmin(admin.ModelAdmin):
    list_display = ('name', 'slug', 'created_at')  # replaced domain with slug
    search_fields = ('name', 'slug')
    ordering = ('-created_at',)

@admin.register(TenantUser)
class TenantUserAdmin(admin.ModelAdmin):
    list_display = ('user', 'tenant', 'role', 'date_joined')  # removed is_active
    list_filter = ('role', 'tenant')  # removed is_active
    search_fields = ('user__username', 'tenant__name')
