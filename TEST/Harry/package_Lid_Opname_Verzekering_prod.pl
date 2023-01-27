#!/usr/bin/perl -w
use strict;

package Lid_Opname_Verzekering;
     use Time::Piece (); 
     use Wx qw[:everything];
     use base qw(Wx::Frame);
     use Wx qw(wxEVT_SCROLL_TOP wxEVT_SCROLL_BOTTOM wxEVT_SCROLL_LINEUP
               wxEVT_SCROLL_LINEDOWN wxEVT_SCROLL_PAGEUP wxEVT_SCROLL_PAGEDOWN
               wxEVT_SCROLL_THUMBTRACK wxEVT_SCROLL_THUMBRELEASE );
     use Wx::Event qw( EVT_BUTTON EVT_TEXT_ENTER EVT_UPDATE_UI );
     
     use Wx::Perl::ListCtrl;
     #use Data::Dumper
     use strict;
     use Wx::Locale gettext => '_T';
     sub new {
         my $test = $main::klant;
         # "\naangeroepen Lid_Opname_Verzekering-new\n_____________________________________________________\n\n";
         my ($class, $frame) = @_;
         $frame->{lov_sizer_1} = Wx::FlexGridSizer->new(4, 19, 10, 10);
         $frame->{lov_Button_Agresso_Nummer}  = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_lov}, -1, _T("Agresso Nummer:"),wxDefaultPosition,wxSIZE(100,20));
         $frame->{lov_Txt_Agressso_nr}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_lov}, -1,("$main::klant->{Agresso_nummer}"),wxDefaultPosition,wxSIZE(300,20));
         $frame->{lov_Button_Naam}  = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_lov}, -1, _T("GKD/Naam:"), wxDefaultPosition,wxSIZE(100,20));
         $frame->{lov_Txt_Naam}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_lov}, -1,($main::klant->{naam}), wxDefaultPosition,wxSIZE(300,20));
         $frame->{lov_Button_GeboorteDatum}  = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_lov}, -1, _T("Geboortedatum:"),wxDefaultPosition,wxSIZE(100,20));
         $frame->{lov_Txt_GeboorteDatum}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_lov}, -1,$main::klant->{geboortedatum},wxDefaultPosition,wxSIZE(300,20));
         $frame->{lov_Button_RijksReg_nr}  = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_lov}, -1, _T("Rijksreg. Nr."),wxDefaultPosition,wxSIZE(100,20));
         $frame->{lov_Txt_RijksReg_nr}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_lov}, -1,($main::klant->{Rijksreg_Nr}),wxDefaultPosition,wxSIZE(300,20));
         $frame->{lov_Button_Begin_opname}  = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_lov}, -1, _T("Begin opname"),wxDefaultPosition,wxSIZE(100,20));
         $frame->{lov_Txt_0_Begin_Opname}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_lov}, -1,$main::begindatum_opname,wxDefaultPosition,wxSIZE(100,20));
         $frame->{lov_Button_Eind_opname}  = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_lov}, -1, _T("Eind opname"),wxDefaultPosition,wxSIZE(100,20));
         $frame->{lov_Txt_0_Eind_Opname}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_lov}, -1,$main::einddatum_opname,wxDefaultPosition,wxSIZE(100,20));
         #$frame->{lov_Button_Verzekering}  = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_lov}, -1, _T("Verzekering"),wxDefaultPosition,wxSIZE(200,20));
         #$frame->{lov_Button_Begin}  = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_lov}, -1, _T("Begin"),wxDefaultPosition,wxSIZE(80,20));
         #$frame->{lov_Button_Eind}  = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_lov}, -1, _T("Eind"),wxDefaultPosition,wxSIZE(80,20));
         $frame->{lov_Txt_0_contracten_naam}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_lov}, -1,$main::klant->{contracten}->[0]->{naam},wxDefaultPosition,wxSIZE(200,20));
         $frame->{lov_Txt_0_contracten_startdatum}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_lov}, -1,$main::klant->{contracten}->[0]->{startdatum},wxDefaultPosition,wxSIZE(80,20));
         $frame->{lov_Txt_0_contracten_einddatum}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_lov}, -1,$main::klant->{contracten}->[0]->{einddatum},wxDefaultPosition,wxSIZE(80,20));
         $frame->{lov_Txt_1_contracten_naam}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_lov}, -1,$main::klant->{contracten}->[1]->{naam},wxDefaultPosition,wxSIZE(200,20));
         $frame->{lov_Txt_1_contracten_startdatum}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_lov}, -1,$main::klant->{contracten}->[1]->{startdatum},wxDefaultPosition,wxSIZE(80,20));
         $frame->{lov_Txt_1_contracten_einddatum}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_lov}, -1,$main::klant->{contracten}->[1]->{einddatum},wxDefaultPosition,wxSIZE(80,20));
         $frame->{lov_Txt_2_contracten_naam}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_lov}, -1,$main::klant->{contracten}->[2]->{naam},wxDefaultPosition,wxSIZE(200,20));
         $frame->{lov_Txt_2_contracten_startdatum}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_lov}, -1,$main::klant->{contracten}->[2]->{startdatum},wxDefaultPosition,wxSIZE(80,20));
         $frame->{lov_Txt_2_contracten_einddatum}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_lov}, -1,$main::klant->{contracten}->[2]->{einddatum},wxDefaultPosition,wxSIZE(80,20));
         $frame->{lov_Txt_3_contracten_naam}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_lov}, -1,$main::klant->{contracten}->[3]->{naam},wxDefaultPosition,wxSIZE(200,20));
         $frame->{lov_Txt_3_contracten_startdatum}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_lov}, -1,$main::klant->{contracten}->[3]->{startdatum},wxDefaultPosition,wxSIZE(80,20));
         $frame->{lov_Txt_3_contracten_einddatum}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_lov}, -1,$main::klant->{contracten}->[3]->{einddatum},wxDefaultPosition,wxSIZE(80,20));
         $frame->{lov_button_Dienst}  = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_lov}, -1, _T("Dienst"),wxDefaultPosition,wxSIZE(100,20));
         $frame->{lov_choice_dienst}  = Wx::Choice->new($frame->{MainFrameNotebookBoven_pane_lov}, 26,wxDefaultPosition,wxSIZE(100,20),\@main::diensten);
         $frame->{lov_button_Hospi_TussenKomst}  = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_lov}, -1, _T("Tussenkomst Hospi"),wxDefaultPosition,wxSIZE(100,20));
         $frame->{lov_Txt_Hospi_Tussenkomst}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_lov}, -1, "$main::hospi_tussenkomst",wxDefaultPosition,wxSIZE(100,20));
         $frame->{lov_Button_Verschil}  = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_lov}, -1, _T("Verschil"),wxDefaultPosition,wxSIZE(100,20));
         $frame->{lov_Txt_Verschil}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_lov}, -1, _T("$main::verschil"),wxDefaultPosition,wxSIZE(100,20));
         $frame->{lov_Button_Dagen_Betaald}  = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_lov}, -1, _T("Dagen F"),wxDefaultPosition,wxSIZE(100,20));
         $frame->{lov_Txt_Dagen_Betaald}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_lov}, -1, _T("$main::aantal_dagen_betaald"),wxDefaultPosition,wxSIZE(100,20));
         #$frame->{lov_Button_Dagen_Betaald}  = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_lov}, -1, _T("Dagen F"),wxDefaultPosition,wxSIZE(100,20));
         #$frame->{lov_Txt_Dagen_Betaald}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_lov}, -1, _T("$main::aantal_dagen_betaald"),wxDefaultPosition,wxSIZE(100,20));
         $frame->{lov_Button_Ptsk_suppl}  = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_lov}, -1, _T("P.tsk+Supl"),wxDefaultPosition,wxSIZE(100,20));
         $frame->{lov_Txt_Ptsk_suppl}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_lov}, -1, _T("$main::psk_plus_suppl"),wxDefaultPosition,wxSIZE(100,20));
         $frame->{lov_Button_Aantal_kaarten}  = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_lov}, -1, _T("K"),wxDefaultPosition,wxSIZE(15,20));
         $frame->{lov_Txt_0_Aantal_kaarten}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_lov}, -1,$main::klant->{aantal_kaarten},wxDefaultPosition,wxSIZE(15,20));
         $frame->{lov_Button_Kaart_Verloren}  = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_lov}, -1, _T("Kaart Verloren"),wxDefaultPosition,wxSIZE(100,20));
         $frame->{lov_Txt_datum_laaste_aanvraag_kaart}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_lov}, -1,$main::klant->{Assurcard_Creatie_datum},wxDefaultPosition,wxSIZE(100,20));              
         $frame->{lov_Txt_0_contracten_wachtdatum}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_lov}, -1,$main::klant->{contracten}->[0]->{wachtdatum},wxDefaultPosition,wxSIZE(80,20));
         $frame->{lov_Txt_1_contracten_wachtdatum}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_lov}, -1,$main::klant->{contracten}->[1]->{wachtdatum},wxDefaultPosition,wxSIZE(80,20));
         $frame->{lov_Txt_2_contracten_wachtdatum}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_lov}, -1,$main::klant->{contracten}->[2]->{wachtdatum},wxDefaultPosition,wxSIZE(80,20));
         $frame->{lov_Txt_3_contracten_wachtdatum}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_lov}, -1,$main::klant->{contracten}->[3]->{wachtdatum},wxDefaultPosition,wxSIZE(80,20));
         $frame->{lov_Txt_0_contracten_zkfnr}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_lov}, -1,$main::klant->{contracten}->[0]->{zkf_nr},wxDefaultPosition,wxSIZE(50,20));
         $frame->{lov_Txt_1_contracten_zkfnr}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_lov}, -1,$main::klant->{contracten}->[1]->{zkf_nr},wxDefaultPosition,wxSIZE(50,20));
         $frame->{lov_Txt_2_contracten_zkfnr}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_lov}, -1,$main::klant->{contracten}->[2]->{zkf_nr},wxDefaultPosition,wxSIZE(50,20));
         $frame->{lov_Txt_3_contracten_zkfnr}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_lov}, -1,$main::klant->{contracten}->[3]->{zkf_nr},wxDefaultPosition,wxSIZE(50,20));
         $frame->{lov_Button_Wacht}  = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_lov}, -1, _T("Wacht"),wxDefaultPosition,wxSIZE(80,20));
         $frame->{lov_Button_ZKF}  = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_lov}, -1, _T("ZKF/GKD"),wxDefaultPosition,wxSIZE(50,20));
         $frame->{lov_Button_Factuur}  = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_lov}, -1, _T("Factuur/Wissen"),wxDefaultPosition,wxSIZE(120,20));
         $frame->{lov_Button_Factuur1}  = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_lov}, -1, _T("Facturen"),wxDefaultPosition,wxSIZE(120,20));
         $frame->{lov_Txt_0_Factuur}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_lov}, -1,$main::invoices[0],wxDefaultPosition,wxSIZE(120,20));
         $frame->{lov_chk_0_Factuur}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_lov}, -1,$main::invoices_check[0],wxDefaultPosition,wxSIZE(15,20));
         $frame->{lov_Txt_1_Factuur}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_lov}, -1,$main::invoices[1],wxDefaultPosition,wxSIZE(120,20));
         $frame->{lov_chk_1_Factuur}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_lov}, -1,$main::invoices_check[1],wxDefaultPosition,wxSIZE(15,20));
         $frame->{lov_Txt_2_Factuur}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_lov}, -1,$main::invoices[2],wxDefaultPosition,wxSIZE(120,20));
         $frame->{lov_chk_2_Factuur}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_lov}, -1,$main::invoices_check[2],wxDefaultPosition,wxSIZE(15,20));
         $frame->{lov_Txt_3_Factuur}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_lov}, -1,$main::invoices[3],wxDefaultPosition,wxSIZE(120,20));
         $frame->{lov_chk_3_Factuur}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_lov}, -1,$main::invoices_check[3],wxDefaultPosition,wxSIZE(15,20));
         $frame->{lov_Txt_4_Factuur}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_lov}, -1,$main::invoices[4],wxDefaultPosition,wxSIZE(120,20));
         $frame->{lov_chk_4_Factuur}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_lov}, -1,$main::invoices_check[4],wxDefaultPosition,wxSIZE(15,20));
         $frame->{lov_Txt_5_Factuur}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_lov}, -1,$main::invoices[5],wxDefaultPosition,wxSIZE(120,20));
         $frame->{lov_chk_5_Factuur}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_lov}, -1,$main::invoices_check[5],wxDefaultPosition,wxSIZE(15,20));
         $frame->{lov_chk_0_Contract}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_lov}, -1,$main::contracts_check[0],wxDefaultPosition,wxSIZE(15,20));
         $frame->{lov_chk_1_Contract}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_lov}, -1,$main::contracts_check[1],wxDefaultPosition,wxSIZE(15,20));
         $frame->{lov_chk_2_Contract}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_lov}, -1,$main::contracts_check[2],wxDefaultPosition,wxSIZE(15,20));
         $frame->{lov_chk_3_Contract}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_lov}, -1,$main::contracts_check[2],wxDefaultPosition,wxSIZE(15,20));
         $frame->{lov_chk_lostcard}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_lov}, -1,$main::klant->{Verloren_kaart},wxDefaultPosition,wxSIZE(15,20));
         $main::hospi_tussenkomsttxtctrl=$frame->{lov_Txt_Hospi_Tussenkomst};
         $main::verschil_txtctrl=$frame->{lov_Txt_Verschil};
	 $main::verschil_dagen_betaald_txtctrl =$frame->{lov_Txt_Dagen_Betaald};
         #Rij1
         #kolom 1 +2
         $frame->{lov_panel_1} = Wx::Panel->new($frame->{MainFrameNotebookBoven_pane_lov},-1,wxDefaultPosition,wxSIZE(20,20));
         $frame->{lov_sizer_1}->Add($frame->{lov_Button_Agresso_Nummer}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_Txt_Agressso_nr}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         #kolom 3+4+5+7+8
         $frame->{lov_sizer_1}->Add($frame->{lov_chk_0_Contract}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_Txt_0_contracten_naam}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_Txt_0_contracten_startdatum}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_Txt_0_contracten_einddatum}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_Txt_0_contracten_wachtdatum}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_Txt_0_contracten_zkfnr}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         #kolom 9+10
         $frame->{lov_sizer_1}->Add($frame->{lov_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_button_Dienst}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         #kolom 11+12
         $frame->{lov_sizer_1}->Add($frame->{lov_chk_lostcard}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_Button_Kaart_Verloren}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         #kolom 13 14 15
         $frame->{lov_sizer_1}->Add($frame->{lov_Button_Aantal_kaarten}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);         
         $frame->{lov_sizer_1}->Add($frame->{lov_Button_Begin_opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_Button_Eind_opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         #kolom 16+17+18+19
         $frame->{lov_sizer_1}->Add($frame->{lov_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);         
         $frame->{lov_sizer_1}->Add($frame->{lov_Button_Factuur}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);         
         $frame->{lov_sizer_1}->Add($frame->{lov_Button_Factuur1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         
         #Rij2
         #kolom 1 +2         
         $frame->{lov_sizer_1}->Add($frame->{lov_Button_Naam}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_Txt_Naam}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);         
         #kolom 3+4+5+6+7+8
         $frame->{lov_sizer_1}->Add($frame->{lov_chk_1_Contract}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_Txt_1_contracten_naam}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_Txt_1_contracten_startdatum}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_Txt_1_contracten_einddatum}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_Txt_1_contracten_wachtdatum}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_Txt_1_contracten_zkfnr}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         #kolom 9+10
         $frame->{lov_sizer_1}->Add($frame->{lov_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_choice_dienst}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         #kolom 11+12
         $frame->{lov_sizer_1}->Add($frame->{lov_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_Txt_datum_laaste_aanvraag_kaart}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         #kolom 13+14+15
         $frame->{lov_sizer_1}->Add($frame->{lov_Txt_0_Aantal_kaarten}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_Txt_0_Begin_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_Txt_0_Eind_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         #kolom 16+17+18+19
         $frame->{lov_sizer_1}->Add($frame->{lov_chk_0_Factuur}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_Txt_0_Factuur}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_chk_3_Factuur}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_Txt_3_Factuur}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         
         #Rij 3
         #kolom 1 +2    
         $frame->{lov_sizer_1}->Add($frame->{lov_Button_RijksReg_nr}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_Txt_RijksReg_nr}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);         
         #kolom 3+4+5+6+7+8
         $frame->{lov_sizer_1}->Add($frame->{lov_chk_2_Contract}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_Txt_2_contracten_naam}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_Txt_2_contracten_startdatum}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_Txt_2_contracten_einddatum}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_Txt_2_contracten_wachtdatum}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_Txt_2_contracten_zkfnr}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         #kolom 9+10
         $frame->{lov_sizer_1}->Add($frame->{lov_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_button_Hospi_TussenKomst}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         #kolom 11+12
         $frame->{lov_sizer_1}->Add($frame->{lov_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_Button_Verschil}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         #kolom 13+14+15
         $frame->{lov_sizer_1}->Add($frame->{lov_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_Button_Dagen_Betaald}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         #$frame->{lov_sizer_1}->Add($frame->{lov_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
	 $frame->{lov_sizer_1}->Add($frame->{lov_Button_Ptsk_suppl}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         
         #kolom 16+17+18+19
         $frame->{lov_sizer_1}->Add($frame->{lov_chk_1_Factuur}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_Txt_1_Factuur}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_chk_4_Factuur}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_Txt_4_Factuur}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         
         
         #Rij4
         #kolom 1 +2 
         $frame->{lov_sizer_1}->Add( $frame->{lov_Button_GeboorteDatum}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_Txt_GeboorteDatum} , 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         #kolom 3+4+5+6+7+8
         $frame->{lov_sizer_1}->Add($frame->{lov_chk_3_Contract}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_Txt_3_contracten_naam}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_Txt_3_contracten_startdatum}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_Txt_3_contracten_einddatum}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_Txt_3_contracten_wachtdatum}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_Txt_3_contracten_zkfnr}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{MainFrameNotebookBoven_pane_lov}->SetSizer($frame->{lov_sizer_1});
          #kolom 9+10
         $frame->{lov_sizer_1}->Add($frame->{lov_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_Txt_Hospi_Tussenkomst}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
          #kolom 11+12
         $frame->{lov_sizer_1}->Add($frame->{lov_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_Txt_Verschil}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
          #kolom 13+14+15
         $frame->{lov_sizer_1}->Add($frame->{lov_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_Txt_Dagen_Betaald}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         #$frame->{lov_sizer_1}->Add($frame->{lov_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_Txt_Ptsk_suppl}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         #kolom 16+17+18+19
         $frame->{lov_sizer_1}->Add($frame->{lov_chk_2_Factuur}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_Txt_2_Factuur}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_chk_5_Factuur}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_Txt_5_Factuur}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         
         #events 
         Wx::Event::EVT_CHOICE($frame,$frame->{lov_choice_dienst},\&keuze);
         Wx::Event::EVT_BUTTON($frame,$frame->{lov_Button_Factuur},\&factuur_wegvegen);
         Wx::Event::EVT_BUTTON($frame,$frame->{lov_Button_Naam},\&gkd); 
         Wx::Event::EVT_BUTTON($frame,$frame->{lov_button_Dienst},\&uncheck_dienst);
         Wx::Event::EVT_BUTTON( $frame,$frame->{lov_Button_Agresso_Nummer},\&Agresso_Nummer);
         #Wx::Event::EVT_TEXT_ENTER($frame,$frame->{lov_Txt_Agressso_nr},\&Agresso_Nummer);
         #Wx::Event::EVT_TEXT($frame,$frame->{lov_Txt_Agressso_nr},\&Agresso_Nummer);
         Wx::Event::EVT_BUTTON( $frame,$frame->{lov_Button_RijksReg_nr},\&RijksRegister_Nummer);
         Wx::Event::EVT_CHECKBOX($frame,$frame->{lov_chk_0_Factuur}, \&checkbox_0_Factuur_clicked);
         Wx::Event::EVT_CHECKBOX($frame,$frame->{lov_chk_1_Factuur}, \&checkbox_1_Factuur_clicked);
         Wx::Event::EVT_CHECKBOX($frame,$frame->{lov_chk_2_Factuur}, \&checkbox_2_Factuur_clicked);
         Wx::Event::EVT_CHECKBOX($frame,$frame->{lov_chk_3_Factuur}, \&checkbox_3_Factuur_clicked);
         Wx::Event::EVT_CHECKBOX($frame,$frame->{lov_chk_4_Factuur}, \&checkbox_4_Factuur_clicked);
         Wx::Event::EVT_CHECKBOX($frame,$frame->{lov_chk_5_Factuur}, \&checkbox_5_Factuur_clicked);
         Wx::Event::EVT_CHECKBOX($frame,$frame->{lov_chk_0_Contract}, \&checkbox_0_Contract_clicked);
         Wx::Event::EVT_CHECKBOX($frame,$frame->{lov_chk_1_Contract}, \&checkbox_1_Contract_clicked);
         Wx::Event::EVT_CHECKBOX($frame,$frame->{lov_chk_2_Contract}, \&checkbox_2_Contract_clicked);
         Wx::Event::EVT_CHECKBOX($frame,$frame->{lov_chk_3_Contract}, \&checkbox_3_Contract_clicked);
         Wx::Event::EVT_BUTTON( $frame,$frame->{lov_Button_Begin_opname},\&opname_data);
         Wx::Event::EVT_BUTTON( $frame,$frame->{lov_Button_Eind_opname},\&opname_data);
         Wx::Event::EVT_BUTTON( $frame,$frame->{lov_Button_Verzekering},\&Verzekering);
         Wx::Event::EVT_BUTTON($frame,$frame->{lov_Button_Kaart_Verloren},\&Kaart_Verloren);
         return ($frame);
        }
