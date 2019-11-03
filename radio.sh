#!/bin/bash 
# 
# Simple script for icecast2 and ezstream 
# to scan folder for mp3 files and start stream

MUSICARCHIVE="/Server/files/external_hd/Radiofiles/"
EXTNS="mp3"
PLFILE="/Server/files/external_hd/Radiofiles/Playlist.m3u"
CONFIGFILE="/Server/configs/ezstream.conf"
RADIOLOG="/Server/logs/HealthRadio.log"
EZPID=`pidof ezstream`
ICECASTPID=`pidof ezstream`

generateplist() {
	cd $MUSICARCHIVE;
	for i in *; do
        sudo find `pwd` -maxdepth 3 -name "*.$EXTNS" > $PLFILE; 
    done
    writelog "Playlist is generated!";
}

writelog() {
    LOG=$(date +"%m-%d-%Y %r");
    LOG="[$LOG] $1";
    echo $LOG;
    sudo echo $LOG >> $RADIOLOG;
}

startradio() {
	generateplist;
	if [ -z "$ICECASTPID" ]; 
	then sudo /etc/init.d/icecast2 start
	else sudo /etc/init.d/icecast2 restart
	fi 
	if [ ! -z $EZPID ];
	then sudo kill -9 $EZPID;
	fi 
	ezstream -c $CONFIGFILE;
	writelog "Radio server started!";
}

stopradio() {
	if [ ! -z "$ICECASTPID" ]; 
	then sudo /etc/init.d/icecast2 stop
	fi 
	if [ ! -z "$EZPID" ];
	then sudo kill -9 $EZPID;
	fi
	writelog "Radio server stopped!";
}

case $1 in
	start) startradio; ;;
	stop) stopradio; ;;
	reload) stopradio; startradio; ;;
	*) writelog "use start|stop|reload params for action!"; ;;
esac