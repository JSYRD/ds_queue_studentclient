import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:ds_queue_studentclient/config.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
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

class ZMQHelper {
  static void getUpdate() {
    final ZContext context = ZContext();
    final ZSocket socket = context.createSocket(SocketType.sub);
    socket.connect(Config.url);
    socket.subscribe("");
    socket.messages.listen((event) {
      print(event.toString());
    });
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
