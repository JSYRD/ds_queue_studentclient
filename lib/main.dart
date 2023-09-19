import 'dart:async';
import 'package:ds_queue_studentclient/listinfo.dart';
import 'package:flutter/material.dart';
import 'package:ds_queue_studentclient/utils.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(
        title: "Queue Client Test",
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<ListInfo> _queue = [];
  List<ListInfo> _supervisors = [];

  final TextEditingController _nameController = TextEditingController();
  final ScrollController _messageController = ScrollController();

  final ServerConnecter sc = ServerConnecter();

  List<String> _log = [];

  List<Text> wrapName2Text(List<String> names) {
    List<Text> ret = [];
    for (var name in names) {
      ret.add(Text(name));
    }
    return ret;
  }

  void enterQueue() {
    sc.enterQueue(_nameController.text);
  }

  void clearLog() {
    setState(() {
      _log.clear();
    });
  }

  static String _fourDigits(int n) {
    int absN = n.abs();
    String sign = n < 0 ? "-" : "";
    if (absN >= 1000) return "$n";
    if (absN >= 100) return "${sign}0$absN";
    if (absN >= 10) return "${sign}00$absN";
    return "${sign}000$absN";
  }

  static String _twoDigits(int n) {
    if (n >= 10) return "$n";
    return "0$n";
  }

  void log(Object? object, {Object? sender}) {
    var now = DateTime.now();
    String y = _fourDigits(now.year);
    String m = _twoDigits(now.month);
    String d = _twoDigits(now.day);
    String h = _twoDigits(now.hour);
    String min = _twoDigits(now.minute);
    String sec = _twoDigits(now.second);
    var currentTime = "[$y-$m-$d $h:$min:$sec]";
    var newMessage = "$currentTime ${sender ?? 'annoymous'}: $object";
    List<String> newlog = _log.cast();
    newlog.add(newMessage);
    setState(() {
      _log = newlog;
    });
    Future.delayed(const Duration(milliseconds: 20), () {
      _messageController.jumpTo(_messageController.position.maxScrollExtent);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: ElevatedButton(
        child: const Icon(Icons.bug_report),
        onPressed: () {
          log("Debug", sender: "debugger");
        },
      ),
      drawer: const Drawer(
        child: Column(
          children: [
            DrawerHeader(
              padding: EdgeInsets.all(0.0),
              child: Center(
                child: Text("About"),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('Designed By'),
                  Text('RundongYang & Leon'),
                  Padding(
                    padding: EdgeInsets.only(bottom: 20.0),
                    child: Text('University of Skövde'),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      body: Builder(
        // Top app bar
        builder: (context) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                    child: const Icon(Icons.menu_open),
                  ),
                  const Text(
                    "Current State:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {},
                    onHover: (value) {},
                    child: Icon((() {
                      switch (sc.serverState) {
                        case SERVERSTATE.up:
                          return Icons.check;
                        case SERVERSTATE.down:
                          return Icons.clear;
                        default:
                          return Icons.question_mark;
                      }
                    })()),
                  ),
                ],
              ),
            ),
            const Divider(
              height: 1.0,
            ),
            //Queues
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ListView(children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 20.0, top: 20.0),
                        child: Text(
                          'Current Queue:',
                          style: TextStyle(fontSize: 28),
                        ),
                      ),
                      Column(
                        children: _queue.isEmpty
                            ? [const Text("No Student in Queue Currently.")]
                            : _queue,
                      )
                    ]),
                  ),
                  const VerticalDivider(
                    width: 1,
                  ),
                  Expanded(
                    child: ListView(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 20.0, top: 20.0),
                          child: Text(
                            'Current Supervisors:',
                            style: TextStyle(fontSize: 28),
                          ),
                        ),
                        Column(
                          children: _supervisors.isEmpty
                              ? [const Text("No Supervisors Online Currently.")]
                              : _supervisors,
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(
              height: 1,
              indent: 20,
              endIndent: 20,
              thickness: 1,
            ),
            //bottom
            SizedBox(
              height: 150,
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Text(
                            "Name:",
                            style: TextStyle(fontSize: 24.0),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                                controller: _nameController,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(5.0)),
                                      borderSide:
                                          BorderSide(color: Colors.lightBlue)),
                                  labelText: 'Name',
                                  hintText: 'Enter Your Name',
                                )),
                          ),
                          TextButton(
                            onPressed: () {
                              if (_nameController.text.isNotEmpty) {
                                enterQueue();
                              }
                            },
                            child: const Text('Enter Queue'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const VerticalDivider(
                    width: 1,
                  ),
                  Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 8.0, top: 8.0),
                            child: Text(
                              "Messages",
                              style: TextStyle(
                                  fontSize: 16.0,
                                  decoration: TextDecoration.underline,
                                  decorationThickness: 1),
                            ),
                          ),
                          Expanded(
                              flex: 1,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ListView(
                                  controller: _messageController,
                                  shrinkWrap: true,
                                  // reverse: true,
                                  children: wrapName2Text(_log),
                                ),
                              ))
                        ],
                      ))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
