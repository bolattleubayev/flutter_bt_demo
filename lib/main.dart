import 'package:flutter/material.dart';

import './screens/devices_list_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Bluetooth Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: DevicesListScreen(title: 'Bluetooth Demo'),
      );
}
