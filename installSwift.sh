#!/bin/bash 


clear # begining from zero

#Colors
red="\e[1;31m"
blue="\e[1;34m"
yellow='\e[1;33m'
transparent="\e[0m"

# your current os, if not a ubuntu just quiting because aptitude use to install dependencies 
FINDISTR="lsb_release -r -s"
# distributive of ubuntu
CURRENTDISTR="0.0" # means null
# name of user from what is executed script
USER=`whoami`
# commands to check
FINDSWIFT="swift --version"
# minimum swift version for installation (if lower version exist, it continues installation)
MINSWIFT="3.1"
# my link for help and correction (if i got mistakes)
AUTHORLINK="https://github.com/devm4x" 
# temporary folder where will be downloaded all files  
DOWNLOADFOLDER="$HOME/tmpSwift"
# temporary file in which will be saved swift archive 
SWIFTFILE="swift_lang.tar.gz"
# just test sample swift project to show how it works, if user wants
TEMPPROJECT="spm_example"
# use this for silent installation
ARG1="$0"


echo "+------------------------------------------------------------+"
echo "|================== Meet Swift with Linux ===================|"
echo "| Script will install swift 3.1/4.0 in Ubuntu 16.04 or later |"
echo "+------------------------------------------------------------+"
echo "If you want continue type: y or yes"
read cAns

case $cAns in 
	[yY]* )
		echo "Checking requirements..."
	;;
	* ) 
		exit 1 
	;;
esac 

if [ -x "$(command -v $FINDISTR)" ]; then
	CURRENTDISTR=`$FINDISTR`

	case $CURRENTDISTR in 
		"16.04" | "16.10" | "17.04" | "17.10")
			echo "[OK] Version of OS is correct"
		;;
		*)
			echo "This script is made for Ubuntu 16.04 and above"
			echo "Your OS is not supported. Aborting..."
			exit 1 
		;;
	esac 
else
	echo "Unknown OS! Aborting..."
	exit 1
fi

if [ $USER == "root" ]; then 
	echo "Don't use this script as root! Aborting..."
	exit 1
fi 

# verify, if user in sudoers group (need to install dependencies)
# not test yet !!!!
SUUSER=`getent group sudo | cut -d: -f4`

if [ $SUUSER == $USER ]; then 
	echo "Important depencies required installation and update!"
	echo "Starting update..."
	sudo apt-get update -y 
	sudo apt-get upgrade -y  
	#sudo apt-get dist-upgrade -y 
	sudo apt-get install -y clang libicu-dev libstdc++6 git cmake ninja-build clang uuid-dev openssl libssl-dev 
	sudo apt-get install -y icu-devtools libbsd-dev libedit-dev libxml2-dev libsqlite3-dev swig libpython-dev libncurses5-dev pkg-config 
else 
	# updating system and installing depencies. Dependencies need to normal work of swift compiler 
	echo "+-------------------------------------------------------------+"
	echo "| you need to update system and install important depencies   |"
	echo "| without this depencies Swift work incorrectly or not work   |" 
	echo "| Also if your accaunt is not in sudoers group                |"
	echo "| update is impossible. So you need install all this manualy. |"
	echo "+-------------------------------------------------------------+"
	echo "| [Fail!]. User is not in sudoers group.                      |"
	echo "+-------------------------------------------------------------+"
	echo "Be ready to swift compiler problems"
	echo "or execute this script in sudo user"
	echo "Wait... 5s"
	sleep 5
fi

if [ -x "$(command -v $FINDSWIFT)" ]; then
	CURRENTSWIFT=`command -v $($FINDSWIFT | awk '{print $3}') || { echo "0.0"; }`
	# checking version of swift (not working yet!)
	if [ $MINSWIFT == $CURRENTSWIFT ]; then 
		echo "You have same or newer version of swift: $CURRENTSWIFT"
		echo "Aborting..."
		exit 1
	fi  
fi 

while true 
do 
	clear
	# set function for selected version of swift
	echo "+----------------------------------------------------------------+"
	echo "| What version of swift you want install?                        |"
	echo "| 1. Swift 4.0                                                   |"
	echo "| 2. Swift 3.1                                                   |"
	echo "+----------------------------------------------------------------+"
	echo "Your choise?"	
	read swiftAns 

	case $swiftAns in 
		"1") echo "Swift 4.0 will be installed!"; break;;
		"2") echo "Swift 3.1 will be installed!"; break;;
		*) echo "Don't understand your answer, try again!"; sleep 3;;
	esac
	echo "------------------------------------------------------------------"
done


