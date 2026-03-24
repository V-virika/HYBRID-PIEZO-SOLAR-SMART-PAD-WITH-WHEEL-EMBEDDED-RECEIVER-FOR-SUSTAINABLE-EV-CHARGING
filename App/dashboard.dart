import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'history_screen.dart';
import 'admin_panel.dart';
import 'login.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final DatabaseReference ref =
  FirebaseDatabase.instance.ref("EV_001");

  final user = FirebaseAuth.instance.currentUser;

  double current = 0;
  double power = 0;
  double energy = 0;
  bool charging = false;
  bool fault = false;

  List<FlSpot> powerSpots = [];
  List<FlSpot> predictedSpots = [];

  final double batteryCapacityWh = 10;

  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();

    /// Listen to last 20 values so graph can draw
    ref.limitToLast(20).onValue.listen((event) {

      if (event.snapshot.value == null) return;

      final values =
      event.snapshot.value as Map<dynamic, dynamic>;

      powerSpots.clear();

      int index = 0;

      values.forEach((key, value) {

        double p = (value['power'] ?? 0).toDouble();

        powerSpots.add(
          FlSpot(index.toDouble(), p),
        );

        index++;

        /// latest values for cards
        current = (value['current'] ?? 0).toDouble();
        power = (value['power'] ?? 0).toDouble();
        energy = (value['energy'] ?? 0).toDouble();
        charging = value['charging'] == 1;
        fault = value['fault'] == 1;

      });

      generatePrediction();

      setState(() {});
    });
  }

  /// Simple prediction line
  void generatePrediction() {

    predictedSpots.clear();

    if (powerSpots.length < 2) return;

    double slope =
        powerSpots.last.y -
            powerSpots[powerSpots.length - 2].y;

    double lastX = powerSpots.last.x;
    double lastY = powerSpots.last.y;

    for (int i = 1; i <= 8; i++) {

      predictedSpots.add(
        FlSpot(lastX + i, max(0, lastY + slope * i)),
      );

    }
  }

  @override
  Widget build(BuildContext context) {

    double percentage =
    (energy / batteryCapacityWh).clamp(0, 1);

    Color bgColor =
    isDarkMode ? Colors.black : const Color(0xFFF3F6F9);

    Color cardColor =
    isDarkMode ? const Color(0xFF1E2A38) : Colors.white;

    Color textColor =
    isDarkMode ? Colors.white : Colors.black87;

    return Scaffold(

      backgroundColor: bgColor,

      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: Text(
          "Welcome ${user?.displayName ?? "User"}",
          style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold),
        ),
        actions: [

          IconButton(
            icon: Icon(
              isDarkMode
                  ? Icons.light_mode
                  : Icons.dark_mode,
              color: textColor,
            ),
            onPressed: () {
              setState(() {
                isDarkMode = !isDarkMode;
              });
            },
          ),

          IconButton(
            icon: Icon(Icons.history,
                color: textColor),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                    const HistoryScreen()),
              );
            },
          ),

          IconButton(
            icon: Icon(Icons.admin_panel_settings,
                color: textColor),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                    const AdminPanel()),
              );
            },
          ),

          IconButton(
            icon: Icon(Icons.logout,
                color: textColor),
            onPressed: () async {

              await FirebaseAuth.instance.signOut();

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                    const LoginPage()),
                    (route) => false,
              );
            },
          ),
        ],
      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(16),

        child: Column(

          children: [

            /// Battery Card
            Card(
              color: cardColor,
              shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(20)),
              child: Padding(
                padding:
                const EdgeInsets.all(16),
                child: Column(
                  children: [

                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment
                          .spaceBetween,
                      children: [

                        Row(
                          children: [

                            Icon(
                              charging
                                  ? Icons.flash_on
                                  : Icons.battery_std,
                              color: charging
                                  ? Colors.green
                                  : textColor,
                            ),

                            const SizedBox(width: 8),

                            Text(
                              "Battery Level",
                              style: TextStyle(
                                  color:
                                  textColor),
                            ),
                          ],
                        ),

                        Text(
                          charging
                              ? "Charging"
                              : "Idle",
                          style: TextStyle(
                              color: charging
                                  ? Colors.green
                                  : Colors.grey,
                              fontWeight:
                              FontWeight.bold),
                        )
                      ],
                    ),

                    const SizedBox(height: 10),

                    LinearProgressIndicator(
                      value: percentage,
                      minHeight: 14,
                      backgroundColor:
                      Colors.grey[300],
                      valueColor:
                      const AlwaysStoppedAnimation(
                          Colors.green),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "${(percentage * 100).toStringAsFixed(1)} %",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight:
                          FontWeight.bold,
                          color:
                          textColor),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// Graph
            Card(
              color: cardColor,
              shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(20)),
              child: Padding(
                padding:
                const EdgeInsets.all(16),
                child: SizedBox(
                  height: 220,

                  child: LineChart(

                    LineChartData(

                      minY: 0,

                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                      ),

                      borderData:
                      FlBorderData(show: false),

                      titlesData:
                      const FlTitlesData(
                          show: false),

                      lineBarsData: [

                        /// real power graph
                        LineChartBarData(
                          spots: powerSpots,
                          isCurved: true,
                          color: Colors.blue,
                          barWidth: 4,
                          dotData:
                          const FlDotData(
                              show: false),
                          belowBarData:
                          BarAreaData(
                            show: true,
                            color: Colors.blue
                                .withOpacity(
                                0.2),
                          ),
                        ),

                        /// prediction
                        LineChartBarData(
                          spots: predictedSpots,
                          isCurved: true,
                          dashArray: [6, 4],
                          color: Colors.orange,
                          barWidth: 3,
                          dotData:
                          const FlDotData(
                              show: false),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// Metric Cards
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics:
              const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,

              children: [

                metricCard(
                    "Current (A)",
                    current.toStringAsFixed(2),
                    Colors.blue,
                    cardColor,
                    textColor),

                metricCard(
                    "Power (W)",
                    power.toStringAsFixed(2),
                    Colors.red,
                    cardColor,
                    textColor),

                metricCard(
                    "Energy (Wh)",
                    energy.toStringAsFixed(2),
                    Colors.green,
                    cardColor,
                    textColor),

                metricCard(
                    "Predicted Time (hr)",
                    power > 0
                        ? ((batteryCapacityWh -
                        energy) /
                        power)
                        .abs()
                        .toStringAsFixed(2)
                        : "0.00",
                    Colors.purple,
                    cardColor,
                    textColor),

                metricCard(
                    "Charging",
                    charging ? "ON" : "OFF",
                    charging
                        ? Colors.green
                        : Colors.grey,
                    cardColor,
                    textColor),

                metricCard(
                    "Fault",
                    fault ? "YES" : "NO",
                    fault
                        ? Colors.red
                        : Colors.green,
                    cardColor,
                    textColor),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget metricCard(String title, String value,
      Color valueColor, Color cardColor, Color textColor) {

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius:
        BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 5))
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment:
        MainAxisAlignment.center,
        children: [

          Text(
            title,
            style: TextStyle(
                color: textColor,
                fontSize: 16),
          ),

          const SizedBox(height: 12),

          Text(
            value,
            style: TextStyle(
                fontSize: 22,
                fontWeight:
                FontWeight.bold,
                color: valueColor),
          ),
        ],
      ),
    );
  }
}