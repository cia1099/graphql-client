import 'package:client/screens/main_page.dart';
import 'package:client/screens/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Futter demo',
      theme: ThemeData(
          primarySwatch: Colors.blue, backgroundColor: Color(0xFF008888)),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _verticalController = ScrollController();
    const minHeight = 500;
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.minHeight < minHeight) {
          return Scrollbar(
            controller: _verticalController,
            child: SingleChildScrollView(
              controller: _verticalController,
              scrollDirection: Axis.vertical,
              child: Container(
                alignment: Alignment.center,
                child: SizedBox(
                  width: kIsWeb ? 400 : null,
                  height: minHeight.toDouble(),
                  child: ProfilePage(userId: "sdadasdada"),
                ),
              ),
            ),
          );
        } else {
          return Container(
            alignment: Alignment.center,
            child: SizedBox(
              width: kIsWeb ? 400 : null,
              child: ProfilePage(userId: "sdadasdada"),
            ),
          );
        }
      },
    );
  }
}
