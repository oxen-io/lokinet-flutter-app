# Lokinet on the Go

An app to interact with Lokinet as a vpn tunnel for android

[![Build Status](https://ci.oxen.rocks/api/badges/oxen-io/lokinet-flutter-app/status.svg)](https://ci.oxen.rocks/oxen-io/lokinet-flutter-app)


## building

build requirements:

* flutter
* gnu make
* cmake
* pkg-config
* git
* autotools

install flutter with snap:

    $ sudo snap install flutter --classic

or with [asdf](https://github.com/asdf-vm/asdf):

    $ asdf install

a one liner to install everything else:

    $ sudo apt install make automake libtool pkg-config cmake git

### build with flutter

before building make sure to update the submodules:

    $ git submodule update --init --recursive

to build the project with flutter:

    $ flutter build apk --debug
    
if succesful it will produce an apk at `build/app/outputs/flutter-apk/app-debug.apk` which you can run

## cleaning

to make the workspace pristine use:

    $ ./contrib/clean.sh
