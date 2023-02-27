# -*- coding: utf-8 -*-
"""
Created on Fri Aug  6 13:22:47 2021

@author: Tijs Conings
"""

import win32com.client as win32
from barcode import Code128
from barcode.writer import ImageWriter
from varia_klassen import date_formatter
from datetime import datetime
import os

overview_file_name = ['Tijs', 'Harry', 'Hilde', 'Nel', 'Nika']
inz_number = ['203', '203', '203', '203', '203']
ad_number = ['23451', '28949', '3819', '4627', '5273']
od_number = ['132881', '139991', '4839993', '246403', '2564728']

def make_doc(place, location, customer):
    '''Haalt de plaats van een document op vult de juiste waarde in het sjabloon in'''
    
    #we halen naam en achternaam  op van de persoon
    voor_naam = customer.data['name']
    achter_naam = customer.data['last_name']
    
    #gebruikersnaam ophalen
    gebruikers_naam = os.getlogin()
    
    #we halen het rijksregister nummer op en maken er een met spaties
    inz_nr_g_sp = customer.data['nat_nr']
    inz_nr_spatie1 = inz_nr_g_sp[0:6]
    inz_nr_spatie2 = inz_nr_g_sp[6:9]
    inz_nr_spatie3 = inz_nr_g_sp[9:11]
    inz_nr_spatie = inz_nr_spatie1 + ' ' + inz_nr_spatie2 + ' ' + inz_nr_spatie3
    
    extern_nummer = customer.data['ext_nr']
    zfk_nr = customer.zfk_nr
    # agr_nr = 

    
    
    #kijken welk gender de klant heeft en de juiste waarden instellen
    if customer.data['gender'] == 'M':
        
        h_h = 'hem'
        h_ar = 'zijn'
        ge_slacht = 'man'
        H_aan_spreek = 'De heer'
        aan_spreek = 'de heer'
        brief_adres_lijn1 = H_aan_spreek + ' ' + achter_naam
    
    elif customer.data['gender'] == 'F':
        
        h_h = 'haar'
        h_ar = 'haar'
        ge_slacht = 'vrouw'
        H_aan_spreek = 'Mevrouw'
        aan_spreek = 'mevrouw'
        brief_adres_lijn1 = H_aan_spreek + ' ' + achter_naam
    
    if customer.post_adress['city'] == '/':
        '''Als de client geen postadres heeft stellen we het domicillie adres in als post adres'''
        
        brief_adres_lijn2 = customer.residence_adress['street'] + " " + customer.residence_adress['house_number']
        brief_adres_lijn3 = customer.residence_adress['postal_code'] + " " + customer.residence_adress['city']
        brief_adres_lijn4 = customer.residence_adress['bus_number']

    else:
        '''Anders is het postadres het adres waar de brief terechtkomt'''
        
        brief_adres_lijn2 = customer.post_adress['street'] + " " + customer.post_adress['house_number']
        brief_adres_lijn3 = customer.post_adress['postal_code'] + " " + customer.post_adress['city']
        brief_adres_lijn4 = customer.post_adress['bus_number']        
    
    domi_adres_lijn1 = brief_adres_lijn1
    domi_adres_lijn2 = customer.residence_adress['street'] + " " + customer.residence_adress['house_number']
    domi_adres_lijn3 = customer.residence_adress['postal_code'] + " " + customer.residence_adress['city']
    
    #geboortedatum omzetten in juiste formaat
    geb_datum = date_formatter(customer.data['birth_date'])
    
    
    #datum aanmaak brief halen en omzetten in juiste formaten
    date_letter = datetime.today()
    datum_geschreven = date_letter.strftime("%d %B %Y")
    datum_min = date_letter.strftime("%d-%m-%Y")
    datum_slashes = date_letter.strftime("%d/%m/%Y")
    
    #we openen word en het juist sjabloon
    word = win32.Dispatch("Word.Application")
    doc = word.Documents.Open(place)

    if doc.Bookmarks.Exists('BarCode') == True:
        '''Maakt barcode aan, herschaalt hem en plakt het op de juiste plaats in het document'''
        
        bar_nr = customer.data['nat_nr']

        bar_code = Code128(bar_nr, writer=ImageWriter())
        bar_code.save('barcode', {'dpi': 200,'module_height': 4, 'quiet_zone': 0, 'text_distance': 0, 'font_size': 7})

        '''De plaats van de afbeelding (bookmark) opslaan waar de barcode moet komen en daar de barcode zetten'''
        rng = doc.Bookmarks.Item("BarCode").Range
        doc.Bookmarks('BarCode').Range = ''

        rng.InlineShapes.AddPicture("P:/GIT/VNZ/gok_blII/barcode.png", False, True)
        
    for tbl in doc.Tables:
        '''Kijkt naar de tabellen in het document, voegt genoeg rijen toe en vult ze in met de juiste data'''

        if tbl.Title == 'overzicht_dossier':

            for idx, item in enumerate(overview_file_name):
                tbl.Rows.Add(tbl.Rows[1])

                if idx+2 == len(overview_file_name):
                    break
            
            counter = 2
            for name in overview_file_name:
                tbl.Cell(counter,1).Range.Text = name
                tbl.Cell(counter,2).Range.Text = inz_number[counter-2]
                tbl.Cell(counter,3).Range.Text = ad_number[counter-2]
                tbl.Cell(counter,4).Range.Text = od_number[counter-2]
                counter += 1
        
        if tbl.Title == 'overzicht_verzekeringen':
            
            for idx, item in enumerate(overview_file_name):
                tbl.Rows.Add(tbl.Rows[0])
                
                if idx+2 == len(overview_file_name):
                    break
            
            counter = 2
            for name in overview_file_name:
                tbl.Cell(counter,1).Range.Text = name
                tbl.Cell(counter,2).Range.Text = inz_number[counter-2]
                tbl.Cell(counter,3).Range.Text = ad_number[counter-2]
                tbl.Cell(counter,4).Range.Text = od_number[counter-2]
                counter += 1
        
        if tbl.Title == 'bestaande_aandoening':

            for idx, item in enumerate(overview_file_name):
                tbl.Rows.Add(tbl.Rows[1])

                if idx+2 == len(overview_file_name):
                    break
            
            counter = 2
            for name in overview_file_name:
                tbl.Cell(counter,1).Range.Text = name
                tbl.Cell(counter,2).Range.Text = inz_number[counter-2]
                tbl.Cell(counter,3).Range.Text = ad_number[counter-2]
                counter += 1           
        
        if tbl.Title == 'een_kolom_bestaande':

            for idx, item in enumerate(overview_file_name):
                tbl.Rows.Add(tbl.Rows[1])

                if idx+2 == len(overview_file_name):
                    break
            
            counter = 2
            for name in overview_file_name:
                tbl.Cell(counter,1).Range.Text = name
                counter += 1  
        
        if tbl.Title == 'ontslag_aansluiting':
            
            for idx, item in enumerate(overview_file_name):
                tbl.Rows.Add(tbl.Rows[1])

                if idx+2 == len(overview_file_name):
                    break
            
            counter = 2
            for name in overview_file_name:
                tbl.Cell(counter,1).Range.Text = name
                tbl.Cell(counter,2).Range.Text = inz_number[counter-2]
                tbl.Cell(counter,3).Range.Text = ad_number[counter-2]
                tbl.Cell(counter,4).Range.Text = od_number[counter-2]
                counter += 1               
        
        if tbl.Title == 'aansluitings_overzicht':
            
            for idx, item in enumerate(overview_file_name):
                tbl.Rows.Add(tbl.Rows[1])

                if idx+2 == len(overview_file_name):
                    break
            
            counter = 2
            for name in overview_file_name:
                tbl.Cell(counter,1).Range.Text = name
                tbl.Cell(counter,2).Range.Text = inz_number[counter-2]
                tbl.Cell(counter,3).Range.Text = ad_number[counter-2]
                counter += 1 


    for shp in doc.Shapes:
        '''gaat in elke shape, later kijken we in welke soor shape we zitten om bewerkingen uit te voeren'''

        if shp.TextFrame.HasText:
            '''Deze code gaat alle tekstvakken af en plaatst er de juiste tekst in'''

            txtRng = shp.TextFrame.TextRange

            txtRng.Find.Execute('brief_adres_lijn1', False, False, False, False, False, True, 1, False, brief_adres_lijn1, 2)
            txtRng.Find.Execute('brief_adres_lijn2', False, False, False, False, False, True, 1, False, brief_adres_lijn2, 2)
            txtRng.Find.Execute('brief_adres_lijn3', False, False, False, False, False, True, 1, False, brief_adres_lijn3, 2)
            txtRng.Find.Execute('brief_adres_lijn4', False, False, False, False, False, True, 1, False, brief_adres_lijn4, 2)
            txtRng.Find.Execute('inz_nr_spatie', False, False, False, False, False, True, 1, False, inz_nr_spatie, 2)
            txtRng.Find.Execute('datum_geschreven', False, False, False, False, False, True, 1, False, datum_geschreven, 2)
            txtRng.Find.Execute('agr_nr', False, False, False, False, False, True, 1, False, 'test1', 2)
            txtRng.Find.Execute('zkf_nr', False, False, False, False, False, True, 1, False, zfk_nr, 2)
            txtRng.Find.Execute('ver_zekering', False, False, False, False, False, True, 1, False, 'test1', 2)
            txtRng.Find.Execute('alle_verzekeringen', False, False, False, False, False, True, 1, False, 'test1', 2)
            txtRng.Find.Execute('aanvangs_datum', False, False, False, False, False, True, 1, False, 'test1', 2)
            txtRng.Find.Execute('for_mule', False, False, False, False, False, True, 1, False, 'test1', 2)
            txtRng.Find.Execute('domi_adres_lijn1', False, False, False, False, False, True, 1, False, domi_adres_lijn1, 2)
            txtRng.Find.Execute('domi_adres_lijn2', False, False, False, False, False, True, 1, False, domi_adres_lijn2, 2)
            txtRng.Find.Execute('domi_adres_lijn3', False, False, False, False, False, True, 1, False, domi_adres_lijn3, 2)
            txtRng.Find.Execute('cg1_cg2', False, False, False, False, False, True, 1, False, '', 2)
            txtRng.Find.Execute('voor_naam', False, False, False, False, False, True, 1, False, voor_naam, 2)
            txtRng.Find.Execute('achter_naam', False, False, False, False, False, True, 1, False, achter_naam, 2)
            txtRng.Find.Execute('inz_nr_g_sp', False, False, False, False, False, True, 1, False, inz_nr_g_sp, 2)
            txtRng.Find.Execute('extern_nummer', False, False, False, False, False, True, 1, False, extern_nummer, 2)
            txtRng.Find.Execute('geb_datum', False, False, False, False, False, True, 1, False, geb_datum, 2)
            txtRng.Find.Execute('H_aan_spreek', False, False, False, False, False, True, 1, False, H_aan_spreek, 2)
            txtRng.Find.Execute('aan_spreek', False, False, False, False, False, True, 1, False, aan_spreek, 2)
            txtRng.Find.Execute('ge_slacht', False, False, False, False, False, True, 1, False, ge_slacht, 2)
            txtRng.Find.Execute('datum_slashes', False, False, False, False, False, True, 1, False, datum_slashes, 2)
            txtRng.Find.Execute('datum_min', False, False, False, False, False, True, 1, False, datum_min, 2)
            txtRng.Find.Execute('h_h', False, False, False, False, False, True, 1, False, h_h, 2)
            txtRng.Find.Execute('h_ar', False, False, False, False, False, True, 1, False, h_ar, 2)
            txtRng.Find.Execute('bic_nummer', False, False, False, False, False, True, 1, False, 'test1', 2)
            txtRng.Find.Execute('eu_rek_nummer', False, False, False, False, False, True, 1, False, 'test1', 2)
            txtRng.Find.Execute('bb_rek_nummer', False, False, False, False, False, True, 1, False, 'test1', 2)
            txtRng.Find.Execute('ontslag_code', False, False, False, False, False, True, 1, False, 'test1', 2)
            txtRng.Find.Execute('ontslagd_code', False, False, False, False, False, True, 1, False, 'test1', 2)
            txtRng.Find.Execute('ontslag_datum', False, False, False, False, False, True, 1, False, 'test1', 2)
            txtRng.Find.Execute('aansluitings_code', False, False, False, False, False, True, 1, False, 'test1', 2)
            txtRng.Find.Execute('_aansluitingsd_code', False, False, False, False, False, True, 1, False, 'test1', 2)
            txtRng.Find.Execute('aansluitings_datum', False, False, False, False, False, True, 1, False, 'test1', 2)
            txtRng.Find.Execute('nummer_dossier', False, False, False, False, False, True, 1, False, 'test1', 2)
            txtRng.Find.Execute('gebruikers_naam', False, False, False, False, False, True, 1, False, gebruikers_naam, 2)
            txtRng.Find.Execute('bestaande_aandoening1', False, False, False, False, False, True, 1, False, 'test1', 2)
            txtRng.Find.Execute('bestaandaandoening1_duur', False, False, False, False, False, True, 1, False, 'test1', 2)
            txtRng.Find.Execute('bestaande_aandoening2', False, False, False, False, False, True, 1, False, 'test1', 2)
            txtRng.Find.Execute('bestaandaandoening2_duur', False, False, False, False, False, True, 1, False, 'test1', 2)
            txtRng.Find.Execute('bestaande_aandoening3', False, False, False, False, False, True, 1, False, 'test1', 2)
            txtRng.Find.Execute('bestaandaandoening3_duur', False, False, False, False, False, True, 1, False, 'test1', 2)
            txtRng.Find.Execute('bestaande_aandoening4', False, False, False, False, False, True, 1, False, 'test1', 2)
            txtRng.Find.Execute('bestaandaandoening4_duur', False, False, False, False, False, True, 1, False, 'test1', 2)
            txtRng.Find.Execute('bestaande_aandoening5', False, False, False, False, False, True, 1, False, 'test1', 2)
            txtRng.Find.Execute('bestaandaandoening5_duur', False, False, False, False, False, True, 1, False, 'test1', 2)
            txtRng.Find.Execute('ernstige_ziekte1', False, False, False, False, False, True, 1, False, 'test1', 2)
            txtRng.Find.Execute('ernstige_ziekte2', False, False, False, False, False, True, 1, False, 'test1', 2)
            txtRng.Find.Execute('ernstige_ziekte3', False, False, False, False, False, True, 1, False, 'test1', 2)
            txtRng.Find.Execute('ernstige_ziekte4', False, False, False, False, False, True, 1, False, 'test1', 2)
            txtRng.Find.Execute('ernstige_ziekte5', False, False, False, False, False, True, 1, False, 'test1', 2)
            txtRng.Find.Execute('car_v_j', False, False, False, False, False, True, 1, False, 'test1', 2)
            txtRng.Find.Execute('car_h_j', False, False, False, False, False, True, 1, False, 'test1', 2)
            txtRng.Find.Execute('eind_wacht', False, False, False, False, False, True, 1, False, 'test1', 2)
            txtRng.Find.Execute('d_l_betaal', False, False, False, False, False, True, 1, False, 'test1', 2)
            txtRng.Find.Execute('m_w', False, False, False, False, False, True, 1, False, 'test1', 2)
            txtRng.Find.Execute('info_text', False, False, False, False, False, True, 1, False, 'test1', 2)
            txtRng.Find.Execute('wat_binnen_brengen1', False, False, False, False, False, True, 1, False, 'test', 2)
            txtRng.Find.Execute('wat_binnen_brengen2', False, False, False, False, False, True, 1, False, 'test', 2)
            txtRng.Find.Execute('wat_binnen_brengen3', False, False, False, False, False, True, 1, False, 'test', 2)
            txtRng.Find.Execute('wat_binnen_brengen4', False, False, False, False, False, True, 1, False, 'test', 2)
            txtRng.Find.Execute('wat_binnen_brengen5', False, False, False, False, False, True, 1, False, 'test', 2)
            txtRng.Find.Execute('wat_binnen_brengen6', False, False, False, False, False, True, 1, False, 'test', 2)
            txtRng.Find.Execute('wat_binnen_brengen7', False, False, False, False, False, True, 1, False, 'test', 2)
            txtRng.Find.Execute('wat_binnen_brengen8', False, False, False, False, False, True, 1, False, 'test', 2)
            txtRng.Find.Execute('wat_binnen_brengen9', False, False, False, False, False, True, 1, False, 'test', 2)
            txtRng.Find.Execute('wat_binnen_brengen010', False, False, False, False, False, True, 1, False, 'test', 2)
            txtRng.Find.Execute('wat_binnen_brengen011', False, False, False, False, False, True, 1, False, 'test', 2)
            txtRng.Find.Execute('wat_binnen_brengen012', False, False, False, False, False, True, 1, False, 'test', 2)
            txtRng.Find.Execute('wat_binnen_brengen013', False, False, False, False, False, True, 1, False, 'test', 2)
            txtRng.Find.Execute('wat_binnen_brengen014', False, False, False, False, False, True, 1, False, 'test', 2)
            txtRng.Find.Execute('wat_binnen_brengen015', False, False, False, False, False, True, 1, False, 'test', 2)
            txtRng.Find.Execute('wat_binnen_brengen016', False, False, False, False, False, True, 1, False, 'test', 2)
            txtRng.Find.Execute('wat_binnen_brengen017', False, False, False, False, False, True, 1, False, 'test', 2)
            txtRng.Find.Execute('wat_binnen_brengen018', False, False, False, False, False, True, 1, False, 'test', 2)
            txtRng.Find.Execute('verz_tekst1', False, False, False, False, False, True, 1, False, 'test', 2)
            txtRng.Find.Execute('verz_tekst2', False, False, False, False, False, True, 1, False, 'test', 2)
            txtRng.Find.Execute('verz_tekst3', False, False, False, False, False, True, 1, False, 'test', 2)
            txtRng.Find.Execute('verz_tekst4', False, False, False, False, False, True, 1, False, 'test', 2)
            txtRng.Find.Execute('verz_tekst5', False, False, False, False, False, True, 1, False, 'test', 2)
            txtRng.Find.Execute('verz_tekst6', False, False, False, False, False, True, 1, False, 'test', 2)
            txtRng.Find.Execute('verz_tekst7', False, False, False, False, False, True, 1, False, 'test', 2)
            txtRng.Find.Execute('verz_tekst8', False, False, False, False, False, True, 1, False, 'test', 2)
            txtRng.Find.Execute('pre_mie', False, False, False, False, False, True, 1, False, 'test', 2)
            txtRng.Find.Execute('agent_tekst', False, False, False, False, False, True, 1, False, 'test', 2)
            txtRng.Find.Execute('Plaats_datum', False, False, False, False, False, True, 1, False, 'test', 2)
            
            for tbl in txtRng.Tables:
                '''Kijkt naar de tabellen in het document, voegt genoeg rijen toe en vult ze in met de juiste data'''

                if tbl.Title == 'overzicht_dossier':

                    for idx, item in enumerate(overview_file_name):
                        tbl.Rows.Add(tbl.Rows[1])
        
                        if idx+2 == len(overview_file_name):
                            break
                    
                    counter = 2
                    for name in overview_file_name:
                        tbl.Cell(counter,1).Range.Text = name
                        tbl.Cell(counter,2).Range.Text = inz_number[counter-2]
                        tbl.Cell(counter,3).Range.Text = ad_number[counter-2]
                        tbl.Cell(counter,4).Range.Text = od_number[counter-2]
                        counter += 1
                
                if tbl.Title == 'overzicht_verzekeringen':
                    
                    for idx, item in enumerate(overview_file_name):
                        tbl.Rows.Add(tbl.Rows[0])
                        
                        if idx+2 == len(overview_file_name):
                            break
                    
                    counter = 1
                    for name in overview_file_name:
                        tbl.Cell(counter,1).Range.Text = name
                        tbl.Cell(counter,2).Range.Text = inz_number[counter-1]
                        tbl.Cell(counter,3).Range.Text = ad_number[counter-1]
                        tbl.Cell(counter,4).Range.Text = od_number[counter-1]
                        counter += 1
                
                if tbl.Title == 'bestaande_aandoening':
        
                    for idx, item in enumerate(overview_file_name):
                        tbl.Rows.Add(tbl.Rows[1])
        
                        if idx+2 == len(overview_file_name):
                            break
                    
                    counter = 2
                    for name in overview_file_name:
                        tbl.Cell(counter,1).Range.Text = name
                        tbl.Cell(counter,2).Range.Text = inz_number[counter-2]
                        tbl.Cell(counter,3).Range.Text = ad_number[counter-2]
                        counter += 1           
                
                if tbl.Title == 'een_kolom_bestaande':
        
                    for idx, item in enumerate(overview_file_name):
                        tbl.Rows.Add(tbl.Rows[1])
        
                        if idx+2 == len(overview_file_name):
                            break
                    
                    counter = 2
                    for name in overview_file_name:
                        tbl.Cell(counter,1).Range.Text = name
                        counter += 1  
                
                if tbl.Title == 'ontslag_aansluiting':
                    
                    for idx, item in enumerate(overview_file_name):
                        tbl.Rows.Add(tbl.Rows[1])
        
                        if idx+2 == len(overview_file_name):
                            break
                    
                    counter = 2
                    for name in overview_file_name:
                        tbl.Cell(counter,1).Range.Text = name
                        tbl.Cell(counter,2).Range.Text = inz_number[counter-2]
                        tbl.Cell(counter,3).Range.Text = ad_number[counter-2]
                        tbl.Cell(counter,4).Range.Text = od_number[counter-2]
                        counter += 1               
                
                if tbl.Title == 'aansluitings_overzicht':
                    
                    for idx, item in enumerate(overview_file_name):
                        tbl.Rows.Add(tbl.Rows[1])
        
                        if idx+2 == len(overview_file_name):
                            break
                    
                    counter = 2
                    for name in overview_file_name:
                        tbl.Cell(counter,1).Range.Text = name
                        tbl.Cell(counter,2).Range.Text = inz_number[counter-2]
                        tbl.Cell(counter,3).Range.Text = ad_number[counter-2]
                        counter += 1 
                
            
    '''Dit deel gaat het document af en plaatst er de juiste info in'''
    word.Selection.Find.Execute('wat_binnen_brengen1', False, False, False, False, False, True, 1, False, 'test', 2)
    word.Selection.Find.Execute('wat_binnen_brengen2', False, False, False, False, False, True, 1, False, 'test', 2)
    word.Selection.Find.Execute('wat_binnen_brengen3', False, False, False, False, False, True, 1, False, 'test', 2)
    word.Selection.Find.Execute('wat_binnen_brengen4', False, False, False, False, False, True, 1, False, 'test', 2)
    word.Selection.Find.Execute('wat_binnen_brengen5', False, False, False, False, False, True, 1, False, 'test', 2)
    word.Selection.Find.Execute('wat_binnen_brengen6', False, False, False, False, False, True, 1, False, 'test', 2)
    word.Selection.Find.Execute('wat_binnen_brengen7', False, False, False, False, False, True, 1, False, 'test', 2)
    word.Selection.Find.Execute('wat_binnen_brengen8', False, False, False, False, False, True, 1, False, 'test', 2)
    word.Selection.Find.Execute('wat_binnen_brengen9', False, False, False, False, False, True, 1, False, 'test', 2)
    word.Selection.Find.Execute('wat_binnen_brengen010', False, False, False, False, False, True, 1, False, 'test', 2)
    word.Selection.Find.Execute('wat_binnen_brengen011', False, False, False, False, False, True, 1, False, 'test', 2)
    word.Selection.Find.Execute('wat_binnen_brengen012', False, False, False, False, False, True, 1, False, 'test', 2)
    word.Selection.Find.Execute('wat_binnen_brengen013', False, False, False, False, False, True, 1, False, 'test', 2)
    word.Selection.Find.Execute('wat_binnen_brengen014', False, False, False, False, False, True, 1, False, 'test', 2)
    word.Selection.Find.Execute('wat_binnen_brengen015', False, False, False, False, False, True, 1, False, 'test', 2)
    word.Selection.Find.Execute('wat_binnen_brengen016', False, False, False, False, False, True, 1, False, 'test', 2)
    word.Selection.Find.Execute('wat_binnen_brengen017', False, False, False, False, False, True, 1, False, 'test', 2)
    word.Selection.Find.Execute('wat_binnen_brengen018', False, False, False, False, False, True, 1, False, 'test', 2)
    word.Selection.Find.Execute('verz_tekst1', False, False, False, False, False, True, 1, False, 'test', 2)
    word.Selection.Find.Execute('verz_tekst2', False, False, False, False, False, True, 1, False, 'test', 2)
    word.Selection.Find.Execute('verz_tekst3', False, False, False, False, False, True, 1, False, 'test', 2)
    word.Selection.Find.Execute('verz_tekst4', False, False, False, False, False, True, 1, False, 'test', 2)
    word.Selection.Find.Execute('verz_tekst5', False, False, False, False, False, True, 1, False, 'test', 2)
    word.Selection.Find.Execute('verz_tekst6', False, False, False, False, False, True, 1, False, 'test', 2)
    word.Selection.Find.Execute('verz_tekst7', False, False, False, False, False, True, 1, False, 'test', 2)
    word.Selection.Find.Execute('verz_tekst8', False, False, False, False, False, True, 1, False, 'test', 2)
    word.Selection.Find.Execute('pre_mie', False, False, False, False, False, True, 1, False, 'test', 2)
    word.Selection.Find.Execute('agent_tekst', False, False, False, False, False, True, 1, False, 'test', 2)
    word.Selection.Find.Execute('Plaats_datum', False, False, False, False, False, True, 1, False, 'test', 2)
    word.Selection.Find.Execute('brief_adres_lijn1', False, False, False, False, False, True, 1, False, 'test1', 2)
    word.Selection.Find.Execute('brief_adres_lijn2', False, False, False, False, False, True, 1, False, 'test1', 2)
    word.Selection.Find.Execute('brief_adres_lijn3', False, False, False, False, False, True, 1, False, 'test1', 2)
    word.Selection.Find.Execute('brief_adres_lijn4', False, False, False, False, False, True, 1, False, 'test1', 2)
    word.Selection.Find.Execute('inz_nr_spatie', False, False, False, False, False, True, 1, False, 'test1', 2)
    word.Selection.Find.Execute('datum_geschreven', False, False, False, False, False, True, 1, False, 'test1', 2)
    word.Selection.Find.Execute('agr_nr', False, False, False, False, False, True, 1, False, 'test1', 2)
    word.Selection.Find.Execute('zkf_nr', False, False, False, False, False, True, 1, False, 'test1', 2)
    word.Selection.Find.Execute('ver_zekering  ', False, False, False, False, False, True, 1, False, 'test1', 2)
    word.Selection.Find.Execute('alle_verzekeringen', False, False, False, False, False, True, 1, False, 'test1', 2)
    word.Selection.Find.Execute('aanvangs_datum', False, False, False, False, False, True, 1, False, 'test1', 2)
    word.Selection.Find.Execute('for_mule', False, False, False, False, False, True, 1, False, 'test1', 2)
    word.Selection.Find.Execute('domi_adres_lijn1', False, False, False, False, False, True, 1, False, 'test1', 2)
    word.Selection.Find.Execute('domi_adres_lijn2', False, False, False, False, False, True, 1, False, 'test1', 2)
    word.Selection.Find.Execute('domi_adres_lijn3', False, False, False, False, False, True, 1, False, 'test1', 2)
    word.Selection.Find.Execute('cg1_cg2', False, False, False, False, False, True, 1, False, 'test1', 2)
    word.Selection.Find.Execute('voor_naam', False, False, False, False, False, True, 1, False, 'test1', 2)
    word.Selection.Find.Execute('achter_naam', False, False, False, False, False, True, 1, False, 'test1', 2)
    word.Selection.Find.Execute('inz_nr_g_sp', False, False, False, False, False, True, 1, False, 'test1', 2)
    word.Selection.Find.Execute('extern_nummer', False, False, False, False, False, True, 1, False, 'test1', 2)
    word.Selection.Find.Execute('geb_datum', False, False, False, False, False, True, 1, False, 'test1', 2)
    word.Selection.Find.Execute('H_aan_spreek', False, False, False, False, False, True, 1, False, 'test1', 2)
    word.Selection.Find.Execute('aan_spreek', False, False, False, False, False, True, 1, False, 'test1', 2)
    word.Selection.Find.Execute('ge_slacht', False, False, False, False, False, True, 1, False, 'test1', 2)
    word.Selection.Find.Execute('datum_slashes', False, False, False, False, False, True, 1, False, 'test1', 2)
    word.Selection.Find.Execute('datum_min', False, False, False, False, False, True, 1, False, 'test1', 2)
    word.Selection.Find.Execute('h_h', False, False, False, False, False, True, 1, False, 'test1', 2)
    word.Selection.Find.Execute('h_ar', False, False, False, False, False, True, 1, False, 'test1', 2)
    word.Selection.Find.Execute('bic_nummer', False, False, False, False, False, True, 1, False, 'test1', 2)
    word.Selection.Find.Execute('eu_rek_nummer', False, False, False, False, False, True, 1, False, 'test1', 2)
    word.Selection.Find.Execute('bb_rek_nummer', False, False, False, False, False, True, 1, False, 'test1', 2)
    word.Selection.Find.Execute('ontslag_code', False, False, False, False, False, True, 1, False, 'test1', 2)
    word.Selection.Find.Execute('ontslagd_code', False, False, False, False, False, True, 1, False, 'test1', 2)
    word.Selection.Find.Execute('ontslag_datum', False, False, False, False, False, True, 1, False, 'test1', 2)
    word.Selection.Find.Execute('aansluitings_code', False, False, False, False, False, True, 1, False, 'test1', 2)
    word.Selection.Find.Execute('_aansluitingsd_code', False, False, False, False, False, True, 1, False, 'test1', 2)
    word.Selection.Find.Execute('aansluitings_datum', False, False, False, False, False, True, 1, False, 'test1', 2)
    word.Selection.Find.Execute('nummer_dossier', False, False, False, False, False, True, 1, False, 'test1', 2)
    word.Selection.Find.Execute('gebruikers_naam', False, False, False, False, False, True, 1, False, 'test1', 2)
    word.Selection.Find.Execute('bestaande_aandoening1', False, False, False, False, False, True, 1, False, 'test1', 2)
    word.Selection.Find.Execute('bestaandaandoening1_duur', False, False, False, False, False, True, 1, False, 'test1', 2)
    word.Selection.Find.Execute('bestaande_aandoening2', False, False, False, False, False, True, 1, False, 'test1', 2)
    word.Selection.Find.Execute('bestaandaandoening2_duur', False, False, False, False, False, True, 1, False, 'test1', 2)
    word.Selection.Find.Execute('bestaande_aandoening3', False, False, False, False, False, True, 1, False, 'test1', 2)
    word.Selection.Find.Execute('bestaandaandoening3_duur', False, False, False, False, False, True, 1, False, 'test1', 2)
    word.Selection.Find.Execute('bestaande_aandoening4', False, False, False, False, False, True, 1, False, 'test1', 2)
    word.Selection.Find.Execute('bestaandaandoening4_duur', False, False, False, False, False, True, 1, False, 'test1', 2)
    word.Selection.Find.Execute('bestaande_aandoening5', False, False, False, False, False, True, 1, False, 'test1', 2)
    word.Selection.Find.Execute('bestaandaandoening5_duur', False, False, False, False, False, True, 1, False, 'test1', 2)
    word.Selection.Find.Execute('ernstige_ziekte1', False, False, False, False, False, True, 1, False, 'test1', 2)
    word.Selection.Find.Execute('ernstige_ziekte2', False, False, False, False, False, True, 1, False, 'test1', 2)
    word.Selection.Find.Execute('ernstige_ziekte3', False, False, False, False, False, True, 1, False, 'test1', 2)
    word.Selection.Find.Execute('ernstige_ziekte4', False, False, False, False, False, True, 1, False, 'test1', 2)
    word.Selection.Find.Execute('ernstige_ziekte5', False, False, False, False, False, True, 1, False, 'test1', 2)
    word.Selection.Find.Execute('car_v_j', False, False, False, False, False, True, 1, False, 'test1', 2)
    word.Selection.Find.Execute('car_h_j', False, False, False, False, False, True, 1, False, 'test1', 2)
    word.Selection.Find.Execute('eind_wacht', False, False, False, False, False, True, 1, False, 'test1', 2)
    word.Selection.Find.Execute('d_l_betaal', False, False, False, False, False, True, 1, False, 'test1', 2)
    word.Selection.Find.Execute('m_w', False, False, False, False, False, True, 1, False, 'test1', 2)
    word.Selection.Find.Execute('info_text', False, False, False, False, False, True, 1, False, 'test1', 2)
            
            
    '''slaat het document op op een andere plaats dan het sjabloon'''
    word.ActiveDocument.SaveAs(location)
    
    
    if place == '':
        '''Sommige documenten moeten openblijven voor manueel in te vullen'''
        
        word.Visible = True
       
    else:
        '''Hier moet er nog voorzien worden dat er geprint of gemaild kan worden'''
        word.Quit()
  
