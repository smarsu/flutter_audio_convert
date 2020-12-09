// Copyright (c) 2020 smarsufan. All Rights Reserved.abstract

import 'dart:ffi';

import 'dart:io';

import 'package:flutter_c_ptr/flutter_c_ptr.dart';
import 'package:path_provider/path_provider.dart';

final DynamicLibrary _audioConvertLib = Platform.isAndroid
    ? DynamicLibrary.open("libaudio_convert.so")
    : DynamicLibrary.open("libaudio_convert.dylib");

final int Function(int, int) _audioConvertToM4A = 
    _audioConvertLib
        .lookup<NativeFunction<Int32 Function(Int64, Int64)>>("to_m4a")
        .asFunction();

final int Function(int, int, double) _audioConvertToVolume = 
    _audioConvertLib
        .lookup<NativeFunction<Int32 Function(Int64, Int64, Double)>>("to_volume")
        .asFunction();

final int Function(int) _audioConvertToDuration = 
    _audioConvertLib
        .lookup<NativeFunction<Int64 Function(Int64)>>("to_duration")
        .asFunction();

final int Function(int, int, int, int, int, int, double) _audioConvertToThumbnail = 
    _audioConvertLib
        .lookup<NativeFunction<Int32 Function(Int64, Int64, Int64, Int32, Int32, Int32, Double)>>("to_thumbnail")
        .asFunction();

final int Function(int, int, double, double) _audioConvertToCut =
    _audioConvertLib
        .lookup<NativeFunction<Int32 Function(Int64, Int64, Double, Double)>>("to_m4a_cut")
        .asFunction();

final double Function(int, int, int, int) _audioConvertSentenceSimilarity = 
    _audioConvertLib
        .lookup<NativeFunction<Float Function(Int64, Int32, Int64, Int32)>>("sentence_bleu")
        .asFunction();

int _lastErrRet = 0;

Map<String, dynamic> cache = {};

int getLastErrRet() {
  return _lastErrRet;
}

Future<String> appDocPath(path) async {
  var dir = (await getApplicationDocumentsDirectory()).path;
  return '$dir/smarsu_flutter_audio_convert/$path';
}

Future<String> toM4A(String input, {String output, String extend='mp4'}) async {
  String key = 'toM4A_${input}_${extend}';
  // if (cache.containsKey(key)) {
  //   return cache[key];
  // }

  if (output == null) {
    output = await appDocPath('${DateTime.now().microsecondsSinceEpoch}.$extend');
  }
  Int8P inputPtr = Int8P.fromString(input);
  Int8P outputPtr = Int8P.fromString(output);
  int convertRet = _audioConvertToM4A(inputPtr.address, outputPtr.address);
  inputPtr.dispose();
  outputPtr.dispose();
  print('In toM4A, convertRet ... $convertRet');
  _lastErrRet = convertRet;
  if (convertRet < 0) {
    // Failed
    cache[key] = input;
    return input;
  }
  else if (convertRet == 0) {
    // Success
    cache[key] = output;
    return output;
  }
  else if (convertRet == 1) {
    // The input is M4A format.
    cache[key] = input;
    return input;
  }
  cache[key] = output;
  return output;
}

Future<String> toVolume(String input, {String output, double volume=-10, String extend='mp4'}) async {
  String key = 'toVolume_${input}_${volume}_${extend}';
  // if (cache.containsKey(key)) {
  //   return cache[key];
  // }

  if (output == null) {
    output = await appDocPath('${DateTime.now().microsecondsSinceEpoch}.$extend');
  }
  Int8P inputPtr = Int8P.fromString(input);
  Int8P outputPtr = Int8P.fromString(output);
  int convertRet = _audioConvertToVolume(inputPtr.address, outputPtr.address, volume);
  inputPtr.dispose();
  outputPtr.dispose();
  print('In toVolume, convertRet ... $convertRet');
  _lastErrRet = convertRet;
  if (convertRet < 0) {
    // Failed
    cache[key] = input;
    return input;
  }
  else if (convertRet == 0) {
    // Success
    cache[key] = output;
    return output;
  }
  cache[key] = output;
  return output;
}

Future<int> toDuration(String input) async {
  String key = 'toDuration_${input}';
  // if (cache.containsKey(key)) {
  //   return cache[key];
  // }

  Int8P inputPtr = Int8P.fromString(input);
  int duration = _audioConvertToDuration(inputPtr.address);
  inputPtr.dispose();
  print('In toDuration, duration ... $duration');
  _lastErrRet = duration;
  if (duration < 0) {
    // Failed
    cache[key] = 0;
    return 0;
  }
  else {
    cache[key] = duration;
    return duration;
  }
}

