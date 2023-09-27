import 'package:ds_queue_studentclient/config.dart';
import 'package:ds_queue_studentclient/student_home_page.dart';
import 'package:ds_queue_studentclient/supervisor_login_page.dart';
import 'package:flutter/material.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with SingleTickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    // controller = AnimationController(
    //     duration: const Duration(milliseconds: 500), vsync: this);
    // animation = Tween<double>(begin: 0, end: 300).animate(controller)
    //   ..addListener(() {
    //     setState(() {
    //       print(animation.value);
    //     });
    //   });
    // controller.forward();
  }

  @override
  void dispose() {
    // controller.dispose();
    super.dispose();
  }

  void _pushPage(BuildContext context, Widget route) {
    Navigator.push(
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                TextEditingController c = TextEditingController();
                return AlertDialog(
                  title: Text(
                      "Change base url:(no prefix, no port, only baseUrl)\n (Current baseUrl: ${Config.baseUrl} )"),
                  content: TextField(
                    controller: c,
                  ),
                  actions: [
                    ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context, c.text);
                        },
                        child: const Text("confirm"))
                  ],
                );
              }).then((value) {
            if (value != null) {
              setState(() {
                Config.baseUrl = value;
                Config.listenUrl = "tcp://$value:5555";
                Config.replyUrl = "tcp://$value:5556";
              });
            }
          });
        },
        child: const Icon(Icons.settings),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > constraints.maxHeight) {
            // horizontal
            return _horizontalWelcomePage();
          } else {
            return _verticalWelcomePage();
          }
        },
      ),
    );
  }

  Widget _supervisorButton() {
    return Expanded(
      child: ElevatedButton(
          style: ButtonStyle(
            splashFactory: NoSplash.splashFactory,
            elevation: MaterialStateProperty.all(0),
            backgroundColor: MaterialStateColor.resolveWith((states) {
              if (states.contains(MaterialState.pressed)) {
                return Colors.black38;
              } else if (states.contains(MaterialState.hovered)) {
                return Colors.black12;
              }
              return Colors.white;
            }),
          ),
          onPressed: () {
            _pushPage(context, const SupervisorLoginPage());
          },
          child: AnimatedContainer(
            width: double.infinity,
            height: double.infinity,
            duration: const Duration(seconds: 1),
            // decoration: const BoxDecoration(color: Colors.blue),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.manage_accounts,
                  size: 40,
                  color: Colors.blue,
                ),
                Text(
                  "I'm supervisor",
                  style: TextStyle(color: Colors.black),
                )
              ],
            ),
          )),
    );
  }

  Widget _studentButton() {
    return Expanded(
        child: ElevatedButton(
            style: ButtonStyle(
              splashFactory: NoSplash.splashFactory,
              elevation: MaterialStateProperty.all(0),
              backgroundColor: MaterialStateColor.resolveWith((states) {
                if (states.contains(MaterialState.pressed)) {
                  return Colors.black38;
                } else if (states.contains(MaterialState.hovered)) {
                  return Colors.black12;
                }
                return Colors.white;
              }),
            ),
            onPressed: () {
              _pushPage(context, const StudentHomePage());
            },
            child: Container(
              width: double.infinity,
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.group,
                    size: 40,
                    color: Colors.black,
                  ),
                  Text(
                    "I'm Student",
                    style: TextStyle(color: Colors.black),
                  )
                ],
              ),
            )));
  }

  Widget _verticalWelcomePage() {
    return Column(
      children: [
        _supervisorButton(),
        const Divider(
          height: 1.0,
        ),
        _studentButton()
      ],
    );
  }

  Widget _horizontalWelcomePage() {
    return Center(
      child: Row(
        children: [
          _supervisorButton(),
          const VerticalDivider(
            width: 1.0,
          ),
          _studentButton()
        ],
      ),
    );
  }
}
