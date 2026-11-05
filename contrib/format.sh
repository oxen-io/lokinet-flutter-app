#!/bin/bash
set -e
flutter pub get
flutter analyze
dart format lib test
(cd lokinet_lib && flutter pub get && flutter analyze && dart format lib)
./gradlew -p lokinet_lib/android spotlessApply
