import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:watering/settingPage.dart';
import 'package:synchronized/synchronized.dart';

const String serviceUUID = "000000ff-0000-1000-8000-00805f9b34fb";
const String rwUUID = "0000ff01-0000-1000-8000-00805f9b34fb";

const String serviceUUID2 = "000000ee-0000-1000-8000-00805f9b34fb";
// const String writeUUID = "0000ff02-0000-1000-8000-00805f9b34fb";
const String notifyUUID = "0000ee01-0000-1000-8000-00805f9b34fb";

const Map<String, List<int>> Protocol = {
  "POWER_ON": [0x01, 0x00],
  "POWER_OFF": [0x01, 0x01],
  "START": [0x01, 0x02],
  "STOP": [0x01, 0x03],
  "SYNC_DATA": [0x01, 0x04],
  "RESET": [0x01, 0x05],
  //
  "TIMESTAMP": [0x02, 0x00],
  "OPEN_TIME": [0x02, 0x01],
  "WATERING_TIME": [0x02, 0x02],
  "RESTING_TIME": [0x02, 0x03],
  'VALVE_ACTIVATION': [0x02, 0x04],
  'STATE': [0x02, 0x05],
  //testing
  'TEST1': [0x09, 0x00],
  'TEST2': [0x09, 0x01],
};

class BleFuncs {
  static BleFuncs _instance = BleFuncs();
  static BleFuncs get instance => _instance;
  Queue<List<int>> cmds = new Queue<List<int>>();

  StreamController<bool>? ready; // = StreamController<bool>();
  StreamController<Map<String, String>>? notificationStream;
  // StreamController<String>? deviceState;
  StreamSubscription<BluetoothDeviceState>? deviceState;

  BluetoothDevice? device;
  // BluetoothCharacteristic? characteristic;

  BluetoothCharacteristic? rwCharacteristic;
  // BluetoothCharacteristic? writeCharacteristic;
  BluetoothCharacteristic? notifyCharacteristic;

  StreamSubscription? deviceService;
  StreamSubscription? rwCharacteristicListener;
  StreamSubscription? readCharStream;
  StreamSubscription? notifyCharStream;

  bool _stopTimer = false;
  bool finishLoop = false;
  Map<String, int>? data;

  String makeWorkingTimeStr() {
    return '${data!['startHour'].toString()}시 ${data!['startMinute'].toString()}분 ~ ${data!['endHour'].toString()}시 ${data!['endMinute'].toString()}분';
  }

  void notifyListener(List<int> v) {
    print('notify listener - $v');
    String state = "";
    switch (v[0]) {
      case 0:
        state = '동작 준비 완료';
        break;
      case 1:
        state = '물 주는 시간';
        break;
      case 2:
        state = '쉬는 시간';
        break;
      case 3:
        state = '동작 정지';
        break;
      case 4:
        state = '지정된 동작 시간 외';
        break;
    }

    String isWorkingTime = "";
    if (v[5] == 1)
      isWorkingTime = '동작 가능 시간임';
    else
      isWorkingTime = '동작 시간이 아님';

    String valveStr = "";
    if (v[6] == 99)
      valveStr = "None";
    else
      valveStr = v[6].toString();

    Map<String, String> noti = {
      'state': state,
      'passed_time': (v[1] | (v[2] << 8)).toString(),
      'set_time': (v[3] | (v[4] << 8)).toString(),
      'is_working_time': isWorkingTime,
      'current_working_valve': valveStr,
    };
    notificationStream!.add(noti);
  }

  void readListener(List<int> v) {
    if (v.isNotEmpty) {
      List<int> cmd = [v[0], v[1]];

      if (listEquals([v[0], v[1]], Protocol['SYNC_DATA'])) {
        data = {
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
        Setting.instatnce.setSetting(data!);
        print("sync data ${data!}");
        ready!.add(true);
      }
    }
  }

  void actionAfterConnection() async {
    await read(
        'TIMESTAMP',
        fixedByteList(
            [DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000.toInt()],
            4));
    await read('SYNC_DATA', []);
    await notifyCharacteristic!.setNotifyValue(true);
  }

  // void cmdLoop() async {
  //   while (!finishLoop) {
  //     if (cmds.isNotEmpty) {
  //       List<int> cmd = cmds.removeFirst();

  //       bool ret = false;
  //       int t = cmd.removeAt(0);
  //       switch (t) {
  //         case 0:
  //           ret = await write(cmd);
  //           break;
  //         case 1:
  //           ret = await read(cmd);
  //           break;
  //       }
  //     }
  //     await Future.delayed(Duration(milliseconds: 50));
  //   }
  // }

  void testNoti(bool v) async {
    await notifyCharacteristic!.setNotifyValue(v);
    print("set notify");
  }

  void initDevice(BluetoothDevice dev) async {
    _stopTimer = false;
    finishLoop = false;
    // cmdLoop();
    ready = new StreamController<bool>();
    notificationStream = new StreamController<Map<String, String>>();

    deviceService = dev.services.listen((services) async {
      for (BluetoothService s in services) {
        for (BluetoothCharacteristic c in s.characteristics) {
          if (c.uuid.toString() == rwUUID) {
            print('set read');
            rwCharacteristic = c;
            readCharStream =
                rwCharacteristic!.value.listen((v) => readListener(v));
          }
          if (c.uuid.toString() == notifyUUID) {
            print('set notify');

            notifyCharacteristic = c;
            notifyCharStream =
                notifyCharacteristic!.value.listen((v) => notifyListener(v));
          }

          if (rwCharacteristic != null && notifyCharacteristic != null) {
            actionAfterConnection();
          }
        }
      }
    });
    await dev.discoverServices();
  }

  void dispose() async {
    // deviceState!.close();
    cmds.clear();
    ready!.close();
    deviceService!.cancel();
    _stopTimer = true;
    finishLoop = true;
    await notifyCharacteristic!.setNotifyValue(false);

    readCharStream!.cancel();
    notifyCharStream!.cancel();
    rwCharacteristic = null;
    notifyCharacteristic = null;
  }

  Future<bool> write(String cmd, List<int> vals) async {
    bool ret = true;
    print('send -  $vals');
    try {
      await rwCharacteristic?.write([...Protocol[cmd]!, vals.length, ...vals]);
    } catch (e) {
      print('write fail - $vals, $e');
      ret = false;
    }
    return ret;
  }

  Future<bool> read(String cmd, List<int> vals) async {
    bool ret = true;
    print('read - $vals');
    await write(cmd, vals);
    try {
      await rwCharacteristic?.read();
    } catch (e) {
      print('read fail - $vals, $e');
      ret = false;
    }
    print('read - $vals');
    return ret;
  }

  void writeBigSize(String cmd, List<int> vals, int byteSz) {
    print('sendBigsize - $cmd, $vals');
    write(cmd, fixedByteList(vals, byteSz));
  }

  List<int> fixedByteList(List<int> vals, int byteSz) {
    List<int> data = [];
    for (int i = 0; i < vals.length; i++) {
      for (int k = 0; k < byteSz; k++) {
        data.add((vals[i] >> (k * 8)) & 0xFF);
      }
    }
    return data;
  }
}
