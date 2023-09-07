import 'dart:convert';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

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

class NetHelper {
  String? defaultUrl;
  NetHelper({this.defaultUrl});
  Future<void> get(String? url) async {
    if (url == null) url = defaultUrl;
    if (url == null) throw "No Url Specified.";
    try {
      var _client = http.Client();
      var uri = Uri.parse("tcp://$url");
      var response = await _client.get(uri, headers: {
        'content-type': 'application/json'
      }).timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {}
    } catch (e) {
      print(e);
    }
  }
}
