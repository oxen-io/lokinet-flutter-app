# Lokinet on Android

An app to interact with Lokinet as a vpn tunnel for android.

[![Build Status](https://ci.oxen.rocks/api/badges/oxen-io/lokinet-flutter-app/status.svg)](https://ci.oxen.rocks/oxen-io/lokinet-flutter-app)


## building

build requirements:

* posix compliant build environment
* flutter
* gnu make
* cmake
* pkg-config
* git
* autotools

a one liner to install everything else:

    $ sudo apt install make automake libtool pkg-config cmake git

### git submodules

before building make sure to update the submodules:

    $ git submodule update --init --recursive

### flutter

install flutter with [asdf](https://github.com/asdf-vm/asdf):

    $ asdf install

to build the project with flutter:

    $ flutter build apk --debug

if successful it will produce an apk at `build/app/outputs/flutter-apk/app-debug.apk` which you can run

## linting and testing

to check the code and run the tests:

    $ flutter analyze
    $ dart format lib test
    $ flutter test

`contrib/format.sh` runs the formatter and the linter for the app and for
`lokinet_lib` (the gradle step additionally requires a local java
installation).

## cleaning

to make the workspace pristine use:

    $ ./contrib/clean.sh
