import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class LayoutNavigator {
  static const minHeight = 750.0;
  static const minWidth = 400.0;
  static Future<T?> push<T extends Object?>(
      {required BuildContext context,
      required Widget page,
      RouteSettings? settings}) async {
    return Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => buildPage(context, page),
            settings: settings));
  }

  static Widget buildPage(BuildContext context, Widget page) {
    final _verticalController = ScrollController();
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
                  width: kIsWeb ? minWidth : null,
                  height: minHeight,
                  child: page,
                ),
              ),
            ),
          );
        } else {
          return Container(
            alignment: Alignment.center,
            child: SizedBox(
              width: kIsWeb ? minWidth : null,
              child: page,
            ),
          );
        }
      },
    );
  }
}
