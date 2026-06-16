class StudentModel {
  final int id;
  final String name;
  final String email;
  final String company;

  StudentModel({
    required this.id,
    required this.name,
    required this.email,
    required this.company,
  });

  // Factory constructor to parse JSON data map into StudentModel instance
  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      company: json['company']['name'], // Extracting nested data
    );
  }
}