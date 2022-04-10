import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:time_range_picker/time_range_picker.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:watering/blefuncs.dart';
import 'package:flutter_switch/flutter_switch.dart';

class Setting {
  static Setting _instance = Setting();
  static Setting get instatnce => _instance;
  int valveCnt = 0;
  int usingValveCnt = 0;
  int workingUnitTime = 0;
  int wateringTime = 0;
  int restingTime = 0;
  int timeCheckingTime = 0;

  int startHour = 0;
  int startMinute = 0;
  int endHour = 0;
  int endMinute = 0;

  List<bool> valveActivation = [true, true, true, true];

  void setSetting(Map<String, int> vals) {
    valveCnt = vals['valveCnt'] as int;
    usingValveCnt = vals['usingValveCnt'] as int;
    workingUnitTime = vals['workingUnitTime'] as int;

    wateringTime = vals['wateringTime'] as int;
    restingTime = vals['restingTime'] as int;
    timeCheckingTime = vals['timeCheckingTime'] as int;
    startHour = vals['startHour'] as int;
    startMinute = vals['startMinute'] as int;
    endHour = vals['endHour'] as int;
    endMinute = vals['endMinute'] as int;
    int val = vals['valveActivation'] as int;

    for (int i = 0; i < valveCnt; i++) {
      valveActivation[i] = intToBool((val >> i) & 1);
    }
  }
}

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool currentState = false;

  List<bool> availableSwtich = [true, true, true, true];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('watering '),
        actions: [],
      ),
      body: StreamBuilder<List<BluetoothDevice>>(
        initialData: [],
        stream: Stream.periodic(Duration(milliseconds: 1000))
            .asyncMap((_) => FlutterBlue.instance.connectedDevices),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return SingleChildScrollView(
              child: Container(
                child: Center(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            "설정 변경후 재시작시 반영",
                            style: TextStyle(fontSize: 15),
                          ),
                        ],
                      ),
                      Text(
                        '물 주는 시간 (1 ~ 100분)',
                        style: TextStyle(
                            fontSize: 30.0, fontWeight: FontWeight.bold),
                      ),
                      Text('${Setting.instatnce.wateringTime} 분'),
                      NumberPicker(
                        value: Setting.instatnce.wateringTime,
                        axis: Axis.horizontal,
                        minValue: 1,
                        maxValue: 100,
                        onChanged: (value) => {
                          BleFuncs.instance
                              .writeBigSize('WATERING_TIME', [value], 2),
                          setState(
                              () => Setting.instatnce.wateringTime = value),
                        },
                      ),
                      Divider(
                        height: 30.0,
                        color: Colors.grey[800],
                      ),
                      Text(
                        '쉬는 시간 ( 1 ~ 1000분)',
                        style: TextStyle(
                            fontSize: 30.0, fontWeight: FontWeight.bold),
                      ),
                      Text('${Setting.instatnce.restingTime} 분'),
                      NumberPicker(
                        value: Setting.instatnce.restingTime,
                        axis: Axis.horizontal,
                        minValue: 1,
                        maxValue: 1000,
                        //step: 30,
                        step: 1,
                        onChanged: (value) => {
                          BleFuncs.instance
                              .writeBigSize('RESTING_TIME', [value], 2),
                          setState(() => Setting.instatnce.restingTime = value)
                        },
                      ),
                      Divider(
                        height: 30.0,
                        color: Colors.grey[800],
                      ),

                      Text(
                        '하루 중 물주기 시작 시간',
                        style: TextStyle(
                            fontSize: 30.0, fontWeight: FontWeight.bold),
                      ),
                      Text(
                          '${Setting.instatnce.startHour}:${Setting.instatnce.startMinute} ~ ${Setting.instatnce.endHour}: ${Setting.instatnce.endMinute}'),
                      ElevatedButton(
                        child: Text("변경"),
                        onPressed: () async {
                          try {
                            TimeRange result = await showTimeRangePicker(
                              context: context,
                              start: TimeOfDay(
                                  hour: Setting.instatnce.startHour,
                                  minute: Setting.instatnce.startMinute),
                              end: TimeOfDay(
                                  hour: Setting.instatnce.endHour,
                                  minute: Setting.instatnce.endMinute),
                              paintingStyle: PaintingStyle.fill,
                              backgroundColor: Colors.grey.withOpacity(0.2),
                              ticks: 8,
                              use24HourFormat: true,
                              strokeColor: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.5),
                              ticksColor: Theme.of(context).primaryColor,
                              labelOffset: 0,
                              padding: 60,
                              clockRotation: 180,
                            );
                            setState(() {
                              Setting.instatnce.startHour =
                                  result.startTime.hour;
                              Setting.instatnce.startMinute =
                                  result.startTime.minute;
                              Setting.instatnce.endHour = result.endTime.hour;
                              Setting.instatnce.endMinute =
                                  result.endTime.minute;
                              BleFuncs.instance.write('OPEN_TIME', [
                                Setting.instatnce.startHour,
                                Setting.instatnce.startMinute,
                                Setting.instatnce.endHour,
                                Setting.instatnce.endMinute
                              ]);
                            });
                          } catch (e) {}
                          // print(openStartHour);
                        },
                      ),
                      Divider(
                        height: 30.0,
                        color: Colors.grey[800],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              Text(
                                '#1',
                                style: TextStyle(fontSize: 30.0),
                              ),
                              FlutterSwitch(
                                value: Setting.instatnce.valveActivation[0],
                                onToggle: (v) {
                                  Setting.instatnce.valveActivation[0] = v;

                                  BleFuncs.instance.write(
                                      'VALVE_ACTIVATION', [0, boolToInt(v)]);
                                },
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                '#2',
                                style: TextStyle(fontSize: 30.0),
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                              FlutterSwitch(
                                value: Setting.instatnce.valveActivation[1],
                                onToggle: (v) {
                                  Setting.instatnce.valveActivation[1] = v;
                                  BleFuncs.instance.write(
                                      'VALVE_ACTIVATION', [1, boolToInt(v)]);
                                },
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                '#3',
                                style: TextStyle(fontSize: 30.0),
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                              FlutterSwitch(
                                value: Setting.instatnce.valveActivation[2],
                                onToggle: (v) {
                                  Setting.instatnce.valveActivation[2] = v;
                                  BleFuncs.instance.write(
                                      'VALVE_ACTIVATION', [2, boolToInt(v)]);
                                },
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                '#4',
                                style: TextStyle(fontSize: 30.0),
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                              FlutterSwitch(
                                value: Setting.instatnce.valveActivation[3],
                                onToggle: (v) {
                                  Setting.instatnce.valveActivation[3] = v;
                                  BleFuncs.instance.write(
                                      'VALVE_ACTIVATION', [3, boolToInt(v)]);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),

                      Divider(
                        height: 30.0,
                        color: Colors.grey[800],
                      ),
                      Text(
                        '테스트',
                        style: TextStyle(
                            fontSize: 30.0, fontWeight: FontWeight.bold),
                      ),
                      // currentStateText(currentState),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              // currentState = true;
                              BleFuncs.instance.write('START', []);
                            },
                            child: Text('시작'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              // currentState = false;
                              BleFuncs.instance.write('STOP', []);
                            },
                            child: Text('멈춤'),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              BleFuncs.instance.write('TEST1', []);
                            },
                            child: Text('빠른 테스트'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              BleFuncs.instance.write('TEST2', []);
                            },
                            child: Text('빠른 테스트 멈춤'),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {
                          BleFuncs.instance.write('RESET', []);
                        },
                        child: Text('reset setting'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else {
            return CircularProgressIndicator();
          }
        },
      ),
    );
  }
}

Text currentStateText(bool state) {
  Text ret;
  if (state) {
    ret = Text('woking', style: TextStyle(color: Colors.green));
  } else
    ret = Text('not woking', style: TextStyle(color: Colors.red));

  return ret;
}

// Widget switchOnOff(int idx, bool state) {
//   return
// }

int boolToInt(bool v) {
  int ret = 0;

  if (v == true) {
    ret = 1;
  }
  return ret;
}

bool intToBool(int v) {
  bool ret = false;

  if (v >= 1) {
    ret = true;
  }

  return ret;
}
