# -*- coding: utf-8 -*-
"""
Created on Wed Aug 18 19:30:50 2021

@author: Tijs Conings
"""

from xml.etree import ElementTree as et

def info_from_xml(path):
    '''De info uit een xml file halen met gekende lay-out'''
    
    tree = et.parse(path)
    root = tree.getroot()
    
    #kijken naar elke waarde in de xml en de tekst die hierbij hoort opslaan
    for child in root:
       
        if child.tag == 'CompanyCode':
            info_from_xml.company_code = child.text
    
        elif child.tag == 'ApArType_klant':
            info_from_xml.ap_ar_type_klant = child.text
    
        elif child.tag == 'ApArType_leverancier':
            info_from_xml.ap_ar_type_leverancier = child.text
    
        elif child.tag == 'assurcard_invoice_import_interface':
            info_from_xml.assurcard_invoice_import_interface = child.text
    
        elif child.tag == 'agresso_voucher_type':
            info_from_xml.agresso_voucher_type = child.text
    
        elif child.tag == 'PayTerms':
            info_from_xml.pay_terms = child.text
        
        elif child.tag == 'CreditLimit':
            info_from_xml.credit_limit = child.text
        
        elif child.tag == 'Currency':
            info_from_xml.currency = child.text
        
        elif child.tag == 'TaxCode':
            info_from_xml.tax_code = child.text
        
        elif child.tag == 'AP_Account':
            info_from_xml.ap_account = child.text
            
        elif child.tag == 'GL_Account':
            info_from_xml.gl_account = child.text
        
        elif child.tag == 'invoice_payment_delay':
            info_from_xml.invoice_payment_delay = child.text
        
        elif child.tag == 'PayMethod':
            info_from_xml.pay_method = child.text
        
        elif child.tag == 'Default_Language':
            info_from_xml.default_language = child.text

def insurance_from_xml(customer, path):
    '''kijken in welk ziekefonds we zitten, aan de hand daarvan de juiste codes van de verzekeringen meegeven'''
    
    zfk_nr = customer.zfk_nr
    tree = et.parse(path)
    root = tree.getroot()
    
    insurance_from_xml.insurances = {}
    insurance_from_xml.insurances_with_card = {}
    
    insurance_from_xml.p_type_i = [] #p_type = product type
    insurance_from_xml.c_type_i = ['1'] #c_type = product code, niet elke verzekering heeft een product code, daarom zetten we deze standaart op 1, alleen HOSPIFORFAIT heeft een product code
    insurance_from_xml.p_type_i_w_c = [] #w_c = insurance with card
    insurance_from_xml.c_type_i_w_c = ['1']
    
    #kijken in subtekst verzekeringen naar de codes van de zfk 203 verzekeringen
    if zfk_nr == '203':
        for child in root:
            if child.tag == 'verzekeringen':
                for chil in child:
                    if chil.tag == 'ZKF203':
                        for ch in chil:
                            if ch.attrib != {}:
                                values_view = ch.attrib.values()
                                value_iterator = iter(values_view)
                                first_value = next(value_iterator)
                                insurance_from_xml.insurances['T' + first_value] = ch.tag
                                
                            else:
                                insurance_from_xml.insurances['T' + ch.text ] = ch.tag 
                                
                            for c in ch:
                                insurance_from_xml.insurances['C' + c.text] = c.tag

            if child.tag == 'verzekeringen_met_kaart':
             for chil in child:
                 if chil.tag == 'ZKF203':
                     for ch in chil:
                            if ch.attrib != {}:
                                values_view = ch.attrib.values()
                                value_iterator = iter(values_view)
                                first_value = next(value_iterator)
                                insurance_from_xml.insurances_with_card['T' + first_value] = ch.tag
                                
                            else:
                                insurance_from_xml.insurances_with_card['T' + ch.text] = ch.tag 
                                
                            for c in ch:
                                insurance_from_xml.insurances_with_card['C' + c.text] = c.tag                    

    if zfk_nr == '235':
        for child in root:
            if child.tag == 'verzekeringen':
                for chil in child:
                    if chil.tag == 'ZKF235':
                        for ch in chil:
                            if ch.attrib != {}:
                                values_view = ch.attrib.values()
                                value_iterator = iter(values_view)
                                first_value = next(value_iterator)
                                insurance_from_xml.insurances['T' + first_value] = ch.tag
                                
                            else:
                                insurance_from_xml.insurances['T' + ch.text ] = ch.tag
                                
                            for c in ch:
                                insurance_from_xml.insurances['C' + c.text] = c.tag 

            if child.tag == 'verzekeringen_met_kaart':
             for chil in child:
                 if chil.tag == 'ZKF235':
                     for ch in chil:
                            if ch.attrib != {}:
                                values_view = ch.attrib.values()
                                value_iterator = iter(values_view)
                                first_value = next(value_iterator)
                                insurance_from_xml.insurances_with_card['T' + first_value] = ch.tag
                                
                            else:
                                insurance_from_xml.insurances_with_card['T' + ch.text] = ch.tag
                                
                            for c in ch:
                                insurance_from_xml.insurances_with_card['C' + c.text ] = c.tag                      
    
    #een T toevoegen bij verzekeringstype, een C bij verzekeringscode
    for key in insurance_from_xml.insurances:
        if key[0] == 'T':
            insurance_from_xml.p_type_i.append(key[1:3])
        if key[0] == 'C':
            insurance_from_xml.c_type_i.append(key[1:3])
            
    for key in insurance_from_xml.insurances_with_card:
        if key[0] == 'T':
            insurance_from_xml.p_type_i_w_c.append(key[1:3])
        if key[0] == 'C':
            insurance_from_xml.c_type_i_w_c.append(key[1:3])
            
