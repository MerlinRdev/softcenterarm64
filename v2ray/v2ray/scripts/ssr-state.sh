#!/bin/sh
LOGTIME=$(date "+%Y-%m-%d %H:%M:%S")

baidu_state()
{
/usr/sbin/wget --no-check-certificate -4 --spider --quiet --tries=2 --timeout=2 wap.baidu.com
if [ "$?" == "0" ]; then
	log='baidu   --- [ '$LOGTIME' ]    OK '
else
	log='baidu   --- [ '$LOGTIME' ]    NO '
fi

nvram set ss_china_state="$log"
}

google_state()
{
/usr/sbin/wget --no-check-certificate -4 --spider --quiet --tries=2 --timeout=2 https://www.google.com.tw
if [ "$?" == "0" ]; then
	log=' google - [ '$LOGTIME' ]    OK '
else
	log=' google - [ '$LOGTIME' ]    NO '
fi

nvram set ss_foreign_state="$log"
}

sleep 5
baidu_state
google_state
sleep 20
baidu_state
google_state
exit 0

