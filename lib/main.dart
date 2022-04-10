import 'package:flutter/material.dart';
import 'package:watering/blepage.dart';

void main() {
  runApp(
    MyApp(),
  );
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Homepage(),
    );
  }
}

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  var searchResult;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() async {
    print('!!!!!!!!!!!!!!!!!!!!!!!!!!14');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('watering '),
        actions: [],
      ),
      body: Ble(),
    );
  }
}
