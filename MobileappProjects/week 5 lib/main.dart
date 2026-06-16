import 'package:flutter/material.dart';
import 'student_list_screen.dart';

void main() {
  runApp(const StudentApiApp());
}

class StudentApiApp extends StatelessWidget {
  const StudentApiApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Student API System',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const StudentListScreen(),
    );
  }
}