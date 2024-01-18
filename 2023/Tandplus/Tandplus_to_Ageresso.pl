#!/usr/bin/perl -w
#OPGELET!!!!!!
#Dit programma is auteursrechtelijk beschermd.
#Deze code is volledig eigendom van de Firma  I.C.E. (liebroekstraat 43 3545 Halen BE0446888007) .
#Deze code mag enkel gebruikt worden met jaarlijkse toestemming van Harry Conings 0475464286 harry@ice.be harry@icebutler.com
#Indien dit toch gebeurt is er een boete verschuldigd van 250.000 EUR exclusief btw aan de Firma  I.C.E.
#Deze code mag niet aan derden (ook niet VNZ en NZVL) getoond worden tenzij met uitdrukkelijke en schriftelijke toestemming van I.C.E. bvba .
#Indien dit toch gebeurt is er een boete verschuldigd van 250.000 EUR exclusief btw aan de Firma  I.C.E.
#Dit geldt ook voor het kopieren van een stuk code of het repliceren van technieken gehanteerd in dit programma
#I.C.E. beheert de broncode je mag  geen veranderingen aanbrengen aan het programma . 
require 'Decryp_Encrypt.pl';
require 'package_as400_gegevens_prod.pl';
require 'package_sql_toegang_agresso_prod.pl';
require 'package_agresso_get_calculater_info_prod.pl';
require 'package_invoice_to_agresso_prod.pl';
require 'package_assurcard_calculation_settings_prod.pl';
require 'package_agresso_get_Tandplus_jaar_prod.pl';
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
our  $agresso_instellingen;
our $AS400_instellingen;
our $calc_instelingen;
our  @verzekeringen_in_xml;
our @ubw_al_gefactureerd = ();
package main;
     use Win32::OLE;
     use Win32::OLE::Const 'Microsoft Excel';
     our $mode = 'PROD'; #TEST voor test   PROG voor productie
     $mode = $ARGV[0] if (defined $ARGV[0]);
     if ( $mode eq 'TEST' or $mode eq 'PROD'){}else{die}
     our $klant;
     our $mail_msg;
     our $variant_LG04 =3;
     $mail_msg = "OVERZICHT VAN DE TANDPLUS UITBETALINGEN \n____________________________________________\n";
     print "OVERZICHT VAN DE TANDPLUS UITBETALINGEN \n____________________________________________\n";
     print "D:\\OGV\\ASSURCARD_2023\\assurcard_settings_xml\\TandPlus_agresso_settings.xml\n";
     main->load_agresso_setting("D:\\OGV\\ASSURCARD_2023\\assurcard_settings_xml\\TandPlus_agresso_settings.xml"); #nagekeken
     foreach my $zkf1 (keys $agresso_instellingen->{as400}) {
        $agresso_instellingen->{as400}->{$zkf1}->{password} = decrypt->new($agresso_instellingen->{as400}->{$zkf1}->{password});
     }
     $calc_instelingen = assurcard_calculation_settings->new();
     my $app = App->new();          
     $app->MainLoop;
     print ;
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
     sub maak_betalingen_aan  {
         my ($class,$huidig_jaar,$dryrun,$contractstartdat) = @_;       
         my $eerstejaar =$huidig_jaar-1;
         my $tweedejaar = $huidig_jaar-2;
         my $derdejaar = $huidig_jaar-3;
         my ($Excel,$Book,$Sheet,$rijteller) = excel->new($eerstejaar,$tweedejaar,$derdejaar);
         my $calc_jaar = "periode_$eerstejaar"."0101-$eerstejaar"."1231";        
         my $verkoopsdagboek = $calc_instelingen->{"$calc_jaar"}->{verzekeringen}->{tandplus}->{verkoopsdagboek};
         my $nomenclatuur = ''; #REMGELDEN MAF
         
         eval {foreach my $groep (keys $calc_instelingen->{"$calc_jaar"}->{verzekeringen}->{tandplus}->{groep}){}};
         if (!$@) {
             foreach my $groep (keys $calc_instelingen->{"$calc_jaar"}->{verzekeringen}->{tandplus}->{groep}){
                 eval {my $nom_naam =uc $calc_instelingen->{"$calc_jaar"}->{verzekeringen}->{tandplus}->{groep}->[$groep]->{nomenclatuur}->{naam};};
                 if (!$@) {
                     my $nom_naam =uc $calc_instelingen->{"$calc_jaar"}->{verzekeringen}->{tandplus}->{groep}->[$groep]->{nomenclatuur}->{naam};
                     if ($nom_naam =~ m/WETTELIJKE REMGELDEN/i) {
                         $nomenclatuur = $calc_instelingen->{"$calc_jaar"}->{verzekeringen}->{tandplus}->{groep}->[$groep]->{nomenclatuur}->{nummer};
                        }
                    }
                }
            }   
         if ($nomenclatuur ne '') {
              my $berekeningsjaren=  "$eerstejaar,$tweedejaar,$derdejaar";
              $mail_msg = $mail_msg."\nBerekeningsjaren : $eerstejaar,$tweedejaar,$derdejaar\n";
              print "\nBerekeningsjaren : $eerstejaar,$tweedejaar,$derdejaar\n";
              my $dbh_agresso = sql_toegang_agresso->setup_mssql_connectie ($mode);
              my $contract_start_jaar = $huidig_jaar;              
              my ($tandplussers,$aantal_tandplussers) = sql_toegang_agresso->get_contracts_by_type($dbh_agresso,'TANDPLUS',$contract_start_jaar);
              my $maanden_wachttijd= 3;
              my $test_teller = 0;
              my $teller_al_gedaan =0;
             foreach my $client_id (sort keys $tandplussers) {
               #print "$test_teller $client_id\n";
               if ($client_id ~~ @ubw_al_gefactureerd) {
                  $teller_al_gedaan +=1;
                  print"$teller_al_gedaan $client_id al gedaan\n";
               }else{
                  #my @proefpersonen = (127891,128759,128769,128770,128884,129063,132934,132935,132936,134389,134473,136710,137487);  
                  #my @proefpersonen = (100624,102177,103783,103955,104863,106730,107350,109520,110102,2016991,219483,219642,220494,221264);
                  #my @proefpersonen = (220224,220744);
                  #my @proefpersonen = (133388,134189,135411);
                  # if ($client_id ~~ @proefpersonen){ 
                if ($client_id != 999999){   #for testing purposes if ( $client_id = 109690 )  if ( $client_id = 191887 )if ( $client_id != 999999
                   my $excel_rij;
                   $test_teller += 1;                 
                   my $begindatum = $tandplussers->{$client_id}->{begin_datum};
                   my $wachtdatum = $tandplussers->{$client_id}->{wacht_datum};
                   my $einddatum =  $tandplussers->{$client_id}->{eind_datum};
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
                   my $zkf =  $tandplussers->{$client_id}->{zkf};
                   my $contractnr =  $tandplussers->{$client_id}->{contract_nr};
                   my ($klant) = main->berekening_teruggave($zkf,$klant->{Rijksreg_Nr},$main::agresso_instellingen,$berekeningsjaren);
                   my $inz =$klant->{Rijksreg_Nr};
                   my $naam = $klant->{naam};
                   $mail_msg = $mail_msg."\t\t$client_id $inz $naam begin $begindatum wacht $wachtdatum eind $einddatum\n";
                   # 2024 aapassing  
                   my $eerstejaar_Remgeld_TandPlus = $klant->{TandPlus}->{$eerstejaar}->{totalen}->{totaal_remgeld};
                   $eerstejaar_Remgeld_TandPlus += $klant->{TandPlus_archief}->{$eerstejaar}->{totalen}->{totaal_remgeld} if $klant->{TandPlus_archief}->{$eerstejaar}->{totalen}->{totaal_remgeld};
                   my $tweedejaar_Remgeld_TandPlus = $klant->{TandPlus}->{$tweedejaar}->{totalen}->{totaal_remgeld};
                   # $tweedejaar_Remgeld_TandPlus += $klant->{TandPlus_archief}->{$tweedejaar}->{totalen}->{totaal_remgeld} if $klant->{TandPlus_archief}->{$tweedejaar}->{totalen}->{totaal_remgeld};
                   my $derdejaar_Remgeld_TandPlus = $klant->{TandPlus}->{$derdejaar}->{totalen}->{totaal_remgeld};
                   # $derdejaar_Remgeld_TandPlus += $klant->{TandPlus_archief}->{$derdejaar}->{totalen}->{totaal_remgeld} if $klant->{TandPlus_archief}->{$derdejaar}->{totalen}->{totaal_remgeld};
                   my $eerstejaar_al_betaald_Remgeld_TandPlus = abs($klant->{TandPlus}->{$eerstejaar}->{totalen}->{al_betaald_remgeld_door_VMOB});
                   my $tweedejaar_al_betaald_Remgeld_TandPlus = abs($klant->{TandPlus}->{$tweedejaar}->{totalen}->{al_betaald_remgeld_door_VMOB});
                   my $derdejaar_al_betaald_Remgeld_TandPlus = abs($klant->{TandPlus}->{$derdejaar}->{totalen}->{al_betaald_remgeld_door_VMOB});         
                   $excel_rij = {
                       'agresso_id' => $client_id,
                       'inz' => $inz,
                       'naam' =>$naam,
                       'begincontract' => $begindatum,
                       'wachtcontract' =>  $wachtdatum,
                       'eindcontract' => $einddatum,
                       'eerstejaar' => $eerstejaar,
                       'eerstejaar_Remgeld_TandPlus' => $eerstejaar_Remgeld_TandPlus,
                       'eerstejaar_al_betaald_Remgeld_TandPlus' => $eerstejaar_al_betaald_Remgeld_TandPlus,
                       'tweedejaar' => $tweedejaar,
                       'tweedejaar_Remgeld_TandPlus' => $tweedejaar_Remgeld_TandPlus,
                       'tweedejaar_al_betaald_Remgeld_TandPlus' => $tweedejaar_al_betaald_Remgeld_TandPlus,
                       'derdejaar' =>$derdejaar,
                       'derdejaar_Remgeld_TandPlus' => $derdejaar_Remgeld_TandPlus,
                       'derdejaar_al_betaald_Remgeld_TandPlus' => $derdejaar_al_betaald_Remgeld_TandPlus,
                       'bankrekening' => $klant->{Bankrekening},
                       'zkf' =>$zkf,
                   };
                   print "execl  $excel_rij->{agresso_id} , $excel_rij->{eerstejaar_Remgeld_TandPlus}\n ";
                   print "\t\t$client_id $inz $naam begin $begindatum wacht $wachtdatum eind $einddatum\n";
                   $mail_msg = $mail_msg."\t\t$eerstejaar ->remgeld  $eerstejaar_Remgeld_TandPlus ->remgeld al betaald $eerstejaar_al_betaald_Remgeld_TandPlus \n";
                   print "\t\t$eerstejaar -> $eerstejaar_Remgeld_TandPlus ->$eerstejaar_al_betaald_Remgeld_TandPlus \n";
                   $mail_msg = $mail_msg."\t\t$tweedejaar ->$tweedejaar_Remgeld_TandPlus -> $tweedejaar_al_betaald_Remgeld_TandPlus\n";
                   print "\t\t$tweedejaar ->$tweedejaar_Remgeld_TandPlus -> $tweedejaar_al_betaald_Remgeld_TandPlus\n";
                   $mail_msg = $mail_msg."\t\t$derdejaar ->$derdejaar_Remgeld_TandPlus -> $derdejaar_al_betaald_Remgeld_TandPlus\n";
                   print "\t\t$derdejaar ->$derdejaar_Remgeld_TandPlus -> $derdejaar_al_betaald_Remgeld_TandPlus\n";
                   print "";
                   my $al_betaald =0;
                   #my $al_betaald = sql_toegang_agresso->get_maf_payment_info($dbh_agresso,$client_id,$eerstejaar,$tweedejaar,$derdejaar);
                   my $wat_we_betalen ;
                   my $maximum_jaar = $main::agresso_instellingen->{Tandplus_maximum};
                   my $maximum_remgeld_jaar = $main::agresso_instellingen->{Tandplus_remgeld_maximum};
                   $mail_msg = $mail_msg."\t\tWat we moeten betalen is wat we betaald hebben - wat we al betaald hebben met een maximum van $maximum_jaar \n";
                   print "\t\tWat we moeten betalen is wat we betaald hebben - wat we al betaald hebben met een maximum van $maximum_jaar\n";
                   my $Tandplusprocent = $agresso_instellingen->{Tandplus_remgeld_procent};
                   if ($eerstejaar_Remgeld_TandPlus != 0) {
                     $excel_rij->{eerstejaar_Remgeld_te_betalen} = $eerstejaar_Remgeld_TandPlus*$Tandplusprocent/100 ;
                    }else{
                      $excel_rij->{eerstejaar_Remgeld_te_betalen} =0; 
                    }
                   if ($tweedejaar_Remgeld_TandPlus != 0) {
                     $excel_rij->{tweedejaar_Remgeld_te_betalen} = $tweedejaar_Remgeld_TandPlus*$Tandplusprocent/100 ;
                   }else {
                     $excel_rij->{tweedejaar_Remgeld_te_betalen} = 0;
                   }
                   if ($derdejaar_Remgeld_TandPlus != 0) {
                     $excel_rij->{derdejaar_Remgeld_te_betalen} =  $derdejaar_Remgeld_TandPlus*$Tandplusprocent/100 ;
                   }else {
                     $excel_rij->{derdejaar_Remgeld_te_betalen} = 0;
                   }
                   
                   my $al_betaald_eerstejaar = abs($klant->{TandPlus}->{$eerstejaar}->{totalen}->{al_betaald_door_VMOB});
                   $excel_rij->{eerstejaar_al_betaald_TandPlus}= $al_betaald_eerstejaar;
                   $excel_rij->{eerstejaar_Remgeld_te_betalen} = $maximum_remgeld_jaar if ($excel_rij->{eerstejaar_Remgeld_te_betalen} > $maximum_remgeld_jaar);
                   $excel_rij->{wat_we_betalen_eerstejaar} = $excel_rij->{eerstejaar_Remgeld_te_betalen};                 
                   if ($excel_rij->{eerstejaar_Remgeld_te_betalen}+ $al_betaald_eerstejaar >= $maximum_jaar) {
                       if ($al_betaald_eerstejaar >= $maximum_jaar) {
                          $excel_rij->{wat_we_betalen_eerstejaar} = 0;
                       }else {
                          $excel_rij->{wat_we_betalen_eerstejaar} = $maximum_jaar - $al_betaald_eerstejaar;
                       }
                    }
                   my $al_betaald_tweedejaar =abs($klant->{TandPlus}->{$tweedejaar}->{totalen}->{al_betaald_door_VMOB});
                   $excel_rij->{tweedejaar_al_betaald_TandPlus}= $al_betaald_tweedejaar;
                   $excel_rij->{tweedejaar_Remgeld_te_betalen} = $maximum_remgeld_jaar if ($excel_rij->{tweedejaar_Remgeld_te_betalen} > $maximum_remgeld_jaar);
                   $excel_rij->{wat_we_betalen_tweedejaar} = $excel_rij->{tweedejaar_Remgeld_te_betalen};
                   if ($excel_rij->{tweedejaar_te_betalen}+ $al_betaald_tweedejaar >= $maximum_jaar) {
                       if ($al_betaald_tweedejaar>= $maximum_jaar) {
                          $excel_rij->{wat_we_betalen_tweedejaar} = 0;
                       }else {
                          $excel_rij->{wat_we_betalen_tweedejaar} = $maximum_jaar - $al_betaald_tweedejaar;
                       }
                    }
                   my $al_betaald_derdejaar =abs($klant->{TandPlus}->{$derdejaar}->{totalen}->{al_betaald_door_VMOB});
                   $excel_rij->{derdejaar_al_betaald_TandPlus}= $al_betaald_derdejaar;
                   $excel_rij->{derdejaar_Remgeld_te_betalen} = $maximum_remgeld_jaar if ($excel_rij->{derdejaar_Remgeld_te_betalen} > $maximum_remgeld_jaar);
                   $excel_rij->{wat_we_betalen_derdejaar} = $excel_rij->{derdejaar_Remgeld_te_betalen};
                   if ($excel_rij->{derdejaar_te_betalen}+ $al_betaald_derdejaar >= $maximum_jaar) {
                       if ($al_betaald_derdejaar>= $maximum_jaar) {
                          $excel_rij->{wat_we_betalen_derdejaar} = 0;
                       }else {
                          $excel_rij->{wat_we_betalen_derdejaar} = $maximum_jaar - $al_betaald_derdejaar;
                       }
                    }             
                 
                  #$excel_rij->{eerstejaar_al_betaald} = $al_betaald_eerstejaar;
                  #$excel_rij->{tweedejaar_al_betaald} = $al_betaald_tweedejaar;
                  #$excel_rij->{derdejaar_al_betaald} =  $al_betaald_derdejaar;
                  $excel_rij->{wat_we_betalen_eerstejaar} =  sprintf "%.2f",$excel_rij->{wat_we_betalen_eerstejaar};
                  $excel_rij->{wat_we_betalen_tweedejaar} =  sprintf "%.2f",$excel_rij->{wat_we_betalen_tweedejaar};
                  $excel_rij->{wat_we_betalen_derdejaar} =  sprintf "%.2f",$excel_rij->{wat_we_betalen_derdejaar};
                  print '';
                  # $wat_we_betalen->{$eerstejaar} = sprintf "%.2f", $wat_we_betalen->{$eerstejaar};  # rounded to 2 decimal places (0.67)
                  # $wat_we_betalen->{$tweedejaar} = sprintf "%.2f", $wat_we_betalen->{$tweedejaar};  # rounded to 2 decimal places (0.67)   
                  # $wat_we_betalen->{$derdejaar} = sprintf "%.2f", $wat_we_betalen->{$derdejaar};  # rounded to 2 decimal places (0.67)   
                  # my $t_betaal =$te_betalen_bedrag->{$derdejaar} ;
                  # my $a_betaal = $al_betaald->{$derdejaar};
                  # my $w_betaal = $wat_we_betalen->{$derdejaar};
                  # $excel_rij->{derdejaar_som} =$w_betaal;
                  # $mail_msg = $mail_msg."\t\t\t$derdejaar -> $w_betaal = $t_betaal -$a_betaal\n";
                  # print "\t\t\t$derdejaar -> $w_betaal = $t_betaal -$a_betaal\n";
                  # $t_betaal =$te_betalen_bedrag->{$tweedejaar} ;
                  # $a_betaal = $al_betaald->{$tweedejaar};
                  # $w_betaal = $wat_we_betalen->{$tweedejaar};
                  # $excel_rij->{tweedejaar_som} =$w_betaal;
                  # $mail_msg = $mail_msg."\t\t\t$tweedejaar -> $w_betaal = $t_betaal -$a_betaal\n";
                  # print "\t\t\t$tweedejaar -> $w_betaal = $t_betaal -$a_betaal\n";
                  # $t_betaal =$te_betalen_bedrag->{$eerstejaar} ;
                  # $a_betaal = $al_betaald->{$eerstejaar};
                  # $w_betaal = $wat_we_betalen->{$eerstejaar};
                  # $excel_rij->{eerstejaar_som} =$w_betaal;
                  # $mail_msg = $mail_msg."\t\t\t$eerstejaar -> $w_betaal = $t_betaal -$a_betaal\n";
                  # print "\t\t\t$eerstejaar -> $w_betaal = $t_betaal -$a_betaal\n";
                  # print '';
                  excel->schrijf_rij($Excel,$Book,$Sheet,$rijteller,$excel_rij);
                  $rijteller +=1;
                  # #my ($class,$klant,$naam_verzekering,$verkoopsdagboek,$nomenclatuur,$wat_we_moeten_betalen,$eerstejaar,$tweedejaar,$derdejaar) = @_;
                   
                   if ($dryrun !=1 ) {
                       my $wat_we_moeten_betalen;
                       $wat_we_moeten_betalen->{$derdejaar} = $excel_rij->{wat_we_betalen_derdejaar};
                       $wat_we_moeten_betalen->{$tweedejaar} = $excel_rij->{wat_we_betalen_tweedejaar};
                       $wat_we_moeten_betalen->{$eerstejaar} = $excel_rij->{wat_we_betalen_eerstejaar};
                       my $antwoord = package_invoice_to_agresso->maak_TandPlus_tussenkomst($client_id,'TANDPLUS',$verkoopsdagboek,$nomenclatuur,$wat_we_moeten_betalen,$eerstejaar,$tweedejaar,$derdejaar);
                       #my $antwoord = "OK ordernr";
                       if ($antwoord eq 'Nul factuur') {
                           $mail_msg = $mail_msg."$client_id -> $inz Nul factuur wordt niet gemaakt\n";
                           print "$client_id -> $inz Nul factuur wordt niet gemaakt\n";
                          }else {
                           if ($antwoord =~ m/OK ordernr/ )  {
                               ##inzetten in database
                               #my $periode = "$derdejaar-$eerstejaar";
                               #my  $klantbedrag =0;
                               ##$klantbedrag = $terugbetalingen->{"$periode"}->{bedrag_VP} if (defined $terugbetalingen->{"$periode"}->{bedrag_VP});
                               #sql_toegang_agresso->enter_maf_payment_info($dbh_agresso,$client_id,$derdejaar,$eerstejaar,$huidig_jaar,$klantbedrag,$excel_rij->{wat_we_betalen_derdejaar}); 
                               #$periode = "$tweedejaar-$eerstejaar";
                               #$klantbedrag =0;
                               ##$klantbedrag = $terugbetalingen->{"$periode"}->{bedrag_VP} if (defined $terugbetalingen->{"$periode"}->{bedrag_VP});
                               #sql_toegang_agresso->enter_maf_payment_info($dbh_agresso,$client_id,$tweedejaar,$eerstejaar,$huidig_jaar,$klantbedrag,$excel_rij->{wat_we_betalen_tweedejaar});
                               #$klantbedrag =0;
                               #$periode = "$eerstejaar-$eerstejaar";
                               ##$klantbedrag = $terugbetalingen->{"$periode"}->{bedrag_VP} if (defined $terugbetalingen->{"$periode"}->{bedrag_VP});;
                               #sql_toegang_agresso->enter_maf_payment_info($dbh_agresso,$client_id,$eerstejaar,$eerstejaar,$huidig_jaar,$klantbedrag,$excel_rij->{wat_we_betalen_eerstejaar});
                               print '';
                              }
                           print '';
                          }
                      }
                  }
                undef $klant;
               }
         }
            my $ok =excel->save_excel_file($Excel);
            #$Excel->ActiveWorkbook->Close(1);
            #$Excel->Quit();
            print "";
            }else {
             $mail_msg = $mail_msg."geen nomenclatuur gevonden naam moet gelijk zijn aan WETTELIJKE REMGELDEN verzekering maxiplan\n";
             print "geen nomenclatuur gevonden naam moet gelijk zijn aan WETTELIJKE REMGELDEN verzekering maxiplan\n";
            }
         print "betalingen gedaan\n";
         
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
             $klant = as400_gegevens->get_remgelden_tandplus_vp($zkf,$ext,$AS400_instellingen,$berekeningsjaren,$agresso_instellingen,$klant);
                 
             #my ($plafond,$berichtp) = as400_gegevens->get_plafond_vp($zkf,$ext,$AS400_instellingen,$berekeningsjaren);
             #$main::mail_msg = $main::mail_msg."$berichtp";   
             my @jaren_te_berekenen = split /,/,$berekeningsjaren;
             my $ipomzet = "Agresso_IP_$mode";
             my $ip =$agresso_instellingen->{$ipomzet};
             my $remgeldnom= $agresso_instellingen->{TandPlus_Remgeld_Nomenclatuur};
             foreach my $tel (@jaren_te_berekenen) {
                if ($klant->{TandPlus}->{$tel}) {                  
                  my ($tandplus_gedane_betaling,$al_betaald_remgeld) = package_get_K_D_jaar->agresso_get_TANDPLUS_jaar($klant->{Agresso_nummer},$tel,'TANDPLUS',$ip,$remgeldnom);
                  $klant->{TandPlus}->{$tel}->{totalen}->{al_betaald_door_VMOB}= $tandplus_gedane_betaling;
                  $klant->{TandPlus}->{$tel}->{totalen}->{al_betaald_remgeld_door_VMOB}= $al_betaald_remgeld;
                  $bedrag_te_betalen->{$tel}=$klant->{TandPlus}->{$tel}->{totalen}->{totaal_remgeld};
                }else {
                  $klant->{TandPlus}->{$tel}->{totalen}->{al_betaald_door_VMOB}=0;
                  $klant->{TandPlus}->{$tel}->{totalen}->{al_betaald_remgeld_door_VMOB}=0;
                  $klant->{TandPlus}->{$tel}->{totalen}->{totaal_betaald_door_lid} =0;
                  $klant->{TandPlus}->{$tel}->{totalen}->{totaal_remgeld}=0;
                  $klant->{TandPlus}->{$tel}->{totalen}->{totaal_terugbetaling}=0;
                  $bedrag_te_betalen->{$tel}=0;
                }
                print '';
             }          
             
             print'';
             return ($klant);
            }      
        
     }
