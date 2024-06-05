import 'package:flutter/material.dart';

class SoundLicensePage extends StatelessWidget {
  const SoundLicensePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: LicensePage(
        applicationName: 'Classic Sound',
        applicationVersion: '1.0.0',
      ),
    );
  }
}