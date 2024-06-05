import 'package:flutter/material.dart';

class SNSLicensePage extends StatelessWidget {
  const SNSLicensePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: LicensePage(
        applicationName: 'HoneyBEE',
        applicationVersion: '1.0.0',
      ),
    );
  }
}