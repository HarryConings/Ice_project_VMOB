from soap_calls_test import agresso_client
from client_getter_test import Customer



customer = Customer('60073024369', '203')
agresso_client('60073024369', customer)

#de bestaande aandoeningen ophalen
# diseases = agresso_client.diseases
# counter = 0
# diseases_name = []
# diseases_text = []
  
# for i in diseases['disease']:
#     if diseases['disease'][counter]['name_insurance'] != '':
        
#         diseases_name.append(diseases['disease'][counter]['name_insurance'])
#         diseases_text.append(diseases['disease'][counter]['text']) 

# print('======================================================')
# print(counter)
# print(diseases_name)
# print(diseases_text)


print(agresso_client.agresso_id)