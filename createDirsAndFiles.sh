#!/bin/bash

#DESCRIPTION
	# SCRIPT CREATE A DIRECTORIES AND FILES INSIDE
	# TAKE 2 PARAMS:
	# FIRST  PARAM: number of directoris
	# SECOND PARAM: number of files inside of each directory

# GLOBAL VARIABLES
	script_name=$0
	func_ret_val=0 # contain function return value

	SUCCESS=0 # functions return 0 if complete success
	FAILURE=1 # else return 1


# @description: check number of input script params
# @param $1: number of script input params
# @return": $SUCCESS if param $1 equal to 2, else $FAILURE
checkParamsCount() 
{
	if [ $1 -ne 2 ]; then
		echo "Script $script_name take 2 params!"
		func_ret_val=$FAILURE
	else 
		func_ret_val=$SUCCESS
	fi
}

# @description: functions check wether the input params great then 0
# @param $1: number of directories
# @param $2: number of files
# @return: SUCCESS if param $1 equal to 2, else return FAILURE
checkInputParams() {
	if [ "$1" -le 0 ] || [ "$2" -le 0 ]; then
		echo "Params must be great then 0"
		func_ret_val=$FAILURE
	else 
		func_ret_val=$SUCCESS
	fi
}

# @description: create directories and files inside
# @param $1: number of directories
# @param $2: number of files
createDirsAndFiles() {
	for dirIndex in $(seq 1 $1); do
		mkdir -p Boichuk/dir$dirIndex

		for fileIndex in $(seq 1 $2); do
			printf "" > Boichuk/dir$dirIndex/file$fileIndex
		done	
	done
}

# @description: exit from script
# @param $1: exit code 
quit()
{
	exit $1
}

# SCRIPT BEGIN
	checkParamsCount $#
	
	# if passed 2 params
	if [ $func_ret_val -eq $SUCCESS ]; then
		checkInputParams $1 $2

		#create dirs and files if checkInputparams return SUCCESS
		if [ $func_ret_val -eq $SUCCESS ]; then
			createDirsAndFiles $1 $2
		else
			quit $FAILURE
		fi
	else 
		quit $FAILURE
	fi

quit $SUCCESS
# SCRIPT END
