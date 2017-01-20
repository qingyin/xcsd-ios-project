#!/bin/bash

cd /Users/lingqingwan/tuxing/tx-pb/
echo current dir $PWD
git pull
cd -

cp /Users/lingqingwan/tuxing/tx-pb/src/main/resources/proto/Wjy.proto .
cp /Users/lingqingwan/tuxing/tx-pb/src/main/resources/proto/jsb.proto .

mv Wjy.proto TXPBChat.proto
mv jsb.proto TXPBJsb.proto

echo 'import "google/protobuf/objectivec-descriptor.proto";' >> TXPBChat.proto
echo 'option (google.protobuf.objectivec_file_options).class_prefix = "TXPB";'>> TXPBChat.proto

echo 'import "google/protobuf/objectivec-descriptor.proto";' >> TXPBJsb.proto
echo 'option (google.protobuf.objectivec_file_options).class_prefix = "TXPB";'>> TXPBJsb.proto
echo 'import "TXPBChat.proto";' >> TXPBJsb.proto

sed -i '-' 's/import "wjy.proto";//g' TXPBJsb.proto

# protoc --plugin=/usr/local/bin/protoc-gen-objc *.proto --objc_out="../src/TXChatSDK/"
echo OK
