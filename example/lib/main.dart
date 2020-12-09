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
    while (true) {
      await AudioConvert.initialized;

      String path1 = await loadAsset('assets/cat.mp4', 'cat.mp4');
      await AudioConvert.toM4AAsync(path1);

      await AudioConvert.toVolumeAsync(path1);

      await toDuration(path1);

      await AudioConvert.toCutAsync(path1, 1000, 2000);

      String path2 = await loadAsset('assets/seeyou.mp4', 'seeyou.mp4');
      await AudioConvert.toM4AAsync(path2);

      await AudioConvert.toVolumeAsync(path2);

      await toDuration(path2);

      await AudioConvert.toCutAsync(path2, 1000, 2000);

      String path3 = await loadAsset('assets/1Min.mp4', '1Min.mp4');
      await toDuration(path3);

      // thumbImages = await AudioConvert.toThumbnailAsync(path3, [0, 1000, -10, 60000, 0, 700000, 6000000, 600000]);
      thumbImages = await AudioConvert.toThumbnailAsync(path3, [0, 300, 600, 900, 1200, 1500, 1800, 2100]);

      var t1 = DateTime.now().millisecondsSinceEpoch;
      double score = sentenceSimilarity('我是范峰源', '你是范峰源');
      var t2 = DateTime.now().millisecondsSinceEpoch;
      print('score ... $score, t ... ${t2 - t1}ms');

      setState(() {});
    }
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
