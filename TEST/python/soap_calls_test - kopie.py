# -*- coding: utf-8 -*-
"""
Created on Tue Aug 17 10:07:02 2021

@author: Tijs Conings
"""

from zeep import Client
from zeep.transports import Transport
from xml.etree import ElementTree
from settings_xml_inlezen_test import info_from_xml
from datetime import datetime
from varia_klassen import compare_insurances

class CustomTransport(Transport): 
    '''deze class zorgt ervoor dat het xml document juist wordt doorgegeven aan agresso'''
    
    def post_xml(self, address, envelope, headers): 
        
        message = ElementTree.tostring(envelope, encoding="unicode")  
        message = message.replace("&lt;", "<")  
        message = message.replace("&gt;", ">") 
        
        return self.post(address, message, headers)  
    
def agresso_client(external_reference, customer):
    '''eerst zoeken we met het rijksregisternummer naar het customer_id, daarna vullen we de juiste informatie van de AS400 in agresso in'''
    
    #info uit de xml halen die in soap moet worden meegegeven
    info_from_xml(r'P:\OGV\ASSURCARD_PROG\assurcard_settings_xml\Tijs.xml')
    
    company_code = info_from_xml.company_code
    ap_ar_type_klant = info_from_xml.ap_ar_type_klant
    payment_terms = info_from_xml.pay_terms
    # ap_ar_type_leverancier = info_from_xml.ap_ar_type_leverancier
    # assurcard_invoice_import_interface = info_from_xml.assurcard_invoice_import_interface
    # agresso_voucher_type = info_from_xml.agresso_voucher_type
    # credit_limit = info_from_xml.credit_limit
    # currency = info_from_xml.currency
    # tax_code = info_from_xml.tax_code
    # ap_account = info_from_xml.ap_account
    # gl_account = info_from_xml.gl_account
    # invoice_payment_delay = info_from_xml.invoice_payment_delay
    pay_method = info_from_xml.pay_method
    default_language = info_from_xml.default_language
    
    client_get = Client(wsdl = 'http://10.198.216.91//BusinessWorld-webservices/service.svc?CustomerService/Customer')
    
    #we halen de klant op uit agresso met het rijksregisternummer
    get = client_get.service.GetCustomers(customerObject = {'ExternalReference': external_reference, 'Company': company_code, 'FixedTaxSystem': 'false', 'FixedPaymentTerms': 'true', 
                                                         'SundryCustomer': 'false', 'CalculatePayDiscountOnTax': 'true', 'FixedCurrency': 'true', 
                                                         'CreditCheckOnHeadOffice': 'false', 'CreditLimit': '0', 'MaxCreditAge': '0', 'FixedPayMethod': 'false', 
                                                         'FixedPayRecipient': 'false', 'ExpiryDate': '1900-01-01T00:00:00', 'Priority': '0', 'FixedTaxCode': 'false'}, 
                                       customerDetailsOnly = 0, credentials = {'Username': 'WEBSERV', 'Client': 'VMOB', 'Password': 'WEBSERV'})

    client_post = Client(wsdl = 'http://10.198.216.91/BusinessWorld-webservices/service.svc?ImportService/ImportV200606', transport=CustomTransport())
    
    #uit de gekregen informatie van de get halen we de customer id
    customer_id = get['CustomerTypeList']['CustomerObject'][0]['CustomerID']
    
    #de customer id ophaalbaar maken voor andere klassen
    agresso_client.agresso_id = customer_id 
    
    #vaste data voor de post
    server_process_id = 'CS15'
    menu_id = 'BI192'
    variant = '7'
    
    #de data uit de as400
    name = (customer.data['name'] + ' ' + customer.data['last_name']).upper()
    e_mail_cc = 'geen'
    land_line = customer.phone_numbers['landline']
    mobile = customer.phone_numbers['mobile']
    external_ref = customer.data['nat_nr']
    
    #zien dat de verkorte naam de juiste lengte heeft
    short_name = (customer.data['name'] + customer.data['last_name'][0:3]).upper()
    
    if len(short_name) > 10:
        short_name = (customer.data['name'][0:7] + customer.data['last_name'][0:3]).upper()
    
    #kijk welke verzekering een IBAN bevat, anders standaard IBAN meegeven
    iban = 'BE18990000000065'
    
    for ins in customer.insurances:
        if ins['iban'] != '':
            iban = ins['iban']
            break
    
    #als er geen country code is dan geef je BE mee
    dom_country_code = 'BE'
    if customer.residence_adress['country'] != '':
        dom_country_code = customer.residence_adress['country'] #kijken of deze codes het juiste formaat hebben

    dom_adress = customer.residence_adress['street'] + " " + customer.residence_adress['house_number'] + ' ' + customer.residence_adress['bus_number'] 
    dom_place = customer.residence_adress['city']
    dom_zip_code = customer.residence_adress['postal_code']

    post_adress = customer.post_adress['street'] + " " + customer.post_adress['house_number'] + ' ' + customer.post_adress['bus_number'] 
    post_place = customer.post_adress['city']
    post_zip_code = customer.post_adress['postal_code']
    post_country_code = customer.post_adress['country']
     
    #als er geen email is geef je 'geen' mee
    e_mail = 'geen'
    if customer.data['email'] != '':
       e_mail = customer.data['email']
    
    #de xml file waar alle info van de as400 inkomt die gepost moet worden
    xml1 = '''<![CDATA[<?xml version="1.0" encoding="UTF-8"?>
    		 <ABWSupplierCustomer xmlns:agrlib="http://services.agresso.com/schema/ABWSchemaLib/2007/12/24">
    		  <MasterFile>
    			<agrlib:CompanyCode>''' + company_code + '''</agrlib:CompanyCode>
    			<agrlib:ApArType>''' + ap_ar_type_klant + '''</agrlib:ApArType>
    			<agrlib:ApArNo>'''+ customer_id +'''</agrlib:ApArNo>
    			<SupplierCustomer>
    			  <agrlib:UpdateFlag>0</agrlib:UpdateFlag>
    			  <agrlib:Name>'''+ name +'''</agrlib:Name>
    			  <ApArGroup>1</ApArGroup>
    			  <agrlib:CompRegNo>19600730</agrlib:CompRegNo>
    			  <ExternalRef>''' + external_ref + ''' </ExternalRef>
    			  <ShortName>'''+ short_name +'''</ShortName>
    			  <agrlib:CountryCode>'''+ dom_country_code +'''</agrlib:CountryCode>
    			  <InvoiceInfo>
    				<PayTerms>''' + payment_terms + '''</PayTerms>
    				<TermsFlag>1</TermsFlag>
    				<Currency>EUR</Currency>
    				<CurrencyFlag>1</CurrencyFlag>
    				<Language>''' + default_language + '''</Language>
    				<CreditLimit>0</CreditLimit>
    			  </InvoiceInfo>
    			  <PaymentInfo>
    				<PayMethod>''' + pay_method + '''</PayMethod>
    				<IBAN>'''+ iban +'''</IBAN>
    				<agrlib:Swift>GEBABEBB</agrlib:Swift>
    				<agrlib:IntruleId>01</agrlib:IntruleId>
    				<Status>N</Status>
    			  </PaymentInfo>
    			</SupplierCustomer>
    			<AddressInfo>
    			  <agrlib:UpdateFlag>0</agrlib:UpdateFlag>
    			  <agrlib:AddressType>1</agrlib:AddressType>
    			  <agrlib:ContactName></agrlib:ContactName>
    			  <agrlib:ContactPosition></agrlib:ContactPosition>
    			  <agrlib:Address>'''+ dom_adress +'''</agrlib:Address>
    			  <agrlib:Place>'''+ dom_place +'''</agrlib:Place>
    			  <agrlib:ZipCode>'''+ dom_zip_code +'''</agrlib:ZipCode>
    			  <agrlib:CountryCode>'''+ dom_country_code +'''</agrlib:CountryCode>
    			  <agrlib:InternetInfo>
    				<agrlib:Email>'''+ e_mail +'''</agrlib:Email>
    				<agrlib:EmailCc>'''+ e_mail_cc +'''</agrlib:EmailCc>
    			  </agrlib:InternetInfo>
    			  <agrlib:Phone>
    				<agrlib:Telephone1>'''+ land_line +'''</agrlib:Telephone1>
    				<agrlib:Telephone2>'''+ mobile +'''</agrlib:Telephone2>
    			  </agrlib:Phone>
                  </AddressInfo>
    			<agrlib:Relation>
    			  <agrlib:UpdateFlag>0</agrlib:UpdateFlag>
    			  <agrlib:RelAttrId>O114</agrlib:RelAttrId>
    			  <agrlib:RelValue>NOK_WS</agrlib:RelValue>
    			</agrlib:Relation>
    		  </MasterFile>
    		</ABWSupplierCustomer>]]>'''

    xml2 = '''<![CDATA[<?xml version="1.0" encoding="UTF-8"?>
    		 <ABWSupplierCustomer xmlns:agrlib="http://services.agresso.com/schema/ABWSchemaLib/2007/12/24">
    		  <MasterFile>
    			<agrlib:CompanyCode>''' + company_code + '''</agrlib:CompanyCode>
    			<agrlib:ApArType>''' + ap_ar_type_klant + '''</agrlib:ApArType>
    			<agrlib:ApArNo>'''+ customer_id +'''</agrlib:ApArNo>
    			<SupplierCustomer>
    			  <agrlib:UpdateFlag>0</agrlib:UpdateFlag>
    			  <agrlib:Name>'''+ name +'''</agrlib:Name>
    			  <ApArGroup>1</ApArGroup>
    			  <agrlib:CompRegNo>19600730</agrlib:CompRegNo>
    			  <ExternalRef>''' + external_ref + ''' </ExternalRef>
    			  <ShortName>'''+ short_name +'''</ShortName>
    			  <agrlib:CountryCode>'''+ dom_country_code +'''</agrlib:CountryCode>
    			  <InvoiceInfo>
    				<PayTerms>''' + payment_terms + '''</PayTerms>
    				<TermsFlag>1</TermsFlag>
    				<Currency>EUR</Currency>
    				<CurrencyFlag>1</CurrencyFlag>
    				<Language>''' + default_language + '''</Language>
    				<CreditLimit>0</CreditLimit>
    			  </InvoiceInfo>
    			  <PaymentInfo>
    				<PayMethod>''' + pay_method + '''</PayMethod>
    				<IBAN>'''+ iban +'''</IBAN>
    				<agrlib:Swift>GEBABEBB</agrlib:Swift>
    				<agrlib:IntruleId>01</agrlib:IntruleId>
    				<Status>N</Status>
    			  </PaymentInfo>
    			</SupplierCustomer>
    			<AddressInfo>
    			  <agrlib:UpdateFlag>0</agrlib:UpdateFlag>
    			  <agrlib:AddressType>1</agrlib:AddressType>
    			  <agrlib:ContactName></agrlib:ContactName>
    			  <agrlib:ContactPosition></agrlib:ContactPosition>
    			  <agrlib:Address>'''+ dom_adress +'''</agrlib:Address>
    			  <agrlib:Place>'''+ dom_place +'''</agrlib:Place>
    			  <agrlib:ZipCode>'''+ dom_zip_code +'''</agrlib:ZipCode>
    			  <agrlib:CountryCode>'''+ dom_country_code +'''</agrlib:CountryCode>
    			  <agrlib:InternetInfo>
    				<agrlib:Email>'''+ e_mail +'''</agrlib:Email>
    				<agrlib:EmailCc>'''+ e_mail_cc +'''</agrlib:EmailCc>
    			  </agrlib:InternetInfo>
    			  <agrlib:Phone>
    				<agrlib:Telephone1>'''+ land_line +'''</agrlib:Telephone1>
    				<agrlib:Telephone2>'''+ mobile +'''</agrlib:Telephone2>
    			  </agrlib:Phone>
    			</AddressInfo>
                <AddressInfo>
    			  <agrlib:UpdateFlag>0</agrlib:UpdateFlag>
    			  <agrlib:AddressType>2</agrlib:AddressType>
    			  <agrlib:ContactName></agrlib:ContactName>
    			  <agrlib:ContactPosition></agrlib:ContactPosition>
    			  <agrlib:Address>'''+ post_adress +'''</agrlib:Address>
    			  <agrlib:Place>'''+ post_place +'''</agrlib:Place>
    			  <agrlib:ZipCode>'''+ post_zip_code +'''</agrlib:ZipCode>
    			  <agrlib:CountryCode>'''+ post_country_code +'''</agrlib:CountryCode>
    			  <agrlib:InternetInfo>
    				<agrlib:Email>'''+ e_mail +'''</agrlib:Email>
    				<agrlib:EmailCc>'''+ e_mail_cc +'''</agrlib:EmailCc>
    			  </agrlib:InternetInfo>
    			  <agrlib:Phone>
    				<agrlib:Telephone1>'''+ land_line +'''</agrlib:Telephone1>
    				<agrlib:Telephone2>'''+ mobile +'''</agrlib:Telephone2>
    			  </agrlib:Phone>
    			</AddressInfo>
    			<agrlib:Relation>
    			  <agrlib:UpdateFlag>0</agrlib:UpdateFlag>
    			  <agrlib:RelAttrId>O114</agrlib:RelAttrId>
    			  <agrlib:RelValue>NOK_WS</agrlib:RelValue>
    			</agrlib:Relation>
    		  </MasterFile>
    		</ABWSupplierCustomer>]]>'''
    
    #de informatie van de as400 posten naar agresso, xml1 voor 1 adres, xml2 voor 2 adressen
    if post_adress != '':
        xml = xml1

    else:
        xml = xml2


    client_post.service.ExecuteServerProcessAsynchronously(input = {'ServerProcessId': server_process_id, 'MenuId': menu_id, 'Variant': variant, 'Xml': xml}, 
                                                             credentials = {'Username': 'WEBSERV', 'Client': 'VMOB', 'Password': 'WEBSERV'})

    #kijken of alle facturen betaald zijn
    #hiervoor doen we een get om te kijken of de klant tussen de lijst met onbetaalde facturen staat
    client_get2 = Client(wsdl = 'http://10.198.216.91/BusinessWorld-webservices/service.svc?QueryEngineService/QueryEngineV201101')
    
    unpaid_invoices =client_get2.service.GetTemplateResultAsDataSet(input = {'TemplateId': '4564'}, credentials = {'Username': 'WEBSERV', 'Client': 'VMOB', 'Password': 'WEBSERV'})
    
    #in deze lijst staan alle rijksreisternummers met openstaande facturen, we gaan kijken of de klant er tussen staat
    for idx, item in enumerate(unpaid_invoices['TemplateResult']['_value_1']['_value_1']):
        test = unpaid_invoices['TemplateResult']['_value_1']['_value_1'][idx]['AgressoQE']['ext_apar_ref__1']
        
        if test == external_reference:
            payment_status_awb = 'NOK'
            
            break
        else:
            payment_status_awb = 'OK'

    #kijken welke verzekeringen naar agresso moeten
    ins_for_agresso = compare_insurances(customer)
     
    #we maken een template voor de data van alle verzekeringen via zeep mee te geven in agresso !betaalstatus er nog bij! werkt voorlopig niet
    template = {'FlexiGroupUnitType': {'FlexiGroup': 'VMOBCONTRACT', 'FlexiFieldRowList': {
                'FlexiRowUnitType': {'RowState': {'ReturnCode': '0', 'ReturnText': 'Saved OK'}, 
                'RowNo': '', 'FlexiFieldList': {'FlexiFieldUnitType': 
                [{'ColumnName': 'product', 'Value': ''}, {'ColumnName': 'startdatum', 'Value': ''}, 
                {'ColumnName': 'wachtdatum', 'Value': ''},  {'ColumnName': 'einddatum', 'Value': ''}, 
                {'ColumnName': 'contract_nr', 'Value': ''}, {'ColumnName': 'zkf_nr', 'Value': ''}, 
                {'ColumnName': 'aansluitingscode_fx', 'Value': ''}, {'ColumnName': 'ontslagcode_fx', 'Value': ''}, 
                {'ColumnName': 'zkf_nr_datum_van', 'Value': ''}, {'ColumnName': 'zkf_nr_datum_tot', 'Value': ''}, 
                {'ColumnName': 'info', 'Value': ''}, {'ColumnName': 'hoedanigheid_fx', 'Value': ''}, 
                {'ColumnName': 'laatste_betaaldatum_fx', 'Value': ''},
                {'ColumnName': 'openstaande_premie_fx', 'Value': ''}, {'ColumnName': 'betaalwijze_fx', 'Value': ''}, 
                {'ColumnName': 'periode_premie_fx', 'Value': ''}, {'ColumnName': 'barema_fx', 'Value': ''}, 
                {'ColumnName': 'betaler_naam_fx', 'Value': ''}, {'ColumnName': 'betaler_rrn_fx', 'Value': ''}]}}}}}
    
    #de verzekeringen in een array zetten in het juiste formaat voor agresso
    ins_for_agresso_temp = []
    counter = 9
    
    for ins in ins_for_agresso:
        
        #zet de interval code om in woorden
        interval_code = interval = ins['payment_interval']
        
        if interval_code == '12':
            interval = 'MAANDELIJKS'
            
        elif interval_code == '04':
            interval = 'KWARTAAL'
            
        elif interval_code == '06':
            interval = 'SEMESTER'
            
        elif interval_code == '01':
            interval = 'JAARLIJKS'
        
        #zet de openstaande premie over in een integer
        outstanding_premium = ins['outstanding_premium']
        
        if outstanding_premium == []:
            outstanding_premium = 0
        
        else:
            outstanding_premium = int(outstanding_premium[0])
        
        #kijken of de debiteur alles betaald heeft
        #kijken of de verzekering binnen de periode betaald is
        
        #laatste betaaldatum en van wanneer het contract loopt ophalen
        last_payment_date = ins['last_payment_date'] 
        payment_date_from = ins['payment_date_from']
        
        #de uren:minuten:seconden weghalen van laatste betaaldatum
        if len(last_payment_date) == 17: 
            d = last_payment_date[:-8]
            last_payment_date_formatted = datetime.strptime(d, '%m/%d/%Y')
        
        elif len(last_payment_date) == 29:
            d = last_payment_date[:-20]
            last_payment_date_formatted = datetime.strptime(d, '%Y-%m-%d')
        
        if len(payment_date_from) == 17: 
            d = payment_date_from[:-8]
            payment_date_from_formatted = datetime.strptime(d, '%m/%d/%Y')
        
        elif len(payment_date_from) == 29:
            d = payment_date_from[:-19]
            payment_date_from_formatted = datetime.strptime(d, '%Y-%m-%d')
        
        #aantal dagen tussen de 2 datums berekenen
        days_left = (last_payment_date_formatted - payment_date_from_formatted).days
        
        #kijken of je binnen het juiste aantal dagen betaald hebt
        if days_left > int(payment_terms):
            payment_status_ws = 'NOK'
        
        else:
            payment_status_ws = 'OK' 
        
        #kijken welke betaalstatussen al dan niet in orde zijn
        if payment_status_ws == 'NOK' and payment_status_awb == 'NOK':
            payment_status = 'NOK_WS_ABW'
        
        elif payment_status_ws == 'OK' and payment_status_awb == 'NOK':
            payment_status = 'NOK_ABW'
        
        elif payment_status_ws == 'NOK' and payment_status_awb == 'OK':
            payment_status = 'NOK_WS'
        
        else:
            payment_status = 'OK'
        
        #het dossier nummer in het juiste formaat zetten
        contract_number = ins['contract_number'][-9:]
        
        template['FlexiGroupUnitType']['FlexiFieldRowList']['FlexiRowUnitType']['RowNo'] = str(counter)
        template['FlexiGroupUnitType']['FlexiFieldRowList']['FlexiRowUnitType']['FlexiFieldList']['FlexiFieldUnitType'][0]['Value'] = ins['product']
        template['FlexiGroupUnitType']['FlexiFieldRowList']['FlexiRowUnitType']['FlexiFieldList']['FlexiFieldUnitType'][1]['Value'] = ins['start_date']
        template['FlexiGroupUnitType']['FlexiFieldRowList']['FlexiRowUnitType']['FlexiFieldList']['FlexiFieldUnitType'][2]['Value'] = ins['wait_date']
        template['FlexiGroupUnitType']['FlexiFieldRowList']['FlexiRowUnitType']['FlexiFieldList']['FlexiFieldUnitType'][3]['Value'] = ins['end_date']
        template['FlexiGroupUnitType']['FlexiFieldRowList']['FlexiRowUnitType']['FlexiFieldList']['FlexiFieldUnitType'][4]['Value'] = contract_number
        template['FlexiGroupUnitType']['FlexiFieldRowList']['FlexiRowUnitType']['FlexiFieldList']['FlexiFieldUnitType'][5]['Value'] = ins['zfk_number']
        template['FlexiGroupUnitType']['FlexiFieldRowList']['FlexiRowUnitType']['FlexiFieldList']['FlexiFieldUnitType'][6]['Value'] = ins['connection_code']
        template['FlexiGroupUnitType']['FlexiFieldRowList']['FlexiRowUnitType']['FlexiFieldList']['FlexiFieldUnitType'][7]['Value'] = ins['dismissal_code']
        template['FlexiGroupUnitType']['FlexiFieldRowList']['FlexiRowUnitType']['FlexiFieldList']['FlexiFieldUnitType'][8]['Value'] = '1/01/1900 0:00:00'
        template['FlexiGroupUnitType']['FlexiFieldRowList']['FlexiRowUnitType']['FlexiFieldList']['FlexiFieldUnitType'][9]['Value'] = '1/01/1900 0:00:00'
        template['FlexiGroupUnitType']['FlexiFieldRowList']['FlexiRowUnitType']['FlexiFieldList']['FlexiFieldUnitType'][10]['Value'] = ''
        template['FlexiGroupUnitType']['FlexiFieldRowList']['FlexiRowUnitType']['FlexiFieldList']['FlexiFieldUnitType'][11]['Value'] = ''
        template['FlexiGroupUnitType']['FlexiFieldRowList']['FlexiRowUnitType']['FlexiFieldList']['FlexiFieldUnitType'][12]['Value'] = last_payment_date
        template['FlexiGroupUnitType']['FlexiFieldRowList']['FlexiRowUnitType']['FlexiFieldList']['FlexiFieldUnitType'][13]['Value'] = outstanding_premium
        template['FlexiGroupUnitType']['FlexiFieldRowList']['FlexiRowUnitType']['FlexiFieldList']['FlexiFieldUnitType'][14]['Value'] = ins['payment_method']
        template['FlexiGroupUnitType']['FlexiFieldRowList']['FlexiRowUnitType']['FlexiFieldList']['FlexiFieldUnitType'][15]['Value'] = interval
        template['FlexiGroupUnitType']['FlexiFieldRowList']['FlexiRowUnitType']['FlexiFieldList']['FlexiFieldUnitType'][16]['Value'] = ins['scale']
        template['FlexiGroupUnitType']['FlexiFieldRowList']['FlexiRowUnitType']['FlexiFieldList']['FlexiFieldUnitType'][17]['Value'] = ins['name_payer']
        template['FlexiGroupUnitType']['FlexiFieldRowList']['FlexiRowUnitType']['FlexiFieldList']['FlexiFieldUnitType'][18]['Value'] = ins['payer_rrn']
        
       
        ins_for_agresso_temp.append(template)
        counter += 1
            
            
        post2 = client_get.service.AddFlexiFieldRow(company = company_code, customerId = customer_id, flexiGroupList = ins_for_agresso_temp, 
                                                includeDataInResponse = 0, credentials = {'Username': 'WEBSERV', 'Client': 'VMOB', 'Password': 'WEBSERV'})
    
#37091402606  
#94052220280
#63081520050
