// import 'package:flutter/widgets.dart';

// class LifecycleWatcher extends StatefulWidget {
//   @override
//   _LifecycleWatcherState createState() => _LifecycleWatcherState();
// }

// class _LifecycleWatcherState extends State<LifecycleWatcher>
//     with WidgetsBindingObserver {
//   AppLifecycleState? _lastLifecycleState;
//   // final FutureVoidCallback resumeCallBack;
//   // final FutureVoidCallback detachedCallBack;
//   // late final Widget child;
//   late Widget child;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance!.addObserver(this);
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance!.removeObserver(this);
//     super.dispose();
//   }

//   @override
//   Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
//     switch (state) {
//       case AppLifecycleState.inactive:
//       case AppLifecycleState.paused:
//       case AppLifecycleState.detached:
//         // await detachedCallBack();
//         break;
//       case AppLifecycleState.resumed:
//         // await resumeCallBack();
//         break;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return widget.child;
//   }
// }
