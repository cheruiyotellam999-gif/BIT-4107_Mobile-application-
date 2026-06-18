import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'student.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Student Record App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const StudentListScreen(),
    );
  }
}

// STUDENT LIST or the HOME SCREEN
class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  List<Map<String, dynamic>> students = [];
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadStudents();
  }

  Future<void> loadStudents() async {
    students = await DatabaseHelper.instance.getStudents();
    setState(() {});
  }

  Future<void> searchStudents(String keyword) async {
    students = await DatabaseHelper.instance.searchStudent(keyword);
    setState(() {});
  }

  void showStudentForm({Map<String, dynamic>? student}) {
    final regNoController = TextEditingController(text: student?['regNo'] ?? '');
    final nameController = TextEditingController(text: student?['name'] ?? '');
    final courseController = TextEditingController(text: student?['course'] ?? '');
    final yearController = TextEditingController(text: student?['year'] ?? '');
    final phoneController = TextEditingController(text: student?['phone'] ?? '');
    final emailController = TextEditingController(text: student?['email'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(student == null ? 'Add Student' : 'Update Student'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: regNoController,
                decoration: const InputDecoration(labelText: 'Registration No'),
              ),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: courseController,
                decoration: const InputDecoration(labelText: 'Course'),
              ),
              TextField(
                controller: yearController,
                decoration: const InputDecoration(labelText: 'Year'),
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              if (student == null) {
                await DatabaseHelper.instance.insertStudent(
                  Student(
                    regNo: regNoController.text,
                    name: nameController.text,
                    course: courseController.text,
                    year: yearController.text,
                    phone: phoneController.text,
                    email: emailController.text,
                  ),
                );
              } else {
                await DatabaseHelper.instance.updateStudent(
                  Student(
                    id: student['id'],
                    regNo: regNoController.text,
                    name: nameController.text,
                    course: courseController.text,
                    year: yearController.text,
                    phone: phoneController.text,
                    email: emailController.text,
                  ),
                );
              }
              if (!mounted || !context.mounted) return;
              Navigator.pop(context);
              loadStudents();
            },
            child: const Text("Save"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Management"),
        actions: [
          IconButton(
            icon: const Icon(Icons.fact_check),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AttendanceScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search Student',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    searchStudents(searchController.text);
                  },
                ),
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: students.isEmpty
                ? const Center(child: Text("No students added yet."))
                : ListView.builder(
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = students[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    title: Text("${student['name']} (${student['regNo']})"),
                    subtitle: Text(
                      "Course: ${student['course']} | Year: ${student['year']}\nEmail: ${student['email']}\nPhone: ${student['phone']}",
                    ),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => showStudentForm(student: student),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            await DatabaseHelper.instance.deleteStudent(student['id']);
                            loadStudents();
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showStudentForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}


//ATTENDANCE SCREEN
class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final nameController = TextEditingController();
  String status = "Present";
  List<Map<String, dynamic>> history = [];

  @override
  void initState() {
    super.initState();
    loadAttendance();
  }

  Future<void> loadAttendance() async {
    history = await DatabaseHelper.instance.getAttendance();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Attendance Records")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Student Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: status,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: "Present", child: Text("Present")),
                DropdownMenuItem(value: "Absent", child: Text("Absent")),
              ],
              onChanged: (value) {
                setState(() {
                  status = value!;
                });
              },
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(45)),
              onPressed: () async {
                if (nameController.text.trim().isEmpty) return;

                await DatabaseHelper.instance.insertAttendance(
                  nameController.text,
                  DateTime.now().toString().substring(0, 10),
                  status,
                );

                nameController.clear();
                loadAttendance();
                if (!mounted || !context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Attendance Saved Successfully!')),
                );
              },
              child: const Text('Save Attendance'),
            ),
            const Divider(height: 30, thickness: 2),
            const Text(
              "Attendance Log History",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: history.isEmpty
                  ? const Center(child: Text("No records captured today."))
                  : ListView.builder(
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final entry = history[index];
                  final isPresent = entry['status'] == "Present";
                  return Card(
                    child: ListTile(
                      leading: Icon(
                        isPresent ? Icons.check_circle : Icons.cancel,
                        color: isPresent ? Colors.green : Colors.red,
                      ),
                      title: Text(entry['studentName']),
                      subtitle: Text("Date: ${entry['attendanceDate']}"),
                      trailing: Text(
                        entry['status'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isPresent ? Colors.green : Colors.red,
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}