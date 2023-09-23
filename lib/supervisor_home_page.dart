import 'package:flutter/material.dart';

class SupervisorHomePage extends StatefulWidget {
  const SupervisorHomePage({super.key});

  @override
  State<SupervisorHomePage> createState() => _SupervisorHomePageState();
}

class _SupervisorHomePageState extends State<SupervisorHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Supervisor"),
        backgroundColor: Colors.white,
        actions: [
          ElevatedButton(onPressed: () {}, child: Icon(Icons.bug_report))
        ],
      ),
    );
  }
}
