#!/usr/bin/perl -w
use strict;


package Assurcard_Ziekenfonds;
     use Wx qw[:everything];
     use base qw(Wx::Frame);
     #use Data::Dumper
     use strict;
     use Wx::Locale gettext => '_T';
     sub new {
         my ($class, $frame) = @_;
         $frame->{AZ_sizer_1} = Wx::FlexGridSizer->new(4, 13, 10, 10);
         $frame->{AZ_Button_AssurcardNummer}  = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_AZ}, -1, _T("Assurcard Nummer"),wxDefaultPosition,wxSIZE(100,20));
         $frame->{AZ_Txt_AssurcardNummer}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_AZ}, -1,$main::klant->{AssurcardNummer},wxDefaultPosition,wxSIZE(150,20));
         $frame->{AZ_Button_Status_Kaart}  = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_AZ}, -1, _T("Status Kaart"), wxDefaultPosition,wxSIZE(100,20));
         $frame->{AZ_Txt_Status_Kaart}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_AZ}, -1,$main::klant->{Assurcard_OK}, wxDefaultPosition,wxSIZE(150,20));
         $frame->{AZ_Button_Kaart_creatie_dat}  = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_AZ}, -1, _T("Creatie Kaart"),wxDefaultPosition,wxSIZE(100,20));
         $frame->{AZ_Txt_Kaart_creatie_dat}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_AZ}, -1,$main::klant->{Assurcard_Creatie_datum},wxDefaultPosition,wxSIZE(150,20));
         $frame->{AZ_Button_Assurcard_eindat_contract}  = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_AZ}, -1, _T("EindDat.Con"),wxDefaultPosition,wxSIZE(100,20));
         $frame->{AZ_Txt_Assurcard_Einddatum_contract}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_AZ}, -1,$main::klant->{Assurcard_Einddatum},wxDefaultPosition,wxSIZE(150,20));
         $frame->{AZ_Button_ZKF}  = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_AZ}, -1, _T("Ziekenfonds"),wxDefaultPosition,wxSIZE(100,20));
         $frame->{AZ_Txt_ZKF}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_AZ}, -1,$main::klant->{Ziekenfonds},wxDefaultPosition,wxSIZE(150,20));
         $frame->{AZ_Button_Extern_nummer}  = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_AZ}, -1, _T("Extern Nr."),wxDefaultPosition,wxSIZE(100,20));
         $frame->{AZ_Txt_Extern_nummer}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_AZ}, -1,$main::klant->{ExternNummer},wxDefaultPosition,wxSIZE(150,20));
         #$main::klant->{adres}->[0]->{Straat}=$response->{_content}[2][0][2][0][4]->{GetCustomerResult}->{CustomerType}->{AddressList}->{AddressUnitType}->{Address};
         #  $main::klant->{adres}->[0]->{Stad}=$response->{_content}[2][0][2][0][4]->{GetCustomerResult}->{CustomerType}->{AddressList}->{AddressUnitType}->{Place};
         #  $main::klant->{adres}->[0]->{Postcode}=$response->{_content}[2][0][2][0][4]->{GetCustomerResult}->{CustomerType}->{AddressList}->{AddressUnitType}->{ZipCode};
         #  $main::klant->{adres}->[0]->{Telefoon_nr}=$response->{_content}[2][0][2][0][4]->{GetCustomerResult}->{CustomerType}->{AddressList}->{AddressUnitType}->{Telephone1};
         #  $main::klant->{adres}->[0]->{e_mail}=$response->{_content}[2][0][2][0][4]->{GetCustomerResult}->{CustomerType}->{AddressList}->{AddressUnitType}->{eMail};
         #  $main::klant->{adres}->[0]->{type}='Domi';
         $frame->{AZ_Button_0_Adres} =  Wx::Button->new($frame->{MainFrameNotebookBoven_pane_AZ}, -1, _T("Adres"),wxDefaultPosition,wxSIZE(70,20));
         $frame->{AZ_Txt_0_Straat}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_AZ}, -1,$main::klant->{adres}->[0]->{Straat},wxDefaultPosition,wxSIZE(300,20));
         $frame->{AZ_Txt_0_Postcode}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_AZ}, -1,$main::klant->{adres}->[0]->{Postcode},wxDefaultPosition,wxSIZE(70,20));
         $frame->{AZ_Txt_0_Stad}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_AZ}, -1,$main::klant->{adres}->[0]->{Stad},wxDefaultPosition,wxSIZE(200,20));
         $frame->{AZ_Txt_0_type}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_AZ}, -1,$main::klant->{adres}->[0]->{type},wxDefaultPosition,wxSIZE(50,20));
         
         $frame->{AZ_Button_0_Email} =  Wx::Button->new($frame->{MainFrameNotebookBoven_pane_AZ}, -1, _T("E-Mail"),wxDefaultPosition,wxSIZE(70,20));        
         $frame->{AZ_Txt_0_Email}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_AZ}, -1,$main::klant->{adres}->[0]->{e_mail},wxDefaultPosition,wxSIZE(300,20));
         $frame->{AZ_Button_0_Telefoon} =  Wx::Button->new($frame->{MainFrameNotebookBoven_pane_AZ}, -1, _T("Telefoon"),wxDefaultPosition,wxSIZE(70,20));
         $frame->{AZ_Txt_0_Telefoon}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_AZ}, -1,$main::klant->{adres}->[0]->{Telefoon_nr},wxDefaultPosition,wxSIZE(200,20));
         
         $frame->{AZ_Button_1_Adres} =  Wx::Button->new($frame->{MainFrameNotebookBoven_pane_AZ}, -1, _T("Adres"),wxDefaultPosition,wxSIZE(70,20));
         $frame->{AZ_Txt_1_Straat}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_AZ}, -1,$main::klant->{adres}->[1]->{Straat},wxDefaultPosition,wxSIZE(300,20));
         $frame->{AZ_Txt_1_Postcode}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_AZ}, -1,$main::klant->{adres}->[1]->{Postcode},wxDefaultPosition,wxSIZE(70,20));
         $frame->{AZ_Txt_1_Stad}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_AZ}, -1,$main::klant->{adres}->[1]->{Stad},wxDefaultPosition,wxSIZE(200,20));
         $frame->{AZ_Txt_1_type}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_AZ}, -1,$main::klant->{adres}->[1]->{type},wxDefaultPosition,wxSIZE(50,20));
         
         $frame->{AZ_Button_1_Email} =  Wx::Button->new($frame->{MainFrameNotebookBoven_pane_AZ}, -1, _T("E-Mail"),wxDefaultPosition,wxSIZE(70,20));
         $frame->{AZ_Txt_1_Email}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_AZ}, -1,$main::klant->{adres}->[1]->{e_mail},wxDefaultPosition,wxSIZE(300,20));
         $frame->{AZ_Button_1_Telefoon} =  Wx::Button->new($frame->{MainFrameNotebookBoven_pane_AZ}, -1, _T("Telefoon"),wxDefaultPosition,wxSIZE(70,20));
         $frame->{AZ_Txt_1_Telefoon}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_AZ}, -1,$main::klant->{adres}->[1]->{Telefoon_nr},wxDefaultPosition,wxSIZE(200,20));
         $frame->{AZ_Button_Taal}  = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_AZ}, -1, _T("Taal"),wxDefaultPosition,wxSIZE(100,20));
         $frame->{AZ_Txt_Taal}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_AZ}, -1,($main::klant->{Taal}),wxDefaultPosition,wxSIZE(100,20));
          #AZ  MainFrameNotebookBoven_pane_AZ
         #Rij1
         #kolom 1 +2
         $frame->{AZ_panel_1} = Wx::Panel->new($frame->{MainFrameNotebookBoven_pane_AZ},-1,wxDefaultPosition,wxSIZE(20,20));
         $frame->{AZ_sizer_1}->Add($frame->{AZ_Button_AssurcardNummer}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{AZ_sizer_1}->Add($frame->{AZ_Txt_AssurcardNummer}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         #kolom 3 + 4 + 5 3=spacer
         $frame->{AZ_sizer_1}->Add($frame->{AZ_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{AZ_sizer_1}->Add($frame->{AZ_Button_Status_Kaart}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{AZ_sizer_1}->Add($frame->{AZ_Txt_Status_Kaart}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         #kolom 6+7+8+9+10+11
         $frame->{AZ_sizer_1}->Add($frame->{AZ_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{AZ_sizer_1}->Add( $frame->{AZ_Button_0_Adres}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);       
         $frame->{AZ_sizer_1}->Add($frame->{AZ_Txt_0_Straat}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{AZ_sizer_1}->Add($frame->{AZ_Txt_0_Postcode}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{AZ_sizer_1}->Add($frame->{AZ_Txt_0_Stad}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{AZ_sizer_1}->Add($frame->{AZ_Txt_0_type}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         #kolom 12 +13
         $frame->{AZ_sizer_1}->Add($frame->{AZ_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{AZ_sizer_1}->Add($frame->{AZ_Button_Taal}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         #Rij2
         #kolom 1 +2         
         $frame->{AZ_sizer_1}->Add($frame->{AZ_Button_Kaart_creatie_dat}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{AZ_sizer_1}->Add($frame->{AZ_Txt_Kaart_creatie_dat}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         #kolom 3 + 4 + 5 3=spacer
         $frame->{AZ_sizer_1}->Add($frame->{AZ_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{AZ_sizer_1}->Add($frame->{AZ_Button_ZKF}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{AZ_sizer_1}->Add($frame->{AZ_Txt_ZKF}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         #kolom 6+7+8+9+10+11
         $frame->{AZ_sizer_1}->Add($frame->{AZ_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{AZ_sizer_1}->Add($frame->{AZ_Button_0_Email}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{AZ_sizer_1}->Add($frame->{AZ_Txt_0_Email}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{AZ_sizer_1}->Add($frame->{AZ_Button_0_Telefoon}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{AZ_sizer_1}->Add( $frame->{AZ_Txt_0_Telefoon}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{AZ_sizer_1}->Add($frame->{AZ_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         #kolom 12 +13
         $frame->{AZ_sizer_1}->Add($frame->{AZ_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{AZ_sizer_1}->Add($frame->{AZ_Txt_Taal}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         #Rij 3
         #kolom 1 +2    
         $frame->{AZ_sizer_1}->Add($frame->{AZ_Button_Assurcard_eindat_contract}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{AZ_sizer_1}->Add($frame->{AZ_Txt_Assurcard_Einddatum_contract}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         #kolom 3 + 4 + 5 3=spacer
         $frame->{AZ_sizer_1}->Add($frame->{AZ_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{AZ_sizer_1}->Add($frame->{AZ_Button_Extern_nummer}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{AZ_sizer_1}->Add($frame->{AZ_Txt_Extern_nummer}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
          #kolom 6+7+8+9+10+11
         $frame->{AZ_sizer_1}->Add($frame->{AZ_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{AZ_sizer_1}->Add( $frame->{AZ_Button_1_Adres}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);        
         $frame->{AZ_sizer_1}->Add($frame->{AZ_Txt_1_Straat}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{AZ_sizer_1}->Add($frame->{AZ_Txt_1_Postcode}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{AZ_sizer_1}->Add($frame->{AZ_Txt_1_Stad}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{AZ_sizer_1}->Add($frame->{AZ_Txt_1_type}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         #kolom 12 +13
         $frame->{AZ_sizer_1}->Add($frame->{AZ_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{AZ_sizer_1}->Add($frame->{AZ_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         #Rij4
         #kolom 1 +2 
         $frame->{AZ_sizer_1}->Add($frame->{AZ_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{AZ_sizer_1}->Add($frame->{AZ_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         #kolom 3 +4 +5
         $frame->{AZ_sizer_1}->Add($frame->{AZ_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{AZ_sizer_1}->Add($frame->{AZ_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{AZ_sizer_1}->Add($frame->{AZ_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         #kolom 6+7+8+9+10+11
         $frame->{AZ_sizer_1}->Add($frame->{AZ_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{AZ_sizer_1}->Add($frame->{AZ_Button_1_Email}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{AZ_sizer_1}->Add($frame->{AZ_Txt_1_Email}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{AZ_sizer_1}->Add($frame->{AZ_Button_1_Telefoon}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{AZ_sizer_1}->Add( $frame->{AZ_Txt_1_Telefoon}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{AZ_sizer_1}->Add($frame->{AZ_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         #kolom 12 +13
         $frame->{AZ_sizer_1}->Add($frame->{AZ_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{AZ_sizer_1}->Add($frame->{AZ_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
       
         return ($frame);
        }
1;