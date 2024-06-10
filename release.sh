#! /bin/bash

echo "\n\n--> Flutter clean"
flutter clean

echo "\n\n--> Flutter pub get"
flutter pub get

echo "\n\n--> Building Android APK"
flutter build apk --release

mv build/app/outputs/flutter-apk/app-release.apk bin/multiroom.apk
echo "\n\n--> Android build available at: bin/multiroom.apk"

if [[ "$OSTYPE" == "msys" ]]; then
  echo "\n\n--> Building Windows EXE"
  flutter build windows --release

  mv -r build/windows/runner/Release bin/windows
  powershell Compress-Archive bin\windows bin\windows.zip
  echo "\n\n--> Windows build available at: bin/windows"
fi
