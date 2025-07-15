import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';

class About extends StatefulWidget {
  const About({super.key});

  @override
  State<About> createState() => _AboutState();
}

class _AboutState extends State<About> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
            color: Color(0xFF4CBA54)
        ),
        title: Text('About'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Text('        Remote Touchpad is an Android based application designed to transform'
            ' a smartphone or tablet into a virtual touchpad for desktop control.'
            ' This app enables users to control their computer\'s mouse remotely using'
            ' intuitive touch gestures, offering real time movement, clicking, scrolling,'
            ' and drag functionality all over a WiFi network.\n\n        My name is Ishfaque'
            ' Jamali, a student of Shaheed Benazir Bhutto University, Shaheed Benazirabad,'
            'currently enrolled in the Department of Information Technology, Roll Number 24-BS(IT)-115.\n\n'
            '        If you have any suggestions, improvements, or feedback regarding my app,'
            'feel free to reach out to me:\n\n'

            '        Email: ishfaqjamali03@gmail.com\n'
            '        WhatsApp: 0316-3164321\n\n'

            '        Your input is highly appreciated and will help me improve and enhance the project further.'
            ,style: TextStyle(fontSize: 18),
        )
      ),
    );
  }
}

