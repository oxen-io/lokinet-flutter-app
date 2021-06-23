#!/bin/bash
flutter format .
cd lokinet_lib/android && gradle spotlessApply
