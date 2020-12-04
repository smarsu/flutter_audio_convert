import 'dart:io';
import 'dart:isolate';

import 'package:flutter_audio_convert/flutter_audio_convert.dart';

class AudioConvert {
  /* Public */
  static Future<void> initialized = _init();

  static Future<String> toM4AAsync(String input, {String output, String extend='mp4'}) async {
    await initialized;

    if (output == null) {
      output = await appDocPath('${DateTime.now().microsecondsSinceEpoch}.$extend');
    }

    ReceivePort receivePort = ReceivePort();
    // _toM4ASendPort.send([receivePort.sendPort, input, output, extend]);
    _audioConvertSendPort.send([receivePort.sendPort, 'toM4a', input, output, extend]);
    return await receivePort.first;
  }

  static Future<String> toVolumeAsync(String input, {String output, double volume=-10, String extend='mp4'}) async {
    await initialized;

    if (output == null) {
      output = await appDocPath('${DateTime.now().microsecondsSinceEpoch}.$extend');
    }

    ReceivePort receivePort = ReceivePort();
    // _toVolumeSendPort.send([receivePort.sendPort, input, output, volume, extend]);
    _audioConvertSendPort.send([receivePort.sendPort, 'toVolume', input, output, volume, extend]);
    return await receivePort.first;
  }

  // threshold [0 - double.infinity]: 越低 图片定位越准
  static Future<List<String>> toThumbnailAsync(String input, List<double> timesInMs, {List<String> outputs, int width=0, int height=0, double threshold=double.infinity}) async {
    await initialized;

    if (outputs == null) {
      outputs = [];
      for (var time in timesInMs) {
        String output = await appDocPath('${DateTime.now().microsecondsSinceEpoch}_$time.jpg');
        outputs.add(output);
      }
    }

    ReceivePort receivePort = ReceivePort();
    // _toThumbnailSendPort.send([receivePort.sendPort, input, timesInMs, outputs, width, height, threshold]);
    _audioConvertSendPort.send([receivePort.sendPort, 'toThumbnail', input, timesInMs, outputs, width, height, threshold]);
    return await receivePort.first;
  }

  static Future<String> toCutAsync(String input, double startMs, double endMs, {String output, String extend='mp4'}) async {
    await initialized;

    if (output == null) {
      output = await appDocPath('${DateTime.now().microsecondsSinceEpoch}.$extend');
    }

    ReceivePort receivePort = ReceivePort();
    // _toCutSendPort.send([receivePort.sendPort, input, startMs, endMs, output, extend]);
    _audioConvertSendPort.send([receivePort.sendPort, 'toCut', input, startMs, endMs, output, extend]);
    return await receivePort.first;
  }

  /* Private */

  static SendPort _audioConvertSendPort;
  // static SendPort _toM4ASendPort;
  // static SendPort _toCutSendPort;
  // static SendPort _toVolumeSendPort;
  // static SendPort _toThumbnailSendPort;
  static Future<void> _init() async {
    String dir = await appDocPath('');
    Directory directory = Directory(dir);
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
    await directory.create(recursive: true);

    final receivePort = ReceivePort();
    await Isolate.spawn(_audioConvertEntryFunction, receivePort.sendPort);
    _audioConvertSendPort = await receivePort.first;

    // // 1. Init ToM4A
    // {
    //   final toM4AReceive = ReceivePort();
    //   await Isolate.spawn(_toM4AEntryFunction, toM4AReceive.sendPort);
    //   _toM4ASendPort = await toM4AReceive.first;
    // }

    // // 2. Init ToCut
    // {
    //   final toCutReceive = ReceivePort();
    //   await Isolate.spawn(_toCutEntryFunction, toCutReceive.sendPort);
    //   _toCutSendPort = await toCutReceive.first;
    // }

    // // 3. Init ToVolume
    // {
    //   final toVolumeReceive = ReceivePort();
    //   await Isolate.spawn(_toThumbnailEntryFunction, toVolumeReceive.sendPort);
    //   _toThumbnailSendPort = await toVolumeReceive.first;
    // }

    // // 4. Init Thumbnail
    // {
    //   final toThumbnailReceive = ReceivePort();
    //   await Isolate.spawn(_toVolumeEntryFunction, toThumbnailReceive.sendPort);
    //   _toVolumeSendPort = await toThumbnailReceive.first;
    // }

    print('AudioConvert Init Success!');
  }

  static void _audioConvertEntryFunction(SendPort sendPort) async {
    ReceivePort receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);

    await for (var msg in receivePort) {
      SendPort callbackPort = msg[0];
      String mod = msg[1];

      if (mod == 'toM4a') {
        String result = await toM4A(msg[2], output: msg[3], extend: msg[4]);
        callbackPort.send(result);
      }
      else if (mod == 'toVolume') {
        String result = await toVolume(msg[2], output: msg[3], volume: msg[4], extend: msg[5]);
        callbackPort.send(result);
      }
      else if (mod == 'toCut') {
        String result = await toCut(msg[2], msg[3], msg[4], output: msg[5], extend: msg[6]);
        callbackPort.send(result);
      }
      else if (mod == 'toThumbnail') {
        List<String> result = await toThumbnail(msg[2], msg[3], outputs: msg[4], width: msg[5], height: msg[6], threshold: msg[7]);
        callbackPort.send(result);
      }
    }
  }

  static void _toM4AEntryFunction(SendPort sendPort) async {
    ReceivePort receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);

    await for (var msg in receivePort) {
      SendPort callbackPort = msg[0];
      String input = msg[1];
      String output = msg[2];
      String extend = msg[3];

      String result = await toM4A(input, output: output, extend: extend);
      callbackPort.send(result);
    }
  }

  static void _toVolumeEntryFunction(SendPort sendPort) async {
    ReceivePort receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);

    await for (var msg in receivePort) {
      SendPort callbackPort = msg[0];
      String input = msg[1];
      String output = msg[2];
      double volume = msg[3];
      String extend = msg[4];

      String result = await toVolume(input, output: output, volume: volume, extend: extend);
      callbackPort.send(result);
    }
  }



  static void _toCutEntryFunction(SendPort sendPort) async {
    ReceivePort receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);

    await for (var msg in receivePort) {
      SendPort callbackPort = msg[0];
      String input = msg[1];
      double startMs = msg[2];
      double endMs = msg[3];
      String output = msg[4];
      String extend = msg[5];

      String result = await toCut(input, startMs, endMs, output: output, extend: extend);
      callbackPort.send(result);
    }
  }

  static void _toThumbnailEntryFunction(SendPort sendPort) async {
    ReceivePort receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);

    await for (var msg in receivePort) {
      SendPort callbackPort = msg[0];
      String input = msg[1];
      List<double> timesInMs = msg[2];
      List<String> outputs = msg[3];
      int width = msg[4];
      int height = msg[5];
      double threshold = msg[6];

      List<String> result = await toThumbnail(input, timesInMs, outputs: outputs, width: width, height: height, threshold: threshold);
      callbackPort.send(result);
    }
  }
}
