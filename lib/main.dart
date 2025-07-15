import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:remotetouchpad/Instructions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:udp/udp.dart';
import 'Desktop_functions.dart';
import 'mobile_app.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Platform check
  if (Platform.isAndroid) {
    final prefs = await SharedPreferences.getInstance();
    bool isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;

    if (isFirstLaunch) {
      await prefs.setBool('isFirstLaunch', false); // Mark as visited
      runApp(Main(showInstructions: true));
    } else {
      runApp(Main(showInstructions: false));
    }
  } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    _startDesktopBroadcaster(); // Your desktop logic
  } else {
    runApp(UnsupportedApp());
  }
}


class Main extends StatelessWidget {
  final bool showInstructions;

  const Main({super.key, required this.showInstructions});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: showInstructions ? Instructions() : MyApp(),
    );
  }
}
/*
void main() {
  if (Platform.isAndroid) {
    runApp(Main());
  } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    _startDesktopBroadcaster();


  } else {
    runApp(UnsupportedApp());
  }
}



class Main extends StatelessWidget {
  const Main({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Instructions(),
    );
  }
}
*/


// 🌐 Start desktop UDP broadcaster
void _startDesktopBroadcaster() async {
  final deviceName = Platform.localHostname;
  final ipAddress = await _getLocalIp();

  if (ipAddress == null) {
    print("❌ Could not determine local IP address.");
    return;
  }

  const int port = 5005;
  final socket = await UDP.bind(Endpoint.any(port: Port(port)));
  print("🖥️ Receiver started on port $port");

  // For smooth mouse movement
  int totalDX = 0;
  int totalDY = 0;

  Timer.periodic(const Duration(milliseconds: 16), (_) {
    if (totalDX != 0 || totalDY != 0) {
      moveMouseBy(totalDX, totalDY);
      totalDX = 0;
      totalDY = 0;
    }
  });

  // Handle incoming UDP commands
  socket.asStream().listen((datagram) {
    if (datagram == null) return;


    final message = String.fromCharCodes(datagram.data).trim();
    try {
      if (message.startsWith("move:")) {
        final parts = message.substring(5).split(',');
        totalDX += double.parse(parts[0]).toInt();
        totalDY += double.parse(parts[1]).toInt();
      } else {
        _handleMouseCommand(message);
      }
    } catch (e) {
      print("❌ Parsing error: $e");
    }
  });

  // Send device identity via UDP broadcast
  final broadcastMessage = jsonEncode({'name': deviceName, 'ip': ipAddress});
  print("📡 Broadcasting: $broadcastMessage");

  Timer.periodic(const Duration(milliseconds: 200), (timer) {
    try {
      socket.send(
        utf8.encode(broadcastMessage),
        Endpoint.broadcast(port: Port(45678)),
      );
    } catch (e) {
      print("❌ Broadcast error: $e");
    }
  });

  // Keep the server running
  await Future.delayed(const Duration(days: 365));
}

void _handleMouseCommand(String command) {
  switch (command) {
    case "click:left":
      simulateClick(left: true);
      break;
    case "click:right":
      simulateClick(left: false);
      break;
    case "click:double":
      simulateClick(left: true);
      Future.delayed(const Duration(milliseconds: 50), () {
        simulateClick(left: true);
      });
      break;
    case "scroll:up":
      simulateScroll(-90);
      break;
    case "scroll:down":
      simulateScroll(90);
      break;
    case "drag:start":
      simulateDrag(start: true);
      break;
    case "drag:end":
      simulateDrag(start: false);
      break;
    default:
      print("⚠️ Unknown command: $command");
  }
}
Future<String?> _getLocalIp() async {
  final interfaces = await NetworkInterface.list(
    type: InternetAddressType.IPv4,
    includeLoopback: false,
  );
  for (var interface in interfaces) {
    for (var addr in interface.addresses) {
      if (!addr.isLoopback && addr.type == InternetAddressType.IPv4) {
        return addr.address;
      }
    }
  }
  return null;
}


class DeviceInfo {
  final String name;
  final String ip;
  DeviceInfo(this.name, this.ip);

  factory DeviceInfo.fromJson(String data) {
    final json = jsonDecode(data);
    return DeviceInfo(json['name'], json['ip']);
  }
}

// ❌ Fallback screen for unsupported platforms
class UnsupportedApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("Unsupported Platform")),
        body: Center(
          child: Text("❌ This app only supports Android and Desktop."),
        ),
      ),
    );
  }
}

