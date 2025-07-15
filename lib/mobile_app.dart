// 📱 Android device screen
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:remotetouchpad/Instructions.dart';
import 'package:remotetouchpad/touchpad_screen.dart';
import 'package:remotetouchpad/wallpaper_selection_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';


import 'about.dart';
import 'connect_by_ip.dart';
import 'history.dart';
import 'main.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}



class _MyAppState extends State<MyApp> {

  final List<DeviceInfo> _devices = [];
  RawDatagramSocket? _socket;
  bool _isSearching = false;
  List<String> myArray = []; // empty dynamic array of strings
  List<List<String>> DeviceData = []; // empty dynamic array of strings

  @override
  void initState() {
    super.initState();
    _startSearch();
  }

  void _startSearch() async {
    await _disposeSocket();

    setState(() {
      _devices.clear();
      _isSearching = true;
    });

    try {
      _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 45678);
      _socket!.broadcastEnabled = true;

      _socket!.listen((event) {
        if (event == RawSocketEvent.read) {
          final datagram = _socket!.receive();
          if (datagram != null) {
            final data = String.fromCharCodes(datagram.data);
            try {
              final json = jsonDecode(data);
              if (json is Map && json.containsKey('name') && json.containsKey('ip')) {
                final device = DeviceInfo(json['name'], json['ip']);
                if (!_devices.any((d) => d.ip == device.ip)) {
                  setState(() {
                    _devices.add(device);
                  });
                }
              }
            } catch (_) {}
          }
        }
      });

      // Listen for 5 seconds then stop
      await Future.delayed(Duration(seconds: 5));
    } catch (e) {
      print("❌ Error: $e");
    } finally {
      await _disposeSocket();
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  Future<void> _disposeSocket() async {
    try {
      _socket?.close(); // ✅

    } catch (_) {}
    _socket = null;
  }


  Future<void> saveDeviceToPrefs(String name, String ip) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Get current time & date
    final now = DateTime.now();
    final time = "${now.hour}:${now.minute}";
    final date = "${now.day}/${now.month}/${now.year}";

    // Fetch existing list
    List<String> rawList = prefs.getStringList('device_list') ?? [];
    List<List<String>> deviceList = rawList.map((e) => e.split('|')).toList();

    // Check if device already exists by name
    int index = deviceList.indexWhere((e) => e[0] == name);

    if (index != -1) {
      // Update existing entry
      deviceList[index] = [name, ip, time, date];
    } else {
      // Add new entry
      deviceList.add([name, ip, time, date]);
    }

    // Save back to SharedPreferences
    List<String> encoded = deviceList.map((e) => e.join('|')).toList();
    await prefs.setStringList('device_list', encoded);
  }



  @override
  void dispose() {
    _disposeSocket();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
            color: Color(0xFF4CBA54)
        ),
        title:   Text("Select a  computer"),
        actions: [
          _isSearching
              ? Padding(
            padding: const EdgeInsets.only(right: 10),
            child: const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.blue,
              ),
            ),
          )
              : Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: "Refresh",
              onPressed: _startSearch,
            ),
          )
        ],
      ),
      drawer: Drawer(
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 30),
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                      border: Border.all(
                          width: 1,
                          color: Colors.black12
                      )
                  ),
                  child:ListTile(
                    leading: Icon(Icons.history,size: 25,color: Color(0xFF4CBA54),),
                    title: Text('History',style: TextStyle(fontSize: 22),),
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>DeviceListScreen()));
                    },
                  ),
                ),
              ),
              Container(
                height: 60,
                decoration: BoxDecoration(
                  border: Border.all(width: 1, color: Colors.black12),
                ),
                child: ListTile(
                  leading: Icon(
                    Icons.add_location_outlined,
                    size: 25,
                    color: Color(0xFF4CBA54),
                  ),
                  title: Text(
                    'Connect by IP address',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ConnectByIp()),
                    );

                  },

                ),
              ),

              Container(
                height: 60,
                decoration: BoxDecoration(
                    border: Border.all(
                        width: 1,
                        color: Colors.black12
                    )
                ),
                child:ListTile(
                  leading: Icon(Icons.wallpaper,size: 25,color: Color(0xFF4CBA54),),
                  title: Text('Wallpaper',style: TextStyle(fontSize: 22),),
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>WallpaperSelectionScreen()));
                  },
                ),
              ),
              Container(
                height: 60,
                decoration: BoxDecoration(
                    border: Border.all(
                        width: 1,
                        color: Colors.black12
                    )
                ),
                child:ListTile(
                  leading: Icon(Icons.help_outline_sharp,size: 25,color: Color(0xFF4CBA54),),
                  title: Text('About',style: TextStyle(fontSize: 22),),
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>About()));
                  },
                ),
              ),
            ],
          )
      ),
      body:
      _devices.isEmpty
          ? Center(
        child: Text(
          _isSearching ? "🔍 Searching for devices..." : "❌ No devices found.",
          style: const TextStyle(fontSize: 18),
        ),
      )
          : Column(
        children: [
          Container(
            height: 70,
            decoration: BoxDecoration(
                border: Border.all(
                    width: 1,
                    color: Colors.black12
                )
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Row(
                children: [
                  Icon(Icons.wifi),
                  SizedBox(width: 33,),
                  Text('Wifi',style: TextStyle(fontSize: 18),)
                ],
              ),
            ),
          ),


          if (_isSearching)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "⏳ Collecting available devices...",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: _devices.length,
              itemBuilder: (context, index) {
                final device = _devices[index];
                return Container(
                  height: 70,
                  decoration: BoxDecoration(
                      border: Border.all(
                          width: 1,
                          color: Colors.black12
                      )
                  ),
                  child: ListTile(
                      leading: const Icon(Icons.devices,color: Color(0xFF4CBA54),),
                      title: Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Text(device.name,style:
                        TextStyle(fontSize: 18),),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Text(device.ip,style:
                        TextStyle(fontSize: 16),),
                      ),
                      onTap: (){
                        saveDeviceToPrefs("${device.name}","${device.ip}");
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TouchpadScreen(receiverIp: device.ip),
                          ),
                        );
                      }
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

}