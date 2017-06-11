#!/bin/bash


#DESCRIPTION
	# SCRIPT DYSPLAY COPY FILE PROGRESS
	# TAKE 2 PARAMS: source directory and destination directory
	# FIRST  PARAM:  source directory 
	# SECOND PARAM:  destination directory

# check number of input params
if [ $# -ne 2 ];
then
	echo "ERROR! Script take 2 params!"
	exit
fi

# check if source directory exist
if [ ! -d "$1" ]
then
	echo "No such file or directory!"
	exit
fi

# check if destination direcrtory exist
if [ ! -d "$2" ]; 
then
	mkdir $2
fi


totalBytes=0

for i in `ls $1`
do
	totalBytes=$(($totalBytes+$(stat -c%s "$1/$i")))
done

#echo "Bytes=$totalBytes" 


totalCopyBytes=0
tmp=0

printf "["

for i in `ls $1`
do
	currentFileSize=$(stat -c%s "$1/$i")
	copyFileSize=0
	# echo "Current=$currentFileSize"
	cp $1/$i $2/$i &
	pid=$!

	# check if copy process still runnig
	while kill -0 $pid 2> /dev/null ; 
	do
		if [ $currentFileSize -gt $copyFileSize ]; then
			sleep 0.1
			copyFileSize=$(stat -c%s "$2/$i")
			tmp=$(($totalCopyBytes+$copyFileSize))
	 		copy_percent=$((( 100 * $tmp ) / $totalBytes))

			iter=40
			clear
			printf "["
			while [ $iter -lt $copy_percent ] ;
			do
				printf "#"
				iter=$(($iter+1))
			done
		fi
	done

	totalCopyBytes=$(($totalCopyBytes+$copyFileSize))
	#echo "totalCopyBytes=$totalCopyBytes"
done

printf "]"
printf " copy done!\n"