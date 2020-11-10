# Copyright (c) 2020 smarsufan. All Rights Reserved.

cmake_minimum_required(VERSION 3.6.0)
project(audio_convert)

link_directories(.)
link_directories(arm64)

add_library(audio_convert SHARED audio_convert.cc)
target_link_libraries(
  audio_convert
  -Wl,--whole-archive
  libaudio_convert.a
  libavcodec.a
  libavfilter.a
  libavformat.a
  libavutil.a
  libswresample.a
  libswscale.a
  -Wl,--no-whole-archive
)
