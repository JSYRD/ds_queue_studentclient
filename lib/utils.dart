import 'dart:async';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:dartzmq/dartzmq.dart';

class Student {
  Student({required this.name, required this.id, required this.number});
  String name;
  int id;
  int number;
}

class StudentContainer {
  final List<Student> _container = [];
  StudentContainer() {
    _container.add(Student(name: "Leon", id: 114514, number: 1919810));
  }

  List<String> getAllNames() {
    List<String> ret = [];
    for (var student in _container) {
      ret.add("Name:${student.name} Id:${student.id} No.:${student.number}");
    }
    return ret;
  }

  void add(Student student) {
    _container.add(student);
  }
}

// class ZConnection {
//   late final ZSocket socket;
//   late final StreamSubscription subscription;
//   void destroy() {
//     subscription.cancel();
//     socket.close();
//   }
// }

class ZMQHelper {
  static final ZContext context = ZContext();

  static List<ZSocket> sockets = [];
  static MonitoredZSocket getNewSocket(String url, SocketType type) {
    // ZSocket ret = context.createSocket(type);
    var ret = context.createMonitoredSocket(type);
    ret.connect(url);
    sockets.add(ret); // NOTE: manage ALL sockets.

    return ret;
  }

  static void subscribe(ZSocket socket, String url, String topic,
      void Function(ZMessage event) onUpdate) {
    socket.subscribe(topic);
    socket.messages.listen(onUpdate);
  }

  static void unsubscribe(ZSocket socket, String topic) {
    socket.unsubscribe(topic);
  }

  // static void send(ZSocket socket, Map<String, dynamic> message) {
  //   socket.send(utf8.encode(json.encode(message)));
  // }

  // static StreamSubscription receive(
  //     ZSocket socket, void Function(ZMessage event) onData) {
  //   return socket.messages.listen(onData);
  // }

  static void dispose() {
    for (var socket in sockets) {
      socket.close();
    }
    context.stop();
  }
}

class NetHelper {
  String? defaultUrl;
  NetHelper({this.defaultUrl});
  Future<Response> _request(String? url,
      {Map<String, String>? header,
      Map<String, String>? body,
      bool isPost = false}) async {
    var client = http.Client();
    var uri = Uri.parse("tcp://$url");
    Future<Response> response;
    if (!isPost) {
      response = client
          .get(uri, headers: header)
          .timeout(const Duration(seconds: 3)) as Future<Response>;
    } else {
      response = client
          .post(uri, headers: header, body: body)
          .timeout(const Duration(seconds: 3)) as Future<Response>;
    }
    return response;
  }

  Future<Response> get(String? url) async {
    return _request(
      url,
      header: {'content-type': 'application/json'},
    );
  }

  Future<Response> post(String? url, Map<String, String>? body) async {
    return _request(url,
        header: {'content-type': 'application/json'}, body: body, isPost: true);
  }
}

enum SERVERSTATE { up, down, heartbeating, unknown }
