# -*- coding: utf-8 -*-
"""
Created on Fri Aug 13 09:50:02 2021

@author: Tijs Conings
"""

from client_getter_test import Customer
from sjabloon_invullen_test import make_doc
import wx
from varia_klassen import compare_insurances
from varia_klassen import date_formatter
from soap_calls_test import agresso_client
from varia_klassen import get_nat_nr_from_agresso

app = wx.App()

class Frame(wx.Frame):
    '''Frame maken waar alles ingezet kan worden'''
    
    text_frame = {}
    text = {}
    buttons = {}
    toolbar_buttons = {}
    tabs = {}
    checks = {}
    box = {}
    
    def __init__(self, *args, **kwargs):
        '''een klasse gemaakt om makkelijk een menu aan te maken met verschillende onderdelen'''
        
        #Frame() roept de class: Frame op, daarom moet je een super() gebruiken die de juiste argumenten voor de frame class meegeeft
        super().__init__(*args, **kwargs)
        
        global panel
        panel = wx.Panel(self)
        
        #zorgt er voor dat bij een nieuwe instance van de klasse alle dictionaries terug leeg zijn
        Frame.text_frame = {}
        Frame.text = {}
        Frame.buttons = {}
        Frame.toolbar_buttons = {}
        Frame.tabs = {}
        Frame.checks = {}
        Frame.box = {}
        
        self.Centre()
           
    def text_box(self, text_box_name, *args, **kwargs):
        '''een tekstbox aanmaken'''
        
        text_box = wx.TextCtrl(*args, **kwargs)
        Frame.text_frame[text_box_name] = text_box
        
    def check_box(self, check_box_name, *args, **kwargs):
        '''een check box aanmaken'''
        
        check_box = wx.CheckBox(*args, **kwargs)
        Frame.checks[check_box_name] = check_box
        
    def static_text(self, *args, **kwargs):
        '''statische tekst aanmaken'''
        
        wx.StaticText(*args, **kwargs)
        
    def button(self, button_name, *args, **kwargs):
        '''een knop aanmaken'''
        
        button = wx.Button(*args, **kwargs)
        Frame.buttons[button_name] = button
        
    def combo_box(self, box_name, *args, **kwargs):
        '''Een knop met vaste keuzes maken'''
        
        box = wx.ComboBox(*args, **kwargs)
        Frame.box[box_name] = box
    
    def get_text(self, event):
        '''de tekst uit een tekstbox halen'''
        
        for key in Frame.text_frame:
            txt = Frame.text_frame[key].GetValue()
            Frame.text[key] = txt
            event.Skip()
            
    def toolbar(self, images):
        '''een toolbar aanmaken met knoppen in'''
        
        tb = self.CreateToolBar()

        counter = 0
        for im in images:
            
            Frame.toolbar_buttons[str(counter)] = tb.AddTool(counter,str(counter), wx.Bitmap(im))
            counter += 1
        
        tb.Realize()
        
        return tb
    
    def notebook(self):
        '''een notebook aanmaken'''
        
        notebook = wx.Notebook(panel)
        return notebook
    
    def make_tab(self, notebook, name):
        '''Een tabblad maken in een notebook en de naam opslaan in een dictionary'''
        
        tab = wx.Panel(notebook)
        notebook.AddPage(tab, name)
        Frame.tabs[name] = tab
        
    def on_close(self, event):
        '''Menus sluiten voor daarna een ander te openen'''
        
        self.Destroy()
        event.Skip()
    
    def on_exit(self, event):
        '''Menu sluiten en het programma beindigen'''

        self.Destroy()
        wx.Exit()
        
def get_customer(event):
    '''Hier roepen we de class customer op met het rijksregisternummer dat we ingevuld hebben'''
    
    global customer
    
    #staat het ingevulde rijksregisternummer in de database?
    try:
        
        #kijken of we waarden uit het eerste of tweede venster moeten halen
        try:
            
            #waarden uit het eerste venster halen
            nat_nr = window1.w.text['nat_nr']
            zfk_nr = window1.w.text['zfk_nr']
            
        except:
            
            #waarden uit het tweede venster halen
            nat_nr = window2.w.text['Rijksreg. Nr.']
            zfk_nr = '203'
         
        #kijken of de ingevulde nummerlengte overeenkomt met wat er moet ingevuld zijn             
        if nat_nr.isdecimal() == True and len(nat_nr) == 11 and zfk_nr.isdecimal() == True and len(zfk_nr) == 3:

            customer = Customer(nat_nr, zfk_nr)
            event.Skip()
        
        else:
            dial = wx.MessageDialog(None, 'Foute waarde', 'Error', wx.OK|wx.STAY_ON_TOP|wx.CENTRE)
            dial.ShowModal()
        
    except Exception as e:
        print(e)
        dial = wx.MessageDialog(None, 'Het rijksregisternummer/ziekefondsnummer staat niet in de database.', 'Error', wx.OK|wx.STAY_ON_TOP|wx.CENTRE)
        dial.ShowModal()

def get_customer_agresso(event):
    '''Een manier om met het agresso nummer een klant op te halen uit de as400'''

    try:
 
        #nat_nr uit agresso halen
        agresso_nr = window2.w.text['Agresso Nummer']
        zfk_nr = '203'

        if agresso_nr.isdecimal() == True and len(agresso_nr) == 6 and zfk_nr.isdecimal() == True and len(zfk_nr) == 3:

            nat_nr = get_nat_nr_from_agresso(agresso_nr)

            global customer
            customer = Customer(nat_nr, zfk_nr)
            event.Skip()

        else:
            dial = wx.MessageDialog(None, 'Foute waarde', 'Error', wx.OK|wx.STAY_ON_TOP|wx.CENTRE)
            dial.ShowModal()
            
    except Exception as e:
        print(e)
        dial = wx.MessageDialog(None, 'Het agresso nummer staat niet in de database.', 'Error', wx.OK|wx.STAY_ON_TOP|wx.CENTRE)
        dial.ShowModal()

def open_file_dialog(event):
    '''Open een file dialoog waar we een sjabloon uit kunnen kiezen'''
    
    file_dialog = wx.FileDialog(None, "Welk Sjabloon?", "P:\OGV\BRIEFWISSELING_NIEUW\SjablonenWord", "","docx files (*.docx)|*.docx", style = wx.FD_OPEN | wx.FD_FILE_MUST_EXIST);
    file_dialog.ShowModal()
    place = file_dialog.GetPath()
    file = file_dialog.GetFilename()
    file = file[:-5]
    file += '_aangepast.docx'
    location = 'P:\OGV\BRIEFWISSELING_NIEUW\Brieven\\' + file
    make_doc(place, location, customer)
    event.Skip()
   
def window1():
    '''hier maken we de eerste window waar je rijksregisterNr en ziekenfondsNr moet ingeven'''
    
    window = Frame(parent = None, title = 'rijksregisterNr & ZiekenfondsNr', size = (400,150), style = wx.MINIMIZE_BOX | wx.MAXIMIZE_BOX | wx.RESIZE_BORDER | wx.SYSTEM_MENU | wx.CAPTION | wx.CLIP_CHILDREN)
    
    
    window.text_box('nat_nr', parent = panel,  size = (110,20), pos = (50,40))
    window.text_box('zfk_nr', parent = panel,  size = (110,20), pos = (235,40))
    
    window.static_text(parent = panel, label = 'Rijksregisternummer', pos = (50,10))
    window.static_text(parent = panel, label = 'ziekenfondsnummer', pos = (235,10))
    
    window.button('OK', parent = panel, label = 'OK', pos = (50,70))
    window.button('Cancel', parent = panel, label = 'Cancel', pos = (235,70))
    
    #hier bepalen we wat de knoppen doen
    window.buttons['Cancel'].Bind(wx.EVT_BUTTON, window.on_close) #sluit het frame en eindigd het programma
    
    window.buttons['OK'].Bind(wx.EVT_BUTTON, window2) #opent het file dialoog
    window.buttons['OK'].Bind(wx.EVT_BUTTON, window.on_close) #zorgt dat window 1 dichtgaat als het menu dichtgaat
    window.buttons['OK'].Bind(wx.EVT_BUTTON, get_customer) #voert de class Customer uit voor het getypte nat_nr
    window.buttons['OK'].Bind(wx.EVT_BUTTON, window.get_text) #haalt de tekst op die in de tekstvakken wordt getypt
    
    window1.w = window
        
    window.Show()
    app.MainLoop()
    
