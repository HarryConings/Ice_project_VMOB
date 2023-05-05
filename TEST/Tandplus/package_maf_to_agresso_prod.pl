#!/usr/bin/perl -w
require 'Decryp_Encrypt.pl';
#2019-11-04   bugs eruit
#require 'package_cnnectdb.pl';
#OPGELET!!!!!!
#Dit programma is auteursrechtelijk beschermd.
#Deze code is voor 100% eigendom van de Firma  I.C.E. (liebroekstraat 43 3545 Halen BE0446888007) .
#Deze code mag niet aan derden (ook niet VNZ en NZVL) getoond worden tenzij met uitdrukkelijke en schriftelijke toestemming van Hospiplus en I.C.E. bvba .
#Indien dit toch gebeurt is er een boete verschuldigd van 250.000 € exclusief btw aan de Firma  I.C.E.
#Dit geldt ook voor het kopieren van een stuk code of het repliceren van technieken gehanteerd in dit programma
#I.C.E. beheert de broncode je mag  veranderingen aanbrengen aan het programma . Deze worden samen met de documentatie overgedragen aan I.C.E. .
#I.C.E. beslist dan op deze veranderingen worden doorgevoerd.

#Door het openen van deze broncode stem je in met de voorgaande voorwaarden.

#
#Harry Conings beheert voor I.C.E de broncode
require 'package_as400_gegevens_prod.pl';
require 'package_sql_toegang_agresso_prod.pl';
require 'package_agresso_get_calculater_info_prod.pl';
require 'package_invoice_to_agresso_prod.pl';
require 'package_maf_calculation_settings_prod.pl';
use strict;
use XML::Simple;
use Time::Piece;
use Time::Seconds;
use Date::Calc qw(:all);
use Wx qw[:everything];
use base qw(Wx::Frame);
use Wx::Locale gettext => '_T';
use DBI;
use DBD::ODBC;
use Date::Calc qw(:all);
our  $agresso_instellingen;
our $AS400_instellingen;
our $calc_instelingen;
our  @verzekeringen_in_xml;

