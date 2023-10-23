#!/usr/bin/perl -w
require 'package_Menuberekening_prod.pl';
require 'package_ToolBarMainFrame_prod.pl';
require 'package_MainFrameNotebookBoven_prod.pl';
require 'package_MainframeNotebookOnder_prod.pl';
require 'package_Overzicht_Grid_prod.pl';
require 'package_Detail_grid_prod.pl';
require 'package_assurcard_calculation_settings_prod.pl';
require 'package_inhoud_overzicht_prod.pl';
require 'package_voor_na_zorg_prod.pl';
require 'package_agresso_get_calculater_info_prod.pl';
require 'package_agresso_get_opname_data_prod.pl';
require 'package_as400_gegevens_prod.pl';
require 'package_agresso_get_K_D_jaar_prod.pl';
require 'package_agresso_get_K_altijd_prod.pl';
require 'package_invoice_to_agresso_prod.pl';
require 'package_sql_toegang_agresso_prod.pl';
require 'package_clear_prod.pl';
require 'package_voor_en_nazorg_naar_agresso_prod.pl';
require 'package_ambulante_zorgen_ernstige_ziekten_naar_agresso_prod.pl';
require 'package_commentaar_tab_prod.pl';
require 'package_Lid_Opname_Verzekering_prod.pl';
require 'package_Assurcard_Ziekenfonds_prod.pl';
require 'package_BestaandeAandoening_ErnstigeZiekte_prod.pl';
require 'package_ernstige_ziekte_prod.pl';
require 'package_opnamadata_prod.pl';
#require "settings.pl";
require "package_settings_prod.pl";
#require "cnnectdb.pl";
require "package_cnnectdb_prod.pl";
require 'package_gkd_tab_prod.pl';
#require 'package_OO_brieven.pl';
#require 'package_maak_brief.pl';
require 'Decryp_Encrypt.pl';
package main;
     our $version = 'v20230925_V7_'; # periode gezet op 2021 aangepast voor windows 10 geen tandplus mail weg in package_invoice_to_agresso_prod
     our $mode = 'PROD'; #TEST voor test   PROG voor productie
     $mode = $ARGV[0] if (defined $ARGV[0]);
     if ( $mode eq 'TEST' or $mode eq 'PROD'){}else{die}
     BEGIN { $ENV{HARNESS_ACTIVE} = 1 }
     use strict;
     use warnings;
     use Params::Validate::XS;
     use Class::Load;
     use Class::Load::PP;
     use Class::Load::XS;
     use DateTime::Locale;
     use XML::Simple;
     use Date::Manip::DM5 ;
     use IO::Socket::INET;
     use Storable;
     use Win32;
     #use Params::Validate::PP;
     our $vandaag = ParseDate("today");
     $vandaag = substr ($vandaag,0,8);
     our @recuperatie_van_ziekenfonds = ();
     our $instelingen = assurcard_calculation_settings->new();     
     our @verzekeringen_in_xml; #verzekeringen die in xml staan
     our @overzicht_matrix; # zit het overzichtsblad in
     our @overzicht_matrix_groeprijen; # welke rijen zijn groepen in het overzicht
     our $aantal_rij_overzicht_matrix; 
     our @nomenclaturen;
     our @diensten;
     our $dienst;
     our %overzicht_per_nomenclatuur; #$overzicht_per_nomenclatuur->{nomeclatuur}[rij][kolom]
     our $rekenregels_per_nomenclatuur;
     our $tekst_rekenregels_per_nomenclatuur;
     our $teksten_gebruikte_rekenregels_per_nomenclatuur;
     our %verkorte_naam_per_nomenclatuur;
     our %nomenclatuur_per_verkorte_naam;
     our %nomenclatuurnummers_per_groep;
     our $nomenclaturen_per_groepsregel;
     our $geweigerde_types_pernomenclatuur;
     our $geweigerde_types_pernomenclatuur_fr;
     our $begin_eind_dat_verschil_nomenclatuur;
     our %type_grid; #type van beeld
     our $frame;
     our %page_nr;
     our $begindatum_opname = '';
     our $einddatum_opname =  '';
     our $leeftijd = 10;
     our $hospi_tussenkomst =0 ;
     our $hospi_tussenkomsttxtctrl;
     our $verschil_dagen_betaald_txtctrl; #berekekening aantal dagen betaald
     our $verschil=0;
     our $aantal_dagen_betaald = 0; #berekekening aantal dagen betaald
     our $prijs_per_dag_forfait = 1; #berekekening aantal dagen betaald
     our $verschil_txtctrl;
     our $datum_laaste_aanvraag_kaart = '';
     our $klant;
     our $opnamedata;
     our @klanten_met_assurcard_facturen;
     our $klanten_met_assurcard_facturen_rijksregnr;
     our @klanten_met_assurcard_facturen_niet_gesorteerd;
     our $klanten_met_assurcard_facturen_teller =0;
     #our $klanten_met_assurcard_facturen_niet_gesorteerd_teller = 0;
     our $aantal_klanten_met_facturen =0;
     our $Handmatig_Inbrengen =1;
     our $Verwerk_Assurcard_Facturen=0;
     our $Normal_Item;
     our $invoice ;
     our @invoices;
     our @invoices_check;
     our $invoices_zgt_mark_invoices;
     our $grid_Default; #voor herbereken
     our $grid_Detail; #voor refresh
     our $grid_VnZ; #voor herbereken
     our $grid_VnZ_refresh; #voor refresh
     our $grid_Overzicht; #voor refresh
     our $agresso_instellingen;
     our $contract_gekozen=0;
     our @contracts_check;
     our @contracts_brieven_check;
     our $zgt_mark_invoice_welke_factuur_we_behandelen;
     our @Voor_en_NaZorg_nomenclaturen;
     our @ambulante_zorgen_ernstige_ziekten_nomenclaturen;
     our $commentaar = '';
     our $carensdagen = 0;
     our $verkoopsdagboek = '';
     our $tech_creation_date;
     our $lijnen_per_invoice_per_nom;
     our $max_lijnen_invoice ;
     our $gkd_commentaar; #hash met gkd_commentaar
     our $teksten_GKD = assurcard_calculation_settings->teksten_gkd();;  #voor naar het gkd te sturen
     our $progess_dialog;
     our $cardinstellingen ;
     our @verzekeringen_met_kaart ;
     our @verzekeringen_niet_in_de_loop; # verzekeringen die niet mee moeten verwerkt worden bij elektronische betalingen
     our $psk_plus_suppl =0;
     our @nomenclaturen_met_wachttijd;
     our $wachttijden_per_nomenclatuur;
     our $as400;    
     our $mobicoon_al_opgestart =0;     
     #kolom 1("P. tsk."));
     #kolom 2 (2, _T("Sup."));
     #kolom 3 (3, _T("Totaal"));
     #kolom 4 (4, _T("Z. tsk"));
     #kolom 5 (5, _T("HP+ tsk"));
     #kolom 6 (6, _T("Verschil"));
     main->load_agresso_setting("\\\\s298file101.zkf200mut.prd\\250-B\\Applicaties\\Assurcard\\assurcard_settings_xml_$mode\\harry_agresso_settings.xml"); #nagekeken     
     my $instpath = $main::agresso_instellingen->{plaats_mobicoon};
     my $periode= "periode_20230101-20231231"; #opgelet ook aanpassen in package_ToolBarMainFrame
     our $gebruikersnaam = package_invoice_to_agresso->get_windows_user;
     #$gebruikersnaam = 'M203DUVI' if (uc $gebruikersnaam eq 'M203HCON');  
     $gebruikersnaam = 'M235DUVI' if (uc $gebruikersnaam eq 'M203DUVI');
     $gebruikersnaam = 'M235DUVI' if (uc $gebruikersnaam eq 'M203HCON');     
     $gebruikersnaam = uc $gebruikersnaam ;
     our $variant_LG04;
     $variant_LG04 = package_agresso_get_calculater_info->variant_LG04($gebruikersnaam);
     $variant_LG04 = $main::agresso_instellingen->{Default_variant_LG04} if ($main::agresso_instellingen->{always_use_default_variant_LG04} eq 'YES');
     #my $verzekering = "hospiplan_ambuplan";
     #my $verzekering = "Hospiforfait25";
     #$variant_LG04 = 20;
     my $verzekering = "hospiplus_ambuplus";
     my $setup = Inhoud_Overzicht_grid->make_overzicht_matrix($periode,$verzekering);
     voor_en_nazorg_naar_agresso->welke_nomenclaturen_zijn_voor_en_nazorg;
     ambulante_zorgen_ernstige_ziekten_naar_agresso->welke_nomenclaturen_zijn_ambulante_zorgen_ernstige_ziekten;
     &verzekeringen_met_kaart;
     &verzekeringen_niet_in_de_loop;
     my $app = App->new();
     $app->MainLoop;
    
     sub load_agresso_setting  {
         my ($class,$file_name) =  @_;
         print "$file_name ->";
         $agresso_instellingen = XMLin("$file_name");
         print "ingelezen\n";
         foreach my $zkf_inst (keys $agresso_instellingen->{verzekeringen}) {
             #my $verz_inst =$agresso_instellingen->{verzekeringen}->{$zkf_inst};
             foreach my $verz_inst  (sort keys $agresso_instellingen->{verzekeringen}->{$zkf_inst}) {
                 if (uc $verz_inst ~~ @main::verzekeringen_in_xml) {
                     #doe niets#code
                    }else {
                     push (@verzekeringen_in_xml,uc $verz_inst);
                    }
                }
            } 
        }
  
     sub verzekeringen_met_kaart {
         foreach my $zkf (keys $main::agresso_instellingen->{verzekeringen_met_kaart}) {
              foreach my $naam_verzekering (keys  $main::agresso_instellingen->{verzekeringen_met_kaart}->{$zkf}){
                 if ($naam_verzekering ~~ @verzekeringen_met_kaart ) {
                     #doe niets#code                
                    }else {
                     push (@verzekeringen_met_kaart,uc $naam_verzekering);
                    }
                 
                }
            }
         print '';
        }
     sub verzekeringen_niet_in_de_loop {
         eval{foreach my $naam_verzekering (keys  $main::agresso_instellingen->{verzekeringen_niet_in_loop}){}};
         if (!$@) {
              foreach my $naam_verzekering (keys  $main::agresso_instellingen->{verzekeringen_niet_in_loop}){
                 if (uc $naam_verzekering ~~ @verzekeringen_niet_in_de_loop ) {
                     #doe niets#code                
                    }else {
                     push (@verzekeringen_niet_in_de_loop,uc $naam_verzekering);
                    }
                 
                }
         }else {
            @verzekeringen_niet_in_de_loop =();
         }
         print '';
        }
     
