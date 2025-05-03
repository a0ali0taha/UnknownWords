import 'dart:io';
import 'package:flutter/material.dart';
import 'package:enjaz/database_helper.dart';
import 'package:enjaz/achievement.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Children Achievements',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        fontFamily: 'ComicNeue',
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> children = ['Salma', 'Jana', 'Hana'];
  final Map<String, int> points = {};
  final Map<String, int?> selectedNumbers = {};

  @override
  void initState() {
    super.initState();
    _loadPoints();
    // Initialize selected numbers for each child
    for (String child in children) {
      selectedNumbers[child] = null;
    }
  }

  Future<void> _loadPoints() async {
    for (String child in children) {
      final totalPoints = await DatabaseHelper.instance.getTotalPoints(child);
      setState(() {
        points[child] = totalPoints;
      });
    }
  }

  Future<void> _saveAchievement(String childName, int number) async {
    try {
      await DatabaseHelper.instance.insertAchievement(
        childName,
        number,
        10, // Fixed point value
      );
      _loadPoints();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Children Achievements'),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: children.length,
        itemBuilder: (context, index) {
          final child = children[index];
          final childPoints = points[child] ?? 0;
          
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    child,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Total Points: $childPoints',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<int>(
                      value: selectedNumbers[child],
                      hint: const Text('Select Achievement Number'),
                      isExpanded: true,
                      underline: const SizedBox(),
                      items: List.generate(6, (index) => index).map((number) {
                        return DropdownMenuItem<int>(
                          value: number,
                          child: Text(number.toString()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          _saveAchievement(child, value);
                        }
                      },
                    ),
                  ),
                  if (childPoints >= 600)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        '🎉 Congratulations! 🎉',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