Future<List<String>> toThumbnail(String input, List<double> timesInMs, {List<String> outputs, int width=0, int height=0, double threshold=double.infinity}) async {
  String key = 'toThumbnail_${input}_${timesInMs}_${width}_${height}_${threshold}';
  // if (cache.containsKey(key)) {
  //   return cache[key];
  // }

  List<Int8P> outputPtrs = [];
  List<int> outputAddress = [];
  // if (outputs == null) {
  //   outputs = [];
  //   for (var time in timesInMs) {
  //     String output = await appDocPath('${DateTime.now().microsecondsSinceEpoch}_$time.jpg');
  //     outputs.add(output);

  //     Int8P outputPtr = Int8P.fromString(output);
  //     outputPtrs.add(outputPtr);
  //     outputAddress.add(outputPtr.address);
  //   }
  // }
  if (outputs == null) {
    outputs = [];
    for (var time in timesInMs) {
      String output = await appDocPath('${DateTime.now().microsecondsSinceEpoch}_$time.jpg');
      outputs.add(output);
    }
  }
  for (int idx = 0; idx < outputs.length; ++idx) {
    String output = outputs[idx];
    Int8P outputPtr = Int8P.fromString(output);
    outputPtrs.add(outputPtr);
    outputAddress.add(outputPtr.address);
  }
  Int8P inputPtr = Int8P.fromString(input);
  Int64P outputAddressPtr = Int64P.fromList(outputAddress);
  DoubleP timesInMsPtr = DoubleP.fromList(timesInMs);

  int convertRet = _audioConvertToThumbnail(inputPtr.address, outputAddressPtr.address, timesInMsPtr.address, timesInMs.length, width, height, threshold);
  print('In toThumbnail, convertRet ... $convertRet');

  for (var outputPtr in outputPtrs) {
    outputPtr.dispose();
  }
  inputPtr.dispose();
  outputAddressPtr.dispose();
  timesInMsPtr.dispose();

  _lastErrRet = convertRet;

  cache[key] = outputs;
  return outputs;
}

Future<String> toCut(String input, double startMs, double endMs, {String output, String extend='mp4'}) async {
  String key = 'toCut_${input}_${extend}';
  // if (cache.containsKey(key)) {
  //   return cache[key];
  // }

  if (output == null) {
    output = await appDocPath('${DateTime.now().microsecondsSinceEpoch}.$extend');
  }
  Int8P inputPtr = Int8P.fromString(input);
  Int8P outputPtr = Int8P.fromString(output);
  int convertRet = _audioConvertToCut(inputPtr.address, outputPtr.address, startMs, endMs);
  inputPtr.dispose();
  outputPtr.dispose();
  print('In toCut, convertRet ... $convertRet');
  _lastErrRet = convertRet;
  if (convertRet < 0) {
    // Failed
    cache[key] = input;
    return input;
  }
  else if (convertRet == 0) {
    // Success
    cache[key] = output;
    return output;
  }
  else if (convertRet == 1) {
    // The input is M4A format.
    cache[key] = input;
    return input;
  }
  cache[key] = output;
  return output;
}

double sentenceSimilarity(String sentence1, String sentence2) {
  Map<String, int> idMap = {};
  int id = 0;
  for (int idx = 0; idx < sentence1.length; ++idx) {
    String char = sentence1[idx];
    if (!idMap.containsKey(char)) {
      // Not Found
      idMap[char] = ++id;
    }
  }

  for (int idx = 0; idx < sentence2.length; ++idx) {
    String char = sentence2[idx];
    if (!idMap.containsKey(char)) {
      // Not Found
      idMap[char] = ++id;
    }
  }

  List<int> ids1 = [];
  for (int idx = 0; idx < sentence1.length; ++idx) {
    ids1.add(idMap[sentence1[idx]]);
  }

  List<int> ids2 = [];
  for (int idx = 0; idx < sentence2.length; ++idx) {
    ids2.add(idMap[sentence2[idx]]);
  }

  Int16P p1 = Int16P.fromList(ids1);
  Int16P p2 = Int16P.fromList(ids2);
  double score = _audioConvertSentenceSimilarity(p1.address, p1.length, p2.address, p2.length);
  p1.dispose();
  p2.dispose();

  return score;
}