package App;
     use strict;
     use warnings;
     use base 'Wx::App';
     sub OnInit {
         $main::frame = Frame->new();
         $main::frame->Maximize( 1 );
         $main::frame->Show(1);
        }     
package Frame;
     use strict;
     use warnings;
     use Wx qw(:everything);
     use base qw(Wx::Frame);
     use Data::Dumper;
     use Wx::Locale gettext => '_T';
     sub new {
          my($self) = @_;
          my $ip = $main::agresso_instellingen->{"Agresso_IP_$main::mode"};
          $self = $self->SUPER::new(undef, -1, "Harry $main::mode $main::version Milestone 7 Agresso  -> User: $main::gebruikersnaam-> $ip -> Variant: $main::variant_LG04",
                              wxDefaultPosition,[1350,850],wxDEFAULT_FRAME_STYLE | wxMAXIMIZE);
          #$self = $self->SUPER::new(undef, -1, "Berekening - Voorbeeld",
          #                    wxDefaultPosition,wxDefaultSize,wxDEFAULT_FRAME_STYLE | wxMAXIMIZE);
          #$self->{matrix}=@overzicht_matrix;     
         my $instelingen = assurcard_calculation_settings->new($self);
         #in $self->{calculation_settings} zit de xml
         my $menu_main_frame = MenuMainFrame->new($self);
         my $toolbar_main_frame = ToolBarMainFrame->new($self);
         my $main_frame_notebook_boven = MainFrameNotebookBoven->new($self);
         my $main_frame_notebook_onder = MainFrameNotebookOnder->new($self);
         my $main_frame_notebook_onder_ovezicht_grid =  Overzicht_GridApp->new($self);
         my $main_frame_notebook_onder_detail_grid;
         foreach my $nom_clatuur (@main::nomenclaturen) {
             if ($main::type_grid{$nom_clatuur} eq 'VnZ') {
                 $main_frame_notebook_onder_detail_grid = Voor_na_zorg_GridApp->new($self,$nom_clatuur);
             }else {
                 $main_frame_notebook_onder_detail_grid =  Detail_GridApp->new($self,$nom_clatuur);
             }
             
            }
         #my $logwindow = Wx::LogWindow->new( $self , "title", !!"show" );
          $self->__do_layout();
         # $self->{Maximize}(1);
          return $self;
        }

     sub check_input_ok {
         my $class = @_;
         if ($main::Handmatig_Inbrengen ==1) {
         if ($main::begindatum_opname < 19000000 or $main::einddatum_opname < 19000000) {
            Wx::MessageBox( _T("Gelieve Begin- en Einddatum opname in te voeren"), 
                 _T("Handmatig Inbrengen"), 
                 wxOK|wxCENTRE, 
                 $main::frame
                );
          }else {
              my $volgnr_contract = '';
              for (my $i=0; $i < 3; $i++) {
                 my $is_checked = $main::contracts_check[$i];
                 $volgnr_contract = $i if ($is_checked == 1);   
                }
             if ($volgnr_contract eq '') {
                Wx::MessageBox( _T("Gelieve een verzekering te kiezen"), 
                     _T("Handmatig Inbrengen"), 
                     wxOK|wxCENTRE, 
                     $main::frame
                    );
               }
            }
        }
    }
