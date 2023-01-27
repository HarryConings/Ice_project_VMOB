#!/usr/bin/perl -w
#versie 4.5 Error code 5020 :  expiration date before startdate
#cersie 4.4 nullen voor rijksregisternr
#versie 4.2 wachttijd
#versie 4.1 aangepast fouten slechts 1 xml
#versie 4.0 zoek ook nieuwe leden die niet in contract xml zitten
#versie 3.0 aangepast aan kaartnrs = 0 voor vezekeringen met geen kaart
#versie 2.0 aangepast aan agresso nr
use strict;

use XML::Simple;
use Date::Manip::DM5 ;
use Data::Dumper;
use XML::Compile::Schema;
use XML::LibXML::Reader;
use Net::SMTP;
use Date::Calc qw(:all);
use Array::Diff;
use List::MoreUtils qw(uniq);
use File::Copy;
use Win32::FileOp;
require "settings.pl";
require "cnnectdb.pl";
require "chkbetaling5.pl";
require "assurcard_card_updates.pl";
#require "assurcard_contract_write_xml.pl";
#require 'assurcard_card_generation.1.6.pl';

use vars qw(%settings $contract_cardinstellingen $mail_contract @te_onderzoeken_verzekering @ziekenfonds_nummers $data_xml_contracts $Concracts %Concracts @Concracts $add_ingezet $updates_ingezet $zkf_add_ingezet $zkf_updates_ingezet $data_contract_xml);
$mail_contract ="MAAK CONTRACT XML AAN\n";
$mail_contract = $mail_contract."============================================================\n============================================================\n\n";
print "MAAK CONTRACT XML AAN\n";
print "============================================================\n============================================================\n\n";
&load_assurcard_generation_setting_contact_a('P:\OGV\ASSURCARD_PROG\assurcard_settings_xml\assurcard_card_generation_settings.xml');
#&maak_xml_file_contract; #test
#&load_assurcard_generation_setting_contact_a('X:\mob-hospiplan-2014\vnzmodules\assurcard_card_generation_settings.xml');
print "\n1. => ZOEK DE ONSTLAGEN\n============================================================\n\n";
$mail_contract = $mail_contract."\n1. => ZOEK DE ONSTLAGEN\n============================================================\n\n";
&zoek_de_onslagen_contract;
print "\n2. => ONDERZOEK OF DE UITGEMUTTEERDE OOK INGEMUTEERD WORDEN\n============================================================\n";
$mail_contract = $mail_contract."\n2. => ONDERZOEK OF DE UITGEMUTTEERDE OOK INGEMUTEERD WORDEN\n============================================================\n";
&check_of_B10_werkelijk_naar_ander_zkf_gemuteerd_is_contract;
print "\n3. => ZOEK NAAR WANBETALERS\n";
print "============================================================\n\n";
$mail_contract = $mail_contract."\n3. => ZOEK NAAR WANBETALERS\n";
$mail_contract = $mail_contract."============================================================\n\n";
&zoek_de_wanbetalers_contract;
print "\n4. => ZOEK NAAR EX WANBETALERS\n";
print "============================================================\n\n";
$mail_contract = $mail_contract."\n4. => ZOEK NAAR EX WANBETALERS\n";
$mail_contract = $mail_contract."============================================================\n\n";
&zoek_de_ex_wanbetalers_contract ;
print "\n5. => ZOEK NAAR VERANDERDE RIJKSREGNUMMERS\n";
print "============================================================\n\n";
$mail_contract = $mail_contract. "\n5. => ZOEK NAAR VERANDERDE RIJKSREGNUMMERS\n";
$mail_contract = $mail_contract."============================================================\n\n";
&zoek_veranderde_rijksregisternr_contract ;
print "\n6. => MAAK CONTRACT XML AAN\n";
print "============================================================\n\n";
$mail_contract = $mail_contract."\n6. => MAAK CONTRACT XML AAN\n";
$mail_contract = $mail_contract."============================================================\n\n";;
#&maak_data_voor_xml_aan_contract;
&maak_xml_file_contract;
&mail_contract_bericht_contract;
print "einde\n";
sub load_assurcard_generation_setting_contact_a  {
     my $file_name = shift @_;
     $contract_cardinstellingen = XMLin("$file_name");
     print "settings ingelezen\n";
     $mail_contract = $mail_contract."settings ingelezen\n";
     #maak verzekeringen
    
    }
sub zoek_de_onslagen_contract {
      my $aantalrij_kaart=0;
      @te_onderzoeken_verzekering =();
      my $verzekerings_nr= 0;
      my $ziekenfondsnr =0;
      my $dbconnectie = '';
      foreach my $ziekfonds (keys %{$contract_cardinstellingen->{verzekeringen_met_kaart}}){ # de mogelijke ziekenfondsen
         $ziekfonds =~ m/\d{3}/;
         $ziekenfondsnr = $&;
         push (@ziekenfonds_nummers,$ziekenfondsnr);
         $mail_contract = $mail_contract."\n-----------------\n$ziekfonds -> $ziekenfondsnr\n";
         print "\n-----------------\n$ziekfonds -> $ziekenfondsnr\n";
         &settings( $ziekenfondsnr);
         my $recordteller = 0; # het aantal records
         $dbconnectie = &cnnectdb ($settings{user_name},$settings{password},$settings{name_as400});
         $verzekerings_nr= 0;
         @te_onderzoeken_verzekering =();
         foreach my $verzekering (keys %{$contract_cardinstellingen->{verzekeringen_met_kaart}->{$ziekfonds}}){ # de verzekering per ziekenfonds
             print"\t->$verzekering :";
             $verzekerings_nr= $contract_cardinstellingen->{verzekeringen_met_kaart}->{$ziekfonds}->{$verzekering};
             print " $verzekerings_nr\n";
             $mail_contract = $mail_contract."      ->$verzekering : $verzekerings_nr\n";
             push (@te_onderzoeken_verzekering,$verzekerings_nr);
            }
          &zoek_ontslagen_contract ($dbconnectie,$ziekenfondsnr);
          &zoek_ex_leden_die_terug_lid_worden_contract ($dbconnectie,$ziekenfondsnr);
          @te_onderzoeken_verzekering =();
        }
     
    }
