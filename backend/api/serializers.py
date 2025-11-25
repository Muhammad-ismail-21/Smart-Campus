from rest_framework import serializers
from .models import (
    User, Department, ClassGroup, TimeTableSlot,
    Announcement, Attendance, Subject, Classroom, Exam, FloorMap
)



# 1. USER SERIALIZER (Login & Profile)
class UserSerializer(serializers.ModelSerializer):
    # We want to see the Dept Name, not just ID 5
    department_name = serializers.CharField(source='department.name', read_only=True)
    class_group_name = serializers.CharField(source='class_group.name', read_only=True)

    class Meta:
        model = User
        fields = ['id', 'username', 'first_name', 'last_name', 'role', 'department_name', 'class_group_name']

# 2. TIMETABLE SERIALIZER (The Schedule)
class TimeTableSerializer(serializers.ModelSerializer):
    subject_name = serializers.CharField(source='subject.name')
    subject_code = serializers.CharField(source='subject.code')
    room_number = serializers.CharField(source='classroom.room_number', allow_null=True)
    faculty_name = serializers.CharField(source='faculty.first_name', allow_null=True)

    class Meta:
        model = TimeTableSlot
        fields = ['id', 'day', 'start_time', 'end_time', 'subject_name', 'subject_code', 'room_number', 'faculty_name']

# 3. ANNOUNCEMENT SERIALIZER
class AnnouncementSerializer(serializers.ModelSerializer):
    posted_by_name = serializers.CharField(source='posted_by.first_name')

    class Meta:
        model = Announcement
        fields = ['id', 'title', 'content', 'date_posted', 'posted_by_name']

# 4. ATTENDANCE SERIALIZER
class AttendanceSerializer(serializers.ModelSerializer):
    subject_name = serializers.CharField(source='slot.subject.name')
    date = serializers.DateField(format="%d-%m-%Y") # Format: 23-11-2025

    class Meta:
        model = Attendance
        fields = ['date', 'subject_name', 'is_present', 'method']

# 5. EXAM SERIALIZER
class ExamSerializer(serializers.ModelSerializer):
    subject_name = serializers.CharField(source='subject.name', read_only=True)
    class_group_name = serializers.CharField(source='class_group.name', read_only=True)
    room_number = serializers.CharField(source='classroom.room_number', allow_null=True, read_only=True)

    class Meta:
        model = Exam
        fields = ['id', 'name', 'description', 'date', 'start_time', 'end_time', 'type', 'subject_name', 'class_group_name', 'room_number']

# 6. FLOORMAP SERIALIZER
class FloorMapSerializer(serializers.ModelSerializer):
    class Meta:
        model = FloorMap
        fields = ['id', 'title', 'image', 'building_name', 'floor_number']
