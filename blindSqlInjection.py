#!/usr/bin/python3

import re
import requests
from urllib.parse import parse_qsl

# declare functions.
#.fetch element from the list
#├─ Parameter:
#├── convert -> which format is needed. (currently avaible dict)
#├── elements -> header list
#└── pattern -> which pattern should looked for
def get_list_element(elements:list, convert=None, key=None):
    response = { "succeed":  None, "headers": {} }
    
    for element in elements:
        try:
         if (convert == 'dict' and not re.search('POST|GET',element)):
             key_value = element.split(":",1)
             response[key][key_value[0].lower()] = key_value[1].lstrip()
        except (KeyError):
             raise ValueError(f"get_list_element failed at the value pair {key_value}")
    
    response['succeed'] = True
    return response

#.fetch methode from the list
#├─ Parameter:
#└── headers -> fetch http methode
def extract_http_methode(headers):
    if ( not headers ):
        raise ValueError("The 'header' key is missing in the request dictionary.")
    
    response = { "succeed": None }

    try:
        response['methode'] = request_conetnt['header'][0].split()[0]
        response['succeed'] = True
        return response
    except (KeyError, IndexError):
        raise ValueError("The 'methode' fetched failed!")


# get file from request
request_path="/tmp/request_file.txt"

with open(f"{request_path}","r") as file:
    raw_file_content = file.read()
    file_content = raw_file_content.split('\n\n',1)

    request_conetnt = {}
    request_conetnt['header'] = file_content[0].split('\n')
    request_conetnt['body'] = file_content[-1]
    
    # get url and http methode
    response = get_list_element(elements=request_conetnt['header'], convert='dict', key='headers')
    if ( not response['succeed']):
        raise ValueError("Url can't be fetched from the provided file!.")


    # set url and methode
    request_conetnt['url'] = response['headers']['referer']
    request_conetnt['methode'] = extract_http_methode(request_conetnt['header']).get('methode')
    request_conetnt['headers'] = response['headers']
    request_conetnt['data'] = dict(parse_qsl(request_conetnt['body'].rstrip()))
    
    # request
    response = requests.request(
            method=str(request_conetnt['methode']),
            url=str(request_conetnt['url']),
            headers=request_conetnt.get('headers'),
            data=request_conetnt['data'],
            verify=False,
            )

    print(response.text)