sub __do_layout {
     my $self =shift;
     $self->SetMenuBar($self->{main_frame_menubar});
     $self->SetToolBar($self->{frame_toolbar});
     $self->{mainframe}->{sizer_1} = Wx::BoxSizer->new(wxVERTICAL);
     $self->SetSizerAndFit( $self->{mainframe}->{sizer_1});
     $self->{MainFrameNotebookBoven_pane_lov}->SetSizer($self->{lov_sizer_1}); 
     $self->{MainFrameNotebookBoven_pane_AZ}->SetSizer($self->{AZ_sizer_1});
     $self->{MainFrameNotebookBoven_pane_BA_EZ}->SetSizer($self->{BA_EZ_sizer_1});
     $self->{MainFrameNotebookBoven_pane_EZ}->SetSizer($self->{EZ_sizer_1});
     $self->{MainFrameNotebookBoven_pane_OPD}->SetSizer($self->{OPD_sizer_1});
     $self->{MainFrameNotebookBoven_pane_CT}->SetSizer($self->{CT_sizer_1});
     $self->{MainFrameNotebookBoven_pane_GKD}->SetSizer($self->{GKD_sizer_1});
     #$self->{MainFrameNotebookBoven_pane_brieven}->SetSizer($self->{brieven_sizer_1});
     #$self->{mainframe}->{sizer_1}->Add($self->{MainFrameNotebookBoven}, 1, wxEXPAND, 0);
     $self->{mainframe}->{sizer_1}->Add($self->{MainFrameNotebookBoven}, 2,wxEXPAND, 0);
     $self->{mainframe}->{sizer_1}->Add($self->{MainframeNotebookOnder}, 11, wxEXPAND | wxALIGN_TOP, 0);
     $self->Layout();
}

1;