sub factuur_wegvegen {
      my ($frame, $evt) = @_;
      my $factuur_nummer = '';
      if ($main::Verwerk_Assurcard_Facturen == 1) {
         my $is_er_een_factuur_aangevinkt = 0;
         for (my $i=0; $i < 6; $i++) {
             if ($main::invoices_check[$i] == 1 ) {
                 $is_er_een_factuur_aangevinkt =1;
                 $factuur_nummer =$main::invoices[$i];
                }
            }
         if ($is_er_een_factuur_aangevinkt == 0) {
             Wx::MessageBox( _T("Gelieve een Factuur aan te vinken"), 
             _T("Actie"), 
                 wxOK|wxCENTRE, 
                 $frame
                );
            }else {
              my( $answer ) = Wx::MessageBox( _T("Deze factuur:$factuur_nummer \nIn de toekomst niet meer verwerken ?"), 
             _T("Actie"), 
                 wxYES_NO|wxCENTRE, 
                 $frame
                );
             if( $answer == Wx::wxYES() ) {
                 my $dbh =  sql_toegang_agresso->setup_mssql_connectie;
                 sql_toegang_agresso->update_completed_to_one ($dbh,$factuur_nummer);
                 sql_toegang_agresso->disconnect_mssql($dbh);
                 print "yes\n";
                 print "";
                }else {
		 print "no\n";
                 print "";
	        }		  
            }
        }
}
sub gkd {
     my ($frame, $evt) = @_;
     my $externnummer =$frame->{AZ_Txt_Extern_nummer}->GetValue();
     my $zkf = $frame->{AZ_Txt_ZKF} ->GetValue();
     if ($zkf == 203) {
         system(1, 'start',"http://dgc.vnz.be/dgccaller.jsp?theexid=$externnummer");#code
     }else {
         system(1, 'start',"http://dgc.vnz235.be/dgccaller.jsp?theexid=$externnummer");#code
     }
     
}
sub uncheck_dienst {
     undef $main::dienst;
     $main::frame->{lov_choice_dienst}->SetSelection(wxNOT_FOUND);
}
sub Kaart_Verloren {
     my ($frame,$keuze) = @_;
     my $RijksRegister = $frame->{lov_Txt_RijksReg_nr}->GetValue();
     as400_gegevens->card_lost($RijksRegister);
     $main::klant->{Verloren_kaart} =1;
     $frame->{lov_chk_lostcard}->SetValue($main::klant->{Verloren_kaart});
     my $dbh = sql_toegang_agresso->setup_mssql_connectie;
     sql_toegang_agresso->add_card_lost($dbh,$main::klant->{Agresso_nummer});
     sql_toegang_agresso->disconnect_mssql($dbh);
     $main::klant->{aantal_kaarten} +=1;
     $frame->{lov_Txt_0_Aantal_kaarten}->SetValue($main::klant->{aantal_kaarten}); 
     my $historiek_gkd = $main::teksten_GKD->{GKD_teksten}->{AUTOMATISCHE_TEKSTEN}->{KAART_VERLOREN}->{tekst};
     my $staat_er_al_in = 'nee';
     $staat_er_al_in = as400_gegevens->lees_history_gkd_agresso_order($historiek_gkd) ;
     as400_gegevens->zet_history_gkd_in ($historiek_gkd)  if (defined $historiek_gkd and $historiek_gkd ne '' and $staat_er_al_in eq 'nee');
     sql_toegang_agresso->disconnect_mssql($dbh);
}
sub Verzekering_periode {
     my ($frame, $evt) = @_;
     my $naam_verzekering = '';
     my $begin_verzekering='';
     my $eind_verzekering = '';
     my $periode = '';
     my $test = $main::klant;
     #my $test1 = $main::contracts_check;
     for (my $i=0; $i < 4; $i++) {
         if ($main::contracts_check[$i] == 1) {
             $naam_verzekering = lc ($main::klant->{contracten}->[$i]->{naam});
             $begin_verzekering = $main::klant->{contracten}->[$i]->{wachtdatum};
             my ($begin_verzekering_dag,$begin_verzekering_maand,$begin_verzekering_jaar) = split /\//,$begin_verzekering; 
             $begin_verzekering = $begin_verzekering_jaar*10000+$begin_verzekering_maand*100+$begin_verzekering_dag;
             $eind_verzekering = $main::klant->{contracten}->[$i]->{einddatum};
             my ($eind_verzekering_dag,$eind_verzekering_maand,$eind_verzekering_jaar) =split /\//,$eind_verzekering;
             $eind_verzekering = $eind_verzekering_jaar*10000+$eind_verzekering_maand*100+$eind_verzekering_dag;
             $main::contract_gekozen=1;
            }
        }
     if ($main::Handmatig_Inbrengen == 1) {
         my $begindatum_opname = $main::begindatum_opname;
         if ($begindatum_opname eq '') {
             Wx::MessageBox( _T("Gelieve een Begindatum en Einddatum\n in te brengen"), 
                 _T("Periode"), 
                 wxOK|wxCENTRE, 
                $frame
                );#code
             for (my $i=0; $i < 4; $i++) {
                 $main::contracts_check[$i] = 0;
                 $main::contract_gekozen=0;
                }
             $frame->{lov_chk_0_Contract}->SetValue($main::contracts_check[0]);
             $frame->{lov_chk_1_Contract}->SetValue($main::contracts_check[1]);
             $frame->{lov_chk_2_Contract}->SetValue($main::contracts_check[2]);
             $frame->{lov_chk_3_Contract}->SetValue($main::contracts_check[3]);
            }else {
             if ($main::begindatum_opname < $begin_verzekering or $main::einddatum_opname >  $eind_verzekering) {
                 Wx::MessageBox( _T("Opnamedata vallen niet binnen de Verzekering\nBegin: $main::begindatum_opname < $begin_verzekering \n\t of\nEinde: $main::einddatum_opname >  $eind_verzekering\n"), 
                 _T("Waarschuwing"), 
                 wxOK|wxCENTRE, 
                $frame
                );#code
             }    
             my $jaar = substr($begindatum_opname,0,4);
             $periode = "periode_$jaar"."0101-$jaar"."1231";
             MainFrameNotebookOnder->delete_all_pages;
             my $setup = Inhoud_Overzicht_grid->make_overzicht_matrix($periode,$naam_verzekering);
             eval {my $agresso_nr = $frame->{lov_Txt_Agressso_nr} ->GetValue()};
             if (!$@) {
                 my $agresso_nr = $frame->{lov_Txt_Agressso_nr} ->GetValue();
                 package_get_K_D_jaar->agresso_get_K_D_jaar($agresso_nr,$jaar,$naam_verzekering);
                 package_get_K_altijd->agresso_get_K_altijd($agresso_nr,$naam_verzekering);#code
             }
             my $main_frame_notebook_onder = MainFrameNotebookOnder->refresh($main::frame);
             my $main_frame_notebook_onder_ovezicht_grid =  Overzicht_GridApp->new($main::frame);
             my $main_frame_notebook_onder_detail_grid;
             foreach my $nom_clatuur (@main::nomenclaturen) {
                 if ($main::type_grid{$nom_clatuur} eq 'VnZ') {
                     $main_frame_notebook_onder_detail_grid = Voor_na_zorg_GridApp->new($main::frame,$nom_clatuur);
                    }else {
                     $main_frame_notebook_onder_detail_grid =  Detail_GridApp->new($main::frame,$nom_clatuur);
                    }
                }
            #$main::frame->{mainframe}->{sizer_1}->Add($main::frame->{MainframeNotebookOnder}, 11, wxEXPAND | wxALIGN_TOP, 0);
            }
        }else {
         my $begindatum_opname = $main::begindatum_opname;
         if ($begindatum_opname eq '') {
             Wx::MessageBox( _T("Gelieve te werken via verwerk factuur"), 
                 _T("Assurcard Facturen"), 
                 wxOK|wxCENTRE, 
                $frame
                );#code
              $main::contract_gekozen=0;
            }else {
             my $jaar = substr($begindatum_opname,0,4);
             $periode = "periode_$jaar"."0101-$jaar"."1231";
             $main::contract_gekozen=1;
             MainFrameNotebookOnder->delete_all_pages;
             my $setup = Inhoud_Overzicht_grid->make_overzicht_matrix($periode,$naam_verzekering);
             my $main_frame_notebook_onder = MainFrameNotebookOnder->refresh($main::frame);
             my $main_frame_notebook_onder_ovezicht_grid =  Overzicht_GridApp->new($main::frame);
             my $main_frame_notebook_onder_detail_grid;
             foreach my $nom_clatuur (@main::nomenclaturen) {
                 if ($main::type_grid{$nom_clatuur} eq 'VnZ') {
                     $main_frame_notebook_onder_detail_grid = Voor_na_zorg_GridApp->new($main::frame,$nom_clatuur);
                    }else {
                     $main_frame_notebook_onder_detail_grid =  Detail_GridApp->new($main::frame,$nom_clatuur);
                    }
                }
            }
        }
     return ($naam_verzekering,$periode);
   }