def window2(event):
    '''de tweede window is een heel menu met allemaal verschillende submenus'''
    
    #de verzekeringen van de klant opslaan
    ins_for_agresso = compare_insurances(customer)
    
    Verzekering1_naam = ''
    Verzekering1_begin = ''
    Verzekering1_eind = ''
    Verzekering1_wacht = ''
    Verzekering1_zfk = ''
    Verzekering1_dos_nr = ''
    
    Verzekering2_naam = ''
    Verzekering2_begin = ''
    Verzekering2_eind = ''
    Verzekering2_wacht = ''
    Verzekering2_zfk = ''
    Verzekering2_dos_nr = ''
    
    Verzekering3_naam = ''
    Verzekering3_begin = ''
    Verzekering3_eind = ''
    Verzekering3_wacht = ''
    Verzekering3_zfk = ''
    Verzekering3_dos_nr = ''
    
    Verzekering4_naam = ''
    Verzekering4_begin = ''
    Verzekering4_eind = ''
    Verzekering4_wacht = ''
    Verzekering4_zfk = ''
    Verzekering4_dos_nr = ''
    
    Verzekering5_naam = ''
    Verzekering5_begin = ''
    Verzekering5_eind = ''
    Verzekering5_wacht = ''
    Verzekering5_zfk = ''
    Verzekering5_dos_nr = ''
    
    counter = 0
    for ins in ins_for_agresso:
        
        if counter == 0:
            Verzekering1_naam = ins['product']
            Verzekering1_begin = date_formatter(ins['start_date'])
            Verzekering1_eind = date_formatter(ins['end_date'])
            Verzekering1_wacht = date_formatter(ins['wait_date'])
            Verzekering1_zfk = ins['zfk_number']
            Verzekering1_dos_nr = ins['contract_number'][-9:]
         
        elif counter == 1:
            Verzekering2_naam = ins['product']
            Verzekering2_begin = date_formatter(ins['start_date'])
            Verzekering2_eind = date_formatter(ins['end_date'])
            Verzekering2_wacht = date_formatter(ins['wait_date'])
            Verzekering2_zfk = ins['zfk_number']
            Verzekering2_dos_nr = ins['contract_number'][-9:]
        
        elif counter == 2:
            Verzekering3_naam = ins['product']
            Verzekering3_begin = date_formatter(ins['start_date'])
            Verzekering3_eind = date_formatter(ins['end_date'])
            Verzekering3_wacht = date_formatter(ins['wait_date'])
            Verzekering3_zfk = ins['zfk_number']
            Verzekering3_dos_nr = ins['contract_number'][-9:]
        
        elif counter == 3:
            Verzekering4_naam = ins['product']
            Verzekering4_begin = date_formatter(ins['start_date'])
            Verzekering4_eind = date_formatter(ins['end_date'])
            Verzekering4_wacht = date_formatter(ins['wait_date'])
            Verzekering4_zfk = ins['zfk_number']
            Verzekering4_dos_nr = ins['contract_number'][-9:]
        
        elif counter == 4:
            Verzekering5_naam = ins['product']
            Verzekering5_begin = date_formatter(ins['start_date'])
            Verzekering5_eind = date_formatter(ins['end_date'])
            Verzekering5_wacht = date_formatter(ins['wait_date'])
            Verzekering5_zfk = ins['zfk_number']
            Verzekering5_dos_nr = ins['contract_number'][-9:]
            
        counter +=1
    
    #AS400 waarden in agresso zetten en de agresso nummer uit agresso halen
    agresso_client(customer.data['nat_nr'], customer)
    agresso_nummer = agresso_client.agresso_id
    
    #de geboortedatum omzetten naar het juiste formaat
    geb_datum = date_formatter(customer.data['birth_date'])
    
    #alle locaties van de fotos voor de toolbar
    file = ['P:\OGV\TIJS\\button_opslaan.png', 'P:\OGV\TIJS\\button_print.png', 'P:\OGV\TIJS\\button_bestaat.png', 'P:\OGV\TIJS\\button_reset.png', 'P:\OGV\TIJS\\button_cancel.png']
    images = []
    
    #fotos van knoppen verkleinen
    for f in file:
        image = wx.Bitmap.ConvertToImage(wx.Bitmap(f))
        image = image.Scale(40, 25, wx.IMAGE_QUALITY_HIGH)
        images.append(image) 
    
    window = Frame(parent = None, title = 'Menu', size = (1865,380), style = wx.MINIMIZE_BOX | wx.MAXIMIZE_BOX | wx.RESIZE_BORDER | wx.SYSTEM_MENU | wx.CAPTION | wx.CLIP_CHILDREN | wx.MINIMIZE)

    #toolbar maken en de verschillende tabbladen
    notebook = window.notebook()
    toolbar = window.toolbar(images)
    
    #tabbladen in notebook maken
    window.make_tab(notebook, "Lid, Opname, Verzekeringen")
    window.make_tab(notebook, "Bestaande Aandoeningen")
    window.make_tab(notebook, "Ernstige Ziekten")
    window.make_tab(notebook, "GKD")
    window.make_tab(notebook, "Brieven Maken")
    window.make_tab(notebook, "Automatische Brieven")
    window.make_tab(notebook, "MIFID ONTBREKENDE DOCUMENTEN")
    window.make_tab(notebook, "MIFID ONTBREKENDE DOCUMENTEN OMSCHAKELING")
    window.make_tab(notebook, "MIFID AANSLUITING NOG NIET MOGELIJK")
    
    #tabbladen juist schalen
    sizer = wx.BoxSizer(wx.HORIZONTAL)
    sizer.Add(notebook, 1, wx.RIGHT|wx.EXPAND, 0)
    panel.SetSizer(sizer)
    notebook.Layout()
    
    #alle knoppen en text voor het eerste tabblad
    window.button('Agresso Nummer:', parent = window.tabs['Lid, Opname, Verzekeringen'], label = 'Agresso Nummer:', pos = (10,10), size = (115,21))
    window.button('Naam:', parent = window.tabs['Lid, Opname, Verzekeringen'], label = 'Naam:', pos = (10,40), size = (115,21))
    window.button('Rijksreg. Nr.:', parent = window.tabs['Lid, Opname, Verzekeringen'], label = 'Rijksreg. Nr.:', pos = (10,70), size = (115,21))
    window.button('Geboortedatum:', parent = window.tabs['Lid, Opname, Verzekeringen'], label = 'Geboortedatum:', pos = (10,100), size = (115,21))
    
    window.button('Verzekering', parent = window.tabs['Lid, Opname, Verzekeringen'], label = 'Verzekering', pos = (700,10), size = (200,21))
    window.button('Begin', parent = window.tabs['Lid, Opname, Verzekeringen'], label = 'Begin', pos = (935,10), size = (100,21))
    window.button('Eind', parent = window.tabs['Lid, Opname, Verzekeringen'], label = 'Eind', pos = (1070,10), size = (100,21))
    window.button('Wacht', parent = window.tabs['Lid, Opname, Verzekeringen'], label = 'Wacht', pos = (1205,10), size = (100,21))
    window.button('ZFK/GKD', parent = window.tabs['Lid, Opname, Verzekeringen'], label = 'ZFK/GKD', pos = (1340,10), size = (100,21))
    window.button('Dossier Nr.', parent = window.tabs['Lid, Opname, Verzekeringen'], label = 'Dossier Nr.', pos = (1470,10), size = (100,21))
    
    
    window.text_box('Agresso Nummer', parent = window.tabs['Lid, Opname, Verzekeringen'], size = (300,21), pos = (130,11), value = agresso_nummer)
    window.text_box('Naam', parent = window.tabs['Lid, Opname, Verzekeringen'], size = (300,21), pos = (130,41), value = (customer.data['name'] + ' ' + customer.data['last_name']).upper())
    window.text_box('Rijksreg. Nr.', parent = window.tabs['Lid, Opname, Verzekeringen'], size = (300,21), pos = (130,71), value = customer.data['nat_nr'])
    window.text_box('Geboortedatum', parent = window.tabs['Lid, Opname, Verzekeringen'], size = (300,21), pos = (130,101), value = geb_datum)
    
    window.text_box('Verzekering1_naam', parent = window.tabs['Lid, Opname, Verzekeringen'], size = (200,21), pos = (700,41), value = Verzekering1_naam)
    window.text_box('Verzekering2_naam', parent = window.tabs['Lid, Opname, Verzekeringen'], size = (200,21), pos = (700,76), value = Verzekering2_naam)
    window.text_box('Verzekering3_naam', parent = window.tabs['Lid, Opname, Verzekeringen'], size = (200,21), pos = (700,111), value = Verzekering3_naam)
    window.text_box('Verzekering4_naam', parent = window.tabs['Lid, Opname, Verzekeringen'], size = (200,21), pos = (700,146), value = Verzekering4_naam)
    window.text_box('Verzekering5_naam', parent = window.tabs['Lid, Opname, Verzekeringen'], size = (200,21), pos = (700,181), value = Verzekering5_naam)
    
    window.text_box('Verzekering1_begin', parent = window.tabs['Lid, Opname, Verzekeringen'], size = (100,21), pos = (935,41), value = Verzekering1_begin)
    window.text_box('Verzekering2_begin', parent = window.tabs['Lid, Opname, Verzekeringen'], size = (100,21), pos = (935,76), value = Verzekering2_begin)
    window.text_box('Verzekering3_begin', parent = window.tabs['Lid, Opname, Verzekeringen'], size = (100,21), pos = (935,111), value = Verzekering3_begin)
    window.text_box('Verzekering4_begin', parent = window.tabs['Lid, Opname, Verzekeringen'], size = (100,21), pos = (935,146), value = Verzekering4_begin)
    window.text_box('Verzekering5_begin', parent = window.tabs['Lid, Opname, Verzekeringen'], size = (100,21), pos = (935,181), value = Verzekering5_begin)
    
    window.text_box('Verzekering1_eind', parent = window.tabs['Lid, Opname, Verzekeringen'], size = (100,21), pos = (1070,41), value = Verzekering1_eind)
    window.text_box('Verzekering2_eind', parent = window.tabs['Lid, Opname, Verzekeringen'], size = (100,21), pos = (1070,76), value = Verzekering2_eind)
    window.text_box('Verzekering3_eind', parent = window.tabs['Lid, Opname, Verzekeringen'], size = (100,21), pos = (1070,111), value = Verzekering3_eind)
    window.text_box('Verzekering4_eind', parent = window.tabs['Lid, Opname, Verzekeringen'], size = (100,21), pos = (1070,146), value = Verzekering4_eind)
    window.text_box('Verzekering5_eind', parent = window.tabs['Lid, Opname, Verzekeringen'], size = (100,21), pos = (1070,181), value = Verzekering5_eind)
    
    window.text_box('Verzekering1_wacht', parent = window.tabs['Lid, Opname, Verzekeringen'], size = (100,21), pos = (1205,41), value = Verzekering1_wacht)
    window.text_box('Verzekering2_wacht', parent = window.tabs['Lid, Opname, Verzekeringen'], size = (100,21), pos = (1205,76), value = Verzekering2_wacht)
    window.text_box('Verzekering3_wacht', parent = window.tabs['Lid, Opname, Verzekeringen'], size = (100,21), pos = (1205,111), value = Verzekering3_wacht)
    window.text_box('Verzekering4_wacht', parent = window.tabs['Lid, Opname, Verzekeringen'], size = (100,21), pos = (1205,146), value = Verzekering4_wacht)
    window.text_box('Verzekering5_wacht', parent = window.tabs['Lid, Opname, Verzekeringen'], size = (100,21), pos = (1205,181), value = Verzekering5_wacht)
    
    window.text_box('Verzekering1_zfk', parent = window.tabs['Lid, Opname, Verzekeringen'], size = (100,21), pos = (1340,41), value = Verzekering1_zfk)
    window.text_box('Verzekering2_zfk', parent = window.tabs['Lid, Opname, Verzekeringen'], size = (100,21), pos = (1340,76), value = Verzekering2_zfk)
    window.text_box('Verzekering3_zfk', parent = window.tabs['Lid, Opname, Verzekeringen'], size = (100,21), pos = (1340,111), value = Verzekering3_zfk)
    window.text_box('Verzekering4_zfk', parent = window.tabs['Lid, Opname, Verzekeringen'], size = (100,21), pos = (1340,146), value = Verzekering4_zfk)
    window.text_box('Verzekering5_zfk', parent = window.tabs['Lid, Opname, Verzekeringen'], size = (100,21), pos = (1340,181), value = Verzekering5_zfk)
    
    window.text_box('Verzekering1_dos_nr', parent = window.tabs['Lid, Opname, Verzekeringen'], size = (100,21), pos = (1470,41), value = Verzekering1_dos_nr)
    window.text_box('Verzekering2_dos_nr', parent = window.tabs['Lid, Opname, Verzekeringen'], size = (100,21), pos = (1470,76), value = Verzekering2_dos_nr)
    window.text_box('Verzekering3_dos_nr', parent = window.tabs['Lid, Opname, Verzekeringen'], size = (100,21), pos = (1470,111), value = Verzekering3_dos_nr)
    window.text_box('Verzekering4_dos_nr', parent = window.tabs['Lid, Opname, Verzekeringen'], size = (100,21), pos = (1470,146), value = Verzekering4_dos_nr)
    window.text_box('Verzekering5_dos_nr', parent = window.tabs['Lid, Opname, Verzekeringen'], size = (100,21), pos = (1470,181), value = Verzekering5_dos_nr)
    
    window.check_box('Verzekering1_check', parent = window.tabs['Lid, Opname, Verzekeringen'], pos = (680,41))
    window.check_box('Verzekering2_check', parent = window.tabs['Lid, Opname, Verzekeringen'], pos = (680,76))
    window.check_box('Verzekering3_check', parent = window.tabs['Lid, Opname, Verzekeringen'], pos = (680,111))
    window.check_box('Verzekering4_check', parent = window.tabs['Lid, Opname, Verzekeringen'], pos = (680,146))
    window.check_box('Verzekering5_check', parent = window.tabs['Lid, Opname, Verzekeringen'], pos = (680,181))
    
    #Alle tekst en knoppen voor het tweede tabblat
    window.button('Bestaande Aandoening1', parent = window.tabs['Bestaande Aandoeningen'], label = 'Bestaande Aandoening', pos = (10,10), size = (270,21))
    window.button('Begindatum1', parent = window.tabs['Bestaande Aandoeningen'], label = 'Begindatum', pos = (285,10), size = (70,21))
    window.button('Einddatum1', parent = window.tabs['Bestaande Aandoeningen'], label = 'Einddatum', pos = (360,10), size = (70,21))
    window.button('Verzekering1', parent = window.tabs['Bestaande Aandoeningen'], label = 'Verzekering', pos = (435,10), size = (180,21))
    window.button('Bestaande Aandoening2', parent = window.tabs['Bestaande Aandoeningen'], label = 'Bestaande Aandoening:', pos = (620,10), size = (270,21))
    window.button('Begindatum2', parent = window.tabs['Bestaande Aandoeningen'], label = 'Begindatum:', pos = (895,10), size = (70,21))
    window.button('Einddatum2', parent = window.tabs['Bestaande Aandoeningen'], label = 'Einddatum:', pos = (970,10), size = (70,21))
    window.button('Verzekering2', parent = window.tabs['Bestaande Aandoeningen'], label = 'Verzekering:', pos = (1045,10), size = (180,21))
    window.button('Bestaande Aandoening3', parent = window.tabs['Bestaande Aandoeningen'], label = 'Bestaande Aandoening:', pos = (1230,10), size = (270,21))
    window.button('Begindatum3', parent = window.tabs['Bestaande Aandoeningen'], label = 'Begindatum:', pos = (1505,10), size = (70,21))
    window.button('Einddatum3', parent = window.tabs['Bestaande Aandoeningen'], label = 'Einddatum:', pos = (1580,10), size = (70,21))
    window.button('Verzekering3', parent = window.tabs['Bestaande Aandoeningen'], label = 'Verzekering:', pos = (1655,10), size = (180,21))
 
    window.text_box('Bestaande Aandoening1.1', parent = window.tabs['Bestaande Aandoeningen'], pos = (10,41), size = (270,21), value = 'test')
    window.text_box('Begindatum1.1', parent = window.tabs['Bestaande Aandoeningen'], pos = (285,41), size = (70,21), value = 'test')
    window.text_box('Einddatum1.1', parent = window.tabs['Bestaande Aandoeningen'], pos = (360,41), size = (70,21), value = 'test')
    window.text_box('Bestaande Aandoening2.1', parent = window.tabs['Bestaande Aandoeningen'], pos = (620,41), size = (270,21), value = 'test')
    window.text_box('Begindatum2.1', parent = window.tabs['Bestaande Aandoeningen'], pos = (895,41), size = (70,21), value = 'test')
    window.text_box('Einddatum2.1', parent = window.tabs['Bestaande Aandoeningen'], pos = (970,41), size = (70,21), value = 'test')
    window.text_box('Bestaande Aandoening3.1', parent = window.tabs['Bestaande Aandoeningen'], pos = (1230,41), size = (270,21), value = 'test')
    window.text_box('Begindatum3.1', parent = window.tabs['Bestaande Aandoeningen'], pos = (1505,41), size = (70,21), value = 'test')
    window.text_box('Einddatum3.1', parent = window.tabs['Bestaande Aandoeningen'], pos = (1580,41), size = (70,21), value = 'test')
   
    window.combo_box('Verzekering1.1_ba', parent = window.tabs['Bestaande Aandoeningen'], choices = ['HOSPIPLUS_AMBUPLUS', 'HOSPIFORFAIT25'], pos = (435,41), size = (180,21), value = 'test')
    window.combo_box('Verzekering2.1_ba', parent = window.tabs['Bestaande Aandoeningen'], choices = ['HOSPIPLUS_AMBUPLUS', 'HOSPIFORFAIT25'], pos = (1045,41), size = (180,21), value = 'test')
    window.combo_box('Verzekering3.1_ba', parent = window.tabs['Bestaande Aandoeningen'], choices = ['HOSPIPLUS_AMBUPLUS', 'HOSPIFORFAIT25'], pos = (1655,41), size = (180,21), value = 'test')
    
    window.text_box('Bestaande Aandoening1.2', parent = window.tabs['Bestaande Aandoeningen'], pos = (10,71), size = (270,21), value = 'test')
    window.text_box('Begindatum1.2', parent = window.tabs['Bestaande Aandoeningen'], pos = (285,71), size = (70,21), value = 'test')
    window.text_box('Einddatum1.2', parent = window.tabs['Bestaande Aandoeningen'], pos = (360,71), size = (70,21), value = 'test')
    window.text_box('Bestaande Aandoening2.2', parent = window.tabs['Bestaande Aandoeningen'], pos = (620,71), size = (270,21), value = 'test')
    window.text_box('Begindatum2.2', parent = window.tabs['Bestaande Aandoeningen'], pos = (895,71), size = (70,21), value = 'test')
    window.text_box('Einddatum2.2', parent = window.tabs['Bestaande Aandoeningen'], pos = (970,71), size = (70,21), value = 'test')
    window.text_box('Bestaande Aandoening3.2', parent = window.tabs['Bestaande Aandoeningen'], pos = (1230,71), size = (270,21), value = 'test')
    window.text_box('Begindatum3.2', parent = window.tabs['Bestaande Aandoeningen'], pos = (1505,71), size = (70,21), value = 'test')
    window.text_box('Einddatum3.2', parent = window.tabs['Bestaande Aandoeningen'], pos = (1580,71), size = (70,21), value = 'test')
   
    window.combo_box('Verzekering1.3_ba', parent = window.tabs['Bestaande Aandoeningen'], choices = ['HOSPIPLUS_AMBUPLUS', 'HOSPIFORFAIT25'], pos = (435,71), size = (180,21), value = 'test')
    window.combo_box('Verzekering2.3_ba', parent = window.tabs['Bestaande Aandoeningen'], choices = ['HOSPIPLUS_AMBUPLUS', 'HOSPIFORFAIT25'], pos = (1045,71), size = (180,21), value = 'test')
    window.combo_box('Verzekering3.3_ba', parent = window.tabs['Bestaande Aandoeningen'], choices = ['HOSPIPLUS_AMBUPLUS', 'HOSPIFORFAIT25'], pos = (1655,71), size = (180,21), value = 'test')
    
    window.text_box('Bestaande Aandoening1.3', parent = window.tabs['Bestaande Aandoeningen'], pos = (10,101), size = (270,21), value = 'test')
    window.text_box('Begindatum1.3', parent = window.tabs['Bestaande Aandoeningen'], pos = (285,101), size = (70,21), value = 'test')
    window.text_box('Einddatum1.3', parent = window.tabs['Bestaande Aandoeningen'], pos = (360,101), size = (70,21), value = 'test')
    window.text_box('Bestaande Aandoening2.3', parent = window.tabs['Bestaande Aandoeningen'], pos = (620,101), size = (270,21), value = 'test')
    window.text_box('Begindatum2.3', parent = window.tabs['Bestaande Aandoeningen'], pos = (895,101), size = (70,21), value = 'test')
    window.text_box('Einddatum2.3', parent = window.tabs['Bestaande Aandoeningen'], pos = (970,101), size = (70,21), value = 'test')
    window.text_box('Bestaande Aandoening3.3', parent = window.tabs['Bestaande Aandoeningen'], pos = (1230,101), size = (270,21), value = 'test')
    window.text_box('Begindatum3.3', parent = window.tabs['Bestaande Aandoeningen'], pos = (1505,101), size = (70,21), value = 'test')
    window.text_box('Einddatum3.3', parent = window.tabs['Bestaande Aandoeningen'], pos = (1580,101), size = (70,21), value = 'test')
   
    window.combo_box('Verzekering1.3_ba', parent = window.tabs['Bestaande Aandoeningen'], choices = ['HOSPIPLUS_AMBUPLUS', 'HOSPIFORFAIT25'], pos = (435,101), size = (180,21), value = 'test')
    window.combo_box('Verzekering2.3_ba', parent = window.tabs['Bestaande Aandoeningen'], choices = ['HOSPIPLUS_AMBUPLUS', 'HOSPIFORFAIT25'], pos = (1045,101), size = (180,21), value = 'test')
    window.combo_box('Verzekering3.3_ba', parent = window.tabs['Bestaande Aandoeningen'], choices = ['HOSPIPLUS_AMBUPLUS', 'HOSPIFORFAIT25'], pos = (1655,101), size = (180,21), value = 'test')
    
    #Alle tekst en knoppen voor het derde tabblat
    window.button('Ernstige Ziekte1', parent = window.tabs['Ernstige Ziekten'], label = 'Ernstige Ziekte1', pos = (10,10), size = (400,21))
    window.button('Verzekering1', parent = window.tabs['Ernstige Ziekten'], label = 'Verzekering1', pos = (420,10), size = (180,21))
    window.button('Ernstige Ziekte2', parent = window.tabs['Ernstige Ziekten'], label = 'Ernstige Ziekte2', pos = (610,10), size = (400,21))
    window.button('Verzekering2', parent = window.tabs['Ernstige Ziekten'], label = 'Verzekering2', pos = (1020,10), size = (180,21))
    window.button('Ernstige Ziekte3', parent = window.tabs['Ernstige Ziekten'], label = 'Ernstige Ziekte3', pos = (1210,10), size = (400,21))
    window.button('Verzekering3', parent = window.tabs['Ernstige Ziekten'], label = 'Verzekering3', pos = (1620,10), size = (180,21))

    window.text_box('Ernstige Ziekte1.1', parent = window.tabs['Ernstige Ziekten'], pos = (10,40), size = (400,21), value = 'test')
    window.text_box('Ernstige Ziekte2.1', parent = window.tabs['Ernstige Ziekten'], pos = (610,40), size = (400,21), value = 'test')
    window.text_box('Ernstige Ziekte3.1', parent = window.tabs['Ernstige Ziekten'], pos = (1210,40), size = (400,21), value = 'test')
    
    window.combo_box('Verzekering1.1_ez', parent = window.tabs['Ernstige Ziekten'], choices = ['HOSPIPLUS_AMBUPLUS', 'HOSPIFORFAIT25'], pos = (420,40), size = (180,21), value = 'test')
    window.combo_box('Verzekering2.1_ez', parent = window.tabs['Ernstige Ziekten'], choices = ['HOSPIPLUS_AMBUPLUS', 'HOSPIFORFAIT25'], pos = (1020,40), size = (180,21), value = 'test')
    window.combo_box('Verzekering3.1_ez', parent = window.tabs['Ernstige Ziekten'], choices = ['HOSPIPLUS_AMBUPLUS', 'HOSPIFORFAIT25'], pos = (1620,40), size = (180,21), value = 'test')
    
    window.text_box('Ernstige Ziekte1.2', parent = window.tabs['Ernstige Ziekten'], pos = (10,70), size = (400,21), value = 'test')
    window.text_box('Ernstige Ziekte2.2', parent = window.tabs['Ernstige Ziekten'], pos = (610,70), size = (400,21), value = 'test')
    window.text_box('Ernstige Ziekte3.2', parent = window.tabs['Ernstige Ziekten'], pos = (1210,70), size = (400,21), value = 'test')
    
    window.combo_box('Verzekering1.2_ez', parent = window.tabs['Ernstige Ziekten'], choices = ['HOSPIPLUS_AMBUPLUS', 'HOSPIFORFAIT25'], pos = (420,70), size = (180,21), value = 'test')
    window.combo_box('Verzekering2.2_ez', parent = window.tabs['Ernstige Ziekten'], choices = ['HOSPIPLUS_AMBUPLUS', 'HOSPIFORFAIT25'], pos = (1020,70), size = (180,21), value = 'test')
    window.combo_box('Verzekering3.2_ez', parent = window.tabs['Ernstige Ziekten'], choices = ['HOSPIPLUS_AMBUPLUS', 'HOSPIFORFAIT25'], pos = (1620,70), size = (180,21), value = 'test')
    
    window.text_box('Ernstige Ziekte1.3', parent = window.tabs['Ernstige Ziekten'], pos = (10,100), size = (400,21), value = 'test')
    window.text_box('Ernstige Ziekte2.3', parent = window.tabs['Ernstige Ziekten'], pos = (610,100), size = (400,21), value = 'test')
    window.text_box('Ernstige Ziekte3.3', parent = window.tabs['Ernstige Ziekten'], pos = (1210,100), size = (400,21), value = 'test')
    
    window.combo_box('Verzekering1.3_ez', parent = window.tabs['Ernstige Ziekten'], choices = ['HOSPIPLUS_AMBUPLUS', 'HOSPIFORFAIT25'], pos = (420,100), size = (180,21), value = 'test')
    window.combo_box('Verzekering2.3_ez', parent = window.tabs['Ernstige Ziekten'], choices = ['HOSPIPLUS_AMBUPLUS', 'HOSPIFORFAIT25'], pos = (1020,100), size = (180,21), value = 'test')
    window.combo_box('Verzekering3.3_ez', parent = window.tabs['Ernstige Ziekten'], choices = ['HOSPIPLUS_AMBUPLUS', 'HOSPIFORFAIT25'], pos = (1620,100), size = (180,21), value = 'test')
    
    #Alle tekst en knoppen voor het vierde tabblat
    window.text_box('GKD1.1', parent = window.tabs['GKD'], pos = (40,10), size = (260,21), value = 'test')
    window.text_box('GKD2.1', parent = window.tabs['GKD'], pos = (340,10), size = (260,21), value = 'test')
    window.text_box('GKD3.1', parent = window.tabs['GKD'], pos = (640,10), size = (260,21), value = 'test')
    window.text_box('GKD4.1', parent = window.tabs['GKD'], pos = (940,10), size = (260,21), value = 'test')
    window.text_box('GKD5.1', parent = window.tabs['GKD'], pos = (1240,10), size = (260,21), value = 'test') 
    window.text_box('GKD6.1', parent = window.tabs['GKD'], pos = (1540,10), size = (260,21), value = 'test')
    
    window.check_box('GKD1.1_check', parent = window.tabs['GKD'], pos = (20,10))
    window.check_box('GKD2.1_check', parent = window.tabs['GKD'], pos = (320,10))
    window.check_box('GKD3.1_check', parent = window.tabs['GKD'], pos = (620,10))
    window.check_box('GKD4.1_check', parent = window.tabs['GKD'], pos = (920,10))
    window.check_box('GKD5.1_check', parent = window.tabs['GKD'], pos = (1220,10))
    window.check_box('GKD6.1_check', parent = window.tabs['GKD'], pos = (1520,10))
    
    window.text_box('GKD1.2', parent = window.tabs['GKD'], pos = (40,40), size = (260,21), value = 'test')
    window.text_box('GKD2.2', parent = window.tabs['GKD'], pos = (340,40), size = (260,21), value = 'test')
    window.text_box('GKD3.2', parent = window.tabs['GKD'], pos = (640,40), size = (260,21), value = 'test')
    window.text_box('GKD4.2', parent = window.tabs['GKD'], pos = (940,40), size = (260,21), value = 'test')
    window.text_box('GKD5.2', parent = window.tabs['GKD'], pos = (1240,40), size = (260,21), value = 'test') 
    window.text_box('GKD6.2', parent = window.tabs['GKD'], pos = (1540,40), size = (260,21), value = 'test')
    
    window.check_box('GKD1.2_check', parent = window.tabs['GKD'], pos = (20,40))
    window.check_box('GKD2.2_check', parent = window.tabs['GKD'], pos = (320,40))
    window.check_box('GKD3.2_check', parent = window.tabs['GKD'], pos = (620,40))
    window.check_box('GKD4.2_check', parent = window.tabs['GKD'], pos = (920,40))
    window.check_box('GKD5.2_check', parent = window.tabs['GKD'], pos = (1220,40))
    window.check_box('GKD6.2_check', parent = window.tabs['GKD'], pos = (1520,40))
    
    window.text_box('GKD1.3', parent = window.tabs['GKD'], pos = (40,70), size = (260,21), value = 'test')
    window.text_box('GKD2.3', parent = window.tabs['GKD'], pos = (340,70), size = (260,21), value = 'test')
    window.text_box('GKD3.3', parent = window.tabs['GKD'], pos = (640,70), size = (260,21), value = 'test')
    window.text_box('GKD4.3', parent = window.tabs['GKD'], pos = (940,70), size = (260,21), value = 'test')
    window.text_box('GKD5.3', parent = window.tabs['GKD'], pos = (1240,70), size = (260,21), value = 'test') 
    window.text_box('GKD6.3', parent = window.tabs['GKD'], pos = (1540,70), size = (260,21), value = 'test')
    
    window.check_box('GKD1.3_check', parent = window.tabs['GKD'], pos = (20,70))
    window.check_box('GKD2.3_check', parent = window.tabs['GKD'], pos = (320,70))
    window.check_box('GKD3.3_check', parent = window.tabs['GKD'], pos = (620,70))
    window.check_box('GKD4.3_check', parent = window.tabs['GKD'], pos = (920,70))
    window.check_box('GKD5.3_check', parent = window.tabs['GKD'], pos = (1220,70))
    window.check_box('GKD6.3_check', parent = window.tabs['GKD'], pos = (1520,70))
    
    window.text_box('GKD1.4', parent = window.tabs['GKD'], pos = (40,100), size = (260,21), value = 'test')
    window.text_box('GKD2.4', parent = window.tabs['GKD'], pos = (340,100), size = (260,21), value = 'test')
    window.text_box('GKD3.4', parent = window.tabs['GKD'], pos = (640,100), size = (260,21), value = 'test')
    window.text_box('GKD4.4', parent = window.tabs['GKD'], pos = (940,100), size = (260,21), value = 'test')
    window.text_box('GKD5.4', parent = window.tabs['GKD'], pos = (1240,100), size = (260,21), value = 'test') 
    window.text_box('GKD6.4', parent = window.tabs['GKD'], pos = (1540,100), size = (260,21), value = 'test')
    
    window.check_box('GKD1.4_check', parent = window.tabs['GKD'], pos = (20,100))
    window.check_box('GKD2.4_check', parent = window.tabs['GKD'], pos = (320,100))
    window.check_box('GKD3.4_check', parent = window.tabs['GKD'], pos = (620,100))
    window.check_box('GKD4.4_check', parent = window.tabs['GKD'], pos = (920,100))
    window.check_box('GKD5.4_check', parent = window.tabs['GKD'], pos = (1220,100))
    window.check_box('GKD6.4_check', parent = window.tabs['GKD'], pos = (1520,100))
    
    #Alle tekst en knoppen voor het vijfde tabblat
    window.button('Verzekering', parent = window.tabs['Brieven Maken'], label = 'Verzekering', pos = (50,10), size = (270,21))
    window.button('Begin', parent = window.tabs['Brieven Maken'], label = 'Begin', pos = (330,10), size = (100,21))
    window.button('Eind', parent = window.tabs['Brieven Maken'], label = 'Eind', pos = (440,10), size = (100,21))
    window.button('Wacht', parent = window.tabs['Brieven Maken'], label = 'Wacht', pos = (550,10), size = (100,21))
    window.button('ZFK/GKD', parent = window.tabs['Brieven Maken'], label = 'ZFK/GKD', pos = (660,10), size = (70,21))
    window.button('Dossier Nr.', parent = window.tabs['Brieven Maken'], label = 'Dossier Nr.', pos = (740,10), size = (100,21))
    window.button('Kies een verzekering en maak brief', parent = window.tabs['Brieven Maken'], label = 'Kies een verzekering en maak brief', pos = (870,70))
    
    window.text_box('Verzekering1_bm', parent = window.tabs['Brieven Maken'], pos = (50,40), size = (270,21), value = Verzekering1_naam)
    window.text_box('Begin1_bm', parent = window.tabs['Brieven Maken'], pos = (330,40), size = (100,21), value = Verzekering1_begin)
    window.text_box('Eind1_bm', parent = window.tabs['Brieven Maken'], pos = (440,40), size = (100,21), value = Verzekering1_eind)
    window.text_box('Wacht1_bm', parent = window.tabs['Brieven Maken'], pos = (550,40), size = (100,21), value = Verzekering1_wacht)
    window.text_box('zfk1_bm', parent = window.tabs['Brieven Maken'], pos = (660,40), size = (70,21), value = Verzekering1_zfk)
    window.text_box('Dossier1_nr_bm', parent = window.tabs['Brieven Maken'], pos = (740,40), size = (100,21), value = Verzekering1_dos_nr)
    
    window.text_box('Verzekering2_bm', parent = window.tabs['Brieven Maken'], pos = (50,70), size = (270,21), value = Verzekering2_naam)
    window.text_box('Begin2_bm', parent = window.tabs['Brieven Maken'], pos = (330,70), size = (100,21), value = Verzekering2_begin)
    window.text_box('Eind2_bm', parent = window.tabs['Brieven Maken'], pos = (440,70), size = (100,21), value = Verzekering2_eind)
    window.text_box('Wacht2_bm', parent = window.tabs['Brieven Maken'], pos = (550,70), size = (100,21), value = Verzekering2_wacht)
    window.text_box('zfk2_bm', parent = window.tabs['Brieven Maken'], pos = (660,70), size = (70,21), value = Verzekering2_zfk)
    window.text_box('Dossier2_nr_bm', parent = window.tabs['Brieven Maken'], pos = (740,70), size = (100,21), value = Verzekering2_dos_nr)
    
    window.text_box('Verzekering3_bm', parent = window.tabs['Brieven Maken'], pos = (50,100), size = (270,21), value = Verzekering3_naam)
    window.text_box('Begin3_bm', parent = window.tabs['Brieven Maken'], pos = (330,100), size = (100,21), value = Verzekering3_begin)
    window.text_box('Eind3_bm', parent = window.tabs['Brieven Maken'], pos = (440,100), size = (100,21), value = Verzekering3_eind)
    window.text_box('Wacht3_bm', parent = window.tabs['Brieven Maken'], pos = (550,100), size = (100,21), value = Verzekering3_wacht)
    window.text_box('zfk3_bm', parent = window.tabs['Brieven Maken'], pos = (660,100), size = (70,21), value = Verzekering3_zfk)
    window.text_box('Dossier3_nr_bm', parent = window.tabs['Brieven Maken'], pos = (740,100), size = (100,21), value = Verzekering3_dos_nr)
    
    window.text_box('Verzekering4_bm', parent = window.tabs['Brieven Maken'], pos = (50,130), size = (270,21), value = Verzekering4_naam)
    window.text_box('Begin4_bm', parent = window.tabs['Brieven Maken'], pos = (330,130), size = (100,21), value = Verzekering4_begin)
    window.text_box('Eind4_bm', parent = window.tabs['Brieven Maken'], pos = (440,130), size = (100,21), value = Verzekering4_eind)
    window.text_box('Wacht4_bm', parent = window.tabs['Brieven Maken'], pos = (550,130), size = (100,21), value = Verzekering4_wacht)
    window.text_box('zfk4_bm', parent = window.tabs['Brieven Maken'], pos = (660,130), size = (70,21), value = Verzekering4_zfk)
    window.text_box('Dossier4_nr_bm', parent = window.tabs['Brieven Maken'], pos = (740,130), size = (100,21), value = Verzekering4_dos_nr)
    
    window.text_box('Verzekering5_bm', parent = window.tabs['Brieven Maken'], pos = (50,160), size = (270,21), value = Verzekering5_naam)
    window.text_box('Begin5_bm', parent = window.tabs['Brieven Maken'], pos = (330,160), size = (100,21), value = Verzekering5_begin)
    window.text_box('Eind5_bm', parent = window.tabs['Brieven Maken'], pos = (440,160), size = (100,21), value = Verzekering5_eind)
    window.text_box('Wacht5_bm', parent = window.tabs['Brieven Maken'], pos = (550,160), size = (100,21), value = Verzekering5_wacht)
    window.text_box('zfk5_bm', parent = window.tabs['Brieven Maken'], pos = (660,160), size = (70,21), value = Verzekering5_zfk)
    window.text_box('Dossier5_nr_bm', parent = window.tabs['Brieven Maken'], pos = (740,160), size = (100,21), value = Verzekering5_dos_nr)
    
    window.check_box('bm_check1.1', parent = window.tabs['Brieven Maken'], pos = (20,40))
    window.check_box('bm_check1.2', parent = window.tabs['Brieven Maken'], pos = (20,70))
    window.check_box('bm_check1.3', parent = window.tabs['Brieven Maken'], pos = (20,100))
    window.check_box('bm_check1.4', parent = window.tabs['Brieven Maken'], pos = (20,130))
    window.check_box('bm_check1.5', parent = window.tabs['Brieven Maken'], pos = (20,160))
    
    #Alle tekst en knoppen voor het zesde tabblat
    window.static_text(parent = window.tabs['Automatische Brieven'], label = 'Welke brieven moeten automatisch verzonden worden?', pos = (10,10))
    
    window.text_box('aut_brieven1.1', parent = window.tabs['Automatische Brieven'], pos = (50,35), size = (400,21), value = 'test')
    window.text_box('aut_brieven2.1', parent = window.tabs['Automatische Brieven'], pos = (500,35), size = (400,21), value = 'test')
    window.text_box('aut_brieven3.1', parent = window.tabs['Automatische Brieven'], pos = (950,35), size = (400,21), value = 'test')
    window.text_box('aut_brieven4.1', parent = window.tabs['Automatische Brieven'], pos = (1400,35), size = (400,21), value = 'test')
 
    window.text_box('aut_brieven1.2', parent = window.tabs['Automatische Brieven'], pos = (50,70), size = (400,21), value = 'test')
    window.text_box('aut_brieven2.2', parent = window.tabs['Automatische Brieven'], pos = (500,70), size = (400,21), value = 'test')
    window.text_box('aut_brieven3.2', parent = window.tabs['Automatische Brieven'], pos = (950,70), size = (400,21), value = 'test')
    window.text_box('aut_brieven4.2', parent = window.tabs['Automatische Brieven'], pos = (1400,70), size = (400,21), value = 'test')

    window.text_box('aut_brieven1.3', parent = window.tabs['Automatische Brieven'], pos = (50,105), size = (400,21), value = 'test')
    window.text_box('aut_brieven2.3', parent = window.tabs['Automatische Brieven'], pos = (500,105), size = (400,21), value = 'test')
    window.text_box('aut_brieven3.3', parent = window.tabs['Automatische Brieven'], pos = (950,105), size = (400,21), value = 'test')
    window.text_box('aut_brieven4.3', parent = window.tabs['Automatische Brieven'], pos = (1400,105), size = (400,21), value = 'test')

    window.text_box('aut_brieven1.4', parent = window.tabs['Automatische Brieven'], pos = (50,140), size = (400,21), value = 'test')
    window.text_box('aut_brieven2.4', parent = window.tabs['Automatische Brieven'], pos = (500,140), size = (400,21), value = 'test')
    window.text_box('aut_brieven3.4', parent = window.tabs['Automatische Brieven'], pos = (950,140), size = (400,21), value = 'test')
    window.text_box('aut_brieven4.4', parent = window.tabs['Automatische Brieven'], pos = (1400,140), size = (400,21), value = 'test')

    window.text_box('aut_brieven1.5', parent = window.tabs['Automatische Brieven'], pos = (50,175), size = (400,21), value = 'test')
    window.text_box('aut_brieven2.5', parent = window.tabs['Automatische Brieven'], pos = (500,175), size = (400,21), value = 'test')
    window.text_box('aut_brieven3.5', parent = window.tabs['Automatische Brieven'], pos = (950,175), size = (400,21), value = 'test')
    window.text_box('aut_brieven4.5', parent = window.tabs['Automatische Brieven'], pos = (1400,175), size = (400,21), value = 'test')

    window.text_box('aut_brieven1.6', parent = window.tabs['Automatische Brieven'], pos = (50,210), size = (400,21), value = 'test')
    window.text_box('aut_brieven2.6', parent = window.tabs['Automatische Brieven'], pos = (500,210), size = (400,21), value = 'test')
    window.text_box('aut_brieven3.6', parent = window.tabs['Automatische Brieven'], pos = (950,210), size = (400,21), value = 'test')
    window.text_box('aut_brieven4.6', parent = window.tabs['Automatische Brieven'], pos = (1400,210), size = (400,21), value = 'test')

    window.text_box('aut_brieven1.7', parent = window.tabs['Automatische Brieven'], pos = (50,245), size = (400,21), value = 'test')
    window.text_box('aut_brieven2.7', parent = window.tabs['Automatische Brieven'], pos = (500,245), size = (400,21), value = 'test')
    window.text_box('aut_brieven3.7', parent = window.tabs['Automatische Brieven'], pos = (950,245), size = (400,21), value = 'test')
    
    window.check_box('aut_brieven1.1_check', parent = window.tabs['Automatische Brieven'], pos = (30,35))
    window.check_box('aut_brieven2.1_check', parent = window.tabs['Automatische Brieven'], pos = (480,35))
    window.check_box('aut_brieven3.1_check', parent = window.tabs['Automatische Brieven'], pos = (930,35))
    window.check_box('aut_brieven4.1_check', parent = window.tabs['Automatische Brieven'], pos = (1380,35))
 
    window.check_box('aut_brieven1.2_check', parent = window.tabs['Automatische Brieven'], pos = (30,70))
    window.check_box('aut_brieven2.2_check', parent = window.tabs['Automatische Brieven'], pos = (480,70))
    window.check_box('aut_brieven3.2_check', parent = window.tabs['Automatische Brieven'], pos = (930,70))
    window.check_box('aut_brieven4.2_check', parent = window.tabs['Automatische Brieven'], pos = (1380,70))

    window.check_box('aut_brieven1.3_check', parent = window.tabs['Automatische Brieven'], pos = (30,105))
    window.check_box('aut_brieven2.3_check', parent = window.tabs['Automatische Brieven'], pos = (480,105))
    window.check_box('aut_brieven3.3_check', parent = window.tabs['Automatische Brieven'], pos = (930,105))
    window.check_box('aut_brieven4.3_check', parent = window.tabs['Automatische Brieven'], pos = (1380,105))

    window.check_box('aut_brieven1.4_check', parent = window.tabs['Automatische Brieven'], pos = (30,140))
    window.check_box('aut_brieven2.4_check', parent = window.tabs['Automatische Brieven'], pos = (480,140))
    window.check_box('aut_brieven3.4_check', parent = window.tabs['Automatische Brieven'], pos = (930,140))
    window.check_box('aut_brieven4.4_check', parent = window.tabs['Automatische Brieven'], pos = (1380,140))

    window.check_box('aut_brieven1.5_check', parent = window.tabs['Automatische Brieven'], pos = (30,175))
    window.check_box('aut_brieven2.5_check', parent = window.tabs['Automatische Brieven'], pos = (480,175))
    window.check_box('aut_brieven3.5_check', parent = window.tabs['Automatische Brieven'], pos = (930,175))
    window.check_box('aut_brieven4.5_check', parent = window.tabs['Automatische Brieven'], pos = (1380,175))

    window.check_box('aut_brieven1.6_check', parent = window.tabs['Automatische Brieven'], pos = (30,210))
    window.check_box('aut_brieven2.6_check', parent = window.tabs['Automatische Brieven'], pos = (480,210))
    window.check_box('aut_brieven3.6_check', parent = window.tabs['Automatische Brieven'], pos = (930,210))
    window.check_box('aut_brieven4.6_check', parent = window.tabs['Automatische Brieven'], pos = (1380,210))

    window.check_box('aut_brieven1.7_check', parent = window.tabs['Automatische Brieven'], pos = (30,245))
    window.check_box('aut_brieven2.7_check', parent = window.tabs['Automatische Brieven'], pos = (480,245))
    window.check_box('aut_brieven3.7_check', parent = window.tabs['Automatische Brieven'], pos = (930,245))
    
    #Alle tekst en knoppen voor het zevende tabblat
    window.static_text(parent = window.tabs['MIFID ONTBREKENDE DOCUMENTEN'], label = 'Wat moet er nog worden binnengebracht voor => "MIFID ONTBREKENDE DOCUMENTEN"?', pos = (10,10))

    window.text_box('mfid_od1.1', parent = window.tabs['MIFID ONTBREKENDE DOCUMENTEN'], pos = (50,35), size = (600,21), value = 'test')
    window.text_box('mfid_od2.1', parent = window.tabs['MIFID ONTBREKENDE DOCUMENTEN'], pos = (750,35), size = (600,21), value = 'test')

    window.text_box('mfid_od1.2', parent = window.tabs['MIFID ONTBREKENDE DOCUMENTEN'], pos = (50,70), size = (600,21), value = 'test')
    window.text_box('mfid_od2.2', parent = window.tabs['MIFID ONTBREKENDE DOCUMENTEN'], pos = (750,70), size = (600,21), value = 'test')
  
    window.text_box('mfid_od1.3', parent = window.tabs['MIFID ONTBREKENDE DOCUMENTEN'], pos = (50,105), size = (600,21), value = 'test')
    window.text_box('mfid_od2.3', parent = window.tabs['MIFID ONTBREKENDE DOCUMENTEN'], pos = (750,105), size = (600,21), value = 'test')
   
    window.check_box('mfid_od1.1_check', parent = window.tabs['MIFID ONTBREKENDE DOCUMENTEN'], pos = (30,35))
    window.check_box('mfid_od1.1_check', parent = window.tabs['MIFID ONTBREKENDE DOCUMENTEN'], pos = (720,35))
    
    window.check_box('mfid_od1.2_check', parent = window.tabs['MIFID ONTBREKENDE DOCUMENTEN'], pos = (30,70))
    window.check_box('mfid_od2.2_check', parent = window.tabs['MIFID ONTBREKENDE DOCUMENTEN'], pos = (720,70))
    
    window.check_box('mfid_od1.3_check', parent = window.tabs['MIFID ONTBREKENDE DOCUMENTEN'], pos = (30,105))
    window.check_box('mfid_od2.3_check', parent = window.tabs['MIFID ONTBREKENDE DOCUMENTEN'], pos = (720,105))
    
    #Alle tekst en knoppen voor het achtste tabblat
    window.static_text(parent = window.tabs['MIFID ONTBREKENDE DOCUMENTEN OMSCHAKELING'], label = 'Wat moet er nog worden binnengebracht voor => "MIFID ONTBREKENDE DOCUMENTEN OMSCHAKELING"?', pos = (10,10))

    
    window.text_box('mfid_od_o1.1', parent = window.tabs['MIFID ONTBREKENDE DOCUMENTEN OMSCHAKELING'], pos = (50,35), size = (600,21), value = 'test')
    window.text_box('mfid_od_o2.1', parent = window.tabs['MIFID ONTBREKENDE DOCUMENTEN OMSCHAKELING'], pos = (750,35), size = (600,21), value = 'test')

    window.text_box('mfid_od_o1.2', parent = window.tabs['MIFID ONTBREKENDE DOCUMENTEN OMSCHAKELING'], pos = (50,70), size = (600,21), value = 'test')
    window.text_box('mfid_od_o2.2', parent = window.tabs['MIFID ONTBREKENDE DOCUMENTEN OMSCHAKELING'], pos = (750,70), size = (600,21), value = 'test')
  
    window.text_box('mfid_od_o1.3', parent = window.tabs['MIFID ONTBREKENDE DOCUMENTEN OMSCHAKELING'], pos = (50,105), size = (600,21), value = 'test')
    window.text_box('mfid_od_o2.3', parent = window.tabs['MIFID ONTBREKENDE DOCUMENTEN OMSCHAKELING'], pos = (750,105), size = (600,21), value = 'test')
   
    window.check_box('mfid_od_o1.1_check', parent = window.tabs['MIFID ONTBREKENDE DOCUMENTEN OMSCHAKELING'], pos = (30,35))
    window.check_box('mfid_od_o1.1_check', parent = window.tabs['MIFID ONTBREKENDE DOCUMENTEN OMSCHAKELING'], pos = (720,35))
    
    window.check_box('mfid_od_o1.2_check', parent = window.tabs['MIFID ONTBREKENDE DOCUMENTEN OMSCHAKELING'], pos = (30,70))
    window.check_box('mfid_od_o2.2_check', parent = window.tabs['MIFID ONTBREKENDE DOCUMENTEN OMSCHAKELING'], pos = (720,70))
    
    window.check_box('mfid_od_o1.3_check', parent = window.tabs['MIFID ONTBREKENDE DOCUMENTEN OMSCHAKELING'], pos = (30,105))
    window.check_box('mfid_od_o2.3_check', parent = window.tabs['MIFID ONTBREKENDE DOCUMENTEN OMSCHAKELING'], pos = (720,105))
    
    #Alle tekst en knoppen voor het negende tabblat
    window.static_text(parent = window.tabs['MIFID AANSLUITING NOG NIET MOGELIJK'], label = 'Wat moet er nog worden binnengebracht voor => "MIFID AANSLUITING NOG NIET MOGELIJK"?', pos = (10,10))

    window.text_box('mfid_anm1.1', parent = window.tabs['MIFID AANSLUITING NOG NIET MOGELIJK'], pos = (50,35), size = (600,21), value = 'test')
    window.text_box('mfid_anm2.1', parent = window.tabs['MIFID AANSLUITING NOG NIET MOGELIJK'], pos = (750,35), size = (600,21), value = 'test')

    window.text_box('mfid_anm1.2', parent = window.tabs['MIFID AANSLUITING NOG NIET MOGELIJK'], pos = (50,70), size = (600,21), value = 'test')
    window.text_box('mfid_anm2.2', parent = window.tabs['MIFID AANSLUITING NOG NIET MOGELIJK'], pos = (750,70), size = (600,21), value = 'test')
  
    window.check_box('mfid_anm1.1_check', parent = window.tabs['MIFID AANSLUITING NOG NIET MOGELIJK'], pos = (30,35))
    window.check_box('mfid_anm2.1_check', parent = window.tabs['MIFID AANSLUITING NOG NIET MOGELIJK'], pos = (720,35))
    
    window.check_box('mfid_anm1.2_check', parent = window.tabs['MIFID AANSLUITING NOG NIET MOGELIJK'], pos = (30,70))
    window.check_box('mfid_anm2.2_check', parent = window.tabs['MIFID AANSLUITING NOG NIET MOGELIJK'], pos = (720,70))
  
    #Alle knoppen die een functie moeten hebben instellen
    window.buttons['Rijksreg. Nr.:'].Bind(wx.EVT_BUTTON, window2) #maakt een nieuw menu met de nieuwe waarden
    window.buttons['Rijksreg. Nr.:'].Bind(wx.EVT_BUTTON, window.on_close) #sluit het menu
    window.buttons['Rijksreg. Nr.:'].Bind(wx.EVT_BUTTON, get_customer) #voert de class Customer uit voor het getypte nat_nr
    window.buttons['Rijksreg. Nr.:'].Bind(wx.EVT_BUTTON, window.get_text) #haalt de tekst op die in de tekstvakken wordt getypt
    
    window.buttons['Agresso Nummer:'].Bind(wx.EVT_BUTTON, window2) #maakt een nieuw menu met de nieuwe waarden
    window.buttons['Agresso Nummer:'].Bind(wx.EVT_BUTTON, window.on_close) #sluit het menu
    window.buttons['Agresso Nummer:'].Bind(wx.EVT_BUTTON, get_customer_agresso) #voert de class Customer uit voor het getypte nat_nr
    window.buttons['Agresso Nummer:'].Bind(wx.EVT_BUTTON, window.get_text) #haalt de tekst op die in de tekstvakken wordt getypt
    
    #knoppen in de toolbar binden
    toolbar.Bind(wx.EVT_TOOL, window.on_exit, window.toolbar_buttons['4'])
    # toolbar.Bind(wx.EVT_TOOL, window.save, window.toolbar_buttons['0'])
    # toolbar.Bind(wx.EVT_TOOL, window.print, window.toolbar_buttons['1'])
    # toolbar.Bind(wx.EVT_TOOL, window.exists, window.toolbar_buttons['2'])
    # toolbar.Bind(wx.EVT_TOOL, window.reset, window.toolbar_buttons['3'])
    
    window2.w = window
    
    
    window.Show()
    app.MainLoop()

window1()
