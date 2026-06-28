class Student {
  int? id;
  String regNo;
  String name;
  String course;
  String year;
  String phone;
  String email;

  Student({
    this.id,
    required this.regNo,
    required this.name,
    required this.course,
    required this.year,
    required this.phone,
    required this.email,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'regNo': regNo,
      'name': name,
      'course': course,
      'year': year,
      'phone': phone,
      'email': email,
    };
  }
}