# !/bin/sh

if [ ! -d ~/genPackage ];then
  mkdir -p ~/genPackage
fi

if [ ! -d ~/genPackage/IOS_Teacher ];then
  mkdir -p ~/genPackage/IOS_Teacher
fi
ROOT_PATH=~/genPackage/IOS_Teacher


#############安装brew和xctool#############
if which brew 2>/dev/null; then
  echo "-> brew已经安装"
else
  echo "-> 检测到brew未安装,开始安装brew···"
  curl -LsSf http://github.com/mxcl/homebrew/tarball/master | sudo tar xvz -C/usr/local --strip 1
  ##ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

if which xctool>/dev/null; then
  echo "-> xctool已经安装"
else
  echo "-> 检测到xctool未安装,开始安装xctool···"
  sudo brew update
  sudo brew install xctool 
fi


###########开始打包IPA########
APP_NAME="TXChatTeacher"
BUILD_DIR="$ROOT_PATH"        #build目录

buildDayTime=$(date +'%Y-%m-%d_%H%M%S')

# ARCHIVE_PATH="$BUILD_DIR/$APP_NAME.xcarchive"
#IPA_PATH_ADHOC="$BUILD_DIR/TXChatTeacher_adHoc_2016-03-30_101124.ipa"

XCWORKSPACE="TXChatTeacher.xcworkspace"
SCHEME="TXChatTeacher"
CONF="Release"
# PROFILE="Provisioning Profile: com.tuxing.chs.parent_adhoc"
PROFILE_ADHOC="teacherClient_adHoc_new"
PROFILE_DIS="teacherClient_dis"

# clean Release
xcodebuild clean \
-project ${APP_NAME}.xcodeproj \
-configuration ${CONF} \
-alltargets


#set version and bundleVesion add 1
InfoPlist="TXChat/info.plist"
BINARY_VERSION=`/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" $InfoPlist`
BINARY_BUILD=`/usr/libexec/PlistBuddy -c "Print CFBundleVersion" $InfoPlist`

BINARY_VERSION=`echo ${BINARY_VERSION%.*}`
BINARY_BUILD=$(($BINARY_BUILD+1))
BINARY_VERSION="$BINARY_VERSION.$BINARY_BUILD"

/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $BINARY_VERSION" $InfoPlist
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $BINARY_BUILD" $InfoPlist


ARCHIVE_PATH="$BUILD_DIR/${APP_NAME}_${buildDayTime}_v${BINARY_VERSION}.xcarchive"
IPA_PATH_ADHOC="$BUILD_DIR/${APP_NAME}_adHoc_${buildDayTime}_v${BINARY_VERSION}.ipa"
IPA_PATH_DIS="$BUILD_DIR/${APP_NAME}_dis_${buildDayTime}_v${BINARY_VERSION}.ipa"

# #archive
xctool \
-workspace $XCWORKSPACE \
-scheme $SCHEME \
-sdk iphoneos \
-configuration $CONF \
archive -archivePath  "$ARCHIVE_PATH"

#导成IPA(adhoc测试版本)
xcodebuild \
-exportArchive \
-exportFormat ipa -archivePath "$ARCHIVE_PATH" \
-exportPath   "$IPA_PATH_ADHOC" \
-exportProvisioningProfile $PROFILE_ADHOC

#导成IPA(dis发布版本)
xcodebuild \
-exportArchive \
-exportFormat ipa -archivePath "$ARCHIVE_PATH" \
-exportPath   "$IPA_PATH_DIS" \
-exportProvisioningProfile $PROFILE_DIS

#判断IPA导出成功没
if [ ! -f "$IPA_PATH_DIS" ];then
  echo "IPA_DIS文件的导出没有成功"
  exit 1
fi

#上传到fir
if [ ! -f "$IPA_PATH_ADHOC" ];then
  echo "找不到IPA文件的路径"
  exit 1
fi


echo "打包成功"
exit 1
  
####获取上传基本信息
#USER_TOKEN和APP_ID，在fir.im网站上注册一个账号，新建一个项目就，有这两个变量了
USER_TOKEN="24b45603fad80e915bc7bc7702623f6f"
APP_ID="57358806e75e2d7ebf000018"
APP_TYPE="ios"

####获取当前时间
date_Y_M_D_W_T()
{
    WEEKDAYS=(星期日 星期一 星期二 星期三 星期四 星期五 星期六)
    WEEKDAY=$(date +%w)
    DT="$(date +%Y年%m月%d日) ${WEEKDAYS[$WEEKDAY]} $(date "+%H:%M:%S")"
    echo "$DT 更新测试包"
}

#读取Info.plist内容
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

#上传Binary
echo "uploading ipa"
BINARY_KEY=$(echo ${APP_INFO} | grep "binary.*token" -o | awk -F '"' '{print $5;}')
BINARY_TOKEN=$(echo ${APP_INFO} | grep "binary.*upload_url" -o | awk -F '"' '{print $9;}')
# echo ${BINARY_KEY}
# echo ${BINARY_TOKEN}

BINARY_INFO=`curl -# -F file=@${IPA_PATH_ADHOC} -F "key=${BINARY_KEY}" -F "token=${BINARY_TOKEN}" -F "x:name=${BINARY_NAME}" -F "x:version=${BINARY_VERSION}" -F "x:build=${BINARY_BUILD}" -F "x:changelog=${BINARY_CHANGELOG}" http://upload.qiniu.com`
echo ${BINARY_INFO}
if [ $? != 0 ];then
  echo "上传IPA失败"
  exit 1
fi

echo "成功上传到fir地址：http://fir.im/lxtTeacherIOSV1"
