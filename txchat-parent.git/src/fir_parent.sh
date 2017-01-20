#上传到fir

IPA_PATH=$1
if [ -z "$IPA_PATH" ]
then
	echo "找不到IPA文件的路径"
	exit 1
fi

####获取上传基本信息
USER_TOKEN="24decbf4a7054fbe1643514166125692"
APP_ID="5588be3417fe2978340021b7"
APP_TYPE="ios"
ICON_FILE="$(pwd)/fir_icon.png"
# echo ${ICON_FILE}

####获取当前时间
date_Y_M_D_W_T()
{
    WEEKDAYS=(星期日 星期一 星期二 星期三 星期四 星期五 星期六)
    WEEKDAY=$(date +%w)
    DT="$(date +%Y年%m月%d日) ${WEEKDAYS[$WEEKDAY]} $(date "+%H:%M:%S")"
    echo "$DT 更新测试包"
}

#读取Info.plist内容
APP_NAME="TXChatParent"
InfoPlist="TXChat/info.plist"
Bundle_ID=`/usr/libexec/PlistBuddy -c "Print CFBundleIdentifier" $InfoPlist`
BINARY_VERSION=`/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" $InfoPlist`
BINARY_NAME=`/usr/libexec/PlistBuddy -c "Print CFBundleDisplayName" $InfoPlist`
BINARY_BUILD=`/usr/libexec/PlistBuddy -c "Print CFBundleVersion" $InfoPlist`
BINARY_CHANGELOG="$(date_Y_M_D_W_T)"

# echo "getting token"

#POST请求获取上传凭证
APP_INFO=`curl -d "type=${APP_TYPE}&bundle_id=${Bundle_ID}&api_token=${USER_TOKEN}" http://api.fir.im/apps/${APP_ID}/releases 2>/dev/null`
# echo ${APP_INFO}

#上传Icon
echo "uploading icon"
ICON_KEY=$(echo ${APP_INFO} | grep "key.*binary" -o | awk -F '"' '{print $3;}')
ICON_TOKEN=$(echo ${APP_INFO} | grep "token.*token" -o | awk -F '"' '{print $3;}')
# echo ${ICON_KEY}
# echo ${ICON_TOKEN}

ICON_INFO=`curl -# -F file=@${ICON_FILE} -F "key=${ICON_KEY}" -F "token=${ICON_TOKEN}" http://upload.qiniu.com`
echo ${ICON_INFO}
if [ $? != 0 ]
then
  echo "上传Icon失败"
  exit 1
fi

#上传Binary
echo "uploading ipa"
BINARY_KEY=$(echo ${APP_INFO} | grep "binary.*token" -o | awk -F '"' '{print $5;}')
BINARY_TOKEN=$(echo ${APP_INFO} | grep "binary.*upload_url" -o | awk -F '"' '{print $9;}')
# echo ${BINARY_KEY}
# echo ${BINARY_TOKEN}

BINARY_INFO=`curl -# -F file=@${IPA_PATH} -F "key=${BINARY_KEY}" -F "token=${BINARY_TOKEN}" -F "x:name=${BINARY_NAME}" -F "x:version=${BINARY_VERSION}" -F "x:build=${BINARY_BUILD}" -F "x:changelog=${BINARY_CHANGELOG}" http://upload.qiniu.com`
echo ${BINARY_INFO}
if [ $? != 0 ]
then
  echo "上传IPA失败"
  exit 1
fi

echo "成功上传到fir地址：http://fir.im/wjyparent"