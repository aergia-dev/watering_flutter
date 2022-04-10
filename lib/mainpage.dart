import 'package:flutter/material.dart';
import 'package:watering/settingPage.dart';
import 'package:watering/blefuncs.dart';
import 'lifecycle_manager.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    BleFuncs.instance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(".."),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (_) => SettingPage()));
              },
              icon: Icon(Icons.settings))
        ],
      ),
      body: StreamBuilder<bool>(
        stream: BleFuncs.instance.ready!.stream,
        initialData: false,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data == true) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(30.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          StreamBuilder<Map<String, String>>(
                            stream:
                                BleFuncs.instance.notificationStream!.stream,
                            initialData: {},
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return Column(
                                  children: [
                                    Text(
                                        '현재 상태: ${snapshot.data!['state'].toString()}'),
                                    Text(
                                        '지난 시간: ${snapshot.data!['passed_time'].toString()}분'),
                                    Text(
                                        '설정된 시간: ${snapshot.data!['set_time'].toString()}분'),
                                    Text(
                                        '동작 가능 시간: ${snapshot.data!['is_working_time'].toString()}'),
                                    Text(
                                        '현재 동작 밸브: #${snapshot.data!['current_working_valve'].toString()}'),
                                  ],
                                );
                              }

                              return Text('준비 중');
                            },
                          ),
                          Text(
                            "하루 중 동작 시간",
                            style: TextStyle(fontSize: 30),
                          ),
                          Text(
                            BleFuncs.instance.makeWorkingTimeStr(),
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),

                      SizedBox(
                        height: 60,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            height: 150,
                            width: 150,
                            child: ElevatedButton(
                                onPressed: () {
                                  BleFuncs.instance.write('START', []);
                                },
                                child:
                                    Text("시작", style: TextStyle(fontSize: 60)),
                                style: ElevatedButton.styleFrom(
                                    shape: CircleBorder(),
                                    primary: Colors.green[200])),
                          ),
                          SizedBox(
                            height: 150,
                            width: 150,
                            child: ElevatedButton(
                                onPressed: () {
                                  BleFuncs.instance.write('STOP', []);
                                },
                                child:
                                    Text("멈춤", style: TextStyle(fontSize: 60)),
                                style: ElevatedButton.styleFrom(
                                    shape: CircleBorder(),
                                    primary: Colors.red[200])),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      // ElevatedButton(
                      //   onPressed: () {
                      //     BleFuncs.instance.testNoti(true);
                      //   },
                      //   child: Text("notify"),
                      // ),
                      // ElevatedButton(
                      //   onPressed: () {
                      //     BleFuncs.instance.testNoti(false);
                      //   },
                      //   child: Text("notify off"),
                      // ),
                    ],
                  ),
                ),
              );
              // Text(
              //   BleFuncs.instance.makeWorkingTimeStr(),
              //   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              // );
            } else
              return Text('loading');
          } else
            return Text('');
        },
      ),
    );
  }
}
