#!/bin/bash
echo "Cleaning builds..."
flutter clean
echo "Building release apk..."
flutter build apk -t lib/main_english.dart --flavor english --release
echo "Renaming apk..."
mv ./build/app/outputs/flutter-apk/app-english-release.apk ./build/app/outputs/flutter-apk/ProfluentEnglish.apk
#mv ./build/app/outputs/flutter-apk/ProfluentEnglish.apk /Users/sumit/Desktop
cd ./build/app/outputs/flutter-apk
echo "Firebase login..."
sudo firebase login

echo "Enter release notes : "
read releaseNote

echo "Distributing for testing..."
sudo firebase appdistribution:distribute ProfluentEnglish.apk  \
    --app 1:620147953805:android:9c7d47377b0e84b4b752c4 \
    --release-notes "$releaseNote" --testers "nemadesumit@gmail.com, litelearninglab@gmail.com, m.praveen.k@gmail.com, jagadeeshgmm@gmail.com"
