#!/bin/bash
mm_version="v3.2.1"
work_dir=$(pwd)
android_dir=$(dirname "$PWD") 
echo
istate=$(cat $work_dir/state.txt)
if [[ "$istate" == "1" ]]
then
	echo "---------------------another is using, please wait------------------"
	exit
fi
echo "1">state.txt
echo
if [[ "$1" == "" ]]
then
	channel_input="test"
else  
	channel_input=$1
fi
if [[ $2 == https://* || $2 == http://* ]]
then
	ip_input=$2	
else  
	ip_input="https://192.168.2.145"
fi
if [[ "$3" =~ "." ]]
then
	pkg_input=$3	
else  
	pkg_input="com.spcfar.service"
fi
echo
echo "-----input--channel--$channel_input--ip--$ip_input--pkg--$pkg_input------"
echo
configText=$(cat $work_dir/config.txt)
OLD_IFS="$IFS" 
IFS="," 
arr=($configText) 
IFS="$OLD_IFS" 

channel_old=${arr[0]}
ip_old=${arr[1]}
pkg_old=${arr[2]}
echo
echo "--read_config----channel--$channel_old--ip--$ip_old--pkg--$pkg_old--"
echo
echo
echo "-----$mm_version-----start_change--pkg--text--------"
echo
sed -i "s#$pkg_old#$pkg_input#g" `grep $pkg_old -rl $work_dir/eagle2_android/detect`
sed -i "s#$pkg_old#$pkg_input#g" `grep $pkg_old -rl $work_dir/eagle2_android/installer/app/src/main/java/com/baidu/installer/Constants.java`
sed -i "s#$ip_old#$ip_input#g" `grep $ip_old -rl $work_dir/eagle2_android/installer/app/src/main/java/com/spcfar/installer/Constants.java`
sed -i "s#$channel_old#$channel_input#g" `grep $channel_old -rl $work_dir/eagle2_android/installer/app/src/main/java/com/spcfar/installer/Constants.java`
OLD_IFS="$IFS" 
IFS="." 
arr_old=($pkg_old) 
IFS="$OLD_IFS" 

OLD_IFS="$IFS" 
IFS="." 
arr_input=($pkg_input) 
IFS="$OLD_IFS" 
echo
echo "---------start_change--pkg--dir---------"

if [ ${arr_input[2]} != ${arr_old[2]} ];then 
	mv $work_dir/eagle2_android/detect/app/src/main/java/${arr_old[0]}/${arr_old[1]}/${arr_old[2]}/ $work_dir/eagle2_android/detect/app/src/main/java/${arr_old[0]}/${arr_old[1]}/${arr_input[2]}/
fi
if [ ${arr_input[1]} != ${arr_old[1]} ];then 
	mv $work_dir/far/detect/app/src/main/java/${arr_old[0]}/${arr_old[1]}/ $work_dir/far/detect/app/src/main/java/${arr_old[0]}/${arr_input[1]}/
fi
if [ ${arr_input[0]} != ${arr_old[0]} ];then 
	mv $work_dir/far/detect/app/src/main/java/${arr_old[0]}/ $work_dir/far/detect/app/src/main/java/${arr_input[0]}/
fi
echo
echo
echo "-------------start--key--------------------"
rm -f $android_dir/Android/key/love.jks
keytool -genkey -alias love -keypass 123456 -keyalg RSA -keysize 1024 -validity 3650 -keystore $android_dir/Android/key/love.jks -storepass 123456 -dname "CN=(-), OU=(-), O=(-), L=(-), ST=(-), C=(-)"
echo
echo "-----------start--clean--detect---------"
echo
chmod 777 -R $work_dir/far/
cd $work_dir/far/detect
gradle clean
rm -f .gradle/4.5/javaCompile/taskHistory.bin
gradle --stop
echo
echo "-----------start--release--detect---------"
echo
gradle as>0.txt
echo
echo "-----------start--jiagu--detect.apk-----------"
echo
java -jar $android_dir/Android/jiagu/jiagu.jar $android_dir/Android/key/love.jks 123456 123456 love encrypt $android_dir/Android/jiagu/apktool_2.3.4.jar $android_dir/Android/jiagu/jiagu.zip $work_dir/far/detect/app/build/outputs/apk/release/detect.apk
echo
echo "-----------start--mv--detect.apk-----------"
echo
if [ -f "$work_dir/far/detect/app/build/outputs/apk/release/detect_encrypt.apk" ]
then
	mv $work_dir/far/detect/app/build/outputs/apk/release/detect_encrypt.apk $work_dir/far/installer/app/src/main/assets/detect.apk
	echo
	echo "---------start--release--installer---------"
	echo
	cd $work_dir/far/installer
	rm -f $work_dir/far/detect/app/build/intermediates/classes/debug/com/spcfar/network1/DetectApplication$MyDaemonListener.class
	gradle clean
	rm -f .gradle/4.5/javaCompile/taskHistory.bin
	gradle --stop
	gradle as
	echo
	echo "-----------start--jiagu--installer.apk-----------"
	echo
	java -jar $android_dir/Android/jiagu/jiagu.jar $android_dir/Android/key/love.jks 123456 123456 love encrypt $android_dir/Android/jiagu/apktool_2.3.4.jar $android_dir/Android/jiagu/jiagu.zip $work_dir/far/installer/app/build/outputs/apk/release/app.apk
	echo
	echo "----------start--out--app.apk----------------"
	echo
	cd $work_dir
	pwd
	mkdir -p $work_dir/vmp/$channel_input
	chmod 777 -R vmp/
	mv $work_dir/far/installer/app/build/outputs/apk/release/app_encrypt.apk $work_dir/vmp/$channel_input/app.apk
	chmod 777 -R vmp/
	echo
	echo "---------start--backup--config----------------"
	echo "$channel_input,$ip_input,$pkg_input">config.txt
	echo
	gradle --stop
	echo
	echo
	echo 	"---$mm_version--channel--$channel_input---ip--$ip_input----pkg--$pkg_input------"
	echo	"---------the out path is----vmp/$channel_input/app.apk----------"
	echo 	"0">state.txt
	echo
	echo -e '\033[0;32;1m-------------------success------done--------------------\033[0m'
	echo
	echo
else
	echo "---------start--backup--config----------------"
	echo "$channel_input,$ip_input,$pkg_input">config.txt
	echo
	gradle --stop
	cd $work_dir
	echo
	echo
	echo 	"---$mm_version--channel--$channel_input---ip--$ip_input----pkg--$pkg_input------"
	echo 	"0">state.txt
	echo -e '\033[0;31;1m-----------failure-----check infos--------------------\033[0m'
fi


