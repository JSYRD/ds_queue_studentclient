import 'package:flutter/material.dart';

class MyMessage extends StatelessWidget {
  late final MyMessageController myMessageController;
  late final ScrollController listViewController;
  MyMessage(
      {Key? key,
      MyMessageController? messageController,
      ScrollController? listViewController,
      StateSetter? stateSetter})
      : myMessageController = messageController ??
            MyMessageController(
                stateSetter: stateSetter!,
                listViewController: listViewController!),
        //TODO: shouldn't use !
        listViewController = listViewController ?? ScrollController(),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        controller: listViewController,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return Text(myMessageController.logs[index]);
        });
  }
}

class MyMessageController {
  MyMessageController(
      {List<String>? logs,
      required StateSetter stateSetter,
      required this.listViewController})
      : _logs = logs ?? [],
        setState = stateSetter;

  late final ScrollController listViewController;
  List<String> _logs;

  List<String> get logs => _logs;

  late final StateSetter setState;

  void clearLog() {
    setState(() {
      logs.clear();
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
    List<String> newlog = _logs.cast();
    newlog.add(newMessage);
    setState(() {
      _logs = newlog;
    });
    Future.delayed(const Duration(milliseconds: 20), () {
      if (listViewController.hasClients) {
        listViewController.jumpTo(listViewController.position.maxScrollExtent);
      }
    });
  }
}
