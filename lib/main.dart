import 'dart:async';

import 'package:flutter/material.dart';
import 'package:time_range_picker/time_range_picker.dart';
import 'package:numberpicker/numberpicker.dart';

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
                onChanged: (value) => {
                  print(value),
                  print(wateringTime),
                  setState(() => wateringTime = value)
                },
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

//  Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Column(
//                     children: [
//                       Text(
//                         'open time',
//                         style: TextStyle(
//                             fontSize: 30.0, fontWeight: FontWeight.bold),
//                       ),
//                       Text(
//                           '$openStartHour:$openStartMinute ~ $openEndHour: $openEndMinute'),
//                     ],
//                   ),
//                   ElevatedButton(
//                     child: Text("change"),
//                     onPressed: () async {
//                       try {
//                         TimeRange result = await showTimeRangePicker(
//                           context: context,
//                           paintingStyle: PaintingStyle.fill,
//                           backgroundColor: Colors.grey.withOpacity(0.2),
//                           ticks: 8,
//                           use24HourFormat: true,
//                           strokeColor:
//                               Theme.of(context).primaryColor.withOpacity(0.5),
//                           ticksColor: Theme.of(context).primaryColor,
//                           labelOffset: 0,
//                           padding: 60,
//                           clockRotation: 180,
//                         );
//                         setState(() {
//                           openStartHour = result.startTime.hour;
//                           openStartMinute = result.startTime.minute;
//                           openEndHour = result.endTime.hour;
//                           openEndMinute = result.endTime.minute;
//                         });
//                       } catch (e) {}
//                       print(openStartHour);
//                     },
//                   ),
//                 ],
//               ),
//               SizedBox(
//                 height: 20.0,
//               ),
///Returns AlertDialog as a Widget so it is designed to be used in showDialog method
class NumberPickerDialog extends StatefulWidget {
  final int minValue;
  final int maxValue;
  final int initialIntegerValue;
  final double initialDoubleValue;
  final int decimalPlaces;
  final Widget title;
  final EdgeInsets titlePadding;
  final Widget confirmWidget;
  final Widget cancelWidget;

  ///constructor for integer values
  NumberPickerDialog({
    required this.minValue,
    required this.maxValue,
    required this.initialIntegerValue,
    required this.title,
    required this.titlePadding,
    required Widget confirmWidget,
    required Widget cancelWidget,
  })  : confirmWidget = new Text("OK"),
        cancelWidget = new Text("CANCEL"),
        decimalPlaces = 0,
        initialDoubleValue = -1.0;

  // ///constructor for decimal values
  // NumberPickerDialog.decimal({
  //   required this.minValue,
  //   required this.maxValue,
  //   required this.initialDoubleValue,
  //   this.decimalPlaces = 1,
  //   required this.title,
  //   required this.titlePadding,
  //   required Widget confirmWidget,
  //   required Widget cancelWidget,
  // })  : confirmWidget = new Text("OK"),
  //       cancelWidget = new Text("CANCEL"),
  //       initialIntegerValue = -1;

  @override
  State<NumberPickerDialog> createState() =>
      new _NumberPickerDialogControllerState(
          initialIntegerValue, initialDoubleValue);
}

class _NumberPickerDialogControllerState extends State<NumberPickerDialog> {
  int selectedIntValue;
  double selectedDoubleValue;

  _NumberPickerDialogControllerState(
      this.selectedIntValue, this.selectedDoubleValue);

  _handleValueChanged(int value) {
    setState(() => selectedIntValue = value);
  }

  NumberPicker _buildNumberPicker() {
    return new NumberPicker(
      // initialValue: selectedDoubleValue,
      minValue: widget.minValue,
      maxValue: widget.maxValue,
      // decimalPlaces: widget.decimalPlaces,
      onChanged: _handleValueChanged, value: 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return new AlertDialog(
      title: widget.title,
      titlePadding: widget.titlePadding,
      content: _buildNumberPicker(),
      actions: [
        new FlatButton(
          onPressed: () => Navigator.of(context).pop(),
          child: widget.cancelWidget,
        ),
        new FlatButton(
            onPressed: () => Navigator.of(context).pop(widget.decimalPlaces > 0
                ? selectedDoubleValue
                : selectedIntValue),
            child: widget.confirmWidget),
      ],
    );
  }
}
