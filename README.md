# Lokinet on the Go

An app to interact with Lokinet as a vpn tunnel for android

## building

build requirements:

* flutter
* gnu make
* cmake
* pkg-config
* git
* autotools

install flutter:

    $ sudo snap install flutter --classic

a one liner to install everything else:

    $ sudo apt install make automake libtool pkg-config cmake git

### build with flutter

before building make sure to update the submodules:

    $ git submodule update --init --recursive

to build the project with flutter:

    $ flutter build apk --debug
    
if succesful it will produce an apk at `build/app/outputs/flutter-apk/app-debug.apk` which you can run

## CI artifacts

auto generated builds can be found at: https://oxen.rocks/majestrate/lokinet-mobile
