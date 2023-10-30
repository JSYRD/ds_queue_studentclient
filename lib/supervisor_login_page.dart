import 'package:ds_queue_studentclient/supervisor_home_page.dart';
import 'package:flutter/material.dart';

class SupervisorLoginPage extends StatefulWidget {
  const SupervisorLoginPage({super.key});

  @override
  State<SupervisorLoginPage> createState() => _SupervisorLoginPageState();
}

class _SupervisorLoginPageState extends State<SupervisorLoginPage> {
  final TextEditingController _supervisorNameController =
      TextEditingController();
  final TextEditingController _supervisorPasswordController =
      TextEditingController();

  void _replacePage(BuildContext context, Widget route) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        opaque: false,
        pageBuilder: ((context, animation, secondaryAnimation) {
          return route;
        }),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.ease;

          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
              // color: Colors.black,
              // padding: EdgeInsets.all(160.0),
              // margin: EdgeInsets.symmetric(
              //     vertical: constraints.biggest.height - 30,
              //     horizontal: constraints.biggest.width - 30.0),
              margin: const EdgeInsets.all(80.0),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black54,
                        offset: Offset(2.0, 2.0),
                        blurRadius: 16.0)
                  ],
                  color: Colors.white),
              child: Stack(
                children: [
                  TextButton(
                    style: const ButtonStyle(
                        shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(8.0)))),
                        minimumSize:
                            MaterialStatePropertyAll(Size(60.0, 60.0))),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Icon(Icons.arrow_back),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    // mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 32.0, bottom: 32.0),
                        child: Text(
                          "Login",
                          style: TextStyle(fontSize: 36),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 32),
                        child: TextField(
                          controller: _supervisorNameController,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5.0)),
                                  borderSide:
                                      BorderSide(color: Colors.lightBlue)),
                              labelText: "Name",
                              hintText: "Enter Your Name"),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 32),
                        child: TextField(
                          controller: _supervisorPasswordController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5.0)),
                                borderSide:
                                    BorderSide(color: Colors.lightBlue)),
                            labelText: "Password (Optional)",
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: ElevatedButton(
                                style: const ButtonStyle(),
                                onPressed: () {
                                  if (_supervisorNameController
                                      .text.isNotEmpty) {
                                    _replacePage(
                                        context,
                                        SupervisorHomePage(
                                            supervisorName:
                                                _supervisorNameController
                                                    .text));
                                  } else {
                                    // _supervisorNameController
                                  }
                                },
                                child: const Text("Login")),
                          )
                        ],
                      )
                    ],
                  ),
                ],
              ));
        },
      ),
    );

    // return Scaffold(
    //   body: Column(
    //       mainAxisAlignment: MainAxisAlignment.center,
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //       children: [
    //         const Text(
    //           "Enter:",
    //           style: TextStyle(fontSize: 32.0),
    //         ),
    // TextField(
    //   controller: _supervisorNameController,
    //   decoration: const InputDecoration(
    //       border: OutlineInputBorder(
    //           borderRadius: BorderRadius.all(Radius.circular(5.0)),
    //           borderSide: BorderSide(color: Colors.lightBlue)),
    //       labelText: "Name",
    //       hintText: "Enter Your Name"),
    // ),
    // TextField(
    //   controller: _supervisorPasswordController,
    //   decoration: const InputDecoration(
    //     border: OutlineInputBorder(
    //         borderRadius: BorderRadius.all(Radius.circular(5.0)),
    //         borderSide: BorderSide(color: Colors.lightBlue)),
    //     labelText: "Password (Optional)",
    //   ),
    // )
    //       ]),
    // );
  }
}
