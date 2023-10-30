import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:ds_queue_studentclient/config.dart';
import 'package:dartzmq/dartzmq.dart';
import 'package:ds_queue_studentclient/listinfo.dart';
import 'package:ds_queue_studentclient/message.dart';
import 'package:flutter/material.dart';

class Student {
  int ticket;
  String name;
  Student(this.ticket, this.name);
}

class SupervisorServerConnecter {
  final ZContext context = ZContext();

  late int clientId;

  Student? currentStudent;

  String name;

  SERVERSTATE serverState = SERVERSTATE.unknown;

  SUPERVISORSTATE supervisorstate = SUPERVISORSTATE.logging;

  late final MonitoredZSocket repSocket;
  late final MonitoredZSocket listenSocket;

  late Timer heartbeater;

  Timer _timeoutHandler =
      Timer.periodic(const Duration(seconds: 1), (timer) {});

  late final StateSetter setState;

  late final MyMessageController logger;

  late final BuildContext buildContext;

  List<ListInfo> queue = [];
  List<ListInfo> supervisors = [];

  SupervisorServerConnecter(
      this.setState, this.name, this.logger, this.buildContext) {
    clientId = context.hashCode;
    repSocket = context.createMonitoredSocket(SocketType.dealer);
    listenSocket = context.createMonitoredSocket(SocketType.sub);
    _connect();
  }

  void _switchStatus(String status, {String? optionalMessage}) {
    if (status != "pending" && status != "available") {
      logger.log("Unknown status", sender: "_switchStatus");
      return;
    }
    var newMessage = ZMessage();
    newMessage.add(ZFrame(Uint8List.fromList(utf8.encode(''))));
    newMessage.add(ZFrame(Uint8List.fromList(utf8.encode(json.encode({
      "supervisor": true,
      "name": name,
      "clientId": "$clientId",
      "status": status,
      "optionalMessage": optionalMessage
    })))));
    repSocket.sendMessage(newMessage);
  }

  void ready({String? optionalMessage}) {
    _switchStatus("available", optionalMessage: optionalMessage);
  }

  void suspend({String? optionalMessage}) {
    _switchStatus("pending", optionalMessage: optionalMessage);
  }

  void broadcast(String message) {
    var newMessage = ZMessage();
    newMessage.add(ZFrame(Uint8List.fromList(utf8.encode(''))));
    newMessage.add(ZFrame(Uint8List.fromList(utf8.encode(json.encode({
      "supervisor": true,
      "name": name,
      "clientId": "$clientId",
      "message": message
    })))));
    repSocket.sendMessage(newMessage);
  }

  void dispose() {
    repSocket.close();
    listenSocket.close();
    if (supervisorstate != SUPERVISORSTATE.logging) heartbeater.cancel();
  }

  // actually this should happen before entering this page, but have no more time lol
  // actually just enter queue
  void _login() {
    var newMessage = ZMessage();
    newMessage.add(ZFrame(Uint8List.fromList(utf8.encode(''))));
    newMessage.add(ZFrame(Uint8List.fromList(utf8.encode(json.encode({
      "supervisor": true,
      "enterQueue": true,
      "name": name,
      "clientId": "$clientId"
    })))));
    repSocket.sendMessage(newMessage);
  }

  void _heartbeat() {
    var newMessage = ZMessage();
    newMessage.add(ZFrame(Uint8List.fromList(utf8.encode(''))));
    newMessage.add(ZFrame(Uint8List.fromList(utf8.encode(json.encode(
        {"name": name, "supervisor": true, "clientId": "$clientId"})))));
    repSocket.sendMessage(newMessage);
  }

