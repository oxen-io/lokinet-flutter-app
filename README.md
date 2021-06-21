# Lokinet on the Go

An app to interact with Lokinet as a vpn tunnel for android

## building

build requirements:

* flutter 1.x (ideally flutter 2.x if you are able to)
* lokinet android jni libs

first you need to get a build of the native libs for android lokinet

### build with flutter

before building make sure to update the submodules:

    $ git submodule update --init --recursive

to build the project with flutter:

    $ flutter build apk --debug
    
if succesful it will produce an apk at `build/app/outputs/flutter-apk/app-debug.apk` which you can run

## CI artifacts

auto generated builds can be found at: https://oxen.rocks/majestrate/lokinet-mobile