sub checkbox_0_Contract_clicked {
     my ($frame, $evt) = @_;
     if ($evt->IsChecked()) {
         for (my $i=0; $i < 4; $i++) {
              $frame->{"lov_chk_$i\_Contract"}->SetValue(0);
              $main::contracts_check[$i] = 0;
         }
         $main::contracts_check[0] = 1;
         $frame->{"lov_chk_0_Contract"}->SetValue (1);
         &Verzekering_periode;
        }else {
          for (my $i=0; $i < 4; $i++) {
              $frame->{"lov_chk_$i\_Contract"}->SetValue(0);
              $main::contracts_check[$i] = 0;
            }
        }
     
    }
sub checkbox_1_Contract_clicked {
     my ($frame, $evt) = @_;
     if ($evt->IsChecked()) {
         for (my $i=0; $i < 4; $i++) {
              $frame->{"lov_chk_$i\_Contract"}->SetValue(0);
              $main::contracts_check[$i] = 0;
         }
         $main::contracts_check[1] = 1;
         $frame->{"lov_chk_1_Contract"}->SetValue (1);
         &Verzekering_periode;
        }else {
          for (my $i=0; $i < 4; $i++) {
              $frame->{"lov_chk_$i\_Contract"}->SetValue(0);
              $main::contracts_check[$i] = 0;
            }
        }     
    }
