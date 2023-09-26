import 'package:ds_queue_studentclient/utils.dart';
import 'package:flutter/material.dart';

class EnterQueueDialog extends StatefulWidget {
  const EnterQueueDialog({super.key, required this.sc});

  final ServerConnecter sc;

  @override
  State<EnterQueueDialog> createState() => _EnterQueueDialogState();
}

class _EnterQueueDialogState extends State<EnterQueueDialog> {
  final TextEditingController _nameController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Enter Queue"),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
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
                            borderSide: BorderSide(color: Colors.lightBlue),
                          ),
                          labelText: 'Name',
                          hintText: 'Enter Your Name, not null'),
                    ),
                  )
                ],
              )),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                  onPressed: () {
                    if (_nameController.text != '') {
                      widget.sc.enterQueue(_nameController.text);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text("Enter"))
            ],
          )
        ],
      ),
    );
  }
}
