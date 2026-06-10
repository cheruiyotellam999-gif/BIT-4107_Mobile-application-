import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Student Portal',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
      home: const LoginScreen(),
    );
  }
}

// ==========================================
// 1. LOGIN SCREEN
// ==========================================
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _isPasswordHidden = true;

  void _checkLogin() {
    if (_formKey.currentState!.validate()) {
      if (_userCtrl.text.trim() == 'admin' && _passCtrl.text == '123') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (ctx) => const RegisterScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid username or password'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                const SizedBox(height: 16),
                const Text(
                  'Welcome!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _userCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                  ),
                  validator: (val) => val == null || val.isEmpty ? 'Enter username' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _isPasswordHidden,
                  decoration: InputDecoration(
                    labelText: 'Password',

                  ),
                  validator: (val) => val == null || val.isEmpty ? 'Enter password' : null,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _checkLogin,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Login', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 2. REGISTRATION SCREEN

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _regCtrl = TextEditingController();
  bool _isSaving = false;

  Future<void> _saveRecord() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('name', _nameCtrl.text.trim());
      await prefs.setString('reg', _regCtrl.text.trim());

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Record Saved Successfully!'), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving data: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _regCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Registration'),
        automaticallyImplyLeading: false, // Prevents backing into Login screen
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Full Name',

                ),
                validator: (val) => val == null || val.isEmpty ? 'Please enter full name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _regCtrl,
                decoration: const InputDecoration(
                  labelText: 'Registration Number',

                ),
                validator: (val) => val == null || val.isEmpty ? 'Please enter registration number' : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isSaving ? null : _saveRecord,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _isSaving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Save Record'),
              ),

              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (ctx) => const Dashboard()));
                },

                label: const Text('Go to Dashboard'),
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// 3. DASHBOARD SCREEN
class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);
  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  String _studentName = 'Loading...';
  String _studentReg = 'Loading...';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    setState(() {
      _studentName = prefs.getString('name') ?? 'No Name Recorded';
      _studentReg = prefs.getString('reg') ?? 'No Registration Recorded';
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(24),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.indigo.withOpacity(0.1),

                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('STUDENT NAME', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                          Text(_studentName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(),
                ),
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.amber.withOpacity(0.1),

                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('REGISTRATION NO.', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                          Text(_studentReg, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}