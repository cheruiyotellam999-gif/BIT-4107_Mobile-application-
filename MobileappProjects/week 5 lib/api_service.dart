import 'dart:convert';
import 'package:http/http.dart' as http;
import 'student_model.dart';

class ApiService {
  // Public REST API Endpoint
  static const String url = 'https://jsonplaceholder.typicode.com/users';

  Future<List<StudentModel>> fetchStudents() async {
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Decode raw JSON string into a list
        List<dynamic> body = jsonDecode(response.body);

        // Map list elements into our StudentModel structure
        List<StudentModel> students = body
            .map((dynamic item) => StudentModel.fromJson(item))
            .toList();

        return students;
      } else {
        throw Exception('Failed to load records. Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error occurred: $e');
    }
  }
}