sub zoek_ontslagen_contract {
     my $dbh = shift @_;   
     my $nrzkfcheck = shift @_;
     #my $verzekering = shift @_;
     my $vandaag = ParseDate("today");
     $vandaag = substr ($vandaag,0,8);  # vandaag in YYYYMMDD
     #$vandaag ='20140401';
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
      #Dit zijn de ontslagcodes met hun betekenis : 
      #  B  MUTATIE BINNEN LANDSBOND 
      #  10 AANVAARD       
      #  C  OUT ANDER ZIEK.          
      #  25 WORDT PTL OF RECHTHEBBEN.
      #  C  OUT ANDER ZIEK.          
      #  26 WORDT GER.OF HOOFDRECHTH.
      #  G  BEHEERDER                
      #  06 SLECHTE BETALER          
      #  G  BEHEERDER                
      #  11 GEWEIGERDE AANSLUITING   
      #  G  BEHEERDER                
      #  13 FOUT CODEREN             
      #  G  BEHEERDER                
      #  23 ADMINISTRAT BESLISSING   
      #  I  OVERLIJDEN              
      #  16 ZONDER ONDERSCHEID      
      #  L  MUTATIE BUITEN LANDSBOND
      #  10 AANVAARD                
      #  Q  VERPLICHT ONTSLAG       
      #  06 SLECHTE BETALER         
      #  T  TRANSFER                
      #  19 PRODUCT NAAR PRODUCT    
      #  T  TRANSFER                
      #  20 DOSSIER NAAR DOSSIER    
      #  T  TRANSFER                   
      #  25 WORDT PTL OF RECHTHEBBEN.
      #  T  TRANSFER                   
      #  26 WORDT GER.OF HOOFDRECHTH.  
      #  V  VRIJWILLIG ONTSLAG         
      #  01 VERTREK NAAR BUITENLAND    
      #  V  VRIJWILLIG ONTSLAG         
      #  02 AANGEVRAAGD ONTSLAG        
        #Ontslagcodes T19 - T20 – T25 en T26  dt krijgen we niet in de sql (dan staat het dossiernr wel fout)
        #ð  Bij deze kunnen de kaarten verder lopen, gezien deze mensen gewoon “verhuizen” van het dossier ouders/partner naar een eigen dossier.
        #Bij ontslagcodes G23 kan de kaart ook soms behouden worden behalve bij HospiContinu.
        #Vb.
        #Plan – G23 – naar Plus : OK  diet wordt opgevangen daaor de sql
        #Plus – G23 – naar Plan : OK
        #Plan – G23 – naar Continu : NOK
        #Plus – G23 – naar Continu : NOK

 


      my $te_onderzoeken = '';
      foreach (@te_onderzoeken_verzekering) {
         $te_onderzoeken = $te_onderzoeken.','.$_; 
      }
      $te_onderzoeken =~ s/^,//;
      my $sqlmutuitdet =("SELECT a.KNRN52,a.DOSSNR,a.EINCON,c.ABEDKK,c.ABOCKK,c.AB2OKK,c.ABTVKK,b.EXIDL8
                        FROM $settings{'ascard_fil'} a JOIN $settings{'pers_fil'} b ON a.KNRN52=b.KNRNL8 JOIN $settings{'phoekk_fil'} c ON b.EXIDL8=c.EXIDKK
                        WHERE c.ABTVKK IN  ($te_onderzoeken) and a.CARDNR != 0 and a.ZKF =$nrzkfcheck and a.KNRN52 != 0 and OKNOW = 'Y'
                        and b.EXIDL8 NOT IN (SELECT  EXIDKK  FROM  $settings{'phoekk_fil'}  WHERE ABEDKK >= $vandaag and ABTVKK IN  ($te_onderzoeken)  )
                        ORDER BY a.KNRN52,a.DOSSNR"); #and a.CARDNR != 0 versie 3.0
     my $sthmutuitdet = $dbh->prepare( $sqlmutuitdet );
     $sthmutuitdet ->execute();
     my $aantaltij= 0;
     print "\nNr -> Rijksregister Dossier VorigEind Einddat code verz Extern Nr ->Uitleg\n";
     print "----------------------------------------------------------------------------------------------\n";
     $mail_contract = $mail_contract."\nNr -> Rijksregister Dossier Vorige Eind Einddat code verz Extern Nr ->Uitleg\n";
     $mail_contract = $mail_contract."----------------------------------------------------------------------------------------------\n";
     while(my @cardholders =$sthmutuitdet->fetchrow_array)  {
         my $rrnr_nullen = sprintf ('%011s',$cardholders[0]); 
         if ($cardholders[4] eq 'B' and $cardholders[5] == 10) {
              #mutatie binnen de landsbond             
             print "$aantaltij -> $rrnr_nullen $cardholders[1] $cardholders[2] $cardholders[3] $cardholders[4] $cardholders[5] $cardholders[6] $cardholders[7]-> mutatie naar het ander zkf\n";             
             $mail_contract = $mail_contract."$aantaltij -> $rrnr_nullen $cardholders[1] $cardholders[2] $cardholders[3] $cardholders[4] $cardholders[5] $cardholders[6] $cardholders[7] -> mutatie naar het ander zkf\n";
              #einddatum rijksregisternummer,dbh
              &einddatum_contract ($cardholders[3],$cardholders[0],$dbh);
              &zet_onderzoek_onslag ($dbh,$nrzkfcheck,$cardholders[0]); 
         }else {
             #altijd eindatum inzetten
              print "$aantaltij -> $rrnr_nullen $cardholders[1] $cardholders[2] $cardholders[3] $cardholders[4] $cardholders[5] $cardholders[6] $cardholders[7]-> onstlagen -> einddatum inzetten\n";
              $mail_contract = $mail_contract."$aantaltij -> $rrnr_nullen $cardholders[1] $cardholders[2] $cardholders[3] $cardholders[4] $cardholders[5] $cardholders[6] $cardholders[7] -> onstlagen -> einddatum inzetten\n";
               #einddatum rijksregisternummer,dbh
              &einddatum_kaart ($cardholders[3],$cardholders[0],$dbh);
         }
         
        
         
         $aantaltij += 1;
     }
}

sub check_of_B10_werkelijk_naar_ander_zkf_gemuteerd_is_contract{
     foreach my $zoekzkf (@ziekenfonds_nummers) {
         &settings ($zoekzkf);
         my $dbh = &cnnectdb ($settings{user_name},$settings{password},$settings{name_as400});
         my $sqlmutuitdet =("SELECT KNRN52,DOSSNR,EINCON
                             FROM $settings{'ascard_fil'} WHERE ONTSLAGO = 'Y' and ZKF = $zoekzkf and CARDNR != 0 ");#and a.CARDNR != 0 versie 3.0
         my $sthmutuitdet = $dbh->prepare( $sqlmutuitdet );
         $sthmutuitdet ->execute();
         my $aantaltij =0;
         while(my @cardholders =$sthmutuitdet->fetchrow_array)  {
             my $rrnr_nullen = sprintf ('%011s',$cardholders[0]); 
             print "$aantaltij onderzoek -> $rrnr_nullen $cardholders[1] $cardholders[2]\n";
             $mail_contract = $mail_contract."$aantaltij onderzoek -> $rrnr_nullen $cardholders[1] $cardholders[2]\n";
             #zien of hij/zij niet veranderd is van ziekenfonds
             &check_of_gemuteerd_tussen_zkf_contract ($zoekzkf,$cardholders[0]);
             $aantaltij += 1;
            }
         
        }
        
    }
sub check_of_gemuteerd_tussen_zkf_contract {
     my $zoek_zkf= shift @_;
     my $rr_nr =shift @_;
     my $rrnr_nullen = sprintf ('%011s',$rr_nr); 
     my $eind_datum = shift @_;
     my $vandaag = ParseDate("today");
     my $rc = '';
     my $zkf_te_onderzoeken_xml ='';
     $vandaag = substr ($vandaag,0,8);  # vandaag in YYYYMMDD
     #$vandaag ='20140401';
      
     foreach my $zkf_te_onderzoeken (@ziekenfonds_nummers) {
         if ($zkf_te_onderzoeken != $zoek_zkf) {
              &settings ($zkf_te_onderzoeken);#code
              my $dbh1 = &cnnectdb ($settings{user_name},$settings{password},$settings{name_as400});
              my $te_onderzoeken ='';
              $zkf_te_onderzoeken_xml = "ZKF$zkf_te_onderzoeken";
              my $verzekerings_nr ='';
              foreach my $verzekering (keys %{$contract_cardinstellingen->{verzekeringen_met_kaart}->{$zkf_te_onderzoeken_xml}}){
                 # de verzekering per ziekenfonds
                 $verzekerings_nr= $contract_cardinstellingen->{verzekeringen_met_kaart}->{$zkf_te_onderzoeken_xml}->{$verzekering};
                 $te_onderzoeken = $te_onderzoeken.','.$verzekerings_nr; 
              }
              $te_onderzoeken =~ s/^,//;
              print "     $zoek_zkf rrnr $rrnr_nullen onderzoek ->$zkf_te_onderzoeken :\n";
              $mail_contract = $mail_contract."     $zoek_zkf rrnr $rrnr_nullen onderzoek ->$zkf_te_onderzoeken :\n";
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
              my $sqlmutuitdet1 =("SELECT b.NAIYL8,b.NAIML8,b.NAIJL8,
                        a.ABNOKK,a.EXIDKK,b.KNRNL8,a.IDFDKK,a.ABTVKK,a.ABEDKK,a.ABOCKK,a.AB2OKK,a.ABFDKK,a.A140KK,a.ABACKK,a.AB2AKK,a.ABOCKK,a.AB2OKK,a.ABPEKK, 
                        b.NAMBL8,b.PRNBL8,b.LANGL8,b.SEXEL8
                        FROM $settings{'phoekk_fil'} a JOIN $settings{'pers_fil'} b ON a.EXIDKK=b.EXIDL8 
                        WHERE b.KNRNL8 = $rr_nr and IDFDKK = $zkf_te_onderzoeken and ABOCKK = '' and ABTVKK IN ($te_onderzoeken) and ABADKK <= $vandaag  " );#fetch first 10 rows only
              my $sthmutuitdet1 = $dbh1->prepare( $sqlmutuitdet1 );
              $sthmutuitdet1 ->execute();
              my $aantaltijr = 0;
              while(my @cardholders1 =$sthmutuitdet1->fetchrow_array)  {
                 print "     gevonden->$aantaltijr -> @cardholders1\n";
                 $mail_contract = $mail_contract."     gevonden->$aantaltijr -> @cardholders1\n";
                 &delete_onderzoek_onslag_verander_zkf_dossiernr_lostcard ($dbh1,$zkf_te_onderzoeken,$cardholders1[5],$cardholders1[3],$cardholders1[4]); #versie 2.0 ->,$cardholders1[4]
                 #zien of hij/zij niet veranderd is van ziekenfonds
                 $aantaltijr += 1;
                }
              if ( $aantaltijr == 0) {
                 print "     niet gevonden in $zkf_te_onderzoeken -> $zoek_zkf rrnr $rr_nr onderzoek ->$zkf_te_onderzoeken\n" ;
                 $mail_contract = $mail_contract."     niet gevonden in $zkf_te_onderzoeken -> $zoek_zkf rrnr $rr_nr onderzoek ->$zkf_te_onderzoeken\n" ;
                 my $sqlmutuitdet2 =("SELECT KNRN52,DOSSNR,EINCON,EINDAT
                             FROM $settings{'ascard_fil'} WHERE ONTSLAGO = 'Y' and KNRN52 = $rr_nr and CARDNR != 0");#and a.CARDNR != 0 versie 3.0
                 my $sthmutuitdet2 = $dbh1->prepare( $sqlmutuitdet2 );
                 $sthmutuitdet2 ->execute();
                 my $aantaltij =0;
                 while(my @cardholders2 =$sthmutuitdet2->fetchrow_array)  {
                     my $jaar1 = substr ($cardholders2[2],0,4);
                     my $maand1 = substr ($cardholders2[2],4,2);
                     my $dag1 = substr ($cardholders2[2],6,2);
                     #print "$jaar1,$maand1,$dag1,\n";
                     if ($jaar1 == 9999) {
                          $jaar1 =5000;#code
                          $maand1 = 10;
                          $dag1 = 10;
                     }
                     
                     my $checkjaar= 0;
                     my $checkmaand =0;
                     my $checkdag =0;
                     ( $checkjaar,$checkmaand,$checkdag) =
                      Add_Delta_YMD($jaar1,$maand1,$dag1,0,0,10);
                     my $checkdatum =  $checkjaar*10000+$checkmaand*100+$checkdag;           
                     if (($cardholders2[2] != $cardholders2[3]) and   $checkdatum  < $vandaag) {
                          #einddatum rijksregisternummer,dbh
                         &einddatum_kaart ($cardholders2[3],$cardholders2[0],$dbh1);#code
                        }
                     
                    }
                 
              }
              $rc = $dbh1 ->disconnect();
              
           }
         
        }
     &settings ($zoek_zkf);#code
    
    }
sub mail_contract_bericht_contract {
     print "mail-start\n";
     my $aan = $contract_cardinstellingen->{mail_verslag_naar};
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
         $smtp->cc('informatica.mail@vnz.be');
         #$smtp->bcc("bar@blah.net");
         $smtp->data;
         $smtp->datasend("From: harry.conings");
         $smtp->datasend("\n");
         $smtp->datasend("To: Kaartbeheerders");
         $smtp->datasend("\n");
         $smtp->datasend("Subject: Contract xml generatie verslag $vandaag");
         $smtp->datasend("\n");
         $smtp->datasend("$mail_contract\nvriendelijke groeten\nHarry Conings");
         $smtp->dataend;
         $smtp->quit;
         print "mail aan $geadresseerde  gezonden\n";
        }
    }
sub zoek_ex_leden_die_terug_lid_worden_contract {
     #$dbh , nr zkf 203 of 235, nummer verzekering, taal N F, group nr, zkf nr ZKF 203 ZKF235, taal xml NL FR, taal brief xml,
     my $dbh = shift @_;   
     my $nrzkfcheck = shift @_;
     my $te_onderzoeken = '';
     my $vandaag = ParseDate("today");
     $vandaag = substr ($vandaag,0,8);  # vandaag in YYYYMMDD
     #&settings ($nrzkfcheck);#cod
     foreach (@te_onderzoeken_verzekering) {
         $te_onderzoeken = $te_onderzoeken.','.$_; 
      }
     $te_onderzoeken =~ s/^,//;
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
      my $sqlmutuitdet =("SELECT b.KNRNL8,a.ABNOKK,a.ABTVKK,b.NAMBL8,b.PRNBL8,a.ABADKK
                        FROM $settings{'phoekk_fil'} a JOIN $settings{'pers_fil'} b ON a.EXIDKK=b.EXIDL8 
                        WHERE b.KNRNL8 != 0 and IDFDKK = $nrzkfcheck and ABOCKK = '' and ABTVKK IN  ($te_onderzoeken) and ABADKK <= $vandaag 
                        and b.KNRNL8 IN (SELECT  KNRN52 FROM  $settings{'ascard_fil'}  WHERE OKNOW != 'Y' and EINDAT != 99999999 and WANBET != 'Y' and CARDNR != 0)
                        ORDER BY b.KNRNL8" );#fetch first 10 rows only #versie 3.0 and CARDNR != 0
      my $sthmutuitdet = $dbh->prepare( $sqlmutuitdet );
      $sthmutuitdet ->execute();
      print "\nWe kunnen volgende personen terug als lid verwelkomen:\n";
      print "--------------------------------------------------------\n";
      $mail_contract = $mail_contract."\nWe kunnen volgende personen terug als lid verwelkomen:\n";
      $mail_contract = $mail_contract."--------------------------------------------------------\n";
      my $aantal_rij =0;
      while(my @cardholders_old =$sthmutuitdet->fetchrow_array)  {
         print "$aantal_rij -> @cardholders_old \n";
         $mail_contract = $mail_contract."$aantal_rij -> @cardholders_old \n";
         &activeer_de_kaart ($dbh,$cardholders_old[0],$cardholders_old[0],$nrzkfcheck);
         $aantal_rij +=1;
        }
      if ($aantal_rij ==0) {
          print "\nEr zijn geen personen die we terug als lid konden verwelkomen:\n";
          $mail_contract = $mail_contract."\nEr zijn geen personen die we terug als lid konden verwelkomen:\n";
        }
      print "\n";
      $mail_contract = $mail_contract."\n";

}
sub zoek_de_wanbetalers_contract {
      my $aantalrij_kaart=0;
      @te_onderzoeken_verzekering =();
      my $verzekerings_nr= 0;
      my $ziekenfondsnr =0;
      my $dbconnectie = '';
      foreach my $ziekfonds (keys %{$contract_cardinstellingen->{verzekeringen_met_kaart}}){ # de mogelijke ziekenfondsen
         $ziekfonds =~ m/\d{3}/;
         $ziekenfondsnr = $&;
         push (@ziekenfonds_nummers,$ziekenfondsnr);
         $mail_contract = $mail_contract."\n-----------------\n$ziekfonds -> $ziekenfondsnr\n";
         print "\n-----------------\n$ziekfonds -> $ziekenfondsnr\n";
         &settings( $ziekenfondsnr);
         my $recordteller = 0; # het aantal records
         $dbconnectie = &cnnectdb ($settings{user_name},$settings{password},$settings{name_as400});
         $verzekerings_nr= 0;
         @te_onderzoeken_verzekering =();
         foreach my $verzekering (keys %{$contract_cardinstellingen->{verzekeringen_met_kaart}->{$ziekfonds}}){ # de verzekering per ziekenfonds
             print"\t->$verzekering :";
             $verzekerings_nr= $contract_cardinstellingen->{verzekeringen_met_kaart}->{$ziekfonds}->{$verzekering};
             print " $verzekerings_nr\n";
             $mail_contract = $mail_contract."      ->$verzekering : $verzekerings_nr\n";
             push (@te_onderzoeken_verzekering,$verzekerings_nr);
            }
          &zoek_wanbetalers_contract ($dbconnectie,$ziekenfondsnr);
          @te_onderzoeken_verzekering =();
        }
     
}
sub zoek_wanbetalers_contract {
      my $dbh = shift @_;   
      my $nrzkfcheck = shift @_;
      my $te_onderzoeken = '';
      foreach (@te_onderzoeken_verzekering) {
         $te_onderzoeken = $te_onderzoeken.','.$_; 
      }
      my $vandaag = ParseDate("today");
      $vandaag = substr ($vandaag,0,8);  # vandaag in YYYYMMDD
      my $vandaag_jaar = substr ($vandaag,0,4);  # vandaag in YYYYMMDD
      my $vandaag_maand= substr ($vandaag,4,2);  # vandaag in YYYYMMDD
      my $vandaag_dag= substr ($vandaag,6,2);  # vandaag in YYYYMMDD
      $te_onderzoeken =~ s/^,//;
      my $sql =("SELECT a.KNRN52,b.EXIDL8,c.IDFDKK,c.ABTVKK,c.ABEDKK,c.ABOCKK,c.AB2OKK  
                        FROM $settings{'ascard_fil'} a JOIN $settings{'pers_fil'} b ON a.KNRN52=b.KNRNL8
                        JOIN $settings{'phoekk_fil'} c ON b.EXIDL8=c.EXIDKK
                        WHERE c.ABTVKK IN  ($te_onderzoeken) and a.KNRN52 != 0 and a.OKNOW = 'Y' and c.ABEDKK > $vandaag and a.CARDNR != 0 ORDER BY a.KNRN52");
      my $sth = $dbh->prepare( $sql );
      $sth ->execute();
      my @betaling =();
      my $teller =0;
      my $rood_teller=0;
      print "\nnr Rijksregister -> jaar maand bedrag saldo totaal\n";
      print "----------------------------------------------------\n";
      $mail_contract = $mail_contract."\nnr Rijksregister -> jaar maand bedrag saldo totaal\n";
      $mail_contract = $mail_contract."----------------------------------------------------\n";
      my  $Dd = 1;
      my $test=0;
      while(my @cardholder =$sth->fetchrow_array)  {
         my $rrnr_nullen = sprintf ('%011s',$cardholder[0]); 
         # we hebben nodig als input
         #my $nr_zkf = shift @_ ;
         #my $type_verz= shift @_;
         #my $externnummer = shift @_;
         #my $betaling_fil = shift @_;
         #my $dbh = shift @_;
         # subroutine geeft terug  nr-zkf,nr_extern,type_verz,jaar laatste bet,maandlaatste bet, bedrag,saldo,totaal al gestord,habben nooit betaald als 1 nooit
        
         @betaling = &checkbetaling ($cardholder[2],$cardholder[3],$cardholder[1],$settings{'ptaxkq_fil'},$dbh);
         print "$teller $cardholder[0] ext $cardholder[1] verzekering $betaling[2] laaste betaling -> $betaling[1]/$betaling[0]";
         #$mail_contract = $mail_contract."$teller $cardholder[0] verzekering $betaling[2] laaste betaling -> $betaling[1]/$betaling[0]";
         if ($betaling[0] == 0 or $betaling[1] == 0) {
              $Dd = 0;#code
         }else {
             $Dd = Delta_Days($vandaag_jaar,$vandaag_maand,$vandaag_dag,$betaling[0],$betaling[1],28);            
         }
         my $aantal_dagen_te_laat = 0;
         if ($Dd < 0) {
             $aantal_dagen_te_laat = -$Dd;
             if ($aantal_dagen_te_laat < $contract_cardinstellingen->{'maximum_aantal_dagen_openstaande_taxatie'} ) {
                 print " -> $aantal_dagen_te_laat dagen te laat binnen de tolerantie van $contract_cardinstellingen->{'maximum_aantal_dagen_openstaande_taxatie'} dagen -> ok\n";
                 #$mail_contract = $mail_contract." -> $aantal_dagen_te_laat dagen te laat binnen de tolerantie van $contract_cardinstellingen->{'maximum_aantal_dagen_openstaande_taxatie'} dagen -> ok\n";
                 #niets doen &reset_wanbetaler ($dbh,$nrzkfcheck,$cardholder[0]);
             }else {
                 print "$rood_teller $rrnr_nullen verzekering $cardholder[3] laaste betaling -> $betaling[1]/$betaling[0]";
                 print " -> HEBBEN NOOIT BETAALD ? " if ($betaling[5]==1);
                 print " -> $aantal_dagen_te_laat dagen te laat meer dan $contract_cardinstellingen->{'maximum_aantal_dagen_openstaande_taxatie'} dagen-> kaart op rood\n" ;#code
                 $mail_contract = $mail_contract."$rood_teller $rrnr_nullen verzekering $cardholder[3] laaste betaling -> $betaling[1]/$betaling[0]";
                 $mail_contract = $mail_contract." -> HEBBEN NOOIT BETAALD ? ->" if ($betaling[5]==1);
                 $mail_contract = $mail_contract." -> $aantal_dagen_te_laat dagen te laat meer dan $contract_cardinstellingen->{'maximum_aantal_dagen_openstaande_taxatie'} dagen-> kaart op rood\n" ;#code
                 $rood_teller +=1;
                 &zet_wanbetaler_in ($dbh,$nrzkfcheck,$cardholder[0],$teller);
             }
         }else {
             print " -> $Dd ok\n";
             #$mail_contract = $mail_contract." -> $Dd ok\n";
             #niets doen &reset_wanbetaler ($dbh,$nrzkfcheck,$cardholder[0],$teller);
         }
         
         $teller += 1;
         #last if ($teller == 10);
      }
}
sub zoek_de_ex_wanbetalers_contract {
      my $aantalrij_kaart=0;
      @te_onderzoeken_verzekering =();
      my $verzekerings_nr= 0;
      my $ziekenfondsnr =0;
      my $dbconnectie = '';
      foreach my $ziekfonds (keys %{$contract_cardinstellingen->{verzekeringen_met_kaart}}){ # de mogelijke ziekenfondsen
         $ziekfonds =~ m/\d{3}/;
         $ziekenfondsnr = $&;
         push (@ziekenfonds_nummers,$ziekenfondsnr);
         $mail_contract = $mail_contract."\n-----------------\n$ziekfonds -> $ziekenfondsnr\n";
         print "\n-----------------\n$ziekfonds -> $ziekenfondsnr\n";
         &settings( $ziekenfondsnr);
         my $recordteller = 0; # het aantal records
         $dbconnectie = &cnnectdb ($settings{user_name},$settings{password},$settings{name_as400});
         $verzekerings_nr= 0;
         @te_onderzoeken_verzekering =();
         foreach my $verzekering (keys %{$contract_cardinstellingen->{verzekeringen_met_kaart}->{$ziekfonds}}){ # de verzekering per ziekenfonds
             print"\t->$verzekering :";
             $verzekerings_nr= $contract_cardinstellingen->{verzekeringen_met_kaart}->{$ziekfonds}->{$verzekering};
             print " $verzekerings_nr\n";
             $mail_contract = $mail_contract."      ->$verzekering : $verzekerings_nr\n";
             push (@te_onderzoeken_verzekering,$verzekerings_nr);
            }
          &zoek_ex_wanbetalers_contract ($dbconnectie,$ziekenfondsnr);
          @te_onderzoeken_verzekering =();
        }
     
}
sub  zoek_ex_wanbetalers_contract {
      my $dbh = shift @_;   
      my $nrzkfcheck = shift @_;
      my $te_onderzoeken = '';
      foreach (@te_onderzoeken_verzekering) {
         $te_onderzoeken = $te_onderzoeken.','.$_; 
      }
      my $vandaag = ParseDate("today");
      $vandaag = substr ($vandaag,0,8);  # vandaag in YYYYMMDD
      my $vandaag_jaar = substr ($vandaag,0,4);  # vandaag in YYYYMMDD
      my $vandaag_maand= substr ($vandaag,4,2);  # vandaag in YYYYMMDD
      my $vandaag_dag= substr ($vandaag,6,2);  # vandaag in YYYYMMDD
      $te_onderzoeken =~ s/^,//;
      my $sql =("SELECT a.KNRN52,b.EXIDL8,c.IDFDKK,c.ABTVKK,c.ABEDKK,c.ABOCKK,c.AB2OKK  
                        FROM $settings{'ascard_fil'} a JOIN $settings{'pers_fil'} b ON a.KNRN52=b.KNRNL8
                        JOIN $settings{'phoekk_fil'} c ON b.EXIDL8=c.EXIDKK
                        WHERE c.ABTVKK IN  ($te_onderzoeken) and a.KNRN52 != 0 and a.OKNOW = 'N' and c.ABEDKK > $vandaag and WANBET= 'Y' and CARDNR != 0 ORDER BY a.KNRN52"); #versie 3.0
      my $sth = $dbh->prepare( $sql );
      $sth ->execute();
      my @betaling =();
      my $teller =0;
      my $groen_teller=0;
      print "\nnr Rijksregister -> jaar maand bedrag saldo totaal\n";
      print "----------------------------------------------------\n";
      $mail_contract = $mail_contract."\nnr Rijksregister -> jaar maand bedrag saldo totaal\n";
      $mail_contract = $mail_contract."----------------------------------------------------\n";
      my  $Dd = 1;
      my $test=0;
      while(my @cardholder =$sth->fetchrow_array)  {
         my $rrnr_nullen = sprintf ('%011s',$cardholder[0]); 
         # we hebben nodig als input
         #my $nr_zkf = shift @_ ;
         #my $type_verz= shift @_;
         #my $externnummer = shift @_;
         #my $betaling_fil = shift @_;
         #my $dbh = shift @_;
         # subroutine geeft terug  nr-zkf,nr_extern,type_verz,jaar laatste bet,maandlaatste bet, bedrag,saldo,totaal al gestord,habben nooit betaald als 1 nooit
                 
         @betaling = &checkbetaling ($cardholder[2],$cardholder[3],$cardholder[1],$settings{'ptaxkq_fil'},$dbh);
         print "$teller $cardholder[0] ext verzekering $cardholder[1]  $betaling[2] laaste betaling -> $betaling[1]/$betaling[0]";
         #$mail_contract = $mail_contract."$teller $cardholder[0] verzekering $betaling[2] laaste betaling -> $betaling[1]/$betaling[0]";
         if ($betaling[0] == 0 or $betaling[1] == 0) {
              $Dd = 0;#code
         }else {
             $Dd = Delta_Days($vandaag_jaar,$vandaag_maand,$vandaag_dag,$betaling[0],$betaling[1],28);            
         }
         #$Dd = Delta_Days($vandaag_jaar,$vandaag_maand,$vandaag_dag,$betaling[0],$betaling[1],28);
         my $aantal_dagen_te_laat = 0;
         
          
         if ($Dd < 0) {
             $aantal_dagen_te_laat = -$Dd;
             if ($aantal_dagen_te_laat < $contract_cardinstellingen->{'maximum_aantal_dagen_openstaande_taxatie'} ) {
                  print "$groen_teller $rrnr_nullen verzekering $cardholder[3] laaste betaling -> $betaling[1]/$betaling[0]";
                  print " -> $aantal_dagen_te_laat dagen te laat binnen de tolerantie van $contract_cardinstellingen->{'maximum_aantal_dagen_openstaande_taxatie'} dagen -> ex wanbetaler activeer kaart \n";
                  $mail_contract = $mail_contract."$groen_teller $rrnr_nullen verzekering $cardholder[3] laaste betaling -> $betaling[1]/$betaling[0]";
                  $mail_contract = $mail_contract." -> $aantal_dagen_te_laat dagen te laat binnen de tolerantie van $contract_cardinstellingen->{'maximum_aantal_dagen_openstaande_taxatie'} dagen -> ex wanbetaler activeer kaart \n";
                  &reset_wanbetaler ($dbh,$nrzkfcheck,$cardholder[0]);
                 $groen_teller +=1;
             }else {
                 print "$aantal_dagen_te_laat > $contract_cardinstellingen->{'maximum_aantal_dagen_openstaande_taxatie'} -> niets doen\n";
                 #print "$rood_teller $cardholder[0] verzekering $cardholder[3] laaste betaling -> $betaling[1]/$betaling[0]";
                 #print " -> HEBBEN NOOIT BETAALD ? ->" if ($betaling[5]==1);
                 #print " -> $aantal_dagen_te_laat dagen te laat meer dan $contract_cardinstellingen->{'maximum_aantal_dagen_openstaande_taxatie'} dagen-> kaart op rood\n" ;#code
                 #$mail_contract = $mail_contract."$rood_teller $cardholder[0] verzekering $cardholder[3] laaste betaling -> $betaling[1]/$betaling[0]";
                 #$mail_contract = $mail_contract." -> HEBBEN NOOIT BETAALD ? ->" if ($betaling[5]==1);
                 #$mail_contract = $mail_contract." -> $aantal_dagen_te_laat dagen te laat meer dan $contract_cardinstellingen->{'maximum_aantal_dagen_openstaande_taxatie'} dagen-> kaart op rood\n" ;#code
                 #
                 #&zet_wanbetaler_in ($dbh,$nrzkfcheck,$cardholder[0],$teller);
             }
         }else {
              print "$groen_teller $rrnr_nullen verzekering $cardholder[3] laaste betaling -> $betaling[1]/$betaling[0]";
              print " -> $aantal_dagen_te_laat dagen te laat binnen de tolerantie van $contract_cardinstellingen->{'maximum_aantal_dagen_openstaande_taxatie'} dagen -> ex wanbetaler activeer kaart \n";
              $mail_contract = $mail_contract."$groen_teller $rrnr_nullen verzekering $cardholder[3] laaste betaling -> $betaling[1]/$betaling[0]";
              $mail_contract = $mail_contract." -> $aantal_dagen_te_laat dagen te laat binnen de tolerantie van $contract_cardinstellingen->{'maximum_aantal_dagen_openstaande_taxatie'} dagen -> ex wanbetaler activeer kaart \n";
              #niets doen &reset_wanbetaler ($dbh,$nrzkfcheck,$cardholder[0]);
              &reset_wanbetaler ($dbh,$nrzkfcheck,$cardholder[0]);
              $groen_teller +=1;
         }
         
         $teller += 1;
         #last if ($teller == 10);
      }
}

sub zoek_veranderde_rijksregisternr_contract {
     my $aantalrij_kaart=0;
     my $ziekenfondsnr =0;
     my $dbh = '';
     my @ziekenfondsen = ();
     my $vandaag = ParseDate("today");
     my @array_rrnr_1 =();
     my @array_rrnr_2 =();
     my @array_rrnr_3 =();
     my @array_rrnr_4 =();
     my @array_rrnr_1_gesorteerd= ();
     my @array_rrnr_2_gesorteerd= ();
     $vandaag = substr ($vandaag,0,8);  # vandaag in YYYYMMDD
     foreach my $ziekfonds (keys %{$contract_cardinstellingen->{verzekeringen_met_kaart}}){ # de mogelijke ziekenfondsen
         $ziekfonds =~ m/\d{3}/;
         $ziekenfondsnr = $&;
         push (@ziekenfondsen,$ziekenfondsnr);
        }
     my $zkf_teller=0;
     my $disconnect=0;
     my $rrnrteller =0;
     my $sql;
     my $sth;
     foreach my $zkf (@ziekenfondsen) {
         &settings($zkf);
         $zkf_teller +=1;
         my $recordteller = 0; # het aantal records
         $dbh = &cnnectdb ($settings{user_name},$settings{password},$settings{name_as400});
        
         
         if ($zkf_teller == 1) {
             $sql =("SELECT KNRN52,ZKF,EXID52 FROM $settings{'ascard_fil'} where KNRN52 IN (SELECT KNRNL8 FROM  $settings{'pers_fil'}) and KNRN52 != 0 and OKNOW = 'Y' ORDER BY KNRN52");
             $sth = $dbh->prepare( $sql );
             $sth ->execute();
             while(my @rrnr =$sth->fetchrow_array)  {
                 push (@array_rrnr_1,$rrnr[0]);
                 #print "wel in zkf $zkf rrnr: $rrnr[0]" if ($rrnr[0] == 2111310818);
                 $rrnrteller +=1;
                }
             #print "$zkf alle rijkregnrs die in een zkf zijn ->$rrnrteller\n";
                    
            }elsif ($zkf_teller == 2) {
             my $sql =("SELECT KNRN52,ZKF,EXID52 FROM $settings{'ascard_fil'} where KNRN52 IN (SELECT KNRNL8 FROM  $settings{'pers_fil'}) and KNRN52 != 0 and OKNOW = 'Y' ORDER BY KNRN52");
             #my $sql =("SELECT a.KNRN52,a.ZKF FROM $settings{'ascard_fil'} a JOIN $settings{'pers_fil'} b ON a.KNRN52=b.KNRNL8  WHERE a.KNRN52 != 0 ORDER BY KNRN52");
             my $sth = $dbh->prepare( $sql );
             $sth ->execute();
             while(my @rrnr =$sth->fetchrow_array)  {
                 push (@array_rrnr_1,$rrnr[0]);
                 #print "wel in zkf $zkf rrnr: $rrnr[0]" if ($rrnr[0] == 2111310818);
                 $rrnrteller +=1;
                 #print "array_2 ->$rrnrteller-> @rrnr\n";
                }
            }
        }
     #print "alle rijkregnrs die in een zkf zijn ->$rrnrteller\n";
     my @unique = uniq(@array_rrnr_1);
     @array_rrnr_1_gesorteerd = sort {$a <=> $b} @unique;
     $rrnrteller =0;
     $sql =("SELECT KNRN52,ZKF FROM $settings{'ascard_fil'} where KNRN52 != 0 and OKNOW = 'Y' ORDER BY KNRN52");
     #my $sql =("SELECT a.KNRN52,a.ZKF FROM $settings{'ascard_fil'} a JOIN $settings{'pers_fil'} b ON a.KNRN52=b.KNRNL8  WHERE a.KNRN52 != 0 ORDER BY KNRN52");
     $sth = $dbh->prepare( $sql );
     $sth ->execute();
     while(my @rrnr =$sth->fetchrow_array)  {
         push (@array_rrnr_2,$rrnr[0]);
         $rrnrteller +=1;
        }
     #print "alle rijkregnrs die in de database zitten ->$rrnrteller\n";
     @array_rrnr_2_gesorteerd = sort {$a <=> $b} @array_rrnr_2;
     
     my $rrn_niet_in_zkf = 0;   
     my $diff = Array::Diff->diff( \@array_rrnr_1_gesorteerd, \@array_rrnr_2_gesorteerd);
     my $aantal_verschillend =0;   # 2
     foreach my $verwijderde_rrn (@{$diff->added}) {
         my $rrnr_nullen = sprintf ('%011s',$verwijderde_rrn); 
         print "$aantal_verschillend $rrnr_nullen niet teruggevonden in pfysl8 -> ";
         $mail_contract = $mail_contract."$aantal_verschillend $rrnr_nullen niet teruggevonden in pfysl8 -> ";
         #&einddatum_kaart($vandaag,$verwijderde_rrn,$dbh);
         my @zkf_exid_knrn = $dbh->selectrow_array("SELECT ZKF,EXID52,KNRN52 FROM $settings{'ascard_fil'} where KNRN52 = $verwijderde_rrn and OKNOW = 'Y'");
         if (defined $zkf_exid_knrn[0]) {
             &settings ($zkf_exid_knrn[0]);#code
             my $dbh1 = &cnnectdb ($settings{user_name},$settings{password},$settings{name_as400});
             my $new_KNRN52 = $dbh1->selectrow_array("SELECT KNRNL8 FROM  $settings{'pers_fil'} WHERE EXIDL8=$zkf_exid_knrn[1] and IDFDL8=$zkf_exid_knrn[0]") ;
             if (defined $new_KNRN52 ) {
                 &verander_rijksregister_nummer($dbh1,$zkf_exid_knrn[0],$new_KNRN52,$zkf_exid_knrn[1]);#code
                 print "nieuw rijksregister gevonden -> nummer verandert\n";
                 $mail_contract = $mail_contract."nieuw rijksregister gevonden -> nummer verandert\n";
             }else {
                 print "nieuw rijksregister nummer niet gevonden -> kaart op rood\n";
                 $mail_contract = $mail_contract."nieuw rijksregister nummer niet gevonden -> kaart op rood\n";
                 &einddatum_kaart($vandaag,$verwijderde_rrn,$dbh);
             }
             
         }else {
              print "extern nummer niet gevonden -> kaart op rood\n";
              $mail_contract = $mail_contract."extern nummer niet gevonden -> kaart op rood\n";
              &einddatum_kaart($vandaag,$verwijderde_rrn,$dbh);
         }
         
         
         $aantal_verschillend +=1;
     }
    foreach my $verwijderde_rrn (@{$diff->deleted}) {
         my $rrnr_nullen = sprintf ('%011s',$verwijderde_rrn); 
         print "$aantal_verschillend $rrnr_nullen niet teruggevonden in pfysl8 -> ";
         $mail_contract = $mail_contract."$aantal_verschillend $rrnr_nullen niet teruggevonden in pfysl8 -> ";
         my @zkf_exid_knrn = $dbh->selectrow_array ("SELECT ZKF,EXID52,KNRN52 FROM $settings{'ascard_fil'} where KNRN52 = $verwijderde_rrn and OKNOW = 'Y'");
         #&einddatum_kaart($vandaag,$verwijderde_rrn,$dbh);
         if (defined $zkf_exid_knrn[0]) {
             &settings ($zkf_exid_knrn[0]);#code
             my $dbh1 = &cnnectdb ($settings{user_name},$settings{password},$settings{name_as400});
             my $new_KNRN52 = $dbh1->selectrow_array("SELECT KNRNL8 FROM  $settings{'pers_fil'} WHERE EXIDL8=$zkf_exid_knrn[1] and IDFDL8=$zkf_exid_knrn[0]") ;
             if (defined $new_KNRN52 ) {
                 &verander_rijksregister_nummer($dbh1,$zkf_exid_knrn[0],$new_KNRN52,$zkf_exid_knrn[1]);#code
                 print "nieuw rijksregister gevonden -> nummer verandert\n";
                 $mail_contract = $mail_contract."nieuw rijksregister gevonden -> nummer verandert\n";
             }else {
                 print "nieuw rijksregister nummer niet gevonden -> kaart op rood\n";
                 $mail_contract = $mail_contract."nieuw rijksregister nummer niet gevonden -> kaart op rood\n";
                 &einddatum_kaart($vandaag,$verwijderde_rrn,$dbh);
             }
             
         }else {
              print "extern nummer niet gevonden -> kaart op rood\n";
              $mail_contract = $mail_contract."extern nummer niet gevonden -> kaart op rood\n";
              &einddatum_kaart($vandaag,$verwijderde_rrn,$dbh);
         }
         $aantal_verschillend +=1;
     }
     $disconnect = $dbh ->disconnect();
     if ($aantal_verschillend == 0) {
          print "Geen verwijderde rijksregister nummers gevonden\n";
         $mail_contract = $mail_contract."Geen verwijderde rijksregister nummers gevonden\n";
     }
     
     #print "verschil\n";
    }                        
sub maak_data_voor_xml_aan_contract {
      my $aantalrij_kaart=0;
      @te_onderzoeken_verzekering =();
      my $verzekerings_nr= 0;
      my $ziekenfondsnr =0;
      my $dbconnectie = '';
      print "maak xml\n";
      foreach my $ziekfonds (keys %{$contract_cardinstellingen->{verzekeringen_met_kaart}}){ # de mogelijke ziekenfondsen
         $ziekfonds =~ m/\d{3}/;
         $ziekenfondsnr = $&;
         push (@ziekenfonds_nummers,$ziekenfondsnr)
      }
      $data_xml_contracts->{Contracts}=> "$contract_cardinstellingen->{nr_verzekeraar}";
      
     
}

sub maak_xml_file_contract {
     my $ziekenfondsnr;
     my $verzekerings_nr =0;
     @ziekenfonds_nummers =();
     $add_ingezet =0;
     $updates_ingezet =0;
     $zkf_add_ingezet =0;
     $zkf_updates_ingezet =0;
     foreach my $ziekfonds (keys %{$contract_cardinstellingen->{verzekeringen_met_kaart}}){ # de mogelijke ziekenfondsen
         $ziekfonds =~ m/\d{3}/;
         $ziekenfondsnr = $&;
         push (@ziekenfonds_nummers,$ziekenfondsnr);
         $mail_contract = $mail_contract."\n-----------------\n$ziekfonds -> $ziekenfondsnr\n";
         print "\n-----------------\n$ziekfonds -> $ziekenfondsnr\n";
         $zkf_add_ingezet =0;
         $zkf_updates_ingezet =0;
          foreach my $verzekering (keys %{$contract_cardinstellingen->{verzekeringen_met_kaart}->{$ziekfonds}}){ # de verzekering per ziekenfonds
             #print"\t->$verzekering :";
             $verzekerings_nr= $contract_cardinstellingen->{verzekeringen_met_kaart}->{$ziekfonds}->{$verzekering};
             print "      ->$verzekering : $verzekerings_nr\n";
             $mail_contract = $mail_contract."      ->$verzekering : $verzekerings_nr\n";
             &settings( $ziekenfondsnr);
              my $dbh = &cnnectdb ($settings{user_name},$settings{password},$settings{name_as400});
             &maak_hash ($ziekenfondsnr,$verzekering,$verzekerings_nr,$dbh);
            }
         print "Voor $ziekfonds -> $ziekenfondsnr -> $zkf_updates_ingezet kaarten gewijzigd en $zkf_add_ingezet kaarten toegevoegd\n";
         $mail_contract = $mail_contract."Voor $ziekfonds -> $ziekenfondsnr -> $zkf_updates_ingezet kaarten gewijzigd en $zkf_add_ingezet kaarten toegevoegd\n";
        }
     print "\nIn het totaal $updates_ingezet kaarten gewijzigd en $add_ingezet kaarten toegevoegd\n";
     $mail_contract = $mail_contract."\nIn het totaal $updates_ingezet kaarten gewijzigd en $add_ingezet kaarten toegevoegd\n";  
     $data_contract_xml = {Contract =>[@Concracts],
                           InsurerAssurCardIdentifier => "$contract_cardinstellingen->{nr_verzekeraar}"
                           };
     my $vandaag = ParseDate("today");
     my $tijd = substr ($vandaag,8,8);
     $tijd =~ s/://g;
     $vandaag = substr ($vandaag,0,8);  # vandaag in YYYYMMDD
     my $plaatsxml= $contract_cardinstellingen->{plaats_file};
     my $nrverzekeraar = $contract_cardinstellingen->{nr_verzekeraar};
     my $naam_file = "$plaatsxml\\Contracts.$nrverzekeraar.$vandaag.$tijd.xml";
     my $dbh = &cnnectdb ($settings{user_name},$settings{password},$settings{name_as400});
     &schrijf_contracts_xml_file ($naam_file,$dbh);
     print "\nDe file kan je vinden op $naam_file\n";
     $mail_contract = $mail_contract."\nDe file kan je vinden op $naam_file\n";
     &copy_file_to_assurcard_upload ($naam_file);
}
sub maak_hash {
     my $ziekenfonds =shift @_;
     my $verzekering_naam = shift @_;
     my $verzekering_nummer = shift @_;
     my $dbh = shift @_;
     #hash layout
     # my $data = {
     #
     # Contract =>
     #[
     #    {
     #       ProfileIdentifier => "profile",
     #       PolicyHolder => {
     #         GenderCode => "F",
     #         PostalCode => "example",
     #         BirthYear => "2006",
     #         BirthDate => "2006-10-06",
     #         PatientName => "examplename",
     #            
     #        },
     #       Method =>  {
     #         FunctionTypeName => "add",
     #       
     #        },
     #        AssurCardIdentifier => "exampleid",
     #        StartDate => "2006-10-06",
     #        ExpirationDate => "2006-10-06",
     #    },
     #  
     #],      
     #
     #InsurerAssurCardIdentifier => "014",
     #} ;
     &zoek_welke_toegevoegd_moeten_worden ($ziekenfonds,$verzekering_naam,$verzekering_nummer,$dbh);
     &zoek_welke_gewijzigd_moeten_worden  ($ziekenfonds,$verzekering_naam,$verzekering_nummer,$dbh);
}
sub zoek_welke_toegevoegd_moeten_worden {
      my $zkf = shift @_;
      my $verzekering_naam = shift @_;
      my $verzekering_nummer = shift @_;
      my $dbh = shift @_;
      my $vandaag = ParseDate("today");
     $vandaag = substr ($vandaag,0,8);  
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
     #ONTSLAGO  VARCHAR(1) J = onderzozk of het om een onstlag gaat contract xml N = niets doen
     #CXMLINIT VARCHAR(1) Y = deze is al opgenomen in contract xml N = moet nog doorgestuurd worden
     #CXMLUPDA VARCHAR(1) Y = er is iets veranderd en deze moet doorgestuurd N = moet niet doorgestuurd worden
     #WANBET VARCHAR(1) Y = het is een wanbetaler kaart geblokkeerd N = geen wanbetaler kaart niet geblokkeerd
     #ONTSLAG VARCHAR(1) Y = ontslagen kaart geblokkeerd N = niet ontslagen
      #openen van PFYSL8
      # EXIDL8 = extern nummer
      # KNRNL8 = nationaalt register nummerVNAAM 
      # NAIJL8 = geboortedag
      # LANGL8 = taal code
      #PRNBL8              PRENOM DU BENEFICIAIRE  /VOORN 
      #NAMBL8              NOM DU BENEFICIAIRE     /NAAM  
      #SEXEL8              CODE SEXE DU BENEFIC.   /KODE
      #NAIYL8              ANNEE DE NAISSANCE  BEN /GEBOO
      #NAIML8              MOIS DE NAISSANCE DU BEN/GEBOO
      #NAIJL8              JOUR DE NAISSANCE DU BEN/GEBOO
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
      
      my $sql =("SELECT a.KNRN52,b.EXIDL8,b.PRNBL8,b.NAMBL8,b.SEXEL8,b.NAIYL8,b.NAIML8,b.NAIJL8,c.ABPTJR,a.EINDAT,a.INZDAT,a.CARDNR,e.ABPEKK
                        FROM $settings{'ascard_fil'} a JOIN $settings{'pers_fil'} b ON a.KNRN52=b.KNRNL8
                        JOIN $settings{'adres_fil'} c ON b.EXIDL8=c.EXIDJR JOIN $settings{'phoekk_fil'} e ON b.EXIDL8=e.EXIDKK 
                        WHERE a.ZKF = $zkf  and a.CXMLINIT = 'N' and a.KNRN52 != 0  and a.CARDNR != 0 and (c.ABGIJR = (SELECT max( d.ABGIJR ) FROM $settings{'adres_fil'} d WHERE d.EXIDJR = b.EXIDL8)) 
                        and (e.ABEDKK >= $vandaag or e.ABEDKK = a.EINDAT) and e.ABTVKK = $verzekering_nummer ORDER BY a.KNRN52");
      my $sth = $dbh->prepare( $sql );
      $sth ->execute();
      my $aantaltijr = 0;
      while(my @cardholders_update =$sth->fetchrow_array)  {
         $add_ingezet +=1;
         $zkf_add_ingezet +=1;
         my $Contract_onderdeel;
          my $element =0;
            foreach (@cardholders_update) {
               $cardholders_update[$element] =~ s/^\s+//;
	       $cardholders_update[$element] =~ s/\s+$//;
               $element +=1; 
               
            }
            my $gender ='';
            if ($cardholders_update[4] == 1) {
                 $gender = 'M'; #code
            }else {
                 $gender = 'F';
            }
          my $startdate ='1000-01-01';
          my $enddate = "5000-01-01";
          my $startdate_nr = $cardholders_update[12];
          my $einddate_nr = $cardholders_update[9];
          if ($startdate_nr > $einddate_nr ) {
             $cardholders_update[9] = $cardholders_update[12];
          }
          
          if ($cardholders_update[12] == 99999999) {
             $startdate = '5000-01-01';
          }else {
              my $y = substr($cardholders_update[12],0,4);
              my $m = substr($cardholders_update[12],4,2);
              my $d = substr($cardholders_update[12],6,2);
              $startdate  = "$y-$m-$d";
          }
           if ($cardholders_update[9] == 99999999) {
              $enddate = '5000-01-01';
          }else {                                                
              my $y = substr($cardholders_update[9],0,4);
              my $m = substr($cardholders_update[9],4,2);
              my $d = substr($cardholders_update[9],6,2);
              $enddate = "$y-$m-$d";
          }
          
          my $geboortedatum = sprintf "%4d-%02d-%02d",$cardholders_update[5],$cardholders_update[6],$cardholders_update[7];
          $Contract_onderdeel = {
              ProfileIdentifier => "$verzekering_naam",
              PolicyHolder => {
              GenderCode => "$gender",
              PostalCode => "$cardholders_update[8]",
              BirthYear => "$cardholders_update[5]",
              BirthDate => "$geboortedatum",
              PatientName => "$cardholders_update[2] $cardholders_update[3]",
            },
              Method =>  {
              FunctionTypeName => "add",
            },
              AssurCardIdentifier => "$cardholders_update[11]",
              StartDate => "$startdate",
              ExpirationDate => "$enddate",
          };
          #print "in contract xml->$aantaltijr -> @cardholders_update\n";
          #push (@{$Concracts{Contract}},$Contract_onderdeel);
          push (@Concracts,$Contract_onderdeel); 
          $aantaltijr +=1   
      }
      #print "einde";
}
sub zoek_welke_gewijzigd_moeten_worden {
      my $zkf = shift @_;
      my $verzekering_naam = shift @_;
      my $verzekering_nummer = shift @_;
      my $dbh = shift @_;
      my $vandaag = ParseDate("today");
     $vandaag = substr ($vandaag,0,8);  
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
     #ONTSLAGO  VARCHAR(1) J = onderzozk of het om een onstlag gaat contract xml N = niets doen
     #CXMLINIT VARCHAR(1) Y = deze is al opgenomen in contract xml N = moet nog doorgestuurd worden
     #CXMLUPDA VARCHAR(1) Y = er is iets veranderd en deze moet doorgestuurd N = moet niet doorgestuurd worden
     #WANBET VARCHAR(1) Y = het is een wanbetaler kaart geblokkeerd N = geen wanbetaler kaart niet geblokkeerd
     #ONTSLAG VARCHAR(1) Y = ontslagen kaart geblokkeerd N = niet ontslagen
      #openen van PFYSL8
      # EXIDL8 = extern nummer
      # KNRNL8 = nationaalt register nummerVNAAM 
      # NAIJL8 = geboortedag
      # LANGL8 = taal code
      #PRNBL8              PRENOM DU BENEFICIAIRE  /VOORN 
      #NAMBL8              NOM DU BENEFICIAIRE     /NAAM  
      #SEXEL8              CODE SEXE DU BENEFIC.   /KODE
      #NAIYL8              ANNEE DE NAISSANCE  BEN /GEBOO
      #NAIML8              MOIS DE NAISSANCE DU BEN/GEBOO
      #NAIJL8              JOUR DE NAISSANCE DU BEN/GEBOO
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
      
      #my $sql =("SELECT a.KNRN52,b.EXIDL8,b.PRNBL8,b.NAMBL8,b.SEXEL8,b.NAIYL8,b.NAIML8,b.NAIJL8,c.ABPTJR,a.EINDAT,a.INZDAT,a.CARDNR,d.ABPEKK 
      #                  FROM $settings{'ascard_fil'} a JOIN $settings{'pers_fil'} b ON a.KNRN52=b.KNRNL8
      #                  JOIN $settings{'adres_fil'} c ON b.EXIDL8=c.EXIDJR  JOIN $settings{'phoekk_fil'} d ON b.EXIDL8=d.EXIDKK 
      #                  WHERE a.ZKF = $zkf and a.CXMLINIT = 'Y' and a.CXMLUPDA = 'Y' and a.KNRN52 != 0 and (c.ABGIJR = (SELECT max( d.ABGIJR ) FROM $settings{'adres_fil'} d  WHERE d.EXIDJR = b.EXIDL8) )
      #                  and b.EXIDL8 IN (SELECT  EXIDKK  FROM  $settings{'phoekk_fil'}  WHERE (ABEDKK >= $vandaag or ABEDKK = a.EINDAT) and ABTVKK = $verzekering_nummer) ORDER BY a.KNRN52");
      my $sql =("SELECT a.KNRN52,b.EXIDL8,b.PRNBL8,b.NAMBL8,b.SEXEL8,b.NAIYL8,b.NAIML8,b.NAIJL8,c.ABPTJR,a.EINDAT,a.INZDAT,a.CARDNR,e.ABPEKK
                        FROM $settings{'ascard_fil'} a JOIN $settings{'pers_fil'} b ON a.KNRN52=b.KNRNL8
                        JOIN $settings{'adres_fil'} c ON b.EXIDL8=c.EXIDJR JOIN $settings{'phoekk_fil'} e ON b.EXIDL8=e.EXIDKK 
                        WHERE a.ZKF = $zkf  and a.CXMLINIT = 'Y' and a.CXMLUPDA = 'Y' and a.KNRN52 != 0 and a.CARDNR != 0 and (c.ABGIJR = (SELECT max( d.ABGIJR ) FROM $settings{'adres_fil'} d WHERE d.EXIDJR = b.EXIDL8)) 
                        and (e.ABEDKK >= $vandaag or e.ABEDKK = a.EINDAT) and e.ABTVKK = $verzekering_nummer ORDER BY a.KNRN52");
      my $sth = $dbh->prepare( $sql );
      $sth ->execute();
      my $aantaltijr = 0;
      while(my @cardholders_update =$sth->fetchrow_array)  {
          my $Contract_onderdeel;
          my $element =0;
          $updates_ingezet +=1;
          $zkf_updates_ingezet +=1;
            foreach (@cardholders_update) {
               $cardholders_update[$element] =~ s/^\s+//;
	       $cardholders_update[$element] =~ s/\s+$//;
               $element +=1; 
               
            }
            my $gender ='';
            if ($cardholders_update[4] == 1) {
                 $gender = 'M'; #code
            }else {
                 $gender = 'F';
            }
          my $startdate ='1000-01-01';
          my $enddate = "5000-01-01";
          my $startdate_nr = $cardholders_update[12];
          my $einddate_nr = $cardholders_update[9];
          if ($startdate_nr > $einddate_nr ) {
             $cardholders_update[9] = $cardholders_update[12];
          }
          if ($cardholders_update[12] == 99999999) {
             $startdate = '5000-01-01';
          }else {
              my $y = substr($cardholders_update[12],0,4);
              my $m = substr($cardholders_update[12],4,2);
              my $d = substr($cardholders_update[12],6,2);
              $startdate  = "$y-$m-$d";
          }
           if ($cardholders_update[9] == 99999999) {
              $enddate = '5000-01-01';
          }else {
              my $y = substr($cardholders_update[9],0,4);
              my $m = substr($cardholders_update[9],4,2);
              my $d = substr($cardholders_update[9],6,2);
              $enddate = "$y-$m-$d";
          }
          
          my $geboortedatum = sprintf "%4d-%02d-%02d",$cardholders_update[5],$cardholders_update[6],$cardholders_update[7];
          $Contract_onderdeel = {
              ProfileIdentifier => "$verzekering_naam",
              PolicyHolder => {
              GenderCode => "$gender",
              PostalCode => "$cardholders_update[8]",
              BirthYear => "$cardholders_update[5]",
              BirthDate => "$geboortedatum",
              PatientName => "$cardholders_update[2] $cardholders_update[3]",
            },
              Method =>  {
              FunctionTypeName => "update",
            },
              AssurCardIdentifier => "$cardholders_update[11]",
              StartDate => "$startdate",
              ExpirationDate => "$enddate",
          };
          #print "update contract xml->$aantaltijr -> @cardholders_update\n";
          #push (@{$Concracts{Contract}},$Contract_onderdeel);
          push (@Concracts,$Contract_onderdeel); 
          $aantaltijr +=1   
      }
      #print "einde";
}

sub schrijf_contracts_xml_file {
     my $xml_file = shift @_;
     my $dbh = shift @_;
     my $xsd = $contract_cardinstellingen->{plaats_contract_xsd};
     my $schema = XML::Compile::Schema->new($xsd);
     $schema->printIndex();
     warn $schema->template('PERL', 'Contracts');
     my $doc    = XML::LibXML::Document->new('1.0', 'UTF-8');
     my $write  = $schema->compile(WRITER => 'Contracts');
     my $xml    = $write->($doc,$data_contract_xml);
     $doc->setDocumentElement($xml);
     open XMLFILE,"> $xml_file" or die "can not open file $xml_file ";
     select XMLFILE;
     print $doc->toString(1); # 1 indicates "pretty print"
     close XMLFILE;
     select STDOUT;
     &zet_update_in_database ($xml_file,$dbh);
}
sub zet_update_in_database {
      my $file_name = shift @_;
      my $dbh = shift @_;
      my $updates_in_xml = XMLin("$file_name");
      print "file ingelezen\n";
#     $mail_contract = $mail_contract."settings ingelezen";
#     #maak verzekeringen
     foreach my $volgnr (keys @{$updates_in_xml->{Contract}}) {
         my $card_nr = $updates_in_xml->{Contract}[$volgnr]->{AssurCardIdentifier};
         my $rijkreg_nummer = substr($card_nr,1,11);
         my($CXMLINIT,$CXMLUPDA,$KNRN52)= $dbh->selectrow_array("SELECT CXMLINIT,CXMLUPDA,KNRN52 FROM $settings{'ascard_fil'} where CARDNR = $card_nr");
         print "$card_nr $CXMLINIT,$CXMLUPDA,$KNRN52 =>";
         if ($CXMLINIT eq 'N' and $CXMLUPDA eq 'Y' ) {
             #print "zet init op y \n";#code
             my $updatethis = $dbh ->do("UPDATE $settings{'ascard_fil'} set CXMLINIT = 'Y' WHERE CARDNR = $card_nr");
         }elsif ($CXMLINIT eq 'N' and $CXMLUPDA eq 'N' ) {
             #print "zet init op y\n";#code
             my $updatethis = $dbh ->do("UPDATE $settings{'ascard_fil'} set CXMLINIT = 'Y' WHERE CARDNR = $card_nr");
         }elsif ($CXMLINIT eq 'Y' and $CXMLUPDA eq 'Y' ) {
              #print "zet update op nee\n";#code
             my $updatethis = $dbh ->do("UPDATE $settings{'ascard_fil'} set CXMLUPDA = 'N' WHERE CARDNR = $card_nr");
         }elsif ($CXMLINIT eq 'Y' and $CXMLUPDA eq 'N' ) {
             print "\n\nDEZE met Rijkregiternummer $rijkreg_nummer ZOU NIET MOGEN IN DEZE XML STAAN : CARDNR = $card_nr\n\n";
             $mail_contract = $mail_contract."\nDEZE met Rijkregiternummer $rijkreg_nummer ZOU NIET MOGEN IN DEZE XML STAAN : CARDNR = $card_nr\nCXMLINIT =$CXMLINIT CXMLUPDA= $CXMLUPDA\n";
         }
     }
     print "\nASCARD aangepast\nxml file => $file_name \nKijk na of deze file werd afgeleverd aan assurcard!\nKijk de fouten na!\n Volgende file bevat de updates en de nieuwe klanten";
     $mail_contract = $mail_contract."\nASCARD aangepast\nxml file => $file_name \nKijk na of deze file werd afgeleverd aan assurcard!\nKijk de fouten na!\n Volgende file bevat de updates en de nieuwe klanten";
    }
sub copy_file_to_assurcard_upload {
     my $file = shift @_;
     my $smbuser = 'assurcard';
     my $smbpasswd = 'Hospiplus';
     my $cifs= $contract_cardinstellingen->{plaats_assurcard_upload};
     my $cifs_readable =$cifs;
     $cifs_readable =~ s/\\/\\\\/g;
     Connect $cifs,{user=>$smbuser,passwd=>$smbpasswd} ;
     if (-e "$cifs\\test.txt") {
         my $test_copy=0;
         copy ("$file"  => $cifs) or $test_copy=&error_mail_copy ("$file" ,$cifs);
         if ($test_copy==0) {
             $mail_contract=$mail_contract."file $file gekopieerd naar $cifs_readable\n" ;
             print "file $file gekopieerd naar $cifs_readable\n" ;
            }else {
             $mail_contract=$mail_contract."ERROR !! =>file $file kon niet gekopieerd worden naar $cifs_readable\n" ;
             print "ERROR !! =>file $file kon niet gekopieerd worden naar $cifs_readable\n" ;
            }
        }else {
         print "map niet gemaakt";
         my $cifs_leesbaar = $cifs;
         $cifs_leesbaar =~ s/\\/\\\\/g;
         $mail_contract = $mail_contract."\nKAN NETWERK MAP NIET MAKEN $cifs_leesbaar !!!!!\n--------------------------------------------\n";
         print "\nKAN NETWERK MAP NIET MAKEN $cifs_leesbaar !!!!!\n--------------------------------------------\n";
         $mail_contract = $mail_contract."of bestand test.txt staat niet op $cifs_leesbaar \n maak het aan\n";
         print "of bestand test.txt staat niet op $cifs_leesbaar \n maak het aan\n";
        }
    }
sub error_mail_copy_invoices {
     my $lijstfile = shift @_;
     my $copy_plaats = shift @_;
     #$mail_contract = $mail_contract."kon file $lijstfile niet kopieren naar $copy_plaats\n";
     return (1);
    }


1; 