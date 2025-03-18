#!/usr/bin/python3

import re
import requests

# declare functions.
#.fetch element from the list
#├─ Parameter:
#├── convert -> which format is needed. (currently avaible dict)
#├── elements -> header list
#└── pattern -> which pattern should looked for
def get_list_element(elements:list, pattern:str, convert=None):
    response = { "succeed":  None }
    
    for element in elements:
         response['match'] = re.search(pattern, element, re.IGNORECASE)
         
         if (response['match']):
             response['match'] = response['match'].string
             response['succeed'] = True
         
         if (convert == 'dict' and response['succeed']):
             key_value = response['match'].split(":",1)
             response['key'] = key_value[1].lstrip()
             break

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
    response = get_list_element(elements=request_conetnt['header'], pattern='referer', convert='dict')
    if ( not response['succeed']):
        raise ValueError("Url can't be fetched from the provided file!.")

    # set url and methode
    request_conetnt['url'] = response['key']
    request_conetnt['methode'] = extract_http_methode(request_conetnt['header'])

    # request
    response = requests.request(
            method=str(request_conetnt['methode']),
            url=str(request_conetnt['url']),
            headers=request_conetnt.get('header', {}),
            data=request_conetnt.get('body', None),
            verify=False
            )

    print(response.text)