package main;
     use Win32::OLE;
     use Win32::OLE::Const 'Microsoft Excel';
     our $mode = 'PROG'; #TEST voor test   PROG voor productie
     $mode = $ARGV[0] if (defined $ARGV[0]);
     if ( $mode eq 'TEST' or $mode eq 'PROG'){}else{die}
     our $klant;
     our $mail_msg;
     our $variant_LG04 =3;
     $mail_msg = "OVERZICHT VAN DE MAF UITBETALINGEN \n____________________________________________\n";
     print "OVERZICHT VAN DE MAF UITBETALINGEN \n____________________________________________\n";
     main->load_agresso_setting("P:\\OGV\\ASSURCARD_$mode\\assurcard_settings_xml\\maf_agresso_settings.xml"); #nagekeken
     foreach my $zkf1 (keys $agresso_instellingen->{as400}) {
        $agresso_instellingen->{as400}->{$zkf1}->{password} = decrypt->new($agresso_instellingen->{as400}->{$zkf1}->{password});
     }
     #main->load_agresso_setting('P:\OGV\ASSURCARD_PROG\assurcard_settings_xml\agresso_settings.xml');
     #$AS400_instellingen = main->load_AS400_settings('P:\OGV\ASSURCARD_PROG\assurcard_settings_xml\AS400_settings.xml'); #C:\macros\doccentermail     
     $calc_instelingen = assurcard_calculation_settings->new();
     #my $intern_nr = as400_gegevens->maf_omzetting_newid(203,48070723233,19480707,$AS400_instellingen) ; #$zkf,$inz,$geboortedatum,$instellingen
     my $app = App->new();          
     $app->MainLoop;
     print ""; 
     
     sub maak_betalingen_aan  {
         my ($class,$huidig_jaar,$dryrun,$contractstartdat) = @_;       
         my $eerstejaar =$huidig_jaar-1;
         my $tweedejaar = $huidig_jaar-2;
         my $derdejaar = $huidig_jaar-3;
         my ($Excel,$Book,$Sheet,$rijteller) = excel->new($eerstejaar,$tweedejaar,$derdejaar);
         my $calc_jaar = "periode_$eerstejaar"."0101-$eerstejaar"."1231";        
         my $verkoopsdagboek = $calc_instelingen->{"$calc_jaar"}->{verzekeringen}->{maxiplan}->{verkoopsdagboek};
         my $nomenclatuur = ''; #REMGELDEN MAF
         
         eval {foreach my $groep (keys $calc_instelingen->{"$calc_jaar"}->{verzekeringen}->{maxiplan}->{groep}){}};
         if (!$@) {
             foreach my $groep (keys $calc_instelingen->{"$calc_jaar"}->{verzekeringen}->{maxiplan}->{groep}){
                 eval {my $nom_naam =uc $calc_instelingen->{"$calc_jaar"}->{verzekeringen}->{maxiplan}->{groep}->[$groep]->{nomenclatuur}->{naam};};
                 if (!$@) {
                     my $nom_naam =uc $calc_instelingen->{"$calc_jaar"}->{verzekeringen}->{maxiplan}->{groep}->[$groep]->{nomenclatuur}->{naam};
                     if ($nom_naam eq 'WETTELIJKE REMGELDEN') {
                         $nomenclatuur = $calc_instelingen->{"$calc_jaar"}->{verzekeringen}->{maxiplan}->{groep}->[$groep]->{nomenclatuur}->{nummer};
                        }
                    }
                }
            }   
         if ($nomenclatuur ne '') {
              my $berekeningsjaren=  "$eerstejaar,$tweedejaar,$derdejaar";
              $mail_msg = $mail_msg."\nBerekeningsjaren : $eerstejaar,$tweedejaar,$derdejaar\n";
              print "\nBerekeningsjaren : $eerstejaar,$tweedejaar,$derdejaar\n";
              my $dbh_agresso = sql_toegang_agresso->setup_mssql_connectie ();
              my $contract_start_jaar = $huidig_jaar;              
              my ($maxiplans,$aantal_maxiplans) = sql_toegang_agresso->get_contracts_by_type($dbh_agresso,'MAXIPLAN',$contract_start_jaar);
              my $maanden_wachttijd= 3;
              my $test_teller = 0;
             foreach my $client_id (sort keys $maxiplans) {
                  
                if ( $client_id != 999999 ){   #for testing purposes if ( $client_id = 109690 )  if ( $client_id = 191887 )if ( $client_id != 999999
                 my $excel_rij;
                 $test_teller += 1;                 
                 my $begindatum = $maxiplans->{$client_id}->{begin_datum};
                 my $wachtdatum = $maxiplans->{$client_id}->{wacht_datum};
                 my $einddatum =  $maxiplans->{$client_id}->{eind_datum};
                 $einddatum =~ s/-//g;
                 $wachtdatum  =~ s/-//g;
                 $begindatum =~ s/-//g;
                 my $einde_eerste_jaar= $eerstejaar*10000+1231;
                 my $einde_tweede_jaar =  $tweedejaar*10000+1231;
                 my $einde_derde_jaar =  $derdejaar*10000+1231;
                 my $b_year = substr($begindatum,0,4);               
                 my $b_month =  substr($begindatum,4,2);
                 my $b_day =  substr($begindatum,6,2);
                 my $e_year = substr($einddatum,0,4);
                 my $e_month =  substr($einddatum,4,2);
                 my $e_day =  substr($einddatum,6,2);
                 #we moeten uitbetalen maar vanaf wanneer
                 package_agresso_get_calculater_info->agresso_get_customer_info($client_id);
                 my $zkf =  $maxiplans->{$client_id}->{zkf};
                 my $contractnr =  $maxiplans->{$client_id}->{contract_nr};
                 my ($te_betalen_bedrag,$terugbetalingen,$geboortejaar,$geboorte_maand) = main->berekening_teruggave($zkf,$klant->{Rijksreg_Nr},$main::agresso_instellingen,$berekeningsjaren);
                 my $inz =$klant->{Rijksreg_Nr};
                 my $naam = $klant->{naam};
                 $mail_msg = $mail_msg."\t\t$client_id $inz $naam begin $begindatum wacht $wachtdatum eind $einddatum\n";
                 my $eerstejaarsmaf = ($te_betalen_bedrag->{$eerstejaar})*2;
                 my $tweedejaarmaf =($te_betalen_bedrag->{$tweedejaar})*2;
                 my $derdejaarmaf =($te_betalen_bedrag->{$derdejaar})*2;                
                 $excel_rij = {
                     'agresso_id' => $client_id,
                     'inz' => $inz,
                     'naam' =>$naam,
                     'begincontract' => $begindatum,
                     'wachtcontract' =>  $wachtdatum,
                     'eindcontract' => $einddatum,
                     'eerstejaar' => $eerstejaar,
                     'eerstejaar_maf' => $eerstejaarsmaf,
                     'tweedejaar' => $tweedejaar,
                     'tweedejaar_maf' => $tweedejaarmaf,
                     'derdejaar' =>$derdejaar,
                     'derdejaar_maf' =>$derdejaarmaf,
                     'bankrekening' => $klant->{Bankrekening},
                     'zkf' =>$zkf,
                 };
                 print "\t\t$client_id $inz $naam begin $begindatum wacht $wachtdatum eind $einddatum\n";
                 $mail_msg = $mail_msg."\t\t$eerstejaar ->$te_betalen_bedrag->{$eerstejaar}\n";
                 print "\t\t$eerstejaar ->$te_betalen_bedrag->{$eerstejaar}\n";
                 $mail_msg = $mail_msg."\t\t$tweedejaar ->$te_betalen_bedrag->{$tweedejaar}\n";
                 print "\t\t$tweedejaar ->$te_betalen_bedrag->{$tweedejaar}\n";
                 $mail_msg = $mail_msg."\t\t$derdejaar ->$te_betalen_bedrag->{$derdejaar}\n";
                 print "\t\t$derdejaar ->$te_betalen_bedrag->{$derdejaar}\n";
                 if ($begindatum == $wachtdatum ) {
                     #beginnen van begindatum
                    
                     my ($start_year,$start_month,$start_day) =($b_year,$b_month,$b_day);
                     my $start_datum = $start_year*10000+$start_month*100+$start_day;
                     $excel_rij->{begin_recht}= $start_year*10000+$start_month*100;
                     $te_betalen_bedrag= main->herberekening_teruggave($te_betalen_bedrag,$start_year,$start_month,$eerstejaar,$tweedejaar,$derdejaar,$e_year,$e_month,$geboortejaar,$geboorte_maand,'geen_wachttijd');
                     if ($begindatum == $einddatum) {
                        $te_betalen_bedrag->{$eerstejaar} = 0;
                        $te_betalen_bedrag->{$tweedejaar} = 0;
                        $te_betalen_bedrag->{$derdejaar} = 0; 
                     }
                    }else {
                     my ($start_year,$start_month,$start_day) =Add_Delta_YM($b_year,$b_month,$b_day,0,$maanden_wachttijd);
                     my $start_datum = $start_year*10000+$start_month*100+$start_day;
                      $excel_rij->{begin_recht}= $start_year*10000+$start_month*100;
                      $te_betalen_bedrag= main->herberekening_teruggave($te_betalen_bedrag,$start_year,$start_month,$eerstejaar,$tweedejaar,$derdejaar,$e_year,$e_month,$geboortejaar,$geboorte_maand,'wachttijd');
                      if ($begindatum == $einddatum) {
                        $te_betalen_bedrag->{$eerstejaar} = 0;
                        $te_betalen_bedrag->{$tweedejaar} = 0;
                        $te_betalen_bedrag->{$derdejaar} = 0; 
                      }
                    }        
                 print "";
                 my $al_betaald = sql_toegang_agresso->get_maf_payment_info($dbh_agresso,$client_id,$eerstejaar,$tweedejaar,$derdejaar);
                 my $wat_we_betalen ;
                 my $maximum_jaar = $main::agresso_instellingen->{maf_maximum};
                 $mail_msg = $mail_msg."\t\tWat we moeten betalen is wat we betaald hebben - wat we al betaald hebben met een maximum van $maximum_jaar \n";
                 print "\t\tWat we moeten betalen is wat we betaald hebben - wat we al betaald hebben met een maximum van $maximum_jaar\n";
                $excel_rij->{eerstejaar_te_betalen} = $te_betalen_bedrag->{$eerstejaar};
                $excel_rij->{tweedejaar_te_betalen} = $te_betalen_bedrag->{$tweedejaar};
                $excel_rij->{derdejaar_te_betalen} =  $te_betalen_bedrag->{$derdejaar}; 
                 if ($te_betalen_bedrag->{$eerstejaar} > $maximum_jaar) {
                     $te_betalen_bedrag->{$eerstejaar} = $maximum_jaar;
                     $mail_msg = $mail_msg."\t\t\tMaximum overschreden te betalen bedrag $eerstejaar aangepast naar $maximum_jaar\n";
                     print "\t\t\tMaximum overschreden te betalen bedrag $eerstejaar aangepast naar $maximum_jaar\n";                     
                 }
                 if ($te_betalen_bedrag->{$tweedejaar} > $maximum_jaar) {
                     $te_betalen_bedrag->{$tweedejaar} = $maximum_jaar;
                     $mail_msg = $mail_msg."\t\t\tMaximum overschreden te betalen bedrag $tweedejaar aangepast naar $maximum_jaar\n";
                     print "\t\t\tMaximum overschreden te betalen bedrag $tweedejaar aangepast naar $maximum_jaar\n";                     
                 }
                 if ($te_betalen_bedrag->{$derdejaar} > $maximum_jaar) {
                     $te_betalen_bedrag->{$derdejaar} = $maximum_jaar;
                     $mail_msg = $mail_msg."\t\t\tMaximum overschreden te betalen bedrag $derdejaar aangepast naar $maximum_jaar\n";
                     print "\t\t\tMaximum overschreden te betalen bedrag $derdejaar aangepast naar $maximum_jaar\n";                     
                 }
                 $wat_we_betalen->{$eerstejaar}= $te_betalen_bedrag->{$eerstejaar} - $al_betaald->{$eerstejaar};
                 $wat_we_betalen->{$tweedejaar}= $te_betalen_bedrag->{$tweedejaar} - $al_betaald->{$tweedejaar};
                 $wat_we_betalen->{$derdejaar} = $te_betalen_bedrag->{$derdejaar} - $al_betaald->{$derdejaar};
                 $excel_rij->{eerstejaar_al_betaald} =  $al_betaald->{$eerstejaar};
                 $excel_rij->{tweedejaar_al_betaald} =  $al_betaald->{$tweedejaar};
                 $excel_rij->{derdejaar_al_betaald} =   $al_betaald->{$derdejaar}; 
                 $wat_we_betalen->{$eerstejaar} = sprintf "%.2f", $wat_we_betalen->{$eerstejaar};  # rounded to 2 decimal places (0.67)
                 $wat_we_betalen->{$tweedejaar} = sprintf "%.2f", $wat_we_betalen->{$tweedejaar};  # rounded to 2 decimal places (0.67)   
                 $wat_we_betalen->{$derdejaar} = sprintf "%.2f", $wat_we_betalen->{$derdejaar};  # rounded to 2 decimal places (0.67)   
                 my $t_betaal =$te_betalen_bedrag->{$derdejaar} ;
                 my $a_betaal = $al_betaald->{$derdejaar};
                 my $w_betaal = $wat_we_betalen->{$derdejaar};
                 $excel_rij->{derdejaar_som} =$w_betaal;
                 $mail_msg = $mail_msg."\t\t\t$derdejaar -> $w_betaal = $t_betaal -$a_betaal\n";
                 print "\t\t\t$derdejaar -> $w_betaal = $t_betaal -$a_betaal\n";
                 $t_betaal =$te_betalen_bedrag->{$tweedejaar} ;
                 $a_betaal = $al_betaald->{$tweedejaar};
                 $w_betaal = $wat_we_betalen->{$tweedejaar};
                 $excel_rij->{tweedejaar_som} =$w_betaal;
                 $mail_msg = $mail_msg."\t\t\t$tweedejaar -> $w_betaal = $t_betaal -$a_betaal\n";
                 print "\t\t\t$tweedejaar -> $w_betaal = $t_betaal -$a_betaal\n";
                 $t_betaal =$te_betalen_bedrag->{$eerstejaar} ;
                 $a_betaal = $al_betaald->{$eerstejaar};
                 $w_betaal = $wat_we_betalen->{$eerstejaar};
                 $excel_rij->{eerstejaar_som} =$w_betaal;
                 $mail_msg = $mail_msg."\t\t\t$eerstejaar -> $w_betaal = $t_betaal -$a_betaal\n";
                 print "\t\t\t$eerstejaar -> $w_betaal = $t_betaal -$a_betaal\n";
                 print '';
                 excel->schrijf_rij($Excel,$Book,$Sheet,$rijteller,$excel_rij);
                 $rijteller +=1;
                 #my ($class,$klant,$naam_verzekering,$verkoopsdagboek,$nomenclatuur,$wat_we_moeten_betalen,$eerstejaar,$tweedejaar,$derdejaar) = @_;
                 
                 if ($dryrun !=1 ) {                                        
                     my $antwoord = package_invoice_to_agresso->maak_maf_tussenkomst($client_id,'MAXIPLAN',$verkoopsdagboek,$nomenclatuur,$wat_we_betalen,$eerstejaar,$tweedejaar,$derdejaar);
                     if ($antwoord eq 'Nul factuur') {
                         $mail_msg = $mail_msg."$client_id -> $inz Nul factuur wordt niet gemaakt\n";
                         print "$client_id -> $inz Nul factuur wordt niet gemaakt\n";
                        }else {
                         if ($antwoord =~ m/OK ordernr/ )  {
                             #inzetten in database
                             my $periode = "$derdejaar-$eerstejaar";
                             my  $klantbedrag =0;
                             $klantbedrag = $terugbetalingen->{"$periode"}->{bedrag_VP} if (defined $terugbetalingen->{"$periode"}->{bedrag_VP});
                             sql_toegang_agresso->enter_maf_payment_info($dbh_agresso,$client_id,$derdejaar,$eerstejaar,$huidig_jaar,$klantbedrag,$wat_we_betalen->{$derdejaar}); 
                             $periode = "$tweedejaar-$eerstejaar";
                             $klantbedrag =0;
                             $klantbedrag = $terugbetalingen->{"$periode"}->{bedrag_VP} if (defined $terugbetalingen->{"$periode"}->{bedrag_VP});
                             sql_toegang_agresso->enter_maf_payment_info($dbh_agresso,$client_id,$tweedejaar,$eerstejaar,$huidig_jaar,$klantbedrag,$wat_we_betalen->{$tweedejaar});
                             $klantbedrag =0;
                             $periode = "$eerstejaar-$eerstejaar";
                             $klantbedrag = $terugbetalingen->{"$periode"}->{bedrag_VP} if (defined $terugbetalingen->{"$periode"}->{bedrag_VP});;
                             sql_toegang_agresso->enter_maf_payment_info($dbh_agresso,$client_id,$eerstejaar,$eerstejaar,$huidig_jaar,$klantbedrag,$wat_we_betalen->{$eerstejaar});
                             print '';
                            }
                         print '';
                        }
                    }
                }
         
         }
            my $ok =excel->save_excel($Excel);
            #$Excel->ActiveWorkbook->Close(1);
            #$Excel->Quit();
            print "";
            }else {
             $mail_msg = $mail_msg."geen nomenclatuur gevonden naam moet gelijk zijn aan WETTELIJKE REMGELDEN verzekering maxiplan\n";
             print "geen nomenclatuur gevonden naam moet gelijk zijn aan WETTELIJKE REMGELDEN verzekering maxiplan\n";
            }
         print "betalingen gedaan\n";
         
        }
    
     
     
     sub herberekening_teruggave {
         my ($class,$te_betalen_bedrag,$start_year,$start_month,$eerstejaar,$tweedejaar,$derdejaar,$end_year,$end_month,$geboortejaar,$geboorte_maand,$wachttijd) = @_;
         $mail_msg = $mail_msg."\t\t\tlooptijd $start_year/$start_month -> $end_year/$end_month\n";
         print "\t\t\tLooptijd $start_year/$start_month -> $end_year/$end_month\n";        
             if ( $start_year == $eerstejaar and $end_year > $eerstejaar) {
                 my $oorspronkelijk_te_betalen =$te_betalen_bedrag->{$derdejaar};
                 my $tebetalen = 0;
                 #$tebetalen  = sprintf("%.2f", $tebetalen ); 
                 $te_betalen_bedrag->{$derdejaar} = $tebetalen ;
                 $mail_msg = $mail_msg."\t\t\t-> $derdejaar $oorspronkelijk_te_betalen->$tebetalen -> herberekend\n";
                 print "\t\t\t-> $derdejaar $oorspronkelijk_te_betalen->$tebetalen -> herberekend\n";
                 $oorspronkelijk_te_betalen =$te_betalen_bedrag->{$tweedejaar};
                 $te_betalen_bedrag->{$tweedejaar} = $tebetalen ;
                 $mail_msg = $mail_msg."\t\t\t-> $tweedejaar $oorspronkelijk_te_betalen->$tebetalen -> herberekend \n";
                 print "\t\t\t-> $tweedejaar $oorspronkelijk_te_betalen->$tebetalen -> herberekend \n";
                 $oorspronkelijk_te_betalen =$te_betalen_bedrag->{$eerstejaar};
                 my $pasgeboren = '';
                 if ($geboortejaar == $eerstejaar and $wachttijd eq 'geen_wachttijd'){     #versie v2 2018 pasgeboren krijgen alles zelfs de fles
                     $tebetalen = $te_betalen_bedrag->{$eerstejaar};
                     $pasgeboren = "-> v2 geboren in $geboortejaar krijgen alles zelfs de fles";
                 }elsif ($geboortejaar == $eerstejaar and $wachttijd ne 'geen_wachttijd')   {
                     $tebetalen = $te_betalen_bedrag->{$eerstejaar}*((12+1-$start_month)/(12+1-$geboorte_maand));  
                 }else {
                     $tebetalen = $te_betalen_bedrag->{$eerstejaar}*((12+1-$start_month)/12);
                 }
                 #$tebetalen = $te_betalen_bedrag->{$eerstejaar}*((12+1-$start_month)/12);
                 $tebetalen  = sprintf("%.2f", $tebetalen ); 
                 $te_betalen_bedrag->{$eerstejaar} = $tebetalen ;
                 $mail_msg = $mail_msg."\t\t\t-> $eerstejaar $oorspronkelijk_te_betalen->$tebetalen -> herberekend  $pasgeboren\n";
                 print "\t\t\t-> $eerstejaar $oorspronkelijk_te_betalen->$tebetalen -> herberekend $pasgeboren\n";
                 
            }elsif ($start_year == $eerstejaar and $end_year == $eerstejaar) {
                 my $oorspronkelijk_te_betalen =$te_betalen_bedrag->{$derdejaar};
                 my $tebetalen = 0;
                 #$tebetalen  = sprintf("%.2f", $tebetalen ); 
                 $te_betalen_bedrag->{$derdejaar} = $tebetalen ;
                 $mail_msg = $mail_msg."\t\t\t-> $derdejaar $oorspronkelijk_te_betalen->$tebetalen -> herberekend\n";
                 print "\t\t\t-> $derdejaar $oorspronkelijk_te_betalen->$tebetalen -> herberekend\n";
                 $oorspronkelijk_te_betalen =$te_betalen_bedrag->{$tweedejaar};
                 $te_betalen_bedrag->{$tweedejaar} = $tebetalen ;
                 $mail_msg = $mail_msg."\t\t\t-> $tweedejaar $oorspronkelijk_te_betalen->$tebetalen -> herberekend \n";
                 print "\t\t\t-> $tweedejaar $oorspronkelijk_te_betalen->$tebetalen -> herberekend \n";
                 $oorspronkelijk_te_betalen =$te_betalen_bedrag->{$eerstejaar};
                 my $aantalmaanden = $end_month-$start_month;
                 if ($aantalmaanden >= 0) {
                     my $tebetalen = $te_betalen_bedrag->{$eerstejaar}*($aantalmaanden/12); #blijft ($aantalmaanden/12);;
                     $tebetalen = $te_betalen_bedrag->{$eerstejaar}*(($aantalmaanden+1)/12) if ($end_year > 2018) ;
                     $tebetalen  = sprintf("%.2f", $tebetalen ); 
                     $te_betalen_bedrag->{$eerstejaar} = $tebetalen ;
                     $mail_msg = $mail_msg."\t\t\t-> $eerstejaar $oorspronkelijk_te_betalen->$tebetalen -> herberekend aantalmaanden = $aantalmaanden+1\n";
                     print "\t\t\t-> $eerstejaar $oorspronkelijk_te_betalen->$tebetalen -> herberekend \n";
                    }else {
                     my $tebetalen = 0;
                     $te_betalen_bedrag->{$eerstejaar} = $tebetalen ;
                     $mail_msg = $mail_msg."\t\t\t-> $eerstejaar $oorspronkelijk_te_betalen->$tebetalen -> herberekend \n";
                     print "\t\t\t-> $eerstejaar $oorspronkelijk_te_betalen->$tebetalen -> herberekend \n";
                    }
                 
            }elsif ($start_year == $tweedejaar and $end_year > $eerstejaar) {
                 my $oorspronkelijk_te_betalen =$te_betalen_bedrag->{$derdejaar};
                 my $tebetalen = 0;
                 #$tebetalen  = sprintf("%.2f", $tebetalen ); 
                 $te_betalen_bedrag->{$derdejaar} = $tebetalen ;
                 $mail_msg = $mail_msg."\t\t\t-> $derdejaar $oorspronkelijk_te_betalen->$tebetalen -> herberekend\n";
                 print "\t\t\t-> $derdejaar $oorspronkelijk_te_betalen->$tebetalen -> herberekend\n";
                 $oorspronkelijk_te_betalen =$te_betalen_bedrag->{$tweedejaar};
                 $tebetalen = $te_betalen_bedrag->{$tweedejaar}*((12-$start_month+1)/12);
                 $tebetalen  = sprintf("%.2f", $tebetalen ); 
                 $te_betalen_bedrag->{$tweedejaar} = $tebetalen ;
                 $mail_msg = $mail_msg."\t\t\t-> $tweedejaar $oorspronkelijk_te_betalen->$tebetalen -> herberekend \n";
                 print "\t\t\t-> $tweedejaar $oorspronkelijk_te_betalen->$tebetalen -> herberekend \n";
                
            }elsif ($start_year == $tweedejaar and $end_year == $eerstejaar) {
                 my $oorspronkelijk_te_betalen =$te_betalen_bedrag->{$derdejaar};
                 my $tebetalen = 0;
                 #$tebetalen  = sprintf("%.2f", $tebetalen ); 
                 $te_betalen_bedrag->{$derdejaar} = $tebetalen ;
                 $mail_msg = $mail_msg."\t\t\t-> $derdejaar $oorspronkelijk_te_betalen->$tebetalen -> herberekend\n";
                 print "\t\t\t-> $derdejaar $oorspronkelijk_te_betalen->$tebetalen -> herberekend\n";
                 $oorspronkelijk_te_betalen =$te_betalen_bedrag->{$tweedejaar};
                 $tebetalen = $te_betalen_bedrag->{$tweedejaar}*((12-$start_month+1)/12);
                 $tebetalen  = sprintf("%.2f", $tebetalen ); 
                 $te_betalen_bedrag->{$tweedejaar} = $tebetalen ;
                 $mail_msg = $mail_msg."\t\t\t-> $tweedejaar $oorspronkelijk_te_betalen->$tebetalen -> herberekend \n";
                 print "\t\t\t-> $tweedejaar $oorspronkelijk_te_betalen->$tebetalen -> herberekend \n";
                 $oorspronkelijk_te_betalen =$te_betalen_bedrag->{$eerstejaar};
                 my $aantalmaanden = 0; # begint altijd op de eerste van de mmand dus -1
                 $aantalmaanden = $end_month-1; # begint altijd op de eerste van de mmand dus -1
                 $aantalmaanden = $end_month if ($eerstejaar > 2018);
                 if ($aantalmaanden > 0) {
                     my $tebetalen = $te_betalen_bedrag->{$eerstejaar}*($aantalmaanden/12);
                     $tebetalen  = sprintf("%.2f", $tebetalen ); 
                     $te_betalen_bedrag->{$eerstejaar} = $tebetalen ;
                     $mail_msg = $mail_msg."\t\t\t-> $eerstejaar $oorspronkelijk_te_betalen->$tebetalen -> herberekend \n";
                     print "\t\t\t-> $eerstejaar $oorspronkelijk_te_betalen->$tebetalen -> herberekend \n";
                    }else {
                     my $tebetalen = 0;
                     $te_betalen_bedrag->{$eerstejaar} = $tebetalen ;
                     $mail_msg = $mail_msg."\t\t\t-> $eerstejaar $oorspronkelijk_te_betalen->$tebetalen -> herberekend \n";
                     print "\t\t\t-> $eerstejaar $oorspronkelijk_te_betalen->$tebetalen -> herberekend \n";
                    }
               
            }elsif ($start_year == $tweedejaar and $end_year == $tweedejaar) {
                 my $oorspronkelijk_te_betalen =$te_betalen_bedrag->{$derdejaar};
                 my $tebetalen = 0;
                 #$tebetalen  = sprintf("%.2f", $tebetalen ); 
                 $te_betalen_bedrag->{$derdejaar} = $tebetalen ;
                 $mail_msg = $mail_msg."\t\t\t-> $derdejaar $oorspronkelijk_te_betalen->$tebetalen -> herberekend\n";
                 print "\t\t\t-> $derdejaar $oorspronkelijk_te_betalen->$tebetalen -> herberekend\n";
                 $oorspronkelijk_te_betalen =$te_betalen_bedrag->{$tweedejaar};
                 my $aantalmaanden = $end_month-$start_month;
                 $aantalmaanden = 0 if ($aantalmaanden<0);
                 $tebetalen = $te_betalen_bedrag->{$tweedejaar}*(($aantalmaanden)/12);
                 $tebetalen = $te_betalen_bedrag->{$tweedejaar}*(($aantalmaanden+1)/12) if ($end_year > 2018); #rechtzetting bug vanaf 2019                              
                 $tebetalen  = sprintf("%.2f", $tebetalen ); 
                 $te_betalen_bedrag->{$tweedejaar} = $tebetalen ;
                 $mail_msg = $mail_msg."\t\t\t-> $tweedejaar $oorspronkelijk_te_betalen->$tebetalen -> herberekend \n";
                 print "\t\t\t-> $tweedejaar $oorspronkelijk_te_betalen->$tebetalen -> herberekend \n";
                 $tebetalen =0;
                 $te_betalen_bedrag->{$eerstejaar} = $tebetalen ;
                 $mail_msg = $mail_msg."\t\t\t-> $eerstejaar $oorspronkelijk_te_betalen->$tebetalen -> herberekend \n";
                 print "\t\t\t-> $eerstejaar $oorspronkelijk_te_betalen->$tebetalen -> herberekend \n";
                
            }elsif ($start_year == $derdejaar and $end_year > $eerstejaar) {
                 my $oorspronkelijk_te_betalen =$te_betalen_bedrag->{$derdejaar};
                 my $tebetalen = $te_betalen_bedrag->{$derdejaar}*((12-$start_month+1)/12);
                 $tebetalen  = sprintf("%.2f", $tebetalen ); 
                 $te_betalen_bedrag->{$derdejaar} = $tebetalen ;
                 $mail_msg = $mail_msg."\t\t\t-> $derdejaar $oorspronkelijk_te_betalen->$tebetalen -> herberekend\n";
                 print "\t\t\t-> $derdejaar $oorspronkelijk_te_betalen->$tebetalen -> herberekend\n";
            }elsif ($start_year == $derdejaar and $end_year == $eerstejaar) {
                 my $oorspronkelijk_te_betalen =$te_betalen_bedrag->{$derdejaar};
                 my $tebetalen = $te_betalen_bedrag->{$derdejaar}*((12-$start_month+1)/12);
                 $tebetalen  = sprintf("%.2f", $tebetalen ); 
                 $te_betalen_bedrag->{$derdejaar} = $tebetalen ;
                 $mail_msg = $mail_msg."\t\t\t-> $derdejaar $oorspronkelijk_te_betalen->$tebetalen -> herberekend\n";
                 print "\t\t\t-> $derdejaar $oorspronkelijk_te_betalen->$tebetalen -> herberekend\n";
                 $oorspronkelijk_te_betalen =$te_betalen_bedrag->{$eerstejaar};
                 my $aantalmaanden = $end_month-1; # begint altijd op de eerste van de mmand dus -1
                 $aantalmaanden = $end_month if ($eerstejaar > 2018); #rechtzetting bug vanaf 2019
                 if ($aantalmaanden > 0) {
                     my $tebetalen = $te_betalen_bedrag->{$eerstejaar}*($aantalmaanden/12);
                     $tebetalen  = sprintf("%.2f", $tebetalen ); 
                     $te_betalen_bedrag->{$eerstejaar} = $tebetalen ;
                     $mail_msg = $mail_msg."\t\t\t-> $eerstejaar $oorspronkelijk_te_betalen->$tebetalen -> herberekend \n";
                     print "\t\t\t-> $eerstejaar $oorspronkelijk_te_betalen->$tebetalen -> herberekend \n";
                    }else {
                     my $tebetalen = 0;
                     $te_betalen_bedrag->{$eerstejaar} = $tebetalen ;
                     $mail_msg = $mail_msg."\t\t\t-> $eerstejaar $oorspronkelijk_te_betalen->$tebetalen -> herberekend \n";
                     print "\t\t\t-> $eerstejaar $oorspronkelijk_te_betalen->$tebetalen -> herberekend \n";
                    }
            }elsif ($start_year == $derdejaar and $end_year == $tweedejaar) {
                 my $oorspronkelijk_te_betalen =$te_betalen_bedrag->{$derdejaar};
                 my $tebetalen = $te_betalen_bedrag->{$derdejaar}*((12-$start_month+1)/12);
                 $tebetalen  = sprintf("%.2f", $tebetalen ); 
                 $te_betalen_bedrag->{$derdejaar} = $tebetalen ;
                 $mail_msg = $mail_msg."\t\t\t-> $derdejaar $oorspronkelijk_te_betalen->$tebetalen -> herberekend\n";
                 print "\t\t\t-> $derdejaar $oorspronkelijk_te_betalen->$tebetalen -> herberekend\n";
                 $oorspronkelijk_te_betalen =$te_betalen_bedrag->{$tweedejaar};
                 my $aantalmaanden = $end_month-1; # begint altijd op de eerste van de mmand dus -1
                 $aantalmaanden = $end_month if ($tweedejaar > 2018); #rechtzetting buf vanaf 2019
                 if ($aantalmaanden > 0) {
                     my $tebetalen = $te_betalen_bedrag->{$tweedejaar}*($aantalmaanden/12);
                     $tebetalen  = sprintf("%.2f", $tebetalen ); 
                     $te_betalen_bedrag->{$tweedejaar} = $tebetalen ;
                     $mail_msg = $mail_msg."\t\t\t-> $tweedejaar $oorspronkelijk_te_betalen->$tebetalen -> herberekend \n";
                     print "\t\t\t-> $tweedejaar $oorspronkelijk_te_betalen->$tebetalen -> herberekend \n";
                    }else {
                     my $tebetalen = 0;
                     $te_betalen_bedrag->{$tweedejaar} = $tebetalen ;
                     $mail_msg = $mail_msg."\t\t\t-> $tweedejaar $oorspronkelijk_te_betalen->$tebetalen -> herberekend \n";
                     print "\t\t\t-> $tweedejaar $oorspronkelijk_te_betalen->$tebetalen -> herberekend \n";
                    }
                 $tebetalen = 0;
                 $te_betalen_bedrag->{$eerstejaar} = $tebetalen ;
                 $mail_msg = $mail_msg."\t\t\t-> $eerstejaar $oorspronkelijk_te_betalen->$tebetalen -> herberekend \n";
                 print "\t\t\t-> $eerstejaar $oorspronkelijk_te_betalen->$tebetalen -> herberekend \n";
            }elsif ($start_year == $derdejaar and $end_year == $derdejaar) {
                 my $oorspronkelijk_te_betalen =$te_betalen_bedrag->{$derdejaar};
                 my $aantalmaanden = $end_month-$start_month; # begint altijd op de eerste van de mmand dus -1
                 if ($aantalmaanden > 0) {
                     my $tebetalen = $te_betalen_bedrag->{$derdejaar}*($aantalmaanden/12);
                     $tebetalen = $te_betalen_bedrag->{$derdejaar}*(($aantalmaanden+1)/12)if ($end_year > 2018);
                     $tebetalen  = sprintf("%.2f", $tebetalen ); 
                     $te_betalen_bedrag->{$derdejaar} = $tebetalen ;
                     $mail_msg = $mail_msg."\t\t\t-> $derdejaar $oorspronkelijk_te_betalen->$tebetalen -> herberekend \n";
                     print "\t\t\t-> $derdejaar $oorspronkelijk_te_betalen->$tebetalen -> herberekend \n";
                    }else {
                     my $tebetalen = 0;
                     $te_betalen_bedrag->{$derdejaar} = $tebetalen ;
                     $mail_msg = $mail_msg."\t\t\t-> $derdejaar $oorspronkelijk_te_betalen->$tebetalen -> herberekend \n";
                     print "\t\t\t-> $derdejaar $oorspronkelijk_te_betalen->$tebetalen -> herberekend \n";
                    }
                 my $tebetalen = 0;
                 $te_betalen_bedrag->{$tweedejaar} = $tebetalen ;
                 $mail_msg = $mail_msg."\t\t\t-> $tweedejaar $oorspronkelijk_te_betalen->$tebetalen -> herberekend \n";
                 print "\t\t\t-> $tweedejaar $oorspronkelijk_te_betalen->$tebetalen -> herberekend \n";
                 $oorspronkelijk_te_betalen =$te_betalen_bedrag->{$eerstejaar};
                 $te_betalen_bedrag->{$eerstejaar} = $tebetalen ;
                 $mail_msg = $mail_msg."\t\t\t-> $eerstejaar $oorspronkelijk_te_betalen->$tebetalen -> herberekend \n";
                 print "\t\t\t-> $eerstejaar $oorspronkelijk_te_betalen->$tebetalen -> herberekend \n";
            }elsif ($start_year < $derdejaar and $end_year == $eerstejaar) {
                 my  $oorspronkelijk_te_betalen =$te_betalen_bedrag->{$eerstejaar};
                 my $aantalmaanden = $end_month-1; # begint altijd op de eerste van de mmand dus -1
                 $aantalmaanden = $end_month if ($eerstejaar >2018); #rechtzetting bug vanaf 2019
                 if ($aantalmaanden > 0) {
                     my $tebetalen = $te_betalen_bedrag->{$eerstejaar}*($aantalmaanden/12);
                     $tebetalen  = sprintf("%.2f", $tebetalen ); 
                     $te_betalen_bedrag->{$eerstejaar} = $tebetalen ;
                     $mail_msg = $mail_msg."\t\t\t-> $eerstejaar $oorspronkelijk_te_betalen->$tebetalen -> herberekend \n";
                     print "\t\t\t-> $eerstejaar $oorspronkelijk_te_betalen->$tebetalen -> herberekend \n";
                    }else {
                     my $tebetalen = 0;
                     $te_betalen_bedrag->{$eerstejaar} = $tebetalen ;
                     $mail_msg = $mail_msg."\t\t\t-> $eerstejaar $oorspronkelijk_te_betalen->$tebetalen -> herberekend \n";
                     print "\t\t\t-> $eerstejaar $oorspronkelijk_te_betalen->$tebetalen -> herberekend \n";
                    }    
            }elsif ($start_year < $derdejaar and $end_year == $tweedejaar) {
                 my $oorspronkelijk_te_betalen =$te_betalen_bedrag->{$tweedejaar};
                 my $aantalmaanden = $end_month-1; # begint altijd op de eerste van de mmand dus -1
                 $aantalmaanden = $end_month if ($end_year >2018); #rechtzetting bug vanaf 2019
                 if ($aantalmaanden > 0) {
                     my $tebetalen = $te_betalen_bedrag->{$tweedejaar}*($aantalmaanden/12);
                     $tebetalen  = sprintf("%.2f", $tebetalen ); 
                     $te_betalen_bedrag->{$tweedejaar} = $tebetalen ;
                     $mail_msg = $mail_msg."\t\t\t-> $tweedejaar $oorspronkelijk_te_betalen->$tebetalen -> herberekend \n";
                     print "\t\t\t-> $tweedejaar $oorspronkelijk_te_betalen->$tebetalen -> herberekend \n";
                    }else {
                     my $tebetalen = 0;
                     $te_betalen_bedrag->{$tweedejaar} = $tebetalen ;
                     $mail_msg = $mail_msg."\t\t\t-> $tweedejaar $oorspronkelijk_te_betalen->$tebetalen -> herberekend \n";
                     print "\t\t\t-> $tweedejaar $oorspronkelijk_te_betalen->$tebetalen -> herberekend \n";
                    }
                 my $tebetalen = 0;
                 $te_betalen_bedrag->{$eerstejaar} = $tebetalen ;
                 $mail_msg = $mail_msg."\t\t\t-> $eerstejaar $oorspronkelijk_te_betalen->$tebetalen -> herberekend \n";
                 print "\t\t\t-> $eerstejaar $oorspronkelijk_te_betalen->$tebetalen -> herberekend \n";
            }elsif ($start_year < $derdejaar and $end_year == $derdejaar) {
                 my $oorspronkelijk_te_betalen =$te_betalen_bedrag->{$derdejaar};
                 my $aantalmaanden = $end_month-1; # begint altijd op de eerste van de mmand dus -1
                 $aantalmaanden = $end_month if ($end_year >2018); #rechtzetting bug vanaf 2019
                 if ($aantalmaanden > 0) {
                     my $tebetalen = $te_betalen_bedrag->{$derdejaar}*($aantalmaanden/12);
                     $tebetalen  = sprintf("%.2f", $tebetalen ); 
                     $te_betalen_bedrag->{$derdejaar} = $tebetalen ;
                     $mail_msg = $mail_msg."\t\t\t-> $derdejaar $oorspronkelijk_te_betalen->$tebetalen -> herberekend \n";
                     print "\t\t\t-> $derdejaar $oorspronkelijk_te_betalen->$tebetalen -> herberekend \n";
                    }else {
                     my $tebetalen = 0;
                     $te_betalen_bedrag->{$derdejaar} = $tebetalen ;
                     $mail_msg = $mail_msg."\t\t\t-> $derdejaar $oorspronkelijk_te_betalen->$tebetalen -> herberekend \n";
                     print "\t\t\t-> $derdejaar $oorspronkelijk_te_betalen->$tebetalen -> herberekend \n";
                    }
                 my $tebetalen = 0;
                 $te_betalen_bedrag->{$tweedejaar} = $tebetalen ;
                 $mail_msg = $mail_msg."\t\t\t-> $tweedejaar $oorspronkelijk_te_betalen->$tebetalen -> herberekend \n";
                 print "\t\t\t-> $tweedejaar $oorspronkelijk_te_betalen->$tebetalen -> herberekend \n";
                 $oorspronkelijk_te_betalen =$te_betalen_bedrag->{$eerstejaar};
                 $te_betalen_bedrag->{$eerstejaar} = $tebetalen ;
                 $mail_msg = $mail_msg."\t\t\t-> $eerstejaar $oorspronkelijk_te_betalen->$tebetalen -> herberekend \n";
                 print "\t\t\t-> $eerstejaar $oorspronkelijk_te_betalen->$tebetalen -> herberekend \n";
            }elsif ($start_year > $eerstejaar or $end_year < $derdejaar or $end_year < $start_year ) {
                 my $tebetalen = 0;
                 my $oorspronkelijk_te_betalen =$te_betalen_bedrag->{$derdejaar};
                 $te_betalen_bedrag->{$derdejaar} = $tebetalen ;
                 $mail_msg = $mail_msg."\t\t\t-> $derdejaar $oorspronkelijk_te_betalen->$tebetalen -> herberekend\n";
                 print "\t\t\t-> $derdejaar $oorspronkelijk_te_betalen->$tebetalen -> herberekend\n";
                 $te_betalen_bedrag->{$tweedejaar} = $tebetalen ;
                 $oorspronkelijk_te_betalen =$te_betalen_bedrag->{$tweedejaar};
                 $mail_msg = $mail_msg."\t\t\t-> $tweedejaar $oorspronkelijk_te_betalen->$tebetalen -> herberekend \n";
                 print "\t\t\t-> $tweedejaar $oorspronkelijk_te_betalen->$tebetalen -> herberekend \n";
                 $te_betalen_bedrag->{$eerstejaar} = $tebetalen ;
                 $oorspronkelijk_te_betalen =$te_betalen_bedrag->{$eerstejaar};
                 $mail_msg = $mail_msg."\t\t\t-> $eerstejaar $oorspronkelijk_te_betalen->$tebetalen -> herberekend \n";
                 print "\t\t\t-> $eerstejaar $oorspronkelijk_te_betalen->$tebetalen -> herberekend \n";
            }
         
         return ($te_betalen_bedrag);
        }
     sub berekening_teruggave {
         my ($class,$zkf,$inz,$AS400_instellingen,$berekeningsjaren) = @_;
         my ($ext,$geboortejaar,$geboorte_maand) =  as400_gegevens->give_extern_nummer($zkf,$inz,$AS400_instellingen);
         my $terugbetalingen;
         my $bedrag_te_betalen;
         if ($ext == 0) {
              print "\n________________________________________________________\nrijksregnummer $inz -> $zkf -> onbekend extern $ext\n________________________________________________________\n";
              $mail_msg = $mail_msg."\n________________________________________________________\nrijksregnummer $inz -> $zkf -> onbekend extern $ext\n________________________________________________________\n";
               my @jaren_te_berekenen = split /,/,$berekeningsjaren;
               foreach my $jaar_te_berekenen (sort {$b <=> $a} @jaren_te_berekenen) {
                    $bedrag_te_betalen->{$jaar_te_berekenen} =0;
                    $terugbetalingen->{$jaar_te_berekenen} =0;
                }
               return ($bedrag_te_betalen,$terugbetalingen);
               
            }else {
             my ($terugbetalingen,$bericht) = as400_gegevens->get_betaalde_bedragen_vp($zkf,$ext,$AS400_instellingen,$berekeningsjaren);
             $main::mail_msg = $main::mail_msg."$bericht";       
             my ($plafond,$berichtp) = as400_gegevens->get_plafond_vp($zkf,$ext,$AS400_instellingen,$berekeningsjaren);
             $main::mail_msg = $main::mail_msg."$berichtp";   
             my @jaren_te_berekenen = split /,/,$berekeningsjaren;
             my $jaar_rangteller = 0;
             my $bedrag_te_betalen;
             my $vorige_keren_uitbetaald;
             foreach my $jaar_te_berekenen (sort {$b <=> $a} @jaren_te_berekenen) {
                  #is er een geldig contract voor dat jaar ?
                 #wat hebben we vorige keer uitbetaald
                 #print "jaar te berekenen  $jaar_te_berekenen \n_______________________ ___________\n";
                 $vorige_keren_uitbetaald->{$jaar_te_berekenen}  = 0;
                 if (defined $plafond->{$jaar_te_berekenen}->{bedrag} and $jaar_rangteller == 0) {
                     if ($vorige_keren_uitbetaald->{$jaar_te_berekenen} == 0) {
                         $bedrag_te_betalen->{$jaar_te_berekenen} =$plafond->{$jaar_te_berekenen}->{bedrag} /2  ; #helft van het plafond terug betalen 
                        }else {
                         $bedrag_te_betalen->{$jaar_te_berekenen} =$plafond->{$jaar_te_berekenen}->{bedrag} /2  - $vorige_keren_uitbetaald->{$jaar_te_berekenen} ; #helft van het plafond terug betalen 
                        }
                    }elsif (!defined $plafond->{$jaar_te_berekenen}->{bedrag}  and $jaar_rangteller == 0) {
                         my $jaar_span= "$jaar_te_berekenen\-$jaar_te_berekenen";
                         if ($terugbetalingen->{$jaar_span}->{bedrag_terugbetaald} == 0) {
                             $bedrag_te_betalen->{$jaar_te_berekenen} =$terugbetalingen->{$jaar_span}->{bedrag_VP}/2- $vorige_keren_uitbetaald->{$jaar_te_berekenen} ;        
                            }else {
                             #speciale soort MAF
                             print "$jaar_span speciale soort MAF\n";
                            }
                    }elsif ($plafond->{$jaar_te_berekenen}->{bedrag} >0 and $jaar_rangteller != 0) {
                         $bedrag_te_betalen->{$jaar_te_berekenen} = $plafond->{$jaar_te_berekenen}->{bedrag}/2 -$vorige_keren_uitbetaald->{$jaar_te_berekenen} ;
                                  
                    }elsif (!defined $plafond->{$jaar_te_berekenen}->{bedrag}  and $jaar_rangteller != 0) {
                         my $diffteller =1;
                         my $jaar_span;
                         foreach my $jaar_te_herrekenen (sort {$b <=> $a} @jaren_te_berekenen) {                     
                             $jaar_span->{0}= "$jaar_te_berekenen\-$jaar_te_berekenen";
                             until ( $diffteller > $jaar_rangteller ) {
                             my $diff_jaar = $jaar_te_berekenen+$diffteller;
                             $jaar_span->{$diffteller}= "$jaar_te_berekenen\-$diff_jaar";
                             $diffteller +=1;
                            }
                    }
                    $bedrag_te_betalen->{$jaar_te_berekenen} = 0;
                    foreach my $key (keys $jaar_span) {
                         my  $span = $jaar_span->{$key};
                         #my $test = $terugbetalingen->{$span}->{bedrag_terugbetaald};
                         #my $test1 = $terugbetalingen->{"$span"}->{bedrag_terugbetaald};
                         #print "$span test $test -> $test1\n";
                         if ($terugbetalingen->{$span}->{bedrag_terugbetaald} == 0) {
                             $bedrag_te_betalen->{$jaar_te_berekenen} += $terugbetalingen->{$span}->{bedrag_VP}/2;
                             print "$span -> $terugbetalingen->{$span}->{bedrag_VP}\n";
                            }else {
                             #speciaal soort MAF
                             print "$span speciale soort MAF\n";
                            }
                        }
                    $bedrag_te_betalen->{$jaar_te_berekenen} -=  $vorige_keren_uitbetaald->{$jaar_te_berekenen} ;
                    # print "bedrag_te_betalen $jaar_te_berekenen -> $bedrag_te_betalen->{$jaar_te_berekenen}\n";
                }
             
             $jaar_rangteller += 1;
         }
             print'';
             return ($bedrag_te_betalen,$terugbetalingen,$geboortejaar,$geboorte_maand);
            }      
        
     }
     
     print '';
     #sub load_AS400_settings  {
     #    my ($class,$file_name)= @_;
     #    print "$file_name\n";
     #    my $instellingen = XMLin("$file_name");
     #    foreach my $zkf (keys $instellingen->{as400}) {
     #        $instellingen->{as400}->{$zkf}->{password}=decrypt->new($instellingen->{as400}->{$zkf}->{password});
     #        $instellingen->{as400}->{$zkf}->{doccenter}->{password}=decrypt->new($instellingen->{as400}->{$zkf}->{doccenter}->{password});        
     #    }
     #   
     #    return ($instellingen);
     #   }
     sub load_agresso_setting  {
         my ($class,$file_name)= @_;
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
package App;
     use strict;
     use warnings;
     use base 'Wx::App';
     sub OnInit {
         $main::dialog = Frame->new();
         #$main::frame->Maximize( 1 );
         $main::dialog->SetSize(1, 1, 740, 280);
         $main::dialog->Centre();
         
         $main::dialog->Show(1);
        }
package Frame;
     use MIME::Base64;
     use Wx qw[:everything];
     use base qw(Wx::Frame);
     use Wx::Locale gettext => '_T';
     use LWP::Simple;
     use Win32::API;
     
     #my $old_charset = odfLocalEncoding(); #versie 5.2 charset utf8 
     #odfLocalEncoding('iso-8859-15');  #versie 5.2
      sub new {
               use warnings;
               use Wx qw(:everything);
               use base qw(Wx::Frame);
               use Data::Dumper;
               use Wx::Locale gettext => '_T';
               my($frame) = @_;
                my $ip = $main::agresso_instellingen->{"Agresso_IP_$main::mode"};   
               $frame = $frame->SUPER::new(undef, -1,_T("Berekeningsjaren Agresso $main::mode -> ip $ip ->  variant = $variant_LG04 "),
                                        [-1,-1],[340,280], wxDEFAULT_FRAME_STYLE | wxTAB_TRAVERSAL  );
               #$frame->Wx::Size->new(800,600) ;
               my $dryrun = 1;
               my $test =0;
               my $change_contracts = 0;
               $frame->{Frame_Sizer_1} = Wx::FlexGridSizer->new(6,7, 10, 10);
               $frame->{Frame_statictxt_Berekeningsjaar}= Wx::StaticText->new($frame, -1,_T("Berekeningsjaar"),wxDefaultPosition,wxSIZE(100,20));
               $frame->{Frame_Txt_Berekeningsjaar} = Wx::TextCtrl->new($frame, -1,'',wxDefaultPosition,wxSIZE(100,20));
               $frame->{Frame_statictxt_jaar_1}= Wx::StaticText->new($frame, -1,_T("jaar 1"),wxDefaultPosition,wxSIZE(100,20));
               $frame->{Frame_Txt__jaar_1} = Wx::TextCtrl->new($frame, -1,'',wxDefaultPosition,wxSIZE(100,20));
               $frame->{Frame_statictxt_jaar_2}= Wx::StaticText->new($frame, -1,_T("jaar 2"),wxDefaultPosition,wxSIZE(100,20));
               $frame->{Frame_Txt__jaar_2} = Wx::TextCtrl->new($frame, -1,'',wxDefaultPosition,wxSIZE(100,20));
               $frame->{Frame_statictxt_jaar_3}= Wx::StaticText->new($frame, -1,_T("jaar 3"),wxDefaultPosition,wxSIZE(100,20));
               $frame->{Frame_Txt__jaar_3} = Wx::TextCtrl->new($frame, -1,'',wxDefaultPosition,wxSIZE(100,20));
               #$frame->{Frame_statictxt_TEST}= Wx::StaticText->new($frame, -1,_T("TEST"),wxDefaultPosition,wxSIZE(100,20));
               #$frame->{Frame_chk_1_TEST}  = Wx::CheckBox->new($frame, -1,$test,wxDefaultPosition,wxSIZE(15,20));
               $frame->{Frame_statictxt_dryrun}= Wx::StaticText->new($frame, -1,_T("Dry run"),wxDefaultPosition,wxSIZE(100,20));
               $frame->{Frame_chk_1_dryrun}  = Wx::CheckBox->new($frame, -1,$dryrun,wxDefaultPosition,wxSIZE(15,20));
               #$frame->{Frame_statictxt_change_contracts}= Wx::StaticText->new($frame, -1,_T("Ander ->"),wxDefaultPosition,wxSIZE(100,20));
               #$frame->{Frame_chk_1_change_contracts}  = Wx::CheckBox->new($frame, -1,$change_contracts,wxDefaultPosition,wxSIZE(15,20));
               #$frame->{Frame_statictxt_Nieuw_starjaar}= Wx::StaticText->new($frame, -1,_T("Startjaar Contract"),wxDefaultPosition,wxSIZE(100,20));
               #$frame->{Frame_Txt_Nieuw_starjaar} = Wx::TextCtrl->new($frame, -1,'',wxDefaultPosition,wxSIZE(100,20));
               #$frame->{Frame_statictxt_aantal}= Wx::StaticText->new($frame, -1,_T("testaantal"),wxDefaultPosition,wxSIZE(100,20));
               #$frame->{Frame_Txt_aantal} = Wx::TextCtrl->new($frame, -1,'',wxDefaultPosition,wxSIZE(100,20));
               $frame->{Frame_panel_1} = Wx::Panel->new($frame,-1,wxDefaultPosition,wxSIZE(60,20));
               $frame->{Frame_Button_OK}  = Wx::Button->new($frame, -1, _T("OK"),wxDefaultPosition,wxSIZE(60,20));
               $frame->{Frame_Cancel}  = Wx::Button->new($frame, -1, _T("Cancel"),wxDefaultPosition,wxSIZE(60,20));
               #rij1
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               #rij2
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_statictxt_Berekeningsjaar}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_statictxt_jaar_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_statictxt_jaar_2}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_statictxt_jaar_3}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_statictxt_dryrun}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               #rij3
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_Txt_Berekeningsjaar}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_Txt__jaar_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_Txt__jaar_2}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_Txt__jaar_3}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_chk_1_dryrun}, 0, wxALIGN_BOTTOM|wxALIGN_LEFT);
               #rij4
               #$frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               #$frame->{Frame_Sizer_1}->Add($frame->{Frame_chk_1_TEST}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               ##$frame->{Frame_Sizer_1}->Add($frame->{Frame_statictxt_TEST}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               #$frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               #$frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               #$frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               #$frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               #rij5
               #$frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               #$frame->{Frame_Sizer_1}->Add($frame->{Frame_chk_1_change_contracts}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               #$frame->{Frame_Sizer_1}->Add($frame->{Frame_statictxt_change_contracts}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);             
               #$frame->{Frame_Sizer_1}->Add($frame->{Frame_statictxt_Nieuw_starjaar}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               #$frame->{Frame_Sizer_1}->Add($frame->{Frame_Txt_Nieuw_starjaar}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               #$frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               #$frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT); 
               #rij4
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               #rij5
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_Button_OK}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_Cancel}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               #rij6
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_chk_1_dryrun}->SetValue(1);
               Wx::Event::EVT_TEXT_ENTER($frame,$frame->{Frame_Txt_Berekeningsjaar},\&Berekeningsjaar_ingevuld);
               #Wx::Event::EVT_CHECKBOX($frame,$frame->{Frame_chk_1_TEST},\&testrun);
               Wx::Event::EVT_TEXT($frame,$frame->{Frame_Txt_Berekeningsjaar},\&Berekeningsjaar_ingevuld);
               Wx::Event::EVT_BUTTON($frame,$frame->{Frame_Button_OK},\&OK);
               Wx::Event::EVT_BUTTON($frame,$frame->{Frame_Cancel},\&Cancel);
             
               $frame->SetSizer($frame->{Frame_Sizer_1});
               $frame->SetBackgroundColour(Wx::Colour->new(239, 243, 255));
               return ($frame);
            }
      sub testrun {
         my($frame)= @_;
         my $bjaar  = $frame->{Frame_Txt_Berekeningsjaar}->GetValue();
         my $dialog = Wx::PasswordEntryDialog->new($frame, "uw paswoord", "Dit veegt alles uit","s3cr3t" );
         my $vink = $frame->{Frame_chk_1_TEST}->GetValue();
         if ($vink ==0) {
              $frame->{Frame_chk_1_TEST}->SetValue(0);
         }else {
              if( $dialog->ShowModal == wxID_CANCEL ) {
                 $frame->{Frame_chk_1_TEST}->SetValue(0);  
                } else {
                 my $paswd  = $dialog->GetValue() ;
                 if ($paswd eq 'Neltijs4711') {
                     $frame->{Frame_chk_1_TEST}->SetValue(1);
                    }else {
                     $frame->{Frame_chk_1_TEST}->SetValue(0);  
                    }
                }
            }
         
         $dialog->Destroy;
        }
      sub Berekeningsjaar_ingevuld {
         my($frame)= @_;           
         my $bjaar  = $frame->{Frame_Txt_Berekeningsjaar}->GetValue();
         my $jaar1  = $frame->{Frame_Txt__jaar_1}->SetValue($bjaar-1);
         my $jaar2  = $frame->{Frame_Txt__jaar_2}->SetValue($bjaar-2);
         my $jaar3  = $frame->{Frame_Txt__jaar_3}->SetValue($bjaar-3);
      }
   
      sub OK {
           my($frame)= @_;           
           my $huidig_jaar =  $frame->{Frame_Txt_Berekeningsjaar}->GetValue();
           if ($huidig_jaar > 2014 and $huidig_jaar < 2024) {
             my $dryrun = $frame->{Frame_chk_1_dryrun}->GetValue();
             if ($dryrun == 0 ) {
                  my( $answer ) =  Wx::MessageBox(
                                'Opgelet gaat echt facturen aanmaken?','vink dryrun aan om enkel het verslag te zien',
                                 Wx::wxYES_NO()|Wx::wxICON_EXCLAMATION,#Wx::wxICON_EXCLAMATION(),   # if you use Wx ':everything', it's wxYES_NO
                                 undef,			  # you needn't pass anything, much less $frame
                    );
                  if( $answer == Wx::wxYES() ) {
                     # save options
                     main->maak_betalingen_aan($huidig_jaar,$dryrun);
                     mail->mail_bericht($main::mail_msg);
                     }	
                }elsif ($dryrun == 1)   {
                 my( $answer ) =  Wx::MessageBox(
                                'Dit geeft je enkel een verslag','doe de vink bij dryrun weg om de facturen te maken',
                                 Wx::wxYES_NO()|Wx::wxICON_EXCLAMATION,#Wx::wxICON_EXCLAMATION(),   # if you use Wx ':everything', it's wxYES_NO
                                 undef,			  # you needn't pass anything, much less $frame
                    );
                  if( $answer == Wx::wxYES() ) {
                         # save options
                         main->maak_betalingen_aan($huidig_jaar,$dryrun);
                         mail->mail_bericht($main::mail_msg);
                     }	
                }      
            }else {
             my( $answer ) =  Wx::MessageBox(
                                'Contacteer Harry Conings 0475464289 om deze te verlengen','Licentie verlopen',
                                 Wx::wxOK()|Wx::wxICON_EXCLAMATION,#Wx::wxICON_EXCLAMATION(),   # if you use Wx ':everything', it's wxYES_NO
                                 undef,			  # you needn't pass anything, much less $frame
                    );
           }
           #my $decode = decrypt->new($ecrypted_password);
           #print "encode->$password -> $decode\n" ;
        }
      sub Cancel {
         die;
      }
