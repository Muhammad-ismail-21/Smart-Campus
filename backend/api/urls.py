from django.urls import path
from . import views

urlpatterns = [
    path('login/', views.login_view, name='api-login'),
    path('timetable/', views.my_timetable, name='api-timetable'),
    path('announcements/', views.get_announcements, name='api-announcements'),
    # New endpoints
    path('announcements/create/', views.create_announcement, name='api-announcement-create'),
    path('attendances/', views.attendance_list, name='api-attendance-list'),
    path('attendances/mark/', views.attendance_mark, name='api-attendance-mark'),
    path('exams/', views.get_exams, name='api-exams'),
    path('floormaps/', views.get_floor_maps, name='api-floormaps'),
    path('profile/', views.get_profile, name='api-profile'),
    path('faculty/today-classes/', views.faculty_today_classes, name='api-faculty-today'),
]
