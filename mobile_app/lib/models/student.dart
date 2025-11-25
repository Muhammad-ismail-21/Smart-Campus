class Student {
  final String srn;
  final String name;

  Student({required this.srn, required this.name});

  factory Student.fromJson(Map<String, dynamic> json) => Student(
    srn: json['srn'] ?? '',
    name: json['name'] ?? '',
  );
}
