#!/usr/bin/perl -w
#in GIT gezet
#OPGELET!!!!!!
#Dit programma is auteursrechtelijk beschermd.
#Deze code is voor 100% eigendom van de Firma  I.C.E. (liebroekstraat 43 3545 Halen BE0446888007) .
#Deze code mag niet aan derden (ook niet VNZ en NZVL) getoond worden tenzij met uitdrukkelijke en schriftelijke toestemming van Hospiplus en I.C.E. bvba .
#Indien dit toch gebeurt is er een boete verschuldigd van 250.000 € exclusief btw aan de Firma  I.C.E.
#Dit geldt ook voor het kopieren van een stuk code of het repliceren van technieken gehanteerd in dit programma
#I.C.E. beheert de broncode je mag  veranderingen aanbrengen aan het programma . Deze worden samen met de documentatie overgedragen aan I.C.E. .
#I.C.E. beslist dan op deze veranderingen worden doorgevoerd.
#Door het openen van deze broncode stem je in met de voorgaande voorwaarden.
#De gerechtigden om deze broncode te bekijken zijn Christian Bruyninckx , Michel Gielens en Ben Van Massenhoven.
#Harry Conings beheert voor I.C.E de broncode
#code weigering is 06 in PTRAXKQ
  #Field      Type       Length  Length  Position        Usage    Heading                            
  #ABPYKQ     PACKED       2  0       2       139        Both     MODE PERCEP.                       
  #                                                               WIJZE VORDERING                    
  #  Field text  . . . . . . . . . . . . . . . :  MODE DE PERCEPTION      /WIJZE VAN VORDERING       
                                           
                                                                                                    
use strict;
use XML::Simple;
use Time::Piece;
use Time::Seconds;
require 'Decryp_Encrypt.pl';
require "cnnectdb_prod.pl";
package main;
my $eind_datum;
my $zes_maanden_geleden;
if ($ARGV[0] > 20180000) {
    $eind_datum =$ARGV[0];
    $zes_maanden_geleden= main->zes_maanden_terug($eind_datum);
}else {
     my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime time;
    #print "$sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst\n";
    $eind_datum = ($year+1900)*10000+(($mon+1)*100)+$mday ;
    $zes_maanden_geleden= main->zes_maanden_terug($eind_datum);
}
my $instellingen = XMLin('P:\OGV\ASSURCARD_PROG\assurcard_settings_xml\Poject_AS400_settings.xml');
#decript password
$instellingen = main->decrypt_paswoord($instellingen);
our $mail_as400 ='';
my $verzekeringen = main->zoek_verzekeringen($instellingen);
my $klanten = AS400->zoek_verzekerden($instellingen,$verzekeringen,$eind_datum,$zes_maanden_geleden);
my $gedaan = maakExcel->rapport2($klanten,$instellingen,$eind_datum);
print '';
1;
    sub decrypt_paswoord {
        my ($self,$agresso_instellingen) = @_;
        foreach my $zkf (keys $agresso_instellingen->{ziekenfondsen}){
            $agresso_instellingen->{ziekenfondsen}->{$zkf}->{as400}->{password} =decrypt->new( $agresso_instellingen->{ziekenfondsen}->{$zkf}->{as400}->{password});            
        }
       return($agresso_instellingen);     
    }
    sub zoek_verzekeringen {
        my ($self,$agresso_instellingen)= @_;
        my $verzekeringen;
         foreach my $zkf (keys $agresso_instellingen->{verzekeringen}){
            
             @{$verzekeringen->{$zkf}}=();
             my $ziekenfondsnr = $& if ($zkf =~ m/\d{3}/);
             $mail_as400 = $mail_as400."$zkf -> volgende verzekeringen:\n";
             $mail_as400= $mail_as400."--------------------------------\n";
             foreach my $verzekerings_naam (keys $agresso_instellingen->{verzekeringen}->{$zkf}){
                 my $verzekerings_nummer = $agresso_instellingen->{verzekeringen}->{$zkf}->{$verzekerings_naam};
                 eval {$verzekerings_nummer = $agresso_instellingen->{verzekeringen}->{$zkf}->{$verzekerings_naam}->{$verzekerings_naam}};
            
                 push (@{$verzekeringen->{$zkf}},$verzekerings_nummer);
                 $mail_as400 = $mail_as400."$verzekerings_naam ->$verzekerings_nummer \n";
                }
             #print "";
             $mail_as400 = $mail_as400."\n";
             #zoek de mensen met deze verzekering
            
            }
         return ($verzekeringen);
        }
    sub zoek_naam_verzekering {
         my ($self,$verz_nr,$produktnummer,$ziekenfonds,$agresso_instellingen) = @_;
         if ($produktnummer == 1) {
             foreach my $naam_verzekering (keys $agresso_instellingen->{verzekeringen}->{$ziekenfonds}) {
                 if ($agresso_instellingen->{verzekeringen}->{$ziekenfonds}->{$naam_verzekering} == $verz_nr) {
                     my $voorlopige_naam = uc $naam_verzekering;
                     return ($voorlopige_naam);
                    }
                }
            }else {
             foreach my $naam_verzekering (keys $agresso_instellingen->{verzekeringen}->{$ziekenfonds}) {                     
                 if (eval {$agresso_instellingen->{verzekeringen}->{$ziekenfonds}->{$naam_verzekering}->{$naam_verzekering} == $verz_nr}) {
                      foreach my $naam_product (keys $agresso_instellingen->{verzekeringen}->{$ziekenfonds}->{$naam_verzekering}) {
                         if ($agresso_instellingen->{verzekeringen}->{$ziekenfonds}->{$naam_verzekering}->{$naam_product} == $produktnummer) {
                             my $voorlopige_naam = uc $naam_product;
                             return ($voorlopige_naam);
                            }
                        }
                    }
                }
            }
         
        }
    sub ouderdom {
	 my ($self,$geboorte_datum) = @_;
	 my $geboorte = Time::Piece->strptime($geboorte_datum, "%Y-%m-%d");
	 my $nu = localtime;
	 my $diff = $nu-$geboorte;
	 my $ouderdom = int($diff->years);
	 return ($ouderdom);
        }
     sub zes_maanden_terug {
        my ($self,$datum) = @_;
        my $jaar= substr($datum,0,4);
        my $maand = substr($datum,4,2);
        my $dag = substr($datum,6,2);
        my $today1 ="$dag\.$maand\.$jaar";
        my $t = Time::Piece->strptime($today1, "%d.%m.%Y");
         $t -= ONE_MONTH;
         $t -= ONE_MONTH;
         $t -= ONE_MONTH;
         $t -= ONE_MONTH;
         $t -= ONE_MONTH;
         $t -= ONE_MONTH;
         print $t->strftime("%Y%m%d");
         my $zes_maanden_terug = sprintf  $t->strftime("%Y%m%d");
         return ($zes_maanden_terug);
         print '';
     }
