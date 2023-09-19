import 'package:ds_queue_studentclient/message.dart';
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
  final TextEditingController _nameController = TextEditingController();
  final ScrollController _messageController = ScrollController();

  late final ServerConnecter sc;

  late final MyMessageController msg;

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

  void showSnackBar(Widget content) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: content,
      action: SnackBarAction(label: "Close", onPressed: () {}),
    ));
  }

  @override
  void initState() {
    msg = MyMessageController(
        stateSetter: setState, listViewController: _messageController);
    sc = ServerConnecter(setState, msg, context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: ElevatedButton(
        child: const Icon(Icons.bug_report),
        onPressed: () {
          // msg.log("Debug", sender: "debugger");
          // sc.reconnect();
          showSnackBar(const Text("DEBUG"));
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
              padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
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
                  Tooltip(
                    message: (() {
                      switch (sc.serverState) {
                        case SERVERSTATE.unknown:
                          return "Unknown, tap to reconnect";
                        case SERVERSTATE.up:
                          return "Connected.";
                        case SERVERSTATE.down:
                          return "Disconnected, tap to reconnect";
                        case SERVERSTATE.retry:
                          return "Retrying...";
                        default:
                      }
                    })(),
                    child: TextButton(
                      style: ButtonStyle(
                        padding: MaterialStateProperty.all(
                            const EdgeInsets.all(10.0)),
                        minimumSize:
                            MaterialStateProperty.all(const Size(20, 20)),
                      ),
                      onPressed: () {
                        switch (sc.serverState) {
                          case SERVERSTATE.unknown:
                            sc.reconnect();
                            break;
                          case SERVERSTATE.down:
                            sc.reconnect();
                            break;
                          default:
                          // msg.log("UNKNOWN");
                        }
                      },
                      child: Icon((() {
                        switch (sc.serverState) {
                          case SERVERSTATE.up:
                            return Icons.check;
                          case SERVERSTATE.down:
                            return Icons.clear;
                          case SERVERSTATE.retry:
                            return Icons.more_horiz;
                          default:
                            return Icons.refresh;
                        }
                      })()),
                    ),
                  )
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
                        children: sc.queue.isEmpty
                            ? [const Text("No Student in Queue Currently.")]
                            : sc.queue,
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
                          children: sc.supervisors.isEmpty
                              ? [const Text("No Supervisors Online Currently.")]
                              : sc.supervisors,
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
                                  children: wrapName2Text(msg.logs),
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
