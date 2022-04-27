import 'package:client/screens/form_profile.dart';
import 'package:client/screens/main_page.dart';
import 'package:client/utili/web_navigator.dart';
import 'package:flutter/material.dart';

const serverLink = "https://app-gql-test.herokuapp.com/graphql";
/**
 * support web for http request
 * https://stackoverflow.com/questions/65630743/how-to-solve-flutter-web-api-cors-error-only-with-dart-code
 * https://blog.bal.al/how-to-fix-cors-error-for-your-flutter-web-app
 */
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
      home: LayoutNavigator.buildPage(context, MainPage()),
    );
  }
}
