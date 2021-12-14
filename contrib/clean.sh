#!/bin/bash

flutter clean
git submodule foreach git clean -xdf
