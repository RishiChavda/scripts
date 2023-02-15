#!/bin/bash

function mkd
{
	# Create a new folder if it doesn't exist then navigate to it
	if [ ! -d $1 ]
	then
		mkdir -p $1 && cd $1 && echo "Folder created "`pwd`
	else
		cd $1
	fi
}

function mkp
{
	# Create a new project folder, navigate into it, and create a diff folder
	mkdir $1 && cd $1 && mkdir ./diff && touch $1"_notes" && echo "New project "`pwd`
}


function cleandiffs
{
	# Delete all empty files/directories and all diffs in the _diff folder
	find ./diff/* -size 0 -delete && find ./diff/* -type d -empty -delete && rm *.diff
}

function cleanempty
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

function mydef
{
	# Display list of custom commands.
	echo "Custom functions in user script (~/.custom.sh)."

	echo -e "\r\nFile and Folder Management"
	echo -e "- mkcd \t\t\tCreate a new folder and navigate into it."
	echo -e "- mkcdd \t\tCreate a new folder, navigate into it, and create a diff folder."
	echo -e "- cleanthis \t\tDelete all empty files in current folder."
	echo -e "- cleandiffs \t\tDelete all empty files and directories in the diff folder."
	echo -e "- sf \t\t\tSearch all files in current directory recursively for $1 and output with line numbers."
	echo -e "- sall \t\t\tSearch all files and folders for $1."
	echo -e "- cfile \t\tCheck if file exists."

	echo -e "\r\nProject Management"
	# diff creation
	echo -e "- log \t\t\tCreate log file if doesn't exist ('-a' to output, '-c' to clean)"

	echo -e "\r\nMisc"
	echo -e "- mkr\t\t\t\Create aliases by setting $1 to $2."
	echo -e "- hfind \t\tSearches command history cache for $1."
	echo -e "- hcommon \t\tDisplay most commonly used commands."
	echo -e "- addtime \t\tAdd an live clock to the top right of the terminal window."
	echo -e "- swap \t\t\tSwaps files $1 ands $2."

	echo -e "- mydef \t\tDisplay list of custom commands."
	echo -e "- startup \t\tStartup display, information output and alias creation."
}

function startup
{
	# Clean, display system information and messages, then create aliases.
	shopt -s expand_aliases
	alias dev="cd /home/rishi/devspace"
	alias scripts="cd /home/rishi/devspace/scripts"
	alias home="cd /../../mnt/c/Users/rishi/Desktop"

	date +%Y\ %B\ %d\ %A | tr a-z A-Z
	cal -3

	echo -e "DISK"
	df -h . | awk '{print $3, $4, $5}' | column -t

	dev
	pwd
	ls

}

startup
