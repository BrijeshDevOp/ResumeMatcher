from django.urls import path
from .views import match_resume

urlpatterns = [
    path('match/', match_resume, name='match_resume'),  # ✅ Ensure this exists!
]
