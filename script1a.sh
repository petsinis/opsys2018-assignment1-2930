#!/bin/bash


SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"

input=$1
echo "Your input is $input."


if [[ $input == *"/"* ]]
then
	if [ -f "$input" ]
	then
		echo "The $input file found."
		exec < "$input"
	else 
		echo "The $input file didn't found."	
		exit
	fi
else			
	if [ -f ""$SCRIPTPATH"/$input" ]
	then
		echo "The $input file found at scipt's path: $SCRIPTPATH."
		exec < "$SCRIPTPATH"/$input
	else
		echo "The $input file didn't found at scipt's path: $SCRIPTPATH , try again and give the full name of the txt."	
		exit

	fi
fi


terminal='tty'


if [ -f ""$SCRIPTPATH"/readList" ]
then
	echo ""
else
	echo "Make a readList file for saving the urls."	
	touch "$SCRIPTPATH"/readList
	ex=$?
	if [[ "$ex" != '0' ]]
	then
		echo "Cannot make readList ,try to run script1a.sh again."
	fi
fi

while read line; do
	    flag=0;
	    for word in $line ; do
		initial="$(echo $word | head -c 1)"	
		if [ $initial == '#' ]
		then
		   flag=1;	
		   break
		fi		
	    done
	

	if [ $flag == '0' ]
	then
		
		num=$(grep -i -n -c "$line" "$SCRIPTPATH"/readList)	
		name="$line"	
		name="${name///}"
		if [ "$num" == '0' ] 
		then 
			echo "$line">>"$SCRIPTPATH"/readList 
			echo "$line INIT"
			wget -q -O "$SCRIPTPATH"/"$name"  $line
			if ! [ $? -eq 0 ] ; then
    				echo "$line FAILED" >&2 
				> "$SCRIPTPATH"/"$name" 
				
			fi
			continue
			
		fi		
		
		
		if [[ -s "$SCRIPTPATH"/"$name" ]] 
		then
			md5b=`md5sum "$SCRIPTPATH"/"$name" | awk '{ print $1 }'`
			wget -q -O "$SCRIPTPATH"/"$name" $line
			temp=$?
			if [ "$temp" = '0' ]
			then
				md5a=`md5sum "$SCRIPTPATH"/"$name"  | awk '{ print $1 }'`
				if [ "$md5a" != "$md5b" ] 
				then
					echo "$line"
				fi
			else
				> "$SCRIPTPATH"/"$name"     				
				echo "$line FAILED" >&2 
				echo "$line"
			
			fi

		else
			wget -q -O "$SCRIPTPATH"/"$name" $line
			temp=$?			
			if [ "$temp" = '0' ]
			then 
				echo "$line"		        
			else
    				echo "$line FAILED" >&2 
				> "$SCRIPTPATH"/"$name" 		
			fi
		fi
	fi
done


