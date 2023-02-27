#!/usr/bin/perl -w
use strict;

package ToolBarMainFrame;
     use Wx qw[:everything];
     use base qw(Wx::Frame);
     use Wx::Event qw(EVT_MENU);
     use Wx::Event qw(EVT_TOOL);
     use Wx::Event qw(EVT_TOOL_ENTER);
     use Wx::Event qw(EVT_TOOL_RCLICKED);
     use Date::Manip::DM5 ;
     use Date::Calc qw(:all);
     use Win32::GuiTest qw(PushButton FindWindowLike SetForegroundWindow SendKeys SendMouse WaitWindow IsWindow IsKeyPressed);
     #use Data::Dumper
     use strict;
     use Wx::Locale gettext => '_T';
     use IO::Socket::INET;
     use Storable;
     sub recreate_toolbar {        
         my ($class,$frame) = @_;
         my $t = $main::frame->GetToolBar;
         #$t->Destroy if $t;
         # Wx::MessageBox( _T("after destroy"), 
         #            _T("toolbar"), 
         #            wxOK|wxCENTRE, 
         #            $frame
         #           );
         #$frame->SetToolBar( undef );
         #my( $style ) =  wxTB_HORIZONTAL | wxTB_DOCKABLE; #  | wxNO_BORDER | wxTB_FLAT
         #$t = $frame->CreateToolBar( $style, 115);
        #
        # $frame->{opslaan}=$frame->{frame_toolbar}->AddTool(1200, _T("Naar Agresso sturen"), Wx::Bitmap->new("C:\\MACROS\\OGV\\bitmap\\opslaan.bmp", wxBITMAP_TYPE_ANY), wxNullBitmap, wxITEM_NORMAL, _T("Naar Agresso"), "");
        # $frame->{vorige_klant_met_factuur} = $frame->{frame_toolbar}->AddTool(1201, _T("Vorige"), Wx::Bitmap->new("C:\\MACROS\\OGV\\bitmap\\vorige.bmp", wxBITMAP_TYPE_ANY), wxNullBitmap, wxITEM_NORMAL, _T("Vorige"), "");      
        # $frame->{volgende_klant_met_factuur} =$frame->{frame_toolbar}->AddTool(1202, _T("Volgende"), Wx::Bitmap->new("C:\\MACROS\\OGV\\bitmap\\volgende.bmp", wxBITMAP_TYPE_ANY), wxNullBitmap, wxITEM_NORMAL, _T("Volgende"), "");
        # $frame->{factuur_ophalen}=$frame->{frame_toolbar}->AddTool(1203, _T("Factuur Ophalen"), Wx::Bitmap->new("C:\\MACROS\\OGV\\bitmap\\factuur_ophalen1.bmp",wxBITMAP_TYPE_ANY), wxNullBitmap, wxITEM_NORMAL, _T("Factuur ophalen"), "");
        # $frame->{factuur_Verwerken}=$frame->{frame_toolbar}->AddTool(1204, _T("Factuur Verwerken"), Wx::Bitmap->new("C:\\MACROS\\OGV\\bitmap\\Factuur_verwerken.bmp",wxBITMAP_TYPE_ANY), wxNullBitmap, wxITEM_NORMAL, _T("Factuur Verwerken"), "");
        # $frame->{mobicoon}=$frame->{frame_toolbar}->AddTool(1206, _T("Mobicoon"), Wx::Bitmap->new("C:\\MACROS\\OGV\\bitmap\\mobicoon.bmp" ,wxBITMAP_TYPE_ANY), wxNullBitmap, wxITEM_NORMAL, _T("Mobicoon"), "");
        # $frame->{Reset}=$frame->{frame_toolbar}->AddTool(1205, _T("Reset"), Wx::Bitmap->new("C:\\MACROS\\OGV\\bitmap\\Reset.bmp" ,wxBITMAP_TYPE_ANY), wxNullBitmap, wxITEM_NORMAL, _T("Reset"), "");
        ## my $test= $main::Handmatig_Inbrengen;
         if ($main::Handmatig_Inbrengen != 1) {
             #$frame->{Reset}=$frame->{frame_toolbar}->AddTool(1210, _T("spacer"), Wx::Bitmap->new("P:\\OGV\\ASSURCARD_PROG\\bitmap\\spacer.bmp",wxBITMAP_TYPE_ANY), wxNullBitmap, wxITEM_NORMAL, _T("spacer"), "");       
             $frame->{frame_toolbar}->AddSeparator;
             $frame->{Toolbar_choice_leden_met_assurcard_facturen} = Wx::Choice->new($frame->{frame_toolbar}, 28,wxDefaultPosition,wxSIZE(100,20),\@main::klanten_met_assurcard_facturen);#\@main::klanten_met_assurcard_facturen
             $frame->{frame_toolbar}->AddControl($frame->{Toolbar_choice_leden_met_assurcard_facturen});
             $frame->{frame_toolbar}->AddSeparator;
             $frame->{Toolbar_choice_leden_met_assurcard_facturen_niet_gesorteerd} = Wx::Choice->new($frame->{frame_toolbar}, 27,wxDefaultPosition,wxSIZE(100,20),\@main::klanten_met_assurcard_facturen_niet_gesorteerd);#@main::klanten_met_assurcard_facturen_niet_gesorteerd
             $frame->{frame_toolbar}->AddControl($frame->{Toolbar_choice_leden_met_assurcard_facturen_niet_gesorteerd});
             Wx::Event::EVT_CHOICE($frame,$frame->{Toolbar_choice_leden_met_assurcard_facturen},\&kies_klant);
              Wx::Event::EVT_CHOICE($frame,$frame->{Toolbar_choice_leden_met_assurcard_facturen_niet_gesorteerd},\&kies_klant_niet_gesorteerd);
            }
         $t->Realize;
         #Wx::MessageBox( _T("after realize"), 
         #            _T("toolbar"), 
         #            wxOK|wxCENTRE, 
         #            $frame
         #           );
        }
     sub new {
         my ($class, $frame) = @_;
        
         $frame->{frame_toolbar} = Wx::ToolBar->new($frame, -1, wxDefaultPosition, wxDefaultSize, );
         $frame->{opslaan}=$frame->{frame_toolbar}->AddTool(1100, _T("Naar Agresso sturen"), Wx::Bitmap->new("P:\\OGV\\ASSURCARD_PROG\\bitmap\\opslaan.bmp", wxBITMAP_TYPE_ANY), wxNullBitmap, wxITEM_NORMAL, _T("Naar Agresso"), "");
         $frame->{vorige_klant_met_factuur} = $frame->{frame_toolbar}->AddTool(1101, _T("Vorige"), Wx::Bitmap->new("P:\\OGV\\ASSURCARD_PROG\\bitmap\\vorige.bmp", wxBITMAP_TYPE_ANY), wxNullBitmap, wxITEM_NORMAL, _T("Vorige"), "");
         $frame->{volgende_klant_met_factuur} =$frame->{frame_toolbar}->AddTool(1102, _T("Volgende"), Wx::Bitmap->new("P:\\OGV\\ASSURCARD_PROG\\bitmap\\volgende.bmp", wxBITMAP_TYPE_ANY), wxNullBitmap, wxITEM_NORMAL, _T("Volgende"), "");
         $frame->{factuur_ophalen}=$frame->{frame_toolbar}->AddTool(1103, _T("Factuur Ophalen"), Wx::Bitmap->new("P:\\OGV\\ASSURCARD_PROG\\bitmap\\factuur_ophalen1.bmp",wxBITMAP_TYPE_ANY), wxNullBitmap, wxITEM_NORMAL, _T("Factuur ophalen"), "");
         $frame->{factuur_Verwerken}=$frame->{frame_toolbar}->AddTool(1104, _T("Factuur Verwerken"), Wx::Bitmap->new("P:\\OGV\\ASSURCARD_PROG\\bitmap\\Factuur_verwerken.bmp",wxBITMAP_TYPE_ANY), wxNullBitmap, wxITEM_NORMAL, _T("Factuur Verwerken"), "");
         $frame->{mobicoon}=$frame->{frame_toolbar}->AddTool(1106, _T("Mobicoon"), Wx::Bitmap->new("P:\\OGV\\ASSURCARD_PROG\\bitmap\\mobicoon.bmp",wxBITMAP_TYPE_ANY), wxNullBitmap, wxITEM_NORMAL, _T("Mobicoon"), "");
         $frame->{Reset}=$frame->{frame_toolbar}->AddTool(1105, _T("Reset"), Wx::Bitmap->new("P:\\OGV\\ASSURCARD_PROG\\bitmap\\Reset.bmp",wxBITMAP_TYPE_ANY), wxNullBitmap, wxITEM_NORMAL, _T("Reset"), "");
         $frame->{frame_toolbar}->Realize();
         Wx::Event::EVT_MENU( $frame,1100,\&factuur_naar_agresso);
         Wx::Event::EVT_MENU( $frame,1101,\&vorige_klant_met_factuur);
         Wx::Event::EVT_MENU($frame,1102,\&volgende_klant_met_factuur);
         Wx::Event::EVT_MENU($frame,1103,\&haal_factuur_op);
         Wx::Event::EVT_MENU($frame,1104,\&verwerk_factuur);
         Wx::Event::EVT_MENU($frame,1105,\&Reset);
         Wx::Event::EVT_MENU($frame,1106,\&start_mobicoon);
         #$agresso_instellingen
         return ($frame);
     }
     sub reset {
        my ($class,$frame)= @_;
        &Reset($frame);
     }
     sub start_mobicoon {
          my ($class,$event)= @_;
          my $test = $main::klant; 
              my   $sock = IO::Socket::INET->new(PeerAddr => 'localhost',  PeerPort => 9000,
                 Type     => SOCK_STREAM, Proto     => 'tcp') || die "Fail: $!";
              Storable::nstore_fd($test, $sock);
          print "";
        }
     sub Reset {
         my($frame, $event) = @_;
         if ($main::Handmatig_Inbrengen == 1) {
              package_clear->clear_overzichts_matrix;     
              package_clear->clear_overzicht_per_nomenclatuur;
             undef $main::klant;
             undef $main::dienst;
             $main::aantal_dagen_betaald =0;
             $main::frame->{lov_choice_dienst}->SetSelection(wxNOT_FOUND);
             $main::verschil=0;
             $main::hospi_tussenkomst =0 ;
             @main::verzekeringen_in_xml= ();
             @main::contracts_check = ();
             @main::contracts_brieven_check = ();
             $main::contract_gekozen=0;
             $main::periode= "periode_20210101-20211231";
             $main::verzekering = "hospiplan_ambuplan";
             MenuMainFrame->set_values_menu($frame);  #code
             MainFrameNotebookOnder->delete_all_pages;
             my $setup = Inhoud_Overzicht_grid->make_overzicht_matrix($main::periode,$main::verzekering);
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
     sub factuur_naar_agresso{
          my($frame, $event) = @_;
          my $contract = '';
          #my $test_VnZ=$main::overzicht_per_nomenclatuur;
          #my $testR1=$main::rekenregels_per_nomenclatuur;
          #my $testR2=$main::tekst_rekenregels_per_nomenclatuur;
          #my $testR3= $main::teksten_gebruikte_rekenregels_per_nomenclatuur;
          #my $invoice =$main::invoice;
          #my @invoices = @main::invoices;
          #my @invoices_check = @main::invoices_check;
          #my @overzicht_matrix = @main::overzicht_matrix;
          #my $instelingen = $main::instelingen;
          #my @klanten_met_assurcard_facturen = @main::klanten_met_assurcard_facturen;
          #my $klanten_met_assurcard_facturen_teller = $main::klanten_met_assurcard_facturen_teller;
          
          if ($main::begindatum_opname < 19000000 or $main::einddatum_opname < 19000000) {
             Wx::MessageBox( _T("Gelieve Begin- en Einddatum opname in te voeren"), 
                 _T("Factuur Opslaan"), 
                 wxOK|wxCENTRE, 
                 $frame
                );
            }else {
              my $volgnr_contract = '';
              for (my $i=0; $i < 4; $i++) {
                 my $is_checked = $main::contracts_check[$i];
                 $volgnr_contract = $i if ($is_checked == 1);   
                }
             if ($volgnr_contract eq '') {
                    Wx::MessageBox( _T("Gelieve een verzekering te kiezen"), 
                     _T("Factuur Opslaan"), 
                     wxOK|wxCENTRE, 
                     $frame
                    );
                }else {
                     my( $answer ) = Wx::MessageBox( _T("Is de dienst aangepast ?"), 
                            _T("Factuur Opslaan"), 
                             wxYES_NO|wxCENTRE, 
                            $frame
                           ); 
                    if( $answer == Wx::wxYES() ) {
                        $contract = $main::klant->{contracten}->[$volgnr_contract]->{naam};
                        $contract = uc $contract ;
                        if ($main::Verwerk_Assurcard_Facturen == 1) {
                            my $dbh =  sql_toegang_agresso->setup_mssql_connectie;
                            #my $klant = $main::klanten_met_assurcard_facturen[$main::klanten_met_assurcard_facturen_teller];
                            my $klant = $main::klanten_met_assurcard_facturen_niet_gesorteerd[$main::klanten_met_assurcard_facturen_teller];
                            my $invoice_zoeknr ='';
                            my $assurcard_invoice_nr ='';
                            for (my $nr = 0 ; $nr < 6 ; $nr++) {
                                $invoice_zoeknr = $nr if ($main::invoices_check[$nr] == 1) ;
                               }
                            $assurcard_invoice_nr = $main::invoices[$invoice_zoeknr] if (defined $invoice_zoeknr);
                            my $voucher_no = $main::invoices_zgt_mark_invoices->{$assurcard_invoice_nr}->{voucher_no};
                            my ($completed,$verzprod1,$verzprod2,$verzprod3,$verzprod4,$verzprod5)=sql_toegang_agresso->check_what_is_completed ($dbh,$voucher_no,$assurcard_invoice_nr,$klant);
                            #my $completed_moet_zijn = 110000;
                            #my  $completed_moet_zijn_plus = 0;
                            #$completed_moet_zijn_plus = 1000 if (defined $verzprod2 and $verzprod2 ne '' );
                            #$completed_moet_zijn_plus = 100 if (defined $verzprod3 and $verzprod3 ne '' );
                            #$completed_moet_zijn_plus = 10 if (defined $verzprod4 and $verzprod4 ne '' );
                            #$completed_moet_zijn_plus = 1 if (defined $verzprod5 and $verzprod5 ne '' );
                            #$completed_moet_zijn =$completed_moet_zijn + $completed_moet_zijn_plus;
                            if ($completed eq '') {
                                 Wx::MessageBox( _T("Er was geen lock op deze factuur.\nDus kunnen we niet opslaan"), 
                                    _T("Factuur Opslaan"), 
                                    wxOK|wxCENTRE, 
                                    $frame
                                   );
                               }elsif ($completed == 1) {
                                Wx::MessageBox( _T("Deze factuur was al volledig behandeld"), 
                                    _T("Factuur Opslaan"), 
                                    wxOK|wxCENTRE, 
                                    $frame
                                   );
                               }elsif ($completed == 0 and $voucher_no == $main::zgt_mark_invoice_welke_factuur_we_behandelen) {                         
                                
                                my $antwoord = package_invoice_to_agresso->maak_agresso_factuur_aan_klant ($frame);
                                Wx::MessageBox( _T("$antwoord\nASSURCARD"), 
                                    _T("Assurcard Factuur doorrekenen aan klant"), 
                                    wxOK|wxCENTRE, 
                                    $frame
                                   );
                                print "";
                                if ($antwoord =~ m/OK ordernr/ )  {
                                    sql_toegang_agresso->update_completed_assurcard_verkoopsorder_gemaakt($dbh,$voucher_no,$assurcard_invoice_nr,$klant);
                                    my $historiek_gkd = $main::teksten_GKD->{GKD_teksten}->{AUTOMATISCHE_TEKSTEN}->{ASSURCARD}->{tekst};            
                                    my $staat_er_al_in = 'nee';
                                    $staat_er_al_in = as400_gegevens->lees_history_gkd_agresso_order($historiek_gkd) ;
                                    as400_gegevens->zet_history_gkd_in ($historiek_gkd) if (defined $historiek_gkd and $historiek_gkd ne '' and $staat_er_al_in eq 'nee');
                                    my $antwoord1 = package_invoice_to_agresso->maak_hospi_plus_tussenkomst ($frame);
                                    Wx::MessageBox( _T("$antwoord1\n$contract"), 
                                        _T("Hospi teruggave aan de klant"), 
                                        wxOK|wxCENTRE, 
                                        $frame
                                       );
                                    if ($antwoord1 =~ m/OK ordernr/ )  {
                                        my $ret = sql_toegang_agresso->update_completed_hospi_verkoopsorder_gemaakt($dbh,$voucher_no,$assurcard_invoice_nr,$klant,$contract);
                                        my $historiek_gkd = $main::teksten_GKD->{GKD_teksten}->{AUTOMATISCHE_TEKSTEN}->{HOSP}->{tekst};            
                                        my $staat_er_al_in = 'nee';
                                        $staat_er_al_in = as400_gegevens->lees_history_gkd_agresso_order($historiek_gkd) ;
                                        as400_gegevens->zet_history_gkd_in ($historiek_gkd) if (defined $historiek_gkd and $historiek_gkd ne '' and $staat_er_al_in eq 'nee');
                                        if ($ret eq 'completed eq ') {
                                             Wx::MessageBox( _T("Fout completed is leeg ?"), 
                                                _T("Assurcard Factuur doorrekenen aan klant"), 
                                                wxOK|wxCENTRE, 
                                                $frame
                                               );#code 
                                           }
                                        voor_en_nazorg_naar_agresso->welke_nomenclaturen_zijn_voor_en_nazorg;
                                        my ($returncode,$ReturnText) = voor_en_nazorg_naar_agresso->save_Voor_en_Nazorg;
                                        Wx::MessageBox("$ReturnText\n code: $returncode", 
                                            _T("Voor en Nazorg Opgeslagen"), 
                                            wxOK|wxCENTRE, 
                                            $frame
                                           );
                                         ambulante_zorgen_ernstige_ziekten_naar_agresso->welke_nomenclaturen_zijn_ambulante_zorgen_ernstige_ziekten;
                                        ($returncode,$ReturnText) = ambulante_zorgen_ernstige_ziekten_naar_agresso->save_ambulante_zorgen_ernstige_ziekten;
                                        Wx::MessageBox("$ReturnText\n code: $returncode", 
                                            _T("AMBULANTE ZORGEN EN ERNSTIGE ZIEKTE OPSLAAN"), 
                                            wxOK|wxCENTRE, 
                                            $frame
                                           );
                                        #clear
                                        package_clear->clear_overzichts_matrix;
                                        #undef %main::overzicht_per_nomenclatuur;
                                        package_clear->clear_overzicht_per_nomenclatuur;
                                        #my %test = %main::overzicht_per_nomenclatuur;
                                        Lid_Opname_Verzekering->Verzekering_periode;
                                        $main::begindatum_opname = '';
                                        $main::einddatum_opname =  '';
                                        $frame->{lov_Txt_0_Begin_Opname}->SetValue($main::begindatum_opname);
                                        $frame->{lov_Txt_0_Eind_Opname}->SetValue($main::einddatum_opname);
                                        $main::contract_gekozen=0;
                                        $main::hospi_tussenkomst=0;
                                        $main::verschil=0;
                                        $frame->{lov_Txt_Hospi_Tussenkomst}->SetValue($main::hospi_tussenkomst);
                                        $frame->{lov_Txt_Verschil}->SetValue($main::verschil);
                                        $frame->{lov_choice_dienst}->SetStringSelection('0');
                                        $main::dienst ='';
                                        for (my $i=0; $i < 4; $i++) {
                                            $main::contracts_check[$i] = 0;
                                            $main::contract_gekozen=0;
                                            $frame->{"lov_chk_$i\_Contract"}->SetValue($main::contracts_check[0]);
                                           }
                                        for (my $i=0; $i < 6; $i++) {
                                            $frame->{"lov_chk_$i\_Factuur"}->SetValue(0);
                                            $main::invoices_check[$i] = 0;
                                           }
                                        #$main::grid_Detail->ForceRefresh();
                                        #$main::grid_VnZ_refresh->ForceRefresh();
                                        #$main::grid_Overzicht->ForceRefresh();
                                       }
                                   }
                               }elsif ($completed >= 100000 and $voucher_no == $main::zgt_mark_invoice_welke_factuur_we_behandelen) {
                                if (substr ($completed,1,1) ne '1' ) {
                                     my $antwoord = package_invoice_to_agresso->maak_agresso_factuur_aan_klant ($frame);
                                     Wx::MessageBox( _T("$antwoord\nASSURCARD"), 
                                        _T("Assurcard Factuur doorrekenen aan klant"), 
                                        wxOK|wxCENTRE, 
                                        $frame
                                       );#code
                                     if ($antwoord =~ m/OK ordernr/ )  {
                                          my $historiek_gkd = $main::teksten_GKD->{GKD_teksten}->{AUTOMATISCHE_TEKSTEN}->{ASSURCARD}->{tekst};
                                          my $staat_er_al_in = 'nee';
                                          $staat_er_al_in = as400_gegevens->lees_history_gkd_agresso_order($historiek_gkd) ;
                                          as400_gegevens->zet_history_gkd_in ($historiek_gkd) if (defined $historiek_gkd and $historiek_gkd ne '' and $staat_er_al_in eq 'nee');      
                                          sql_toegang_agresso->update_completed_assurcard_verkoopsorder_gemaakt($dbh,$voucher_no,$assurcard_invoice_nr,$klant);
                                       }
                                   }
                                
                                my ($completed,$verzprod1,$verzprod2,$verzprod3,$verzprod4,$verzprod5)=sql_toegang_agresso->check_what_is_completed ($dbh,$voucher_no,$assurcard_invoice_nr,$klant);
                                my $completed_moet_zijn = 110000;
                                my  $completed_moet_zijn_plus = 0;
                                $completed_moet_zijn_plus += 1000 if (defined $verzprod2 and $verzprod2 ne '' );
                                $completed_moet_zijn_plus += 100 if (defined $verzprod3 and $verzprod3 ne '' );
                                $completed_moet_zijn_plus += 10 if (defined $verzprod4 and $verzprod4 ne '' );
                                $completed_moet_zijn_plus += 1 if (defined $verzprod5 and $verzprod5 ne '' );
                                $completed_moet_zijn =$completed_moet_zijn + $completed_moet_zijn_plus;
                                my $tekst = '';
                                $tekst = "$tekst"."$verzprod2" if (substr($completed_moet_zijn,2,1) eq '1' );
                                $tekst = "$tekst"."$verzprod3" if (substr($completed_moet_zijn,3,1) eq '1' );
                                $tekst = "$tekst"."$verzprod4" if (substr($completed_moet_zijn,4,1) eq '1' );
                                $tekst = "$tekst"."$verzprod5" if (substr($completed_moet_zijn,5,1) eq '1' );
                                if ($completed > 1) {
                                    if ($contract eq uc $verzprod2 and substr ($completed,2,1) ne '1' and substr($completed_moet_zijn,2,1) eq '1' ) {
                                        my $antwoord1 = package_invoice_to_agresso->maak_hospi_plus_tussenkomst ($frame);                                 
                                        Wx::MessageBox( _T("$antwoord1\n$contract"), 
                                            _T("Hospi teruggave aan de klant"), 
                                            wxOK|wxCENTRE, 
                                            $frame
                                           );
                                        if ($antwoord1 =~ m/OK ordernr/ ) {
                                              my $ret = sql_toegang_agresso->update_completed_hospi_verkoopsorder_gemaakt($dbh,$voucher_no,$assurcard_invoice_nr,$klant,$contract) ;
                                              my $historiek_gkd = $main::teksten_GKD->{GKD_teksten}->{AUTOMATISCHE_TEKSTEN}->{HOSP}->{tekst} if ($antwoord1 =~ m/OK ordernr/ );
                                              my $staat_er_al_in = 'nee';
                                              $staat_er_al_in = as400_gegevens->lees_history_gkd_agresso_order($historiek_gkd) ;
                                              as400_gegevens->zet_history_gkd_in ($historiek_gkd)  if (defined $historiek_gkd and $historiek_gkd ne '' and $staat_er_al_in eq 'nee');
                                           }    
                                         voor_en_nazorg_naar_agresso->welke_nomenclaturen_zijn_voor_en_nazorg;
                                         my ($returncode,$ReturnText) = voor_en_nazorg_naar_agresso->save_Voor_en_Nazorg;
                                         Wx::MessageBox("$ReturnText\n code: $returncode", 
                                            _T("Voor en Nazorg Opgeslagen"), 
                                            wxOK|wxCENTRE, 
                                            $frame
                                           );
                                         ambulante_zorgen_ernstige_ziekten_naar_agresso->welke_nomenclaturen_zijn_ambulante_zorgen_ernstige_ziekten;
                                        ($returncode,$ReturnText) = ambulante_zorgen_ernstige_ziekten_naar_agresso->save_ambulante_zorgen_ernstige_ziekten;
                                        Wx::MessageBox("$ReturnText\n code: $returncode", 
                                            _T("AMBULANTE ZORGEN EN ERNSTIGE ZIEKTE OPSLAAN"), 
                                            wxOK|wxCENTRE, 
                                            $frame
                                           );
                                           
                                       }elsif  ($contract eq uc $verzprod3 and substr ($completed,3,1) ne '1' and substr($completed_moet_zijn,3,1) eq '1' ) {
                                        my $antwoord1 = package_invoice_to_agresso->maak_hospi_plus_tussenkomst ($frame);                                 
                                        Wx::MessageBox( _T("$antwoord1\n$contract"), 
                                            _T("Hospi teruggave aan de klant"), 
                                            wxOK|wxCENTRE, 
                                            $frame
                                           );
                                        if ($antwoord1 =~ m/OK ordernr/ ) {
                                            my $ret = sql_toegang_agresso->update_completed_hospi_verkoopsorder_gemaakt($dbh,$voucher_no,$assurcard_invoice_nr,$klant,$contract);
                                            my $historiek_gkd = $main::teksten_GKD->{GKD_teksten}->{AUTOMATISCHE_TEKSTEN}->{HOSP}->{tekst};            
                                            my $staat_er_al_in = 'nee';
                                            $staat_er_al_in = as400_gegevens->lees_history_gkd_agresso_order($historiek_gkd) ;
                                            as400_gegevens->zet_history_gkd_in ($historiek_gkd)  if (defined $historiek_gkd and $historiek_gkd ne '' and $staat_er_al_in eq 'nee' );
                                           }
                                        voor_en_nazorg_naar_agresso->welke_nomenclaturen_zijn_voor_en_nazorg;
                                        my ($returncode,$ReturnText) = voor_en_nazorg_naar_agresso->save_Voor_en_Nazorg;
                                         Wx::MessageBox("$ReturnText\n code: $returncode", 
                                            _T("Voor en Nazorg Opgeslagen"), 
                                            wxOK|wxCENTRE, 
                                            $frame
                                           );
                                         ambulante_zorgen_ernstige_ziekten_naar_agresso->welke_nomenclaturen_zijn_ambulante_zorgen_ernstige_ziekten;
                                        ($returncode,$ReturnText) = ambulante_zorgen_ernstige_ziekten_naar_agresso->save_ambulante_zorgen_ernstige_ziekten;
                                        Wx::MessageBox("$ReturnText\n code: $returncode", 
                                            _T("AMBULANTE ZORGEN EN ERNSTIGE ZIEKTE OPSLAAN"), 
                                            wxOK|wxCENTRE, 
                                            $frame
                                           );
                                       }elsif  ($contract eq uc $verzprod4 and substr ($completed,4,1) ne '1' and substr($completed_moet_zijn,4,1) eq '1' ) {
                                        my $antwoord1 = package_invoice_to_agresso->maak_hospi_plus_tussenkomst ($frame);                                 
                                        Wx::MessageBox( _T("$antwoord1\n$contract"), 
                                            _T("Hospi teruggave aan de klant"), 
                                            wxOK|wxCENTRE, 
                                            $frame
                                           );
                                        if ($antwoord1 =~ m/OK ordernr/ ) {
                                            my $ret = sql_toegang_agresso->update_completed_hospi_verkoopsorder_gemaakt($dbh,$voucher_no,$assurcard_invoice_nr,$klant,$contract) ;
                                            my $historiek_gkd = $main::teksten_GKD->{GKD_teksten}->{AUTOMATISCHE_TEKSTEN}->{HOSP}->{tekst} ;
                                            my $staat_er_al_in = 'nee';
                                            $staat_er_al_in = as400_gegevens->lees_history_gkd_agresso_order($historiek_gkd) ;
                                            as400_gegevens->zet_history_gkd_in ($historiek_gkd)  if (defined $historiek_gkd and $historiek_gkd ne '' and $staat_er_al_in eq 'nee');
                                           } 
                                        voor_en_nazorg_naar_agresso->welke_nomenclaturen_zijn_voor_en_nazorg;
                                        my ($returncode,$ReturnText) = voor_en_nazorg_naar_agresso->save_Voor_en_Nazorg;
                                        Wx::MessageBox("$ReturnText\n code: $returncode", 
                                            _T("Voor en Nazorg Opgeslagen"), 
                                            wxOK|wxCENTRE, 
                                            $frame
                                           );
                                        ambulante_zorgen_ernstige_ziekten_naar_agresso->welke_nomenclaturen_zijn_ambulante_zorgen_ernstige_ziekten;
                                        ($returncode,$ReturnText) = ambulante_zorgen_ernstige_ziekten_naar_agresso->save_ambulante_zorgen_ernstige_ziekten;
                                        Wx::MessageBox("$ReturnText\n code: $returncode", 
                                            _T("AMBULANTE ZORGEN EN ERNSTIGE ZIEKTE OPSLAAN"), 
                                            wxOK|wxCENTRE, 
                                            $frame
                                           );
                                       }elsif  ($contract eq uc $verzprod5 and substr ($completed,5,1) ne '1' and substr($completed_moet_zijn,5,1) eq '1' ) {
                                        my $antwoord1 = package_invoice_to_agresso->maak_hospi_plus_tussenkomst ($frame);                                 
                                        Wx::MessageBox( _T("$antwoord1\n$contract"), 
                                            _T("Hospi teruggave aan de klant"), 
                                            wxOK|wxCENTRE, 
                                            $frame
                                           );
                                        if ($antwoord1 =~ m/OK ordernr/ ) {
                                            my $ret = sql_toegang_agresso->update_completed_hospi_verkoopsorder_gemaakt($dbh,$voucher_no,$assurcard_invoice_nr,$klant,$contract) ;
                                            my $historiek_gkd = $main::teksten_GKD->{GKD_teksten}->{AUTOMATISCHE_TEKSTEN}->{HOSP}->{tekst} if ($antwoord1 =~ m/OK ordernr/ );            
                                            my $staat_er_al_in = 'nee';
                                            $staat_er_al_in = as400_gegevens->lees_history_gkd_agresso_order($historiek_gkd) ;
                                            as400_gegevens->zet_history_gkd_in ($historiek_gkd)  if (defined $historiek_gkd and $historiek_gkd ne '' and $staat_er_al_in eq 'nee');
                                           }
                                         voor_en_nazorg_naar_agresso->welke_nomenclaturen_zijn_voor_en_nazorg;
                                         my ($returncode,$ReturnText) = voor_en_nazorg_naar_agresso->save_Voor_en_Nazorg;
                                         Wx::MessageBox("$ReturnText\n code: $returncode", 
                                            _T("Voor en Nazorg Opgeslagen"), 
                                            wxOK|wxCENTRE, 
                                            $frame
                                           );
                                         ambulante_zorgen_ernstige_ziekten_naar_agresso->welke_nomenclaturen_zijn_ambulante_zorgen_ernstige_ziekten;
                                        ($returncode,$ReturnText) = ambulante_zorgen_ernstige_ziekten_naar_agresso->save_ambulante_zorgen_ernstige_ziekten;
                                        Wx::MessageBox("$ReturnText\n code: $returncode", 
                                            _T("AMBULANTE ZORGEN EN ERNSTIGE ZIEKTE OPSLAAN"), 
                                            wxOK|wxCENTRE, 
                                            $frame
                                           );
                                       }else {
                                        Wx::MessageBox( _T("Onderstaande Verzekering moet nog gedaan:\n$tekst"), 
                                            _T("Hospi teruggave aan de klant"), 
                                            wxOK|wxCENTRE, 
                                            $frame
                                           );
                                      
                                       }
                                   }else {
                                        Wx::MessageBox( _T("Factuur afgewerkt"), 
                                            _T("Hospi teruggave aan de klant"), 
                                            wxOK|wxCENTRE, 
                                            $frame
                                           );   
                                    }
                                    
                                    
                                   
                               }
                            sql_toegang_agresso->disconnect_mssql($dbh);
                           }else {
                             my $klant = $main::klant->{Agresso_nummer};
                             if ($klant < 100) {
                                 Wx::MessageBox( _T("Gelieve een klant te kiezen"), 
                                    _T("Factuur Opslaan"), 
                                    wxOK|wxCENTRE, 
                                    $frame
                                   );
                               }else {
                                if ($volgnr_contract eq '') {
                                    Wx::MessageBox( _T("Gelieve een verzekering te kiezen"), 
                                        _T("Factuur Opslaan"), 
                                        wxOK|wxCENTRE, 
                                        $frame
                                       );
                                   }else {
                                     my $antwoord1 = package_invoice_to_agresso->maak_hospi_plus_Handmatige_tussenkomst ($klant);
                                     Wx::MessageBox( _T("$antwoord1\n$contract"), 
                                            _T("Hospi teruggave aan de klant"), 
                                            wxOK|wxCENTRE, 
                                            $frame
                                           );
                                     my $zet_HOSPI_tekst_in_het_gkd = 'nee';
                                     if ($antwoord1 =~ m/OK ordernr/ )  {
                                         $zet_HOSPI_tekst_in_het_gkd = 'ja';
                                         my $historiek_gkd = $main::teksten_GKD->{GKD_teksten}->{AUTOMATISCHE_TEKSTEN}->{HOSP}->{tekst};            
       #                                  my $staat_er_al_in = 'nee';
       #			                       $staat_er_al_in = as400_gegevens->lees_history_gkd_agresso_order($historiek_gkd) ;
       #                                  as400_gegevens->zet_history_gkd_in ($historiek_gkd)  if (defined $historiek_gkd and $historiek_gkd ne ''  and $staat_er_al_in eq 'nee');
                                         voor_en_nazorg_naar_agresso->welke_nomenclaturen_zijn_voor_en_nazorg;
                                         my ($returncode,$ReturnText) = voor_en_nazorg_naar_agresso->save_Voor_en_Nazorg;
                                          $zet_HOSPI_tekst_in_het_gkd = 'nee' if ($ReturnText ne "geen voor en nazorg");
                                         Wx::MessageBox("$ReturnText\n code: $returncode", 
                                            _T("Voor en Nazorg Opgeslagen"), 
                                            wxOK|wxCENTRE, 
                                            $frame
                                           );
                                         ambulante_zorgen_ernstige_ziekten_naar_agresso->welke_nomenclaturen_zijn_ambulante_zorgen_ernstige_ziekten;
                                        ($returncode,$ReturnText) = ambulante_zorgen_ernstige_ziekten_naar_agresso->save_ambulante_zorgen_ernstige_ziekten;
                                        $zet_HOSPI_tekst_in_het_gkd = 'nee' if ($ReturnText ne "geen AMB of ernstige ziekte");
                                        Wx::MessageBox("$ReturnText\n code: $returncode", 
                                            _T("AMBULANTE ZORGEN EN ERNSTIGE ZIEKTE OPSLAAN"), 
                                            wxOK|wxCENTRE, 
                                            $frame
                                           );
                                         if ($zet_HOSPI_tekst_in_het_gkd eq 'ja') {
                                            my $historiek_gkd = $main::teksten_GKD->{GKD_teksten}->{AUTOMATISCHE_TEKSTEN}->{HOSP}->{tekst};
                                            my $staat_er_al_in = 'nee';
                                            $staat_er_al_in = as400_gegevens->lees_history_gkd_agresso_order($historiek_gkd) ;
                                            as400_gegevens->zet_history_gkd_in ($historiek_gkd)  if (defined $historiek_gkd and $historiek_gkd ne '' and $staat_er_al_in eq 'nee');
                                           }
                                        #clear
                                               #package_clear->clear_overzichts_matrix;                               
                                               ##undef %main::overzicht_per_nomenclatuur;
                                               #package_clear->clear_overzicht_per_nomenclatuur;
                                               ##my %test = %main::overzicht_per_nomenclatuur;
                                               #Lid_Opname_Verzekering->Verzekering_periode;
                                               #$main::begindatum_opname = '';
                                               #$main::einddatum_opname =  '';
                                               #$frame->{lov_Txt_0_Begin_Opname}->SetValue($main::begindatum_opname);
                                               #$frame->{lov_Txt_0_Eind_Opname}->SetValue($main::einddatum_opname);
                                               #$main::hospi_tussenkomst=0;
                                               #$main::verschil=0;
                                               #$frame->{lov_Txt_Hospi_Tussenkomst}->SetValue($main::hospi_tussenkomst);
                                               #$frame->{lov_Txt_Verschil}->SetValue($main::verschil);
                                               #$frame->{lov_choice_dienst}->SetStringSelection('0');
                                               #$main::dienst='';
                                               #for (my $i=0; $i < 4; $i++) {
                                               #    $main::contracts_check[$i] = 0;
                                               #    $main::contract_gekozen=0;
                                               #    $frame->{"lov_chk_$i\_Contract"}->SetValue($main::contracts_check[0]);
                                               #   }
                                               #for (my $i=0; $i < 6; $i++) {
                                               #    $frame->{"lov_chk_$i\_Factuur"}->SetValue(0);
                                               #    $main::invoices_check[$i] = 0;
                                               #   }
                                        &Reset($main::frame,'');
                                       }
                                   }
                               }
                           }
                    }
                    print '';
                }
                    print "";
            }
          
        }
     sub kies_klant {
          my($frame, $event) = @_;
          #$main::klant->{ziekten}->[$nr]->{verzekering} = $frame->{Toolbar_choice_leden_met_assurcard_facturen}->GetStringSelection();
          if ($main::Verwerk_Assurcard_Facturen == 1) {
             #$main::klanten_met_assurcard_facturen_teller=$frame->{Toolbar_choice_leden_met_assurcard_facturen}->GetSelection();
	      my $geselecteerde_klant = $frame->{Toolbar_choice_leden_met_assurcard_facturen}->GetStringSelection();
          undef $main::dienst;
          $main::frame->{lov_choice_dienst}->SetSelection(wxNOT_FOUND);
	     for (my $i =0;$i < $main::aantal_klanten_met_facturen;$i++) {
		 if ($geselecteerde_klant ==  $main::klanten_met_assurcard_facturen_niet_gesorteerd[$i]) {
		     $main::klanten_met_assurcard_facturen_teller = $i;
		     last;
		 }
		 
	     }	   
             for (my $i=0; $i < 6; $i++) {
                 $main::invoices[$i] ='';
                 $main::invoices_check[$i] = 0;
                 $frame->{"lov_Txt_$i\_Factuur"}->SetValue($main::invoices[$i]);
                 $frame->{"lov_chk_$i\_Factuur"}->SetValue($main::invoices_check[$i]);
                }
             my $vorige_klant  =Lid_Opname_Verzekering->Agresso_Nummer_verwerk_facturen($frame); 
          }
     }
     sub kies_klant_niet_gesorteerd {
          my($frame, $event) = @_;
          #$main::klant->{ziekten}->[$nr]->{verzekering} = $frame->{Toolbar_choice_leden_met_assurcard_facturen}->GetStringSelection();
          if ($main::Verwerk_Assurcard_Facturen == 1) {
             my $geselecteerde_klant = $frame->{Toolbar_choice_leden_met_assurcard_facturen_niet_gesorteerd}->GetStringSelection();
             undef $main::dienst;
             $main::frame->{lov_choice_dienst}->SetSelection(wxNOT_FOUND);
	     for (my $i =0;$i < $main::aantal_klanten_met_facturen;$i++) {
		 if ($geselecteerde_klant ==  $main::klanten_met_assurcard_facturen_niet_gesorteerd[$i]) {
		     $main::klanten_met_assurcard_facturen_teller = $i;
		     last;
		 }
		 
	     }	   
             for (my $i=0; $i < 6; $i++) {
                 $main::invoices[$i] ='';
                 $main::invoices_check[$i] = 0;
                 $frame->{"lov_Txt_$i\_Factuur"}->SetValue($main::invoices[$i]);
                 $frame->{"lov_chk_$i\_Factuur"}->SetValue($main::invoices_check[$i]);
                }
             my $vorige_klant  =Lid_Opname_Verzekering->Agresso_Nummer_verwerk_facturen($frame); 
          }
     }
     sub vorige_klant_met_factuur {
         my($frame, $event) = @_;
         #my $id =$event->GetId;
         if ($main::Verwerk_Assurcard_Facturen == 1) {
             my $klant_teller = $main::klanten_met_assurcard_facturen_teller ;
             if ($klant_teller >  0) {
                 $main::klanten_met_assurcard_facturen_teller -=1;
                 #clear block facturen
                 for (my $i=0; $i < 6; $i++) {
                     $main::invoices[$i] ='';
                     $main::invoices_check[$i] = 0;
                     $frame->{"lov_Txt_$i\_Factuur"}->SetValue($main::invoices[$i]);
                     $frame->{"lov_chk_$i\_Factuur"}->SetValue($main::invoices_check[$i]);
                    }
                 my $vorige_klant  =Lid_Opname_Verzekering->Agresso_Nummer_verwerk_facturen($frame);
                }
            }else {
              Wx::MessageBox( _T("Werkt niet bij handmatige invoer"), 
                  _T("Vorige klant met factuur"), 
                   wxOK|wxCENTRE, 
                   $frame
               );
            }
         
     }
     sub volgende_klant_met_factuur {
         my($frame, $event) = @_;
         if ($main::Verwerk_Assurcard_Facturen == 1) {
             my $klant_teller = $main::klanten_met_assurcard_facturen_teller ;
             my $max_teller = $main::aantal_klanten_met_facturen-1;
             if ($klant_teller < $max_teller) {
                 $main::klanten_met_assurcard_facturen_teller +=1;
                 #clear block facturen
                 for (my $i=0; $i < 6; $i++) {
                     $main::invoices[$i] ='';
                     $main::invoices_check[$i] = 0;
                     $frame->{"lov_Txt_$i\_Factuur"}->SetValue($main::invoices[$i]);
                     $frame->{"lov_chk_$i\_Factuur"}->SetValue($main::invoices_check[$i]);
                    }
                 my $volgende_klant  =Lid_Opname_Verzekering->Agresso_Nummer_verwerk_facturen($frame);
                }
              }else {
              Wx::MessageBox( _T("Werkt niet bij handmatige invoer"), 
                  _T("Volgende klant met factuur"), 
                   wxOK|wxCENTRE, 
                   $frame
               );
            }
         
     }
     sub haal_factuur_op {
         my($frame, $event) = @_;
         if ($main::Verwerk_Assurcard_Facturen == 1) {
            # my $agresso_nr =$main::klanten_met_assurcard_facturen[$main::klanten_met_assurcard_facturen_teller];
	     my $agresso_nr =  $main::klanten_met_assurcard_facturen_niet_gesorteerd[$main::klanten_met_assurcard_facturen_teller];
             my $test =$main::klanten_met_assurcard_facturen_rijksregnr;
             my $rijksregnr = $main::klanten_met_assurcard_facturen_rijksregnr->{$agresso_nr};
             my $ophalen_facturen =package_agresso_get_calculater_info->agresso_get_invoice_info($agresso_nr,$rijksregnr);
             if ($ophalen_facturen =~ m/AGRESSO NOK/) {
                 Wx::MessageBox("$ophalen_facturen", 
                  _T("Factuur ophalen"), 
                   wxOK|wxCENTRE, 
                   $frame
               );
             }
             
             for (my $i=0; $i < 6; $i++) {
                 $frame->{"lov_Txt_$i\_Factuur"}->SetValue($main::invoices[$i]);
                 $frame->{"lov_chk_$i\_Factuur"}->SetValue($main::invoices_check[$i]);
                }
             }else {
              Wx::MessageBox( _T("Werkt niet bij handmatige invoer"), 
                  _T("Factuur ophalen"), 
                   wxOK|wxCENTRE, 
                   $frame
               );
            } 
        }
     
     sub verwerk_factuur {
         my($frame, $event) = @_;
         #package_clear->clear_overzicht_per_nomenclatuur;
         #package_clear->clear_overzichts_matrix;
         my $vandaag = ParseDate("today");
         $vandaag = substr ($vandaag,0,8);
         #my $testa = $main::klant;
         #my $testb = $main::invoice;
         #my @testc = @main::invoices;
         if ($main::Verwerk_Assurcard_Facturen == 1) {
             package_clear->clear_overzichts_matrix;
             #my $agresso_nr =$main::klanten_met_assurcard_facturen[$main::klanten_met_assurcard_facturen_teller];
            my $agresso_nr =  $main::klanten_met_assurcard_facturen_niet_gesorteerd[$main::klanten_met_assurcard_facturen_teller];
             my $is_er_een_factuur_aangevinkt = 0;
             my $factuur_nummer = -1;
             #my $ftest = $main::invoice;
             #my $ftest2;
             my @chk = @main::invoices_check;
             #my $nomenclaturen;
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
                 #kies contracten die opportuun zijn 
                 my $contracten = $main::klant->{contracten};
               
                 #plaatsen factuur
                 print "";
                 
                 undef $main::overzicht_per_nomenclatuur;
                 #foreach my $nom_cla (keys %main::type_grid) {
                 #     if ($main::type_grid{$nom_cla} eq 'VnZ') {
                 #        #Voor_na_zorg_Grid->Toolbar_Herbereken($main::grid_VnZ,$nom_cla);
                 #        Voor_na_zorg_GridApp->refresh_grid($main::grid_VnZ_refresh,$nom_cla);
                 #       }
                 #     if ($main::type_grid{$nom_cla} eq 'Default') {
                 #        #Detail_Grid->Toolbar_Herbereken($main::grid_Default,$nom_cla);
                 #        Detail_GridApp->refresh_grid($main::grid_Detail,$nom_cla);
                 #       }
                 #   }
                 #beginen eiddatum
                 my $begindatum = 99999999;
                 my $einddatum = 0;
                 my $test_inv =$main::invoice;
                 my $test_inv_f =$main::invoice->{$factuur_nummer};
                 foreach my $nr (sort keys $main::invoice->{$factuur_nummer}){
                     $begindatum = $main::invoice->{$factuur_nummer}->{$nr}->{begindatum} if ($main::invoice->{$factuur_nummer}->{$nr}->{begindatum} < $begindatum and $main::invoice->{$factuur_nummer}->{$nr}->{begindatum} > 0);
                     $einddatum = $main::invoice->{$factuur_nummer}->{$nr}->{einddatum} if ($main::invoice->{$factuur_nummer}->{$nr}->{einddatum} >$einddatum  );
                    }
                 $main::einddatum_opname = $einddatum;
                 $frame->{lov_Txt_0_Eind_Opname}->SetValue($main::einddatum_opname);
                 $main::begindatum_opname = $begindatum;
                 $frame->{lov_Txt_0_Begin_Opname}->SetValue($main::begindatum_opname);
                 my $beginjaar = substr($begindatum,0,4);
                 my $periode = "periode_$beginjaar"."0101-$beginjaar"."1231";
                 @main::verzekeringen_in_xml = ();
                 my $test = $main::instelingen;
                 eval { foreach my $verzekering (keys $main::instelingen->{$periode}->{verzekeringen}) {}};
                 if (!$@) {
                     foreach my $verzekering (keys $main::instelingen->{$periode}->{verzekeringen}) {
                         push (@main::verzekeringen_in_xml,uc($verzekering)); 
                        }
                    }else {
                     Wx::MessageBox( _T("Er klopt iets niet met de periode\n$periode"), 
                                                        _T("Waarschuwing !!!"), 
                                                        wxOK|wxCENTRE, 
                                                        $frame
                                            );#code
                     $beginjaar = substr($vandaag,0,4);
                     $periode = "periode_$beginjaar"."0101-$beginjaar"."1231";
                     $begindatum = $beginjaar."0101";
                     $einddatum = $beginjaar."0101";
                     $main::begindatum_opname = $begindatum;
                     $main::einddatum_opname = $einddatum;
                     foreach my $verzekering (keys $main::instelingen->{$periode}->{verzekeringen}) {
                         push (@main::verzekeringen_in_xml,uc($verzekering)); 
                        }
                      Wx::MessageBox( _T("We nemen\n$periode"), 
                                                        _T("Waarschuwing !!!"), 
                                                        wxOK|wxCENTRE, 
                                                        $frame
                                            );#code
                    }
                 #my @testverz = @main::verzekeringen_in_xml;
                 #opzoeken welk contracten geldig zijn
                 my $verzprod1 = '';
                 my $verzprod2 = '';
                 my $verzprod3 = '';
                 my $verzprod4 = '';
                 my $verzprod5 = '';
                 my $contracteller = 2; #$verzprod1 = altijd ASSURCARD
                 foreach my $nr1 (keys $main::klant->{contracten}) {
                     if ($main::klant->{contracten}->[$nr1]->{contract_nr} > 0) {
                         my $contract_eindatum = $main::klant->{contracten}->[$nr1]->{einddatum};
                         my $contract_wachtdatum = $main::klant->{contracten}->[$nr1]->{wachtdatum};
                         my ($contract_einddag,$contract_eindmaand,$contract_eindjaar) = split (/\//,$contract_eindatum);
                         my ($contract_wachtdag,$contract_wachtmaand,$contract_wachtjaar) = split (/\//,$contract_wachtdatum);
                         $contract_wachtdatum =$contract_wachtjaar*10000+$contract_wachtmaand*100+$contract_wachtdag;
                         $contract_eindatum = $contract_eindjaar*10000+$contract_eindmaand*100+$contract_einddag;
                         if ($begindatum <= $contract_eindatum and $begindatum >=$contract_wachtdatum ) {
                             #geldig contract
                             if (($main::klant->{contracten}->[$nr1]->{naam} ~~ @main::verzekeringen_in_xml)) {
                                  $verzprod1 =$main::klant->{contracten}->[$nr1]->{naam} if ($contracteller == 1 ) ;
                                  $verzprod2 =$main::klant->{contracten}->[$nr1]->{naam} if ($contracteller == 2 ) ;
                                  $verzprod3 =$main::klant->{contracten}->[$nr1]->{naam} if ($contracteller == 3 ) ;
                                  $verzprod4 =$main::klant->{contracten}->[$nr1]->{naam} if ($contracteller == 4 ) ;
                                  $verzprod5 =$main::klant->{contracten}->[$nr1]->{naam} if ($contracteller == 5) ;
                                 $contracteller += 1;#code  
                                }
                            }
                        }
                    }
                 #$verzprod2 moet assurcard zijn en verzekering niet in de loop laatst 
                 my @test=@main::verzekeringen_met_kaart;
                 if (uc $verzprod2 ~~ @main::verzekeringen_met_kaart  ) {
                     #doe niets is ok
                    }else {
                     if (uc $verzprod3 ~~ @main::verzekeringen_met_kaart ) {
                         my $onthoud =$verzprod2;
                         $verzprod2 =  $verzprod3;
                         $verzprod3 = $onthoud;
                        }else {
                         if (uc $verzprod4 ~~ @main::verzekeringen_met_kaart ) {
                             my $onthoud =$verzprod2;
                             $verzprod2 =  $verzprod4;
                             $verzprod4 = $onthoud;
                            }else {
                             if (uc $verzprod5 ~~ @main::verzekeringen_met_kaart ) {
                                 my $onthoud =$verzprod2;
                                 $verzprod2 =  $verzprod5;
                                 $verzprod5 = $onthoud;
                                }else {
                                   Wx::MessageBox( _T("Geen verzekring met Assurcard\n"), 
                                                        _T("Waarschuwing"), 
                                                        wxOK|wxCENTRE, 
                                                        $frame
                                            );#code
                                }
                            }
                         
                        }
                     
                    }
                 if (uc $verzprod3 ~~ @main::verzekeringen_niet_in_de_loop and ($verzprod4 ne '' and defined $verzprod4)) { #verzekering niet in de loop laatst 
                        my $onthoud =$verzprod3;
                        $verzprod3 = $verzprod4;
                        $verzprod4 = $onthoud;
                 }
                 if (uc $verzprod4 ~~ @main::verzekeringen_niet_in_de_loop and ($verzprod5 ne '' and defined $verzprod5)) {
                        my $onthoud =$verzprod4;
                        $verzprod4 = $verzprod5;
                        $verzprod5 = $onthoud;
                 }
                 #is deze factuur al in zgt_mark_invoices
                 my $dbh = sql_toegang_agresso->setup_mssql_connectie;
                 my $voucher_no = $main::invoices_zgt_mark_invoices->{$factuur_nummer}->{voucher_no};
                 my ($completed,$last_update,$voucher_no_db) = sql_toegang_agresso->check_off_line_exists($dbh,$voucher_no,$factuur_nummer,$agresso_nr );#my ($dbh,$voucher_no,$ext_inv_ref,$apar_id) =  @_;
                 $last_update = substr ($last_update,0,10);
                 $last_update =~ s/-//g;
                 
                 
                 
                 
                
                 
                 if ($completed eq '') {
                     my $result = sql_toegang_agresso->insert_invoice_in_zgt_mark_invoices ($dbh,$voucher_no,$factuur_nummer,$agresso_nr,$verzprod2,$verzprod3,$verzprod4,$verzprod5)  ;#($dbh,$voucher_no,$ext_inv_ref,$apar_id,$verzprod2,$verzprod3,$verzprod4,$verzprod5) 
                     $main::zgt_mark_invoice_welke_factuur_we_behandelen =$voucher_no;
                     my $verzekering_gevonden =0;
                     if ($verzprod2 ne '') {
                         
                         foreach my $nr (keys $main::klant->{contracten}) {
                             if (uc $main::klant->{contracten}->[$nr]->{naam} eq uc $verzprod2) {
                                 for (my $i=0; $i < 4; $i++) {
                                     $main::contracts_check[$i] = 0;
                                     $main::contract_gekozen=0;
                                    }
                                 my $contract_naam = $main::klant->{contracten}->[$nr]->{naam} ;
                                 my $contract_eindatum = $main::klant->{contracten}->[$nr]->{einddatum};
                                 my $contract_wachtdatum =  $main::klant->{contracten}->[$nr]->{wachtdatum};
                                 my ($contract_einddag,$contract_eindmaand,$contract_eindjaar) = split (/\//,$contract_eindatum);
                                 my ($contract_wachtdag,$contract_wachtmaand,$contract_wachtjaar) = split (/\//,$contract_wachtdatum);
                                 $contract_wachtdatum =$contract_wachtjaar*10000+$contract_wachtmaand*100+$contract_wachtdag;
                                 $contract_eindatum = $contract_eindjaar*10000+$contract_eindmaand*100+$contract_einddag;
                                 if ($begindatum >= $contract_wachtdatum and $begindatum <= $contract_eindatum and $contract_naam eq $verzprod2) {
                                     $main::contracts_check[$nr] =1;
                                     #my @testa1 = @main::contracts_check;
                                     $verzekering_gevonden = 1;
                                     $main::contract_gekozen=1;
                                     last;
                                    }
                                }
                            }
                        }
                     if ($verzekering_gevonden == 0){
                          Wx::MessageBox( _T("Deze klant heeft geen verzekering ?"), 
                             _T("Opgepast !!!!"), 
                             wxOK|wxCENTRE, 
                             $frame
                            );
                        }else {
                         $main::frame->{lov_chk_0_Contract}->SetValue($main::contracts_check[0]);
                         $main::frame->{lov_chk_1_Contract}->SetValue($main::contracts_check[1]);
                         $main::frame->{lov_chk_2_Contract}->SetValue($main::contracts_check[2]);
                         $main::frame->{lov_chk_3_Contract}->SetValue($main::contracts_check[3]);
                         my $naam_verzekering2 ='';
                         for (my $i=0; $i < 4; $i++) {
                             if ($main::contracts_check[$i] == 1) {
                                 $naam_verzekering2 = lc ($main::klant->{contracten}->[$i]->{naam});
                                }
                            }
                         Lid_Opname_Verzekering->Verzekering_periode;
                         my $nomenclaturen_verwerk = &vul_grid_in($factuur_nummer);
                         package_get_K_D_jaar->agresso_get_K_D_jaar($agresso_nr,$beginjaar,$naam_verzekering2);
                         package_get_K_altijd->agresso_get_K_altijd($agresso_nr,$naam_verzekering2);
                         #my $test = $main::dienst;
                         if ($main::dienst ~~ @main::diensten) {
                             $main::frame->{lov_choice_dienst}->SetStringSelection($main::dienst);
                             Lid_Opname_Verzekering->keuze($main::frame->{lov_choice_dienst});
                         }
                         print "";
                            eval {foreach my $nom (keys $nomenclaturen_verwerk) {}};
                            if (!$@) {
                                foreach my $nom (keys $nomenclaturen_verwerk) {
                                   print "$nom\n";
                                   if ($nomenclaturen_verwerk->{$nom} eq 'Default') {
                                   Detail_Grid->Toolbar_Herbereken($main::grid_Default,$nom);
                                   Detail_GridApp->refresh_grid($main::grid_Detail,$nom);
                                      }
                                   if ($nomenclaturen_verwerk->{$nom} eq 'VnZ') {
                                   Voor_na_zorg_Grid->Toolbar_Herbereken($main::grid_VnZ,$nom);
                                   Voor_na_zorg_GridApp->refresh_grid($main::grid_VnZ_refresh,$nom);
                                      }
                               }
                            }
			 
                         
                        }
                    }elsif (($completed == 0 or $completed >= 100000) and $voucher_no_db != $main::zgt_mark_invoice_welke_factuur_we_behandelen and $last_update == $vandaag ) {
                      Wx::MessageBox( _T("Dit factuur wordt al door iemand anders behandeld"), 
                         _T("Verwerk Factuur"), 
                         wxOK|wxCENTRE, 
                         $frame
                        );
                     undef $main::overzicht_per_nomenclatuur;
                    }elsif (($completed == 0 or $completed >= 100000) and $voucher_no_db != $main::zgt_mark_invoice_welke_factuur_we_behandelen and $last_update < $vandaag ) {
                       sql_toegang_agresso->set_last_update_to_today($dbh,$voucher_no,$factuur_nummer,$agresso_nr );
                       $main::zgt_mark_invoice_welke_factuur_we_behandelen = $voucher_no_db;
                       my $volgende_verzekering = '';
                       my $volgende_verzekering_gekozen = 0;
                       if ($completed >= 100000) {
                         my $tekst = "";
                         my ($completed,$verzprod1,$verzprod2,$verzprod3,$verzprod4,$verzprod5) =  sql_toegang_agresso->check_what_is_completed($dbh,$voucher_no,$factuur_nummer,$agresso_nr);
                         $tekst = $tekst."$verzprod1 \n" if ($verzprod1 ne '' and substr ($completed,1,1) ne '1');
                         if ($verzprod2 ne '' and substr ($completed,2,1) ne '1') {
                             $tekst = $tekst."$verzprod2 \n";
                             if ($volgende_verzekering_gekozen == 0) {
                                  $volgende_verzekering =  $verzprod2 ;#code
                                  $volgende_verzekering_gekozen = 1;
                                }
                            }
                         if ($verzprod3 ne '' and substr ($completed,3,1) ne '1') {
                             $tekst = $tekst."$verzprod3 \n" ;
                             if ($volgende_verzekering_gekozen == 0) {
                                  $volgende_verzekering =  $verzprod3 ;#code
                                  $volgende_verzekering_gekozen = 1;
                                }
                            }
                         if ($verzprod4 ne '' and substr ($completed,4,1) ne '1') {
                             $tekst = $tekst."$verzprod4 \n" ;
                             if ($volgende_verzekering_gekozen == 0) {
                                  $volgende_verzekering =  $verzprod4 ;#code
                                  $volgende_verzekering_gekozen = 1;
                                }
                            }
                         if ($verzprod5 ne '' and substr ($completed,5,1) ne '1') {
                             $tekst = $tekst."$verzprod5 \n" ;
                             if ($volgende_verzekering_gekozen == 0) {
                                  $volgende_verzekering =  $verzprod5 ;#code
                                  $volgende_verzekering_gekozen = 1;
                                }
                         }
                         Wx::MessageBox( "$tekst \n -> $volgende_verzekering", 
                             _T("Volgende verzekeringen moeten nog behandeld worden:"), 
                              wxOK|wxCENTRE, 
                             $frame
                            );
                        }else {
                         $volgende_verzekering =  $verzprod2;
                         $volgende_verzekering_gekozen = 1;
                        }
                     my $verzekering_gevonden =0; 
                     foreach my $nr (keys $main::klant->{contracten}) {
                         if (uc $main::klant->{contracten}->[$nr]->{naam} eq uc $volgende_verzekering) {
                             for (my $i=0; $i < 4; $i++) {
                                 $main::contracts_check[$i] = 0;
                                 $main::contract_gekozen=0;
                                }
                             my $contract_eindatum = $main::klant->{contracten}->[$nr]->{einddatum};
                             my $contract_wachtdatum =  $main::klant->{contracten}->[$nr]->{wachtdatum};
                             my ($contract_einddag,$contract_eindmaand,$contract_eindjaar) = split (/\//,$contract_eindatum);
                             my ($contract_wachtdag,$contract_wachtmaand,$contract_wachtjaar) = split (/\//,$contract_wachtdatum);
                             $contract_wachtdatum =$contract_wachtjaar*10000+$contract_wachtmaand*100+$contract_wachtdag;
                             $contract_eindatum = $contract_eindjaar*10000+$contract_eindmaand*100+$contract_einddag;
                             if ($begindatum >= $contract_wachtdatum and $begindatum <= $contract_eindatum) {
                                 $main::contracts_check[$nr] =1;
                                 #my @testa1 = @main::contracts_check;
                                 $verzekering_gevonden =1;
                                 $main::contract_gekozen=1;
                                 last;
                                }
                            }
                        }
                     if ($verzekering_gevonden == 0){
                          Wx::MessageBox( _T("Deze klant heeft geen verzekering meer open ?"), 
                             _T("Opgepast !!!!"), 
                             wxOK|wxCENTRE, 
                             $frame
                            );
                        }else {
                         $main::frame->{lov_chk_0_Contract}->SetValue($main::contracts_check[0]);
                         $main::frame->{lov_chk_1_Contract}->SetValue($main::contracts_check[1]);
                         $main::frame->{lov_chk_2_Contract}->SetValue($main::contracts_check[2]);
                         my $naam_verzekering1 ='';
                         for (my $i=0; $i < 4; $i++) {
                             if ($main::contracts_check[$i] == 1) {
                                 $naam_verzekering1 = lc ($main::klant->{contracten}->[$i]->{naam});
                                 $main::contract_gekozen=1;
                                }
                            }
                         Lid_Opname_Verzekering->Verzekering_periode;
                         my $nomenclaturen_verwerk = &vul_grid_in($factuur_nummer);
                         package_get_K_D_jaar->agresso_get_K_D_jaar($agresso_nr,$beginjaar,$naam_verzekering1);
                         package_get_K_altijd->agresso_get_K_altijd($agresso_nr,$naam_verzekering1);
                         if ($main::dienst ~~ @main::diensten) {
                             $main::frame->{lov_choice_dienst}->SetStringSelection($main::dienst);
                             Lid_Opname_Verzekering->keuze($main::frame->{lov_choice_dienst});
                         }
                          print "";
			 eval {foreach my $nom (keys $nomenclaturen_verwerk) {}};
			 if (!$@) {
			     foreach my $nom (keys $nomenclaturen_verwerk) {
				 #print "$nom\n";
				 if ($nomenclaturen_verwerk->{$nom} eq 'Default') {
				    Detail_Grid->Toolbar_Herbereken($main::grid_Default,$nom);
				    Detail_GridApp->refresh_grid($main::grid_Detail,$nom);
				   }
				 if ($nomenclaturen_verwerk->{$nom} eq 'VnZ') {
				    Voor_na_zorg_Grid->Toolbar_Herbereken($main::grid_VnZ,$nom);
				    Voor_na_zorg_GridApp->refresh_grid($main::grid_VnZ_refresh,$nom);
				   }
                            }#code
			 }
			 
                         
                        }
                    }elsif (($completed == 0 or $completed >= 100000) and $voucher_no_db == $main::zgt_mark_invoice_welke_factuur_we_behandelen and $last_update == $vandaag) {
                     my $volgende_verzekering = '';
                     my $volgende_verzekering_gekozen = 0;   
                     if ($completed >= 100000) {
                         my $tekst = "";
                         my ($completed,$verzprod1,$verzprod2,$verzprod3,$verzprod4,$verzprod5) =  sql_toegang_agresso->check_what_is_completed($dbh,$voucher_no,$factuur_nummer,$agresso_nr);                          
                         $tekst = $tekst."$verzprod1 \n" if ($verzprod1 ne '' and substr ($completed,1,1) ne '1');
                         if ($verzprod2 ne '' and substr ($completed,2,1) ne '1') {
                             $tekst = $tekst."$verzprod2 \n";
                             if ($volgende_verzekering_gekozen == 0) {
                                 $volgende_verzekering =  $verzprod2 ;#code
                                 $volgende_verzekering_gekozen = 1;
                                }
                            }
                         if ($verzprod3 ne '' and substr ($completed,3,1) ne '1') {
                             $tekst = $tekst."$verzprod3 \n" ;
                             if ($volgende_verzekering_gekozen == 0) {
                                 $volgende_verzekering =  $verzprod3 ;#code
                                 $volgende_verzekering_gekozen = 1;
                                }
                            }
                         if ($verzprod4 ne '' and substr ($completed,4,1) ne '1') {
                             $tekst = $tekst."$verzprod4 \n" ;
                             if ($volgende_verzekering_gekozen == 0) {
                                 $volgende_verzekering =  $verzprod4 ;#code
                                 $volgende_verzekering_gekozen = 1;
                                }
                            }
                         if ($verzprod5 ne '' and substr ($completed,5,1) ne '1') {
                             $tekst = $tekst."$verzprod5 \n" ;
                             if ($volgende_verzekering_gekozen == 0) {
                                 $volgende_verzekering =  $verzprod5 ;#code
                                 $volgende_verzekering_gekozen = 1;
                                }
                            }
                         Wx::MessageBox( "$tekst \n -> $volgende_verzekering", 
                             _T("Volgende verzekeringen moeten nog behandeld worden:"), 
                             wxOK|wxCENTRE, 
                             $frame
                            );
                        }else {
                         $volgende_verzekering =  $verzprod2;
                         $volgende_verzekering_gekozen = 1;
                        }
                     my $verzekering_gevonden =0;                     
                     foreach my $nr (keys $main::klant->{contracten}) {
                         if (uc $main::klant->{contracten}->[$nr]->{naam} eq uc $volgende_verzekering) {#$verzprod2
                             for (my $i=0; $i < 4; $i++) {
                                 $main::contracts_check[$i] = 0;
                                 $main::contract_gekozen=0;
                                }
                             my $contract_eindatum = $main::klant->{contracten}->[$nr]->{einddatum};
                             my $contract_wachtdatum =  $main::klant->{contracten}->[$nr]->{wachtdatum};
                             my ($contract_einddag,$contract_eindmaand,$contract_eindjaar) = split (/\//,$contract_eindatum);
                             my ($contract_wachtdag,$contract_wachtmaand,$contract_wachtjaar) = split (/\//,$contract_wachtdatum);
                             $contract_wachtdatum =$contract_wachtjaar*10000+$contract_wachtmaand*100+$contract_wachtdag;
                             $contract_eindatum = $contract_eindjaar*10000+$contract_eindmaand*100+$contract_einddag;
                             if ($begindatum >= $contract_wachtdatum and $begindatum <= $contract_eindatum) {
                                 $main::contracts_check[$nr] =1;
                                 #my @testa1 = @main::contracts_check;
                                 $verzekering_gevonden = 1;
                                 $main::contract_gekozen=1;
                                 last;
                                }
                            }
                        }
                     if ($verzekering_gevonden == 0){
                          Wx::MessageBox( _T("Deze klant heeft geen \nte behandelen \nverzekering meer ?"), 
                             _T("Opgepast !!!!"), 
                             wxOK|wxCENTRE, 
                             $frame
                            );
                        }else {
                         $main::frame->{lov_chk_0_Contract}->SetValue($main::contracts_check[0]);
                         $main::frame->{lov_chk_1_Contract}->SetValue($main::contracts_check[1]);
                         $main::frame->{lov_chk_2_Contract}->SetValue($main::contracts_check[2]);
                         $main::frame->{lov_chk_3_Contract}->SetValue($main::contracts_check[3]);
                         #Lid_Opname_Verzekering->Verzekering_periode;
                         my $naam_verzekering3 ='';
                         for (my $i=0; $i < 3; $i++) {
                             if ($main::contracts_check[$i] == 1) {
                                 $naam_verzekering3 = lc ($main::klant->{contracten}->[$i]->{naam});
                                }
                            }
                         Lid_Opname_Verzekering->Verzekering_periode;
                         my $nomenclaturen_verwerk = &vul_grid_in($factuur_nummer);
                         package_get_K_D_jaar->agresso_get_K_D_jaar($agresso_nr,$beginjaar,$naam_verzekering3);
                         package_get_K_altijd->agresso_get_K_altijd($agresso_nr,$naam_verzekering3);
                         if ($main::dienst ~~ @main::diensten) {
                             $main::frame->{lov_choice_dienst}->SetStringSelection($main::dienst);
                             Lid_Opname_Verzekering->keuze($main::frame->{lov_choice_dienst});
                         }
                         print "";
			 eval { foreach my $nom (keys $nomenclaturen_verwerk) {}};
			 if (!$@) {
			     foreach my $nom (keys $nomenclaturen_verwerk) {
				    print "$nom\n";
				    if ($nomenclaturen_verwerk->{$nom} eq 'Default') {
					Detail_Grid->Toolbar_Herbereken($main::grid_Default,$nom);
					Detail_GridApp->refresh_grid($main::grid_Detail,$nom);
				       }
				    if ($nomenclaturen_verwerk->{$nom} eq 'VnZ') {
					Voor_na_zorg_Grid->Toolbar_Herbereken($main::grid_VnZ,$nom);
					Voor_na_zorg_GridApp->refresh_grid($main::grid_VnZ_refresh,$nom);
				       }
				}
			    }
			 
                        
                        }
                    }elsif ($completed == 1) {
                         Wx::MessageBox( _T("Deze factuur was al volledig behandeld"), 
                             _T("Factuur Opslaan"), 
                             wxOK|wxCENTRE, 
                             $frame
                            );
                    }
                 sql_toegang_agresso->disconnect_mssql($dbh);
                }
            
            }else {
              Wx::MessageBox( _T("Werkt niet bij handmatige invoer"), 
                  _T("Verwerk Factuur"), 
                   wxOK|wxCENTRE, 
                   $frame
               );
             
              
            }  
        }
sub vul_grid_in {
     my ($factuur_nummer) = @_;
     my $nomenclaturen_verwerk;
     my $nomclatuur_rijteller;
     undef $main::dienst ;
     $main::frame->{lov_choice_dienst}->SetSelection(wxNOT_FOUND);
     my $test =  $main::invoice->{$factuur_nummer};
     #test oplichten
     #my $nomenclatuur =882077;
     #$nomclatuur_rijteller->{$nomenclatuur}=0;
     #$main::overzicht_per_nomenclatuur->{$nomenclatuur}[$nomclatuur_rijteller->{$nomenclatuur}][0] = 0 ;#code
     #$main::overzicht_per_nomenclatuur->{$nomenclatuur}[$nomclatuur_rijteller->{$nomenclatuur}][2] = 222 ;
     #$main::overzicht_per_nomenclatuur->{$nomenclatuur}[$nomclatuur_rijteller->{$nomenclatuur}][3] = 0;
     #$main::overzicht_per_nomenclatuur->{$nomenclatuur}[$nomclatuur_rijteller->{$nomenclatuur}][11]=   222;
     #$main::overzicht_per_nomenclatuur->{$nomenclatuur}[$nomclatuur_rijteller->{$nomenclatuur}][12]=   444 ;
     #$main::overzicht_per_nomenclatuur->{$nomenclatuur}[$nomclatuur_rijteller->{$nomenclatuur}][13] = 0;
     #$nomenclaturen_verwerk->{$nomenclatuur}= 'Default' ;
     #einde test
                 foreach my $nr (sort keys $main::invoice->{$factuur_nummer}){
                     my $nomenclatuur = $main::invoice->{$factuur_nummer}->{$nr}->{interne_nomenclatuur};
                     #$begindatum = $main::invoice->{$factuur_nummer}->{$nr}->{begindatum} if ($main::invoice->{$factuur_nummer}->{$nr}->{begindatum} < $begindatum and $main::invoice->{$factuur_nummer}->{$nr}->{begindatum} > 0);
                     #$einddatum = $main::invoice->{$factuur_nummer}->{$nr}->{einddatum} if ($main::invoice->{$factuur_nummer}->{$nr}->{einddatum} >$einddatum  );
                     my $persoonlijke_tussenkomst = $main::invoice->{$factuur_nummer}->{$nr}->{persoonlijke_tussenkomst};
                     my $supplement = $main::invoice->{$factuur_nummer}->{$nr}->{supplement};
                     my $aantal_dagen = $main::invoice->{$factuur_nummer}->{$nr}->{aantal_dagen};
                     my $honderd = $main::invoice->{$factuur_nummer}->{$nr}->{honderd};
                     my $tweehonderd = $main::invoice->{$factuur_nummer}->{$nr}->{tweehonderd};
                     my $dienst = $main::invoice->{$factuur_nummer}->{$nr}->{dienst};
                     $main::dienst = $dienst if ($dienst ne  $main::dienst);
                     if ($persoonlijke_tussenkomst == 0 and $supplement  == 0 and not($nomenclatuur == 882206 or $nomenclatuur == 882000 or $nomenclatuur == 882001)) { #882206 is franchise moeten doorgeteld 882200,882201 dagen moeten doorgezet
                         #doe niets#code
                     }else {
                         if ((defined $nomclatuur_rijteller->{$nomenclatuur}) and $nomclatuur_rijteller->{$nomenclatuur} >= 0) {
                             $nomclatuur_rijteller->{$nomenclatuur} += 1;
                            }else {
                             $nomclatuur_rijteller->{$nomenclatuur} = 0;
                            }
                         #my $test1 = $main::type_grid{$nomenclatuur};
                         #kolom layout gewoon
                         #$grid->SetColLabelValue(0, _T("Dagen"));                            $grid->SetColLabelValue(0, _T("Voor- en Nazorg/Ambulante zorgen"));
                         #$grid->SetColLabelValue(1, _T("Bdrg/dg"));                          $grid->SetColLabelValue(1, _T("M-D-A"));   
                         #$grid->SetColLabelValue(2, _T("P. tsk."));                          $grid->SetColLabelValue(2, _T("Datum"));
                         #$grid->SetColLabelValue(3, _T("Sup."));                             $grid->SetColLabelValue(3, _T("Code"));
                         #$grid->SetColLabelValue(4, _T("Totaal"));                           $grid->SetColLabelValue(4, _T("P. tsk."));
                         #$grid->SetColLabelValue(5, _T("Z. tsk"));                           $grid->SetColLabelValue(5, _T("Z. tsk"));
                         #$grid->SetColLabelValue(6, _T("HP+ tsk"));                          $grid->SetColLabelValue(6, _T("HP+ tsk"));
                         #$grid->SetColLabelValue(7, _T("Verschil"));                         $grid->SetColLabelValue(7, _T("Verschil"));
                         #$grid->SetColLabelValue(8, _T("Regel Toegepast"));                  $grid->SetColLabelValue(8, _T("Datum -$aantal_dagen_voor_begindatum"));
                         #$grid->SetColLabelValue(9, _T("Aanvaard"));                         $grid->SetColLabelValue(9, _T("Datum +$aantal_dagen_na_einddatum"));
                         #$grid->SetColLabelValue(10, _T("Geweigerd"));                       $grid->SetColLabelValue(10, _T("Regel Toegepast"));
                         #$grid->SetColLabelValue(11, _T("100%"));
                         #$grid->SetColLabelValue(12, _T("200%"));
                         #$grid->SetColLabelValue(13, _T("Dienst"));
                         #my %test = %main::type_grid;
                         if ($main::type_grid{$nomenclatuur} eq 'Default') {
                             #grid links
                             $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$nomclatuur_rijteller->{$nomenclatuur}][0] = $aantal_dagen ;#code
                             $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$nomclatuur_rijteller->{$nomenclatuur}][2] = $persoonlijke_tussenkomst ;
                             $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$nomclatuur_rijteller->{$nomenclatuur}][3] = $supplement;
                             $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$nomclatuur_rijteller->{$nomenclatuur}][11]=   $honderd;
                             $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$nomclatuur_rijteller->{$nomenclatuur}][12]=   $tweehonderd ;
                             $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$nomclatuur_rijteller->{$nomenclatuur}][13] = $dienst;
                             $nomenclaturen_verwerk->{$nomenclatuur}= 'Default' ;
                            }elsif ($main::type_grid{$nomenclatuur} eq 'VnZ') {
                             #grid rechts
                             #$main::overzicht_per_nomenclatuur->{$nomenclatuur}[$nomclatuur_rijteller->{$nomenclatuur}][0] = $aantal_dagen ;#code
                             $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$nomclatuur_rijteller->{$nomenclatuur}][4] = $persoonlijke_tussenkomst ;
                             $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$nomclatuur_rijteller->{$nomenclatuur}][5] = $supplement;
                             $nomenclaturen_verwerk->{$nomenclatuur}= 'VnZ' ;
                            }
                                
                             print "";
                        }
                           
                     print "";
                    }
                 #$ftest2 = $main::overzicht_per_nomenclatuur;
                 print "";
                 
      return ($nomenclaturen_verwerk);              
}
    
1;
