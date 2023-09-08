import 'package:flutter/material.dart';

class ListInfo extends Padding {
  ListInfo({Key? key, required String title, required String data})
      : super(
            key: key,
            padding: const EdgeInsets.all(14.0),
            child: OutlinedButton(
                onPressed: () {},
                child: Row(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            title,
                            style: const TextStyle(
                                color: Colors.black, fontSize: 20),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            data,
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 15),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ],
                    ),
                  ],
                )));
}
