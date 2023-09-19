import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:ds_queue_studentclient/config.dart';
import 'package:dartzmq/dartzmq.dart';
import 'package:ds_queue_studentclient/listinfo.dart';
import 'package:ds_queue_studentclient/message.dart';
import 'package:flutter/material.dart';

class ServerConnecter {
  final ZContext context = ZContext();

  List<ListInfo> queue = [];
  List<ListInfo> supervisors = [];

  String? currentUser;

  final SERVERSTATE serverState = SERVERSTATE.unknown;

  late final MonitoredZSocket repSocket;
  late final MonitoredZSocket listenSocket;

  late final Timer heartbeater;

  late final StateSetter setState;

  late final MyMessageController logger;

  ServerConnecter(StateSetter stateSetter, MyMessageController logger) {
    setState = stateSetter;
    repSocket = context.createMonitoredSocket(SocketType.dealer);
    listenSocket = context.createMonitoredSocket(SocketType.sub);
    logger = logger;
    connect();
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
    var newMessage = ZMessage();
    newMessage.add(ZFrame(Uint8List(0)));
    newMessage.add(ZFrame(Uint8List.fromList(utf8.encode(json.encode({
      "enterQueue": true,
      "name": name,
      "clientId": "${context.hashCode}"
    })))));
    repSocket.sendMessage(newMessage);
  }

  void connect() {
    repSocket.connect(Config.replyUrl);

    repSocket.messages.listen((event) {
      for (var element in event) {
        if (element.payload.isEmpty) continue;
        Map<String, dynamic> reply = jsonDecode(utf8.decode(element.payload));
        // check if it is queue's ticket
        if (reply.containsKey("name")) {
          if (currentUser != null) unsubscribe(currentUser!);
          currentUser = reply["name"];
          //TODO: notify main page to update currentUser
          subscribe(currentUser!);
        } else if (reply.containsKey("error")) {
          print("error");
          //TODO: implement log
        }
      }
    });

    heartbeater = Timer.periodic(const Duration(seconds: 1), (timer) {
      _heartbeat();
    });

    listenSocket.connect(Config.listenUrl);
    listenSocket.subscribe("queue");
    listenSocket.subscribe("supervisors");
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
                  "status:${element['status']}    ${element['client'] == 'undefined' ? 'No Client.' : "Client: ${element['client']['name']} Ticket: ${element['client']['ticket']} "}"));
        }
        setState(() {
          supervisors = newsupervisors;
        });
      }
    });
  }
}

enum SERVERSTATE { up, down, unknown }
