from django.db import models
from django.contrib.auth.models import User


class Tenant(models.Model):
    """
    Represents an organization or customer account.
    """
    name = models.CharField(max_length=255, unique=True)
    slug = models.SlugField(unique=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.name


class TenantUser(models.Model):
    """
    Maps users to tenants (supports multi-tenant user access).
    """
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    tenant = models.ForeignKey(Tenant, on_delete=models.CASCADE)
    is_admin = models.BooleanField(default=False)
    date_joined = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ("user", "tenant")

    def __str__(self):
        return f"{self.user.username} @ {self.tenant.name}"

