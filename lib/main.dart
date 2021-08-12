import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
// import 'package:flutter_blue/flutter_blue.dart';
import 'package:watering/blepage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
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
    // TODO: implement initState
    super.initState();

    // ble.startScan(timeout: Duration(seconds: 5));
    // searchResult = ble.scanResults.listen((results) {
    //   for (ScanResult r in results) {
    //     print('${r.device.name} found! rssi: ${r.rssi}');
    //   }
    // });
  }

  @override
  void dispose() async {
    // TODO: implement dispose
    super.dispose();
    List<BluetoothDevice> devices = await FlutterBlue.instance.connectedDevices;

    for (BluetoothDevice dev in devices) {
      dev.disconnect();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('watering '),
        actions: [],
      ),
      body: Ble(),
      // StreamBuilder<List<ScanResult>>(
      //   stream: FlutterBlue.instance.scanResults,
      //   initialData: [],
      //   builder: (c, snapshot) => Column(
      //     children: snapshot.data!
      //         .map((e) => Text('${e.advertisementData.localName}'))
      //         .toList(),
      //   ),
      // ),
    );
  }
}
