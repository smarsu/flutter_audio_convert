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

int _lastErrRet = 0;

int getLastErrRet() {
  return _lastErrRet;
}

Future<String> appDocPath(path) async {
  var dir = (await getApplicationDocumentsDirectory()).path;
  return '$dir/$path';
}

Future<String> toM4A(String input, {String output, String extend='mp4'}) async {
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
    return input;
  }
  else if (convertRet == 0) {
    // Success
    return output;
  }
  else if (convertRet == 1) {
    // The input is M4A format.
    return input;
  }
  return output;
}
