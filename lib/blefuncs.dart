import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:watering/mainpage.dart';

final String serviceUUID = "000000ff-0000-1000-8000-00805f9b34fb";
final String characteristicUUID = "0000ff01-0000-1000-8000-00805f9b34fb";

const Map<String, List<int>> Protocol = {
  "POWER_ON": [0x01, 0x00],
  "POWER_OFF": [0x01, 0x01],
  "START": [0x01, 0x02],
  "STOP": [0x01, 0x03],
  "SYNC_DATA": [0x01, 0x04],

  //
  "TIMESTAMP": [0x02, 0x00],
  "OPEN_TIME": [0x02, 0x01],
  "WATERING_TIME": [0x02, 0x02],
  "RESTING_TIME": [0x02, 0x03],
  'VALVE_ACTIVATION': [0x02, 0x04],
  //testing
  'TEST1': [0x09, 0x00],
  'TEST2': [0x09, 0x01],
};

class BleFuncs {
  static BleFuncs _instance = BleFuncs();
  static BleFuncs get instance => _instance;

  BluetoothDevice? device;
  BluetoothCharacteristic? characteristic;
  StreamSubscription? deviceService;
  StreamSubscription? deviceCharacteristic;

  void readListener(List<int> v) {
    if (v.isNotEmpty) {
      List<int> cmd = [v[0], v[1]];

      if (listEquals([v[0], v[1]], Protocol['SYNC_DATA'])) {
        Map<String, int> data = {
          'valveCnt': v[3],
          'usingValveCnt': v[4],
          'workingUnitTime': v[5],
          'wateringTime': v[6],
          'restingTime': v[7],
          'timeCheckingTime': v[8],
          'startHour': v[9],
          'startMinute': v[10],
          'endHour': v[11],
          'endMinute': v[12],
          'valveActivation': v[13],
        };
        Setting.instatnce.setSetting(data);
      }
    }
  }

  void actionAfterConnection() async {
    await BleFuncs.instance.sendBigSize('TIMESTAMP',
        [DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000.toInt()], 4);
    await BleFuncs.instance.read('SYNC_DATA', []);
  }

  void initDevice(BluetoothDevice device) {
    deviceService = device.services.listen((services) {
      services.forEach((s) {
        if (s.uuid.toString() == serviceUUID) {
          s.characteristics.forEach((c) {
            if (c.uuid.toString() == characteristicUUID) {
              print('characteristic - $c');
              BleFuncs.instance.characteristic = c;
              deviceCharacteristic = BleFuncs.instance.characteristic!.value
                  .listen((v) => BleFuncs.instance.readListener(v));
              actionAfterConnection();
            }
          });
        }
      });
    });

    device.discoverServices();
  }

  void dispose() {
    deviceService!.cancel();
    deviceCharacteristic!.cancel();
  }

  Future<void> send(String cmd, List<int> vals) async {
    print('send - $cmd, ${vals.length}, $vals');
    try {
      await characteristic?.write([...Protocol[cmd]!, vals.length, ...vals]);
    } catch (e) {
      print('write fail - $cmd, $vals, $e');
    }
    print('write  - $cmd, $vals');
  }

  Future<void> read(String cmd, List<int> vals) async {
    print('read - $cmd, ${vals.length}, $vals');
    await send(cmd, vals);
    try {
      await characteristic?.read();
    } catch (e) {
      print('read fail - $cmd, $vals, $e');
    }
    print('read - $cmd, $vals');
  }

  Future<void> sendBigSize(String cmd, List<int> vals, int byteSz) async {
    print('sendBigsize - $cmd, $vals');
    List<int> data = [];
    for (int i = 0; i < vals.length; i++) {
      for (int k = 0; k < byteSz; k++) {
        data.add((vals[i] >> (k * 8)) & 0xFF);
      }
    }
    try {
      await characteristic?.write([...Protocol[cmd]!, data.length, ...data]);
    } catch (e) {
      print('write fail - $cmd, $data, $e');
    }
    print('write  - $cmd, ${data.length}, $data');
  }
}
