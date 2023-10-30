import 'package:flutter/material.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: constraints.maxWidth / 2,
                    height: constraints.maxHeight,
                    color: Colors.green,
                  ),
                  AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    curve: Curves.fastOutSlowIn,
                    width: constraints.maxWidth / 2,
                    height: constraints.maxHeight,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {});
                      },
                      child: Icon(Icons.abc),
                    ),
                  )
                ],
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: constraints.maxWidth / 2,
                    color: Colors.green,
                  ),
                  AnimatedContainer(
                    duration: Duration(milliseconds: 50),
                    width: constraints.maxWidth / 2,
                    color: Colors.blue,
                  )
                ],
              )
            ],
          );
        },
      ),
    );
  }
}
