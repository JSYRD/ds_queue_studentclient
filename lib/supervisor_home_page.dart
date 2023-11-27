import 'package:ds_queue_studentclient/message.dart';
import 'package:ds_queue_studentclient/utils.dart';
import 'package:flutter/material.dart';

class SupervisorHomePage extends StatefulWidget {
  const SupervisorHomePage({super.key, required this.supervisorName});

  final String supervisorName;

  @override
  State<SupervisorHomePage> createState() => _SupervisorHomePageState();
}

class _SupervisorHomePageState extends State<SupervisorHomePage> {
  final MaterialStatesController _susController = MaterialStatesController();
  final MaterialStatesController _playController = MaterialStatesController();

  final ScrollController _messageController = ScrollController();

  late final SupervisorServerConnecter sc;

  late final MyMessageController msg;

  @override
  void initState() {
    msg = MyMessageController(
        stateSetter: setState, listViewController: _messageController);
    sc = SupervisorServerConnecter(
        setState, widget.supervisorName, msg, context);
    super.initState();
  }

  @override
  void dispose() {
    sc.dispose();
    super.dispose();
  }

  List<Text> wrapName2Text(List<String> names) {
    List<Text> ret = [];
    for (var name in names) {
      ret.add(Text(name));
    }
    return ret;
  }

