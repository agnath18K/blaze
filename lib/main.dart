import 'package:blaze/dashboard_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Download Manager',
      theme: ThemeData.dark(useMaterial3: true),
      home: const DashboardScreen(),
    );
  }
}

class Download {
  final String url;
  final int maxRetries;
  final bool forceDownload;
  int downloadedBytes;
  int totalBytes;
  String status;
  bool isDownloading;

  Download({
    required this.url,
  
    this.maxRetries = 3,
    this.forceDownload = false,
  })  : downloadedBytes = 0,
        totalBytes = 0,
        status = 'Ready',
        isDownloading = false;
}
