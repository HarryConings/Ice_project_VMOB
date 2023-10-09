#!/usr/bin/perl -w
#OPGELET!!!!!!
#Dit programma is auteursrechtelijk beschermd.
#Deze code is voor 50% eigendom van Hospiplus en voor 50% eigendom van de Firma  I.C.E. (liebroekstraat 43 3545 Halen BE0446888007) .
#Deze code mag niet aan derden (ook niet VNZ en NZVL) getoond worden tenzij met uitdrukkelijke en schriftelijke toestemming van Hospiplus en I.C.E. bvba .
#Indien dit toch gebeurt is er een boete verschuldigd van 250.000 € exclusief btw aan de Firma  I.C.E.
#Dit geldt ook voor het kopieren van een stuk code of het repliceren van technieken gehanteerd in dit programma
#I.C.E. beheert de broncode je mag  veranderingen aanbrengen aan het programma . Deze worden samen met de documentatie overgedragen aan I.C.E. .
#I.C.E. beslist dan op deze veranderingen worden doorgevoerd.

#Door het openen van deze broncode stem je in met de voorgaande voorwaarden.

#De gerechtigden om deze broncode te bekijken zijn Christian Bruyninckx , Michel Gielens en Ben Van Massenhoven.
#Harry Conings beheert voor I.C.E de broncode
#versie 2.5 CONCAT(a.ABACKK,a.AB2AKK) != 'A04' and CONCAT(a.ABACKK,a.AB2AKK) != 'L05'
#versie 2.4 niuew logo
#use strict;
#versie 2.3
     #2a/ Bestandsnaam : de ZKFetc en taal mogen niet voorkomen in de bestandsnaam.
     #Voorbeeld : 014 .00214.testlaser.20140513.160736.ZKF235.NL.xml moet worden 014.00214.testlaser.20140513.160736.xml.
     #2b/ De tag "InformationFlow" moet worden vervolledigd met de bestandnaam xsd.
     #<InformationFlow> wordt dus <InformationFlow smlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="InformationFlow.xsd">

#versie 2.2 telleing van hoeveel brieven
#versie 2.1 aanpassing als CARDNR in ascard_fil = leeg dan heeft hij bestaat hij maar is ingezet door agresso
#versie 2.0 agresso nummers
#versie 1.7 ONTSLAGO = N
#mime lite vervangen door net smtp
#versie 1.5 voorwaarden generatie + layout
#versie 1.4 famaly grouping code
#versie 1.3 lost card
use XML::Simple;
use Date::Manip::DM5 ;
use Scalar::MoreUtils qw(empty);
use Data::Dumper;
use XML::Compile::Schema;
use XML::LibXML::Reader;
use XML::SAX;
use File::Copy;
#use XML::SAX::ExpatXS;
use vars qw(%settings $data_xml @group $group_onderdeel $body_onderdeel $contact);
use vars qw($cardinstellingen $aantalrij_kaart);
use vars qw(@assurcard_verzekeringen);
use vars qw($mail);
use Net::SMTP;
#use MIME::Lite;
#use Encode qw/encode decode/;
#use Encode::MIME::Header;
#use Encode::locale;
#use MIME::Words qw(encode_mimewords);
#use Algorithm::Diff::XS;
#use Log::Report;
#use Log::Report::Dispatcher;
use Devel::GlobalDestruction::XS;
use JSON::PP;
#use JSON::XS;
use Date::Calc::XS;
#use JSON::PP58;

require "chknaam.pl";
require "settings_prod.pl";
require "cnnectdb_prod.pl";
require "chk_of_in_rusthuis.pl";
require "assurcard_card_updates.pl";
our $teller_aantal_brieven = 0;
$mail='';
&load_assurcard_generation_setting('P:\OGV\ASSURCARD_PROG\assurcard_settings_xml\assurcard_card_generation_settings.xml');
&zoek_verzekerden_die_een_kaart_moeten_krijgen;
print "gedaan\n";
$mail = $mail."\neinde programma\n";
&mail_bericht;
#my @xmlfile_batchnr =&maak_xml_file ;
#&maak_header_xml ('ZKF203',$xmlfile_batchnr[1],2); #ziekenfonds batchnummer aantal_records

sub load_assurcard_generation_setting  {
     my $file_name = shift @_;
     $cardinstellingen = XMLin("$file_name");
     print "ingelezen\n";
     #maak verzekeringen
    
    }