  Widget _msg() {
    return Expanded(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 8.0, top: 8.0),
          child: Text(
            "Messages",
            style: TextStyle(
                fontSize: 32.0,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
                decorationThickness: 1),
          ),
        ),
        Expanded(
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
    ));
  }

  Widget _queue() {
    return Expanded(
      flex: 1,
      child: Column(
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
          Divider(
            height: 1.0,
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
                      ? [const Text("No Supervisor Online Currently.")]
                      : sc.supervisors,
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  List<Widget> _buttons() {
    List<Widget> ret = [];
    ret.add(Padding(
      padding: const EdgeInsets.all(2.0),
      child: ElevatedButton.icon(
        onPressed: () {
          //broadcast button
          showDialog(
              context: context,
              builder: (context) {
                TextEditingController c = TextEditingController();
                return AlertDialog(
                  title: const Text("Broadcast to all students:"),
                  content: TextField(
                    controller: c,
                    decoration:
                        const InputDecoration(hintText: "Broadcast Message"),
                  ),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("cancel")),
                    ElevatedButton(
                        onPressed: () {
                          sc.broadcast(c.text);
                          Navigator.pop(context);
                        },
                        child: const Text("confirm"))
                  ],
                );
              });
        },
        icon: const Icon(Icons.wifi),
        label: const Text("Broadcast"),
        style: const ButtonStyle(
            fixedSize: MaterialStatePropertyAll(Size(130, 30))),
      ),
    ));
    if (sc.supervisorstate == SUPERVISORSTATE.occupied) {
      // suspend
      ret.add(Padding(
        padding: const EdgeInsets.all(2.0),
        child: ElevatedButton.icon(
          onPressed: () {
            TextEditingController c = TextEditingController();
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text("Do you want to suspend?"),
                  content: TextField(
                    controller: c,
                    decoration:
                        const InputDecoration(hintText: "Optional Message"),
                  ),
                  actions: [
                    TextButton.icon(
                        onPressed: () {
                          Navigator.pop(context, 0);
                        },
                        icon: const Icon(Icons.pause),
                        label: const Text("suspend")),
                    ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context, 1);
                        },
                        icon: const Icon(Icons.chevron_right),
                        label: const Text("Next"))
                  ],
                );
              },
            ).then((value) {
              if (value != null) {
                if (value == 0) {
                  //suspend
                  sc.suspend(optionalMessage: c.text);
                } else if (value == 1) {
                  sc.ready(optionalMessage: c.text);
                }
              }
            });
          },
          statesController: _playController,
          icon: const Icon(Icons.check),
          label: const Text("Done"),
          style: const ButtonStyle(
              fixedSize: MaterialStatePropertyAll(Size(130, 30))),
        ),
      ));
    } else if (sc.supervisorstate == SUPERVISORSTATE.pending) {
      ret.add(Padding(
        padding: const EdgeInsets.all(2.0),
        child: ElevatedButton.icon(
          onPressed: () {
            TextEditingController c = TextEditingController();
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text("Ready?"),
                    content: TextField(
                      controller: c,
                      decoration:
                          const InputDecoration(hintText: "Optional Message"),
                    ),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text("cancel")),
                      ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context, 1);
                          },
                          child: const Text("confirm"))
                    ],
                  );
                }).then((value) {
              if (value != null) {
                sc.ready(optionalMessage: c.text);
              }
            });
          },
          statesController: _playController,
          icon: const Icon(Icons.play_arrow),
          label: const Text("Ready"),
          style: const ButtonStyle(
              fixedSize: MaterialStatePropertyAll(Size(130, 30))),
        ),
      ));
    } else if (sc.supervisorstate == SUPERVISORSTATE.available) {
      ret.add(Padding(
        padding: const EdgeInsets.all(2.0),
        child: ElevatedButton.icon(
          onPressed: () {
            TextEditingController c = TextEditingController();
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text("Suspend?"),
                    content: TextField(
                      controller: c,
                      decoration:
                          const InputDecoration(hintText: "Optional Message"),
                    ),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text("cancel")),
                      ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context, 1);
                          },
                          child: const Text("confirm"))
                    ],
                  );
                }).then((value) {
              if (value != null) {
                sc.suspend(optionalMessage: c.text);
              }
            });
          },
          statesController: _susController,
          icon: const Icon(Icons.pause),
          label: const Text("Suspend"),
          style: const ButtonStyle(
            fixedSize: MaterialStatePropertyAll(Size(130, 30)),
          ),
        ),
      ));
    } else {}
    return ret;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end, children: _buttons()),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: LayoutBuilder(
        // Top app bar
        builder: (context, constraints) =>
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.only(top: 0.0, bottom: 0.0),
            child: SafeArea(
              top: true,
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  TextButton(
                    style: const ButtonStyle(
                        minimumSize:
                            MaterialStatePropertyAll(Size(60.0, 60.0))),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Icon(Icons.arrow_back),
                  ),
                  // const SizedBox(
                  //   height: 60.0,
                  //   child: VerticalDivider(
                  //     width: 3.0,
                  //   ),
                  // ),
                  // supervisor state
                  const Text(
                    "Current State:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Tooltip(
                    message: (() {
                      switch (sc.supervisorstate) {
                        case SUPERVISORSTATE.available:
                          return "Available, waiting for student";
                        case SUPERVISORSTATE.pending:
                          return "Suspending";
                        case SUPERVISORSTATE.occupied:
                          return "Dealing with: ${sc.currentStudent!.name}";

                        case SUPERVISORSTATE.logging:
                          return "logging in...";
                        default:
                          return "Unknown";
                      }
                    })(),
                    child: TextButton(
                      style: ButtonStyle(
                        padding: MaterialStateProperty.all(
                            const EdgeInsets.all(10.0)),
                        minimumSize:
                            MaterialStateProperty.all(const Size(20, 20)),
                      ),
                      onPressed: () {},
                      child: Icon((() {
                        switch (sc.supervisorstate) {
                          case SUPERVISORSTATE.available:
                            return Icons.check;
                          case SUPERVISORSTATE.pending:
                            return Icons.pause;
                          case SUPERVISORSTATE.occupied:
                            return Icons.group;
                          case SUPERVISORSTATE.logging:
                            return Icons.more_horiz;
                          default:
                            return Icons.refresh;
                        }
                      })()),
                    ),
                  ),
                  // const SizedBox(
                  //   height: 60.0,
                  //   child: VerticalDivider(
                  //     width: 3.0,
                  //   ),
                  // ),
                  //Server state
                  const Text(
                    "Server State:",
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
                          return "Unknown";
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
                  ),
                  Text("(DEBUG ONLY)ClientId: ${sc.context.hashCode}")
                ],
              ),
            ),
          ),
          const Divider(
            height: 1.0,
          ),
          Expanded(
            child: (constraints.maxWidth > constraints.maxHeight)
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                        _msg(),
                        const VerticalDivider(
                          width: 1,
                        ),
                        _queue()
                      ])
                : Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _msg(),
                      const Divider(
                        height: 1,
                      ),
                      _queue()
                    ],
                  ),
          ),
        ]),
      ),
    );
  }
}
