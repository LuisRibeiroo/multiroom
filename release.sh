#! /bin/bash

printf "\n--> Flutter clean\n"
flutter clean

printf "\n\n--> Flutter pub get\n"
flutter pub get

printf "\n\n--> Building Android APK"
flutter build apk --release


printf "\n\n--> Building MAC App"
flutter build macos --release

mv build/app/outputs/flutter-apk/app-release.apk bin/multiroom.apk
mv build/macos/Build/Products/Release/multiroom.app bin/multiroom.app

printf "\n\n--> Android build available at: bin/multiroom.apk"
printf "\n--> MacOS build available at: bin/multiroom.app\n"