sub zoek_verzekerden_die_een_kaart_moeten_krijgen {
      #lees verzekeringen in waarvoor men een kaart moet genereren
      my $xml_file ='';
      my $batch_nummer ='';
      $aantalrij_kaart=0;
      foreach my $ziekfonds (keys %{$cardinstellingen->{verzekeringen_met_kaart}}){ # de mogelijke ziekenfondsen
         $ziekfonds =~ m/\d{3}/;
         my $ziekenfondsnr = $&;
         $mail = $mail."\n-----------------\n$ziekfonds -> $ziekenfondsnr\n";
         print "\n-----------------\n$ziekfonds -> $ziekenfondsnr\n";
         &settings( $ziekenfondsnr);
         my $recordteller = 0; # het aantal records
         my $dbconnectie = &cnnectdb ($settings{user_name},$settings{password},$settings{name_as400});
         my $aantal_dagen_geen_productie = &datum_laatste_generatie ($ziekenfondsnr,$dbconnectie );
         foreach my $taal_code (keys %{$cardinstellingen->{ondersteunde_kaarten}->{$ziekfonds}->{ondersteunde_talen}}){ # de mogelijke talen
             my $taal_as400 = $cardinstellingen->{ondersteunde_kaarten}->{$ziekfonds}->{ondersteunde_talen}->{$taal_code}->{taal_code_as400};
             my $taal_brief = $cardinstellingen->{ondersteunde_kaarten}->{$ziekfonds}->{ondersteunde_talen}->{$taal_code}->{brief};
             #print "taal_code ->$taal_code-> as400->$taal_as400->$taal_brief\n";
             $teller_aantal_brieven = 0;
             my $group_nummer = 0;
             my $verzekerings_nr='';
             foreach my $verzekering (keys %{$cardinstellingen->{verzekeringen_met_kaart}->{$ziekfonds}}){ # de verzekering per ziekenfonds
                 print"\t->$verzekering :";
                 $verzekerings_nr= $cardinstellingen->{verzekeringen_met_kaart}->{$ziekfonds}->{$verzekering};
                 print " $verzekerings_nr\n";
                 $mail = $mail."      ->$verzekering : $verzekerings_nr\n";
                 #we moeten een kaart genereren voor alle verzekerden van zkf = $ziekfonds verzekeringsnaam = $verzekering nummer verzekering $verzekerings_nr
                  #$dbh , nr zkf 203 of 235, nummer verzekering, taal N F, group nr, zkf nr ZKF 203 ZKF235, taal xml NL FR, taal brief xml,
                 ($group_nummer,$recordteller)=&chk_voor_nieuwe_kaarthouders ($dbconnectie,$ziekenfondsnr,$verzekerings_nr,$taal_as400,$group_nummer,$ziekfonds,$taal_code,$taal_brief,$recordteller);
                }
              # na elke taal nieuwe xml
              if (@group) {
                  if ($cardinstellingen->{ondersteunde_kaarten}->{$ziekfonds}->{ondersteunde_talen}->{$taal_code}->{minimum_aantal_kaarten_voor_productie} <= $recordteller ) {
                     my $cnt =0;
                     #foreach my $nrg (keys @group) {
                     #    my $test = $group[$nrg]->{Body};
                     #    foreach my $nr_key (keys $group[$nrg]->{Body}) {
                     #         $cnt +=1;
                     #         print " $nrg ,Cardid:, $group[$nrg]->{Body}->[$nr_key]->{CardId}, ";
                     #         print " CarrierFirstname:, $group[$nrg]->{Body}->[$nr_key]->{CarrierFirstname}, ";
                     #         print " CarrierLastname:, $group[$nrg]->{Body}->[$nr_key]->{CarrierLastname},";
                     #         print " HolderFirstname:, $group[$nrg]->{Body}->[$nr_key]->{HolderFirstname}, ";
                     #         print " HolderLastname:, $group[$nrg]->{Body}->[$nr_key]->{HolderLastname},\n";
                     #         if ($group[$nrg]->{Body}->[$nr_key]->{CardId} == 818120636345){
                     #              $group[$nrg]->{Body}->[$nr_key]->{HolderFirstname} = 'GABRIEL';
                     #              $group[$nrg]->{Body}->[$nr_key]->{HolderLastname} = 'KETTING';
                     #              $group[$nrg]->{Body}->[$nr_key]->{HolderName} = 'GABRIEL KETTING';
                     #              print "Changed -----------------------\n";
                     #              print " $nrg ,Cardid:, $group[$nrg]->{Body}->[$nr_key]->{CardId}, ";
                     #              print " CarrierFirstname:, $group[$nrg]->{Body}->[$nr_key]->{CarrierFirstname}, ";
                     #              print " CarrierLastname:, $group[$nrg]->{Body}->[$nr_key]->{CarrierLastname},";
                     #              print " HolderFirstname:, $group[$nrg]->{Body}->[$nr_key]->{HolderFirstname}, ";
                     #              print " HolderLastname:, $group[$nrg]->{Body}->[$nr_key]->{HolderLastname},\n";
                     #         }
                     #    }
                     #}
                     #cod
                     print '';
                     ($xml_file,$batch_nummer) = &maak_xml_file ($dbconnectie,$ziekfonds,$taal_code);
                     #header zkf,batch nr,aantal records
                     &maak_header_xml ($ziekfonds,$batch_nummer,$recordteller,$taal_brief,$taal_code);
                     &schrijf_xml_file ($xml_file);
                     $mail = $mail."xml file $xml_file gemaakt\n";
                     print "xml file $xml_file gemaakt\n";
                     &insert_kaart_gemaakt_in_DB ($ziekenfondsnr,$dbconnectie);
                     $mail = $mail."kaarten zijn gemaakt voor ziekenfonds : $ziekfonds\n->met batch $batch_nummer\n->aantal kaarten : $recordteller\n->taal: $taal_code\n ";
                     $mail = $mail."aantal $taal_code brieven voor $recordteller kaarten -> $teller_aantal_brieven\n";
                     print "kaart zijn gemaakt:\n\t voor ziekenfonds : $ziekfonds \n\t met batch $batch_nummer \n\t aantal kaarten : $recordteller \n\t taal: $taal_code  ";
                     print "aantal $taal_code brieven voor $recordteller kaarten -> $teller_aantal_brieven\n";
                    }else {
                     $mail = $mail."geen productie $ziekfonds $taal_code te weinig kaarten -> aantal = $recordteller\n";
                     print "geen productie $ziekfonds $taal_code te weinig kaarten -> aantal = $recordteller\n";
                     if ($aantal_dagen_geen_productie > $cardinstellingen->{maximum_wachtdagen_op_kaart}) {
                         #code
                         print "aanmaak geforceerd :$aantal_dagen_geen_productie > $cardinstellingen->{maximum_wachtdagen_op_kaart}\n";
                         $mail = $mail."aanmaak geforceerd :$aantal_dagen_geen_productie > $cardinstellingen->{maximum_wachtdagen_op_kaart}\n";
                         ($xml_file,$batch_nummer) = &maak_xml_file ($dbconnectie,$ziekfonds,$taal_code);
                         #header zkf,batch nr,aantal records
                         &maak_header_xml ($ziekfonds,$batch_nummer,$recordteller,$taal_brief,$taal_code);
                         &schrijf_xml_file ($xml_file);
                         $mail = $mail."xml file $xml_file gemaakt\n";
                         print "xml file $xml_file gemaakt\n";
                         &insert_kaart_gemaakt_in_DB ($ziekenfondsnr,$dbconnectie);
                         $mail = $mail."kaarten zijn gemaakt voor ziekenfonds : $ziekfonds\n->met batch $batch_nummer\n->aantal kaarten : $recordteller\n->taal: $taal_code\n ";
                         $mail = $mail."aantal $taal_code brieven voor $recordteller kaarten -> $teller_aantal_brieven\n";
                         print "kaart zijn gemaakt:\n\t voor ziekenfonds : $ziekfonds \n\t met batch $batch_nummer \n\t aantal kaarten : $recordteller \n\t taal: $taal_code  ";
                         print "aantal $taal_code brieven voor $recordteller kaarten -> $teller_aantal_brieven\n";
                     }
                     
                  }
              }else {
                     $mail = $mail."geen productie $ziekfonds $taal_code geen kaarten -> aantal = $recordteller\n";
                     print "geen productie $ziekfonds $taal_code geen kaarten -> aantal = $recordteller\n";
              }
              
             
             $recordteller = 0;
             #&maak_trailer_xml;
              print "\n--------------\n";
             
             @group =[];
             undef @group;
             $contact ={};
             undef $contact;
             $group_onderdeel = {};
             $body_onderdeel ={};
             undef $data_xml ;
          
            # print "\n--------------\ndata xml leeg\n---------------\n\n";
            }
        
         &dscnnectdb ($dbconnectie );
         
        }
}
sub chk_voor_nieuwe_kaarthouders {
     #$dbh , nr zkf 203 of 235, nummer verzekering, taal N F, group nr, zkf nr ZKF 203 ZKF235, taal xml NL FR, taal brief xml,
     my $dbh = shift @_;   
     my $nrzkfcheck = shift @_;
     my $verzekering = shift @_;
     my $taal = shift @_;
     my $group_nr = shift@_;
     my $zkf_nr = shift @_; #ZKF203 of ZKF235
     my $taal_xml = shift @_;
     my $taal_brief_xml = shift @_;
     my $record_teller = shift @_;
     my @cardholders = ();
     my $vandaag = ParseDate("today");
     $vandaag = substr ($vandaag,0,8);  # vandaag in YYYYMMDD
     my $jaar = substr ($vandaag,0,4);
     my $max_aantal_kaarten_brief = $cardinstellingen->{ondersteunde_kaarten}->{$zkf_nr}->{max_aantal_kaarten_per_brief};
      #print "dossier  $zof_zkfnr $zof_externnr $zof_datum\n ";
      #we openen PHOEKK
      #IDFDKK              NUMERO MUTUELLE         /NUMME
      #A.EXIDKK              NUMERO EXTERNE          /EXTER
      #A.ABADKK              DATE DEBUT DOSSIER      /AANVA
      #A.ABEDKK              DATE FIN DOSSIER        /EINDD    
      #A.ABNOKK              NUMERO DOSSIER          /DOSSI    
      #A.ABPRKK              NO PRODUIT              /NUMME    
      #A.ABCTKK              CODE TITULAIRE          /CODET
      #A.ABTVKK              CODE VERZEKERING         /CODET
      #ABACKK              CODE AFFILIATION / AANSLUITING 
      #AB2AKK              CODE DETAIL AFFILIATION /DETAI
      #ABOCKK              CODE DESAFFILIATION     /ONTSL    
      #AB2OKK              CODE DETAIL DESAFFILIATION / D
      #ABPEKK              DATE PRISE D'EFFET     /AANVANGDATUM
      #openen van PFYSL8
      # EXIDL8 = extern nummer
      # KNRNL8 = nationaalt register nummer
      # NAMBL8 = naam van de gerechtigde
      # PRNBL8 = voornaam van de gerechtigde
      # SEXEL8 = code van het geslacht
      # NAIYL8 = geboortejaat
      # NAIML8 = geboortemaand
      # NAIJL8 = geboortedag
      # LANGL8 = taal code
      #openen van PADRJR op as400
      # EXIDJR = extern nummer
      # ABGIJR = soort adres post of gewoon post =02
      # ABKTJR = naam van de bewoner van het postadress
      # ABSTJR = naam van de straat
      # ABNTJR = huisnnummer
      # ABBTJR = busnummer
      # IV00JR = kode van het land
      # ABPTJR = postnummer
      # ABWTJR = woornplaats
      # ER ZIJN DUBBEL ENTRIES VOOR POSTADRES EN GEWOON ADRES WE KIJKEN OF ER EEN POSTADRES IS
      # het postadres heeft ABGIJR == 02 dit gaan we zoeken
      # KGERJR              CODE RUE DONN.LEGALE  
      #0-10
      #11 - 25
      #26-28
     my $sqlmutuitdet =("SELECT b.NAIYL8,b.NAIML8,b.NAIJL8,c.ABSTJR,c.ABNTJR,c.ABBTJR,c.ABPTJR,c.ABWTJR,c.IV00JR,c.ABGIJR,c.KGERJR,
                        a.ABNOKK,a.EXIDKK,b.KNRNL8,a.IDFDKK,a.ABTVKK,a.ABEDKK,a.ABOCKK,a.AB2OKK,a.ABFDKK,a.A140KK,a.ABACKK,a.AB2AKK,a.ABOCKK,a.AB2OKK,a.ABPEKK, 
                        b.NAMBL8,b.PRNBL8,b.LANGL8,b.SEXEL8
                        FROM $settings{'phoekk_fil'} a JOIN $settings{'pers_fil'} b ON a.EXIDKK=b.EXIDL8 JOIN $settings{'adres_fil'} c ON a.EXIDKK=EXIDJR
                        WHERE b.KNRNL8 != 0  and IDFDKK = $nrzkfcheck and ABOCKK = '' and ABTVKK = $verzekering and ABADKK <= $vandaag and b.LANGL8 = '$taal'
                        and CONCAT(a.ABACKK,a.AB2AKK) != 'A04' and CONCAT(a.ABACKK,a.AB2AKK) != 'L05' 
                        and b.KNRNL8 NOT IN (SELECT  KNRN52 FROM  $settings{'ascard_fil'}  WHERE LOSTCARD = 0 and CARDNR != 0 )
                        and (c.ABGIJR = (SELECT max( d.ABGIJR ) FROM $settings{'adres_fil'} d  WHERE d.EXIDJR =a.EXIDKK))  
                        ORDER BY c.IV00JR,c.KGERJR,c.ABPTJR,c.ABNTJR,c.ABBTJR,b.NAIYL8,b.NAIML8,b.NAIJL8 ASC " );#fetch first 10 rows only #versie 2.1 and CARDNR != 0
     my $sthmutuitdet = $dbh->prepare( $sqlmutuitdet ); #test and a.EXIDKK IN (810007100361,810013263497,810004841170)or CONCAT(a.ABACKK,a.AB2AKK) != 'L05')
     $sthmutuitdet ->execute();
     
     my $rusthuis=0;
     my $adres_old='';
     my $adres_new = '';
     my $adres_current ='';
     my $group_old = $group_nr ;
     my $body_nr = 0;
     my $straat_nr_bus_nr = '';
     my $achternaam_brief ='';
     my $voornaam_brief ='';
     my $land_naam = '';
     while(@cardholders =$sthmutuitdet->fetchrow_array)  {
         #@ext_nr=&checknaamextern ($cardholders[1]);
         $record_teller +=1;
         #print " $record_teller -> @cardholders \n";
         my $element;
         my $geslacht = '';
         $geslacht = 'M' if ($cardholders[29] == 1);
         $geslacht = 'F' if ($cardholders[29] == 2);
         foreach $element (@cardholders) { #verwijder de leading en trailing spaces
             $element =~ s/^\s+//;
             $element =~ s/\s+$//;
            }
         if (($jaar-$cardholders[0]) > 60) {
             $rusthuis = &checkofinrusthuis ($cardholders[11],$dbh);# code
             #print "rusthuis check ->";
         }
         $land_naam = $cardholders[8];
         $land_naam = '' if ($cardholders[8] eq 'B' or $cardholders[8] eq 'b' );
         $land_naam = 'DEUTCHLAND' if ($cardholders[8] eq 'D' or $cardholders[8] eq 'd' );
         $land_naam = 'FRANCE' if ($cardholders[8] eq 'F' or $cardholders[8] eq 'f' );
         $land_naam = 'GREECE' if ($cardholders[8] eq 'GR' or $cardholders[8] eq 'gr' );
         $land_naam = 'INDIA' if ($cardholders[8] eq 'IND' or $cardholders[8] eq 'ind' );
         $land_naam = 'LUXEMBURG' if ($cardholders[8] eq 'L' or $cardholders[8] eq 'l' );
         $land_naam = 'NEDERLAND' if ($cardholders[8] eq 'N' or $cardholders[8] eq 'n' );
         $land_naam = 'SWITZERLAND' if ($cardholders[8] eq 'CH' or $cardholders[8] eq 'ch' );
         $land_naam = 'ESPANA' if ($cardholders[8] eq 'E' or $cardholders[8] eq 'e' );
         $land_naam = 'ITALIA' if ($cardholders[8] eq 'I' or $cardholders[8] eq 'i' );
         $land_naam = 'THAILAND' if ($cardholders[8] eq 'THA' or $cardholders[8] eq 'tha' );
         $land_naam = 'PORTUGAL' if ($cardholders[8] eq 'POR' or $cardholders[8] eq 'por' );
         $land_naam = 'INDONESIA' if ($cardholders[8] eq 'INO' or $cardholders[8] eq 'ino' );
         $land_naam = 'GREAT BRITTAIN' if ($cardholders[8] eq 'GB' or $cardholders[8] eq 'gb' );
         $land_naam = 'SWEDEN' if ($cardholders[8] eq 'S' or $cardholders[8] eq 's' );
         $land_naam = 'TUNESIA' if ($cardholders[8] eq 'TUN' or $cardholders[8] eq 'tun' );
         $land_naam = 'MOROCCO' if ($cardholders[8] eq 'M' or $cardholders[8] eq 'm' );
         $adres_old = "$cardholders[8]"."$cardholders[6]"."$cardholders[4]"."$cardholders[5]" if ($group_old == $group_nr  and  $adres_old eq '');
         $adres_new = "$cardholders[8]"."$cardholders[6]"."$cardholders[4]"."$cardholders[5]";
         $straat_nr_bus_nr = "$cardholders[3] $cardholders[4] " if ($cardholders[5] eq '') ;
         $straat_nr_bus_nr = "$cardholders[3] $cardholders[4] B $cardholders[5]" if ($cardholders[5] ne '') ;
         my $geboorte_datum = sprintf ('%04s',$cardholders[0])."-".sprintf ('%02s',$cardholders[1])."-".sprintf ('%02s',$cardholders[2]);
         if ($body_nr < $max_aantal_kaarten_brief ) {
             if ($rusthuis == 0) {
                 if ($adres_old eq $adres_new ) {
                     #contact group nummer,ZKF203 of ZKF235, achternaam, voornaam ,straat nr bus nr, postcode, stad ,taalbrief uit settings vb Nederlands_brief, land
                     if ($body_nr == 0) {
                         #&maak_contact_xml ($group_nr,$zkf_nr,$cardholders[26],$cardholders[27],$straat_nr_bus_nr,$cardholders[6],$cardholders[7],$taal_xml,$land_naam);#code
                         $achternaam_brief =$cardholders[26];
                         $voornaam_brief = $cardholders[27];
                         $teller_aantal_brieven +=1;
                        }
                     #body group nummer,body nummer,ZKF203 of ZKF235, rijksregisternummer, dossier nummer,taal NL of FR,achternaam , voornaam, gegoortedatum YYYY-MM-DD, geslacht M of F
                     #straat nr bus nr, postcode, stad, land 
                     &maak_body_xml ($group_nr,$body_nr,$zkf_nr,$cardholders[13],$cardholders[11],$taal_xml,$cardholders[26],$cardholders[27],"$geboorte_datum",
                              $geslacht,$straat_nr_bus_nr,$cardholders[6],$cardholders[7],,$achternaam_brief,$voornaam_brief,$land_naam);
                     $body_nr +=1;
                     
                    }else {
                     $group_nr +=1;
                     my $teller=0;
                     my $body_nr_sp = sprintf ('%03s',$body_nr);    
                     for (my $tel = 0; $tel < $body_nr ;$tel +=1){
                          $teller = $tel + 1;
                          $teller = sprintf ('%03s',$teller);    
                          $group_onderdeel{Body}[$tel]{'FamilyGroupingCode'} = "$teller/$body_nr_sp";
                         }
                     $body_nr =0;
                     push (@group,{%group_onderdeel});
                     #print "hash\n";
                     delete $group_onderdeel{$_} for keys %group_onderdeel;
                     $achternaam_brief =$cardholders[26];
                     $voornaam_brief = $cardholders[27];
                     #&maak_contact_xml ($group_nr,$zkf_nr,$cardholders[26],$cardholders[27],$straat_nr_bus_nr,$cardholders[6],$cardholders[7],$taal_xml,$land_naam);
                     &maak_body_xml ($group_nr,$body_nr,$zkf_nr,$cardholders[13],$cardholders[11],$taal_xml,$cardholders[26],$cardholders[27],"$geboorte_datum",
                              $geslacht,$straat_nr_bus_nr,$cardholders[6],$cardholders[7],,$achternaam_brief,$voornaam_brief,$land_naam);
                     $body_nr +=1;
                     $teller_aantal_brieven +=1;
                    }
               }else {
                 $group_nr +=1;
                 my $teller=0;
                 my $body_nr_sp = sprintf ('%03s',$body_nr);    
                 for (my $tel = 0; $tel < $body_nr ;$tel +=1){
                     $teller = $tel + 1;
                     $teller = sprintf ('%03s',$teller);    
                     $group_onderdeel{Body}[$tel]{'FamilyGroupingCode'} = "$teller/$body_nr_sp";
                     }
                 $body_nr =0;
                 push (@group,{%group_onderdeel});
                 #print "hash\n";
                 delete $group_onderdeel{$_} for keys %group_onderdeel;
                 $achternaam_brief =$cardholders[26];
                 $voornaam_brief = $cardholders[27];
                 #&maak_contact_xml ($group_nr,$zkf_nr,$cardholders[26],$cardholders[27],$straat_nr_bus_nr,$cardholders[6],$cardholders[7],$taal_xml,$land_naam);
                 &maak_body_xml ($group_nr,$body_nr,$zkf_nr,$cardholders[13],$cardholders[11],$taal_xml,$cardholders[26],$cardholders[27],"$geboorte_datum",
                              $geslacht,$straat_nr_bus_nr,$cardholders[6],$cardholders[7],,$achternaam_brief,$voornaam_brief,$land_naam);
                 $body_nr +=1;    
                  $teller_aantal_brieven +=1;  
               }
          }else {
             $group_nr +=1;
             my $teller=0;
             my $body_nr_sp = sprintf ('%03s',$body_nr);    
             for (my $tel = 0; $tel < $body_nr ;$tel +=1){
                 $teller = $tel + 1;
                 $teller = sprintf ('%03s',$teller);    
                 $group_onderdeel{Body}[$tel]{'FamilyGroupingCode'} = "$teller/$body_nr_sp";
                }
             $body_nr =0;
             push (@group,{%group_onderdeel});
             print "hash\n";
             #print "hash\n";
             delete $group_onderdeel{$_} for keys %group_onderdeel;
             $achternaam_brief =$cardholders[26];
             $voornaam_brief = $cardholders[27];
             #&maak_contact_xml ($group_nr,$zkf_nr,$cardholders[26],$cardholders[27],$straat_nr_bus_nr,$cardholders[6],$cardholders[7],$taal_xml,$land_naam);
             &maak_body_xml ($group_nr,$body_nr,$zkf_nr,$cardholders[13],$cardholders[11],$taal_xml,$cardholders[26],$cardholders[27],"$geboorte_datum",
                              $geslacht,$straat_nr_bus_nr,$cardholders[6],$cardholders[7],,$achternaam_brief,$voornaam_brief,$land_naam);
             $body_nr +=1;
             $teller_aantal_brieven +=1;
          }
      $adres_old = "$cardholders[8]"."$cardholders[6]"."$cardholders[4]"."$cardholders[5]";
       #print "$aantalrij_kaart  ->@cardholders -> rusthuis $rusthuis \n";
          
      $aantalrij_kaart +=1;
            
        }
      my $teller=0;
      my $body_nr_sp = sprintf ('%03s',$body_nr);    
      for (my $tel = 0; $tel < $body_nr ;$tel +=1){
         $teller = $tel + 1;
         $teller = sprintf ('%03s',$teller);    
         $group_onderdeel{Body}[$tel]{'FamilyGroupingCode'} = "$teller/$body_nr_sp";
        }
     push (@group,{%group_onderdeel}) if (%group_onderdeel);
     #print "hash\n";
     delete $group_onderdeel{$_} for keys %group_onderdeel;
    # print "einde-loop chk_voor_nieuwe_kaarthouders -> $group_nr \n\n";
     return ($group_nr,$record_teller);
    }
    
sub ckh_of_ze_al_een_kaart_hebben {
     my $heeft_een_kaart =  0;
     my $rijsregister_nr = shift @_;
     my $dbh = shift @_;   
     my $nrzkfcheck = shift @_;
     &settings(203);
     $dbh1 = &cnnectdb ($settings{user_name},$settings{password},$settings{name_as400});
     my $kaart = $dbh1->selectrow_array("SELECT KNRN52 FROM $settings{'ascard_fil'} WHERE KNRN52= $rijsregister_nr and CARDNR != 0");#versie 2.1 and CARDNR != ''
     if (defined $kaart) {
         $heeft_een_kaart =  1;#code
     }
     &dscnnectdb ($dbh1);
     &settings($nrzkfcheck);
     return ($heeft_een_kaart);
}

sub maak_xml_file {
     my $dbh = shift @_;   
     my $zkf = shift @_;
     my $taal = shift @_;
     
     my $nrverzekeraar = $cardinstellingen->{nr_verzekeraar};
     my $soort_printer =  $cardinstellingen->{soort_printer};
     my $prod_test = $cardinstellingen->{productie_test};#productie_test;
     if ($prod_test =~ m/^t/i) {
        $soort_printer ="test$soort_printer";
     }
     
     my $produktie_test =  $cardinstellingen->{productie_test};
     my $plaats_file = $cardinstellingen->{plaats_file};
     my $vandaag = ParseDate("today");
     my $tijd = substr ($vandaag,8,8);
     $tijd =~ s/://g;
     $vandaag = substr ($vandaag,0,8);  # vandaag in YYYYMMDD
     
     my $batchnr = $dbh->selectrow_array ("SELECT MAX (BATCHNT) FROM $settings{'ascard_batchnr_fil'} ");
     $batchnr +=1;
     my $zetin = "INSERT INTO $settings{'ascard_batchnr_fil'} values (?,?,?,?)";
     my $sth = $dbh ->prepare($zetin);
         $sth->bind_param(1,$nrverzekeraar);
         $sth->bind_param(2,$batchnr);
         $sth->bind_param(3,$vandaag);
         $sth->bind_param(4,$produktie_test );
         $sth -> execute();
         $sth -> finish();
         #&dscnnectdb ($dbh1);
         print "batchnr  $batchnr ingezet";
     $batchnr = sprintf ('%05s',$batchnr);    
     #my $xmlfile= "$plaats_file\\$nrverzekeraar.$batchnr.$soort_printer.$vandaag.$tijd.$zkf.$taal.xml";
     my $xmlfile= "$plaats_file\\$nrverzekeraar.$batchnr.$soort_printer.$vandaag.$tijd.xml"; #versie 2.3
     open XMLFILE,"> $xmlfile" or die "can not open file $xmlfile ";
     select XMLFILE;
     close XMLFILE;
     select STDOUT;
     
     return ($xmlfile,$batchnr);
}
sub maak_header_xml {
     #header zkf,batch nr,aantal records
     my $ziekenfonds = shift @_;
     my $batch_nummer = shift @_;
     my $aantal_records = shift @_;
     my $taal_brief = shift @_;
     my $taal_code = shift @_;
     #$aantal_records =12;
     my $vandaag = ParseDate("today");
     $vandaag = substr ($vandaag,0,8);  # vandaag in YYYYMMDD
     $vandaag = sprintf "%04d-%02d-%02d",substr ($vandaag,0,4),substr ($vandaag,4,2),substr ($vandaag,6,2);
     my $Recordtype = 'T';
     $Recordtype = 'A' if ($cardinstellingen->{productie_test} =~ m/^p/i );
     $Recordtype = 'T' if ($cardinstellingen->{productie_test} =~ m/^t/i );
     $data_xml=
        {
            Header =>
                {
                  Recordtype => "$Recordtype",
                  ProjectName => "$cardinstellingen->{project_naam}",
                  Typeofcard => "$cardinstellingen->{type_kaart}",
                  InsuranceCompanyIndex => "$cardinstellingen->{nr_verzekeraar}",
                  LogoIndex => "$cardinstellingen->{ondersteunde_kaarten}->{$ziekenfonds}->{ondersteunde_talen}->{$taal_code}->{logo_kaart}",
                  CarrierType => "$taal_brief",
                  ExpeditionType => "$cardinstellingen->{ondersteunde_kaarten}->{$ziekenfonds}->{expeditie_type}",
                  Batchnumber => "$batch_nummer",
                  Numberofrecords => $aantal_records,
                  Electricalversion => "$cardinstellingen->{electrische_versie}",
                  Graphicalversion => "$cardinstellingen->{grafische_versie}",
                  PersonalizationDate => "$vandaag",
                  MultiCard  => $cardinstellingen->{ondersteunde_kaarten}->{$ziekenfonds}->{multi_card}
                },
                
            Group =>[@group],   
                
                
            Trailer => 
                {
                Recordtype => "Z",  
                }
                
        };
     
        
         
     
     print "header gemaakt \n";
    
}
sub maak_contact_xml {
     #contact group nummer,ZKF203 of ZKF235, achternaam, voornaam ,straat nr bus nr, postcode, stad, land ,taalbrief uit settings vb Nederlands_brief
     my $group_nummer = shift @_;
     my $ziekenfonds = shift @_;
     my $achternaam = shift @_;
     my $voornaam = shift @_;
     my $straat_nr_bus = shift @_;
     my $postcode = shift @_;
     my $stad = shift @_;
     my $taal = shift @_;
     my $land =shift @_;
     $group_onderdeel{Contact}=
   
            {
              #ContactText => '', #$cardinstellingen->{ondersteunde_kaarten}->{$ziekenfonds}->{ondersteunde_talen}->{$taal}->{brief},
              ContactLastname => "$achternaam",
              ContactFirstname => "$voornaam",
              ContactName => "$voornaam $achternaam",
              ContactAddress => "$straat_nr_bus",
              ContactPostalCode => "$postcode",
              ContactCity => "$stad",
              ContactCountry => "$land"
            };
        
      
        
        
    }
sub maak_body_xml {
      #body group nummer,body nummer,ZKF203 of ZKF235, rijksregisternummer, dossier nummer,taal NL of FR,achternaam , voornaam, gegoortedatum YYYY-MM-DD, geslacht M of F
      #straat nr bus nr, postcode, stad, land 
      my $group_nummer = shift @_;
      my $body_nr = shift @_;
      my $ziekenfonds = shift @_;
      my $rijksregister_nr = shift @_;
      my $card_id = ($cardinstellingen->{kaart_nummer_prefix})*100000000000+$rijksregister_nr;
      my $dossier_nummer = shift @_;
      my $taal = shift @_; #NL FR
      my $achternaam = shift @_;
      my $voornaam = shift @_;
      my $geboorte_datum = shift @_; #formaat YYYY-MM-DD
      my $geslacht = shift @_; #M F
      my $straat_nr_bus = shift @_;
      my $postcode = shift @_;
      my $stad = shift @_;
      my $achternaam_oudste = shift @_; #versie 1.4
      my $voornaam_oudste = shift @_; #versie 1.4
      my $land = shift @_;
      my $OpenField1 = "$cardinstellingen->{ondersteunde_kaarten}->{$ziekenfonds}->{open_veld1}";
      my $OpenField2 = "$cardinstellingen->{ondersteunde_kaarten}->{$ziekenfonds}->{open_veld2}";
      $OpenField1 = '' if ($OpenField1 eq '.');
      $OpenField2 = '' if ($OpenField2 eq '.');
      my $aanspreek = "$cardinstellingen->{nr_verzekeraar}",
      $body_onderdeel =
             {
              InsuranceCompanynumber => "$cardinstellingen->{nr_verzekeraar}",
              CardId => "$card_id",
              Contractnumber => "$dossier_nummer",
              Language => "$taal",
              PoliteRemark  => "$cardinstellingen->{ondersteunde_kaarten}->{$ziekenfonds}->{ondersteunde_talen}->{$taal}->{$geslacht}",
              InsuranceRepresentative => "$cardinstellingen->{ondersteunde_kaarten}->{$ziekenfonds}->{vertegenwoordiger_verzekeraar}",
              InsurerCity => "$cardinstellingen->{ondersteunde_kaarten}->{$ziekenfonds}->{stad_verzekeraar}",
              HolderLastname => "$achternaam",
              HolderFirstname => "$voornaam",
              HolderName => "$voornaam $achternaam",
              HolderBirthdate => "$geboorte_datum",
              HolderGender => "$geslacht",
              OpenField1 => $OpenField1 ,
              OpenField2 => $OpenField2,
              CarrierLastname => "$achternaam_oudste",
              CarrierFirstname => "$voornaam_oudste",
              CarrierName =>  "$voornaam_oudste $achternaam_oudste",
              CarrierAddress => "$straat_nr_bus" ,
              CarrierPostalCode => => "$postcode",
              CarrierCity => "$stad",
              CarrierCountry => "$land",
              InsuranceCompanyName => "$cardinstellingen->{naam_bedrijf}"
            };
     push (@{$group_onderdeel{Body}},$body_onderdeel); 
     #print "push body gedaan";  
   }

sub maak_trailer_xml {
    $data_xml->{Trailer}=
             {
                Recordtype => "Z",  
             };
    
        
    }
sub schrijf_xml_file {
     my $xml_file = shift @_;
     my $xsd = $cardinstellingen->{plaats_xsd};
     my $schema = XML::Compile::Schema->new($xsd);
     $schema->printIndex();
     warn $schema->template('PERL', 'InformationFlow');
     my $doc    = XML::LibXML::Document->new('1.0', 'UTF-8');
     my $write  = $schema->compile(WRITER => 'InformationFlow');
     my $xml    = $write->($doc,$data_xml);
     $doc->setDocumentElement($xml);
     open XMLFILE,"> $xml_file" or die "can not open file $xml_file ";
     select XMLFILE;
     print $doc->toString(1); # 1 indicates "pretty print"
     close XMLFILE;
     select STDOUT;
     &patch_replace($xml_file); #versie 2.3
}
sub insert_kaart_gemaakt_in_DB {
     my $ZKF = shift @_;
     my $dbh = shift @_;
     #ZKF
     #EXID52 extern nummer
     #KNRN52 rijksregister nummer
     #DOSSNR dossiernr
     #NAAM52 naam
     #VNAAM voornaam
     #INZDAT    datum caard ok en ingezet
     #CREDAT datum file naar assurcard zetes
     #EINDAT einddatum kaart
     #EINCON einddatum contract
     #CARDNR cardnummer
     #ASSNR  assurcar ensurance number
     #OKNOW  is nu ok als yes
     #DTCGOK datum waarop ok het laast werd veranderd
     #CARDTY cardtype
     #DTCATY datum waarop het cardtype het laatst verandert werd$
     #LOSTCARD kaart is verloren en er moet een ieuwe gegenereerd 0 is niet verloren 1 = verloren
     #BATCHNR nummer van de batch waarmee de kaart gemaakt
     #TESTPROD  VARCHAR(1) T is test P = productie
     my $EXID52=0;
     my $CARDNR = 0;
     my $DOSSNR = 0;
     my $KNRN52 = 0;
     my $NAAM52 ='';
     my $VNAAM ='';
     my $TESTPROD =  $data_xml -> {Header} -> {Recordtype};
     my $BATCHNR  =  $data_xml -> {Header} -> {Batchnumber};
     my $ASSNR =  $data_xml -> {Header} -> {InsuranceCompanyIndex};
     my $CREDAT=  $data_xml -> {Header} -> {PersonalizationDate};
     $CREDAT =~ s/-//g;
     my $CARDTY =  $data_xml -> {Header} -> {LogoIndex};
     my $LOSTCARD = 0;
     my $OKNOW = 'Y';
     my $DTCGOK = $CREDAT;
     my $INZDAT = $CREDAT;
     my $DTCATY = $CREDAT;
     my $EINDAT = 99999999;
     my $EINCON = 99999999;
     my @sqlrecord_bestaat;
     my $ONTSLAGO ='N';
     my $CXMLINIT ='N';
     my $CXMLUPDA ='N';
     my $WANBET = 'N';
     my $ONTSLAG = 'N';
     
     my $AGRESONR = $dbh->selectrow_array("SELECT MAX(AGRESONR) FROM $settings{'ascard_fil'}");#versie 2.0
     $AGRESONR = 100000 if(!defined $AGRESONR) ;       #versie 2.0     
     foreach my $gp_nummer (keys $data_xml->{Group}) {
         
         foreach my $bd_nummer (keys $data_xml->{Group}->[$gp_nummer]->{Body}) {
             $CARDNR = $data_xml->{Group}->[$gp_nummer]->{Body}->[$bd_nummer]->{CardId};
             $DOSSNR = $data_xml->{Group}->[$gp_nummer]->{Body}->[$bd_nummer]->{Contractnumber};
             $KNRN52 = $data_xml->{Group}->[$gp_nummer]->{Body}->[$bd_nummer]->{CardId};
             $KNRN52 = substr($KNRN52,1,11);
             $NAAM52 = $data_xml->{Group}->[$gp_nummer]->{Body}->[$bd_nummer]->{HolderLastname};
             $VNAAM = $data_xml->{Group}->[$gp_nummer]->{Body}->[$bd_nummer]->{HolderFirstname};
             $EXID52 = &check_ext_via_natreg ($KNRN52,$dbh); #versie 2.0
             $AGRESONR +=1;#versie 2.0
             @sqlrecord_bestaat = $dbh->selectrow_array ("SELECT KNRN52,LOSTCARD FROM $settings{'ascard_fil'} WHERE KNRN52= $KNRN52");
             if (!$sqlrecord_bestaat[0]) {
                  #print "$KNRN52 record bestaat niet\n";
                  my $zetin = "INSERT INTO $settings{'ascard_fil'} values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
                  my $sth= $dbh ->prepare($zetin);
                  $sth->bind_param(1,$ZKF);
                  $sth->bind_param(2,$EXID52);
                  $sth->bind_param(3,$KNRN52);
                  $sth->bind_param(4,$DOSSNR);
                  $sth->bind_param(5,$NAAM52);
                  $sth->bind_param(6,$VNAAM);
                  $sth->bind_param(7,$INZDAT);
                  $sth->bind_param(8,$CREDAT);
                  $sth->bind_param(9,$EINDAT);
                  $sth->bind_param(10,$EINCON);
                  $sth->bind_param(11,$CARDNR);
                  $sth->bind_param(12,$ASSNR);
                  $sth->bind_param(13,$OKNOW);
                  $sth->bind_param(14,$DTCGOK);
                  $sth->bind_param(15,$CARDTY);
                  $sth->bind_param(16,$DTCATY);
                  $sth->bind_param(17,$LOSTCARD);
                  $sth->bind_param(18,$BATCHNR);
                  $sth->bind_param(19,$TESTPROD);
                  $sth->bind_param(20,$ONTSLAGO);
                  $sth->bind_param(21,$CXMLINIT);
                  $sth->bind_param(22,$CXMLUPDA);
                  $sth->bind_param(23,$WANBET);
                  $sth->bind_param(24,$ONTSLAG);
                  $sth->bind_param(25,$AGRESONR);
                  $sth -> execute();
                  $sth -> finish()
                }elsif ($sqlrecord_bestaat[1] ==1){
                  print "$KNRN52 record bestaat -> lostcard  !!!!!\n";
                  &card_lost_reset ($sqlrecord_bestaat[0],$dbh);
                }else {
                  print "$KNRN52 record bestaat en geen lostcard  -> stond in met andere verzekering door agresso ??\n";
                  my @sqlrecord_bestaat1 = $dbh->selectrow_array ("SELECT KNRN52,LOSTCARD FROM $settings{'ascard_fil'} WHERE KNRN52= $KNRN52 and CARDNR =0");
                  if ($sqlrecord_bestaat1[0]) {
                     #iemand ingezet door agresso
                      print "$KNRN52 agresso record opgevuld!!!!!\n";
                     &verander_agresso_lid_naar_kaart ($dbh,$KNRN52,$ZKF,$EXID52,$DOSSNR,$INZDAT,$CREDAT,
                                                       $EINDAT,$EINCON,$CARDNR,$ASSNR,$OKNOW,$DTCGOK,$CARDTY,$DTCATY,$LOSTCARD,
                                                       $BATCHNR,$TESTPROD,$ONTSLAGO,$CXMLINIT,$CXMLUPDA,$WANBET,$ONTSLAG);
                    }else {
                     print "er klopt is niet cardnr is niet 0 ?"
                    }
                  
                  
                }
               # print "testinsert";
            }
        }
    }
sub mail_bericht {
     print "mail-start\n";
     my $aan = $cardinstellingen->{mail_verslag_naar};
     my @aan_lijst = split (/\,/,$aan);
     my $van = 'harry.conings@vnz.be';
     my $vandaag = ParseDate("today");
     $vandaag = substr ($vandaag,0,8);  # vandaag in YYYYMMDD
     $vandaag = sprintf "%04d-%02d-%02d",substr ($vandaag,0,4),substr ($vandaag,4,2),substr ($vandaag,6,2);
     foreach $geadresseerde (@aan_lijst) {
         $smtp = Net::SMTP->new('10.63.120.3',
                    Hello => 'mail.vnz.be',
                    Timeout => 60);
         $smtp->auth('mailprogrammas','pleintje203');
         $smtp->mail($van);
         $smtp->to($geadresseerde);
         $smtp->cc('informatica.mail@vnz.be');
         #$smtp->bcc("bar@blah.net");
         $smtp->data;
         $smtp->datasend("From: harry.conings");
         $smtp->datasend("\n");
         $smtp->datasend("To: Kaartbeheerders");
         $smtp->datasend("\n");
         $smtp->datasend("Subject: Kaart generatie verslag van $vandaag");
         $smtp->datasend("\n");
         $smtp->datasend("$mail\nvriendelijke groeten\nHarry Conings");
         $smtp->dataend;
         $smtp->quit;
         print "mail aan $geadresseerde  gezonden\n";
        }
    }

sub datum_laatste_generatie {
     my $zkf = shift @_;
     my $dbh = shift @_;
     #ZKF
     #EXID52 extern nummer
     #KNRN52 rijksregister nummer
     #DOSSNR dossiernr
     #NAAM52 naam
     #VNAAM voornaam
     #INZDAT    datum caard ok en ingezet
     #CREDAT datum file naar assurcard zetes
     #EINDAT einddatum kaart
     #EINCON einddatum contract
     #CARDNR cardnummer
     #ASSNR  assurcar ensurance number
     #OKNOW  is nu ok als yes
     #DTCGOK datum waarop ok het laast werd veranderd
     #CARDTY cardtype
     #DTCATY datum waarop het cardtype het laatst verandert werd
     #LOSTCARD kaart is verloren en er moet een ieuwe gegenereerd 0 is niet verloren 1 = verloren
     #BATCHNR nummer van de batch waarmee de kaart gemaakt
     #TESTPROD  VARCHAR(1) T is test P = productie
     my $vandaag = ParseDate("today");
     $vandaag = substr ($vandaag,0,8);  # vandaag in YYYYMMDD
     #$vandaag = sprintf "%04d-%02d-%02d",substr ($vandaag,0,4),substr ($vandaag,4,2),substr ($vandaag,6,2);
     my $sql =("SELECT max(CREDAT) FROM $settings{'ascard_fil'} WHERE ZKF = $zkf"); 
     my $sth = $dbh->prepare( $sql );
     my $dagen_geleden = 0;
     $sth->execute();
     while(my $datum_laatste =$sth->fetchrow_array)  {
         my $datum_laatste1 = sprintf "%04d-%02d-%02d",substr ($datum_laatste,0,4),substr ($datum_laatste,4,2),substr ($datum_laatste,6,2);
         my  $delta = DateCalc($datum_laatste,$vandaag,1);
         #$delta = DateCalc($vandaag,2014215,1);
         $dagen_geleden = Delta_Format($delta, 0,'%dt');
         $dagen_geleden =~ s/\.0+//;
         print "datum laatste = $datum_laatste1 -> aantal dagen geleden $dagen_geleden\n ";
         $mail = $mail."datum laatste productie: $datum_laatste1 -> aantal dagen geleden $dagen_geleden \n"
     }
     return ($dagen_geleden);
     #print "select gedaan";
}
sub check_ext_via_natreg {
      my $natnummer_ext = shift @_;
      my $dbh = shift @_;
      $extern_nummer=0;
      #openen van PFYSL8
      # EXIDL8 = extern nummer
      # KNRNL8 = nationaalt register nummer
      # NAMBL8 = naam van de gerechtigde
      # PRNBL8 = voornaam van de gerechtigde
      # SEXEL8 = code van het geslacht
      # NAIYL8 = geboortejaat
      # NAIML8 = geboortemaand
      # NAIJL8 = geboortedag
      $extern_nummer = $dbh->selectrow_array("SELECT EXIDL8 FROM $settings{'pers_fil'} WHERE KNRNL8= $natnummer_ext");
      return ($extern_nummer);


}
sub patch_replace{ #versie 2.3
      my $input_file = shift @_;
      my $input_zonder_extensie = $input_file;
      $input_zonder_extensie =~ s/\.xml//g;
      copy("$input_file","$input_zonder_extensie.bak") or &copy_failed("$input_zonder_extensie");
      open (INPUTFILE,"$input_zonder_extensie.bak") or &open_failed("$input_zonder_extensie.bak") ;
      unlink ($input_file) or &cannot_unlink($input_file);
      my $teller = 0;
      my $te_vervangen_door_dit ='<InformationFlow xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="InformationFlow.xsd">';
      while ($record = <INPUTFILE>) {
           chomp $record;
           open OUTPUTFILE,">>$input_file" or&open_failed($input_file);
           select OUTPUTFILE;
           $record =~ s/<InformationFlow>/$te_vervangen_door_dit/;
           if ($record =~ m%<LogoIndex>\d+</LogoIndex>% ) {
                $record =~ m%>\d+<%;
                my $logo_index = $&;
                $logo_index =~ s/>//g;
                $logo_index =~ s/<//g;
                $logo_index = sprintf ('%02s',$logo_index);  #voorafgaande nullen terug zetten
                $record = "<LogoIndex>$logo_index</LogoIndex>";
           }
            if ($record =~ m%<CarrierType>\d+</CarrierType>% ) {
                $record =~ m%>\d+<%;
                my $CarrierType = $&;
                $CarrierType =~ s/>//g;
                $CarrierType =~ s/<//g;
                $CarrierType = sprintf ('%03s',$CarrierType);  #voorafgaande nullen terug zetten
                $record = "<CarrierType>$CarrierType</CarrierType>";
           }
           print "$record";
           print "\n";
           close OUTPUTFILE;
           $teller +=1;
          }
      close INPUTFILE;
      select STDOUT;
     }

sub copy_failed {
      my $input_file = shift @_;
      print "\n!!kan file $input_file niet kopieren voor de patch to te passen\n";
      $mail = $mail."\n!!kan file $input_file niet kopieren voor de patch to te passen!!\n";
}
sub open_failed {
      my $input_file = shift @_;
      print "\n!!kan file $input_file niet openen voor de patch to te passen\n";
      $mail = $mail."\n!!kan file $input_file niet openen voor de patch to te passen!!\n";
}
sub cannot_unlink {
      my $input_file = shift @_;
      print "\n!!kan file $input_file niet verwijderen voor de patch to te passen\n";
      $mail = $mail."\n!!kan file $input_file niet verwijderen voor de patch to te passen!!\n";
}
1;