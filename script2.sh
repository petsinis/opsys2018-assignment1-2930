#!/bin/bash

find_all_adresses()
{
	terminal='tty'
	exec < $text
	flag=0	
	while read line; do		
		var=$(cut -c-5 <<< "$line")
		if [[ $var = "https" ]]
		then
			adress=$line;
			flag=1;
			break;
		fi
	done
	
}


clone_adress()
{ 
	if [[ $adress == *".git" ]]
	then
		tt=$(echo "$adress" | sed -e 's/.*\/\(.*\).git/\1/')
	else
		tt=$(echo "$adress" | sed -e 's/.*\/\(.*\)/\1/')
	fi
	

	git clone --quiet  $adress "$SCRIPTPATH"/assignments/"$tt" &>/dev/null
	
	ex=$?
	if [[ "$ex" == '0' ]]
	then
		echo "$adress: Cloning OK"
		name_of_repo[k]=$tt
		k=$((k+1))
	else
		echo "$adress: Cloning FAILED" >&2 
		rm -r "$SCRIPTPATH"/assignments/"$tt" &>/dev/null
		
	fi
			
}

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"

input=$1
echo "Your input is $input"

if [[ $input == *"/"* ]]
then
	if [ -f "$input" ]
	then
		echo "The $input file found."
		rm -rf "$SCRIPTPATH"/extar/*	&>/dev/null		
		tar xf "$input" -C "$SCRIPTPATH"/extar &>/dev/null
	else 
		echo "The $input file didn't found."	
		exit
	fi
else			
	if [ -f ""$SCRIPTPATH"/$input" ]
	then
		echo "The $input file found at scipt's path: $SCRIPTPATH."
		rm -rf "$SCRIPTPATH"/extar/*	&>/dev/null		
		tar xf "$SCRIPTPATH"/$input -C "$SCRIPTPATH"/extar &>/dev/null
	else
		echo "The $input file didn't found at scipt's path: $SCRIPTPATH , try again and give the full name of the txt."	
		exit

	fi
fi


echo $(find "$SCRIPTPATH"/extar -name "*.txt") > "$SCRIPTPATH"/extar/listt

terminal='tty'
exec < "$SCRIPTPATH"/extar/listt

i=1
while read line; do
	for word in $line ; do		
		#echo "word is $word"
		array[i]=$word
		i=$((i+1))
	done
done	

j=$((i-1))

> "$SCRIPTPATH"/extar/gitrepos

mkdir "$SCRIPTPATH"/assignments &>/dev/null
rm -rf "$SCRIPTPATH"/assignments/*	&>/dev/null


k=1
for i in $(seq 1 1 $j)
do
	text=${array[i]}		
	find_all_adresses
	if [[ $flag = 1 ]]
	then		
		echo $adress >> "$SCRIPTPATH"/extar/gitrepos
			clone_adress	
	fi
done 



p=$((k-1))
for k in $(seq 1 1 $p)
do
	name=${name_of_repo[k]}
	
	num_of_dir=$(find "$SCRIPTPATH"/assignments/$name -not -path '*/\.*' -type d | wc -l)
	num_of_dir=$((num_of_dir-1))
	
	name_of_dir=$(find "$SCRIPTPATH"/assignments/$name -not -path '*/\.*' -type d )
	name_of_dir=$(echo $name_of_dir)	

	temp=""$SCRIPTPATH"/assignments/$name "$SCRIPTPATH"/assignments/$name/more"

	num_of_files=$(find "$SCRIPTPATH"/assignments/$name -not -path '*/\.*' -type f | wc -l)
	

	num_of_txt_files=$(find "$SCRIPTPATH"/assignments/$name -not -path '*/\.*' -name "*.txt" | wc -l)		
	
	name_of_txt_files=$(find "$SCRIPTPATH"/assignments/$name -not -path '*/\.*' -name "*.txt") 
	name_of_txt_files=$(echo $name_of_txt_files)
	temp2=""$SCRIPTPATH"/assignments/$name/dataA.txt "$SCRIPTPATH"/assignments/$name/more/dataB.txt "$SCRIPTPATH"/assignments/$name/more/dataC.txt"

	num_of_other_files=$(( num_of_files - num_of_txt_files ))
	

	echo "$name:"
	echo "Number of directories: $num_of_dir"
	echo "Number of txt files: $num_of_txt_files"
	echo "Number of other files: $num_of_other_files"
	

	
	if [[ "$name_of_dir" == "$temp"  ]] && [[ "$name_of_txt_files" == "$temp2" ]]	
	then
		echo "Directory structure is OK"
	else 
		echo "Directory structure is NOT OK" >&2 
	fi
done




