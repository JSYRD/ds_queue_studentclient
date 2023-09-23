import 'package:ds_queue_studentclient/main.dart';
import 'package:flutter/material.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: MaterialButton(
            minWidth: double.infinity,
            onPressed: () {},
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.manage_accounts,
                  size: 40,
                ),
                Text("I'm supervisor")
              ],
            )));
  }

  Widget _studentButton() {
    return Expanded(
        child: MaterialButton(
            height: double.infinity,
            onPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  opaque: false,
                  pageBuilder: ((context, animation, secondaryAnimation) {
                    return MyHomePage(title: "title");
                  }),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    const begin = Offset(1.0, 0.0);
                    const end = Offset.zero;
                    const curve = Curves.ease;

                    var tween = Tween(begin: begin, end: end)
                        .chain(CurveTween(curve: curve));
                    return SlideTransition(
                      position: animation.drive(tween),
                      child: child,
                    );
                  },
                ),
              );
            },
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.group,
                  size: 40,
                ),
                Text("I'm Student")
              ],
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
