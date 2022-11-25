import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterBackgroundService.initialize(onServiceStart);
  runApp(MyApp());
}

onServiceStart() {
  WidgetsFlutterBinding.ensureInitialized();
  final service = FlutterBackgroundService();

  Timer? timer;
  service.onDataReceived.listen((event) {
    if (event!["action"] == "startTimer") {
      timer = Timer.periodic(Duration(seconds: 1), (t) {
        print(t.tick.toInt());
        service.sendData(
          {"timer": t.tick.toInt()},
        );
      });
    }

    if (event["action"] == "stopTimer" && timer != null) {
      timer?.cancel();
    }
  });
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  String text = "Stop Service";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print("stete = $state");//状態を詳しく出す
    switch (state) {
      case AppLifecycleState.inactive:
        print('非アクティブになったときの処理');
        break;
      case AppLifecycleState.paused:
        print('停止されたときの処理');
        break;
      case AppLifecycleState.resumed:
        print('再開されたときの処理');
        break;
      case AppLifecycleState.detached:
        print('破棄されたときの処理');
        break;
    }
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Service App'),
        ),
        body: Column(
          children: [
            StreamBuilder<Map<String, dynamic>?>(
              stream: FlutterBackgroundService().onDataReceived,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                final data = snapshot.data!;
                return Center(
                  child: Text(
                    data.values.toString(),
                    style: TextStyle(
                      fontSize: 36,
                    ),
                  ),
                );
              },
            ),
            ElevatedButton(
                child: Text("Start Timer"),
                onPressed: () {
                  FlutterBackgroundService().sendData({"action": "startTimer"});
                }),
            ElevatedButton(
                child: Text("Stop Timer"),
                onPressed: () {
                  FlutterBackgroundService().sendData({"action": "stopTimer"});
                }),
          ],
        ),
      ),
    );
  }
}