package App;
     use strict;
     use warnings;
     use base 'Wx::App';
     sub OnInit {
         $main::dialog = Frame->new();
         #$main::frame->Maximize( 1 );
         $main::dialog->SetSize(1, 1, 980, 280);
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
               $frame = $frame->SUPER::new(undef, -1,_T("Berekeningsjaren TandPlus Agresso $main::mode -> ip $ip ->  variant = $variant_LG04 V20240118"),
                                        [-1,-1],[980,280], wxDEFAULT_FRAME_STYLE | wxTAB_TRAVERSAL ); # | wxSTAY_ON_TOP
               #$frame->Wx::Size->new(800,600) ;
               my $dryrun = 1;
               my $test =0;
               my $change_contracts = 0;
               my $xlsx_file ='';
               $frame->{Frame_Sizer_1} = Wx::FlexGridSizer->new(7,7, 10, 10);
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
               #$frame->{Frame_panel_2} = Wx::Panel->new($frame,-1,wxDefaultPosition,wxSIZE(60,5));
               $frame->{Frame_Button_OK}  = Wx::Button->new($frame, -1, _T("OK"),wxDefaultPosition,wxSIZE(60,20));
               $frame->{Frame_Cancel}  = Wx::Button->new($frame, -1, _T("Cancel"),wxDefaultPosition,wxSIZE(60,20));
               $frame->{Frame_statictxt_al_in_agresso}= Wx::StaticText->new($frame, -1,_T("Al in UBW xlsx"),wxDefaultPosition,wxSIZE(410,20));
               $frame->{Frame_Button_Bestand}  = Wx::Button->new($frame, -1, _T("Bestand"),wxDefaultPosition,wxSIZE(80,20));
               $frame->{Frame_Txt_XLSX} = Wx::TextCtrl->new($frame, -1, $xlsx_file,wxDefaultPosition,wxSIZE(410,20));
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
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_statictxt_Berekeningsjaar}, 0, wxALIGN_BOTTOM|wxALIGN_LEFT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_statictxt_jaar_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_statictxt_jaar_2}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_statictxt_jaar_3}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_statictxt_dryrun}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               #rij3
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_Txt_Berekeningsjaar}, 0, wxALIGN_BOTTOM|wxALIGN_LEFT);
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
               #$frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_statictxt_al_in_agresso}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               #$frame->{Frame_Sizer_1}->Add($frame->{Frame_Button_Bestand}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               #rij5
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_Txt_XLSX}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT); 
               #$frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_Button_Bestand}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               #$frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               #rij6
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);               
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_Button_OK}, 0, wxALIGN_BOTTOM|wxALIGN_LEFT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_Cancel}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               #rij7
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
               Wx::Event::EVT_BUTTON($frame,$frame->{Frame_Button_Bestand},\&Bestand);
               $frame->SetSizer($frame->{Frame_Sizer_1});
               $frame->SetBackgroundColour(Wx::Colour->new(239, 243, 255));
               return ($frame);
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
           my $al_gefactureerd =  $frame->{Frame_Txt_XLSX}->GetValue();
           if ($al_gefactureerd ne '') {
               @ubw_al_gefactureerd = excel->zijn_al_gefactureerd($al_gefactureerd);
           }else {
               print '';
           }           
           if ($huidig_jaar > 2014 and $huidig_jaar < 2027) {
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
                     #mail->mail_bericht($main::mail_msg);
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
      sub Bestand {
         my($frame)= @_;
         my $filedlg = Wx::FileDialog->new(  $frame,         # parent
                                          'Open File',   # Caption
                                          '',            # Default directory
                                          '',            # Default file
                                          "XLSX (*.xls,*.xlsx)|*.xlsx;*.xls", # wildcard                                          
                                          wxFD_OPEN);        # style
             # If the user really selected one
             if ($filedlg->ShowModal==wxID_OK)   {
                 my $filename = $filedlg->GetPath;
                 $frame->{Frame_Txt_XLSX}->SetValue($filename);
                }
        }
      
      sub Cancel {
         die;
        }  
package excel;
     use Win32::OLE;
     use Win32::OLE::Const 'Microsoft Excel';
     use Date::Manip::DM5;
     sub new {     
         #excel tabel openen
         my ($self,$eerstejaar,$tweedejaar,$derdejaar) = @_;
         my $Excel1 = Win32::OLE->GetActiveObject('Excel.Application')
        	|| Win32::OLE->new('Excel.Application', 'Quit');
         $Excel1->{'Visible'} = 0;  # toon wat je doet is 1
         # open Excel file
         my $test = $main::agresso_instellingen;
         my $sjabloon = $main::agresso_instellingen->{Tandplus_sjabloon};
         my $Book1 = $Excel1->Workbooks->Open($sjabloon );
         my $ex_file = excel->save_excel($Excel1);
         my $Excel = Win32::OLE->GetActiveObject('Excel.Application')
        	|| Win32::OLE->new('Excel.Application', 'Quit');
         $Excel1->{'Visible'} = 1;  # toon wat je doet is 1
         # open Excel file
         my $Book = $Excel->Workbooks->Open($ex_file);
         my $Sheet = $Book->Worksheets(1);
         $Sheet->{Name} = 'TandPlus uitbetaling';
         my $inhoudcel= $Sheet->Cells(1,1);
         $inhoudcel->{Value} = "TANDPLUS";
         $inhoudcel= $Sheet->Cells(3,1);
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
         $inhoudcel->{Value} = "$derdejaar\n Te betalen\n Remgeld";
         $inhoudcel= $Sheet->Cells(3,7);
         $inhoudcel->{Value} = "$derdejaar\n Al betaald\n Remgeld";
         $inhoudcel= $Sheet->Cells(3,8);
         $inhoudcel->{Value} = "$derdejaar\n Totaal al\n betaald";
         $inhoudcel= $Sheet->Cells(3,9);
         $inhoudcel->{Value} = "$derdejaar\n\n betaald";
         $inhoudcel= $Sheet->Cells(3,10);
         $inhoudcel->{Value} = "$tweedejaar\n Te betalen\n Remgeld";
         $inhoudcel= $Sheet->Cells(3,11);
         $inhoudcel->{Value} = "$tweedejaar\n Al betaald\n Remgeld";
         $inhoudcel= $Sheet->Cells(3,12);
         $inhoudcel->{Value} = "$tweedejaar\n Totaal al\n betaald";
         $inhoudcel= $Sheet->Cells(3,13);
         $inhoudcel->{Value} = "$tweedejaar\n\n betaald";
         $inhoudcel= $Sheet->Cells(3,14);
         $inhoudcel->{Value} = "$eerstejaar\n Te betalen\n Remgeld";
         $inhoudcel= $Sheet->Cells(3,15);
         $inhoudcel->{Value} = "$eerstejaar\n Al betaald\n Remgeld";
         $inhoudcel= $Sheet->Cells(3,16);
         $inhoudcel->{Value} = "$eerstejaar\n Totaal al\n betaald";
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
         my $vandaag = ParseDate("today");
         $vandaag = substr ($vandaag,0,8);  # vandaag in YYYYMMDD
         $vandaag = sprintf "%04d-%02d-%02d",substr ($vandaag,0,4),substr ($vandaag,4,2),substr ($vandaag,6,2);
         #my $path_to_files =$main::agresso_instellingen->{Tandplus_verslag};
         #my $save_file="$path_to_files\\$vandaag-TandPlus.xlsx";
         #print "save_file $save_file\n";
         #$Excel->ActiveWorkbook->SaveAs($save_file);
         #$Excel->ActiveWorkbook->Close(1);
         #$Book = $Excel->Workbooks->Open($save_file );
         #$Sheet = $Book->Worksheets(1);
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
         $inhoudcel->{Value} =$excel_rij->{wachtcontract};
         $inhoudcel= $Sheet->Cells($rijteller,5);
         $inhoudcel->{Value} =$excel_rij->{eindcontract};
         $inhoudcel= $Sheet->Cells($rijteller,6);
         $inhoudcel->{Value} =$excel_rij->{derdejaar_Remgeld_te_betalen};
         $inhoudcel= $Sheet->Cells($rijteller,7);
         $inhoudcel->{Value} =$excel_rij->{derdejaar_al_betaald_Remgeld_TandPlus};
         $inhoudcel= $Sheet->Cells($rijteller,8);
         $inhoudcel->{Value} =$excel_rij->{derdejaar_al_betaald_TandPlus};
         $inhoudcel= $Sheet->Cells($rijteller,9);
         $inhoudcel->{Value} =$excel_rij->{wat_we_betalen_derdejaar};
         $inhoudcel= $Sheet->Cells($rijteller,10);
         $inhoudcel->{Value} =$excel_rij->{tweedejaar_Remgeld_te_betalen};
         $inhoudcel= $Sheet->Cells($rijteller,11);
         $inhoudcel->{Value} =$excel_rij->{tweedejaar_al_betaald_Remgeld_TandPlus};
         $inhoudcel= $Sheet->Cells($rijteller,12);
         $inhoudcel->{Value} =$excel_rij->{tweedejaar_al_betaald_TandPlus};
         $inhoudcel= $Sheet->Cells($rijteller,13);
         $inhoudcel->{Value} =$excel_rij->{wat_we_betalen_tweedejaar};
         $inhoudcel= $Sheet->Cells($rijteller,14);
         $inhoudcel->{Value} =$excel_rij->{eerstejaar_Remgeld_te_betalen};
         $inhoudcel= $Sheet->Cells($rijteller,15);
         $inhoudcel->{Value} =$excel_rij->{eerstejaar_al_betaald_Remgeld_TandPlus};
         $inhoudcel= $Sheet->Cells($rijteller,16);
         $inhoudcel->{Value} =$excel_rij->{eerstejaar_al_betaald_TandPlus};
         $inhoudcel= $Sheet->Cells($rijteller,17);
         $inhoudcel->{Value} =$excel_rij->{wat_we_betalen_eerstejaar};           
         my $som = $excel_rij->{wat_we_betalen_derdejaar}+$excel_rij->{wat_we_betalen_tweedejaar}+ $excel_rij->{wat_we_betalen_eerstejaar};          
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
         my $path_to_files =$main::agresso_instellingen->{Tandplus_verslag};
         #$Excel->ActiveWorkbook->Save;
         unlink "$path_to_files\\$vandaag-TandPlus.xlsx";
         $Excel->ActiveWorkbook->SaveAs("$path_to_files\\$vandaag-TandPlus.xlsx");
         $Excel->ActiveWorkbook->Close(1);
         $Excel->Quit();
         return ("$path_to_files\\$vandaag-TandPlus.xlsx");
        }
     sub save_excel_file {
         my ($self,$Excel) = @_;
         my $vandaag = ParseDate("today");
         $vandaag = substr ($vandaag,0,8);  # vandaag in YYYYMMDD
         $vandaag = sprintf "%04d-%02d-%02d",substr ($vandaag,0,4),substr ($vandaag,4,2),substr ($vandaag,6,2);
         my $path_to_files =$main::agresso_instellingen->{Tandplus_verslag};
         $Excel->ActiveWorkbook->Save;
         #$Excel->ActiveWorkbook->SaveAs("$path_to_files\\$vandaag-TandPlus.xls");
         $Excel->ActiveWorkbook->Close(1);
         $Excel->Quit();
         return ($Excel);
        }
     
     sub zijn_al_gefactureerd {
         my ($self,$bestand) = @_   ;
          #excel tabel openen         
         my $Excel = Win32::OLE->GetActiveObject('Excel.Application')
        	|| Win32::OLE->new('Excel.Application', 'Quit');
         $Excel->{'Visible'} = 0;  # toon wat je doet is 1
         # open Excel file
         my $Book = $Excel->Workbooks->Open($bestand);
         my $Sheet = $Book->Worksheets(1);
         my $rij_begin = 4;
         my $kolom_agresso_id = 20;
         my $rowCount = $Sheet->UsedRange->Rows->{Count};
         print '';
         my $rij = $rij_begin;
         my $rijcount1 = $rowCount +1;
         my @al_gefact_UBW_ID;
         my $teller = 0;
         while ($rij < $rijcount1) {
            my $inhoudcel= $Sheet->Cells($rij, $kolom_agresso_id);
            my $inz = $inhoudcel->{Value}; 
            $teller += 1;
            push (@al_gefact_UBW_ID,$inz);
            print "$teller $inz\n";
            $rij += 1;
         }
         print"";
         $Excel->ActiveWorkbook->Close(1);
         $Excel->Quit();
         return(@al_gefact_UBW_ID);
         #my $inhoudcel= $Sheet->Cells($rij,$kolom_inz);
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
             my $smtp = Net::SMTP->new('mailservices.m-team.be',
                    Hello => 'mail.vnz.be',
                    Timeout => 60);
             #$smtp->auth('mailprogrammas','pleintje203');
             $smtp->mail($van);
             $smtp->to($geadresseerde);
             #$smtp->cc('informatica.mail@vnz.be');
             #$smtp->bcc("bar@blah.net");
             $smtp->data;
             $smtp->datasend("From: harry.conings");
             $smtp->datasend("\n");
             $smtp->datasend("To: Kaartbeheerders");
             $smtp->datasend("\n");
             $smtp->datasend("Subject: Agresso TandPlus facturen inzetten $vandaag");
             $smtp->datasend("\n");
             $smtp->datasend("$mail_msg\nvriendelijke groeten\nHarry Conings");
             $smtp->dataend;
             $smtp->quit;
             print "mail aan $geadresseerde  gezonden\n";
            }
          print "\neinde\n";
          die;
        } 