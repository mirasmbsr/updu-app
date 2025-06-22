import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const UpduApp());
}

class UpduApp extends StatelessWidget {
  const UpduApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Updu',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class Task {
  final String title;
  bool done;
  Task(this.title, {this.done = false});
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Task> _tasks = [
    Task('Wake Up'),
    Task('Run / Move'),
    Task('Water / Hydration'),
  ];

  int _streak = 0;
  DateTime? _lastCheckIn;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _streak = prefs.getInt('streak') ?? 0;
    final last = prefs.getString('lastCheckIn');
    if (last != null) {
      _lastCheckIn = DateTime.tryParse(last);
    }
    setState(() {});
  }

  Future<void> _checkIn() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();

    if (_lastCheckIn != null) {
      final diff = today.difference(_lastCheckIn!).inDays;
      if (diff == 1) {
        _streak += 1;
      } else if (diff != 0) {
        _streak = 1;
      }
    } else {
      _streak = 1;
    }

    _lastCheckIn = DateTime(today.year, today.month, today.day);
    await prefs.setInt('streak', _streak);
    await prefs.setString('lastCheckIn', _lastCheckIn!.toIso8601String());

    for (final t in _tasks) {
      t.done = false;
    }
    setState(() {});
    _showPhrase();
  }

  void _showPhrase() {
    const phrases = [
      'Still here. Still rising.',
      'You chose yourself today.',
      'One more step!',
      'Keep moving!',
    ];
    final phrase = phrases[Random().nextInt(phrases.length)];
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: Text(phrase),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  bool get _allDone => _tasks.every((t) => t.done);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Updu'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Streak: $_streak day${_streak == 1 ? '' : 's'}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            ..._tasks.map(
              (task) => CheckboxListTile(
                title: Text(task.title),
                value: task.done,
                onChanged: (v) => setState(() => task.done = v ?? false),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: _allDone ? _checkIn : null,
                child: const Text('Check In'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