package mail;
     #use Date::Calc qw(:all);
     use Date::Manip::DM5;
     sub mail_bericht {
         my ($class,$mail_msg) = @_;
         #print "mail-start\n";
         my $aan = $main::agresso_instellingen->{mail_verslag_naar};
         my @aan_lijst = split (/\,/,$aan);
         my $van = 'harry.conings@vnz.be';
         my $vandaag = ParseDate("today");
         $vandaag = substr ($vandaag,0,8);  # vandaag in YYYYMMDD
         $vandaag = sprintf "%04d-%02d-%02d",substr ($vandaag,0,4),substr ($vandaag,4,2),substr ($vandaag,6,2);
          foreach my $geadresseerde (@aan_lijst) {
             my $smtp = Net::SMTP->new('10.63.120.3',
                    Hello => 'mail.vnz.be',
                    Timeout => 60);
             $smtp->auth('mailprogrammas','pleintje203');
             $smtp->mail($van);
             $smtp->to($geadresseerde);
             #$smtp->cc('informatica.mail@vnz.be');
             #$smtp->bcc("bar@blah.net");
             $smtp->data;
             $smtp->datasend("From: harry.conings");
             $smtp->datasend("\n");
             $smtp->datasend("To: Kaartbeheerders");
             $smtp->datasend("\n");
             $smtp->datasend("Subject: Agresso maf facturen inzetten $vandaag");
             $smtp->datasend("\n");
             $smtp->datasend("$mail_msg\nvriendelijke groeten\nHarry Conings");
             $smtp->dataend;
             $smtp->quit;
             print "mail aan $geadresseerde  gezonden\n";
            }
          print "\neinde\n";
          die;
        }