def MIFID_from_xml(path):
    '''We halen de automatische brieven en de MIDFIT info uit een xml'''
    
    tree = et.parse(path)
    root = tree.getroot()
    
    MIFID_from_xml.MIFID_od = {}
    MIFID_from_xml.MIFID_anm = {}
    MIFID_from_xml.MIFID_odo = {}
    
    for child in root:
        if child.tag == 'A00ontbrekende_doc':
            for chil in child:
                if chil.tag == 'aanvinkteksten':
                    counter = 0
                    for chi in chil:
                        MIFID_from_xml.MIFID_od[counter] = chi.text
                        counter += 1
                        
        if child.tag == 'A01HOSP_DB_MIFID-doc-aansluiting-nog-niet-mogelijk-geenmail':
            for chil in child:
                if chil.tag == 'aanvinkteksten':
                    counter = 0
                    for chi in chil:
                        MIFID_from_xml.MIFID_anm[counter] = chi.text
                        counter += 1
                        
        if child.tag == 'A02ontbrekende_doc':
            for chil in child:
                if chil.tag == 'aanvinkteksten':
                    counter = 0
                    for chi in chil:
                        MIFID_from_xml.MIFID_odo[counter] = chi.text
                        counter += 1    

def aut_letters_from_xml(path):
    'hier halen we de namen van de automatische brieven uit de xml en de paden naar de documenten van de brieven die gemaakt moeten worden'
    
    tree = et.parse(path)
    root = tree.getroot()

    aut_letters_from_xml.aut_letter = {}
    
    for child in root:
        if child.tag != 'A00ontbrekende_doc' and child.tag != 'A01HOSP_DB_MIFID-doc-aansluiting-nog-niet-mogelijk-geenmail' and child.tag != 'A02ontbrekende_doc':
            for chil in child:
                if chil.tag == 'naam':
                    name = chil.text
                if chil.tag == 'sjabloon':
                    aut_letters_from_xml.aut_letter[name] = chil.text
                         
                    


