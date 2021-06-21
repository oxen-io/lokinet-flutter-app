#!/bin/bash

flutter clean
cd "$(dirname $0)/../lokinet_lib/android" && gradle clean
