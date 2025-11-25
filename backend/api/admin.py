from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from .models import (
	User, Department, ClassGroup, Classroom, Subject, 
	TimeTableSlot, Attendance, Announcement, Exam, FloorMap
)

# 1. Custom User Admin (To handle our custom fields like 'role')
class CustomUserAdmin(UserAdmin):
	model = User
	fieldsets = UserAdmin.fieldsets + (
		('College Info', {'fields': ('role', 'department', 'class_group')}),
	)
	# Ensure these fields also appear on the default "add user" form
	add_fieldsets = UserAdmin.add_fieldsets + (
		('College Info', {'fields': ('role', 'department', 'class_group')}),
	)
	list_display = ['username', 'role', 'department', 'class_group']
	list_filter = ['role', 'department']

# 2. Registering models with specific display columns
@admin.register(Department)
class DepartmentAdmin(admin.ModelAdmin):
	list_display = ['id', 'name']

@admin.register(ClassGroup)
class ClassGroupAdmin(admin.ModelAdmin):
	list_display = ['name', 'department', 'semester', 'section']
	list_filter = ['department', 'semester']

@admin.register(Classroom)
class ClassroomAdmin(admin.ModelAdmin):
	list_display = ['room_number', 'building_name', 'type']

@admin.register(Subject)
class SubjectAdmin(admin.ModelAdmin):
	list_display = ['name', 'code', 'department', 'faculty_coordinator']

@admin.register(TimeTableSlot)
class TimeTableSlotAdmin(admin.ModelAdmin):
	list_display = ['day', 'start_time', 'subject', 'class_group', 'classroom', 'faculty']
	list_filter = ['day', 'class_group']

@admin.register(Attendance)
class AttendanceAdmin(admin.ModelAdmin):
	list_display = ['date', 'student', 'slot', 'is_present', 'method']
	# FIXED: We traverse from 'slot' to 'class_group'
	list_filter = ['date', 'is_present', 'slot__class_group']

	# Helper to show class group in the list
	def class_group__name(self, obj):
		return obj.slot.class_group.name

@admin.register(Exam)
class ExamAdmin(admin.ModelAdmin):
	list_display = ['name', 'subject', 'date', 'start_time', 'class_group']

# Register the rest simply
admin.site.register(User, CustomUserAdmin)
admin.site.register(Announcement)
admin.site.register(FloorMap)
