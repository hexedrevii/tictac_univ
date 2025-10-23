#!/bin/bash

rm -rf out/
mkdir out/

zip -rq out/focus.love lib/ src/ assets/ conf.lua main.lua

cd out/
love.js focus.love focus -c

cd focus/
python -m http.server 8000
