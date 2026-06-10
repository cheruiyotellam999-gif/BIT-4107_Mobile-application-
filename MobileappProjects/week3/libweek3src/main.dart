import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Week 3 Assignment',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginScreen(),
    );
  }
}

// LOGIN SCREEN
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailController =
  TextEditingController();

  final TextEditingController passwordController =
  TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Icon(
                Icons.person,
                size: 100,
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Enter Email";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 15),

              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Enter Password";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                        const HomeScreen(),
                      ),
                    );
                  }
                },
                child: const Text("LOGIN"),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// HOME SCREEN
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Widget buildCard(
      BuildContext context,
      String title,
      IconData icon,
      Widget page) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => page,
          ),
        );
      },
      child: Card(
        elevation: 5,
        child: SizedBox(
          height: 120,
          child: Center(
            child: Column(
              mainAxisAlignment:
              MainAxisAlignment.center,
              children: [
                Icon(icon, size: 40),
                const SizedBox(height: 10),
                Text(title),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
      AppBar(title: const Text("Home")),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: [
            buildCard(
              context,
              "Dashboard",
              Icons.dashboard,
              const DashboardScreen(),
            ),
            buildCard(
              context,
              "Profile",
              Icons.person,
              const ProfileScreen(),
            ),
            buildCard(
              context,
              "Settings",
              Icons.settings,
              const SettingsScreen(),
            ),
          ],
        ),
      ),
    );
  }
}

// DASHBOARD SCREEN
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  Widget dashboardCard(
      String title,
      String value) {
    return Card(
      elevation: 4,
      child: ListTile(
        title: Text(title),
        trailing: Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
      AppBar(title: const Text("Dashboard")),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            dashboardCard(
                "Students", "200"),
            dashboardCard(
                "Courses", "8"),
            dashboardCard(
                "Lecturers", "7"),
          ],
        ),
      ),
    );
  }
}

// PROFILE SCREEN
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
      AppBar(title: const Text("Profile")),
      body: const Center(
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              child: Icon(
                Icons.person,
                size: 50,
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Ellam",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text("student@email.com"),
          ],
        ),
      ),
    );
  }
}

// SETTINGS SCREEN
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() =>
      _SettingsScreenState();
}

class _SettingsScreenState
    extends State<SettingsScreen> {
  bool notifications = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
      AppBar(title: const Text("Settings")),
      body: Column(
        children: [
          SwitchListTile(
            title:
            const Text("Enable Notifications"),
            value: notifications,
            onChanged: (value) {
              setState(() {
                notifications = value;
              });
            },
          ),
          ListTile(
            leading:
            const Icon(Icons.logout),
            title: const Text("Logout"),
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                  const LoginScreen(),
                ),
                    (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}