#!/usr/bin/env bash

echo "<?xml version='1.0' encoding='UTF-8'?>
<!DOCTYPE plist PUBLIC '-//Apple//DTD PLIST 1.0//EN' 'http://www.apple.com/DTDs/PropertyList-1.0.dtd'>
<plist version='1.0'>
<dict>
    <key>TestKey</key>
    <string>$TEST_KEY</string>
    <key>GMSApiKey</key>
    <string>\$(GMSApiKey)</string>
</dict>
</plist>" > Scout/PrivateConfig.plist
