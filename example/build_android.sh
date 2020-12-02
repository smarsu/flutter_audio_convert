set -e
set -x

cd /Users/smarsu/tencent/projects/audio_convert
bash build.sh arm64
cd -

cp ~/tencent/projects/audio_convert/build_android/libaudio_convert.a ../android/libaudio_convert.a
cp ~/tencent/projects/audio_convert/build_ios/libaudio_convert.dylib ../ios/Classes/libaudio_convert.dylib

flutter clean
flutter pub get
flutter pub upgrade 

flutter run -v 
