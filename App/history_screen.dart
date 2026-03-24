import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {

  final DatabaseReference ref =
  FirebaseDatabase.instance.ref("EV_001");

  List<Map> history = [];

  @override
  void initState() {
    super.initState();

    ref.limitToLast(20).onValue.listen((event) {
      if (event.snapshot.value == null) return;

      final values =
      event.snapshot.value as Map<dynamic, dynamic>;

      List<Map> temp = [];

      values.forEach((key, value) {
        temp.add({
          "power": value["power"] ?? 0,
          "current": value["current"] ?? 0,
          "energy": value["energy"] ?? 0,
        });
      });

      setState(() {
        history = temp.reversed.toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Charging History")),
      body: ListView.builder(
        itemCount: history.length,
        itemBuilder: (context, index) {
          final item = history[index];

          return Card(
            margin: const EdgeInsets.all(10),
            child: ListTile(
              title: Text("Power: ${item['power']} W"),
              subtitle: Text(
                  "Current: ${item['current']} A\nEnergy: ${item['energy']} Wh"),
            ),
          );
        },
      ),
    );
  }
}
