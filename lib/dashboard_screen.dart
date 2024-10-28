import 'package:blaze/empty_downloads_screen.dart';
import 'package:blaze/main.dart';
import 'package:blaze_engine/blaze_downloader.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final List<Download> downloads = [];

  void startDownload(String url, int maxRetries, bool forceDownload) {
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid URL and file path.')),
      );
      return;
    }

    setState(() {
      downloads.add(Download(
        url: url,
        maxRetries: maxRetries,
        forceDownload: forceDownload,
      ));
    });

    _downloadFile(downloads.last);
  }

  void _downloadFile(Download download) {
    setState(() {
      download.isDownloading = true;
      download.status = 'Starting download...';
    });

    final downloader = BlazeDownloader(
      download.url,
      maxRetries: download.maxRetries,
      forceDownload: download.forceDownload,
      onProgress: (int downloaded, int total) {
        setState(() {
          download.downloadedBytes = downloaded;
          download.totalBytes = total;
          download.status =
              'Downloading... ${((downloaded / total) * 100).toStringAsFixed(0)}%';
        });
      },
      onStatusChange: (String newStatus) {
        setState(() {
          download.status = newStatus;
        });
      },
      onDownloadComplete: () {
        setState(() {
          download.isDownloading = false;
          download.status = 'Download complete!';
        });
      },
    );

    downloader.download().catchError((error) {
      setState(() {
        download.isDownloading = false;
        download.status = 'Error: $error';
      });
    });
  }

  void _deleteDownload(int index) {
    setState(() {
      downloads.removeAt(index);
    });
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Max Retries:'),
                        DropdownButton<int>(
                          value: maxRetries,
                          items: [1, 2, 3, 4, 5]
                              .map((value) => DropdownMenuItem<int>(
                                    value: value,
                                    child: Text(value.toString()),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              maxRetries = value;
                            }
                          },
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Text('Force Download:'),
                        Switch(
                          value: forceDownload,
                          onChanged: (value) {
                            forceDownload = value;
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                startDownload(url, maxRetries, forceDownload);
                Navigator.of(context).pop(); // Close the dialog
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
                                          value: download.totalBytes > 0
                                              ? download.downloadedBytes /
                                                  download.totalBytes
                                              : null,
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
                                      icon:
                                          const Icon(Icons.delete, color: Colors.red),
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
