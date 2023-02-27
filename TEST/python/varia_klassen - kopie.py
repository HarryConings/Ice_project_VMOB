# -*- coding: utf-8 -*-
"""
Created on Fri Aug 27 10:52:09 2021

@author: Tijs Conings
"""

from settings_xml_inlezen_test import insurance_from_xml
from datetime import datetime
from zeep import Client

def compare_insurances(customer):
    '''we kijken welke verzekeringen van de as400 overgezet moeten worden naar agresso door middel van de xml '''
    
    insurance_from_xml(customer, r'P:\OGV\ASSURCARD_PROG\assurcard_settings_xml\Tijs.xml')
    ins_for_agresso = []
        
    for insurance in customer.insurances:
        
        p_type = insurance['product_type']
        p_code = insurance['product_code']
        
        if p_type in insurance_from_xml.p_type_i:
            
            if p_code == '1':
                insurance['product'] = insurance_from_xml.insurances['T' + p_type]
               
            else:
                insurance['product'] = insurance_from_xml.insurances['C' + p_code]
              
            ins_for_agresso.append(insurance)
            
    return ins_for_agresso

def date_formatter(date):
    if date.find('Z') == -1:
    
        dat = date.replace('T', ' ')
        d = dat[:-19]
        dateOK = datetime.strptime(d, '%Y-%m-%d')
        date = dateOK.strftime("%d/%m/%Y")
    
    else: 
        
        dat = date.replace('T', ' ')
        d = dat[:-14]
        dateOK = datetime.strptime(d, '%Y-%m-%d')
        date = dateOK.strftime("%d/%m/%Y")
        
    return date

def get_nat_nr_from_agresso(agresso_nr):
    '''we halen via het agresso nummer het rijksregisternummer op'''
    
    client_get = Client(wsdl = 'http://10.198.216.91//BusinessWorld-webservices/service.svc?CustomerService/Customer')
    
    get = client_get.service.GetCustomer(company = 'VMOB', customerId = agresso_nr, customerDetailsOnly = 1, credentials = {'Username': 'WEBSERV', 'Client': 'VMOB', 'Password': 'WEBSERV'})
    
    nat_nr = get['CustomerType']['ExternalReference']
    
    return nat_nr
    
