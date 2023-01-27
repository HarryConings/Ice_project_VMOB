#!/usr/bin/perl -w
use strict;

package ambulante_zorgen_ernstige_ziekten_naar_agresso;
use Date::Manip::DM5 ;
use Date::Calc qw(:all);
use DateTime::Format::Strptime;
use DateTime;
sub welke_nomenclaturen_zijn_ambulante_zorgen_ernstige_ziekten {
     @main::ambulante_zorgen_ernstige_ziekten_nomenclaturen = ();
     foreach my $groep (keys %main::nomenclatuurnummers_per_groep) {
         if ($groep eq 'AMBULANTE ZORGEN EN ERNSTIGE ZIEKTE') {
             foreach my $nr (keys $main::nomenclatuurnummers_per_groep{'AMBULANTE ZORGEN EN ERNSTIGE ZIEKTE'}) {
                 my $nomenclatuur = $main::nomenclatuurnummers_per_groep{'AMBULANTE ZORGEN EN ERNSTIGE ZIEKTE'}->[$nr];
                 my $type_grid = $main::type_grid{$nomenclatuur};
                 if ($main::type_grid{$nomenclatuur} eq 'VnZ') {
                      push (@main::ambulante_zorgen_ernstige_ziekten_nomenclaturen,$nomenclatuur);
                    }
                }
            }

        }
     print "";
    }
