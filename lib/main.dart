import 'dart:convert';
import 'package:ds_queue_studentclient/config.dart';
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
  ZMQHelper zmqHelper = ZMQHelper();
  final TextEditingController _nameController = TextEditingController();

  List<Text> wrapName2Text(List<String> names) {
    List<Text> ret = [];
    for (var name in names) {
      ret.add(Text(name));
    }
    return ret;
  }

  void subscribeQueueStatus() {
    zmqHelper.subscribe(
      Config.url,
      "queue",
      (event) {
        var queue = json.decode(utf8.decode(event.last.payload));
        List<ListInfo> newqueue = [];
        for (var element in queue) {
          newqueue.add(ListInfo(
              title: element['name'], data: "ticket:${element['ticket']}"));
        }
        setState(
          () {
            _queue = newqueue;
          },
        );
      },
    );
  }

  void subscribeSupervisorStatus() {
    zmqHelper.subscribe(
      Config.url,
      "supervisors",
      (event) {
        var supervisors = json.decode(utf8.decode(event.last.payload));
        List<ListInfo> newqueue = [];
        for (var element in supervisors) {
          newqueue.add(ListInfo(
              title: element['name'],
              data:
                  "status:${element['status']}    ${element['client'] == 'undefined' ? 'No Client.' : "Client: ${element['client']['name']} Ticket: ${element['client']['ticket']} "}"));
        }
        setState(
          () {
            _supervisors = newqueue;
          },
        );
      },
    );
  }

  @override
  void initState() {
    subscribeQueueStatus();
    subscribeSupervisorStatus();
    super.initState();
  }

  @override
  void dispose() {
    zmqHelper.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  )
                ],
              ),
            ),
            const Divider(
              height: 1.0,
            ),
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
                          style: TextStyle(fontSize: 32),
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
                            style: TextStyle(fontSize: 32),
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
            Expanded(
              flex: 0,
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
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5.0)),
                                borderSide:
                                    BorderSide(color: Colors.lightBlue)),
                            labelText: 'Name',
                            hintText: 'Enter Your Name',
                          )),
                    ),
                    TextButton(
                      onPressed: () {
                        if (_nameController.text.isNotEmpty) {}
                      },
                      child: const Text('Enter Queue'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
