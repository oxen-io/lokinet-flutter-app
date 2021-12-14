#!/bin/bash

flutter clean
cd "$(dirname $0)/../lokinet_lib/android" && gradle clean
cd "$(dirname $0)/../" && git submodule foreach git clean -xdf
