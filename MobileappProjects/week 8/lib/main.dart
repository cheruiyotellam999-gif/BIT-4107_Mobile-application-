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

// WEEK 8 INTEGRATION: CLASS-BASED OBJECTS FOR INPUT VALIDATION & EVENT LOGS
class FormValidator {
  static String? validateRequiredField(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return "$fieldName cannot be empty"; // Input Validation handling [cite: 14]
    }
    if (fieldName == "Name" && value.trim().length < 3) {
      return "Name must be at least 3 characters long"; // String validation constraints [cite: 15]
    }
    return null;
  }
}

class AppActionLogger {
  // Class-based event logging method to track app behavior dynamically [cite: 8, 10, 28]
  static void logInput(String actionType, String description) {
    debugPrint(" [WEEK 8 EVENT LOG] Action: $actionType | Details: $description");
  }

  static void onTapEvent(String layoutElement) {
    debugPrint(" [WEEK 8 GESTURE LOG] Tap event caught on element structure: '$layoutElement' [cite: 10, 17]");
  }
}

// SCREEN 1: STUDENT LIST (HOME SCREEN)
class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  List<Map<String, dynamic>> students = [];
  final TextEditingController searchController = TextEditingController();

  // WEEK 8 INTEGRATION: GlobalKey used for validating Form State [cite: 14]
  final _formKey = GlobalKey<FormState>();

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
          // WEEK 8 INTEGRATION: Wrapped inside a Form widget to monitor validation state [cite: 14, 15]
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: regNoController,
                  decoration: const InputDecoration(labelText: 'Registration No'),
                  validator: (v) => FormValidator.validateRequiredField(v, "Reg No"),
                ),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  // WEEK 8 INTEGRATION: Keyboard Input Event Handling [cite: 11, 13]
                  onChanged: (text) => AppActionLogger.logInput("Keyboard Input", "Typing name: $text"),
                  validator: (v) => FormValidator.validateRequiredField(v, "Name"),
                ),
                TextFormField(
                  controller: courseController,
                  decoration: const InputDecoration(labelText: 'Course'),
                  validator: (v) => FormValidator.validateRequiredField(v, "Course"),
                ),
                TextFormField(
                  controller: yearController,
                  decoration: const InputDecoration(labelText: 'Year'),
                  validator: (v) => FormValidator.validateRequiredField(v, "Year"),
                ),
                TextFormField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Phone'),
                  validator: (v) => FormValidator.validateRequiredField(v, "Phone"),
                ),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (v) => FormValidator.validateRequiredField(v, "Email"),
                ),
              ],
            ),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              // WEEK 8 INTEGRATION: Form input validation routing before database submission [cite: 14]
              if (_formKey.currentState!.validate()) {
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
                  AppActionLogger.logInput("Database Commit", "Inserted student record: ${nameController.text}");
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
                  AppActionLogger.logInput("Database Commit", "Updated student profile ID: ${student['id']}");
                }
                if (!context.mounted) return;
                Navigator.pop(context);
                loadStudents();
              } else {
                // WEEK 8 INTEGRATION: Tracking validation failure event logs [cite: 28]
                AppActionLogger.logInput("Validation Failure", "Form execution rejected due to failed rules.");
              }
            },
            child: const Text("Save"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // WEEK 8 INTEGRATION: Touch Gesture Handling via GestureDetector Wrapper [cite: 16]
    return GestureDetector(
      // WEEK 8 INTEGRATION: Swipe Gesture implementation (Swipe Left to change pages) [cite: 17, 18, 26]
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! < 0) {
          AppActionLogger.logInput("Swipe Gesture", "Detected Left Swipe - Navigating to Attendance Screen [cite: 19]");
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AttendanceScreen()),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Student Management"),
          actions: [
            IconButton(
              icon: const Icon(Icons.fact_check),
              tooltip: "Tap to view Attendance",
              onPressed: () {
                // WEEK 8 INTEGRATION: Tap action logging mechanism [cite: 10, 17, 26]
                AppActionLogger.onTapEvent("AppBar Attendance Button Clicked");
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
                // WEEK 8 INTEGRATION: Interactive Real-time Keyboard events [cite: 11, 26]
                onChanged: (text) {
                  AppActionLogger.logInput("Keyboard Search", "Searching live query: $text");
                  searchStudents(text);
                },
                decoration: InputDecoration(
                  labelText: 'Search Student',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () => searchStudents(searchController.text),
                  ),
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 2.0),
              child: Text(
                "💡 Tip: Swipe LEFT to jump to Attendance. Long Press card to delete.",
                style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
              ),
            ),
            Expanded(
              child: students.isEmpty
                  ? const Center(child: Text("No students added yet."))
                  : ListView.builder(
                itemCount: students.length,
                itemBuilder: (context, index) {
                  final student = students[index];
                  // WEEK 8 INTEGRATION: Individual list card gesture recognition [cite: 16]
                  return GestureDetector(
                    // WEEK 8 INTEGRATION: Long Press Touch Gesture to launch deletion context [cite: 17, 20, 21]
                    onLongPress: () async {
                      AppActionLogger.logInput("Long Press Gesture", "Triggered deletion modal context [cite: 21]");
                      bool? confirmDelete = await showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text("Confirm Deletion"),
                          content: Text("Are you sure you want to delete ${student['name']}?"),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
                            TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Delete", style: TextStyle(color: Colors.red))),
                          ],
                        ),
                      );
                      if (confirmDelete == true) {
                        await DatabaseHelper.instance.deleteStudent(student['id']);
                        loadStudents();
                      }
                    },
                    child: Card(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        title: Text("${student['name']} (${student['regNo']})"),
                        subtitle: Text(
                          "Course: ${student['course']} | Year: ${student['year']}\nEmail: ${student['email']}\nPhone: ${student['phone']}",
                        ),
                        isThreeLine: true,
                        trailing: IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            // WEEK 8 INTEGRATION: Reusable single-tap event mapping [cite: 10, 17]
                            AppActionLogger.logInput("Tap Gesture", "Selected edit button element.");
                            showStudentForm(student: student);
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // WEEK 8 INTEGRATION: Standard single-tap event tracking [cite: 10]
            AppActionLogger.logInput("Tap Gesture", "Opened registration modal widget form.");
            showStudentForm();
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

// SCREEN 2: ATTENDANCE SCREEN
class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final nameController = TextEditingController();
  String status = "Present";
  List<Map<String, dynamic>> history = [];

  // WEEK 8 INTEGRATION: Form Key for validation orchestration on Screen 2 [cite: 14]
  final _attendanceFormKey = GlobalKey<FormState>();

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
    // WEEK 8 INTEGRATION: Touch GestureDetector to support bidirectional screen traversal [cite: 16]
    return GestureDetector(
      // WEEK 8 INTEGRATION: Swipe Right Gesture used to dismiss and return home smoothly [cite: 18, 19]
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! > 0) {
          AppActionLogger.logInput("Swipe Gesture", "Detected Right Swipe - Returning Home [cite: 19]");
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("Attendance Records")),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _attendanceFormKey, // Links operational text values to validator check methods [cite: 14]
            child: Column(
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: "Student Name",
                    border: OutlineInputBorder(),
                  ),
                  // WEEK 8 INTEGRATION: Real-time user type logging handler [cite: 11, 26]
                  onChanged: (text) => AppActionLogger.logInput("Keyboard Input", "Typing target attendance name: $text"),
                  validator: (v) => FormValidator.validateRequiredField(v, "Student Name"), // OOP validation execution [cite: 14]
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
                    // WEEK 8 INTEGRATION: Dropdown option change value tracking event [cite: 28]
                    AppActionLogger.logInput("Dropdown State Changed", "Status field modified to: $value");
                    setState(() {
                      status = value!;
                    });
                  },
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(45)),
                  onPressed: () async {
                    // WEEK 8 INTEGRATION: Validation check triggered at point of form submission [cite: 13, 14]
                    if (_attendanceFormKey.currentState!.validate()) {
                      await DatabaseHelper.instance.insertAttendance(
                        nameController.text,
                        DateTime.now().toString().substring(0, 10),
                        status,
                      );

                      AppActionLogger.logInput("Database Commit", "Saved log row entry for ${nameController.text}");
                      nameController.clear();
                      loadAttendance();
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Attendance Saved Successfully!')),
                      );
                    }
                  },
                  child: const Text('Save Attendance'),
                ),
                const SizedBox(height: 10),
                const Text("💡 Tip: Swipe RIGHT to return to the Student List screen.", style: TextStyle(color: Colors.grey, fontSize: 11)),
                const Divider(height: 25, thickness: 2),
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
        ),
      ),
    );
  }
}

// WEEK 8 INTEGRATION: ADVANCED TOUCH EVENT TRACING LOGGING MOVED TO AppActionLogger
