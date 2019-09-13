#!/bin/sh

source /jffs/softcenter/scripts/base.sh
eval `dbus export serverchan_`
# for long message job remove
remove_cron_job(){
    echo 关闭自动发送状态消息...
    cru d serverchan_check >/dev/null 2>&1
}

# for long message job creat
creat_cron_job(){
    echo 启动自动发送状态消息...
    if [[ "${serverchan_status_check}" == "1" ]]; then
        cru a serverchan_check ${serverchan_check_time_min} ${serverchan_check_time_hour}" * * * /jffs/softcenter/scripts/serverchan_check_task.sh"
    elif [[ "${serverchan_status_check}" == "2" ]]; then
        cru a serverchan_check ${serverchan_check_time_min} ${serverchan_check_time_hour}" * * "${serverchan_check_week}" /jffs/softcenter/scripts/serverchan_check_task.sh"
    elif [[ "${serverchan_status_check}" == "3" ]]; then
        cru a serverchan_check ${serverchan_check_time_min} ${serverchan_check_time_hour} ${serverchan_check_day}" * * /jffs/softcenter/scripts/serverchan_check_task.sh"
    elif [[ "${serverchan_status_check}" == "4" ]]; then
        if [[ "${serverchan_check_inter_pre}" == "1" ]]; then
            cru a serverchan_check "*/"${serverchan_check_inter_min}" * * * * /jffs/softcenter/scripts/serverchan_check_task.sh"
        elif [[ "${serverchan_check_inter_pre}" == "2" ]]; then
            cru a serverchan_check "0 */"${serverchan_check_inter_hour}" * * * /jffs/softcenter/scripts/serverchan_check_task.sh"
        elif [[ "${serverchan_check_inter_pre}" == "3" ]]; then
            cru a serverchan_check ${serverchan_check_time_min} ${serverchan_check_time_hour}" */"${serverchan_check_inter_day} " * * /jffs/softcenter/scripts/serverchan_check_task.sh"
        fi
    elif [[ "${serverchan_status_check}" == "5" ]]; then
        check_custom_time=`dbus get serverchan_check_custom | base64_decode`
        cru a serverchan_check ${serverchan_check_time_min} ${check_custom_time}" * * * /jffs/softcenter/scripts/serverchan_check_task.sh"
    else
        remove_cron_job
    fi
}

creat_trigger_dhcp(){
    #rm -f /etc/dnsmasq.user/dhcp_trigger.conf
    #echo "dhcp-script=/jffs/softcenter/scripts/serverchan_dhcp_trigger.sh" >> /etc/dnsmasq.user/dhcp_trigger.conf
    #[ "${serverchan_info_logger}" == "1" ] && logger "[软件中心] - [ServerChan]: 重启DNSMASQ！"
    #service restart_dnsmasq
#和aimesh冲突，改为由aimesh触发
	nvram set sc_dhcp_script='serverchan_dhcp_trigger.sh'
	nvram commit
}

remove_trigger_dhcp(){
    #rm -f /etc/dnsmasq.user/dhcp_trigger.conf
    #[ "${serverchan_info_logger}" == "1" ] && logger "[软件中心] - [ServerChan]: 重启DNSMASQ！"
    #service restart_dnsmasq
	nvram unset sc_dhcp_script
	nvram commit
}

creat_trigger_ifup(){
    rm -f /jffs/softcenter/init.d/*serverchan.sh
    if [[ "${serverchan_trigger_ifup}" == "1" ]]; then
	if [ "`nvram get productid`" == "BLUECAVE" ];then
		cp -r /jffs/softcenter/scripts/serverchan_ifup_trigger.sh /jffs/softcenter/init.d/M99serverchan.sh
	else
		ln -sf /jffs/softcenter/scripts/serverchan_ifup_trigger.sh /jffs/softcenter/init.d/S99serverchan.sh
	fi
    else
        rm -f /jffs/softcenter/init.d/*serverchan.sh
    fi
}

remove_trigger_ifup(){
    rm -f /jffs/softcenter/init.d/*serverchan.sh
}

onstart(){
	if [ "`nvram get productid`" == "BLUECAVE" ];then
		cp -r /jffs/softcenter/scripts/serverchan_config.sh /jffs/softcenter/init.d/M98serverchan.sh
	else
		ln -sf /jffs/softcenter/scripts/serverchan_config.sh /jffs/softcenter/init.d/S98serverchan.sh
	fi
    creat_cron_job
    creat_trigger_ifup
    if [ "${serverchan_trigger_dhcp}" == "1" ]; then
        creat_trigger_dhcp
    else
        remove_trigger_dhcp
    fi
}
# used by httpdb
case $1 in
start)
    if [[ "${serverchan_enable}" == "1" ]]; then
        logger "[软件中心]: 启动ServerChan！"
        onstart
    else
        logger "[软件中心]: ServerChan未设置启动，跳过！"
    fi
    ;;
stop)
    remove_trigger_dhcp
    remove_trigger_ifup
    remove_cron_job
    logger "[软件中心]: 关闭ServerChan！"
    ;;
restart)
    if [[ "${serverchan_enable}" == "1" ]]; then
        logger "[软件中心]: 启动ServerChan！"
        onstart
    else
        logger "[软件中心]: ServerChan未设置启动，跳过！"
    fi
    ;;
esac