sub checkbox_2_Contract_clicked {
     my ($frame, $evt) = @_;
     if ($evt->IsChecked()) {
         for (my $i=0; $i < 4; $i++) {
              $frame->{"lov_chk_$i\_Contract"}->SetValue(0);
              $main::contracts_check[$i] = 0;
         }
         $main::contracts_check[2] = 1;
         $frame->{"lov_chk_2_Contract"}->SetValue (1);
         &Verzekering_periode;
        }else {
          for (my $i=0; $i < 4; $i++) {
              $frame->{"lov_chk_$i\_Contract"}->SetValue(0);
              $main::contracts_check[$i] = 0;
            }
        }     
    }
sub checkbox_3_Contract_clicked {
     my ($frame, $evt) = @_;
     if ($evt->IsChecked()) {
         for (my $i=0; $i < 4; $i++) {
              $frame->{"lov_chk_$i\_Contract"}->SetValue(0);
              $main::contracts_check[$i] = 0;
         }
         $main::contracts_check[2] = 1;
         $frame->{"lov_chk_3_Contract"}->SetValue (1);
         &Verzekering_periode;
        }else {
          for (my $i=0; $i < 4; $i++) {
              $frame->{"lov_chk_$i\_Contract"}->SetValue(0);
              $main::contracts_check[$i] = 0;
            }
        }     
    }
sub checkbox_0_Factuur_clicked {
     my ($frame, $evt) = @_;
     if ($evt->IsChecked()) {
         for (my $i=0; $i < 6; $i++) {
              $frame->{"lov_chk_$i\_Factuur"}->SetValue(0);
              $main::invoices_check[$i] = 0;
         }
         $main::invoices_check[0] = 1;
         $frame->{"lov_chk_0_Factuur"}->SetValue (1);
        }else {
          for (my $i=0; $i < 6; $i++) {
              $frame->{"lov_chk_$i\_Factuur"}->SetValue(0);
              $main::invoices_check[$i] = 0;
            }
        }     
    }
sub checkbox_1_Factuur_clicked {
     my ($frame, $evt) = @_;
     if ($evt->IsChecked()) {
         for (my $i=0; $i < 6; $i++) {
              $frame->{"lov_chk_$i\_Factuur"}->SetValue(0);
              $main::invoices_check[$i] = 0;
         }
         $main::invoices_check[1] = 1;
         $frame->{"lov_chk_1_Factuur"}->SetValue (1);
        
        }else {
          for (my $i=0; $i < 6; $i++) {
              $frame->{"lov_chk_$i\_Factuur"}->SetValue(0);
              $main::invoices_check[$i] = 0;
            }
        }     
    }
sub checkbox_2_Factuur_clicked {
     my ($frame, $evt) = @_;
     if ($evt->IsChecked()) {
         for (my $i=0; $i < 6; $i++) {
              $frame->{"lov_chk_$i\_Factuur"}->SetValue(0);
              $main::invoices_check[$i] = 0;
         }
         $main::invoices_check[2] = 1;
         $frame->{"lov_chk_2_Factuur"}->SetValue (1);
         
        }else {
          for (my $i=0; $i < 6; $i++) {
              $frame->{"lov_chk_$i\_Factuur"}->SetValue(0);
              $main::invoices_check[$i] = 0;
            }
        }     
    }
sub checkbox_3_Factuur_clicked {
     my ($frame, $evt) = @_;
     if ($evt->IsChecked()) {
         for (my $i=0; $i < 6; $i++) {
              $frame->{"lov_chk_$i\_Factuur"}->SetValue(0);
              $main::invoices_check[$i] = 0;
         }
         $main::invoices_check[3] = 1;
         $frame->{"lov_chk_3_Factuur"}->SetValue (1);
        
        }else {
          for (my $i=0; $i < 6; $i++) {
              $frame->{"lov_chk_$i\_Factuur"}->SetValue(0);
              $main::invoices_check[$i] = 0;
            }
        }     
    }
sub checkbox_4_Factuur_clicked {
     my ($frame, $evt) = @_;
     if ($evt->IsChecked()) {
         for (my $i=0; $i < 6; $i++) {
              $frame->{"lov_chk_$i\_Factuur"}->SetValue(0);
              $main::invoices_check[$i] = 0;
         }
         $main::invoices_check[4] = 1;
         $frame->{"lov_chk_4_Factuur"}->SetValue (1);
        }else {
          for (my $i=0; $i < 6; $i++) {
              $frame->{"lov_chk_$i\_Factuur"}->SetValue(0);
              $main::invoices_check[$i] = 0;
            }
        }     
    }
sub checkbox_5_Factuur_clicked {
     my ($frame, $evt) = @_;
     if ($evt->IsChecked()) {
         for (my $i=0; $i < 6; $i++) {
              $frame->{"lov_chk_$i\_Factuur"}->SetValue(0);
              $main::invoices_check[$i] = 0;
         }
         $main::invoices_check[5] = 1;
         $frame->{"lov_chk_5_Factuur"}->SetValue (1);
        }else {
          for (my $i=0; $i < 6; $i++) {
              $frame->{"lov_chk_$i\_Factuur"}->SetValue(0);
              $main::invoices_check[$i] = 0;
            }
        }     
    }    
