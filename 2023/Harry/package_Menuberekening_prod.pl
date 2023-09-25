#!/usr/bin/perl -w
use strict;

package MenuMainFrame;
     use Wx qw[:everything];
     use base qw(Wx::Frame);
     use Wx::Event qw(EVT_MENU);
     #use Data::Dumper;
     use strict;
     use Wx::Locale gettext => '_T';
     sub new {
         my ($class, $frame) = @_;
         
         $frame->{main_frame_menubar} = Wx::MenuBar->new();
         my $Actie_menu;
         $Actie_menu = Wx::Menu->new();
         $frame->{Handmatig_Inbrengen}=$Actie_menu->AppendRadioItem(wxID_ANY, _T("Handmatig Inbrengen"), "");
         $frame->{Verwerk_Assurcard_Facturen}=$Actie_menu->AppendRadioItem(wxID_ANY, _T("Verwerk Assurcard Facturen"), "");
         $frame->{main_frame_menubar}->Append($Actie_menu, _T("Actie"));
         
         my $Exit_menu   = Wx::Menu->new();
         $Exit_menu->Append(wxID_EXIT,_T("Exit\tCtrl+X"));
         $frame->{main_frame_menubar}->Append($Exit_menu, _T("Exit"));
         
         Wx::Event::EVT_MENU( $frame, $frame->{Verwerk_Assurcard_Facturen}, \&Verwerk_Assurcard_Facturen);
         Wx::Event::EVT_MENU( $frame,$frame->{Handmatig_Inbrengen}, \&Handmatig_Inbrengen);
         Wx::Event::EVT_MENU( $frame, wxID_EXIT, sub {$_[0]->Close(1)} );
         return ($frame);
        }
     
     sub Verwerk_Assurcard_Facturen {
         my($frame, $event) = @_;
         @main::klanten_met_assurcard_facturen=();
         undef $main::klanten_met_assurcard_facturen_rijksregnr;
         @main::klanten_met_assurcard_facturen_niet_gesorteerd = ();
         $main::klanten_met_assurcard_facturen_teller =0;
         #my $pid = 0;
         #eval { $pid = fork(); };
         #print "";
         #Wx::MessageBox( _T("Verwerk Assurcard Facturen\nEven Geduld ophalen Data"), 
         #         _T("Actie"), 
         #          wxOK|wxCENTRE, 
         #          $frame
         #      );
         $main::progess_dialog = Wx::ProgressDialog->new("Even Geduld ophalen Data", 'Connecteer Agresso',7, $frame,
                                        wxPD_AUTO_HIDE | wxPD_APP_MODAL | wxPD_ELAPSED_TIME | wxPD_SMOOTH);
         #delete $main::klant{$_} for keys $main::klant;
         undef $main::klant;
         @main::verzekeringen_in_xml= ();
         @main::contracts_check = ();
         $main::contract_gekozen=0;
         MenuMainFrame->set_values_menu ($main::frame);
         #$frame->{Verwerk_Assurcard_Facturen}->SetValue(1);
         #$frame->{Handmatig_Inbrengen}->SetValue(0);
         $main::progess_dialog->Update(1,'Start Soap');
         my $ophalen_data = package_agresso_get_calculater_info->agresso_get_clients_with_assurcard_invoices ;
         $main::progess_dialog->Update(7,'Finished');
         $main::progess_dialog->Destroy();
         if ($ophalen_data eq 'geen_facturen') {
              Wx::MessageBox( _T("Geen klanten met Assurcard Facturen"), 
                  _T("Klanten met Assurcard Facturen"), 
                   wxOK|wxCENTRE, 
                   $frame
               );#code
         }elsif ($ophalen_data =~ m/AGRESSO NOK/) {
             Wx::MessageBox("$ophalen_data", 
                  _T("Klanten met Assurcard Facturen"), 
                   wxOK|wxCENTRE, 
                   $frame
               );#code
         }else {
             #my @test=@main::klanten_met_assurcard_facturen;
             my $eerste_klant =Lid_Opname_Verzekering->Agresso_Nummer_verwerk_facturen($frame);
             $main::Verwerk_Assurcard_Facturen =1;
             $main::Handmatig_Inbrengen=0;
             print"";
             ToolBarMainFrame->recreate_toolbar($frame);             
            }
     }
     sub Handmatig_Inbrengen {
          my($frame) = @_;
          Wx::MessageBox( _T("Handmatig Inbrengen"), 
                  _T("Actie"), 
                   wxOK|wxCENTRE, 
                   $frame
               );
         undef $main::klant; 
         @main::verzekeringen_in_xml= ();
         @main::contracts_check = ();
         if ($main::Verwerk_Assurcard_Facturen == 1) { # clear alless
             undef @main::invoices;
             undef @main::invoices_check;
             $main::aantal_dagen_betaald =0;
             $main::verschil=0;
             $main::hospi_tussenkomst=0;
             $main::psk_plus_suppl=0;
             
             $frame->{lov_Txt_Ptsk_suppl}->SetValue('');
             $frame->{lov_Txt_Dagen_Betaald}->SetValue('');
             $frame->{lov_Txt_Verschil}->SetValue('');
             $frame->{lov_Txt_Hospi_Tussenkomst}->SetValue('');
             $frame->{lov_Txt_0_Aantal_kaarten}->SetValue('');
             $frame->{lov_chk_0_Factuur}->SetValue(0);
             $frame->{lov_chk_1_Factuur}->SetValue(0);
             $frame->{lov_chk_2_Factuur}->SetValue(0);
             $frame->{lov_chk_3_Factuur}->SetValue(0);
             $frame->{lov_chk_4_Factuur}->SetValue(0);
             $frame->{lov_chk_5_Factuur}->SetValue(0);
             $frame->{lov_Txt_0_Factuur}->SetValue('');
             $frame->{lov_Txt_1_Factuur}->SetValue('');
             $frame->{lov_Txt_2_Factuur}->SetValue('');
             $frame->{lov_Txt_3_Factuur}->SetValue('');
             $frame->{lov_Txt_4_Factuur}->SetValue('');
             $frame->{lov_Txt_5_Factuur}->SetValue('');
             #my @test_over =  @main::overzicht_matrix;
             #my @test_nom =@main::nomenclaturen;
             #my %test_type_grid = %main::type_grid;
             #my $test_overzicht_nom = $main::overzicht_per_nomenclatuur;
             #my @test_overzicht = @main::overzicht_matrix;
             #my $test_grid_Default = $main::grid_Default; #voor herbereken
             #my $test_grid_detail = $main::grid_Detail; #voor refresh
             #my $test_grid_vnz = $main::grid_VnZ; #voor herbereken
             #my  $test_grid_VnZ_refresh = $main::grid_VnZ_refresh; #voor refresh
             #my $test_grid_Overzicht= $main::grid_Overzicht ; #voor refresh
             #print '';
             package_clear->clear_overzichts_matrix($frame);
             #@test_over =  @main::overzicht_matrix;
             #print '';
             package_clear->clear_overzicht_per_nomenclatuur_without_calc($frame);
             #print '';
         }
         
         MenuMainFrame->set_values_menu ($main::frame); 
         #$frame->{Verwerk_Assurcard_Facturen}->SetValue(0);
         #$frame->{Handmatig_Inbrengen}->SetValue(1);  
         $main::Verwerk_Assurcard_Facturen =0;
         $main::Handmatig_Inbrengen=1;
         print"";
         ToolBarMainFrame->recreate_toolbar($frame);
     }
     sub Agresso_Nummer_verwerk_facturen {
         my ($keuze,$frame)= @_;
         my $agresso_nr = $frame->{lov_Txt_Agressso_nr} ->GetValue();
         for (keys $main::klant){
             delete $main::klant->{$_};
            }
         my $ophalen_data = package_agresso_get_calculater_info->agresso_get_customer_info($agresso_nr);
         my $ophalen_opnames = package_agresso_get_opname_data->agresso_get_opname_data($agresso_nr);
         my $ophalen_as400 = as400_gegevens->get_assurcard_info_rijksregnr($main::klant->{Rijksreg_Nr});
         my $zet_waarden = MenuMainFrame->set_values_menu($frame);  
        }
     sub set_values_menu {
         my ($class,$frame) = @_;
         
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
         #my $test = $main::klant;
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
         $frame->{lov_Txt_0_contracten_wachtdatum}->SetValue($main::klant->{contracten}->[0]->{wachtdatum});
         $frame->{lov_Txt_1_contracten_wachtdatum}->SetValue($main::klant->{contracten}->[1]->{wachtdatum});
         $frame->{lov_Txt_2_contracten_wachtdatum}->SetValue($main::klant->{contracten}->[2]->{wachtdatum});
         $frame->{lov_Txt_0_contracten_zkfnr}->SetValue($main::klant->{contracten}->[0]->{zkf_nr});
         $frame->{lov_Txt_1_contracten_zkfnr}->SetValue($main::klant->{contracten}->[1]->{zkf_nr});
         $frame->{lov_Txt_2_contracten_zkfnr}->SetValue($main::klant->{contracten}->[2]->{zkf_nr});
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
         $frame->{lov_chk_3_Contract}->SetValue($main::contracts_check[3]); 
         
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
         #$frame->{brieven_Txt_0_contracten_startdatum}->SetValue($main::klant->{contracten}->[0]->{startdatum});
         #$frame->{brieven_Txt_0_contracten_einddatum}->SetValue($main::klant->{contracten}->[0]->{einddatum});
         #$frame->{brieven_Txt_1_contracten_naam}->SetValue($main::klant->{contracten}->[1]->{naam});
         #$frame->{brieven_Txt_1_contracten_startdatum}->SetValue($main::klant->{contracten}->[1]->{startdatum});
         #$frame->{brieven_Txt_1_contracten_einddatum}->SetValue($main::klant->{contracten}->[1]->{einddatum});
         #$frame->{brieven_Txt_2_contracten_naam}->SetValue($main::klant->{contracten}->[2]->{naam});
         #$frame->{brieven_Txt_2_contracten_startdatum}->SetValue($main::klant->{contracten}->[2]->{startdatum});
         #$frame->{brieven_Txt_2_contracten_einddatum}->SetValue($main::klant->{contracten}->[2]->{einddatum});
         #$frame->{brieven_Txt_0_contracten_wachtdatum}->SetValue($main::klant->{contracten}->[0]->{wachtdatum});
         #$frame->{brieven_Txt_1_contracten_wachtdatum}->SetValue($main::klant->{contracten}->[1]->{wachtdatum});
         #$frame->{brieven_Txt_2_contracten_wachtdatum}->SetValue($main::klant->{contracten}->[2]->{wachtdatum});
         #$frame->{brieven_Txt_0_contracten_zkfnr}->SetValue($main::klant->{contracten}->[0]->{zkf_nr});
         #$frame->{brieven_Txt_1_contracten_zkfnr}->SetValue($main::klant->{contracten}->[1]->{zkf_nr});
         #$frame->{brieven_Txt_2_contracten_zkfnr}->SetValue($main::klant->{contracten}->[2]->{zkf_nr});
         #$frame->{brieven_chk_0_Contract}->SetValue($main::contracts_brieven_check[0]);
         #$frame->{brieven_chk_1_Contract}->SetValue($main::contracts_brieven_check[1]);
         #$frame->{brieven_chk_2_Contract}->SetValue($main::contracts_brieven_check[2]); 
          my $naam_verzekering ='';
         for (my $i=0; $i < 4; $i++) {
             if ($main::contracts_check[$i] == 1) {
                 $naam_verzekering = uc ($main::klant->{contracten}->[$i]->{naam});
                 $main::contract_gekozen=1;
                }
            }
         if ($naam_verzekering =~ m/forfait/i or $naam_verzekering =~ m/continue/i) {
              $main::aantal_dagen_betaald = $main::hospi_tussenkomst /$main::prijs_per_dag_forfait if ($main::prijs_per_dag_forfait > 0) ;
            }else {
             $main::aantal_dagen_betaald = '';
            }   
         $main::verschil_dagen_betaald_txtctrl->SetValue("$main::aantal_dagen_betaald");
        }


1;