echo -e "\n--> Flutter clean\n"
flutter clean

echo -e "\n\n--> Flutter pub get\n"
flutter pub get

echo -e "\n\n--> Building Windows EXE"
flutter build windows --release

mv -r build/windows/runner/Release bin/windows
powershell Compress-Archive bin\wwindows bin\wwindows.zip
echo -e "\n\n--> Windows build available at: bin/windows\n"