# here is link and hash for downloaded file, hash need if download will be interuppted but file keeps in folder
case $CURRENTDISTR in
        "16.04")
			if [ $swiftAns == "1" ]; then 
            	SWIFTLINK="https://swift.org/builds/swift-4.0-release/ubuntu1604/swift-4.0-RELEASE/swift-4.0-RELEASE-ubuntu16.04.tar.gz"
            	SWIFTFOLDER="swift-4.0-RELEASE-ubuntu16.04"
            	SWIFTARCHIVEHASH="17b4c8ccefb828df26c77028230b6971" # this hash is for 16.04 and swift 4.0
			else 
            	SWIFTLINK="https://swift.org/builds/swift-3.1-branch/ubuntu1604/swift-3.1-DEVELOPMENT-SNAPSHOT-2017-06-14-a/swift-3.1-DEVELOPMENT-SNAPSHOT-2017-06-14-a-ubuntu16.04.tar.gz"
            	SWIFTFOLDER="swift-3.1-DEVELOPMENT-SNAPSHOT-2017-06-14-a-ubuntu16.04"
            	SWIFTARCHIVEHASH="33fce9254c858ca9756afc9e63d9b343" # this hash is for 16.04 and swift 4.0
			fi 
        ;;  
        "16.10"| "17.04" | "17.10") # temporary for support newwer versions of ubuntu

			if [ $swiftAns == "1" ]; then 
				SWIFTLINK="https://swift.org/builds/swift-4.0-release/ubuntu1610/swift-4.0-RELEASE/swift-4.0-RELEASE-ubuntu16.10.tar.gz"
            	SWIFTFOLDER="swift-4.0-RELEASE-ubuntu16.10"
            	SWIFTARCHIVEHASH="884b4b0dd32945e1c5d9676f79d8dcdc"
			else 
				SWIFTLINK="https://swift.org/builds/swift-3.1-branch/ubuntu1610/swift-3.1-DEVELOPMENT-SNAPSHOT-2017-06-14-a/swift-3.1-DEVELOPMENT-SNAPSHOT-2017-06-14-a-ubuntu16.10.tar.gz"
            	SWIFTFOLDER="swift-3.1-DEVELOPMENT-SNAPSHOT-2017-06-14-a-ubuntu16.10"
            	SWIFTARCHIVEHASH="e65c5f705bfb32d654cdf7e682d714bc"
			fi
            ;;         
        *)
            echo "Something happens wrong! try it again" 
			echo "If it continues contact with author: $AUTHORLINK"
            exit 1
            ;;
esac

# creating working dir, installing swift 
if [ ! -d $DOWNLOADFOLDER ]; then 
	mkdir $DOWNLOADFOLDER
fi 

if [ ! -e $DOWNLOADFOLDER/$SWIFTFILE ]; then 
	wget -O $DOWNLOADFOLDER/$SWIFTFILE $SWIFTLINK
fi

cd $DOWNLOADFOLDER
DOWNLOADHASH=`md5sum $SWIFTFILE | awk '{print $1}'`

echo "Checking hash of downloaded file..."

if [ $ARG1 == "--silent" ]; then 
	echo "bypassing hash checksum..."
else 
	if [ $SWIFTARCHIVEHASH != $DOWNLOADHASH ]; then 
		echo "+------------------------------------------------------+"
		echo "| Wrong file's hash! Maybe download was interupted     |"
		echo "| Please try again! To by pass hash verification use   |"
		echo "| --silet <== argument                                 |"
		echo "+------------------------------------------------------+"
		exit 1
	fi
fi 

tar -xzvf $DOWNLOADFOLDER/$SWIFTFILE 

if [ ! -d $DOWNLOADFOLDER/$SWIFTFOLDER ]; then
	echo "Extracted folder not found! Try again"; 
	exit 1 
else 
	cp -R $DOWNLOADFOLDER/$SWIFTFOLDER $HOME
fi

# setup variables to understand that swift is installed
if [ ! -d $HOME/$SWIFTFOLDER ]; then 
	echo "Swift folder with bin not found! Something wrong, try again!"
	exit 1
fi 

export PATH=$HOME/$SWIFTFOLDER/usr/bin:$PATH
echo "export PATH=$HOME/$SWIFTFOLDER/usr/bin:$PATH" >> $HOME/.profile
source $HOME/.profile
echo "Installation Done! Wait... 5s"
sleep 5

# checking of installed swift right now

#if [ -x "$(command -v $FINDSWIFT)" ]; then
#	CURRENTSWIFT=command -v $($FINDSWIFT | awk '{print $3}') || { echo "0.0"; }
#else 
#	echo "Oops! i cannot find installed swift"
#	echo "try to reboot "	
#fi 

clear
echo "+--------------------------------------+"
echo "| ok, let's try swift in action!"
echo "| ==> `swift --version` "
echo "+--------------------------------------+"
echo "Can you see version of swift compiler? [y/n]"
read compAns

echo "+------------------------------------------------+"
echo "| I found two best IDEs for programming on swift |" 
echo "| Sublime text editor 3 with plugins and         |"
echo "| Microsoft Visual code editor with plugins      |"
echo "+------------------------------------------------+"
echo "Do you want install Sublime text editor 3? [y/n]"
read subAns

case $subAns in 
	[Yy]* ) 
		echo "Downloading Sublime 3 editor"
		wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
		sudo apt-get install apt-transport-https >> /dev/null
		echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
		sudo apt-get update >> /dev/null
		echo "Installing Sublime 3 editor"
		sudo apt-get install sublime-text
	;;
esac 

echo "Do you want install Visual Code edit? [y/n]"
read visAns

case $visAns in 
	[Yy]* ) 
		echo "Downloading Visual Code editor"
		wget -O $DOWNLOADFOLDER/"VisualCodeEditor.deb" "https://go.microsoft.com/fwlink/?LinkID=760868"
		sudo dpkg -i $DOWNLOADFOLDER/"VisualCodeEditor.deb"
	;;
esac 


case $compAns in
	[Yy]* )
		rm -R $DOWNLOADFOLDER
		echo "OK! Deleting temp folder "
	;;
	*)
		echo "Temporary folder keeped! You can delete in manualy"
	;;
esac 

echo ""
echo "You need a reboot to reload your profile file!"
echo "Do you want a reboot? [y/n]"
read ansReboot 

echo "+--------------------------------------------------------+"
echo "| Author & issues:         $AUTHORLINK" 
echo "| Swift official:          https://swift.org"
echo "| Modules for swift (SPM): https://packagecatalog.com/"
echo "+--------------------------------------------------------+"
# finishing installation...

case $ansReboot in 
	[Yy]* )
		echo "Rebooting... wait 5s"
		sleep 5
		sudo shutdown -r now
	;;
	* ) 
		echo "Execution Done!"
		echo "Good luck, buy!"
	;;
esac 

# Done.......
