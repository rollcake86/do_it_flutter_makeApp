import 'package:crafty/data/constant.dart';
import 'package:flutter/material.dart';

class CraftyLicensePage extends StatelessWidget {
  const CraftyLicensePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: LicensePage(
        applicationName: Constant.APP_NAME,
        applicationVersion: '1.0.0',
      ),
    );
  }
}