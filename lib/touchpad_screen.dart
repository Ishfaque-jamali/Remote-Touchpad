import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:udp/udp.dart';

class TouchpadScreen extends StatefulWidget {
  final String receiverIp;
  TouchpadScreen({required this.receiverIp});

  @override
  _TouchpadScreenState createState() => _TouchpadScreenState();
}

class _TouchpadScreenState extends State<TouchpadScreen> {
  String? _customWallpaperPath;
  late UDP sender;
  final int serverPort = 5005;
  double? lastX;
  double? lastY;
  bool dragging = false;
  double? _scrollStartY;
  bool _isScrolling = false;

  bool _doubleTapDragActive = false;

  DateTime _lastScrollTime = DateTime.now();
  final Duration _scrollThrottle = Duration(milliseconds: 100); // Increase this to slow it down more

  @override
  void initState() {
    super.initState();
    loadWallpaper();
    initSocket();
  }

  void initSocket() async {
    sender = await UDP.bind(Endpoint.any());
  }

  void loadWallpaper() async{
    SharedPreferences preferences= await SharedPreferences.getInstance();
    setState(() {
      _customWallpaperPath=preferences.getString('Touchpad Wallpaper');
    });
  }
  void sendCommand(String command) {
    sender.send(
      command.codeUnits,
      Endpoint.unicast(InternetAddress(widget.receiverIp), port: Port(serverPort)),
    );
  }
  void sendDelta(double dx, double dy) {
    if (dx.abs() < 0.5 && dy.abs() < 0.5) return;
    sendCommand("move:$dx,$dy");
  }

  @override
  void dispose() {
    sender.close();
    super.dispose();
  }
  void _handleScrollStart(DragStartDetails details) {
    _scrollStartY = details.globalPosition.dy;
    _isScrolling = true;
  }

  void _handleScrollUpdate(DragUpdateDetails details) {
    if (!_isScrolling) return;

    final now = DateTime.now();
    if (now.difference(_lastScrollTime) < _scrollThrottle) return;

    _lastScrollTime = now;

    final currentY = details.globalPosition.dy;
    final deltaY = _scrollStartY! - currentY;
    _scrollStartY = currentY;

    if (deltaY > 0) {
      sendCommand("scroll:up");
    } else if (deltaY < 0) {
      sendCommand("scroll:down");
    }
  }


  void _handleScrollEnd(DragEndDetails details) {
    _isScrolling = false;
    _scrollStartY = null;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        if (didPop) {


          sender.close(); // Disconnect UDP before leaving the screen
        }
      },
      child: Scaffold(

        appBar: AppBar(
            iconTheme: IconThemeData(
                color: Color(0xFF4CBA54)
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {




                sender.close(); // Close the connection
                Navigator.of(context).pop(); // Go back
              },
            ),
            title: Text("Touchpad - Connected ")),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: _customWallpaperPath !=null
              ? FileImage(File(_customWallpaperPath!)) as ImageProvider
              :AssetImage('assets/images/touchpadBackground.jpg',), // Correct path & name
              fit: BoxFit.cover, // or BoxFit.fill, BoxFit.contain as needed
              opacity: 0.8
            ),
          ),
          child: Stack(
            children: [
              GestureDetector(


                // Left click (single tap)
                onTap: () => sendCommand("click:left"),

                // Right click (long press)
                onLongPress: () => sendCommand("click:right"),

                // Double click (double tap)
                onDoubleTap: () => sendCommand("click:double"),

                onDoubleTapDown: (_) {
                  _doubleTapDragActive = true;
                  sendCommand("drag:start");
                },

                onDoubleTapCancel: () {
                  _doubleTapDragActive = false;
                },

                onPanUpdate: (details) {
                  if (_doubleTapDragActive) {
                    sendDelta(details.delta.dx * 1.5, details.delta.dy * 1.5);
                  } else {
                    sendDelta(details.delta.dx * 3, details.delta.dy * 3);
                  }
                },

                onPanEnd: (details) {
                  if (_doubleTapDragActive) {
                    sendCommand("drag:end");
                  }
                  _doubleTapDragActive = false;
                },

                onPanStart: (details) {
                  lastX = details.globalPosition.dx;
                  lastY = details.globalPosition.dy;
                  if (dragging) sendCommand("drag:start");
                },


                behavior: HitTestBehavior.opaque,


                child: Center(
                  child: Text(
                    'Touch & Move',
                    style: TextStyle(color: Colors.black, fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              // Floating scroll control on the right side
              Positioned(
                right: 10,
                top: 100,
                bottom: 100,
                child: GestureDetector(
                  onVerticalDragStart: _handleScrollStart,
                  onVerticalDragUpdate: _handleScrollUpdate,
                  onVerticalDragEnd: _handleScrollEnd,
                  child: Container(
                    width: 60,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white54, width: 1),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.keyboard_arrow_up, color: Colors.white70),
                        SizedBox(height: 20),
                        Text("SCROLL", style: TextStyle(color: Colors.white70, fontSize: 12)),
                        SizedBox(height: 20),
                        Icon(Icons.keyboard_arrow_down, color: Colors.white70),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 20,
                left: 10,
                right: 10,
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  spacing: 10,
                  children: [


                    //Leftclick Button
                    SizedBox(
                      width: 140,
                      height: 50,
                      child: FloatingActionButton(
                        heroTag: "leftClick",
                        onPressed: () => sendCommand("click:left"),
                        tooltip: "Left Click",
                        child: Image(image: AssetImage('assets/images/left-click.png')),
                      ),
                    ),


                    //Rightclick Button
                    SizedBox(
                      width: 140,
                      height: 50,
                      child: FloatingActionButton(
                        heroTag: "rightClick",
                        onPressed: () => sendCommand("click:right"),
                        tooltip: "Right Click",
                        child: Image(image: AssetImage('assets/images/right-click.png')),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
