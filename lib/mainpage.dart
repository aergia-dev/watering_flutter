import 'package:flutter/material.dart';
import 'package:time_range_picker/time_range_picker.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:watering/mainpage.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int openStartHour = 0;
  int openStartMinute = 0;

  int openEndHour = 0;
  int openEndMinute = 0;

  int wateringTime = 33;
  int restingTime = 2;
  bool currentState = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('watering '),
        actions: [],
      ),
      body: Container(
        child: Center(
          child: Column(
            children: [
              Text(
                'watering time',
                style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
              ),
              Text('$wateringTime minutes'),
              NumberPicker(
                value: wateringTime,
                axis: Axis.horizontal,
                minValue: 0,
                maxValue: 100,
                onChanged: (value) => {setState(() => wateringTime = value)},
              ),
              Divider(
                height: 30.0,
                color: Colors.grey[800],
              ),
              // SizedBox(
              //   height: 20.0,
              // ),
              Text(
                'resting time',
                style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
              ),
              Text('$restingTime minutes'),
              NumberPicker(
                value: restingTime,
                axis: Axis.horizontal,
                minValue: 0,
                maxValue: 1000,
                //step: 30,
                step: 1,
                onChanged: (value) => {
                  print(value),
                  print(restingTime),
                  setState(() => restingTime = value)
                },
              ),
              Divider(
                height: 30.0,
                color: Colors.grey[800],
              ),

              Text(
                'open time',
                style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
              ),
              Text(
                  '$openStartHour:$openStartMinute ~ $openEndHour: $openEndMinute'),

              ElevatedButton(
                child: Text("change"),
                onPressed: () async {
                  try {
                    TimeRange result = await showTimeRangePicker(
                      context: context,
                      start: TimeOfDay(
                          hour: openStartHour, minute: openStartMinute),
                      end: TimeOfDay(hour: openEndHour, minute: openEndMinute),
                      paintingStyle: PaintingStyle.fill,
                      backgroundColor: Colors.grey.withOpacity(0.2),
                      ticks: 8,
                      use24HourFormat: true,
                      strokeColor:
                          Theme.of(context).primaryColor.withOpacity(0.5),
                      ticksColor: Theme.of(context).primaryColor,
                      labelOffset: 0,
                      padding: 60,
                      clockRotation: 180,
                    );
                    setState(() {
                      openStartHour = result.startTime.hour;
                      openStartMinute = result.startTime.minute;
                      openEndHour = result.endTime.hour;
                      openEndMinute = result.endTime.minute;
                    });
                  } catch (e) {}
                  print(openStartHour);
                },
              ),
              Divider(
                height: 30.0,
                color: Colors.grey[800],
              ),
              Text(
                'current state',
                style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
              ),
              currentStateText(currentState),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    child: Text('start'),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    child: Text('stop'),
                  ),
                ],
              )
            ],
          ),
        ),
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
