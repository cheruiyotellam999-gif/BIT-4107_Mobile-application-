import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int counter = 0;
  String message = "Welcome to My first Flutter App";
  Color bgColor = Colors.lightBlue;

  void increaseCounter() {
    setState(() {
      counter++;
    });
  }

  void changeMessage() {
    setState(() {
      message = "Thanks for clicking the button!";
    });
  }

  void changeColor() {
    setState(() {
      if (bgColor == Colors.lightBlue) {
        bgColor = Colors.green;
      } else if (bgColor == Colors.green) {
        bgColor = Colors.orange;
      } else {
        bgColor = Colors.purple;
      }
    });
  }

  void resetApp() {
    setState(() {
      counter = 0;
      message = "Welcome to My Flutter App";
      bgColor = Colors.lightBlue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,

      appBar: AppBar(
        title: const Text("BIT4107 Assignment"),
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Text(
              message,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            Text(
              "Number count: $counter",
              style: const TextStyle(
                fontSize: 24,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: increaseCounter,
              child: const Text("Click this button to increse count"),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: changeMessage,
              child: const Text("Change Message"),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: changeColor,
              child: const Text("Change Background"),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: resetApp,
              child: const Text("Reset"),
            ),
          ],
        ),
      ),
    );
  }
}