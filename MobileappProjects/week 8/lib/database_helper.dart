import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'student.dart';

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
      version: 2, // Upgraded to v2 to support table transformations
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE Students(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            regNo TEXT,
            name TEXT,
            course TEXT,
            year TEXT,
            phone TEXT,
            email TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE Attendance(
            attendanceId INTEGER PRIMARY KEY AUTOINCREMENT,
            studentName TEXT,
            attendanceDate TEXT,
            status TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Drops old structural version safely to implement new assignment parameters
          await db.execute('DROP TABLE IF EXISTS Students');
          await db.execute('''
            CREATE TABLE Students(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              regNo TEXT,
              name TEXT,
              course TEXT,
              year TEXT,
              phone TEXT,
              email TEXT
            )
          ''');
          await db.execute('''
            CREATE TABLE Attendance(
              attendanceId INTEGER PRIMARY KEY AUTOINCREMENT,
              studentName TEXT,
              attendanceDate TEXT,
              status TEXT
            )
          ''');
        }
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

  Future<List<Map<String, dynamic>>> searchStudent(String keyword) async {
    final db = await instance.database;
    return await db.query(
      'Students',
      where: 'name LIKE ?',
      whereArgs: ['%$keyword%'],
    );
  }

  Future<int> insertAttendance(String studentName, String attendanceDate, String status) async {
    final db = await instance.database;
    return await db.insert(
      'Attendance',
      {
        'studentName': studentName,
        'attendanceDate': attendanceDate,
        'status': status,
      },
    );
  }

  Future<List<Map<String, dynamic>>> getAttendance() async {
    final db = await instance.database;
    return await db.query('Attendance');
  }
}