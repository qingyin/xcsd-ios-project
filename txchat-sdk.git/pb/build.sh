#!/bin/bash

protoc --plugin=/usr/local/bin/protoc-gen-objc *.proto --objc_out="../src/TXChatSDK/"
