import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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
      home: StudentListScreen(),
    );
  }
}

// STUDENT MODEL
class Student {
  int? id;
  String name;
  String course;
  String email;

  Student({
    this.id,
    required this.name,
    required this.course,
    required this.email,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'course': course,
      'email': email,
    };
  }
}

// DATABASE HELPER
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('students.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE Students(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            course TEXT,
            email TEXT
          )
        ''');
      },
    );
  }

  Future<int> insertStudent(Student student) async {
    final db = await instance.database;
    return await db.insert('Students', student.toMap());
  }

  Future<List<Map<String, dynamic>>> getStudents() async {
    final db = await instance.database;
    return await db.query('Students');
  }

  Future<int> updateStudent(Student student) async {
    final db = await instance.database;
    return await db.update(
      'Students',
      student.toMap(),
      where: 'id=?',
      whereArgs: [student.id],
    );
  }

  Future<int> deleteStudent(int id) async {
    final db = await instance.database;
    return await db.delete(
      'Students',
      where: 'id=?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> searchStudent(
      String keyword) async {
    final db = await instance.database;

    return await db.query(
      'Students',
      where: 'name LIKE ?',
      whereArgs: ['%$keyword%'],
    );
  }
}

// HOME SCREEN
class StudentListScreen extends StatefulWidget {
  @override
  State<StudentListScreen> createState() =>
      _StudentListScreenState();
}

class _StudentListScreenState
    extends State<StudentListScreen> {
  List<Map<String, dynamic>> students = [];
  final TextEditingController searchController =
  TextEditingController();

  @override
  void initState() {
    super.initState();
    loadStudents();
  }

  Future<void> loadStudents() async {
    students =
    await DatabaseHelper.instance.getStudents();
    setState(() {});
  }

  Future<void> searchStudents(String keyword) async {
    students = await DatabaseHelper.instance
        .searchStudent(keyword);
    setState(() {});
  }

  void showStudentForm(
      {Map<String, dynamic>? student}) {
    final nameController = TextEditingController(
        text: student?['name'] ?? '');
    final courseController =
    TextEditingController(
        text: student?['course'] ?? '');
    final emailController =
    TextEditingController(
        text: student?['email'] ?? '');

    showDialog(
      context: this.context,
      builder: (context) => AlertDialog(
        title: Text(
            student == null ? 'Add Student' : 'Update Student'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration:
                const InputDecoration(
                  labelText: 'Name',
                ),
              ),
              TextField(
                controller: courseController,
                decoration:
                const InputDecoration(
                  labelText: 'Course',
                ),
              ),
              TextField(
                controller: emailController,
                decoration:
                const InputDecoration(
                  labelText: 'Email',
                ),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              if (student == null) {
                await DatabaseHelper.instance
                    .insertStudent(
                  Student(
                    name: nameController.text,
                    course:
                    courseController.text,
                    email: emailController.text,
                  ),
                );
              } else {
                await DatabaseHelper.instance
                    .updateStudent(
                  Student(
                    id: student['id'],
                    name: nameController.text,
                    course:
                    courseController.text,
                    email: emailController.text,
                  ),
                );
              }

              Navigator.pop(context);
              loadStudents();
            },
            child: const Text("Save"),
          )
        ],
      ),
    );
  }

  Future<void> deleteStudent(int id) async {
    await DatabaseHelper.instance.deleteStudent(id);
    loadStudents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
        const Text("Student Record Management"),
      ),
      body: Column(
        children: [
          Padding(
            padding:
            const EdgeInsets.all(10),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search Student',
                suffixIcon: IconButton(
                  icon:
                  const Icon(Icons.search),
                  onPressed: () {
                    searchStudents(
                        searchController.text);
                  },
                ),
                border:
                const OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student =
                students[index];

                return Card(
                  child: ListTile(
                    title:
                    Text(student['name']),
                    subtitle: Text(
                      "${student['course']}\n${student['email']}",
                    ),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize:
                      MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                              Icons.edit),
                          onPressed: () {
                            showStudentForm(
                                student:
                                student);
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                              Icons.delete),
                          onPressed: () {
                            deleteStudent(
                                student['id']);
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
      floatingActionButton:
      FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          showStudentForm();
        },
      ),
    );
  }
}