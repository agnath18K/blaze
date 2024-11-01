import 'dart:convert';
import 'dart:io';

import 'package:blaze/download_model.dart';
import 'package:blaze/empty_downloads_screen.dart';
import 'package:blaze/settings_page.dart';
import 'package:blaze_engine/blaze_engine.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dbus/dbus.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Future<void> showGnomeNotification(String title, String message) async {
    try {
      await Process.run('notify-send', [title, message]);
    } catch (e) {
      print("Error showing notification: $e");
    }
  }

  double current_progress = 0;
  final List<Download> downloads = [];

  @override
  void initState() {
    super.initState();
    _loadDownloads();
  }

  // Save downloads to SharedPreferences
  Future<void> _saveDownloads() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> downloadJsonList =
        downloads.map((download) => jsonEncode(download.toJson())).toList();
    await prefs.setStringList('downloads', downloadJsonList);
  }

  // Load downloads from SharedPreferences on startup
  Future<void> _loadDownloads() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? downloadJsonList = prefs.getStringList('downloads');

    if (downloadJsonList != null) {
      setState(() {
        downloads.addAll(downloadJsonList.map(
            (downloadJson) => Download.fromJson(jsonDecode(downloadJson))));
      });
    }
  }

  void startDownload(String url, int maxRetries, bool forceDownload) {
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter a valid URL and file path.')),
      );
      return;
    }

    setState(() {
      downloads.add(Download(url: url));
    });

    _downloadFile(downloads.last);
    _saveDownloads(); // Save updated downloads list
  }

  void _downloadFile(Download download) async {
    final Directory? downloadsDir = await getDownloadsDirectory();
    setState(() {
      download.isDownloading = true;
      download.status = 'Starting download...';
    });

    final downloader = SequentialDownload(
      allowResume: true,
      downloadUrl: download.url,
      destinationPath: downloadsDir!.path,
      onProgress: (double progress) {
        setState(() {
          current_progress = progress;
          download.status = 'Downloading... ${(progress).toStringAsFixed(0)}%';
        });
      },
      onComplete: (String filePath) {
        showGnomeNotification(
            "Download Complete", "Your file has been successfully downloaded!");

        setState(() {
          download.isDownloading = false;
          download.status = 'Download complete!';
        });
        _saveDownloads(); // Save after download completes
      },
      onError: (String error) {
        setState(() {
          download.isDownloading = false;
          download.status = 'Error: $error';
        });
        _saveDownloads(); // Save if an error occurs
      },
    );

    downloader.startDownload().catchError((error) {
      setState(() {
        download.isDownloading = false;
        download.status = 'Error: $error';
      });
      _saveDownloads();
    });
  }

  void _deleteDownload(int index) async {
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Download'),
          content: const Text('Are you sure you want to delete this download?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Cancel deletion
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Confirm deletion
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    // If confirmed, delete the item
    if (confirmDelete == true) {
      setState(() {
        downloads.removeAt(index);
      });
      _saveDownloads(); // Save updated list after deletion
    }
  }

  void _showDownloadDialog() {
    String url = '';
    int maxRetries = 3;
    bool forceDownload = false;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Download'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'File URL',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    url = value;
                  },
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                startDownload(url, maxRetries, forceDownload);
                Navigator.of(context).pop();
              },
              child: const Text('Start Download'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Blaze Download Manager'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SettingsPage()),
                  ); // Push the SettingsPage onto the stack
                },
                icon: Icon(Icons.menu)),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: downloads.isEmpty
                  ? const EmptyDownloadsScreen()
                  : ListView.builder(
                      itemCount: downloads.length,
                      itemBuilder: (context, index) {
                        final download = downloads[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        download.url,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text('Status: ${download.status}'),
                                      if (download.isDownloading) ...[
                                        LinearProgressIndicator(
                                          value: current_progress / 100,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                            'Downloaded: ${download.downloadedBytes} bytes'),
                                        Text(
                                            'Total: ${download.totalBytes} bytes'),
                                      ],
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      download.isDownloading
                                          ? Icons.download
                                          : Icons.done,
                                      color: download.isDownloading
                                          ? Colors.blue
                                          : Colors.green,
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () => _deleteDownload(index),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showDownloadDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