sub save_ambulante_zorgen_ernstige_ziekten {
     my $agresso_nr = $main::klant->{Agresso_nummer};
     my $er_zijn_ambulante_zorgen =0;
     my $laaste_rij = Voor_na_zorg_Grid->GetNumberRows;
     $laaste_rij -=1;
     my $vandaag = ParseDate("today");
     #my $parser = DateTime::Format::Strptime->new(pattern => '%d/%m/%Y');
     my $parser = DateTime::Format::Strptime->new(pattern => '%Y%m%d');
     $vandaag =$parser->parse_datetime($vandaag);
     my $toegevoegd=$vandaag->strftime('%Y-%m-%d %H:%M:%S');
     my $begindatum_alg = $vandaag->strftime('%d-%m-%Y');
     my $einddatum_alg = $vandaag->strftime('%d-%m-%Y');
     my $datum_alg =$vandaag->strftime('%d-%m-%Y');
     my $xml='';
     $xml=$xml."<cus:company>VMOB</cus:company>";
     $xml=$xml."<cus:customerId>$agresso_nr</cus:customerId>";
     $xml=$xml."<cus:flexiGroupList>";
     $xml=$xml."<cus:FlexiGroupUnitType>";
     $xml=$xml."<cus:FlexiGroup>VMOBAMBU</cus:FlexiGroup>";
     $xml=$xml."<cus:FlexiFieldRowList>";
     my $dbh = sql_toegang_agresso->setup_mssql_connectie;
     my $RowNo = sql_toegang_agresso->get_row_number_VMOBAMBU($dbh,$agresso_nr);
     $RowNo =0 if (!defined $RowNo ) ;
     foreach my $nomenclatuur (@main::ambulante_zorgen_ernstige_ziekten_nomenclaturen) {
         foreach my $rij (keys $main::overzicht_per_nomenclatuur->{$nomenclatuur}) {
             my $er_staat_iets_in_de_rij=0;

             my $tekst = $main::overzicht_per_nomenclatuur->{$nomenclatuur}->[$rij]->[0];
             $er_staat_iets_in_de_rij=1 if (defined $tekst and $tekst ne '');
             my $mdh = $main::overzicht_per_nomenclatuur->{$nomenclatuur}->[$rij]->[1];
             $er_staat_iets_in_de_rij=1 if (defined $mdh and $mdh ne '');
             my $datum = $main::overzicht_per_nomenclatuur->{$nomenclatuur}->[$rij]->[2];
             if (defined $datum and $datum ne '') {
                 $datum =~ s%/%-%g;
                 $er_staat_iets_in_de_rij=1 ;
                 $datum_alg =$datum;
             }
             my $inami = $main::overzicht_per_nomenclatuur->{$nomenclatuur}->[$rij]->[3];
             if (defined $inami and $inami ne '') {
                 $er_staat_iets_in_de_rij=1 ;
                 #$inami = int($inami);
             }
             my $pers_tussenkomst = $main::overzicht_per_nomenclatuur->{$nomenclatuur}->[$rij]->[4];
             $er_staat_iets_in_de_rij=1 if (defined $pers_tussenkomst and $pers_tussenkomst > 0);
             my $zkf_tussenkomst =  $main::overzicht_per_nomenclatuur->{$nomenclatuur}->[$rij]->[5];
             $er_staat_iets_in_de_rij=1 if (defined $zkf_tussenkomst and $zkf_tussenkomst > 0 );
             my $hospi_tussenkomst =  $main::overzicht_per_nomenclatuur->{$nomenclatuur}->[$rij]->[6];
             $er_staat_iets_in_de_rij=1 if (defined $hospi_tussenkomst and $hospi_tussenkomst > 0);
             my $verschil =  $main::overzicht_per_nomenclatuur->{$nomenclatuur}->[$rij]->[7];
             my $begindatum = $main::overzicht_per_nomenclatuur->{$nomenclatuur}->[$rij]->[8];
             $begindatum =~ s%/%-%g if (defined $begindatum and $begindatum ne '');
             $begindatum_alg =  $begindatum if (defined $begindatum and $begindatum ne '');
             my $einddatum = $main::overzicht_per_nomenclatuur->{$nomenclatuur}->[$rij]->[9];
             $einddatum=~ s%/%-%g if (defined $einddatum and $einddatum ne '');
             $einddatum_alg =~ $einddatum if (defined $einddatum and $einddatum ne '');
             my $regel = $main::overzicht_per_nomenclatuur->{$nomenclatuur}->[$rij]->[10];
             $regel = substr ($regel,0,99) if (defined $regel);
             $regel =~ s%\s+$%% if (defined $regel);
             my $beschrijving = '';
             $hospi_tussenkomst = 0 if (!defined $hospi_tussenkomst) ;
             if ($er_staat_iets_in_de_rij == 1 and ($nomenclatuur < 999991 or ($nomenclatuur > 999990 and $hospi_tussenkomst != 0) )) {
                 if (($pers_tussenkomst > 0 or $zkf_tussenkomst >0 or $hospi_tussenkomst > 0) and $rij != $laaste_rij) {
                     $er_zijn_ambulante_zorgen =1;
                     $begindatum = $begindatum_alg if (!defined $begindatum or $begindatum eq '') ;
                     $einddatum = $einddatum_alg if (!defined $einddatum or $einddatum eq '') ;
                     $datum = $datum_alg if (!defined $datum or $datum eq '') ;
                     $pers_tussenkomst = 0 if (!defined $pers_tussenkomst) ;
                     $pers_tussenkomst =~ s/\./,/g;
                     $zkf_tussenkomst = 0 if (!defined $zkf_tussenkomst) ;
                     $zkf_tussenkomst =~ s/\./,/g;
                     $hospi_tussenkomst = 0 if (!defined $hospi_tussenkomst) ;
                     $hospi_tussenkomst =~ s/\./,/g;
                     $verschil = 0 if (!defined $verschil) ;
                     $verschil  =~ s/\./,/g;
                     $xml=$xml."<cus:FlexiRowUnitType>";
                     $xml=$xml."<cus:RowNo>$RowNo</cus:RowNo>";
                     $xml=$xml."<cus:FlexiFieldList>";
                         $xml=$xml."<cus:FlexiFieldUnitType>";
                             $xml=$xml."<cus:ColumnName>internenom</cus:ColumnName>";
                             $xml=$xml."<cus:Value>$nomenclatuur</cus:Value>";
                         $xml=$xml."</cus:FlexiFieldUnitType>";
                          $xml=$xml."<cus:FlexiFieldUnitType>";
                             $xml=$xml."<cus:ColumnName>toegevoegd</cus:ColumnName>";
                             $xml=$xml."<cus:Value>$toegevoegd</cus:Value>";
                         $xml=$xml."</cus:FlexiFieldUnitType>";
                         $xml=$xml."<cus:FlexiFieldUnitType>";
                             $xml=$xml."<cus:ColumnName>tekst</cus:ColumnName>";
                             $xml=$xml."<cus:Value>$tekst</cus:Value>";
                         $xml=$xml."</cus:FlexiFieldUnitType>";
                         $xml=$xml."<cus:FlexiFieldUnitType>";
                             $xml=$xml."<cus:ColumnName>mdh</cus:ColumnName>";
                             $xml=$xml."<cus:Value>$mdh</cus:Value>";
                         $xml=$xml."</cus:FlexiFieldUnitType>";
                         $xml=$xml."<cus:FlexiFieldUnitType>";
                             $xml=$xml."<cus:ColumnName>datum</cus:ColumnName>";
                             $xml=$xml."<cus:Value>$datum</cus:Value>";
                         $xml=$xml."</cus:FlexiFieldUnitType>";
                         $xml=$xml."<cus:FlexiFieldUnitType>";
                             $xml=$xml."<cus:ColumnName>code</cus:ColumnName>";
                             $xml=$xml."<cus:Value>$inami</cus:Value>";
                         $xml=$xml."</cus:FlexiFieldUnitType>";
                         $xml=$xml."<cus:FlexiFieldUnitType>";
                             $xml=$xml."<cus:ColumnName>pers_tussenkomst</cus:ColumnName>";
                             $xml=$xml."<cus:Value>$pers_tussenkomst</cus:Value>";
                         $xml=$xml."</cus:FlexiFieldUnitType>";
                         $xml=$xml."<cus:FlexiFieldUnitType>";
                             $xml=$xml."<cus:ColumnName>zkf_tussenkomst</cus:ColumnName>";
                             $xml=$xml."<cus:Value>$zkf_tussenkomst</cus:Value>";
                         $xml=$xml."</cus:FlexiFieldUnitType>";
                         $xml=$xml."<cus:FlexiFieldUnitType>";
                             $xml=$xml."<cus:ColumnName>hospi_tussenkomst</cus:ColumnName>";
                             $xml=$xml."<cus:Value>$hospi_tussenkomst</cus:Value>";
                         $xml=$xml."</cus:FlexiFieldUnitType>";
                         $xml=$xml."<cus:FlexiFieldUnitType>";
                             $xml=$xml."<cus:ColumnName>verschil</cus:ColumnName>";
                             $xml=$xml."<cus:Value>$verschil</cus:Value>";
                         $xml=$xml."</cus:FlexiFieldUnitType>";
                         $xml=$xml."<cus:FlexiFieldUnitType>";
                             $xml=$xml."<cus:ColumnName>begindatum</cus:ColumnName>";
                             $xml=$xml."<cus:Value>$begindatum</cus:Value>";
                         $xml=$xml."</cus:FlexiFieldUnitType>";
                         $xml=$xml."<cus:FlexiFieldUnitType>";
                             $xml=$xml."<cus:ColumnName>einddatum</cus:ColumnName>";
                             $xml=$xml."<cus:Value>$einddatum</cus:Value>";
                         $xml=$xml."</cus:FlexiFieldUnitType>";
                         $xml=$xml."<cus:FlexiFieldUnitType>";
                             $xml=$xml."<cus:ColumnName>regel</cus:ColumnName>";
                             $xml=$xml."<cus:Value>$regel</cus:Value>";
                         $xml=$xml."</cus:FlexiFieldUnitType>";
                         $xml=$xml."<cus:FlexiFieldUnitType>";
                             $xml=$xml."<cus:ColumnName>beschrijving</cus:ColumnName>";
                             $xml=$xml."<cus:Value>$beschrijving</cus:Value>";
                         $xml=$xml."</cus:FlexiFieldUnitType>";
                     $xml=$xml."</cus:FlexiFieldList>";
                     $xml=$xml."</cus:FlexiRowUnitType>";
                     $RowNo +=1;
                    }


                }

            }
        }
     $xml=$xml."</cus:FlexiFieldRowList>";
     $xml=$xml."</cus:FlexiGroupUnitType>";
     $xml=$xml."</cus:flexiGroupList>";
     $xml=$xml."<cus:includeDataInResponse>1</cus:includeDataInResponse>";
     $xml=$xml."<cus:credentials>";
         $xml=$xml."<cus:Username>WEBSERV</cus:Username>";
         $xml=$xml."<cus:Client>VMOB</cus:Client>";
         $xml=$xml."<cus:Password>WEBSERV</cus:Password>";
     $xml=$xml."</cus:credentials>";
     my ($returncode,$ReturnText) = ("OK","geen AMB of ernstige ziekte");
     ($returncode,$ReturnText) = &insert_ambulante($xml) if ($er_zijn_ambulante_zorgen ==1) ;
     my $historiek_gkd = $main::teksten_GKD->{GKD_teksten}->{AUTOMATISCHE_TEKSTEN}->{AMBULANTE_ZORGEN}->{tekst};
     my $staat_er_al_in = 'nee';
     $staat_er_al_in = as400_gegevens->lees_history_gkd_agresso_order($historiek_gkd) if ($er_zijn_ambulante_zorgen ==1) ;
     as400_gegevens->zet_history_gkd_in ($historiek_gkd) if ($er_zijn_ambulante_zorgen ==1 and $staat_er_al_in eq 'nee') ;
     sql_toegang_agresso->disconnect_mssql($dbh);
     return ($returncode,$ReturnText);
    }
sub insert_ambulante {
     my $xml_content = shift @_;
     my $ip = $main::agresso_instellingen->{"Agresso_IP_$main::mode"}; 
     my $proxy ="http://$ip/BusinessWorld-webservices/service.svc?CustomerService/Customer";
     my $uri   = 'http://services.agresso.com/CustomerService/Customer';
     my $soap = SOAP::Lite
        ->proxy($proxy)
        ->ns($uri,'cus')
        ->on_action( sub { return 'AddFlexiFieldRow' } );
     my $AddFlexiFieldRow = SOAP::Data->type('xml' => $xml_content);
     my $response = $soap->AddFlexiFieldRow($AddFlexiFieldRow);
     my $returncode = $response->{_content}[4]->{Body}->{AddFlexiFieldRowResponse}->{AddFlexiFieldRowResult}->{ReturnCode};
     my $ReturnText = $response->{_content}[4]->{Body}->{AddFlexiFieldRowResponse}->{AddFlexiFieldRowResult}->{ReturnText};
     return ($returncode,$ReturnText);

    }
1;
