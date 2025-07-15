import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeviceListScreen extends StatefulWidget {
  const DeviceListScreen({super.key});

  @override
  State<DeviceListScreen> createState() => _DeviceListScreenState();
}

class _DeviceListScreenState extends State<DeviceListScreen> {
  List<List<String>> deviceList = [];

  @override
  void initState() {
    super.initState();
    fetchDevices();
  }

  Future<void> fetchDevices() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> rawList = prefs.getStringList('device_list') ?? [];
    setState(() {
      deviceList = rawList.map((e) => e.split('|')).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          iconTheme: IconThemeData(
              color: Color(0xFF4CBA54)
          ),
          title: const Text("Saved Devices")),
      body: deviceList.isEmpty
          ? const Center(child: Text("No devices found"))
          : ListView.builder(
        itemCount: deviceList.length,
        itemBuilder: (context, index) {
          final device = deviceList[index];
          return ListTile(
            leading: const Icon(Icons.devices),
            title: Text(device[0],style: TextStyle(fontSize: 18)), // Device name
            subtitle: Text(device[1],style: TextStyle(fontSize: 16),), // IP address
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Time: ${device[2]}",style: TextStyle(fontSize: 14),),
                Text("Date: ${device[3]}",style: TextStyle(fontSize: 14),),
              ],
            ),
          );
        },
      ),
    );
  }
}
