#!/bin/bash

function mkcd
{
	# Create a new folder and navigate into it
	mkdir $1 && cd $1
	echo "Folder created - "`pwd`
}

function mkcdd
{
	# Create a new project folder, navigate into it, and create a diff folder
	mkdir $1 && cd $1 && mkdir ~/main/_diffs/$1 && echo "Folder and Diff folder created - "`pwd`
}

function mkde
{
	# create folder if it doesn't exist
	if [ ! -d $1 ]; then
		mkdir -p $1 && echo "Folder created - "$1
	fi	
}

function cleandiffs
{
	# Delete all empty files/directories and all diffs in the _diff folder
	find ~/main/_diffs/* -size 0 -delete && find ~/main/_diffs/* -type d -empty -delete && rm *.diff
}

function cleanthis
{
	# Delete all empty files/directories in current folder
	find . -type d -empty -delete
	find . -size 0 -delete
}

function log
{
	# Create log file if doesn't exist ('-a' to output, '-c' to clean) and pipeable ("|")
	if [ ! -f ~/main/_misc/_log ]
	then
		echo "[null]"
		touch ~/main/_misc/_log
	fi
	if [ "$1" = "-a" ]
	then
		cat ~/main/_misc/_log
	elif [ "$1" = "-c" ] 
	then
		rm ~/main/_misc/_log
		touch ~/main/_misc/_log
	else
		if [ -z "$1" ]
		then
			read logData
			echo "\r\n"`date +%Y_%m_%d`"\t " $logData >> ~/main/_misc/_log
		else
			oldIFS=IFS
			IFS=' '
			echo "\r\n"`date +%Y_%m_%d`"\t " $@ >> ~/main/_misc/_log
			IFS=oldIFS
		fi
	fi
}

function sf
{
	# Search all files in current directory recursively for $1 and output with line numbers
	grep -rnw '.' -e $1
}


function nta
{
	# Global regression run with success/fail filtering ('-o' to output to folder-named file).
	echo "Global regression run with success/fail filtering ('-o' to output to folder-named file)."
	echo -e "\n\e[1m\e[41m TODO \e[0m\n"
	#`ntt t 2&1> | tee | sed 's/OK/\n\e[1m\e[41m OK \e[0m\n/g; s/NEW/\n\e[1m\e[41m NEW \e[0m\n/g; s/FAILED/\n\e[1m\e[42m FAILED \e[0m\n/g;'`
}

function addtime
{
	# Add an live clock to the top right of the terminal window.
	while sleep 1; do tput sc; tput cup 0 $(($(tput cols)-29)); date; tput rc; done &
}

function riff
{
	# Creates diff in '_diffs' folder ('-a' for all repositories).
	if [ "$1" = "-a" ]
	then
		projname=`basename "$PWD" |  tr a-z A-Z`
		echo "Project "$projname
		mkde ~/main/_diffs/$projname
		echo "diffs/"$projname
		for d in `find -maxdepth 1 -name "cm*" -type d`; do
			cd $d > /dev/null
			packname=`basename "$PWD" |  tr a-z A-Z`
			diffname=$projname"_"$packname"_"`date +%Y_%m_%d_%H_%M_%S`".diff"
			hg diff > ~/main/_diffs/$projname/$diffname
			echo -e "\t"$packname "DIFF created - "$diffname
			cd - > /dev/null
		done
	else
		cd ../ > /dev/null
		projname=`basename "$PWD" |  tr a-z A-Z`
		cd - > /dev/null
		packname=`basename "$PWD" |  tr a-z A-Z`
		diffname=$projname"_"$packname"_"`date +%Y_%m_%d_%H_%M_%S`".diff"
		echo "Project "$projname
		echo "Package "$packname
		echo "diffs/"$projname/$diffname
		hg diff > ~/main/_diffs/$projname/$diffname
		echo "DIFF created - diffs/"$projname"/"$diffname
	fi
}

function sall
{
	# Searches for filenames containing '$1'.
	echo -e "Searching for '"$1"'"
	locate $1
}

function swap
{
	# Swaps files '$1' ands '$2'.
	cp $1 ~/TMP_$1
	cp $2 $1
	mv ~/TMP_$1 $2
}

function cfile
{
	# Check if file exists.
	if [ -f $1 ]
	then
		echo "1"
	else
		echo "0"
	fi
}

function hfind
{
	# Searches command history cache for '$1'.
	history | grep $1
}

function hcommon
{
	# Display most commonly used commands.
	history | awk '{CMD[$2]++;count++;}END { for (a in CMD)print CMD[a] " " CMD[a]/count*100 "% " a;}' | grep -v "./" | column -c3 -s " " -t | sort -nr | nl |  head -n10
}

function backup
{
	# Run 'riff' in each project folder and save in '_backups'.
	cd ~/main
	result=""
	for e in `ls`
	do
		dd=`date +%Y_%m_%d_%A | tr a-z A-Z`
		mkdir -p ~/main/_backups/$dd
		if ! [[ $e =~ ^_.* ]] && [[ -d $e ]]
		then
			cd $e
			projname=`basename "$PWD" |  tr a-z A-Z`
			result+="\r\n"$projname
			for d in `find -maxdepth 1 -name "cm*" -type d`; do
				cd $d > /dev/null
				packname=`basename "$PWD" |  tr a-z A-Z`
				diffname=$projname"_"$packname"_"$dd".diff"
				hg diff > ~/main/_backups/$dd/$diffname
				cd - > /dev/null
				result+="\r\n\t"$packname
			done
			cd ..
		fi
	done
	echo -e $result
	echo $dd$result >> ~/main/_misc/_msgs
	cd ~/main
}

function daily
{
	# Run 'backup', runs 'cleanthis' in _diffs and _backups then adds outputs in '_misc/_msgs').
	msgs
	clear
	echo -e "\r\nDRSTART"`date +%Y_%m_%d_%A` >> ~/main/_misc/_msgs
	backup >> ~/main/_misc/_msgs
	echo "\r\nDaily backup completed." >> ~/main/_misc/_msgs
	cd ~/main/_diffs
	cleanthis >> ~/main/_misc/_msgs
	cd ~/main/_backups
	cleanthis >> ~/main/_misc/_msgs
	echo "\r\nDaily clean completed." >> ~/main/_misc/_msgs
	echo "\r\nDREND" >> ~/main/_misc/_msgs
	cd ~/main
}

function msgs
{
	# Create msgs file if it doesn't exist then outputs the contents.
	if [ ! -f ~/main/_misc/_msgs ]
	then
		touch ~/main/_misc/_msgs
	fi
	if [ -s ~/main/_misc/_msgs ]
	then
		cat ~/main/_misc/_msgs && rm ~/main/_misc/_msgs
	else
		echo "No messages."
	fi
}

function mydef
{
	# Display list of custom commands.
	echo "Custom functions in user script (~/.custom.sh)."

	echo -e "\r\nDirectory"
	echo -e "- mkcd \t\t\tCreate a new folder and navigate into it."
	echo -e "- mkcdd \t\tCreate a new folder, navigate into it, and create a diff folder."
	echo -e "- mkde \t\t\tCreate folder if it doesn't exist"

	echo -e "\r\nClean"
	echo -e "- cleanthis \t\tDelete all empty files in current folder."
	echo -e "- cleandiffs \t\tDelete all empty files and directories in the diff folder."

	echo -e "\r\nMisc"
	echo -e "- sf \t\t\tSearch all files in current directory recursively for $1 and output with line numbers."
	echo -e "- addtime \t\tAdd an live clock to the top right of the terminal window."
	echo -e "- build \t\tRuns 'hamstr' but only shows compilation errors and final status."
	echo -e "- nta \t\tGlobal regression run with success/fail filtering ('-o' to output to folder-named file)."
	echo -e "- riff \t\t\tCreates diff in '_diffs' folder ('-a' for all repositories)."
	echo -e "- sall \t\t\tSearch all files and folders for $1."
	echo -e "- swap \t\t\tSwaps files $1 ands $2."
	echo -e "- cfile \t\tCheck if file exists."
	echo -e "- mkr\t\t\t\Create aliases by setting $1 to $2."
	echo -e "- hfind \t\tSearches command history cache for $1."
	echo -e "- hcommon \t\tDisplay most commonly used commands."
	echo -e "- backup \t\tRun 'riff' in each project folder and save in '_backups'"
	echo -e "- daily \t\tRun 'backup' and 'cleanthis' (all output in '_misc/_msgs')"
	echo -e "- log \t\t\tCreate log file if doesn't exist ('-a' to output, '-c' to clean)"
	echo -e "- nce \t\t\tSSH in to Nice Linux machine."
	echo -e "- msgs \t\t\tCreate msgs file if it doesn't exist then outputs the contents."
	echo -e "- mydef \t\tDisplay list of custom commands."
	echo -e "- startup \t\tStartup display, information output and alias creation."
}

function startup
{
	# Clean, display system information and messages, then create aliases.

	date +%Y\ %B\ %d\ %A | tr a-z A-Z
	echo -e "\r\n"

	alias dev="cd /home/rishi/devspace"
	alias home="cd ~/../../mnt/c/Users/rishi/Desktop"

	clear
	date +%Y\ %B\ %d\ %A | tr a-z A-Z
	echo -e "\r\n"
	cal -3

	echo -e "\r\n\r\nDISK"
	df -h . | awk '{print $3, $4, $5}' | column -t

	cd ~/main
	echo -e "\r\n\r\n"`ls`

}

# extension of 'cat' that gives file name/size/datemodified and contents of a file ('-a' for all files in a folder)

# 'qc' quickly creates a copy of a file in the main folder for ease of access

# Look into 'df -h'


startup
