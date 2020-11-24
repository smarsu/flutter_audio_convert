import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_audio_convert/flutter_audio_convert.dart';

void main() {
  runApp(MyApp());
}

Future<String> loadAsset(asset, local, {package}) async {
  var bytes = await rootBundle.load(asset);
  var path = await appDocPath(local);
  File(path).writeAsBytesSync(bytes.buffer.asUint8List());
  return path;
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    run();
  }

  run() async {
    String path1 = await loadAsset('assets/cat.mp4', 'cat.mp4');
    await toM4A(path1);
    await toVolume(path1);
    print('assets/cat.mp4 duration ... ${await toDuration(path1)}');
    String path2 = await loadAsset('assets/seeyou.mp4', 'seeyou.mp4');
    await toM4A(path2);
    await toVolume(path2);
    print('assets/seeyou.mp4 duration ... ${await toDuration(path2)}');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('Running on: $_platformVersion\n'),
        ),
      ),
    );
  }
}
