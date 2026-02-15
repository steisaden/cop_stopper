import 'package:flutter/material.dart';

class SessionManagementScreen extends StatelessWidget {
  const SessionManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Session Management'),
      ),
      body: const Center(
        child: Text('Session Management Screen'),
      ),
    );
  }
}