  void _connect() {
    repSocket.events.distinct().listen((event) {
      logger.log(event.first, sender: "MONITOR");
      switch (event.first) {
        case ZEvent.HANDSHAKE_SUCCEEDED:
          logger.log("Connected to server", sender: "Client");
          setState(() {
            serverState = SERVERSTATE.up;
          });
          break;
        case ZEvent.CLOSED:
          logger.log("Socket closed.", sender: "Client");
          setState(() {
            serverState = SERVERSTATE.down;
          });
          heartbeater.cancel();
          _timeoutHandler = Timer.periodic(const Duration(seconds: 1), (timer) {
            _login();
          });
        case ZEvent.CONNECT_RETRIED:
          setState(() {
            serverState = SERVERSTATE.retry;
          });
        case ZEvent.DISCONNECTED:
          setState(() {
            logger.log("Socket disconnected.", sender: "Client");
            setState(() {
              serverState = SERVERSTATE.down;
            });
            heartbeater.cancel();
            _timeoutHandler =
                Timer.periodic(const Duration(seconds: 1), (timer) {
              _login();
            });
          });
        default:
          // setState(() {
          //   serverState = SERVERSTATE.unknown;
          // });
          break;
      }
      // logger.log(event, sender: "SupervisorServerConnecter");
    });

    repSocket.connect(Config.replyUrl);

    repSocket.messages.listen((event) {
      for (var element in event) {
        if (element.payload.isEmpty) continue;
        Map<String, dynamic> reply = jsonDecode(utf8.decode(element.payload));
        if (reply.containsKey("login") &&
            reply["login"] == true &&
            reply["name"] == name) {
          logger.log("Succeed logging.", sender: "Client:");
          heartbeater = Timer.periodic(const Duration(seconds: 1), (timer) {
            _heartbeat();
          });
          _timeoutHandler.cancel();
          setState(() {
            supervisorstate = SUPERVISORSTATE.pending;
          });
        } else if (reply.containsKey("status")) {
          setState(() {
            switch (reply["status"]) {
              case "pending":
                {
                  supervisorstate = SUPERVISORSTATE.pending;
                }
                break;
              case "available":
                {
                  supervisorstate = SUPERVISORSTATE.available;
                }
                break;
              case "occupied":
                {
                  supervisorstate = SUPERVISORSTATE.occupied;
                }
                break;
              default:
                break;
            }
          });
        } else if (reply.containsKey("error")) {
          logger.log("ERROR CAUGHT ${reply["error"]} : ${reply["msg"]}",
              sender: "Server:");
        }
      }
    });

    listenSocket.connect(Config.listenUrl);
    listenSocket.subscribe("queue");
    listenSocket.subscribe("supervisors");
    listenSocket.subscribe(name);
    listenSocket.messages.listen((event) {
      var topic = utf8.decode(event.first.payload);
      if (topic == name) {
        var next = json.decode(utf8.decode(event.last.payload));
        // TODO: ticket property maybe string
        setState(() {
          currentStudent = Student(next["ticket"], next["name"]);
          supervisorstate = SUPERVISORSTATE.occupied;
        });
        logger.log("Next Student: ${next["name"]}, ticket: ${next["ticket"]}",
            sender: "Server");
        logger.log("Now occupied with: ${next["name"]}");
      } else if (topic == "queue") {
        var tqueue = json.decode(utf8.decode(event.last.payload));
        List<ListInfo> newqueue = [];
        for (var element in tqueue) {
          if (element == null) continue;
          newqueue.add(ListInfo(
              title: element['name'], data: "ticket:${element['ticket']}"));
        }
        setState(() {
          queue = newqueue;
        });
      } else if (topic == "supervisors") {
        var tsupervisors = json.decode(utf8.decode(event.last.payload));
        List<ListInfo> newsupervisors = [];
        for (var element in tsupervisors) {
          if (element == null) continue;
          newsupervisors.add(ListInfo(
              title: element['name'] +
                  (element['name'] == name ? "(yourself)" : ''),
              data:
                  "status:${element['status']}    ${(element['client'] == 'undefined' || element['status'] != "occupied") ? 'No Client.' : "Client: ${element['client']['name']} Ticket: ${element['client']['ticket']} "}"));
        }
        setState(() {
          supervisors = newsupervisors;
        });
      }
    });
    _login();
  }

  void reconnect() {
    repSocket.connect(Config.replyUrl);
    listenSocket.connect(Config.listenUrl);
  }
}

enum SUPERVISORSTATE { available, pending, occupied, logging }

class ServerConnecter {
  final ZContext context = ZContext();

  List<ListInfo> queue = [];
  List<ListInfo> supervisors = [];

  String? currentUser;

  SERVERSTATE serverState = SERVERSTATE.unknown;

  late final MonitoredZSocket repSocket;
  late final MonitoredZSocket listenSocket;

  late Timer heartbeater;

  Timer _timeoutHandler =
      Timer.periodic(const Duration(seconds: 1), (timer) {});

  late final StateSetter setState;

  late final MyMessageController logger;

  late final BuildContext buildContext;
  // late final void Function() ;

  ServerConnecter(StateSetter stateSetter, this.logger, this.buildContext) {
    setState = stateSetter;
    repSocket = context.createMonitoredSocket(SocketType.dealer);
    listenSocket = context.createMonitoredSocket(SocketType.sub);
    _connect();
  }

  void dispose() {
    repSocket.close();
    listenSocket.close();
    // heartbeater.cancel();
    // context.stop();
  }

  void unsubscribe(String topic) {
    listenSocket.subscribe(topic);
  }

  void subscribe(String topic) {
    listenSocket.subscribe(topic);
  }

  void _heartbeat() {
    if (currentUser != null) {
      var newMessage = ZMessage();
      newMessage.add(ZFrame(Uint8List.fromList(utf8.encode(''))));
      newMessage.add(ZFrame(Uint8List.fromList(utf8.encode(json
          .encode({"name": currentUser, "clientId": "${context.hashCode}"})))));
      repSocket.sendMessage(newMessage);
    }
  }

