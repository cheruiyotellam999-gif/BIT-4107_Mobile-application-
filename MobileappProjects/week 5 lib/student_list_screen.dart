import 'package:flutter/material.dart';
import 'api_service.dart';
import 'student_model.dart';

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  late Future<List<StudentModel>> _futureStudents;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  void _loadStudents() {
    setState(() {
      _futureStudents = _apiService.fetchStudents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Directory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _loadStudents,
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadStudents(),
        child: FutureBuilder<List<StudentModel>>(
          future: _futureStudents,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return _ErrorView(
                error: snapshot.error.toString(),
                onRetry: _loadStudents,
              );
            } else if (snapshot.hasData) {
              final students = snapshot.data!;

              if (students.isEmpty) {
                return const Center(child: Text('No students found.'));
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: students.length,
                itemBuilder: (context, index) {
                  return StudentCard(student: students[index]);
                },
              );
            }

            return const Center(child: Text('No data found'));
          },
        ),
      ),
    );
  }
}

class StudentCard extends StatelessWidget {
  final StudentModel student;

  const StudentCard({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Text(
            student.name.isNotEmpty ? student.name[0].toUpperCase() : 'S',
            style: TextStyle(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        title: Text(
          student.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.email_outlined, size: 16),
                  const SizedBox(width: 8),
                  Expanded(child: Text(student.email)),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.business_outlined, size: 16),
                  const SizedBox(width: 8),
                  Expanded(child: Text(student.company)),
                ],
              ),
            ],
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: theme.colorScheme.primary,
        ),
        onTap: () {
          // Future: Navigate to detail screen
        },
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorView({
    super.key,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}