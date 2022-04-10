import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:watering/mainpage.dart';
import 'blefuncs.dart';

final String devName = 'watering';

class Ble extends StatefulWidget {
  const Ble({Key? key}) : super(key: key);

  @override
  _BleState createState() => _BleState();
}

class _BleState extends State<Ble> {
  StreamSubscription scanResultListener =
      FlutterBlue.instance.scanResults.listen((results) async {
    if (results.length > 0 && results.last.device.name == devName) {
      BluetoothDevice device = results.last.device;

      await device.connect();

      print('trying connect ${results.last.device.name}');
    }
  });

  @override
  void initState() {
    FlutterBlue.instance.startScan(timeout: Duration(seconds: 5));

    super.initState();
  }

  @override
  void dispose() {
    scanResultListener.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(30.0),
        child: StreamBuilder<List<BluetoothDevice>>(
          stream: Stream.periodic(Duration(milliseconds: 1000))
              .asyncMap((_) => FlutterBlue.instance.connectedDevices),
          initialData: [],
          builder: (c, snapshot) {
            if (snapshot.data!.isNotEmpty) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "블루투스 연결 됨",
                    style: TextStyle(fontSize: 50),
                  ),
                  Text(
                    "\"다음\"을 눌러 진행",
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(
                    height: 100,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      BleFuncs.instance.initDevice(snapshot.data!.last);
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => MainPage()));
                    },
                    child: Text('다음'),
                  ),
                ],
              );
            } else {
              return StreamBuilder<bool>(
                stream: FlutterBlue.instance.isScanning,
                initialData: false,
                builder: (c, snapshot) {
                  if (snapshot.data!) {
                    return Center(
                      child: Text(
                        "검색 중(최대 5초)",
                        style: TextStyle(fontSize: 50),
                      ),
                    );
                  }
                  return ButtonTheme(
                    height: 100.0,
                    minWidth: 100.0,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            "블루투스 검색 안됨 ",
                            style:
                                TextStyle(fontSize: 50, color: Colors.red[700]),
                          ),
                          Text(
                            "해당 기기가 꺼져 있거나, 거리가 너무 멈",
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              // if(FlutterBlue.instance.isScanning)
                              FlutterBlue.instance
                                  .startScan(timeout: Duration(seconds: 5));
                            },
                            child: Text(
                              '다시 시도',
                              style: TextStyle(fontSize: 40.0),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