  void enterQueue(String name) {
    if (serverState != SERVERSTATE.up) return;
    var newMessage = ZMessage();
    newMessage.add(ZFrame(Uint8List(0)));
    newMessage.add(ZFrame(Uint8List.fromList(utf8.encode(json.encode({
      "enterQueue": true,
      "name": name,
      "clientId": "${context.hashCode}"
    })))));
    repSocket.sendMessage(newMessage);
  }

  void reconnect() {
    if (serverState == SERVERSTATE.up) return;
    repSocket.connect(Config.replyUrl);
    listenSocket.connect(Config.listenUrl);
  }

  void _connect() {
    repSocket.events.distinct().listen((event) {
      switch (event.first) {
        case ZEvent.HANDSHAKE_SUCCEEDED:
          logger.log("Connected to server", sender: "Client");
          setState(() {
            serverState = SERVERSTATE.up;
          });
          break;
        case ZEvent.CLOSED:
          logger.log("Socket closed.", sender: "Client");
          setState(() {
            serverState = SERVERSTATE.down;
          });
          if (currentUser != null) {
            heartbeater.cancel();
            _timeoutHandler =
                Timer.periodic(const Duration(seconds: 1), (timer) {
              enterQueue(currentUser!);
            });
          }
          break;
        case ZEvent.CONNECT_RETRIED:
          setState(() {
            serverState = SERVERSTATE.retry;
          });
          break;
        case ZEvent.DISCONNECTED:
          logger.log("Socket disconnected...", sender: "Client");
          setState(() {
            serverState = SERVERSTATE.down;
          });
          if (currentUser != null) {
            heartbeater.cancel();
            _timeoutHandler =
                Timer.periodic(const Duration(seconds: 1), (timer) {
              enterQueue(currentUser!);
            });
          }
          break;
        default:
          // setState(() {
          //   serverState = SERVERSTATE.unknown;
          // });
          break;
      }
      // logger.log(event, sender: "ServerConnecter");
    });

    repSocket.connect(Config.replyUrl);

    repSocket.messages.listen((event) {
      for (var element in event) {
        if (element.payload.isEmpty) continue;
        Map<String, dynamic> reply = jsonDecode(utf8.decode(element.payload));
        // check if it is queue's ticket
        // logger.log(reply, sender: "DEBUG");
        if (reply.containsKey("name")) {
          if (currentUser != null) unsubscribe(currentUser!);
          setState(() {
            currentUser = reply["name"];
          });
          logger.log(
              "Succeed entering queue, current user: $currentUser; ticket: ${reply['ticket']}",
              sender: "Server");
          subscribe(currentUser!);
          heartbeater = Timer.periodic(const Duration(seconds: 1), (timer) {
            _heartbeat();
          });
          _timeoutHandler.cancel();
        } else if (reply.containsKey("error")) {
          logger.log("ERROR CAUGHT ${reply["error"]} : ${reply["msg"]}",
              sender: "Server:");
        }
      }
    });

    listenSocket.connect(Config.listenUrl);
    listenSocket.subscribe("queue");
    listenSocket.subscribe("supervisors");
    listenSocket.subscribe("supervisorBroadcast");
    listenSocket.messages.listen((event) {
      var topic = utf8.decode(event.first.payload);
      if (topic == "queue") {
        var tqueue = json.decode(utf8.decode(event.last.payload));
        List<ListInfo> newqueue = [];
        for (var element in tqueue) {
          if (element == null) continue;
          newqueue.add(ListInfo(
              title: element['name'], data: "ticket:${element['ticket']}"));
        }
        setState(() {
          queue = newqueue;
        });
      } else if (topic == "supervisors") {
        var tsupervisors = json.decode(utf8.decode(event.last.payload));
        List<ListInfo> newsupervisors = [];
        for (var element in tsupervisors) {
          if (element == null) continue;
          newsupervisors.add(ListInfo(
              title: element['name'],
              data:
                  "status:${element['status']}    ${(element['client'] == 'undefined' || element['status'] != "occupied") ? 'No Client.' : "Client: ${element['client']['name']} Ticket: ${element['client']['ticket']} "}"));
        }
        setState(() {
          supervisors = newsupervisors;
        });
      } else if (topic == currentUser || topic == "supervisorBroadcast") {
        var userMessage = json.decode(utf8.decode(event.last.payload));
        logger.log(userMessage['message'], sender: userMessage['supervisor']);
        ScaffoldMessenger.of(buildContext).showSnackBar(
          SnackBar(
            content: Text(
                "You have a new message from supervisor:${userMessage['supervisor']}"),
            action: SnackBarAction(label: "Check", onPressed: () {}),
          ),
        );
      }
    });
  }
}

enum SERVERSTATE { up, down, retry, unknown }
