#!/bin/bash
echo "Cleaning builds..."
flutter clean
echo "Building release apk..."
flutter build apk -t lib/main_prod.dart --flavor prod --release
echo "Renaming apk..."
mv ./build/app/outputs/flutter-apk/app-prod-release.apk ./build/app/outputs/flutter-apk/Profluent.apk
#mv ./build/app/outputs/flutter-apk/Profluent.apk /Users/sumit/Desktop
cd ./build/app/outputs/flutter-apk
echo "Firebase login..."
sudo firebase login

echo "Enter release notes : "
read releaseNote

echo "Distributing for testing..."
sudo firebase appdistribution:distribute Profluent.apk  \
    --app 1:620147953805:android:389a231abf4e75ef \
    --release-notes "$releaseNote" --testers "nemadesumit@gmail.com, litelearninglab@gmail.com, m.praveen.k@gmail.com, jagadeeshgmm@gmail.com"
