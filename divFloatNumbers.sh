#!/bin/bash

#DESCRIPTION
	# IMPLEMENT FLOAT DIVIDE
	# TAKE 3 PARAMS:
	# FIRST  PARAM: divide
	# SECOND PARAM: divisor
	# THIRD  PARAM: precision
	# float number must have less then 32 integer symbols and 32 symlobs after float point
	# int number must have less then 64 symbols


divide=$1
divisor=$2
precision=$3

# float point position in number
firstNumFloatPointPos=-1
secondNumFloatPointPos=-1

# need if we have number like: 1.0000002
fnZeroPos=-1
snZeroPos=-2

# contain divide operation result
declare -a result

# @[brief:] 	print result to display
# @[params:]	none
# @[retrun:] 	none
printResult()
{
	flag=0
	strResult=''
	flStr=''
	for x in "${result[@]}"; 
	do
		if [ $flag -eq 0 ];
		then
			strResult+=$x
		else
			flStr+=$x
		fi
		
		if [ "$x" == '.' ];
		then
			flag=1;
		fi
	done

	strResult=$strResult${flStr:0:$precision}

	echo "strResult = $strResult"
	#echo -e "\n"
}

# @[brief:]		mult number by 10^n  
# @[params:]	$1 - n; $2 - number
# @[retrun:]	number $2 mult by 10^$1
pow()
{
	local num=$2
	for((i=1;i<$1;i++))
	{
		num=$((num*10))
	}

	echo "$num"
}

# @[brief:]		find index of symbol '.' in number
# @[params:]	$1 - substr, $2 - number
# @[retrun:]	none
findFloatPointPos()
{
	if [ "$1" != "$2" ]; 
	then
		fp_pos=${#1}
		firstNumFloatPointPos=$fp_pos
	fi

	if [ "$3" != "$4" ]; 
	then
		fp_pos2=${#3}
		secondNumFloatPointPos=$fp_pos2;
	fi
}

findZeroPos()
{
	if [[ "$2" != "$1" && "$2" != "" ]];
	then
		zp=${#1}
		fnZeroPos=$zp
	fi
}


# @[brief:]		div 2 int numbers
# @[params:]	$1 - divide, $2 - divisor
# @[retrun:]	none
divInt()
{
	local integer=$(($1/$2))
	result+=( [0]=$integer [1]='.' )
}

# @[brief:]		div 2 float numbers
# @[params:]	$1 - divide, $2 - divisor
# @[retrun:]	none
divFloat()
{
	local float=$1
	local cnt=0
	local position=$2
	local flRes=0
	local mult=$precision;

	while [ $cnt -lt $precision ]; 
	do
		if [ $float -ge $divisor ]; 
		then
			local divRes=0
			divRes=$((float/$divisor))
			divRes=$(pow $mult $divRes)
			flRes=$((flRes+divRes))
			float=$(( ($float%$divisor)*10 ))
			mult=$((mult-1))
		fi
		cnt=$((cnt+1))
	done

	result+=( [$((pos+$cnt))]=$flRes )
}

# @[brief:]		div integer numbers
# @[params:]	
# @[retrun:]
divIntNumbers()
{
	divInt $divide $divisor
	local irreg=$(($divide%$divisor))
	local pos=2
	local cnt=0
	# if no float after div, then conplement reslt by zero
	# else do float part div
	if [ $irreg -eq 0 ]; 
	then
		for x in $(seq 1 $precision); do
			result+=( [$x]=0 )
		done
	else
		while [ $cnt -ne $precision ]; 
		do
			irreg=$((irreg*10))

			if [ $irreg -ge $divisor ]; 
			then
				result+=( [$(($pos+$cnt))]=$(($irreg/$divisor)) )
				irreg=$(($irreg%$divisor))
			else 
				result+=( [$(($pos+$cnt))]=0 )		
			fi
		
			cnt=$((cnt+1))
		done
	fi
}

divFloatNumbers()
{
	# separate integer and float
	intPart=${divide:0:$firstNumFloatPointPos}
	floatPart=${divide:$((firstNumFloatPointPos+1))}
	divInt $intPart $divisor
	ir=$((intPart%divisor))

	local pos=2

	if [ $ir -ne 0 ];
	then
		floatPart=$ir$floatPart
	else
		local tmp="${floatPart%%[1-9]*}"
		findZeroPos $tmp $floatPart

		if [ $fnZeroPos -ne -1 ]; then
			floatPart=${floatPart:$((fnZeroPos))}
			for (( i = 0; i < $fnZeroPos; i++ )); do
				result+=( [$pos]=0 )
				pos=$((pos+1))
			done
		fi
	fi
	divFloat $floatPart $pos
}

div2FloatNum()
{
	# separate integer and float
	intPart=${divide:0:$firstNumFloatPointPos}
	floatPart=${divide:$((firstNumFloatPointPos+1))}
	intPartd=${divisor:0:$secondNumFloatPointPos}
	floatPartd=${divisor:$((secondNumFloatPointPos+1))}

	local moveSymbol=$((${#divisor}-$secondNumFloatPointPos-1))

	divide=$intPart${floatPart:0:$moveSymbol}'.'${floatPart:$((moveSymbol))}
	divisor=$intPartd${floatPartd:0:$moveSymbol}

	local tmp="${divide%%.*}"

	if [ "$tmp" != "$divide" ]; 
	then
		fp_pos=${#tmp}
		firstNumFloatPointPos=$fp_pos
	fi

	divFloatNumbers
}

Divide()
{
	if   [ $firstNumFloatPointPos -eq -1 ] && [ $secondNumFloatPointPos -eq -1 ]; then # if it is integer numbers 
		divIntNumbers
	elif [ $firstNumFloatPointPos -ne -1 ] && [ $secondNumFloatPointPos -eq -1 ]; then # if it is integer divisor and float divide 
		divFloatNumbers
	elif [ $firstNumFloatPointPos -ne -1 ] && [ $secondNumFloatPointPos -ne -1 ]; then # if it is integer numbers
		div2FloatNum
	fi
}

########SCRIPT BEGIN##############################

# check count of input parameters
if [ $# -ne 3 ];
then
	echo "ERROR! SKRIPT TAKE 3 PARAMS!!!"
	exit
fi
# check input numbers length
if [[ ${#1} -ge 63 || ${#2} -ge 63 ]];
then
	echo "To big numbers! Can't execute divide!"
	exit
fi

# ckeck if divisor not equal 0
if [ "$divisor" == "0" ]; then						
	echo "Can't divide by zero!"					
	exit											
fi 													

# need to separate int part of number and float
d1Tmp="${divide%%.*}"
d2Tmp="${divisor%%.*}"
findFloatPointPos $d1Tmp $divide $d2Tmp $divisor	
													
Divide
printResult											