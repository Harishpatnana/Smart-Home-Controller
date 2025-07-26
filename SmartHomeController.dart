import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: HomePage(),
    theme: ThemeData(
      primarySwatch: Colors.indigo,
      scaffoldBackgroundColor: Colors.grey.shade100,
    ),
  ));
}

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final String baseUrl = "http://172.16.101.255"; // ← Replace with your NodeMCU IP

  bool doorLocked = false;
  bool fanOn = false;
  bool lightOn = false;
  double temperature = 0.0;
  double humidity = 0.0;

  @override
  void initState() {
    super.initState();
    fetchStatus();
  }

  Future<void> fetchStatus() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/status"));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          temperature = data["temperature"];
          humidity = data["humidity"];
          doorLocked = data["door"] == 1;
          lightOn = data["light"] == 1;
          fanOn = data["fan"] == 1;
        });
      }
    } catch (e) {
      print("Fetch error: $e");
    }
  }

  Future<void> toggleDevice(String device, bool state) async {
    final url = "$baseUrl/$device?state=${state ? 1 : 0}";
    try {
      await http.get(Uri.parse(url));
      fetchStatus();
    } catch (e) {
      print("Toggle error: $e");
    }
  }

  Widget buildDeviceCard({
    required String title,
    required bool state,
    required Function(bool) onChanged,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      color: color.withOpacity(0.15),
      margin: EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.25),
          child: Icon(icon, color: color, size: 30),
        ),
        title: Text(title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        trailing: Switch(
          value: state,
          onChanged: onChanged,
          activeColor: color,
        ),
      ),
    );
  }

  Widget buildSensorCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 30, color: color),
            SizedBox(height: 8),
            Text(label,
                style: TextStyle(fontSize: 16, color: color, fontWeight: FontWeight.w600)),
            SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Smart Home Controller"),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                buildSensorCard("Temp", "$temperature°C", Icons.thermostat, Colors.orange),
                buildSensorCard("Humidity", "$humidity%", Icons.water_drop, Colors.blue),
              ],
            ),
            SizedBox(height: 20),
            buildDeviceCard(
              title: "Door Lock",
              state: doorLocked,
              onChanged: (val) => toggleDevice("door", val),
              icon: doorLocked ? Icons.lock : Icons.lock_open,
              color: Colors.purple,
            ),
            buildDeviceCard(
              title: "Fan",
              state: fanOn,
              onChanged: (val) => toggleDevice("fan", val),
              icon: Icons.air,
              color: Colors.green,
            ),
            buildDeviceCard(
              title: "Light",
              state: lightOn,
              onChanged: (val) => toggleDevice("light", val),
              icon: Icons.lightbulb_outline,
              color: Colors.amber,
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: fetchStatus,
              icon: Icon(Icons.refresh),
              label: Text("Refresh Status"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
