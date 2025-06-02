#from django.db.models.signals import post_save
#from django.dispatch import receiver
#from django.contrib.auth.models import User
#from .models import TenantUser

#@receiver(post_save, sender=User)
#def create_tenant_user(sender, instance, created, **kwargs):
    #if created:
        # You can customize this logic based on the default tenant or assign based on request in views
        #tenant_user = TenantUser.objects.create(user=instance)
        #tenant_user.save()
