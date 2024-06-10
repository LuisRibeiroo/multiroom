flutter clean
flutter pub get

echo "--> Building Android APK"
flutter build apk --release

mv build/app/outputs/flutter-apk/app-release.apk bin/multiroom.apk
echo "--> Android build available at: bin/multiroom.apk"

if [[ "$OSTYPE" == "msys" ]]; then
  echo "--> Building Windows EXE"
  flutter build windows --release

  mv -r build/windows/runner/Release bin/windows
  powershell Compress-Archive bin\windows bin\windows.zip
  echo "--> Windows build available at: bin/windows"
fi
