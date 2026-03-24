import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {

  final DatabaseReference ref =
  FirebaseDatabase.instance.ref("EV_001");

  double avgPower = 0;
  double totalEnergy = 0;
  int sessions = 0;

  @override
  void initState() {
    super.initState();

    ref.onValue.listen((event) {
      if (event.snapshot.value == null) return;

      final values =
      event.snapshot.value as Map<dynamic, dynamic>;

      double powerSum = 0;
      double energySum = 0;
      int count = 0;

      values.forEach((key, value) {
        powerSum += (value["power"] ?? 0);
        energySum += (value["energy"] ?? 0);
        count++;
      });

      setState(() {
        sessions = count;
        totalEnergy = energySum;
        avgPower = count > 0 ? powerSum / count : 0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Analytics")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            analyticsCard("Average Power", avgPower),
            analyticsCard("Total Energy", totalEnergy),
            analyticsCard("Sessions", sessions.toDouble()),
          ],
        ),
      ),
    );
  }

  Widget analyticsCard(String title, double value) {
    return Card(
      child: ListTile(
        title: Text(title),
        trailing: Text(
          value.toStringAsFixed(2),
          style: const TextStyle(
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