package AS400;
    use Unicode::String qw(utf8 latin1 utf16le);
      sub zoektitularis {
            my ($self,$klant,$dbh,$settings) = @_;
            my $pben_fil ="$settings->{libcxfil}.PBEN17";
                if ($klant->{volgnummer} == 0) {
                        $klant->{ext_titularis} = $klant->{ext_nummer};
                        return ($klant);
                    }else {
                my $stamnummer= $klant->{stamnummer};
                #print "SELECT IDNS17,EXID17,IDNO17 $pben_fil FROM  WHERE DAFC17 = '' and IDNO17 = $stamnummer and IDNS17 = 0\n";
                        my @pben1_uit = $dbh->selectrow_array("SELECT IDNS17,EXID17,IDNO17 FROM $pben_fil  WHERE DAFC17 = '' and IDNO17 = $stamnummer and IDNS17 = 0");
                        $klant->{ext_titularis}=$pben1_uit[1];                 
                    }
                return ($klant);
            }
    sub zoek_verzekerden {
     my ($self,$instellingen,$verzekeringen,$eind_datum,$zes_maanden_geleden) = @_;
     my $klant;
     
     #my $jaar = substr ($vandaag,0,4);
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
     #AGRESONR is nummer voor agresso begint bij 100000
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
    #A.NAMBL8              NOM DU BENEFICIAIRE     /NAAM  
    #A.PRNBL8              PRENOM DU BENEFICIAIRE  /VOORN      
    #A.NAIYL8              ANNEE DE NAISSANCE  BEN /GEBOO      
    #A.NAIML8              MOIS DE NAISSANCE DU BEN/GEBOO      
    #A.NAIJL8              JOUR DE NAISSANCE DU BEN/GEBOO      
    #A.SEXEL8              CODE SEXE DU BENEFIC.   /KODE       
    #A.W010L8              NOM/PRENOM ALPHABETIQUE /NAAM/
       my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);
            my $jaar_getal = $year+1900;
            my $vandaag = $jaar_getal*10000+$mon*100+$mday;
      my $totaal_aantal_lijnen=0;
      foreach my $zkf (keys $instellingen->{ziekenfondsen}) {
                         my $zkf_nr  = substr ($zkf,3,3);
                         my $link = $instellingen->{ziekenfondsen}->{$zkf}->{as400};                      
                         my $dbh = AS400->cnnectdb($link->{username},$link->{password},$link->{as400_name});
                         my $placeholders = join ",", (@{$verzekeringen->{$zkf}});
                         my $ASCARD="$link->{libcxcom}\.ASCARD";
                         my $PFYSL8= "$link->{libcxfil}\.PFYSL8";
                         my $PHOEKK= "$link->{libcxfil}\.PHOEKK";
                         my $PADRJR = "$link->{libcxfil}\.PADRJR";
                         my $PTAXKQ = "$link->{libcxfil}\.PTAXKQ";
                         my $sql =("SELECT CONCAT (b.ABTVKK,CONCAT(b.ABPRKK,b.ABNOKK))
                                        FROM $PFYSL8 c                                      
                                        JOIN $PHOEKK  b ON c.EXIDL8=b.EXIDKK
                                        WHERE c.KNRNL8 !=0 and b.ABTVKK IN ($placeholders)
                                        and b.ABEDKK > $vandaag
                                        GROUP BY CONCAT (b.ABTVKK,CONCAT(b.ABPRKK,b.ABNOKK))
                                        HAVING COUNT (CONCAT (b.ABTVKK,CONCAT(b.ABPRKK,b.ABNOKK))) > 4" );
                         my $sth = $dbh->prepare( $sql );
                         $sth ->execute();
                         my $konijnen = "";
                         my $teller = 0;
                         while(my @agresso_klant =$sth->fetchrow_array)  {
                            $teller++;
                            $konijnen = $konijnen.",".$agresso_klant[0];
                            print "\n$teller @agresso_klant";
                         }
                         $konijnen =~ s/^,//;
                         my $sql1  =("SELECT c.KNRNL8,c.EXIDL8,
                                        b.ABTVKK,b.ABPRKK,b.ABADKK,b.ABPEKK,b.ABEDKK,b.ABNOKK,b.ABACKK,b.AB2AKK,b.ABOCKK,b.AB2OKK,
                                        c.NAMBL8,c.PRNBL8,c.NAIYL8,NAIML8,NAIJL8,SEXEL8,b.ABNOKK  
                                        FROM $PFYSL8 c                                      
                                        JOIN $PHOEKK  b ON c.EXIDL8=b.EXIDKK
                                        WHERE CONCAT (b.ABTVKK,CONCAT(b.ABPRKK,b.ABNOKK)) IN ($sql) and b.ABEDKK > $vandaag  order by b.ABNOKK,NAIYL8,NAIML8,NAIJL8,PRNBL8 " );#fetch first 10 rows only enddatum ? and b.ABEDKK > $eind_datum and  b.ABADKK <= $zes_maanden_geleden
                         my $sth1 = $dbh->prepare( $sql1 );
                         $sth1 ->execute();
                         my  $record_teller =0;
                       
                         my @agresso_klant =();
                         my $line_no = 0;
                         my $last_agr_nr=0;
                         my $dossier_nummer = 0;
                         my $dossier_onthoud= 0;
                         my $kind_teller;
                         while(@agresso_klant =$sth1->fetchrow_array)  { 
                                for (my $i=0; $i <= 18; $i++) {
                                    my $item = utf8($agresso_klant[$i]);
                                    $agresso_klant[$i] = $item->latin1;
                                }
                                 $dossier_nummer = $agresso_klant[7];
                                if ($dossier_nummer == $dossier_onthoud or  $dossier_onthoud == 0 ) {
                                    $dossier_onthoud =$dossier_nummer;
                                    my $kind = AS400->checkkind($dbh,$agresso_klant[1],$zkf_nr);
                                    if ($kind eq 'kind') {
                                       $kind_teller->{$agresso_klant[2]} +=1;
                                       if ($agresso_klant[1]==810013395459) {
                                           print '';
                                       }
                                       my ($jaarb,$maandb,$bedragb,$saldob,$totb,$hebben_nooit_betaald,$totaal_over_alles,$weigering,$dossier)= AS400->checkbetaling($dbh,$PTAXKQ,$zkf_nr,$agresso_klant[2],$agresso_klant[1]);
                                       if ( $kind_teller->{$agresso_klant[2]} < 4) {
                                            print "!!!!!! konijnen  $kind_teller->{$agresso_klant[2]}\de kind -> @agresso_klant\n";
                                              if ( $bedragb == 0 or $totb == 0) {
                                                    print "!!!!!! profiteurs -> @agresso_klant\n";
                                                    my $verz_naam= main->zoek_naam_verzekering($agresso_klant[2],$agresso_klant[3],$zkf,$instellingen);
                                                    print "$agresso_klant[0] $weigering saldo $saldob  bedrag betaald $bedragb $totb verz_naam $verz_naam\n";
                                                    my ($D_Address,$D_ZipCode,$D_Place,$D_CountryCode,$P_Address,$P_ZipCode,$P_Place,$P_CountryCode) = AS400->checkadres($dbh,$PADRJR,$agresso_klant[1],$zkf_nr);
                                                    #$klant->{$agresso_klant[0]}->{$zkf_nr}->{$naam}
                                                    $klant->{$agresso_klant[0]}->{$zkf_nr}->{klantinfo}->{naam} = $agresso_klant[12];
                                                    $klant->{$agresso_klant[0]}->{$zkf_nr}->{klantinfo}->{voor_naam} = $agresso_klant[13];
                                                    $klant->{$agresso_klant[0]}->{$zkf_nr}->{klantinfo}->{geboortedatum} ="$agresso_klant[16]/$agresso_klant[15]/$agresso_klant[14]";
                                                    $klant->{$agresso_klant[0]}->{$zkf_nr}->{klantinfo}->{ouderdom} =main->ouderdom("$agresso_klant[14]-$agresso_klant[15]-$agresso_klant[16]");
                                                    $klant->{$agresso_klant[0]}->{$zkf_nr}->{klantinfo}->{geslacht} = '';
                                                    $klant->{$agresso_klant[0]}->{$zkf_nr}->{klantinfo}->{geslacht} = 'M' if $agresso_klant[17] == 01;
                                                    $klant->{$agresso_klant[0]}->{$zkf_nr}->{klantinfo}->{geslacht} = 'V' if $agresso_klant[17] == 02;
                                                    $klant->{$agresso_klant[0]}->{$zkf_nr}->{klantinfo}->{D_Address}= $D_Address;
                                                    $klant->{$agresso_klant[0]}->{$zkf_nr}->{klantinfo}->{D_ZipCode}= $D_ZipCode;
                                                    $klant->{$agresso_klant[0]}->{$zkf_nr}->{klantinfo}->{D_Place}= $D_Place;
                                                    $klant->{$agresso_klant[0]}->{$zkf_nr}->{klantinfo}->{D_CountryCode}= $D_CountryCode;
                                                    $klant->{$agresso_klant[0]}->{$zkf_nr}->{klantinfo}->{P_Address}= $P_Address;
                                                    $klant->{$agresso_klant[0]}->{$zkf_nr}->{klantinfo}->{P_ZipCode}= $P_ZipCode;
                                                    $klant->{$agresso_klant[0]}->{$zkf_nr}->{klantinfo}->{P_Place}= $P_Place;
                                                    $klant->{$agresso_klant[0]}->{$zkf_nr}->{klantinfo}->{P_CountryCode}= $P_CountryCode;
                                                    $klant->{$agresso_klant[0]}->{$zkf_nr}->{$verz_naam}->{startdatum} =$agresso_klant[4];
                                                    $klant->{$agresso_klant[0]}->{$zkf_nr}->{$verz_naam}->{verzekeringsnr} =$agresso_klant[2];
                                                    $klant->{$agresso_klant[0]}->{$zkf_nr}->{$verz_naam}->{dossier_nr}  =$dossier;
                                                    $klant->{$agresso_klant[0]}->{$zkf_nr}->{$verz_naam}->{Verz_nr} = "$agresso_klant[2] P $agresso_klant[3]";                                       
                                                    $klant->{$agresso_klant[0]}->{$zkf_nr}->{$verz_naam}->{openstaand_saldo} = $totaal_over_alles;
                                                    
                                                    #$link->{start_jaar}= substr($agresso_klant[4],0,4);
                                                    #$link->{start_maand}=substr($agresso_klant[4],4,2);
                                                    #$link->{start_dag}=substr($agresso_klant[4],6,2);
                                                    #my $agresso_start_datum = "$link->{start_jaar}-$link->{start_maand}-$link->{start_dag}";
                                                    #$link->{start-datum} =$agresso_start_datum;
                                                    $klant->{$agresso_klant[0]}->{$zkf_nr}->{$verz_naam}->{wachtdatum} = $agresso_klant[5];
                                                    #$link->{wacht_jaar} = substr($agresso_klant[5],0,4);
                                                    #$link->{wacht_maand} = substr($agresso_klant[5],4,2);
                                                    #$link->{wacht_dag} = substr($agresso_klant[5],6,2);
                                                    #my $agresso_wacht_datum = "$wacht_dag-$wacht_maand-$wacht_jaar";
                                                    #$link->{einddatum} = $agresso_klant[6];                              
                                                    #$link->{eind_jaar}= substr($agresso_klant[6],0,4);
                                                    #$link->{eind_maand}= substr($agresso_klant[6],4,2);
                                                    #$link->{eind_dag}= substr($agresso_klant[6],6,2);
                                                    #my $agresso_eind_datum = "$eind_dag-$eind_maand-$eind_jaar";
                                                    $klant->{$agresso_klant[0]}->{$zkf_nr}->{$verz_naam}->{aansluitingscode}= "$agresso_klant[8]$agresso_klant[9]";
                                                    $klant->{$agresso_klant[0]}->{$zkf_nr}->{$verz_naam}->{ontslagcode}= "$agresso_klant[10]$agresso_klant[11]";
                                                    $klant->{$agresso_klant[0]}->{$zkf_nr}->{$verz_naam}->{einddatum}=$agresso_klant[6];
                                                    $klant->{$agresso_klant[0]}->{$zkf_nr}->{$verz_naam}->{datestring} = gmtime();
                                                    #print "time $klant->{$agresso_klant[0]}->{$zkf_nr}->{$naam}->{datestring}\n";
                                                    $line_no +=1;
                                                    $totaal_aantal_lijnen +=1;
                                                    my $zkf_line_no=$zkf_nr*100+ $line_no;
                                            }
                                       }
                                    }
                                }else {
                                    $dossier_onthoud =$dossier_nummer;
                                    foreach my $verz (keys $kind_teller) {
                                        $kind_teller->{$verz} =0;
                                    }
                                   
                                }
                                #$klant->{$agresso_klant[0]}->{rijksreg_nr} = $agresso_klant[0];
                                my ($jaarb,$maandb,$bedragb,$saldob,$totb,$hebben_nooit_betaald,$totaal_over_alles,$weigering,$dossier)= AS400->checkbetaling($dbh,$PTAXKQ,$zkf_nr,$agresso_klant[2],$agresso_klant[1]);
                                #print "$weigering saldo $saldob  bedrag betaald $bedragb $totb\n" ;#if ($weigering eq 'Weigering');
                              
                               
                               #$line_no = $dbh_agresso->selectrow_array("SELECT COUNT(*) from afxvmobcontract where dim_value= '$agresso_klant[0]'");
                            }
                         AS400->dscnnectdb($dbh);
                        }
                    
     return ($klant);                
    }
    sub checkkind {
         my ($self,$dbh,$extern_nummer,$zkf_nummer) = @_;
            my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);
            my $jaar_getal = $year+1900;
            my $vandaag = $jaar_getal*10000+$mon*100+$mday;
            my $as400_file = $instellingen->{ziekenfondsen}->{"ZKF$zkf_nummer"}->{as400}->{libcxfil};
            $as400_file =  $as400_file."\.PAOP25";
            my $kind = "geen kind";
            #A.CTPC25              CATEGORIE DE LA PAC     /KATEG       
            #A.STPC25              STATUT DE LA PAC        /STATU       
            #A.QLFJ25              JOUR FIN   QUALITE BEN  /EINDD       
            #A.QLFM25              MOIS FIN   QUALITE BEN  /EINDM       
            #A.QLFY25              ANNEE FIN   QUALITE BEN /EINDJ       
            #A.EXID25              NUMERO EXTERNE          /EXTER       
            #A.IDFD25              NUMERO MUTUELLE         /NUMME       
            #A.IDMT25              NUMERO MUTUELLE DU BEN  /NUMME
            my (@code_ptl) =$dbh->selectrow_array("SELECT CTPC25,STPC25 FROM $as400_file WHERE EXID25= $extern_nummer and IDFD25 = $zkf_nummer and (QLFY25*10000+QLFM25*100+QLFJ25) > $vandaag");
            if ($code_ptl[0] == 3 and $code_ptl[1] == 0) {
               $kind = 'kind'; 
            }
        return ($kind);
    }
    sub checkadres {
             my ($self,$dbh,$as400_file,$extern_nummer,$zkf_nummer) = @_;  
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
             # IDFDJR = NUMMER ZIEKENFOND
             # ER ZIJN DUBBEL ENTRIES VOOR POSTADRES EN GEWOON ADRES WE KIJKEN OF ER EEN POSTADRES IS
             # het postadres heeft ABGIJR == 02 dit gaan we zoeken
             # KGERJR = srtaat kode
             #ABTPJR  = INTERNAT.PREFIX TELNR
             # ABTEJR  = TELEFOONNUMMER
             # PGSMJR  = INT. PREFIX GSM-NR
             # NGSMJR = GSM-NUMMER
             my $sql =("SELECT EXIDJR,ABGIJR,ABKTJR,ABSTJR,ABNTJR,ABBTJR,IV00JR,ABPTJR,ABWTJR,ABTPJR,ABTEJR,PGSMJR,NGSMJR FROM $as400_file WHERE EXIDJR= $extern_nummer and IDFDJR = $zkf_nummer");
             my $sth = $dbh->prepare( $sql );
             $sth->execute();
             #my( $exidjr, $abgijr, $abktjr, $abstjr, $abntjr, $abbtjr, $ivoojr, $abptjr, $abwtjr );
             #$sth->bind_columns( undef, \$exidjr, \$abgijr, \$abktjr, \$abstjr, \$abntjr, \$abbtjr, \$ivoojr, \$abptjr, \$abwtjr );
             my $aantalrij=0;
             my @adresrij;
             my @domi_adres;
             while(my @mijnrij=$sth->fetchrow_array)  {
                 #print "$aantalrij    @mijnrij\n";
                 @adresrij=@mijnrij if ($aantalrij == 0 );
                 @domi_adres=@mijnrij if ($aantalrij == 0 );
                 @adresrij=@mijnrij if ($aantalrij >= 0) ; #and ($mijnrij[1] == 02);  #postadres
                 @domi_adres=@mijnrij if ($aantalrij >= 0) and ($mijnrij[1] == 01);  #domicili adres
                 $aantalrij +=1;
                }
             #print "post -- @adresrij \n";
             #print "domi -- @adresrijdomi \n";
             $sth->finish();
             
        foreach my $element (@domi_adres) { #verwijder de leading en trailing spaces
                    $element =~ s/^\s+//;
                    $element =~ s/\s+$//;
                   }
         foreach my $element (@adresrij) { #verwijder de leading en trailing spaces
                    $element =~ s/^\s+//;
                    $element =~ s/\s+$//;
                   }
         my $Address ='';
            $Address = "$domi_adres[3] $domi_adres[4]" if ($domi_adres[5] eq '') ;
            $Address = "$domi_adres[3] $domi_adres[4] B $domi_adres[5]" if ($domi_adres[5] ne '') ;
         my $CountryCode =  $domi_adres[6];
            my $ZipCode = $domi_adres[7];
            my $Place = $domi_adres[8];
            my $Telephone1 ="$domi_adres[9]$domi_adres[10]";
            my $Telephone2 ="$domi_adres[11]$domi_adres[12]";
            my $P_Address ='';
            $P_Address = "$domi_adres[3] $domi_adres[4] " if ($domi_adres[5] eq '') ;
            $P_Address = "$domi_adres[3] $domi_adres[4] B $domi_adres[5]" if ($domi_adres[5] ne '') ;
         my $P_CountryCode =  $domi_adres[6];
            my $P_ZipCode = $domi_adres[7];
            my $P_Place = $domi_adres[8];
            my $P_Telephone1 ="$domi_adres[9]$domi_adres[10]";
            my $P_Telephone2 ="$domi_adres[11]$domi_adres[12]";
            return ($Address,$ZipCode,$Place,$CountryCode,$P_Address,$P_ZipCode,$P_Place,$P_CountryCode);
        
        }
       #sub checkadres {
       #    my ($self,$dbh,$as400_file,$extern_nummer,$zkf_nummer) = @_;          
       #     #openen van PADRJR op as400
       #     # EXIDJR = extern nummer
       #     # ABGIJR = soort adres post of gewoon post =02
       #     # ABKTJR = naam van de bewoner van het postadress
       #     # ABSTJR = naam van de straat
       #     # ABNTJR = huisnnummer
       #     # ABBTJR = busnummer
       #     # IV00JR = kode van het land
       #     # ABPTJR = postnummer
       #     # ABWTJR = woornplaats
       #     # IDFDJR = NUMMER ZIEKENFOND
       #     # ER ZIJN DUBBEL ENTRIES VOOR POSTADRES EN GEWOON ADRES WE KIJKEN OF ER EEN POSTADRES IS
       #     # het postadres heeft ABGIJR == 02 dit gaan we zoeken
       #     # KGERJR = srtaat kode
       #     # ABTPJR  = INTERNAT.PREFIX TELNR
       #     # ABTEJR  = TELEFOONNUMMER
       #     # PGSMJR  = INT. PREFIX GSM-NR
       #     # NGSMJR = GSM-NUMMER
       #     my @domi_adres =$dbh->selectrow_array("SELECT EXIDJR,ABGIJR,ABKTJR,ABSTJR,ABNTJR,ABBTJR,IV00JR,ABPTJR,ABWTJR,ABTPJR,ABTEJR,PGSMJR,NGSMJR
       #                                           FROM $as400_file WHERE EXIDJR= $extern_nummer and IDFDJR = $zkf_nummer "); #and ABGIJR = '01'
       #     foreach my $element (@domi_adres) { #verwijder de leading en trailing spaces
       #             $element =~ s/^\s+//;
       #             $element =~ s/\s+$//;
       #            }
       #     my $Address ='';
       #     $Address = "$domi_adres[3] $domi_adres[4] " if ($domi_adres[5] eq '') ;
       #     $Address = "$domi_adres[3] $domi_adres[4] B $domi_adres[5]" if ($domi_adres[5] ne '') ;
       #     my $CountryCode =  $domi_adres[6];
       #     my $ZipCode = $domi_adres[7];
       #     my $Place = $domi_adres[8];
       #     my $Telephone1 ="$domi_adres[9]$domi_adres[10]";
       #     my $Telephone2 ="$domi_adres[11]$domi_adres[12]";
       #     return ($Address,$ZipCode,$Place,$CountryCode,$Telephone1,$Telephone2);
       # }
    sub cnnectdb {
        my ($self,$user_name,$password,$as400) =@_;
        	     #username as400
                 #paswoord
                 #naam as400
        my $DSN="driver={iSeries Access ODBC Driver};System=$as400";
        # connect to database
        #
        my $dbh = DBI->connect("dbi:ODBC:$DSN",$user_name,$password) or die "Couldn't connect to database: " . BDI->errstr;
        #
        #  dbh->disconnect;
        return ($dbh)
    }

    sub dscnnectdb {
        my ($self,$dbh) = @_;
        $dbh->disconnect;
    }
    sub checkbetaling {
     my ($self,$dbh,$betaling_fil,$nr_zkf,$type_verz,$externnummer) = @_ ;
     my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);
            my $jaar_getal = $year+1900;
            my $vorig_jaar = $jaar_getal-1,
     #print "chkbet:$nr_zkf,$type_verz,$externnummer, $betaling_fil,$dbh \n";
     #openen van  PTAXKQ in LIBCXFIL03 
     #IDFDKQ            NUMERO MUTUELLE         /NUMMER ZIEKENFOND 
     #EXIDKQ            NUMERO EXTERNE          /EXTERN NUMMER     
     #ABTVKQ            TYPE ASSURABILITE       /TYPE VERZEKERING  
     #ABVYKQ            DATE DEBUT ANNEE        /DATUM VANAF JAAR  
     #ABVMKQ            DATE DEBUT MOIS         /DATUM VANAF MAAND 
     #ABVJKQ            DATE DEBUT JOUR         /DATUM VANAF DAG   
     #ABTYKQ            DATE FIN ANNEE          /DATUM TOT JAAR    
     #ABTMKQ            DATE FIN MOIS           /DATUM TOT MAAND   
     #ABTJKQ            DATE FIN JOUR           /DATUM TOT DAG
     #ABBAKQ            BAREMA CODE             /CODE BAREMA    
     #ABCNKQ            MONTANT TAXATION        /BEDRAG TAXATIE    
     #ABCOKQ            SOLDE   TAXATION        /SALDO  TAXATIE
     #AT79KQ            REPORTING MT TAXATION   /REPORTING BDRG TA
     #code weigering is 06 in PTRAXKQ ABPYKQ MODE DE PERCEPTION      /WIJZE VAN VORDERING
     #ABNOKQ              NUMERO DOSSIER          /DOSSI  
     my $ABPYKQ = 'alles ok';
     my $sqlbetaling =("SELECT IDFDKQ,EXIDKQ,ABTVKQ,ABVYKQ,ABVMKQ,ABCNKQ,ABCOKQ,AT79KQ,ABPYKQ,ABNOKQ  FROM $betaling_fil WHERE IDFDKQ = $nr_zkf and EXIDKQ  = $externnummer and ABTVKQ  = $type_verz
                       and ABVYKQ BETWEEN $vorig_jaar and $jaar_getal");
     my $sthbetaling = $dbh->prepare( $sqlbetaling );
     $sthbetaling ->execute();
     my @betalingen = () ;
     my @laatstebetaling=();
     my  $totaal_over_alles;
     my $rijenteller = 0;
     my $hebben_nooit_betaald =0;
     my $betalingenh ;
     my $k;
     my $kold =0;
     my $eerste = 1;
     my $jaarb =0;
     my $maandb = 0;
     my $bedragb = 0;
     my $saldob =0;
     my $totb =0;
     while(@betalingen =$sthbetaling ->fetchrow_array)  {
         $ABPYKQ = 'Weigering';
         $totaal_over_alles +=  $betalingen[5];
         $betalingenh->{($betalingen[3]*100+$betalingen[4])}->{'betaald'} += $betalingen[5]; #zien of er gecrditeerd wordt        
         $betalingenh->{($betalingen[3]*100+$betalingen[4])}->{'jaar'} = $betalingen[3]; 
         $betalingenh->{($betalingen[3]*100+$betalingen[4])}->{'maand'} = $betalingen[4];
         $betalingenh->{($betalingen[3]*100+$betalingen[4])}->{'bedrag'} = $betalingen[5];
         $betalingenh->{($betalingen[3]*100+$betalingen[4])}->{'saldo'} = $betalingen[6];
         $betalingenh->{($betalingen[3]*100+$betalingen[4])}->{'totaal'} = $betalingen[7];
         $betalingenh->{($betalingen[3]*100+$betalingen[4])}->{'Dossier'} = $betalingen[9];
         #print "@betalingen->\n";
         if ($rijenteller== 0) {
           $jaarb = $betalingen[3]; #code
           $maandb =$betalingen[4];
           $hebben_nooit_betaald =1;
         }
         
         $rijenteller +=1;
         
        }
     eval {foreach $k (sort keys $betalingenh) {}};
     my $dossier=0;
     if (!$@) {
        foreach $k (sort keys $betalingenh) {
             
            if (($eerste == 1) and ($betalingenh->{$k}->{'saldo'} == 0 ) or $betalingenh->{$k}->{'betaald'} == 0  ) {
               $kold = $k;
               #print "->eerste -kold $kold \n";
               $jaarb = $betalingenh->{$k}->{'jaar'} ;
               $maandb = $betalingenh->{$k}->{'maand'};
               $bedragb = $betalingenh->{$k}->{'bedrag'};
               $saldob = $betalingenh->{$k}->{'saldo'};
               $totb = $betalingenh->{$k}->{'totaal'};
               $eerste = 0;
               $hebben_nooit_betaald =0;
               $dossier =$betalingenh->{$k}->{'Dossier'};
            }else {
               $jaarb = $betalingenh->{$k}->{'jaar'} ;
               $maandb = $betalingenh->{$k}->{'maand'};
               $bedragb += $betalingenh->{$k}->{'bedrag'};
               $saldob += $betalingenh->{$k}->{'saldo'};
               $totb = $betalingenh->{$k}->{'totaal'};
               $hebben_nooit_betaald = 0;
               $dossier =$betalingenh->{$k}->{'Dossier'};
            }
          
         #print "$betalingenh{$k}{'jaar'} $betalingenh{$k}{'maand'} $betalingenh{$k}{'bedrag'}  $betalingenh{$k}{'saldo'} $betalingenh{$k}{'totaal'}\n";
         #print  "->$jaarb,$maandb,$bedragb,$saldob,$totb\n";    
        }
     }
       #if ($ABPYKQ eq 'Weigering' and $saldob < 10 and $totb >= 0) {
       #    print '';
       #}
     return ($jaarb,$maandb,$bedragb,$saldob,$totb,$hebben_nooit_betaald,$totaal_over_alles,$ABPYKQ,$dossier);
    }
