import 'package:flutter/material.dart';
import 'package:remotetouchpad/touchpad_screen.dart';
class ConnectByIp extends StatefulWidget {
  const ConnectByIp({super.key});

  @override
  State<ConnectByIp> createState() => _ConnectByIpState();
}

class _ConnectByIpState extends State<ConnectByIp> {
  final TextEditingController _ipController = TextEditingController();
  void connectToReceiver() {
    String receiverIp = _ipController.text.trim();

    final ipRegex = RegExp(
      r'^((25[0-5]|2[0-4][0-9]|1\d\d|[1-9]?\d)\.){3}(25[0-5]|2[0-4][0-9]|1\d\d|[1-9]?\d)$',
    );

    if (receiverIp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter the receiver IP")),
      );
      return;
    }

    if (!ipRegex.hasMatch(receiverIp)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Invalid IP address format")),
      );
      return;
    }

    // ✅ IP format is valid
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TouchpadScreen(receiverIp: receiverIp),
      ),
    );
  }

  /*void connectToReceiver() {
    String receiverIp = _ipController.text.trim();
    if (receiverIp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter the receiver IP")),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TouchpadScreen(receiverIp: receiverIp),
      ),
    );
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
            color: Color(0xFF4CBA54)
        ),
          title: Text("Connect Ip")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            SizedBox(height: 20),
            TextField(
              controller: _ipController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Receiver (Laptop) IP",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(

              onPressed: connectToReceiver,
              child: Text("Connect",style: TextStyle(
                color: Color(0xFF4CBA54)
              ),),
            ),
          ],
        ),
      ),
    );
  }
}
