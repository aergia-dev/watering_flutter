import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:watering/mainpage.dart';
//import 'package:flutter_blue/gen/flutterblue.pbserver.dart';
// import 'package:flutter_blue/gen/flutterblue.pb.dart';

class Ble extends StatefulWidget {
  const Ble({Key? key}) : super(key: key);

  @override
  _BleState createState() => _BleState();
}

class _BleState extends State<Ble> {
  StreamSubscription scanResultListener =
      FlutterBlue.instance.scanResults.listen((results) {
    if (results.last.device.name == 'SleepLight') {
      results.last.device.connect();
    }
  });

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    FlutterBlue.instance.startScan(timeout: Duration(seconds: 5));
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Bluetooth connecting",
              style: TextStyle(fontSize: 40.0, fontWeight: FontWeight.bold),
            ),
            StreamBuilder<List<BluetoothDevice>>(
              stream: Stream.periodic(Duration(milliseconds: 100))
                  .asyncMap((_) => FlutterBlue.instance.connectedDevices),
              initialData: [],
              builder: (c, snapshot) {
                if (snapshot.data!.isNotEmpty) {
                  return ElevatedButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => MainPage()));
                    },
                    child: Text('next'),
                  );
                } else {
                  return StreamBuilder<bool>(
                    stream: FlutterBlue.instance.isScanning,
                    initialData: false,
                    builder: (c, snapshot) {
                      if (snapshot.data!) {
                        return ElevatedButton(
                          onPressed: () {},
                          child: Text('scanning'),
                        );
                      }
                      return ButtonTheme(
                        height: 100.0,
                        minWidth: 100.0,
                        child: ElevatedButton(
                          onPressed: () {
                            // if(FlutterBlue.instance.isScanning)
                            FlutterBlue.instance
                                .startScan(timeout: Duration(seconds: 5));
                          },
                          child: Text(
                            'refresh',
                            style: TextStyle(fontSize: 40.0),
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
