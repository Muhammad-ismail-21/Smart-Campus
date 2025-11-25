from django.db import models
from django.contrib.auth.models import AbstractUser
from django.utils.translation import gettext_lazy as _

# 1. DEPARTMENTS
class Department(models.Model):
	name = models.CharField(max_length=100, unique=True)

	def __str__(self):
		return self.name

# 2. CLASS GROUPS (Batches)
class ClassGroup(models.Model):
	name = models.CharField(max_length=50) # e.g., "5th Sem CSE A"
	semester = models.PositiveIntegerField()
	section = models.CharField(max_length=5) # e.g., "A"
	department = models.ForeignKey(Department, on_delete=models.CASCADE)

	class Meta:
		# Constraint: A section must be unique within a semester and department
		unique_together = ('department', 'semester', 'section')

	def __str__(self):
		return f"{self.name} ({self.department.name})"

# 3. CLASSROOMS (Physical Rooms)
class Classroom(models.Model):
	room_number = models.CharField(max_length=20)
	building_name = models.CharField(max_length=50, null=True, blank=True)
	floor_number = models.IntegerField(null=True, blank=True)
	type = models.CharField(max_length=20, default='Lecture Hall')

	class Meta:
		# Constraint: Room number unique within a building
		unique_together = ('building_name', 'room_number')

	def __str__(self):
		return f"{self.room_number} - {self.building_name}"

# 4. CUSTOM USER MODEL
class User(AbstractUser):
	class Role(models.TextChoices):
		STUDENT = 'student', 'Student'
		FACULTY = 'faculty', 'Faculty'
		ADMIN = 'admin', 'Admin'

	# We use 'username' as SRN / Employee ID
	role = models.CharField(max_length=20, choices=Role.choices)
	department = models.ForeignKey(Department, on_delete=models.SET_NULL, null=True, blank=True)
    
	# Only Students need this (Nullable for Faculty)
	class_group = models.ForeignKey(ClassGroup, on_delete=models.SET_NULL, null=True, blank=True)

	def __str__(self):
		return f"{self.username} ({self.role})"

# 5. SUBJECTS
class Subject(models.Model):
	name = models.CharField(max_length=100)
	code = models.CharField(max_length=20, unique=True)
	department = models.ForeignKey(Department, on_delete=models.CASCADE)
    
	# Coordinator (Faculty)
	faculty_coordinator = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, blank=True, related_name='coordinated_subjects')

	def __str__(self):
		return f"{self.name} ({self.code})"

# 6. TIMETABLE SLOTS
class TimeTableSlot(models.Model):
	DAYS = (
		('MON', 'Monday'),
		('TUE', 'Tuesday'),
		('WED', 'Wednesday'),
		('THU', 'Thursday'),
		('FRI', 'Friday'),
		('SAT', 'Saturday'),
	)

	day = models.CharField(max_length=3, choices=DAYS)
	start_time = models.TimeField()
	end_time = models.TimeField()
    
	class_group = models.ForeignKey(ClassGroup, on_delete=models.CASCADE)
	classroom = models.ForeignKey(Classroom, on_delete=models.SET_NULL, null=True)
	subject = models.ForeignKey(Subject, on_delete=models.PROTECT) # Don't delete subject if classes exist
	faculty = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, limit_choices_to={'role': 'faculty'})

	class Meta:
		constraints = [
			# 1. Class Group cannot be in two places
			models.UniqueConstraint(fields=['class_group', 'day', 'start_time'], name='unique_class_slot'),
			# 2. Room cannot host two classes
			models.UniqueConstraint(fields=['classroom', 'day', 'start_time'], name='unique_room_slot'),
			# 3. Faculty cannot teach two classes
			models.UniqueConstraint(fields=['faculty', 'day', 'start_time'], name='unique_faculty_slot'),
		]

	def __str__(self):
		return f"{self.day} {self.start_time} - {self.subject.code} ({self.class_group.name})"

# 7. ATTENDANCE
class Attendance(models.Model):
	date = models.DateField()
	is_present = models.BooleanField(default=False)
	method = models.CharField(max_length=20, default='manual') # manual/qr
    
	marked_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, related_name='attendance_marked')
	student = models.ForeignKey(User, on_delete=models.CASCADE, limit_choices_to={'role': 'student'})
	slot = models.ForeignKey(TimeTableSlot, on_delete=models.CASCADE)

	class Meta:
		# Prevent duplicate attendance for same student/slot/date
		unique_together = ('student', 'slot', 'date')

	def __str__(self):
		return f"{self.student.username} - {self.date} - {self.is_present}"

# 8. ANNOUNCEMENTS
class Announcement(models.Model):
	TARGET_ROLES = (('all', 'All'), ('student', 'Student'), ('faculty', 'Faculty'))

	title = models.CharField(max_length=200)
	content = models.TextField()
	date_posted = models.DateTimeField(auto_now_add=True)
	posted_by = models.ForeignKey(User, on_delete=models.CASCADE)

	# Targeting
	target_role = models.CharField(max_length=20, choices=TARGET_ROLES, default='all')
	target_department = models.ForeignKey(Department, on_delete=models.SET_NULL, null=True, blank=True)
	target_class_group = models.ForeignKey(ClassGroup, on_delete=models.SET_NULL, null=True, blank=True)
	target_subject = models.ForeignKey(Subject, on_delete=models.SET_NULL, null=True, blank=True)

	def __str__(self):
		return self.title

# 9. EXAMS (The New Table)
class Exam(models.Model):
	TYPES = (('theory', 'Theory'), ('lab', 'Lab'), ('viva', 'Viva'))

	name = models.CharField(max_length=100)
	description = models.TextField(blank=True)
	date = models.DateField()
	start_time = models.TimeField()
	end_time = models.TimeField()
	type = models.CharField(max_length=20, choices=TYPES, default='theory')

	subject = models.ForeignKey(Subject, on_delete=models.CASCADE)
	class_group = models.ForeignKey(ClassGroup, on_delete=models.CASCADE)
	classroom = models.ForeignKey(Classroom, on_delete=models.SET_NULL, null=True, blank=True)

	class Meta:
		# No two exams for same class at same time
		unique_together = ('class_group', 'date', 'start_time')

	def __str__(self):
		return f"{self.name} - {self.subject.name}"

# 10. FLOOR MAPS
class FloorMap(models.Model):
	title = models.CharField(max_length=100)
	image = models.ImageField(upload_to='floor_maps/')
	building_name = models.CharField(max_length=50)
	floor_number = models.IntegerField()

	def __str__(self):
		return self.title
