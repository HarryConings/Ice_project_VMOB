# -*- coding: utf-8 -*-
"""
Created on Tue Aug  3 11:13:25 2021

@author: Tijs Conings
"""

import requests


def get_token(zfk_nr):
    '''maak een token aan die gebruikt kan worden om informatie van de klant aan te vragen aan webservice'''

    if zfk_nr == '203':
        url = 'https://fes203.m-team.be/login/oauth2/access_token?grant_type=client_credentials&username=203-mymut-app&realm=/203'
        authorization = "Basic MjAzLW15bXV0LWFwcDppenFxU1Y5WEtiRjFQa1pjN0U5aE9aUEU="
        cache_control = "no-cache"
        content_type = "application/x-www-form-urlencoded"
    elif zfk_nr == '235':
        print('hier moeten andere waarden komen')
    
    data = {'Authorization':authorization,
         'Cache-Control':cache_control,
         'Content-Type' : content_type}

    response = requests.post(url, headers = data)
    lib_response = response.json()

    acces_token = lib_response.get('access_token')
    token_type = lib_response.get('token_type')
    expires_in = lib_response.get('expires_in')

    return [acces_token, token_type, expires_in]

class Customer:
    '''Een klant met al zijn persoonlijke gegevens opgeroepen door: rijksregisternummer, referentie id of extern nummer'''

    uri_bigleap = 'http://api-mnnz.jablux.cpc998.be'

    def __init__(self, nat_nr, zfk_nr):
        '''Hier slaan we alle nuttige data van de klant op in verschillende dictionarys'''

        self.data = {'nat_nr': '', 'ref_id': '', 'ext_nr': '', 'name': '', 'last_name': '', 'birth_date': '', 'gender': '', 'email': ''}
        self.post_adress = {'contact_person': '', 'country': '', 'postal_code': '', 'city': '', 'street': '', 'house_number': '', 'bus_number': ''}
        self.residence_adress = {'country': '', 'postal_code': '', 'city': '', 'street': '', 'house_number': '', 'bus_number': ''}
        self.phone_numbers = {'landline': '', 'mobile': '', 'work': ''}
        self.family_member = {'nat_nr': '', 'name': '', 'last_name': '', 'gender': '', 'birth_date': '', 'civil_status': ''}
        self.family_members = []
        self.insurance = {'product': '', 'product_type': '','product_code': '' , 'start_date': '', 'end_date': '', 'wait_date': '', 'contract_number': '',
                          'zfk_number': '', 'connection_code': '', 'dismissal_code': '', 'info': '', 'titular_ref_id': '', 'titular_ext_nr': '', 'iban': '',
                          'outstanding_premium': '', 'payment_method_code': '','payment_method': '', 'payment_interval': '', 'scale': '0', 'name_payer': '', 'payer_rrn': '', 'last_payment_date': '', 'payment_date_from': ''}
        self.insurances = []
        self.nat_nr = nat_nr
        self.zfk_nr = zfk_nr

        #Hier halen we data van de webservice en zetten het om in een leesbare dictionary
        uri = Customer.uri_bigleap + '/mca/api/persondata/persons?nationalNumber=' + nat_nr
        token_type = get_token(zfk_nr)[1]
        acces_token = get_token(zfk_nr)[0]
        data = {"Authorization" : token_type + " " + acces_token, "Accept": "Application/json"}

        response = requests.get(uri,headers = data)
        response_dict = response.json()
         
        for key in response_dict['personSummaries']:
            #Zet de gekregen data om in de dictionarys die we in het begin gedefinieerd hebben
            self.data['ref_id'] = key['referenceID']
            self.data['name'] = key['firstName']
            self.data['last_name'] = key['lastName']
            self.data['birth_date'] = key['birthDate']
            self.data['nat_nr'] = key['nationalNumber']
            self.data['ext_nr'] = key['externalNumber']
            self.data['gender'] = key['gender']

        for key in response_dict['personSummaries'][0]['contactInformation']['emailAddresses']:
            #Zet de gekregen data om in de dictionarys die we in het begin gedefinieerd hebben
            self.data['email'] = key['email']

        for key in response_dict['personSummaries'][0]['contactInformation']['addresses']:
            #Zet de gekregen data om in de dictionarys die we in het begin gedefinieerd hebben     
            kind = key['type']

            if kind == 'POSTAL':
                self.post_adress['country'] = key['country']
                self.post_adress['postal_code'] = key['zip']
                self.post_adress['city'] = key['city']
                self.post_adress['street'] = key['street']
                self.post_adress['house_number'] = key['number']
                self.post_adress['bus_number'] = key['boxNumber']
                self.post_adress['contact_person'] = key['co']
            else:
                self.residence_adress['country'] = key['country']
                self.residence_adress['postal_code'] = key['zip']
                self.residence_adress['city'] = key['city']
                self.residence_adress['street'] = key['street']
                self.residence_adress['house_number'] = key['number']
                self.residence_adress['bus_number'] = key['boxNumber']

        for key in response_dict['personSummaries'][0]['contactInformation']['phoneNumbers']:
            #Zet de gekregen data om in de dictionarys die we in het begin gedefinieerd hebben     
            kind = key['type']

            if kind == 'FIXED':
                if key['countryCode'] == '':
                    nr = key['number'].lstrip('0')
                    self.phone_numbers['landline'] = '+32' + nr
                else:
                    self.phone_numbers['landline'] = key['countryCode'] + key['number']

            elif kind == 'MOBILE':
                self.phone_numbers['mobile'] = key['countryCode'] + key['number']

            elif kind == 'WORK':
                self.phone_numbers['work'] = key['countryCode'] + key['number']

        #Hier halen we de info van familieleden op met person_reference_id uit de webservice
        ref_id = self.data.get('ref_id')
        uri = self.uri_bigleap + '/mca/api/familydata/persons/' + ref_id + "/legalFamilyMembers"
        data = {"Authorization" : token_type + " " + acces_token,
                "Accept" : "Application/json"}

        response = requests.get(uri,headers = data)

        if response.status_code == 200:
            family_members = response.json()

            for key in family_members['legalFamilyMembers']:
                self.family_member['nat_nr'] = key['nationalNumber']
                self.family_member['name'] = key['firstName']
                self.family_member['last_name'] = key['lastName']
                self.family_member['gender'] = key['gender']
                self.family_member['birth_date'] = key['birthDate']
                self.family_member['civil_status'] = key['civilStatus']

                self.family_members.append(self.family_member.copy())

        #Dit deel haalt met het person_reference_id de info van de verzekeringen op uit de webservice
        ref_id = self.data.get('ref_id')
        uri = self.uri_bigleap + '/mca/api/insurancedata/persons/' + ref_id + '/insurances?history=true'
        data = {"Authorization" : token_type + " " + acces_token,
                "Accept" : "Application/json"}

        response = requests.get(uri,headers = data)

        if response.status_code == 200:
            #Hier halen we data van de verzekeringen en ordenen we ze in een dictionary            
            insurance_data = response.json()
            counter=0
            
            for i in insurance_data['insurances']:             
                self.insurance['start_date'] = insurance_data['insurances'][counter]['affiliationDate']
                self.insurance['end_date'] = insurance_data['insurances'][counter]['cancellationDate']
                self.insurance['product_type'] = insurance_data['insurances'][counter]['productType']['backendCode']
                self.insurance['product_code'] =  insurance_data['insurances'][counter]['productCode']['backendCode']
                self.insurance['titular_ref_id'] =  insurance_data['insurances'][counter]['titularRefId']
                self.insurance['titular_ext_nr'] =  insurance_data['insurances'][counter]['titularInformation']['externalNumber']
                self.insurance['zfk_number'] = zfk_nr

                #referentie id van de verzekering uit de data halen om nog een call te doen naar de webservice voor de resterende verzekeringsinformatie
                insurance_ref_id = insurance_data['insurances'][counter]['insuranceRefId']
                uri = self.uri_bigleap + '/mca/api/insurancedata/persons/' + ref_id + '/beneficiaryDetails/' + insurance_ref_id
                data = {"Authorization" : token_type + " " + acces_token,
                "Accept" : "Application/json"}

                response2 = requests.get(uri,headers = data)
                insurance_data_2 = response2.json()    

                #Hier halen we data2 van de verzekeringen en ordenen ze in een dictionary
                self.insurance['connection_code'] = insurance_data_2['subscriptionPeriods'][0]['affiliation']['code']['backendCode']
                self.insurance['outstanding_premium'] = insurance_data_2['openTaxations']
                self.insurance['wait_date'] = insurance_data_2['subscriptionPeriods'][0]['affiliation']['effectiveDate']
                self.insurance['contract_number'] =  insurance_data_2['insuranceFolderNumber']

                if insurance_data_2['subscriptionPeriods'][0]['cancellationInformation']['reasonCode'] != None:
                    self.insurance['dismissal_code'] = insurance_data_2['subscriptionPeriods'][0]['cancellationInformation']['reasonCode']['backendCode'] + insurance_data_2['subscriptionPeriods'][0]['cancellationInformation']['motivationCode']['backendCode']

                if insurance_data_2['insurancePayments'] != []:
                    self.insurance['payment_method_code'] = insurance_data_2['insurancePayments'][0]['paymentModeCode']['backendCode']
                    self.insurance['payment_interval'] = insurance_data_2['insurancePayments'][0]['paymentPeriodicityCode']['backendCode']
                    self.insurance['name_payer'] = insurance_data_2['insurancePayments'][0]['payer']['firstName'] + ' ' + insurance_data_2['insurancePayments'][0]['payer']['lastName']
                    self.insurance['payer_rrn'] = insurance_data_2['insurancePayments'][0]['payer']['nationalNumber']
                    self.insurance['last_payment_date'] = insurance_data_2['insurancePayments'][0]['lastPaymentDate']
                    self.insurance['iban'] = insurance_data_2['insurancePayments'][0]['bankAccountInfo']['IBAN']
                    self.insurance['payment_date_from'] = insurance_data_2['insurancePayments'][0]['paymentDateFrom']
 
                if insurance_data_2['nonMandatoryInsuranceDetails'] != None:
                    self.insurance['product'] = insurance_data_2['nonMandatoryInsuranceDetails']['insuranceName']
                
                if self.insurance['payment_method_code'] == '00':
                    self.insurance['payment_method'] = 'DOMI'
                
                elif self.insurance['payment_method_code'] == '01':
                    self.insurance['payment_method'] = 'OVERSCHRIJVING'
  
                self.insurances.append(self.insurance.copy())
                counter +=1
                