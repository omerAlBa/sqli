#!/usr/bin/python3

import re
import requests

# declare functions
def get_list_element(elements:list, pattern:str, convert=None):
    for element in elements:
         result = re.search(pattern, element)
         if (result):
             parsed_result = result.string
             
             if (convert == 'dict'):
                 obj = {}
                 key_value = parsed_result.split(":",1)
                 obj[key_value[0].lower()] = key_value[1].lstrip()
                 return obj

             return parsed_result

# get file from request
request_path="/tmp/request_file.txt"

with open(f"{request_path}","r") as file:
    raw_file_content = file.read()
    file_content = raw_file_content.split('\n\n',1)

    request_conetnt = {}
    request_conetnt['header'] = file_content[0].split('\n')
    request_conetnt['body'] = file_content[-1]
    
    # get url and path
    response = get_list_element(elements=request_conetnt['header'], pattern='Referer', convert='dict')
    print(f"element -> {response['referer']}")
    
    print('---')