sub keuze {
      my ($self,$keuzemenu) = @_;
      my $selectie = $keuzemenu->GetSelection;
      my $oude_dienst =$main::dienst;
      my $test_begin= $main::begindatum_opname;
      my $test_einde = $main::einddatum_opname;
      $main::dienst=$main::diensten[$selectie];
      # "\naangreopen keuze $self,$keuzemenu selectie $selectie oude_dienst $oude_dienst begin $test_begin einde $test_einde\n______________________________________________________\n\n";
      #my @test  = @main::diensten;
      my $har1 =  $main::overzicht_per_nomenclatuur;
      my $har2 = $main::rekenregels_per_nomenclatuur;
      my $hospi_tussenkomst_voor_dienst = $main::hospi_tussenkomst;
      my @test =@main::overzicht_matrix;
      my $bedrag_nom_overzicht;
      foreach my $nom_lijn (keys @main::overzicht_matrix) {
        my $nom_overzichtswaarde = $main::overzicht_matrix[$nom_lijn][1] ;
        if ($nom_overzichtswaarde > 0) {
             $bedrag_nom_overzicht->{$nom_overzichtswaarde}=$main::overzicht_matrix[$nom_lijn][6] ;
             print "";
        }
      }
      if ($main::dienst != $oude_dienst and $main::dienst == 0) {
         eval {foreach my $nomenclatuur (keys $main::overzicht_per_nomenclatuur) {}};
         if (!$@) {
             my $iets_veranderd =0;
            
             foreach my $nomenclatuur (reverse sort keys $main::overzicht_per_nomenclatuur) {
                 
                 my $moet_refreshen = 0;
                 my $soort_werkblad = $main::rekenregels_per_nomenclatuur->{$nomenclatuur}->{soort_werkblad};
                 if($nomenclatuur > 0) {
                        if ($soort_werkblad ne 'dienst') {                   
                            foreach my $rij (sort keys $main::overzicht_per_nomenclatuur->{$nomenclatuur}) {
                                  if ($main::overzicht_per_nomenclatuur->{$nomenclatuur}->[$rij]->[13] > 0) {
                                     $main::overzicht_per_nomenclatuur->{$nomenclatuur}->[$rij]->[13] = 0;
                                     $moet_refreshen = 1;
                                   }                      
                                  
                               }                              
                             Detail_GridApp->refresh_grid($main::grid_Detail,$nomenclatuur) if ($moet_refreshen == 1);
                           }else {
                            #my $testoverzicht_per_nomenclatuur= $main::overzicht_per_nomenclatuur;
                            #my $testnomenclatuur =$nomenclatuur;
                            #print'';
                            if ($nomenclatuur == 882137) {
                               print '';
                            }
                            foreach my $rij (keys $main::overzicht_per_nomenclatuur->{$nomenclatuur}) {
                                
                                if ($main::overzicht_per_nomenclatuur->{$nomenclatuur}->[$rij]->[4] > 0){
                                    $moet_refreshen = 1;
                                    $iets_veranderd =1;
                                    $main::overzicht_per_nomenclatuur->{$nomenclatuur}->[$rij]->[0] =0;
                                    $main::overzicht_per_nomenclatuur->{$nomenclatuur}->[$rij]->[1] =0;
                                    $main::overzicht_per_nomenclatuur->{$nomenclatuur}->[$rij]->[2] =0;
                                    $main::overzicht_per_nomenclatuur->{$nomenclatuur}->[$rij]->[3] =0;
                                    $main::overzicht_per_nomenclatuur->{$nomenclatuur}->[$rij]->[4] =0;
                                    $main::overzicht_per_nomenclatuur->{$nomenclatuur}->[$rij]->[6] =0;
                                    $main::overzicht_per_nomenclatuur->{$nomenclatuur}->[$rij]->[7] =0;
                                    $main::overzicht_per_nomenclatuur->{$nomenclatuur}->[$rij]->[8] ='';
                                    $main::overzicht_per_nomenclatuur->{$nomenclatuur}->[$rij]->[13] = 0;    
                                   }
                               }
                            Detail_GridApp->refresh_grid($main::grid_Detail,$nomenclatuur) if ($moet_refreshen == 1);
                           }
                    }
		         # my $test = $main::grid_Default;
                 if ( $iets_veranderd == 1) {
                     Detail_Grid->Toolbar_Herbereken($main::grid_Default,$nomenclatuur,1);
                     $iets_veranderd =0;
                     print '';
                 }
                 
                }
            }    
        }
      if ($main::dienst != $oude_dienst and $main::dienst != 0) {
         eval {foreach my $nomenclatuur (keys $main::overzicht_per_nomenclatuur) {}};
         if (!$@) {
             foreach my $nomenclatuur (keys $main::overzicht_per_nomenclatuur) {
                 my $iets_veranderd =0;
                 my $soort_werkblad = $main::rekenregels_per_nomenclatuur->{$nomenclatuur}->{soort_werkblad};
                 if ($soort_werkblad ne 'dienst') {
                     #foreach my $rij (keys $main::overzicht_per_nomenclatuur->{$nomenclatuur}) {
                     #    #if ($main::overzicht_per_nomenclatuur->{$nomenclatuur}->[$rij]->[13] eq  "$oude_dienst") {
                     #    if ($main::overzicht_per_nomenclatuur->{$nomenclatuur}->[$rij]->[4] >  0) {
                     #        $main::overzicht_per_nomenclatuur->{$nomenclatuur}->[$rij]->[13] = $main::dienst;
                     #$iets_veranderd =1;
                     #       }
                     #   }
                    }else {
                     if($nomenclatuur > 0) {
                         foreach my $rij (keys $main::overzicht_per_nomenclatuur->{$nomenclatuur}) {
                                $main::overzicht_per_nomenclatuur->{$nomenclatuur}->[$rij]->[0] =0;
                                $main::overzicht_per_nomenclatuur->{$nomenclatuur}->[$rij]->[1] =0;
                                $main::overzicht_per_nomenclatuur->{$nomenclatuur}->[$rij]->[2] =0;
                                $main::overzicht_per_nomenclatuur->{$nomenclatuur}->[$rij]->[3] =0;
                                $main::overzicht_per_nomenclatuur->{$nomenclatuur}->[$rij]->[4] =0;
                                $main::overzicht_per_nomenclatuur->{$nomenclatuur}->[$rij]->[6] =0;
                                $iets_veranderd =1;
                            }
                        }
                    
                    }
                     if ( $iets_veranderd == 1) {
                        #if ($nomenclatuur == 882103) {
                        #    print '';
                        #}
                         $main::grid_Default->Herberekenen($nomenclatuur,$soort_werkblad) if ($bedrag_nom_overzicht->{$nomenclatuur} > 0);
                         Detail_GridApp->refresh_grid($main::grid_Detail,$nomenclatuur);
                     }
                     
                 
                }
             my $herbereken_nom ='';
             my $herberekennom_niet_gezet =0;
             my $soort_werkblad_nom_herbereken = '';
             foreach my $nomenclatuur (keys $main::overzicht_per_nomenclatuur) {
                 my $iets_veranderd =0;
                 my $soort_werkblad = $main::rekenregels_per_nomenclatuur->{$nomenclatuur}->{soort_werkblad};
                 if($nomenclatuur > 0) {                         
                         if ($soort_werkblad ne 'dienst') {
                             if ($herberekennom_niet_gezet ==0 and $main::type_grid{$nomenclatuur} ne 'VnZ' ){
                                $soort_werkblad_nom_herbereken =$soort_werkblad;
                                $herbereken_nom = $nomenclatuur;
                               }
                            foreach my $rij (keys $main::overzicht_per_nomenclatuur->{$nomenclatuur}) {
                               #if ($main::overzicht_per_nomenclatuur->{$nomenclatuur}->[$rij]->[13] eq  "$oude_dienst") {
                                   
                                #   my $test =$main::overzicht_per_nomenclatuur;
                                if ($main::overzicht_per_nomenclatuur->{$nomenclatuur}->[$rij]->[4] >  0) {
                                    $main::overzicht_per_nomenclatuur->{$nomenclatuur}->[$rij]->[13] = $main::dienst;
                                    if ($herberekennom_niet_gezet ==0 and $main::type_grid{$nomenclatuur} ne 'VnZ' ){
                                         $herberekennom_niet_gezet =1;
                                         $herbereken_nom = $nomenclatuur;
                                         $soort_werkblad_nom_herbereken =$soort_werkblad;
                                    }
                                    $iets_veranderd =1;
                                   }
                               }
                           }
                        }
                        if ( $iets_veranderd == 1) {
                           #if ($nomenclatuur == 882103) {
                           #     print '';
                           # }
                            #print "693 Herberekenen($nomenclatuur , $soort_werkblad )\n";
                            $main::grid_Default->Herberekenen($nomenclatuur,$soort_werkblad) if ($bedrag_nom_overzicht->{$nomenclatuur} > 0);
                            #Voor_na_zorg_GridApp->refresh_grid($main::grid_VnZ,$nomenclatuur);
                            #$main::grid_VnZ->Herberekenen($nomenclatuur,$soort_werkblad) ;
                            Detail_GridApp->refresh_grid($main::grid_Detail,$nomenclatuur);
                        }
                        print "";
                       }
             #print "700 herbereken $herbereken_nom, $soort_werkblad_nom_herbereken\n";
             $main::grid_Default->Herberekenen($herbereken_nom, $soort_werkblad_nom_herbereken) if ($bedrag_nom_overzicht->{$herbereken_nom} > 0);
             #print '';
            }
        }
      
    # $_[0]->main->error('Handler method refilter for event filter.OnChoice not implemented');
     #my $testttsk =$main::hospi_tussenkomst;
     #my $test =$main::overzicht_per_nomenclatuur;
     print "";
    }
