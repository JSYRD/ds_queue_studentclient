import 'dart:async';
import 'dart:convert';

import 'package:dartzmq/dartzmq.dart';
import 'package:ds_queue_studentclient/config.dart';
import 'package:ds_queue_studentclient/listinfo.dart';
import 'package:flutter/material.dart';
import 'package:ds_queue_studentclient/utils.dart';
import 'dart:isolate';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
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

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  final String title;
  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final StudentContainer _studentContainer = StudentContainer();
  List<ListInfo> _queue = [];

  final ZContext _context = ZContext();
  late final ZSocket _socket;
  late StreamSubscription _subscription;

  List<Text> wrapName2Text(List<String> names) {
    List<Text> ret = [];
    for (var name in names) {
      ret.add(Text(name));
    }
    return ret;
  }

  @override
  void initState() {
    _socket = _context.createSocket(SocketType.sub);
    _socket.connect(Config.url);
    _socket.subscribe("queue");
    // print("test");
    _subscription = _socket.messages.listen((event) {
      var queue = json.decode(utf8.decode(event.last.payload));
      setState(() {
        List<ListInfo> newqueue = [];
        for (var element in queue) {
          newqueue.add(ListInfo(
              title: element['name'], data: "ticket:${element['ticket']}"));
        }
        _queue = newqueue;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _socket.close();
    _context.stop();
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var appBarTitle = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(2.0),
          child: Icon(Icons.format_line_spacing_rounded),
        ),
        Text(widget.title)
      ],
    );

    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: appBarTitle,
      ),
      // body: Column(
      //   children: wrapName2Text(_studentContainer.getAllNames()),
      // ),
      body: ListView(children: [
        const Text(
          'Current Queue:',
          style: TextStyle(fontSize: 32),
        ),
        Column(
          children: _queue,
        )
      ]),
      floatingActionButton: IconButton(
        icon: const Icon(Icons.add),
        onPressed: () {
          setState(() {
            _studentContainer
                .add(Student(name: "Rundong Yang", id: 114, number: 514));
          });
        },
      ),
    );
  }
}
