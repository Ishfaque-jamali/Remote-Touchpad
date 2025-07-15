import 'package:flutter/material.dart';

import 'mobile_app.dart';

class Instructions extends StatefulWidget {
  @override
  _InstructionsState createState() => _InstructionsState();
}

class _InstructionsState extends State<Instructions> {
  final PageController _controller = PageController();

  int _currentPage = 0;
  List<String> image=["assets/images/instruction01.png","assets/images/instruction02.png",
    "assets/images/instruction03.png","assets/images/instruction04.png"];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Main PageView
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: 4,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                return Container(
                  color: Color(0xFF429f48),
                  child: Image(image: AssetImage("${image[index]}"))
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: // Dots indicator
      Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if(_currentPage==3)
            ElevatedButton(
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>MyApp()));
                },
                child: Text('Finish')),


          Padding(
            padding: const EdgeInsets.only(bottom: 30, top: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                bool isActive = index == _currentPage;
                return AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  margin: EdgeInsets.symmetric(horizontal: 6),
                  width: isActive ? 16 : 10,
                  height: isActive ? 16 : 10,
                  decoration: BoxDecoration(
                    color: isActive ? Colors.white : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
          ),

        ],
      ),

    );
  }
}