sub Agresso_Nummer {
     my ($frame,$keuze) = @_;
     if ($main::Handmatig_Inbrengen == 1) {        
         my $agresso_nr = $frame->{lov_Txt_Agressso_nr} ->GetValue();
         for (keys $main::klant){
             delete $main::klant->{$_};
            }
         ToolBarMainFrame->reset($frame);
                #undef $main::klant;
                #@main::invoices_check =();
                #@main::contracts_check =();
                #$frame->{lov_chk_0_Contract}->SetValue(0);
                #$frame->{lov_chk_1_Contract}->SetValue(0);
                #$frame->{lov_chk_2_Contract}->SetValue(0);
                #$frame->{lov_chk_3_Contract}->SetValue(0); 
                ##undef $main::gkd_commentaar;
                #@main::contracts_brieven_check = ();
                #$main::contract_gekozen=0;
                #$main::verschil=0;
                #$main::hospi_tussenkomst =0 ;
         $main::klant->{Agresso_nummer} = $agresso_nr;
         my $ophalen_data = package_agresso_get_calculater_info->agresso_get_customer_info($agresso_nr);
         my $ophalen_opnames = package_agresso_get_opname_data->agresso_get_opname_data($agresso_nr);
         my $ophalen_as400 = as400_gegevens->get_assurcard_info_rijksregnr($main::klant->{Rijksreg_Nr});
         my $resultaat  = as400_gegevens->lees_history_gkd($frame);
         #my $test = $main::klant;
         my $geboortejaar = substr($main::klant->{geboortedatum},6,4);
         my $jaar = substr($main::vandaag,0,4);
         $main::leeftijd=$jaar-$geboortejaar;
         my $zet_waarden = &set_values($frame);
        
         
         print "print";
        }else {
         Wx::MessageBox( _T("Werkt niet bij Assurcard Facturen"), 
             _T("Ophalen Via Agresso Nummer:"), 
             wxOK|wxCENTRE, 
             $frame
            );
        }  
     
    
    
}
sub Agresso_Nummer_verwerk_facturen {
     my ($keuze,$frame)= @_;
     #my $agresso_nr =$main::klanten_met_assurcard_facturen[$main::klanten_met_assurcard_facturen_teller];
     my $agresso_nr =$main::klanten_met_assurcard_facturen_niet_gesorteerd[$main::klanten_met_assurcard_facturen_teller];
     #undef $main::gkd_commentaar;
     @main::contracts_brieven_check = ();
     for (keys $main::klant){
         delete $main::klant->{$_};
     }
     print "\n\npackage_agresso_get_calculater_info->agresso_get_customer_info($agresso_nr)\n\n";     
     my $ophalen_data = package_agresso_get_calculater_info->agresso_get_customer_info($agresso_nr);
       #Wx::MessageBox( _T("package_agresso_get_calculater_info -> GEDAAN"), 
       #              _T("agresso_get_customer_info($agresso_nr))"), 
       #              wxOK|wxCENTRE, 
       #              $frame
       #             );
     print "\n\npackage_agresso_get_opname_data->agresso_get_opname_data($agresso_nr)\n\n";
     my $ophalen_opnames = package_agresso_get_opname_data->agresso_get_opname_data($agresso_nr);
     #Wx::MessageBox( _T("package_agresso_get_opname_data -> GEDAAN"), 
     #                _T("agresso_get_opname_data($agresso_nr)"), 
     #                wxOK|wxCENTRE, 
     #                $frame
     #               );
    
     print "\n\nas400_gegevens->get_assurcard_info_rijksregnr($main::klant->{Rijksreg_Nr}\n\n";
     
     my $ophalen_as400 = as400_gegevens->get_assurcard_info_rijksregnr($main::klant->{Rijksreg_Nr});
     print "as400_gegevens->lees_history_gkd($frame)\n";
     my $resultaat  = as400_gegevens->lees_history_gkd($frame);
     my $geboortejaar = substr($main::klant->{geboortedatum},6,4);
     my $jaar = substr($main::vandaag,0,4);
     $main::leeftijd=$jaar-$geboortejaar;
     #my $ophalen_facturen =package_agresso_get_calculater_info->agresso_get_invoice_info($agresso_nr); #TE TRAAG
     my $zet_waarden = &set_values($frame);   
     #Wx::MessageBox( _T("lid_opname verzekering -> GEDAAN"), 
     #                _T("aantal_dagen_betaald $main::aantal_dagen_betaald"), 
     #                wxOK|wxCENTRE, 
     #                $frame
     #               );
     print '';
}
sub RijksRegister_Nummer {
     my ($frame,$keuze) = @_;
     if ($main::Handmatig_Inbrengen == 1) {         
         my $RijksRegister = $frame->{lov_Txt_RijksReg_nr}->GetValue();
         $RijksRegister =~ s/-//g;
         $RijksRegister =~ s/\s//g;
         $RijksRegister= sprintf ('%011s',$RijksRegister);
         #for (keys $main::klant){
         #    delete $main::klant->{$_};
         #   }
         undef $main::klant;
        #my $test=$main::klant;
         ToolBarMainFrame->reset($frame);
         #undef $main::gkd_commentaar;
                #@main::contracts_check =();
                #$frame->{lov_chk_0_Contract}->SetValue(0);
                #$frame->{lov_chk_1_Contract}->SetValue(0);
                #$frame->{lov_chk_2_Contract}->SetValue(0);
                #$frame->{lov_chk_3_Contract}->SetValue(0); 
                #@main::contracts_brieven_check = ();
                #$main::verschil=0;
                #$main::hospi_tussenkomst =0 ;
         #print "\nVoor Klant:";
         #my $t = localtime;
         #print "$t";         
         my $ophalen_data = package_agresso_get_calculater_info->agresso_get_customer_info_rr_nr($RijksRegister);
         #print "\nNa Klant:";
         #$t = localtime;
         #print "$t";  
         if ($ophalen_data eq 'ok') {
                 my $agresso_nr = $main::klant->{Agresso_nummer};
                 #print "\nVoor opnames:";
                 #$t = localtime;
                 #print "$t";  
                 my $ophalen_opnames = package_agresso_get_opname_data->agresso_get_opname_data($agresso_nr);
                 #print "\nNa opnames:";
                 #$t = localtime;
                 #print "$t";  
                 #print "\nVoor AS400:";
                 #$t = localtime;
                 #print "$t";  
                 my $ophalen_as400 = as400_gegevens->get_assurcard_info_rijksregnr($RijksRegister);
                 #print "\nNa AS400:";
                 #$t = localtime;
                 #print "$t";  
                 my $resultaat  = as400_gegevens->lees_history_gkd($frame);	 
                 my $zet_waarden = &set_values($frame);
                 #my $test = $main::klant;
                 print "";
         }else {
              Wx::MessageBox( _T("Foutief rijkregister nummer: $RijksRegister "), 
             _T("Ophalen Via Agresso Rijksregister Nummer:"), 
             wxOK|wxCENTRE, 
             $frame
            );
         }
        
        }else {
         Wx::MessageBox( _T("Werkt niet bij Assurcard Facturen"), 
             _T("Ophalen Via Agresso Rijksregister Nummer:"), 
             wxOK|wxCENTRE, 
             $frame
            );
        }   
}
sub opname_data {
     my ($frame,$keuze) = @_;
     if ($main::Handmatig_Inbrengen == 1) {
         my $begindatum = $frame->{lov_Txt_0_Begin_Opname}->GetValue();
         my $einddatum  = $frame->{lov_Txt_0_Eind_Opname}->GetValue();
         if ($begindatum =~ m/^\d{8}$/ and $einddatum =~ m/^\d{8}$/ ) {
             if ($begindatum <= $einddatum) {
                 $main::einddatum_opname = $einddatum;
                 $main::begindatum_opname = $begindatum;
                }else {
                  Wx::MessageBox( _T("Vul eerst begin en einddatum in"), 
                      _T("Einddatum is later dan Begindatum"), 
                      wxOK|wxCENTRE, 
                     $frame
                    );
                }
             
            }else {
              Wx::MessageBox( _T("Vul eerst begin en einddatum in"), 
                   _T("Begin- en Einddatum zetten"), 
                   wxOK|wxCENTRE, 
                  $frame
                );
            }
         
        }else {
         Wx::MessageBox( _T("Werkt niet bij Assurcard Facturen"), 
             _T("Begin- en Einddatum zetten"), 
             wxOK|wxCENTRE, 
             $frame
            );
        }    
}
sub set_values {
     my ($frame) = @_;
     #print "\aangeroepen set values \n-----------------------------------\n";
      #$main::klant->{Agresso_nummer}
      #$main::klant->{Bankrekening}
      #$main::klant->{naam}
      #$main::klant->{Rijksreg_Nr}
      #$main::klant->{geboortedatum}
      #$main::klant->{adres}->[0..]->{e_mail}
      #$main::klant->{adres}->[0..]->{Postcode}
      #$main::klant->{adres}->[0..]->{Stad}
      #$main::klant->{adres}->[0..]->{Straat}
      #$main::klant->{adres}->[0..]->{Telefoon_nr}
      #$main::klant->{adres}->[0..]->{Type}
      #$main::klant->{contracten}->[0]->{contract_nr}
      #$main::klant->{contracten}->[0]->{einddatum}
      #$main::klant->{contracten}->[0]->{naam}
      #$main::klant->{contracten}->[0]->{startdatum}
      #$main::klant->{contracten}->[0]->{wachtdatum}
      #$main::klant->{contracten}->[0]->{zkf_nr}
      #$main::klant->{ten_laste_name}->{commentaar}
      #$main::klant->{ten_laste_name}->{ja_nee}
      #$main::klant->{ziekten}->[0..]->{verzekering}
      #$main::klant->{ziekten}->[0..]->{ziekte}
      #$main::klant->{aandoeningen}->[0..]->{aandoening}
      #$main::klant->{aandoeningen}->[0..]->{begindatum}
      #$main::klant->{aandoeningen}->[0..]->{einddatum}
      #$main::klant->{aandoeningen}->[0..]->{verzekering}
      $frame->{lov_Txt_0_Aantal_kaarten}->SetValue($main::klant->{aantal_kaarten}); 
      $frame->{lov_Txt_Agressso_nr}->SetValue("$main::klant->{Agresso_nummer}" );
      $frame->{lov_Txt_Naam}->SetValue($main::klant->{naam}); 
      $frame->{lov_Txt_RijksReg_nr}->SetValue("$main::klant->{Rijksreg_Nr}");
      $frame->{lov_Txt_GeboorteDatum}->SetValue("$main::klant->{geboortedatum}"); 
      $frame->{lov_Txt_0_contracten_naam}->SetValue($main::klant->{contracten}->[0]->{naam});
      $frame->{lov_Txt_0_contracten_startdatum}->SetValue($main::klant->{contracten}->[0]->{startdatum});
      $frame->{lov_Txt_0_contracten_einddatum}->SetValue($main::klant->{contracten}->[0]->{einddatum});
      $frame->{lov_Txt_1_contracten_naam}->SetValue($main::klant->{contracten}->[1]->{naam});
      $frame->{lov_Txt_1_contracten_startdatum}->SetValue($main::klant->{contracten}->[1]->{startdatum});
      $frame->{lov_Txt_1_contracten_einddatum}->SetValue($main::klant->{contracten}->[1]->{einddatum});
      $frame->{lov_Txt_2_contracten_naam}->SetValue($main::klant->{contracten}->[2]->{naam});
      $frame->{lov_Txt_2_contracten_startdatum}->SetValue($main::klant->{contracten}->[2]->{startdatum});
      $frame->{lov_Txt_2_contracten_einddatum}->SetValue($main::klant->{contracten}->[2]->{einddatum});
      $frame->{lov_Txt_3_contracten_naam}->SetValue($main::klant->{contracten}->[3]->{naam});
      $frame->{lov_Txt_3_contracten_startdatum}->SetValue($main::klant->{contracten}->[3]->{startdatum});
      $frame->{lov_Txt_3_contracten_einddatum}->SetValue($main::klant->{contracten}->[3]->{einddatum});
      $frame->{lov_Txt_0_contracten_wachtdatum}->SetValue($main::klant->{contracten}->[0]->{wachtdatum});
      $frame->{lov_Txt_1_contracten_wachtdatum}->SetValue($main::klant->{contracten}->[1]->{wachtdatum});
      $frame->{lov_Txt_2_contracten_wachtdatum}->SetValue($main::klant->{contracten}->[2]->{wachtdatum});
      $frame->{lov_Txt_3_contracten_wachtdatum}->SetValue($main::klant->{contracten}->[3]->{wachtdatum});
      $frame->{lov_Txt_0_contracten_zkfnr}->SetValue($main::klant->{contracten}->[0]->{zkf_nr});
      $frame->{lov_Txt_1_contracten_zkfnr}->SetValue($main::klant->{contracten}->[1]->{zkf_nr});
      $frame->{lov_Txt_2_contracten_zkfnr}->SetValue($main::klant->{contracten}->[2]->{zkf_nr});
      $frame->{lov_Txt_3_contracten_zkfnr}->SetValue($main::klant->{contracten}->[3]->{zkf_nr});
      $frame->{lov_chk_lostcard}->SetValue($main::klant->{Verloren_kaart});
     
      #bestaande aandoening
      $frame->{BA_Txt_0_aandoening}->SetValue($main::klant->{aandoeningen}->[0]->{aandoening});
      $frame->{BA_Txt_0_begindatum}->SetValue($main::klant->{aandoeningen}->[0]->{begindatum});
      $frame->{BA_Txt_0_einddatum}->SetValue($main::klant->{aandoeningen}->[0]->{einddatum});
      $frame->{BA_Txt_0_verzekering}->SetValue($main::klant->{aandoeningen}->[0]->{verzekering});
      $frame->{BA_Txt_1_aandoening}->SetValue($main::klant->{aandoeningen}->[1]->{aandoening});
      $frame->{BA_Txt_1_begindatum}->SetValue($main::klant->{aandoeningen}->[1]->{begindatum});
      $frame->{BA_Txt_1_einddatum}->SetValue($main::klant->{aandoeningen}->[1]->{einddatum});
      $frame->{BA_Txt_1_verzekering}->SetValue($main::klant->{aandoeningen}->[1]->{verzekering});
      $frame->{BA_Txt_2_aandoening}->SetValue($main::klant->{aandoeningen}->[2]->{aandoening});
      $frame->{BA_Txt_2_begindatum}->SetValue($main::klant->{aandoeningen}->[2]->{begindatum});
      $frame->{BA_Txt_2_einddatum}->SetValue($main::klant->{aandoeningen}->[2]->{einddatum});
      $frame->{BA_Txt_2_verzekering}->SetValue($main::klant->{aandoeningen}->[2]->{verzekering});
      $frame->{BA_Txt_3_aandoening}->SetValue($main::klant->{aandoeningen}->[3]->{aandoening});
      $frame->{BA_Txt_3_begindatum}->SetValue($main::klant->{aandoeningen}->[3]->{begindatum});
      $frame->{BA_Txt_3_einddatum}->SetValue($main::klant->{aandoeningen}->[3]->{einddatum});
      $frame->{BA_Txt_3_verzekering}->SetValue($main::klant->{aandoeningen}->[3]->{verzekering});
      $frame->{BA_Txt_4_aandoening}->SetValue($main::klant->{aandoeningen}->[4]->{aandoening});
      $frame->{BA_Txt_4_begindatum}->SetValue($main::klant->{aandoeningen}->[4]->{begindatum});
      $frame->{BA_Txt_4_einddatum}->SetValue($main::klant->{aandoeningen}->[4]->{einddatum});
      $frame->{BA_Txt_4_verzekering}->SetValue($main::klant->{aandoeningen}->[4]->{verzekering});
      $frame->{BA_Txt_5_aandoening}->SetValue($main::klant->{aandoeningen}->[5]->{aandoening});
      $frame->{BA_Txt_5_begindatum}->SetValue($main::klant->{aandoeningen}->[5]->{begindatum});
      $frame->{BA_Txt_5_einddatum}->SetValue($main::klant->{aandoeningen}->[5]->{einddatum});
      $frame->{BA_Txt_5_verzekering}->SetValue($main::klant->{aandoeningen}->[5]->{verzekering});
      $frame->{BA_Txt_6_aandoening}->SetValue($main::klant->{aandoeningen}->[6]->{aandoening});
      $frame->{BA_Txt_6_begindatum}->SetValue($main::klant->{aandoeningen}->[6]->{begindatum});
      $frame->{BA_Txt_6_einddatum}->SetValue($main::klant->{aandoeningen}->[6]->{einddatum});
      $frame->{BA_Txt_6_verzekering}->SetValue($main::klant->{aandoeningen}->[6]->{verzekering});
      $frame->{BA_Txt_7_aandoening}->SetValue($main::klant->{aandoeningen}->[7]->{aandoening});
      $frame->{BA_Txt_7_begindatum}->SetValue($main::klant->{aandoeningen}->[7]->{begindatum});
      $frame->{BA_Txt_7_einddatum}->SetValue($main::klant->{aandoeningen}->[7]->{einddatum});
      $frame->{BA_Txt_7_verzekering}->SetValue($main::klant->{aandoeningen}->[7]->{verzekering});
      $frame->{BA_Txt_8_aandoening}->SetValue($main::klant->{aandoeningen}->[8]->{aandoening});
      $frame->{BA_Txt_8_begindatum}->SetValue($main::klant->{aandoeningen}->[8]->{begindatum});
      $frame->{BA_Txt_8_einddatum}->SetValue($main::klant->{aandoeningen}->[8]->{einddatum});
      $frame->{BA_Txt_8_verzekering}->SetValue($main::klant->{aandoeningen}->[8]->{verzekering});
      #ernstige ziekte
      $frame->{EZ_Txt_0_ziekte}->SetValue($main::klant->{ziekten}->[0]->{ziekte});
      $frame->{EZ_Txt_0_verzekering}->SetValue($main::klant->{ziekten}->[0]->{verzekering});
      $frame->{EZ_Txt_1_ziekte}->SetValue($main::klant->{ziekten}->[1]->{ziekte});
      $frame->{EZ_Txt_1_verzekering}->SetValue($main::klant->{ziekten}->[1]->{verzekering});
      $frame->{EZ_Txt_2_ziekte}->SetValue($main::klant->{ziekten}->[2]->{ziekte});
      $frame->{EZ_Txt_2_verzekering}->SetValue($main::klant->{ziekten}->[2]->{verzekering});
      $frame->{EZ_Txt_3_ziekte}->SetValue($main::klant->{ziekten}->[3]->{ziekte});
      $frame->{EZ_Txt_3_verzekering}->SetValue($main::klant->{ziekten}->[3]->{verzekering});
      $frame->{EZ_Txt_4_ziekte}->SetValue($main::klant->{ziekten}->[4]->{ziekte});
      $frame->{EZ_Txt_4_verzekering}->SetValue($main::klant->{ziekten}->[4]->{verzekering});
      $frame->{EZ_Txt_5_ziekte}->SetValue($main::klant->{ziekten}->[5]->{ziekte});
      $frame->{EZ_Txt_5_verzekering}->SetValue($main::klant->{ziekten}->[5]->{verzekering});
      $frame->{EZ_Txt_6_ziekte}->SetValue($main::klant->{ziekten}->[6]->{ziekte});
      $frame->{EZ_Txt_6_verzekering}->SetValue($main::klant->{ziekten}->[6]->{verzekering});
      $frame->{EZ_Txt_6_ziekte}->SetValue($main::klant->{ziekten}->[7]->{ziekte});
      $frame->{EZ_Txt_6_verzekering}->SetValue($main::klant->{ziekten}->[7]->{verzekering});
      $frame->{EZ_Txt_6_ziekte}->SetValue($main::klant->{ziekten}->[8]->{ziekte});
      $frame->{EZ_Txt_6_verzekering}->SetValue($main::klant->{ziekten}->[8]->{verzekering});
      #opname data
      $frame->{OPD_Txt_0_Begin_Opname}->SetValue($main::klant->{opnames}->[0]->{begindatum});
      $frame->{OPD_Txt_0_Eind_Opname}->SetValue($main::klant->{opnames}->[0]->{einddatum});
      $frame->{OPD_Txt_1_Begin_Opname}->SetValue($main::klant->{opnames}->[1]->{begindatum});
      $frame->{OPD_Txt_1_Eind_Opname}->SetValue($main::klant->{opnames}->[1]->{einddatum});
      $frame->{OPD_Txt_2_Begin_Opname}->SetValue($main::klant->{opnames}->[2]->{begindatum});
      $frame->{OPD_Txt_2_Eind_Opname}->SetValue($main::klant->{opnames}->[2]->{einddatum});
      $frame->{OPD_Txt_3_Begin_Opname}->SetValue($main::klant->{opnames}->[3]->{begindatum});
      $frame->{OPD_Txt_3_Eind_Opname}->SetValue($main::klant->{opnames}->[3]->{einddatum});
      $frame->{OPD_Txt_4_Begin_Opname}->SetValue($main::klant->{opnames}->[4]->{begindatum});
      $frame->{OPD_Txt_4_Eind_Opname}->SetValue($main::klant->{opnames}->[4]->{einddatum});
      $frame->{OPD_Txt_5_Begin_Opname}->SetValue($main::klant->{opnames}->[5]->{begindatum});
      $frame->{OPD_Txt_5_Eind_Opname}->SetValue($main::klant->{opnames}->[5]->{einddatum});
      $frame->{OPD_Txt_6_Begin_Opname}->SetValue($main::klant->{opnames}->[6]->{begindatum});
      $frame->{OPD_Txt_6_Eind_Opname}->SetValue($main::klant->{opnames}->[6]->{einddatum});
      $frame->{OPD_Txt_7_Begin_Opname}->SetValue($main::klant->{opnames}->[7]->{begindatum});
      $frame->{OPD_Txt_7_Eind_Opname}->SetValue($main::klant->{opnames}->[7]->{einddatum});
      $frame->{OPD_Txt_8_Begin_Opname}->SetValue($main::klant->{opnames}->[8]->{begindatum});
      $frame->{OPD_Txt_8_Eind_Opname}->SetValue($main::klant->{opnames}->[8]->{einddatum});
      $frame->{OPD_Txt_9_Begin_Opname}->SetValue($main::klant->{opnames}->[9]->{begindatum});
      $frame->{OPD_Txt_9_Eind_Opname}->SetValue($main::klant->{opnames}->[9]->{einddatum});
      $frame->{OPD_Txt_10_Begin_Opname}->SetValue($main::klant->{opnames}->[10]->{begindatum});
      $frame->{OPD_Txt_10_Eind_Opname}->SetValue($main::klant->{opnames}->[10]->{einddatum});
      $frame->{OPD_Txt_11_Begin_Opname}->SetValue($main::klant->{opnames}->[11]->{begindatum});
      $frame->{OPD_Txt_11_Eind_Opname}->SetValue($main::klant->{opnames}->[11]->{einddatum});
      $frame->{OPD_Txt_12_Begin_Opname}->SetValue($main::klant->{opnames}->[12]->{begindatum});
      $frame->{OPD_Txt_12_Eind_Opname}->SetValue($main::klant->{opnames}->[12]->{einddatum});
      $frame->{OPD_Txt_13_Begin_Opname}->SetValue($main::klant->{opnames}->[13]->{begindatum});
      $frame->{OPD_Txt_13_Eind_Opname}->SetValue($main::klant->{opnames}->[13]->{einddatum});
      $frame->{OPD_Txt_14_Begin_Opname}->SetValue($main::klant->{opnames}->[14]->{begindatum});
      $frame->{OPD_Txt_14_Eind_Opname}->SetValue($main::klant->{opnames}->[14]->{einddatum});
      $frame->{OPD_Txt_15_Begin_Opname}->SetValue($main::klant->{opnames}->[15]->{begindatum});
      $frame->{OPD_Txt_15_Eind_Opname}->SetValue($main::klant->{opnames}->[15]->{einddatum});
      $frame->{OPD_Txt_16_Begin_Opname}->SetValue($main::klant->{opnames}->[16]->{begindatum});
      $frame->{OPD_Txt_16_Eind_Opname}->SetValue($main::klant->{opnames}->[16]->{einddatum});
      $frame->{OPD_Txt_17_Begin_Opname}->SetValue($main::klant->{opnames}->[17]->{begindatum});
      $frame->{OPD_Txt_17_Eind_Opname}->SetValue($main::klant->{opnames}->[17]->{einddatum});
      $frame->{OPD_Txt_18_Begin_Opname}->SetValue($main::klant->{opnames}->[18]->{begindatum});
      $frame->{OPD_Txt_18_Eind_Opname}->SetValue($main::klant->{opnames}->[18]->{einddatum});
      $frame->{OPD_Txt_19_Begin_Opname}->SetValue($main::klant->{opnames}->[19]->{begindatum});
      $frame->{OPD_Txt_19_Eind_Opname}->SetValue($main::klant->{opnames}->[19]->{einddatum});
      $frame->{OPD_Txt_20_Begin_Opname}->SetValue($main::klant->{opnames}->[20]->{begindatum});
      $frame->{OPD_Txt_20_Eind_Opname}->SetValue($main::klant->{opnames}->[20]->{einddatum});
      $frame->{OPD_Txt_21_Begin_Opname}->SetValue($main::klant->{opnames}->[21]->{begindatum});
      $frame->{OPD_Txt_21_Eind_Opname}->SetValue($main::klant->{opnames}->[21]->{einddatum});
      $frame->{OPD_Txt_22_Begin_Opname}->SetValue($main::klant->{opnames}->[22]->{begindatum});
      $frame->{OPD_Txt_22_Eind_Opname}->SetValue($main::klant->{opnames}->[22]->{einddatum});
      $frame->{OPD_Txt_23_Begin_Opname}->SetValue($main::klant->{opnames}->[23]->{begindatum});
      $frame->{OPD_Txt_23_Eind_Opname}->SetValue($main::klant->{opnames}->[23]->{einddatum});
      for (my $i=0; $i < 24; $i++) {
          $frame->{"OPD_chk_$i\_Eind_Opname"}->SetValue(0);
          $main::klant->{opnames}->[$i]->{eind_select} = 0;
        }
     for (my $i=0; $i < 24; $i++) {
          $frame->{"OPD_chk_$i\_Begin_Opname"}->SetValue(0);
          $main::klant->{opnames}->[$i]->{begin_select} = 0;
        }
     for (my $i=0; $i < 6; $i++) {
          $frame->{"lov_Txt_$i\_Factuur"}->SetValue($main::invoices[$i]);
          $frame->{"lov_chk_$i\_Factuur"}->SetValue($main::invoices_check[$i]);
        }
     $main::begindatum_opname = '';
     $main::einddatum_opname =  '';
     $frame->{lov_Txt_0_Begin_Opname}->SetValue($main::begindatum_opname);
     $frame->{lov_Txt_0_Eind_Opname}->SetValue($main::einddatum_opname);
     $frame->{AZ_Txt_ZKF}->SetValue($main::klant->{Ziekenfonds}); 
     $frame->{AZ_Txt_Extern_nummer}->SetValue($main::klant->{ExternNummer}); 
     $frame->{AZ_Txt_AssurcardNummer}->SetValue($main::klant->{AssurcardNummer}); 
     $frame->{AZ_Txt_Kaart_creatie_dat}->SetValue($main::klant->{Assurcard_Creatie_datum} );
     $frame->{AZ_Txt_Status_Kaart}->SetValue($main::klant->{Assurcard_OK});
     $frame->{AZ_Txt_Assurcard_Einddatum_contract}->SetValue($main::klant->{Assurcard_Einddatum});
     $frame->{AZ_Txt_0_Straat}->SetValue($main::klant->{adres}->[0]->{Straat});
     $frame->{AZ_Txt_0_Postcode}->SetValue($main::klant->{adres}->[0]->{Postcode});
     $frame->{AZ_Txt_0_Stad}->SetValue($main::klant->{adres}->[0]->{Stad});
     $frame->{AZ_Txt_0_type}->SetValue($main::klant->{adres}->[0]->{type});
     $frame->{AZ_Txt_0_Email}->SetValue($main::klant->{adres}->[0]->{e_mail});
     $frame->{AZ_Txt_0_Telefoon}->SetValue($main::klant->{adres}->[0]->{Telefoon_nr});
     
     $frame->{AZ_Txt_1_Straat}->SetValue($main::klant->{adres}->[1]->{Straat});
     $frame->{AZ_Txt_1_Postcode}->SetValue($main::klant->{adres}->[1]->{Postcode});
     $frame->{AZ_Txt_1_Stad}->SetValue($main::klant->{adres}->[1]->{Stad});
     $frame->{AZ_Txt_1_type}->SetValue($main::klant->{adres}->[1]->{type});
     $frame->{AZ_Txt_1_Email}->SetValue($main::klant->{adres}->[1]->{e_mail});
     $frame->{AZ_Txt_1_Telefoon}->SetValue($main::klant->{adres}->[1]->{Telefoon_nr});
     $frame->{lov_Txt_datum_laaste_aanvraag_kaart}->SetValue($main::klant->{Assurcard_Creatie_datum} );
     $frame->{AZ_Txt_Taal} ->SetValue($main::klant->{Taal});
     $frame->{lov_chk_0_Contract}->SetValue($main::contracts_check[0]);
     $frame->{lov_chk_1_Contract}->SetValue($main::contracts_check[1]);
     $frame->{lov_chk_2_Contract}->SetValue($main::contracts_check[2]);
     $frame->{lov_chk_2_Contract}->SetValue($main::contracts_check[3]); 
     
       
      $frame->{GKD_chk_0}->SetValue($main::gkd_commentaar->{0});
     $frame->{GKD_chk_1}->SetValue($main::gkd_commentaar->{1});
     $frame->{GKD_chk_2}->SetValue($main::gkd_commentaar->{2});
     $frame->{GKD_chk_3}->SetValue($main::gkd_commentaar->{3});
     $frame->{GKD_chk_4}->SetValue($main::gkd_commentaar->{4});
     $frame->{GKD_chk_5}->SetValue($main::gkd_commentaar->{5});
     #aansluiting
     $frame->{GKD_chk_6}->SetValue($main::gkd_commentaar->{6} );
     $frame->{GKD_chk_7}->SetValue($main::gkd_commentaar->{7});
     $frame->{GKD_chk_8}->SetValue($main::gkd_commentaar->{8});
     $frame->{GKD_chk_9}->SetValue($main::gkd_commentaar->{9});
     $frame->{GKD_chk_10}->SetValue($main::gkd_commentaar->{10});
     #diverse
     $frame->{GKD_chk_11}->SetValue($main::gkd_commentaar->{11});
     $frame->{GKD_chk_12}->SetValue($main::gkd_commentaar->{12});
     $frame->{GKD_chk_13}->SetValue($main::gkd_commentaar->{13});
     
     $frame->{GKD_chk_14}->SetValue($main::gkd_commentaar->{14});
     $frame->{GKD_chk_15}->SetValue($main::gkd_commentaar->{15});
     $frame->{GKD_chk_16}->SetValue($main::gkd_commentaar->{16});
     
     $frame->{GKD_chk_17}->SetValue($main::gkd_commentaar->{17});
     $frame->{GKD_chk_18}->SetValue($main::gkd_commentaar->{18});
     $frame->{GKD_chk_19}->SetValue($main::gkd_commentaar->{19});
     
     $frame->{GKD_chk_20}->SetValue($main::gkd_commentaar->{20});
     $frame->{GKD_chk_21}->SetValue($main::gkd_commentaar->{21});
     $frame->{GKD_chk_22}->SetValue($main::gkd_commentaar->{22});
     $frame->{GKD_chk_23}->SetValue($main::gkd_commentaar->{23});
     
     #$frame->{brieven_Txt_0_contracten_naam}->SetValue($main::klant->{contracten}->[0]->{naam});
     # $frame->{brieven_Txt_0_contracten_startdatum}->SetValue($main::klant->{contracten}->[0]->{startdatum});
     # $frame->{brieven_Txt_0_contracten_einddatum}->SetValue($main::klant->{contracten}->[0]->{einddatum});
     # $frame->{brieven_Txt_1_contracten_naam}->SetValue($main::klant->{contracten}->[1]->{naam});
     # $frame->{brieven_Txt_1_contracten_startdatum}->SetValue($main::klant->{contracten}->[1]->{startdatum});
     # $frame->{brieven_Txt_1_contracten_einddatum}->SetValue($main::klant->{contracten}->[1]->{einddatum});
     # $frame->{brieven_Txt_2_contracten_naam}->SetValue($main::klant->{contracten}->[2]->{naam});
     # $frame->{brieven_Txt_2_contracten_startdatum}->SetValue($main::klant->{contracten}->[2]->{startdatum});
     # $frame->{brieven_Txt_2_contracten_einddatum}->SetValue($main::klant->{contracten}->[2]->{einddatum});
     # $frame->{brieven_Txt_0_contracten_wachtdatum}->SetValue($main::klant->{contracten}->[0]->{wachtdatum});
     # $frame->{brieven_Txt_1_contracten_wachtdatum}->SetValue($main::klant->{contracten}->[1]->{wachtdatum});
     # $frame->{brieven_Txt_2_contracten_wachtdatum}->SetValue($main::klant->{contracten}->[2]->{wachtdatum});
     # $frame->{brieven_Txt_0_contracten_zkfnr}->SetValue($main::klant->{contracten}->[0]->{zkf_nr});
     # $frame->{brieven_Txt_1_contracten_zkfnr}->SetValue($main::klant->{contracten}->[1]->{zkf_nr});
     # $frame->{brieven_Txt_2_contracten_zkfnr}->SetValue($main::klant->{contracten}->[2]->{zkf_nr});
     # $frame->{brieven_chk_0_Contract}->SetValue($main::contracts_brieven_check[0]);
     # $frame->{brieven_chk_1_Contract}->SetValue($main::contracts_brieven_check[1]);
     # $frame->{brieven_chk_2_Contract}->SetValue($main::contracts_brieven_check[2]);
      my $naam_verzekering ='';
      #print Dumper(\$main::contracts_check);
      print "\n__________________\n";
      my @maincontract = @main::contracts;
      for (my $i=0; $i < 4; $i++) {
            print "$i contract nr $main::contracts_check[$i]";
            if ($main::contracts_check[$i] == 1) {
                $naam_verzekering = uc ($main::klant->{contracten}->[$i]->{naam});
                print "   naam  $naam_verzekering";
            }
            print "\n\n";
        }
      print "\nvoor if naam_verzekering $naam_verzekering \n________________\n";
      if ($naam_verzekering =~ m/forfait/i or $naam_verzekering =~ m/continue/i) {
         print "naam_verzekering $naam_verzekering main::prijs_per_dag_forfait $main::prijs_per_dag_forfait\n";
         $main::aantal_dagen_betaald = $main::hospi_tussenkomst /$main::prijs_per_dag_forfait if ($main::prijs_per_dag_forfait > 0) ;;
      }else {
         $main::aantal_dagen_betaald = '';
      }
      print "na if\n";
      my $ant_bet= $main::aantal_dagen_betaald;
      print "aantal dag betaald $ant_bet\----\n";
      $main::aantal_dagen_betaald =0 if !($main::aantal_dagen_betaald);
      $ant_bet= $main::aantal_dagen_betaald;
      print "aantal dag betaald $ant_bet\----\n";
      $main::verschil_dagen_betaald_txtctrl->SetValue("$main::aantal_dagen_betaald");     
      print "lid_opname verzekering gedaan";
       
    }

1;