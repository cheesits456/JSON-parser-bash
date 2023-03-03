#!/usr/bin/env bash
[ -z "$1" ] && exit 1
input=$(cat "$1")
output=""
i=0

exit=0
var_name=()
level=0
in_value=false
in_key=false
in_array=false
after_key=false
array_index=0
keyname=""
value=""
last_char=""
while [ $exit == "0" ]; do
	char=${input:i:1}
	case $char in
	"\"")
		if [ $in_key == true ]; then
			in_key=false
			var_name+=("$keyname")
			keyname=""
		elif [ $in_value == true ]; then
			if [ "$last_char" == "\\" ]; then
				value+="\\\""
			else
				in_value=false
				output+="$(
					IFS=_
					echo "${var_name[*]}"
				)=\"$value\"\n"
				value=""
			fi
		else
			if [ $after_key == false ]; then
				in_key=true
			else
				in_value=true
			fi
		fi
		;;
	":")
		if [ $in_key == false ] && [ $in_value == false ]; then
			if [ $after_key == false ]; then
				after_key=true
			fi
		elif [ $in_value == true ]; then
			value+=":"
		fi
		;;
	",")
		if [ $in_key == false ] && [ $in_value == false ]; then
			after_key=false
			unset "var_name[-1]"
		fi
		;;
	*)
		if [ $in_key == true ]; then
			keyname+=$char
		elif [ $in_value == true ]; then
			value+=$char
		fi
		;;
	esac
	last_char=$char
	i=$(("$i" + 1))
	[ $((${#input} - 1)) == $i ] && exit=1
done
echo -en "$output"