package excel;
     use Win32::OLE;
     use Win32::OLE::Const 'Microsoft Excel';
     use Date::Manip::DM5;
     sub new {     
         #excel tabel openen
         my ($self,$eerstejaar,$tweedejaar,$derdejaar) = @_;
         my $Excel = Win32::OLE->GetActiveObject('Excel.Application')
        	|| Win32::OLE->new('Excel.Application', 'Quit');
         $Excel->{'Visible'} = 1;  # toon wat je doet is 1
         # open Excel file
         my $test = $main::agresso_instellingen;
         my $sjabloon = $main::agresso_instellingen->{maf_sjabloon};
         my $Book = $Excel->Workbooks->Open($sjabloon );
         my $Sheet = $Book->Worksheets(1);
         $Sheet->{Name} = 'MAF uitbetaling';
          my $inhoudcel= $Sheet->Cells(3,1);
         $inhoudcel->{Value} = "Naam";
         $inhoudcel= $Sheet->Cells(3,2);
         $inhoudcel->{Value} = "Rijksregister nr";
         $inhoudcel= $Sheet->Cells(3,3);
         $inhoudcel->{Value} = "Begin";
         $inhoudcel= $Sheet->Cells(3,4);
         $inhoudcel->{Value} = "Recht";
         $inhoudcel= $Sheet->Cells(3,5);
         $inhoudcel->{Value} = "Eind";
         $inhoudcel= $Sheet->Cells(3,6);
         $inhoudcel->{Value} = "$derdejaar\n\n MAF";
         $inhoudcel= $Sheet->Cells(3,7);
         $inhoudcel->{Value} = "$derdejaar\n te\n betalen";
         $inhoudcel= $Sheet->Cells(3,8);
         $inhoudcel->{Value} = "$derdejaar\n al\n betaald";
         $inhoudcel= $Sheet->Cells(3,9);
         $inhoudcel->{Value} = "$derdejaar\n\n betaald";
         $inhoudcel= $Sheet->Cells(3,10);
         $inhoudcel->{Value} = "$tweedejaar\n\n MAF";
         $inhoudcel= $Sheet->Cells(3,11);
         $inhoudcel->{Value} = "$tweedejaar\n te\n betalen";
         $inhoudcel= $Sheet->Cells(3,12);
         $inhoudcel->{Value} = "$tweedejaar\n al\n betaald";
         $inhoudcel= $Sheet->Cells(3,13);
         $inhoudcel->{Value} = "$tweedejaar\n\n betaald";
         $inhoudcel= $Sheet->Cells(3,14);
         $inhoudcel->{Value} = "$eerstejaar\n\n MAF";
         $inhoudcel= $Sheet->Cells(3,15);
         $inhoudcel->{Value} = "$eerstejaar\n te\n betalen";
         $inhoudcel= $Sheet->Cells(3,16);
         $inhoudcel->{Value} = "$eerstejaar\n al\n betaald";
         $inhoudcel= $Sheet->Cells(3,17);
         $inhoudcel->{Value} = "$eerstejaar\n\n betaald";
         $inhoudcel= $Sheet->Cells(3,18);
         $inhoudcel->{Value} = "Totaal";
         $inhoudcel= $Sheet->Cells(3,19);
         $inhoudcel->{Value} = "Bankrekening";
         $inhoudcel= $Sheet->Cells(3,20);
         $inhoudcel->{Value} = "Agresso\n ID";
         $inhoudcel= $Sheet->Cells(3,21);
         $inhoudcel->{Value} = "ZKF";
         return ($Excel,$Book,$Sheet,4);
        }
     sub schrijf_rij{
         my ($self,$Excel,$Book,$Sheet,$rijteller,$excel_rij) = @_;
         my $inhoudcel= $Sheet->Cells($rijteller,1);
         $inhoudcel->{Value} =$excel_rij->{naam};
         $inhoudcel= $Sheet->Cells($rijteller,2);
         $inhoudcel->{Value} =$excel_rij->{inz};
         $inhoudcel= $Sheet->Cells($rijteller,3);
         $inhoudcel->{Value} =$excel_rij->{begincontract};
         #my $begincontract = $excel_rij->{begincontract};
         #my $beginmaand = substr ($begincontract,4,2);
         #$beginmaand +=3;
         #my $aantalmaanden = 13 -$beginmaand;
         #$aantalmaanden = 0 if ($beginmaand > 12);
         #my $percent = $aantalmaanden/12*100;
         $inhoudcel= $Sheet->Cells($rijteller,4);
         $inhoudcel->{Value} =$excel_rij->{begin_recht};
         $inhoudcel= $Sheet->Cells($rijteller,5);
         $inhoudcel->{Value} =$excel_rij->{eindcontract};
         $inhoudcel= $Sheet->Cells($rijteller,6);
         $inhoudcel->{Value} =$excel_rij->{derdejaar_maf};
         $inhoudcel= $Sheet->Cells($rijteller,7);
         $inhoudcel->{Value} =$excel_rij->{derdejaar_te_betalen};
         $inhoudcel= $Sheet->Cells($rijteller,8);
         $inhoudcel->{Value} =$excel_rij->{derdejaar_al_betaald};
         $inhoudcel= $Sheet->Cells($rijteller,9);
         $inhoudcel->{Value} =$excel_rij->{derdejaar_som};
         $inhoudcel= $Sheet->Cells($rijteller,10);
         $inhoudcel->{Value} =$excel_rij->{tweedejaar_maf};
         $inhoudcel= $Sheet->Cells($rijteller,11);
         $inhoudcel->{Value} =$excel_rij->{tweedejaar_te_betalen};
         $inhoudcel= $Sheet->Cells($rijteller,12);
         $inhoudcel->{Value} =$excel_rij->{tweedejaar_al_betaald};
         $inhoudcel= $Sheet->Cells($rijteller,13);
         $inhoudcel->{Value} =$excel_rij->{tweedejaar_som};
         $inhoudcel= $Sheet->Cells($rijteller,14);
         $inhoudcel->{Value} =$excel_rij->{eerstejaar_maf};
         $inhoudcel= $Sheet->Cells($rijteller,15);
         $inhoudcel->{Value} =$excel_rij->{eerstejaar_te_betalen};
         $inhoudcel= $Sheet->Cells($rijteller,16);
         $inhoudcel->{Value} =$excel_rij->{eerstejaar_al_betaald};
         $inhoudcel= $Sheet->Cells($rijteller,17);
         $inhoudcel->{Value} =$excel_rij->{eerstejaar_som};           
         my $som = $excel_rij->{eerstejaar_som}+$excel_rij->{tweedejaar_som}+ $excel_rij->{derdejaar_som};          
         $inhoudcel= $Sheet->Cells($rijteller,18);
         $inhoudcel->{Value} =$som;
         $inhoudcel= $Sheet->Cells($rijteller,19);
         $inhoudcel->{Value} =$excel_rij->{bankrekening};
         $inhoudcel= $Sheet->Cells($rijteller,20);
         $inhoudcel->{Value} =$excel_rij->{agresso_id};
         $inhoudcel= $Sheet->Cells($rijteller,21);
         $inhoudcel->{Value} =$excel_rij->{zkf};
        
        
                     #'eerstejaar' => $eerstejaar,
                     #'eerstejaar_maf' => $eerstejaarsmaf,
                     #'eerstejaar_te_betalen'
                     #'eerstejaar_al_betaald'
                     #'eerstejaar_som'
                     #'derdejaar' =>$derdejaar,
                     #'derdejaar_maf' =>$derdejaarmaf,
                     #'derdejaar_te_betalen'
                     #'derdejaar_al_betaald'
                     #'derdejaar_som'
                      #'agresso_id' => $client_id,
                     #'inz' => $inz,
                     #'naam' =>$naam,
                     #'begincontract' => $begindatum,
                     #'wachtcontract' =>  $wachtdatum,
                     #'eindcontract' => $einddatum,
                     #'tweedejaar' => $tweedejaar,
                     #'tweedejaar_maf' => $tweedejaarmaf,
                     #'tweedejaar_te_betalen'
                     #'tweedejaar_al_betaald'
                     #'tweedejaar_som'
                
        }
   
     sub save_excel {
         my ($self,$Excel) = @_;
         my $vandaag = ParseDate("today");
         $vandaag = substr ($vandaag,0,8);  # vandaag in YYYYMMDD
         $vandaag = sprintf "%04d-%02d-%02d",substr ($vandaag,0,4),substr ($vandaag,4,2),substr ($vandaag,6,2);
         my $path_to_files =$main::agresso_instellingen->{maf_verslag};
         $Excel->ActiveWorkbook->SaveAs("$path_to_files\\$vandaag-MAF.xls");
         $Excel->ActiveWorkbook->Close(1);
         $Excel->Quit();
         return ($Excel);
        }