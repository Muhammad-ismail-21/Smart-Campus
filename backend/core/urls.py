# core/urls.py
"""
URL configuration for core project.

The `urlpatterns` list routes URLs to views.
"""
from django.contrib import admin
from django.urls import path, include  # include added
# If you want to keep direct imports you used before you can still import views,
# but we recommend including api.urls from the api app.
# from api import views

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/', include('api.urls')),   # include the api app's urls
]