package maakExcel;
     use utf8;
     use Win32::OLE qw(CP_UTF8);
     Win32::OLE->Option(CP => CP_UTF8);      # set utf8 encoding
     use Unicode::String qw(utf8 latin1 utf16le);
 
     #use Win32::OLE;
     use Win32::OLE::Const 'Microsoft Excel';
     use Win32::OLE::Const 'Microsoft Word';
     use Win32::OLE qw(in with);
     use Win32::OLE::Variant;
     use File::Copy;
     #my $old_charset = odfLocalEncoding(); #versie 5.2 charset utf8 
     #LocalEncoding('iso-8859-15');  #versie 5.2
     sub rapport1 {
          my ($self,$klant,$instellingen,$eind_datum) = @_;
          my $plaats_sjabloon = $instellingen->{excel}->{plaats_sjabloon};
          my $sjabloon1 =  $instellingen->{excel}->{sjabloon1};
          my $sjabloon = "$plaats_sjabloon\\$sjabloon1";
          my $plaats_verslag = $instellingen->{excel}->{plaats_verslag};
          my $naam_verslag ="rapport1$eind_datum\.xlsx";
          unlink "$plaats_verslag\\$naam_verslag";
          my $Excel = Win32::OLE->GetActiveObject('Excel.Application')
     	|| Win32::OLE->new('Excel.Application', 'Quit');     
          $Excel->{'Visible'} = 0;  # toon wat je doet is 1
          my $Book = $Excel->Workbooks->Open($sjabloon);
          my $Sheet = $Book->Worksheets(1);
          $Sheet->{Name} = "overzicht op $eind_datum";
          my $aantal_verzekerden=0;
          my $rij_teller=0;
          my $kolom_teller=0;
          my $rij_offset = 1;
          my $kolom_offset = 1;
          my $inhoudcel= $Sheet->Cells($rij_offset,$kolom_offset+2);
          $inhoudcel->{Value} = "Rapport 1 op $eind_datum";
          $inhoudcel= $Sheet->Cells($rij_offset+2,$kolom_offset+0);
          $rij_teller +=1;
          #titel
          
          my $kolom_adres=16;
          my $er_is_een_verzekeringslijn=0;
          foreach my $rrn (sort keys $klanten) {
              $rij_teller +=1 if ($er_is_een_verzekeringslijn==0);
              $aantal_verzekerden +=1; 
              eval {foreach my  $zkfnr (keys $klanten->{$rrn}) {}};
                if (!$@){
                  foreach my  $zkfnr (keys $klanten->{$rrn}) { 
                    
                         $er_is_een_verzekeringslijn=0;
                         eval  {foreach my $verzekering (sort keys $klanten->{$rrn}->{$zkfnr}) {}};
                         if (!$@){
                                foreach my $verzekering (sort keys $klanten->{$rrn}->{$zkfnr}) {
                                       if ($verzekering ne 'klantinfo') {  
#                                            nieuw stuk bijgevoegd van bovenstaande om alle cellen in te vullen
                                            $inhoudcel= $Sheet->Cells($rij_offset+$rij_teller,$kolom_offset+1);
                                            $inhoudcel->{Value} =  sprintf ('%011s',$rrn);
                                            $inhoudcel= $Sheet->Cells($rij_offset+$rij_teller,$kolom_offset +2);
                                            $inhoudcel->{Value} =$zkfnr;
                                            $inhoudcel= $Sheet->Cells($rij_offset+$rij_teller,$kolom_offset +3);
                                            $inhoudcel->{Value} =$klanten->{$rrn}->{$zkfnr}->{klantinfo}->{voor_naam};
                                            $inhoudcel= $Sheet->Cells($rij_offset+$rij_teller,$kolom_offset +4);                                           
                                            $inhoudcel->{Value} =$klanten->{$rrn}->{$zkfnr}->{klantinfo}->{naam};
                                            $inhoudcel= $Sheet->Cells($rij_offset+$rij_teller,$kolom_offset +5);
                                            $inhoudcel->{Value} =$klanten->{$rrn}->{$zkfnr}->{klantinfo}->{geslacht};
                                            $inhoudcel= $Sheet->Cells($rij_offset+$rij_teller,$kolom_offset +6);
                                            $inhoudcel->{Value} =$klanten->{$rrn}->{$zkfnr}->{klantinfo}->{ouderdom};
                                            $inhoudcel= $Sheet->Cells($rij_offset+$rij_teller,$kolom_offset +7);
                                            $inhoudcel->{Value} =$klanten->{$rrn}->{$zkfnr}->{klantinfo}->{geboortedatum};
                                            $inhoudcel= $Sheet->Cells($rij_offset+$rij_teller,$kolom_offset+$kolom_adres);   
                                            $inhoudcel->{Value} = $klanten->{$rrn}->{$zkfnr}->{klantinfo}->{D_Address};
                                            $inhoudcel= $Sheet->Cells($rij_offset+$rij_teller,$kolom_offset+$kolom_adres+1);   
                                            $inhoudcel->{Value} = $klanten->{$rrn}->{$zkfnr}->{klantinfo}->{D_ZipCode};
                                            $inhoudcel= $Sheet->Cells($rij_offset+$rij_teller,$kolom_offset+$kolom_adres+2);   
                                            $inhoudcel->{Value} = $klanten->{$rrn}->{$zkfnr}->{klantinfo}->{D_Place};
                                            $inhoudcel= $Sheet->Cells($rij_offset+$rij_teller,$kolom_offset+$kolom_adres+3);   
                                            $inhoudcel->{Value} = $klanten->{$rrn}->{$zkfnr}->{klantinfo}->{D_CountryCode};
                                            $inhoudcel= $Sheet->Cells($rij_offset+$rij_teller,$kolom_offset+$kolom_adres+4);   
                                            $inhoudcel->{Value} = $klanten->{$rrn}->{$zkfnr}->{klantinfo}->{P_Address};
                                            $inhoudcel= $Sheet->Cells($rij_offset+$rij_teller,$kolom_offset+$kolom_adres+5);   
                                            $inhoudcel->{Value} = $klanten->{$rrn}->{$zkfnr}->{klantinfo}->{P_ZipCode};
                                            $inhoudcel= $Sheet->Cells($rij_offset+$rij_teller,$kolom_offset+$kolom_adres+6);   
                                            $inhoudcel->{Value} = $klanten->{$rrn}->{$zkfnr}->{klantinfo}->{P_Place};
                                            $inhoudcel= $Sheet->Cells($rij_offset+$rij_teller,$kolom_offset+$kolom_adres+7);   
                                            $inhoudcel->{Value} = $klanten->{$rrn}->{$zkfnr}->{klantinfo}->{P_CountryCode};

#                                            nieuw stuk bijgevoegd
                                              
                                              $inhoudcel= $Sheet->Cells($rij_offset+$rij_teller,$kolom_offset);
                                              $inhoudcel->{Value} =$aantal_verzekerden;
                                              $inhoudcel= $Sheet->Cells($rij_offset+$rij_teller,$kolom_offset+8);
                                              $inhoudcel->{Value} = $verzekering;
                                              $inhoudcel= $Sheet->Cells($rij_offset+$rij_teller,$kolom_offset+9);
                                              $inhoudcel->{Value} = $klanten->{$rrn}->{$zkfnr}->{$verzekering}->{dossier_nr};
                                              $inhoudcel= $Sheet->Cells($rij_offset+$rij_teller,$kolom_offset+10);
                                              $inhoudcel->{Value} = $klanten->{$rrn}->{$zkfnr}->{$verzekering}->{aansluitingscode};
                                              $inhoudcel= $Sheet->Cells($rij_offset+$rij_teller,$kolom_offset+11);
                                              $inhoudcel->{Value} = $klanten->{$rrn}->{$zkfnr}->{$verzekering}->{startdatum};
                                              $inhoudcel= $Sheet->Cells($rij_offset+$rij_teller,$kolom_offset+12);
                                              $inhoudcel->{Value} = $klanten->{$rrn}->{$zkfnr}->{$verzekering}->{wachtdatum};
                                              $inhoudcel= $Sheet->Cells($rij_offset+$rij_teller,$kolom_offset+13);
                                              $inhoudcel->{Value} = $klanten->{$rrn}->{$zkfnr}->{$verzekering}->{ontslagcode};
                                              $inhoudcel= $Sheet->Cells($rij_offset+$rij_teller,$kolom_offset+14);
                                              $inhoudcel->{Value} = $klanten->{$rrn}->{$zkfnr}->{$verzekering}->{einddatum};
                                              $inhoudcel= $Sheet->Cells($rij_offset+$rij_teller,$kolom_offset+15);
                                              $inhoudcel->{Value} = $klanten->{$rrn}->{$zkfnr}->{$verzekering}->{Verz_nr};
                                              $rij_teller +=1;
                                              $er_is_een_verzekeringslijn=1; 
                                       }
                                   }
                            }
                    }
                  
                }
              
            }
           $Excel->ActiveWorkbook->SaveAs("$plaats_verslag\\$naam_verslag");
           $Excel->ActiveWorkbook->Close(1);
         $Excel->Quit();
          return (1);
        }
 sub rapport2 {
          my ($self,$klant,$instellingen,$eind_datum) = @_;
          my $plaats_sjabloon = $instellingen->{excel}->{plaats_sjabloon};
          my $sjabloon2 =  $instellingen->{excel}->{sjabloon2};
          my $sjabloon = "$plaats_sjabloon\\$sjabloon2";
          my $plaats_verslag = $instellingen->{excel}->{plaats_verslag};
          my $naam_verslag ="rapport2$eind_datum\.xlsx";
          unlink "$plaats_verslag\\$naam_verslag";
          my $Excel = Win32::OLE->GetActiveObject('Excel.Application')
     	|| Win32::OLE->new('Excel.Application', 'Quit');     
          $Excel->{'Visible'} = 0;  # toon wat je doet is 1
          my $Book = $Excel->Workbooks->Open($sjabloon);
          my $Sheet = $Book->Worksheets(1);
          $Sheet->{Name} = "overzicht op $eind_datum";
          my $aantal_verzekerden=0;
          my $rij_teller=0;
          my $kolom_teller=0;
          my $rij_offset = 1;
          my $kolom_offset = 1;
          my $inhoudcel= $Sheet->Cells($rij_offset,$kolom_offset+2);
          $inhoudcel->{Value} = "Rapport 1 op $eind_datum";
          $inhoudcel= $Sheet->Cells($rij_offset+2,$kolom_offset+0);
          $rij_teller +=1;
          #titel
          
          my $kolom_adres=16;
          my $er_is_een_verzekeringslijn=0;
          eval { foreach my $rrn (sort keys $klanten) {}};
          if (!$@) {
            foreach my $rrn (sort keys $klanten) {
              $rij_teller +=1 if ($er_is_een_verzekeringslijn==0);
              $aantal_verzekerden +=1; 
              eval {foreach my  $zkfnr (keys $klanten->{$rrn}) {}};
                if (!$@){
                  foreach my  $zkfnr (keys $klanten->{$rrn}) { 
                    
                         $er_is_een_verzekeringslijn=0;
                         eval  {foreach my $verzekering (sort keys $klanten->{$rrn}->{$zkfnr}) {}};
                         if (!$@){
                                foreach my $verzekering (sort keys $klanten->{$rrn}->{$zkfnr}) {
                                       if ($verzekering ne 'klantinfo') {  
#                                            nieuw stuk bijgevoegd van bovenstaande om alle cellen in te vullen
                                            $inhoudcel= $Sheet->Cells($rij_offset+$rij_teller,$kolom_offset+1);
                                            $inhoudcel->{Value} =  sprintf ('%011s',$rrn);
                                            $inhoudcel= $Sheet->Cells($rij_offset+$rij_teller,$kolom_offset +2);
                                            $inhoudcel->{Value} =$zkfnr;
                                            $inhoudcel= $Sheet->Cells($rij_offset+$rij_teller,$kolom_offset +3);
                                            $inhoudcel->{Value} =$klanten->{$rrn}->{$zkfnr}->{klantinfo}->{voor_naam};
                                            $inhoudcel= $Sheet->Cells($rij_offset+$rij_teller,$kolom_offset +4);                                           
                                            $inhoudcel->{Value} =$klanten->{$rrn}->{$zkfnr}->{klantinfo}->{naam};
                                            $inhoudcel= $Sheet->Cells($rij_offset+$rij_teller,$kolom_offset +5);
                                            $inhoudcel->{Value} =$klanten->{$rrn}->{$zkfnr}->{klantinfo}->{geslacht};
                                            $inhoudcel= $Sheet->Cells($rij_offset+$rij_teller,$kolom_offset +6);
                                            $inhoudcel->{Value} =$klanten->{$rrn}->{$zkfnr}->{klantinfo}->{ouderdom};
                                            $inhoudcel= $Sheet->Cells($rij_offset+$rij_teller,$kolom_offset +7);
                                            $inhoudcel->{Value} =$klanten->{$rrn}->{$zkfnr}->{klantinfo}->{geboortedatum};
                                            $inhoudcel= $Sheet->Cells($rij_offset+$rij_teller,$kolom_offset+$kolom_adres);   
                                            $inhoudcel->{Value} = $klanten->{$rrn}->{$zkfnr}->{klantinfo}->{D_Address};
                                            $inhoudcel= $Sheet->Cells($rij_offset+$rij_teller,$kolom_offset+$kolom_adres+1);   
                                            $inhoudcel->{Value} = $klanten->{$rrn}->{$zkfnr}->{klantinfo}->{D_ZipCode};
                                            $inhoudcel= $Sheet->Cells($rij_offset+$rij_teller,$kolom_offset+$kolom_adres+2);   
                                            $inhoudcel->{Value} = $klanten->{$rrn}->{$zkfnr}->{klantinfo}->{D_Place};
                                            $inhoudcel= $Sheet->Cells($rij_offset+$rij_teller,$kolom_offset+$kolom_adres+3);   
                                            $inhoudcel->{Value} = $klanten->{$rrn}->{$zkfnr}->{klantinfo}->{D_CountryCode};
                                            $inhoudcel= $Sheet->Cells($rij_offset+$rij_teller,$kolom_offset+$kolom_adres+4);
                                            $inhoudcel->{Value} =  $klanten->{$rrn}->{$zkfnr}->{$verzekering}->{openstaand_saldo};
                                            #$inhoudcel= $Sheet->Cells($rij_offset+$rij_teller,$kolom_offset+$kolom_adres+5);
                                            #$inhoudcel->{Value} =  $klanten->{$rrn}->{$zkfnr}->{$verzekering}->{gefactureerd};
                                            #$inhoudcel= $Sheet->Cells($rij_offset+$rij_teller,$kolom_offset+$kolom_adres+6);
                                            #$inhoudcel->{Value} =  $klanten->{$rrn}->{$zkfnr}->{$verzekering}->{saldo};
                                            #$inhoudcel->{Value} = $klanten->{$rrn}->{$zkfnr}->{klantinfo}->{P_Address};
                                            #$inhoudcel= $Sheet->Cells($rij_offset+$rij_teller,$kolom_offset+$kolom_adres+5);   
                                            #$inhoudcel->{Value} = $klanten->{$rrn}->{$zkfnr}->{klantinfo}->{P_ZipCode};
                                            #$inhoudcel= $Sheet->Cells($rij_offset+$rij_teller,$kolom_offset+$kolom_adres+6);   
                                            #$inhoudcel->{Value} = $klanten->{$rrn}->{$zkfnr}->{klantinfo}->{P_Place};
                                            #$inhoudcel= $Sheet->Cells($rij_offset+$rij_teller,$kolom_offset+$kolom_adres+7);   
                                            #$inhoudcel->{Value} = $klanten->{$rrn}->{$zkfnr}->{klantinfo}->{P_CountryCode};

#                                            nieuw stuk bijgevoegd
                                              
                                              $inhoudcel= $Sheet->Cells($rij_offset+$rij_teller,$kolom_offset);
                                              $inhoudcel->{Value} =$aantal_verzekerden;
                                              $inhoudcel= $Sheet->Cells($rij_offset+$rij_teller,$kolom_offset+8);
                                              $inhoudcel->{Value} = $verzekering;
                                              $inhoudcel= $Sheet->Cells($rij_offset+$rij_teller,$kolom_offset+9);
                                              $inhoudcel->{Value} = $klanten->{$rrn}->{$zkfnr}->{$verzekering}->{dossier_nr};
                                              $inhoudcel= $Sheet->Cells($rij_offset+$rij_teller,$kolom_offset+10);
                                              $inhoudcel->{Value} = $klanten->{$rrn}->{$zkfnr}->{$verzekering}->{aansluitingscode};
                                              $inhoudcel= $Sheet->Cells($rij_offset+$rij_teller,$kolom_offset+11);
                                              $inhoudcel->{Value} = $klanten->{$rrn}->{$zkfnr}->{$verzekering}->{startdatum};
                                              $inhoudcel= $Sheet->Cells($rij_offset+$rij_teller,$kolom_offset+12);
                                              $inhoudcel->{Value} = $klanten->{$rrn}->{$zkfnr}->{$verzekering}->{wachtdatum};
                                              $inhoudcel= $Sheet->Cells($rij_offset+$rij_teller,$kolom_offset+13);
                                              $inhoudcel->{Value} = $klanten->{$rrn}->{$zkfnr}->{$verzekering}->{ontslagcode};
                                              $inhoudcel= $Sheet->Cells($rij_offset+$rij_teller,$kolom_offset+14);
                                              $inhoudcel->{Value} = $klanten->{$rrn}->{$zkfnr}->{$verzekering}->{einddatum};
                                              $inhoudcel= $Sheet->Cells($rij_offset+$rij_teller,$kolom_offset+15);
                                              $inhoudcel->{Value} = $klanten->{$rrn}->{$zkfnr}->{$verzekering}->{Verz_nr};
                                              $rij_teller +=1;
                                              $er_is_een_verzekeringslijn=1; 
                                       }
                                   }
                            }
                    }
                  
                }
              
            }
          }
          
           $Excel->ActiveWorkbook->SaveAs("$plaats_verslag\\$naam_verslag");
           $Excel->ActiveWorkbook->Close(1);
            $Excel->Quit();
          return (1);
        }    