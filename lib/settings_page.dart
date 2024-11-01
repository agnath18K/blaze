import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _autoResume = false;
  int _defaultWorkerCount = 4;
  int _defaultSegmentCount = 8;
  String _downloadType = 'Sequential Download';

  final List<String> _downloadTypes = [
    'Sequential Download',
    'Segmented Download with Worker Pooling',
    'Segmented Download with Fixed Isolates'
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _autoResume = prefs.getBool('autoResume') ?? false;
      _defaultWorkerCount = prefs.getInt('defaultWorkerCount') ?? 3;
      _defaultSegmentCount = prefs.getInt('defaultSegmentCount') ?? 1024;
      _downloadType = prefs.getString('downloadType') ?? _downloadTypes[0];
    });
  }

  Future<void> _saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('autoResume', _autoResume);
    await prefs.setInt('defaultWorkerCount', _defaultWorkerCount);
    await prefs.setInt('defaultSegmentCount', _defaultSegmentCount);
    await prefs.setString('downloadType', _downloadType);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Settings Options',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Enable Auto Resume'),
                  Switch(
                    value: _autoResume,
                    onChanged: (bool value) {
                      setState(() {
                        _autoResume = value;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Select Download Type',
                style: TextStyle(fontSize: 18),
              ),
              DropdownButton<String>(
                value: _downloadType,
                onChanged: (String? newValue) {
                  setState(() {
                    _downloadType = newValue!;
                  });
                },
                items: _downloadTypes
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              const Text(
                'Default Worker Number',
                style: TextStyle(fontSize: 18),
              ),
              TextField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter number of workers',
                ),
                controller:
                    TextEditingController(text: _defaultWorkerCount.toString()),
                onChanged: (value) {
                  int? number = int.tryParse(value);
                  if (number != null) {
                    setState(() {
                      _defaultWorkerCount = number;
                    });
                  }
                },
              ),
              const SizedBox(height: 20),
              const Text(
                'Default Segment Count',
                style: TextStyle(fontSize: 18),
              ),
              TextField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter segment count',
                ),
                controller: TextEditingController(
                    text: _defaultSegmentCount.toString()),
                onChanged: (value) {
                  int? size = int.tryParse(value);
                  if (size != null) {
                    setState(() {
                      _defaultSegmentCount = size;
                    });
                  }
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _saveSettings();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Settings saved!')),
                  );
                },
                child: const Text('Save Settings'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
