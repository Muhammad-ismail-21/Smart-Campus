from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from rest_framework_simplejwt.tokens import RefreshToken
from django.contrib.auth import authenticate
from .models import TimeTableSlot, Announcement, Attendance, User
from .serializers import UserSerializer, TimeTableSerializer, AnnouncementSerializer, AttendanceSerializer

# 1. LOGIN API (The Gatekeeper)
@api_view(['POST'])
def login_view(request):
	username = request.data.get('username')
	password = request.data.get('password')

	user = authenticate(username=username, password=password)
    
	if user is not None:
		# Generate Tokens for Flutter
		refresh = RefreshToken.for_user(user)
		serializer = UserSerializer(user)
		return Response({
			'refresh': str(refresh),
			'access': str(refresh.access_token),
			'user': serializer.data
		})
	else:
		return Response({'error': 'Invalid Credentials'}, status=400)

# 2. GET MY TIMETABLE
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def my_timetable(request):
	user = request.user
    
	if user.role == 'student':
		# Logic: Get slots for the Student's Class Group
		if not user.class_group:
			return Response({'error': 'You are not assigned to any class group'}, status=404)
        
		slots = TimeTableSlot.objects.filter(class_group=user.class_group).order_by('day', 'start_time')
    
	elif user.role == 'faculty':
		# Logic: Get slots where this Faculty is teaching
		slots = TimeTableSlot.objects.filter(faculty=user).order_by('day', 'start_time')
        
	else:
		return Response([])

	serializer = TimeTableSerializer(slots, many=True)
	return Response(serializer.data)

# 3. GET ANNOUNCEMENTS (Targeted!)
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_announcements(request):
	user = request.user
    
	# Filter Logic: 
	# Show announcements that are for 'all' OR specifically for this user's role/dept/class
	from django.db.models import Q
    
	if user.role == 'student':
		query = Q(target_role='all') | Q(target_role='student') | \
				Q(target_class_group=user.class_group) | Q(target_department=user.department)
	else:
		# Faculty logic
		query = Q(target_role='all') | Q(target_role='faculty') | Q(target_department=user.department)

	announcements = Announcement.objects.filter(query).order_by('-date_posted')
	serializer = AnnouncementSerializer(announcements, many=True)
	return Response(serializer.data)
from django.shortcuts import render

# Create your views here.
from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from django.utils import timezone
from django.db.models import Q

# ANNOUNCEMENT CREATE (faculty/admin)
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def create_announcement(request):
    user = request.user
    if user.role not in ('faculty', 'admin'):
        return Response({'detail': 'Forbidden'}, status=status.HTTP_403_FORBIDDEN)

    serializer = AnnouncementSerializer(data=request.data)
    if serializer.is_valid():
        serializer.save(posted_by=user)
        return Response(serializer.data, status=status.HTTP_201_CREATED)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

# ATTENDANCE: list (student sees own; faculty can filter)
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def attendance_list(request):
    user = request.user
    if user.role == 'student':
        records = Attendance.objects.filter(student=user).order_by('-date')
    elif user.role == 'faculty':
        # optional query param ?student_id= or ?class_group_id=
        student_id = request.query_params.get('student_id')
        class_group_id = request.query_params.get('class_group_id')
        if student_id:
            records = Attendance.objects.filter(student__id=student_id).order_by('-date')
        elif class_group_id:
            records = Attendance.objects.filter(slot__class_group__id=class_group_id).order_by('-date')
        else:
            # faculty sees records for slots they teach
            records = Attendance.objects.filter(slot__faculty=user).order_by('-date')
    else:
        records = Attendance.objects.none()

    serializer = AttendanceSerializer(records, many=True)
    return Response(serializer.data)

# ATTENDANCE: mark (faculty marks attendance)
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def attendance_mark(request):
    user = request.user
    if user.role != 'faculty':
        return Response({'detail': 'Forbidden'}, status=status.HTTP_403_FORBIDDEN)

    student_id = request.data.get('student_id')
    slot_id = request.data.get('slot_id')
    date = request.data.get('date')  # "YYYY-MM-DD"
    is_present = request.data.get('is_present', True)
    method = request.data.get('method', 'manual')

    if not all([student_id, slot_id, date]):
        return Response({'detail': 'student_id, slot_id and date are required'}, status=status.HTTP_400_BAD_REQUEST)

    try:
        att, created = Attendance.objects.update_or_create(
            student_id=student_id,
            slot_id=slot_id,
            date=date,
            defaults={'is_present': is_present, 'method': method, 'marked_by': user}
        )
        serializer = AttendanceSerializer(att)
        return Response(serializer.data, status=status.HTTP_201_CREATED if created else status.HTTP_200_OK)
    except Exception as e:
        return Response({'detail': str(e)}, status=status.HTTP_400_BAD_REQUEST)

# EXAMS list (students get their class_group exams; faculty get exams for their subjects/classes)
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_exams(request):
    user = request.user
    if user.role == 'student':
        exams = Exam.objects.filter(class_group=user.class_group).order_by('date', 'start_time')
    elif user.role == 'faculty':
        exams = Exam.objects.filter(subject__faculty_coordinator=user).order_by('date', 'start_time')
    else:
        exams = Exam.objects.none()

    serializer = ExamSerializer(exams, many=True)
    return Response(serializer.data)

# FLOOR MAPS list (public to authenticated users)
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_floor_maps(request):
    maps = FloorMap.objects.all().order_by('building_name', 'floor_number')
    serializer = FloorMapSerializer(maps, many=True, context={'request': request})
    return Response(serializer.data)

# PROFILE
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_profile(request):
    serializer = UserSerializer(request.user)
    return Response(serializer.data)

# FACULTY: today classes
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def faculty_today_classes(request):
    user = request.user
    if user.role != 'faculty':
        return Response({'detail': 'Forbidden'}, status=status.HTTP_403_FORBIDDEN)

    today = timezone.localtime().weekday()  # 0=Monday? (note: Python weekday is 0=Mon)
    # We stored day choices as 'MON','TUE' etc. Map weekday to those strings:
    weekday_map = {0: 'MON', 1: 'TUE', 2: 'WED', 3: 'THU', 4: 'FRI', 5: 'SAT', 6:'MON'}
    day_str = weekday_map.get(today, 'MON')
    slots = TimeTableSlot.objects.filter(faculty=user, day=day_str).order_by('start_time')
    serializer = TimeTableSerializer(slots, many=True)
    return Response(serializer.data)
