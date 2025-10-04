import 'package:flutter/material.dart';

class QrPage extends StatelessWidget {
  const QrPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR'), backgroundColor: Colors.white, foregroundColor: const Color(0xFF003E77), elevation: 0.5),
      body: const Center(child: Text('QR Action Placeholder', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600))),
      backgroundColor: Colors.white,
    );
  }
}
