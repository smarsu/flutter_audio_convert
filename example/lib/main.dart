import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_audio_convert/flutter_audio_convert.dart';
import 'package:flutter_audio_convert/isolate.dart';

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
  List<String> thumbImages = [];

  @override
  void initState() {
    super.initState();
    run();
  }

  run() async {
    await AudioConvert.initialized;

    String path1 = await loadAsset('assets/cat.mp4', 'cat.mp4');
    await toM4A(path1);
    // Future.delayed(Duration(seconds: 1));
    await toVolume(path1);
    // Future.delayed(Duration(seconds: 1));
    // await toDuration(path1);
    // Future.delayed(Duration(seconds: 1));
    await toCut(path1, 1000, 2000);
    // Future.delayed(Duration(seconds: 1));
    String path2 = await loadAsset('assets/seeyou.mp4', 'seeyou.mp4');
    await toM4A(path2);
    // Future.delayed(Duration(seconds: 1));
    await toVolume(path2);
    // Future.delayed(Duration(seconds: 1));
    // await toDuration(path2);
    // Future.delayed(Duration(seconds: 1));
    await toCut(path2, 1000, 2000);
    // Future.delayed(Duration(seconds: 1));
    String path3 = await loadAsset('assets/16Min.mp4', '16Min.mp4');
    await toDuration(path3);
    // Future.delayed(Duration(seconds: 1));
    thumbImages = await toThumbnail(path3, [0, 1000, -10, 60000, 0, 700000, 6000000, 600000]);
    // Future.delayed(Duration(seconds: 1));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        // body: Center(
        //   child: Text('Running on: $_platformVersion\n'),
        // ),
        body: ListView(
          children: List.generate(thumbImages.length, (index) {
            return Image.file(
              File(thumbImages[index]),
            );
          }),
        ),
      ),
    );
  }
}
