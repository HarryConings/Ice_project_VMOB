#!/usr/bin/perl -w
#OPGELET!!!!!!
#Dit programma is auteursrechtelijk beschermd.
#Deze code is voor 50% eigendom van Hospiplus en voor 50% eigendom van de Firma  I.C.E. (liebroekstraat 43 3545 Halen BE0446888007) .
#Deze code mag niet aan derden (ook niet VNZ en NZVL) getoond worden tenzij met uitdrukkelijke en schriftelijke toestemming van Hospiplus en I.C.E. bvba .
#Indien dit toch gebeurt is er een boete verschuldigd van 250.000 Euro exclusief btw aan de Firma  I.C.E.
#Dit geldt ook voor het kopieren van een stuk code of het repliceren van technieken gehanteerd in dit programma
#I.C.E. beheert de broncode je mag  veranderingen aanbrengen aan het programma . Deze worden samen met de documentatie overgedragen aan I.C.E. .
#I.C.E. beslist dan op deze veranderingen worden doorgevoerd.

#Door het openen van deze broncode stem je in met de voorgaande voorwaarden.

#De gerechtigden om deze broncode te bekijken zijn Christian Bruyninckx , Michel Gielens en Ben Van Massenhoven.
#Harry Conings beheert voor I.C.E de broncode
#versie 1.8c aanpassing  bankrekening
#versie 1.8b geen@vnz.be
#versie 1.8a geboortedatum
#versie 1.8 uùlauten etc weg
#vesie 1.7 nieuwe layout agresso settings xml
#versie 1.5 NOK_WS
#versie 1.4 versturen in blokken van
#versie 1.3 error spaties bic nu altijd swift ingevuld plaats ingevuld ok ingevuld
#verie 1.2 dubbels ? + geen spaties in bic swift bankrekening VP als
#my $data = {
#     MasterFile => [ {
#         CompanyCode => 'VMOB',
#         ApArType => 'R',
#         ApArNo => 1000003,
#         SupplierCustomer => [{
#             UpdateFlag => 0,
#             Name => "Vanhoof Julien",
#             ApArGroup => 1,
#             CompRegNo => '',
#             ExternalRef => '0070003874691058',
#             ShortName => 'VANHOOFJUL',
#             CountryCode => "BE",
#             InvoiceInfo =>  {
#                 PayTerms => 45,
#                 TermsFlag => 1,
#                 Currency => 'EUR',
#                 CurrencyFlag => 1,
#                 Language => 'NL',
#                 CreditLimit => 0,
#                },
#             PaymentInfo => {
#                 PayMethod => 'IP',
#                 IBAN => 'BE82000000006868',
#                 Swift => 'BPOTBEB1',
#                 IntruleId => '01',
#                 Status => 'N',
#               },
#            },
#            ],
#         AddressInfo => [{
#             UpdateFlag => 0,
#             AddressType => 1,
#             ContactName => '',
#             ContactPosition => '',
#             Address => "Boslaan 20",
#             Place => "GEEL",
#             ZipCode => "2440",
#             CountryCode => "BE",
#             InternetInfo => {
#                 Email => "julien.vanhoof\@mail.be",
#                },
#             Phone => {
#                 Telephone1 => "014282546",
#                 Telephone6 => "N",
#                },
#            },
#            ],
#         Relation => [{
#             UpdateFlag => 0,
#             RelAttrId => 'O114',
#             RelValue => "OK",
#            },
#            ],
#        },
#        ],
#
#    };

use strict;
use XML::Simple;
use Date::Manip::DM5 ;
use Date::Calc qw(:all);
use Scalar::MoreUtils qw(empty);
use Data::Dumper;
use XML::Compile::Schema;
use XML::LibXML::Reader;
use XML::SAX;
use Net::SMTP;
use File::Slurp;
use utf8;
use Text::Unidecode;
require "settings_prod.pl";
require "cnnectdb_prod.pl";
require "bban_to_bic.pl";
require "chkbetaling.pl";
our $agresso_instellingen;
our @verzekeringen = ();
our %settings;
our @agresso_klant;
our %DATA;
our $cdata='';
our $mail = "VERSLAG KLANTENSYNCHRONISATE MET AGRESSO TEST\n-----------------------------------------\n\n";
our $aantal_blokken = 0;
our $test_prod = 'TEST'; # test = 'TEST' productie = 'PROG'
BEGIN { $ENV{HARNESS_ACTIVE} = 1 }
&load_agresso_setting("P:\\OGV\\ASSURCARD_$test_prod\\assurcard_settings_xml\\agresso_klanten_generatie_settings.xml");
my $ip = $main::agresso_instellingen->{"Agresso_IP_$main::test_prod"};  
&zoek_verzekeringen;

&mail_bericht;

sub load_agresso_setting  {
     my $file_name = shift @_;
     $agresso_instellingen = XMLin("$file_name");
     print "ingelezen\n";
     #maak verzekeringen

    }
sub zoek_verzekeringen {
     foreach my $zkf (keys $agresso_instellingen->{verzekeringen}){
         @verzekeringen = ();
         my $ziekenfondsnr = $& if ($zkf =~ m/\d{3}/);
         $mail = $mail."$zkf -> volgende verzekeringen:\n";
         $mail = $mail."--------------------------------\n";
         foreach my $verzekerings_naam (keys $agresso_instellingen->{verzekeringen}->{$zkf}){
             my $verzekerings_nummer = $agresso_instellingen->{verzekeringen}->{$zkf}->{$verzekerings_naam};
             eval {$verzekerings_nummer = $agresso_instellingen->{verzekeringen}->{$zkf}->{$verzekerings_naam}->{$verzekerings_naam}};

             push (@verzekeringen,$verzekerings_nummer);
             $mail = $mail."$verzekerings_naam ->$verzekerings_nummer \n";
            }
         #print "";
         $mail = $mail."\n";
         #zoek de mensen met deze verzekering
         &settings($ziekenfondsnr);
         my $dbconnectie = &cnnectdb ($settings{user_name},$settings{password},$settings{name_as400});
         &zoek_verzekerden ($dbconnectie,$ziekenfondsnr) ;#if ($zkf eq 'ZKF203')
        }
    }
sub zoek_verzekerden {
     my $dbh = shift @_;
     my $nrzkfcheck = shift @_;
     my $vandaag = ParseDate("today");
     $vandaag = substr ($vandaag,0,8);  # vandaag in YYYYMMDD
     my $jaar = substr ($vandaag,0,4);
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
       #ABTPJR  = INTERNAT.PREFIX TELNR
      # ABTEJR  = TELEFOONNUMMER
      # PGSMJR  = INT. PREFIX GSM-NR
      # NGSMJR = GSM-NUMMER
      #0-10
      #11 - 25
      #26-28
      my $driejaarterug = $vandaag-30000;
      my $placeholders = join ",", (@verzekeringen);
      my $sqlmutuitdet =("SELECT DISTINCT a.EXIDKK,b.NAIYL8,b.NAIML8,b.NAIJL8,c.ABSTJR,c.ABNTJR,c.ABBTJR,c.ABPTJR,c.ABWTJR,c.IV00JR,c.ABGIJR,c.KGERJR,
                        a.ABNOKK,a.EXIDKK,b.KNRNL8,a.IDFDKK,a.ABTVKK,a.ABEDKK,a.ABOCKK,a.AB2OKK,a.ABFDKK,a.A140KK,a.ABACKK,a.AB2AKK,a.ABOCKK,a.AB2OKK,a.ABPEKK,
                        b.NAMBL8,b.PRNBL8,b.LANGL8,b.SEXEL8,c.ABGIJR,c.ABKTJR,c.ABTPJR,c.ABTEJR,c.PGSMJR,c.NGSMJR
                        FROM $settings{'phoekk_fil'} a JOIN $settings{'pers_fil'} b ON a.EXIDKK=b.EXIDL8 JOIN $settings{'adres_fil'} c ON a.EXIDKK=EXIDJR
                        WHERE b.KNRNL8 != 0 and IDFDKK = $nrzkfcheck and ABTVKK IN ($placeholders) and ABADKK <= $vandaag and ABEDKK > $driejaarterug
                        and CONCAT(a.ABACKK,a.AB2AKK) != 'A04' and CONCAT(a.ABACKK,a.AB2AKK) != 'L05'
                        and (c.ABGIJR = (SELECT max( d.ABGIJR ) FROM $settings{'adres_fil'} d  WHERE d.EXIDJR =a.EXIDKK)  )
                        ORDER BY a.EXIDKK,c.IV00JR,c.KGERJR,c.ABPTJR,c.ABNTJR,c.ABBTJR,b.NAIYL8,b.NAIML8,b.NAIJL8 ASC" );#fetch first 10 rows only  ABOCKK  = '' bijgevoegd probleem circ cheque
      #versie 1.8 and ABOCKK = '' de ontslagen ookand b.KNRNL8 = 60073024369
     my $sthmutuitdet = $dbh->prepare( $sqlmutuitdet );
     $sthmutuitdet ->execute();
     my  $record_teller =0;
     my @agresso_klant =();
     my $klantteller = 0;
     my $oud_exid = 0;
     my $blok_grootte = $agresso_instellingen->{blok_grootte};
     my $blok_teller = 0;
     $aantal_blokken = 0;
     while(@agresso_klant =$sthmutuitdet->fetchrow_array)  {
         #@ext_nr=&checknaamextern ($agresso_klant[1]);
         foreach my $element (@agresso_klant) { #verwijder de leading en trailing spaces
             $element =~ s/^\s+//;
             $element =~ s/\s+$//;
            }
         if ($blok_teller ==$blok_grootte  ) {  #versie 1.4
              $aantal_blokken +=1;
              &maak_xml_file ($nrzkfcheck,$aantal_blokken);
              &verander_xml_file($nrzkfcheck,$aantal_blokken);
              &send_via_webserv_client($nrzkfcheck,$aantal_blokken);
              $blok_teller = 0#code
         }

         if ($oud_exid eq $agresso_klant[0]) {
             #print "\n\nDUBELE!!!!!\n\n";#code

         }else {
             $blok_teller +=1;
             $oud_exid =$agresso_klant[0];
             $record_teller +=1;
             my $ApArNo = &zoek_agresso_nummer ($dbh,$nrzkfcheck,$agresso_klant[13],$agresso_klant[14],$agresso_klant[27],$agresso_klant[28]);
             my $dossier_nr = $agresso_klant[12];
             my $verzek_nr =  $agresso_klant[16];
             my $Address ='';
             my $Name = "$agresso_klant[28] $agresso_klant[27]";
             $Name = unidecode ($Name); #versie 1.8 umlaut weg
             my $ExternalRef = $agresso_klant[14];
             $ExternalRef = sprintf ('%011s',$agresso_klant[14]); #voorloopnullen
             my $ShortName1 = "$agresso_klant[28]";
             my $ShortName2 = "$agresso_klant[27]";
             #$ShortName =~ s/\s//g;
             $ShortName1 = substr($ShortName1,0,7);
             $ShortName2 = substr($ShortName2,0,3);

             my $ShortName ="$ShortName1$ShortName2";
             $ShortName = unidecode ($ShortName);
             my $CountryCode = $agresso_klant[9];
             $CountryCode =~ s/\s//g;
             my $CompRegNo = $agresso_klant[1]*10000+$agresso_klant[2]*100+$agresso_klant[3];
             if ($CountryCode eq 'B' or $CountryCode eq 'b') {
                 $CountryCode = 'BE';
                }elsif ($CountryCode eq 'N' or $CountryCode eq 'n') {
                 $CountryCode = 'NL';
                }elsif ($CountryCode eq 'F' or $CountryCode eq 'f'){
                 $CountryCode = 'FR';
                }elsif ($CountryCode eq 'D' or $CountryCode eq 'd'){
                 $CountryCode = 'DE';
                }elsif ($CountryCode eq 'IND' or $CountryCode eq 'ind'){
                 $CountryCode = 'IN';
                }elsif ($CountryCode eq 'L' or $CountryCode eq 'l'){
                 $CountryCode = 'LU';
                }elsif ($CountryCode eq 'E' or $CountryCode eq 'e'){
                 $CountryCode = 'ES';
                }elsif ($CountryCode eq 'I' or $CountryCode eq 'i'){
                 $CountryCode = 'IT';
                }elsif ($CountryCode eq 'L' or $CountryCode eq 'l'){
                 $CountryCode = 'LU';
                }elsif ($CountryCode eq 'S' or $CountryCode eq 's'){
                 $CountryCode = 'SE';
                }elsif ($CountryCode eq 'M' or $CountryCode eq 'm'){
                 $CountryCode = 'MA';
                }elsif ($CountryCode eq 'IND' or $CountryCode eq 'ind'){
                 $CountryCode = 'IN';
                }elsif ($CountryCode eq 'THA' or $CountryCode eq 'tha'){
                 $CountryCode = 'TH';
                }elsif ($CountryCode eq 'POR' or $CountryCode eq 'por'){
                 $CountryCode = 'PT';
                }elsif ($CountryCode eq 'INO' or $CountryCode eq 'ino'){
                 $CountryCode = 'ID';
                }elsif ($CountryCode eq 'TUN' or $CountryCode eq 'tun'){
                     $CountryCode = 'TN';
                }elsif ($CountryCode eq 'CAN' or $CountryCode eq 'can'){
                     $CountryCode = 'CA';
                }elsif ($CountryCode eq 'IRL' or $CountryCode eq 'irl'){
                     $CountryCode = 'IE';
                }elsif ($CountryCode eq 'PHI' or $CountryCode eq 'phi'){
                     $CountryCode = 'PH';
                }elsif ($CountryCode eq 'CRO' or $CountryCode eq 'cro'){
                     $CountryCode = 'HR';
                }elsif ($CountryCode eq 'ROU' or $CountryCode eq 'rou'){
                     $CountryCode = 'RO';
                }elsif ($CountryCode eq 'TJE' or $CountryCode eq 'tje'){
                     $CountryCode = 'CZ';
                }elsif ($CountryCode eq 'POL' or $CountryCode eq 'pol'){
                     $CountryCode = 'PL';
                }elsif ($CountryCode eq 'A' or $CountryCode eq 'a'){
                     $CountryCode = 'AT';
                }elsif ($CountryCode eq 'TUR' or $CountryCode eq 'tur'){
                     $CountryCode = 'TM';
                }elsif ($CountryCode eq 'USA' or $CountryCode eq 'usa'){
                     $CountryCode = 'US';
                }elsif ($CountryCode eq 'ISR' or $CountryCode eq 'isr'){
                     $CountryCode = 'IL';
                }elsif ($CountryCode eq 'AUS' or $CountryCode eq 'aus'){
                     $CountryCode = 'AU';
                }elsif ($CountryCode eq 'SIN' or $CountryCode eq 'sin'){
                     $CountryCode = 'SG';
                }elsif ($CountryCode eq 'POL' or $CountryCode eq 'pol'){
                     $CountryCode = 'PL';
                }elsif ($CountryCode eq 'BEL' or $CountryCode eq 'bel'){
                     $CountryCode = 'BE';
                }elsif ($CountryCode eq 'VEZ' or $CountryCode eq 'vez'){
                     $CountryCode = 'VE';
                }elsif ($CountryCode eq 'EST' or $CountryCode eq 'est'){
                     $CountryCode = 'EE';
                }elsif ($CountryCode eq 'MAL' or $CountryCode eq 'mal'){
                     $CountryCode = 'MT';
                }elsif ($CountryCode eq 'RSL' or $CountryCode eq 'rsl'){
                     $CountryCode = 'SK';
                }elsif ($CountryCode eq 'T' or $CountryCode eq 't'){
                     $CountryCode = 'TR';
                }elsif ($CountryCode eq 'HAI' or $CountryCode eq 'hai'){
                     $CountryCode = 'HT';
                }elsif ($CountryCode eq 'SEN' or $CountryCode eq 'sen'){
                     $CountryCode = 'SN';
                }elsif ($CountryCode eq 'HON' or $CountryCode eq 'hon'){
                     $CountryCode = 'HU';
                }elsif ($CountryCode eq 'BUL' or $CountryCode eq 'bul'){
                     $CountryCode = 'BG';
                }elsif ($CountryCode eq 'RUS' or $CountryCode eq 'rus'){
                     $CountryCode = 'RU';
                }elsif ($CountryCode eq 'PAN' or $CountryCode eq 'pan'){
                     $CountryCode = 'PA';
                }elsif ($CountryCode eq 'COL' or $CountryCode eq 'col'){
                     $CountryCode = 'CO';
                }elsif ($CountryCode eq 'EAU' or $CountryCode eq 'eau'){
                     $CountryCode = 'AE';
                }elsif ($CountryCode eq 'MEX' or $CountryCode eq 'mex'){
                     $CountryCode = 'MX';
                }elsif ($CountryCode eq 'SUR' or $CountryCode eq 'sur'){
                     $CountryCode = 'SR';
                }elsif ($CountryCode eq 'SLO' or $CountryCode eq 'slo'){
                     $CountryCode = 'SL';
                }elsif ($CountryCode eq 'FIN' or $CountryCode eq 'fin'){
                     $CountryCode = 'FI';
                }elsif ($CountryCode eq 'LIT' or $CountryCode eq 'lit'){
                     $CountryCode = 'LT';
                }elsif ($CountryCode eq 'MON' or $CountryCode eq 'mon'){
                     $CountryCode = 'MC';
                }elsif ($CountryCode eq 'QAT' or $CountryCode eq 'qat'){
                     $CountryCode = 'QA';
                }elsif ($CountryCode eq 'EGY' or $CountryCode eq 'egy'){
                     $CountryCode = 'EG';
                }elsif ($CountryCode eq 'BRE' or $CountryCode eq 'bre'){
                     $CountryCode = 'BR';
                }elsif ($CountryCode eq 'OUG' or $CountryCode eq 'oug'){
                     $CountryCode = 'UG';
                }elsif ($CountryCode eq 'COR' or $CountryCode eq 'cor'){
                                        $CountryCode = 'CR';
                }elsif ($CountryCode eq 'SUR' or $CountryCode eq 'sur'){
                                        $CountryCode = 'SR';
                }elsif ($CountryCode eq 'MON' or $CountryCode eq 'mon'){
                                        $CountryCode = 'MC';                       
                }
                                  
             my $Email = &zoekemailadres ($dbh,$nrzkfcheck,$agresso_klant[13],$vandaag);
             my $EmailCc = 'geen';
             if ($Email =~ /geen\@vnz.be/i ) {
                 $EmailCc = 'geen@vnz.be';
                 $Email = 'geen';
             }

             my $Telephone1 ="$agresso_klant[33]$agresso_klant[34]";
             my $Telephone2 ="$agresso_klant[35]$agresso_klant[36]";
             #print "$nrzkfcheck $ExternalRef $Name $agresso_klant[14]\n";
             my @rekening_info = &zoekrekening_nummer ($dbh,$dossier_nr,$verzek_nr,$agresso_klant[0]);
             my $IBAN = $rekening_info[1];
             $IBAN =~ s/\s//g;
             $IBAN =~ s/\-//g;
             my $Swift = $rekening_info[0];
             $Swift =~ s/\s//g;
             my $Language = $agresso_klant[29];
             my $ontslagcode = $agresso_klant[29];
             my $RelValue = 'OK';
             if ($ontslagcode ne '') {
                 $RelValue = 'NOK_WS';#code
             }else {
                 $RelValue = &zoek_status_ok($dbh,$nrzkfcheck,$agresso_klant[16],$agresso_klant[0],$agresso_klant[14]);
             }


             if ($Language eq 'N') { #taal aanpassen aan agresso
                 $Language = 'NL';
                }elsif ($Language eq 'F') {
                 $Language = 'FR'
                }elsif ($Language eq 'D') {
                 $Language = 'DE'
                }else {
                 $Language = $agresso_instellingen->{Default_Language};
                }
             my $AddressType = $agresso_klant[31];
             if ($AddressType eq '01') { #aanpassen adrestype aan agresso
                 $AddressType = 1;#code
                }elsif ($AddressType eq '02') {
                 $AddressType = 2;
                }else {
                 $AddressType = 1;
                }

             my $ContactName =$agresso_klant[32];
             my $ZipCode = $agresso_klant[7];
             my $Place = $agresso_klant[8];
             $Address = "$agresso_klant[4] $agresso_klant[5] " if ($agresso_klant[6] eq '') ;
             $Address = "$agresso_klant[4] $agresso_klant[5] B $agresso_klant[6]" if ($agresso_klant[6] ne '') ;
             #print "$nrzkfcheck:$record_teller->@agresso_klant\n ";
             #aanmaken adresInfo
             my %masterfile_onderdeel;
             if (1 == 1) {     #gemaakt om makkelijker te colapsen
             my $adres_onderdeel = {
                 UpdateFlag => 0,
                 AddressType => $AddressType,
                 ContactName => $ContactName,
                 ContactPosition => '',
                 Address => $Address,
                 Place => $Place,
                 ZipCode => $ZipCode,
                 CountryCode => $CountryCode,
                 InternetInfo => {
                     Email =>$Email,
                     EmailCc => $EmailCc,
                    },
                 Phone => {
                     Telephone1 => $Telephone1,
                     Telephone2 => $Telephone2,
                    },
                };

             push (@{$masterfile_onderdeel{AddressInfo}},$adres_onderdeel);
             if ($AddressType == 2) {     #postadres zoek naar het domi adres
                 #return ($Address,$ZipCode,$Place,$CountryCode,$Telephone1,$Telephone2);
                 my @domi_adres = &checkadres ($dbh,$agresso_klant[0],$nrzkfcheck);
                 #print "@domi_adres\n";
                 #delete $adres_onderdeel{$_} for keys %adres_onderdeel;
                 $adres_onderdeel ='';
                 $domi_adres[3] =~ s/\s//g;
                 if ($domi_adres[3] eq 'B' or $domi_adres[3] eq 'b') {
                     $domi_adres[3] = 'BE';
                    }elsif ($domi_adres[3] eq 'N' or $domi_adres[3] eq 'n') {
                     $domi_adres[3] = 'NL';
                    }elsif ($domi_adres[3] eq 'F' or $domi_adres[3] eq 'f'){
                     $domi_adres[3] = 'FR';
                    }elsif ($domi_adres[3] eq 'D' or $domi_adres[3] eq 'd'){
                     $domi_adres[3] = 'DE';
                    }elsif ($domi_adres[3] eq 'IND' or $domi_adres[3] eq 'ind'){
                     $domi_adres[3] = 'IN';
                    }elsif ($domi_adres[3] eq 'L' or $domi_adres[3] eq 'l'){
                     $domi_adres[3] = 'LU';
                    }elsif ($domi_adres[3] eq 'E' or $domi_adres[3] eq 'e'){
                     $domi_adres[3] = 'ES';
                    }elsif ($domi_adres[3] eq 'I' or $domi_adres[3] eq 'i'){
                     $domi_adres[3] = 'IT';
                    }elsif ($domi_adres[3] eq 'L' or $domi_adres[3] eq 'l'){
                     $domi_adres[3] = 'LU';
                    }elsif ($domi_adres[3] eq 'S' or $domi_adres[3] eq 's'){
                     $domi_adres[3] = 'SE';
                    }elsif ($domi_adres[3] eq 'M' or $domi_adres[3] eq 'm'){
                     $domi_adres[3] = 'MA';
                    }elsif ($domi_adres[3] eq 'IND' or $domi_adres[3] eq 'ind'){
                     $domi_adres[3] = 'IN';
                    }elsif ($domi_adres[3] eq 'THA' or $domi_adres[3] eq 'tha'){
                     $domi_adres[3] = 'TH';
                    }elsif ($domi_adres[3] eq 'POR' or $domi_adres[3] eq 'por'){
                     $domi_adres[3] = 'PT';
                    }elsif ($domi_adres[3] eq 'INO' or $domi_adres[3] eq 'ino'){
                     $domi_adres[3] = 'ID';
                    }elsif ($domi_adres[3] eq 'TUN' or $domi_adres[3] eq 'tun'){
                     $domi_adres[3] = 'TN';
                    }elsif ($domi_adres[3] eq 'CAN' or $domi_adres[3] eq 'can'){
                     $domi_adres[3]  = 'CA';
                    }elsif ($domi_adres[3] eq 'IRL' or $domi_adres[3] eq 'irl'){
                     $domi_adres[3]  = 'IE';
                    }elsif ($domi_adres[3] eq 'PHI' or $domi_adres[3] eq 'phi'){
                     $domi_adres[3] = 'PH';
                    }elsif ($domi_adres[3] eq 'CRO' or $domi_adres[3] eq 'cro'){
                     $domi_adres[3] = 'HR';
                    }elsif ($domi_adres[3] eq 'ROU' or $domi_adres[3] eq 'rou'){
                     $domi_adres[3] = 'RO';
                    }elsif ($domi_adres[3] eq 'TJE' or $domi_adres[3] eq 'tje'){
                     $domi_adres[3] = 'CZ';
                    }elsif ($domi_adres[3] eq 'POL' or $domi_adres[3] eq 'pol'){
                     $domi_adres[3] = 'PL';
                    }elsif ($domi_adres[3] eq 'A' or $domi_adres[3] eq 'a'){
                     $domi_adres[3] = 'AT';
                    }elsif ($domi_adres[3] eq 'TUR' or $domi_adres[3] eq 'tur'){
                     $domi_adres[3] = 'TM';
                    }elsif ($domi_adres[3] eq 'USA' or $domi_adres[3] eq 'usa'){
                     $domi_adres[3] = 'US';
                    }elsif ($domi_adres[3] eq 'ISR' or $domi_adres[3] eq 'isr'){
                     $domi_adres[3] = 'IL';
                    }elsif ($domi_adres[3] eq 'AUS' or $domi_adres[3] eq 'aus'){
                     $domi_adres[3] = 'AU';
                    }elsif ($domi_adres[3] eq 'SIN' or $domi_adres[3] eq 'sin'){
                     $domi_adres[3] = 'SG';
                    }elsif ($domi_adres[3] eq 'POL' or $domi_adres[3] eq 'pol'){
                     $domi_adres[3] = 'PL';
                    }elsif ($domi_adres[3] eq 'BEL' or $domi_adres[3] eq 'bel'){
                     $domi_adres[3] = 'BE';
                    }elsif ($domi_adres[3] eq 'VEZ' or $domi_adres[3] eq 'vez'){
                     $domi_adres[3] = 'VE';
                    }elsif ($domi_adres[3] eq 'EST' or $domi_adres[3] eq 'est'){
                     $domi_adres[3] = 'EE';
                    }elsif ($domi_adres[3] eq 'MAL' or $domi_adres[3] eq 'mal'){
                     $domi_adres[3] = 'MT';
                    }elsif ($domi_adres[3] eq 'RSL' or $domi_adres[3] eq 'rsl'){
                     $domi_adres[3] = 'SK';
                    }elsif ($domi_adres[3] eq 'T' or $domi_adres[3] eq 't'){
                     $domi_adres[3] = 'TR';
                    }elsif ($domi_adres[3] eq 'HAI' or $domi_adres[3] eq 'hai'){
                     $domi_adres[3] = 'HT';
                    }elsif ($domi_adres[3] eq 'SEN' or $domi_adres[3] eq 'sen'){
                     $domi_adres[3] = 'SN';
                    }elsif ($domi_adres[3] eq 'HON' or $domi_adres[3] eq 'hon'){
                     $domi_adres[3] = 'HU';
                    }elsif ($domi_adres[3] eq 'BUL' or $domi_adres[3] eq 'bul'){
                     $domi_adres[3] = 'BG';
                    }elsif ($CountryCode eq 'RUS' or $CountryCode eq 'rus'){
                     $CountryCode = 'RU';
                    }elsif ($CountryCode eq 'PAN' or $CountryCode eq 'pan'){
                     $CountryCode = 'PA';
                    }elsif ($CountryCode eq 'COL' or $CountryCode eq 'col'){
                     $CountryCode = 'CO';
                    }elsif ($CountryCode eq 'EAU' or $CountryCode eq 'eau'){
                     $CountryCode = 'AE';
                    }elsif ($CountryCode eq 'MEX' or $CountryCode eq 'mex'){
                     $CountryCode = 'MX';
                    }elsif ($CountryCode eq 'SUR' or $CountryCode eq 'sur'){
                     $CountryCode = 'SR';
                    }elsif ($CountryCode eq 'SLO' or $CountryCode eq 'slo'){
                     $CountryCode = 'SL';
                    }elsif ($CountryCode eq 'FIN' or $CountryCode eq 'fin'){
                     $CountryCode = 'FI';
                    }elsif ($CountryCode eq 'LIT' or $CountryCode eq 'lit'){
                     $CountryCode = 'LT';
                    }elsif ($CountryCode eq 'MON' or $CountryCode eq 'mon'){
                     $CountryCode = 'MC';
                    }elsif ($CountryCode eq 'QAT' or $CountryCode eq 'qat'){
                     $CountryCode = 'QA';
                    }elsif ($CountryCode eq 'EGY' or $CountryCode eq 'egy'){
                     $CountryCode = 'EG';
                    }elsif ($CountryCode eq 'BRE' or $CountryCode eq 'bre'){
                     $CountryCode = 'BR';
                    }elsif ($CountryCode eq 'OUG' or $CountryCode eq 'oug'){
                     $CountryCode = 'UG';
                    }elsif ($CountryCode eq 'COR' or $CountryCode eq 'cor'){
                                        $CountryCode = 'CR';
                    }elsif ($CountryCode eq 'SUR' or $CountryCode eq 'sur'){
                                        $CountryCode = 'SR';
                    }elsif ($CountryCode eq 'MON' or $CountryCode eq 'mon'){
                                        $CountryCode = 'MC';     
                    }
                   
                 #print "$adres_onderdeel\n ";
                 $adres_onderdeel = {
                     UpdateFlag => 0,
                     AddressType => '1',
                     ContactName => '',
                     ContactPosition => '',
                     Address => $domi_adres[0],
                     Place => $domi_adres[2],
                     ZipCode => $domi_adres[1],
                     CountryCode => $domi_adres[3],
                     InternetInfo => {
                         Email =>$Email,
                         EmailCc => $EmailCc,
                        },
                     Phone => {
                         Telephone1 => $domi_adres[4],
                         Telephone2 => $domi_adres[5],
                        },
                    };
                 push (@{$masterfile_onderdeel{AddressInfo}},$adres_onderdeel);
                }else { # postadres terug leegmaken
                     $adres_onderdeel ='';
                     $adres_onderdeel = {
                     UpdateFlag => 0,
                     AddressType => '2',
                     ContactName => '',
                     ContactPosition => '',
                     Address => 'Hospiplus',
                     Place => 'Hospiplus',
                     ZipCode => '',
                     CountryCode => 'BE',
                     #InternetInfo => {
                     #    Email =>$Email,
                     #    EmailCc => $EmailCc,
                     #   },
                     #Phone => {
                     #    Telephone1 => $Telephone1,
                     #    Telephone2 => $Telephone2,
                     #   },
                    };
                  push (@{$masterfile_onderdeel{AddressInfo}},$adres_onderdeel);    
                }
              $adres_onderdeel ='';
             }
             #aanmaken  SupplierCustomer
             my $SupplierCustomer_onderdeel ;
             if (1==1) {
             if (!defined $Swift or $Swift eq '') {
                 $Swift=&bic_via_webserv_client($IBAN,$dbh);
                }
             $Swift = 'RAIFCH22' if ($Swift eq 'RAIFCH2257' or $Swift eq 'raifch2257' );
             $Swift = '' if ($Swift eq 'VRIJ' or $Swift eq 'vrij');
             $Swift =~ s/\s//g;
             $SupplierCustomer_onderdeel = {
                 UpdateFlag => 0,
                 Name =>$Name,
                 ApArGroup => 1,
                 CompRegNo => $CompRegNo,
                 ExternalRef =>$ExternalRef,
                 ShortName => $ShortName,
                 CountryCode => $CountryCode,
                 InvoiceInfo =>  {
                     PayTerms => $agresso_instellingen->{PayTerms},
                     TermsFlag => 1,
                     Currency => $agresso_instellingen->{Currency},
                     CurrencyFlag => 1,
                     Language => $Language,
                     CreditLimit => $agresso_instellingen->{CreditLimit},
                    },
                 PaymentInfo => {
                     PayMethod => $agresso_instellingen->{PayMethod},
                     IBAN => $IBAN,
                     Swift => $Swift,
                     IntruleId => '01',
                     Status => 'N',
                    },
               };#code



             push (@{$masterfile_onderdeel{SupplierCustomer}},$SupplierCustomer_onderdeel);
             $SupplierCustomer_onderdeel ='';
             }
             #aanmaken relation
             if (1==1) { #makkelijker om te colapsen

             my $Relation_onderdeel = {
                 UpdateFlag => 0,
                 RelAttrId => 'O114',
                 RelValue => "$RelValue",
                };
             push (@{$masterfile_onderdeel{Relation}},$Relation_onderdeel);
             $Relation_onderdeel ='';
             }
             $masterfile_onderdeel{CompanyCode}='VMOBZZ';
             $masterfile_onderdeel{ApArType} ='R';
             $masterfile_onderdeel{ApArNo} = $ApArNo;
             #print "";
             push (@{$DATA{MasterFile}},{%masterfile_onderdeel});
             #print"";
             $klantteller +=1;
            }

        }
     $mail = $mail."aantal klanten in deze verzekeringen -> $klantteller\n\n" ;
     $aantal_blokken +=1;
     &maak_xml_file ($nrzkfcheck,$aantal_blokken);
     &verander_xml_file($nrzkfcheck,$aantal_blokken);
     &send_via_webserv_client($nrzkfcheck,$aantal_blokken);
     $mail = $mail."\n$aantal_blokken XML's verzonden voor ziekenfonds $nrzkfcheck\n\n";
     $blok_teller = 0#code
    }
sub zoek_status_ok {
     my $dbh = shift @_;
     my $zkf_nr = shift @_;
     my $verzekering = shift @_;
     my $extern_nr = shift @_;
     my $rijksregnr = shift @_;
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
     #AGRESONR is nummer voor agresso begint bij 100000
     my $ok = $dbh->selectrow_array("SELECT OKNOW FROM $settings{'ascard_fil'} WHERE KNRN52 =$rijksregnr");
     $ok =~ s/\s//g;
     if ($ok eq 'Y') {
         return ('OK') ; # OK is '' moet nog veranderd worden in ok #code
     }elsif  ($ok eq 'N') {
         return ('NOK_WS') ;
     }else {
         my $get_ok = &zoek_of_betaald_heeft($dbh,$zkf_nr,$verzekering,$extern_nr);
         return ($get_ok);
     }

}
sub zoek_of_betaald_heeft {
     my $dbh = shift @_;
     my $zkf_nr = shift @_;
     my $verzekering = shift @_;
     my $extern_nr = shift @_;
     my $vandaag = ParseDate("today");
     $vandaag = substr ($vandaag,0,8);  # vandaag in YYYYMMDD
     my $vandaag_jaar = substr ($vandaag,0,4);  # vandaag in YYYYMMDD
     my $vandaag_maand= substr ($vandaag,4,2);  # vandaag in YYYYMMDD
     my $vandaag_dag= substr ($vandaag,6,2);  # vandaag in YYYYMMDD
     # subroutine geeft terug  nr-zkf,nr_extern,type_verz,jaar laatste bet,maandlaatste bet, bedrag,saldo,totaal al gestord,habben nooit betaald als 1 nooit
     my @betaling = &checkbetaling ($zkf_nr,$verzekering,$extern_nr,$settings{'ptaxkq_fil'},$dbh);
     print "$zkf_nr,$verzekering,$extern_nr,$betaling[0],$betaling[1]\n";
     my $Dd = Delta_Days($vandaag_jaar,$vandaag_maand,$vandaag_dag,$betaling[0],$betaling[1],28);
     my $aantal_dagen_te_laat = 0;
     if ($Dd < 0) {
         $aantal_dagen_te_laat = -$Dd;
         if ($aantal_dagen_te_laat < $agresso_instellingen->{'PayTerms'} ) {
              return ('');  # ok is '' in agresso
            }else {
              return ('NOK_WS');
            }
        }else {
         return ('');
        }

}
sub zoekemailadres {
     my $dbh = shift @_;
     my $nrzkfcheck = shift @_;
     my $externnummer = shift @_;
     my $vandaag_dag  = shift @_;
     my $emailadres='';
    #openen libcxfilxx.PEMWVL
     #ABVDVL              DATE DEBUT              /DATUM
     #ABTDVL              DATE FIN                /DATUM
     #EXIDVL              NUMERO EXTERNE          /EXTER
     #AJW1VL              CODE WWW                /CODE
     #AJW2VL              ZONE WWW                /ZONE
     #IDFDVL              NUMERO MUTUELLE         /NUMME
     my $emailadressenselect = ("SELECT IDFDVL,ABVDVL,ABTDVL,EXIDVL,AJW1VL,AJW2VL FROM $settings{'email_fil'}  WHERE IDFDVL = $nrzkfcheck and ABVDVL !> $vandaag_dag and ABTDVL !< $vandaag_dag and AJW2VL != '' and EXIDVL = $externnummer ");
     my $sthemailadressen = $dbh->prepare($emailadressenselect);
     $sthemailadressen ->execute();
     while (my @emailadressen = $sthemailadressen ->fetchrow_array)  {
         #print"$emailadressen[5]";
         $emailadres = $emailadressen[5];
        }
     if ($emailadres eq '' or $emailadres =~ m/geen\@vnz.be/) {  #versie 8.3
          $emailadres = 'geen';
        }else {
         $emailadres =~s/\s//g;
        }
      return ($emailadres)
}
sub zoekrekening_nummer {
     my $dbh = shift @_;
     my $dossiernr = shift @_;
     my $verz = shift @_;
     my $extern_nummer = shift @_;
     my $verz_dossier;
     my @dossiers;
     my @verzekeringen_klant;
     my @rij;
     my @rek =();
     my $sql =("SELECT ABNOKK,ABTVKK FROM $settings{'phoekk_fil'} WHERE EXIDKK = $extern_nummer and ABOCKK = '' ");
     my $sth = $dbh->prepare( $sql );
     $sth ->execute();
     while(@rij =$sth->fetchrow_array)  {
           push (@verzekeringen_klant,$rij[1]);
           push (@dossiers,$rij[0]);
           $verz_dossier->{$rij[1]}= $rij[0];
          }
     # B.ABTDKW              DATE FIN                /DATUM
     # B.ABTVKW              TYPE ASSURABILITE       /TYPE
     # B.EXIDKW              NUMERO EXTERNE          /EXTER
     # B.ABRCKW              NUM CPTE FIN. TIT.      /NR FI
     # B.SR93KW              BIC BANQUE BEN.             /B
     # B.CPETKW              NO COMPTE ETRANGER-IBAN /FIN.
     # B.ABNOKW              NUMERO DOSSIER          /DOSSI
     # B.ADBRKW              TYPE COMPTE BANCAIRE /SOORT BA
      if ($verz_dossier->{$verz} == $dossiernr) {
           #is ok
          }else {
            foreach my $verzke (sort @verzekeringen) {
                if (defined $verz_dossier->{$verzke} ) {
                     $dossiernr = $verz_dossier->{$verzke};
                     $verz = $verzke;
                     last;
                    }
               }
          }
      #@rek= $dbh->selectrow_array("SELECT SR93KW,CPETKW,ABRCKW  FROM $settings{'prek_fil'} WHERE ABNOKW  = $dossiernr and ABTDKW  =  99999999 and ABTVKW = $verz");
      $sql =("SELECT SR93KW,CPETKW,ABRCKW,ADBRKW  FROM $settings{'prek_fil'} WHERE ABNOKW  = $dossiernr and ABTDKW  =  99999999 and ABTVKW = $verz ORDER BY ADBRKW DESC ");
      $sth = $dbh->prepare( $sql );
      $sth ->execute();
      while(my @rek_voorlopig =$sth->fetchrow_array)  {
           foreach my $element (@rek_voorlopig) { #verwijder de leading en trailing spaces
                $element =~ s/^\s+//;
                $element =~ s/\s+$//;
               }
           #print "rek_voorlopig @rek_voorlopig\n";
           if ($rek_voorlopig[3] == 3) {
                @rek = @rek_voorlopig;
               }
           if ($rek_voorlopig[3] == 2 and ($rek_voorlopig[1] ne 'BE18990000000065' or $rek_voorlopig[1] ne 'BE00990000000065') and defined $rek_voorlopig[1]) {
                @rek = @rek_voorlopig;
                last;
               }
           if ($rek_voorlopig[3] == 1 and ($rek_voorlopig[1] ne 'BE18990000000065' or $rek_voorlopig[1] ne 'BE00990000000065') and defined $rek_voorlopig[1]) {
                @rek = @rek_voorlopig;
               }
           if ($rek_voorlopig[3] == 1 and !defined $rek[1]) {
                @rek = @rek_voorlopig;
               }
          }
          #print "rek @rek\n" ;
      if ($rek[1] eq 'BE18990000000065' or $rek[1] eq 'BE00990000000065' or !defined $rek[1]) {
           #print "$rek[1] -> nemen verzekering 1\n";
           #@rek= $dbh->selectrow_array("SELECT SR93KW,CPETKW,ABRCKW  FROM $settings{'prek_fil'} WHERE ABNOKW  = $dossiernr and ABTDKW  =  99999999 and ABTVKW = 1");#code
            $sql =("SELECT SR93KW,CPETKW,ABRCKW,ADBRKW  FROM $settings{'prek_fil'} WHERE ABNOKW  = $dossiernr and ABTDKW  =  99999999 and ABTVKW = 1 ORDER BY ADBRKW DESC ");
            $sth = $dbh->prepare( $sql );
            $sth ->execute();
            while(my @rek_voorlopig =$sth->fetchrow_array)  {
                foreach my $element (@rek_voorlopig) { #verwijder de leading en trailing spaces
                     $element =~ s/^\s+//;
                     $element =~ s/\s+$//;
                    }
                #print "rek_voorlopig1 @rek_voorlopig\n";
                if ($rek_voorlopig[3] == 3) {
                     @rek = @rek_voorlopig;
                    }
                if ($rek_voorlopig[3] == 2 and ($rek_voorlopig[1] ne 'BE18990000000065' or $rek_voorlopig[1] ne 'BE00990000000065') and defined $rek_voorlopig[1]) {
                     @rek = @rek_voorlopig;
                     last;
                    }
                if ($rek_voorlopig[3] == 1 and ($rek_voorlopig[1] ne 'BE18990000000065' or $rek_voorlopig[1] ne 'BE00990000000065') and defined $rek_voorlopig[1]) {
                     @rek = @rek_voorlopig;
                    }
                if ($rek_voorlopig[3] == 1 and !defined $rek[1]) {
                     @rek = @rek_voorlopig;
                    }
               }
           #print "rek 1 @rek\n";
           if (!defined $rek[1] or $rek[1] eq 'BE18990000000065' or $rek[1] eq 'BE00990000000065') {
                #print " kan geen rekening vinden 1 -> @rek\n";
                my $dossier = &zoekdossier ($dbh,$extern_nummer);
                print "dossier  $dossier\n";
                if ($dossier) {
                     #@rek= $dbh->selectrow_array("SELECT SR93KW,CPETKW,ABRCKW  FROM $settings{'prek_fil'} WHERE ABNOKW  = $dossier and ABTDKW  =  99999999 and ABTVKW = 1");#code
                     $sql =("SELECT SR93KW,CPETKW,ABRCKW,ADBRKW  FROM $settings{'prek_fil'} WHERE ABNOKW  = $dossier and ABTDKW  =  99999999 and ABTVKW = 1 ORDER BY ADBRKW DESC ");
                     $sth = $dbh->prepare( $sql );
                     $sth ->execute();
                     while(my @rek_voorlopig =$sth->fetchrow_array)  {
                          foreach my $element (@rek_voorlopig) { #verwijder de leading en trailing spaces
                               $element =~ s/^\s+//;
                               $element =~ s/\s+$//;
                              }
                          #print "rek_voorlopig3 @rek_voorlopig\n";
                          if ($rek_voorlopig[3] == 3) {
                               @rek = @rek_voorlopig;
                              }
                          if ($rek_voorlopig[3] == 2 and ($rek_voorlopig[1] ne 'BE18990000000065' or $rek_voorlopig[1] ne 'BE00990000000065') and defined $rek_voorlopig[1]) {
                               @rek = @rek_voorlopig;
                               last;
                              }
                          if ($rek_voorlopig[3] == 1 and ($rek_voorlopig[1] ne 'BE18990000000065' or $rek_voorlopig[1] ne 'BE00990000000065') and defined $rek_voorlopig[1]) {
                               @rek = @rek_voorlopig;
                              }
                          if ($rek_voorlopig[3] == 1 and !defined $rek[1]) {
                               @rek = @rek_voorlopig;
                              }
                         }
                    }
                #print "rek 3 @rek\n";
                #print " kan geen rekening vinden-> ander dossier $dossier -> @rek \n";
                $rek[1] =  'BE18990000000065' if (!defined $rek[1]) ;
               }
          }
     #we hebben aangepast dat hij van de verzerking 1 neemt 1 terug op $verz als we het anders willen


     #print "@rek\n";
     return (@rek);
}
sub zoekdossier {
     my $dbh =shift @_;
     my $extern_tit = shift @_;
     my @dossier = ();
      #zoek in PDOSKJ het dossier nummer
      # openen van PDOSKJ
      # IDFDKJ nummer ziekenfonds
      # ABTVKJ  TYPE VERZEKERING 1 IS VERPLICHTE
      # ABXSKJ EXTERN NUMMER
      # ABEDKJ EINDDATUM DOSSIER
      # ABOCKJ ONTSLAGKODE
      # AB2OKJ DETAIL ONTSLAGCODE
      # ABACKJ ansluitingskode
      # AB2AKJ detail aansluitingscode
      # ABDNKJ NUMMER VAN HET DOSSIER
      # ABADKJ aanvangsdatum van het dossier
      # ABFDKJ datum inbrengen eindatum dossier
      # A140KJ datum bijwerking dossier
      # ABADKJ begindatum dossier
      # ABDDKJ DATUM INBR.DEF.DOSSS.
      # ABGVKJ GEBRUIKER AKTIVATIE
      # NAG1KJ NUMMER AGENT 1
      # NAG2KJ NUMMER AGENT 2
      # ABNOKJ DOSSIERNUMMER
      # NBURKJ          NUMERO BUREAU TITULAIRE /BUREELNUMMER TI
      # SECTKJ          NUMERO DE SECTION DU TIT/SEKTIENUMMER TI
     @dossier = $dbh->selectrow_array("SELECT ABNOKJ,ABXSKJ,ABEDKJ,ABTVKJ,ABADKJ,ABEDKJ  FROM $settings{'pdoskj_fil'} WHERE ABXSKJ = $extern_tit and ABEDKJ  =  99999999 and ABTVKJ = 1");



     #print "dossier @dossier\n";

     return ($dossier[0]);
}
sub checkadres {
     my $dbh = shift @_;
     my $extern_nummer  = shift @_;
     my $zkf_nummer = shift @_;
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
     # ABTPJR  = INTERNAT.PREFIX TELNR
     # ABTEJR  = TELEFOONNUMMER
     # PGSMJR  = INT. PREFIX GSM-NR
     # NGSMJR = GSM-NUMMER
     my @domi_adres =$dbh->selectrow_array("SELECT EXIDJR,ABGIJR,ABKTJR,ABSTJR,ABNTJR,ABBTJR,IV00JR,ABPTJR,ABWTJR,ABTPJR,ABTEJR,PGSMJR,NGSMJR
                                           FROM $settings{'adres_fil'} WHERE EXIDJR= $extern_nummer and IDFDJR = $zkf_nummer and ABGIJR = '01'");
     foreach my $element (@domi_adres) { #verwijder de leading en trailing spaces
             $element =~ s/^\s+//;
             $element =~ s/\s+$//;
            }
     my $Address ='';
     $Address = "$domi_adres[3] $domi_adres[4] " if ($domi_adres[5] eq '') ;
     $Address = "$domi_adres[3] $domi_adres[4] B $domi_adres[5]" if ($domi_adres[5] ne '') ;
     my $CountryCode =  $domi_adres[6];
     my $ZipCode = $domi_adres[7];
     my $Place = $domi_adres[8];
     my $Telephone1 ="$domi_adres[9]$domi_adres[10]";
     my $Telephone2 ="$domi_adres[11]$domi_adres[12]";
     return ($Address,$ZipCode,$Place,$CountryCode,$Telephone1,$Telephone2);
}
sub zoek_agresso_nummer {
     my $dbh = shift @_;
     my $zkf = shift @_;
     my $extern = shift @_;
     my $rr_nr = shift @_;
     my $DOSSNR =0;
     my $NAAM52 = shift @_;
     my $VNAAM = shift @_;
     my $INZDAT =0;
     my $CREDAT=0;
     my $EINDAT=0;
     my $EINCON =0;
     my $CARDNR =0;
     my $ASSNR=0;
     my $OKNOW=0;
     my $DTCGOK=0;
     my $CARDTY=0;
     my $DTCATY=0;
     my $LOSTCARD=0;
     my $BATCHNR=0;
     my $TESTPROD=0;
     my $ONTSLAGO=0;
     my $CXMLINIT=0;
     my $CXMLUPDA=0;
     my $WANBET=0;
     my $ONTSLAG=0;
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
     #AGRESONR is nummer voor agresso begint bij 100000
     my $heeft_nr =$dbh->selectrow_array("SELECT AGRESONR FROM $settings{'ascard_fil'} WHERE KNRN52 =$rr_nr");
     if (defined $heeft_nr) {
         #print "$heeft_nr bestaat \n";
         return ($heeft_nr);#code
     }else {
         my $AGRESONR = $dbh->selectrow_array("SELECT MAX(AGRESONR) FROM $settings{'ascard_fil'}");
         $AGRESONR = 100000 if(!defined $AGRESONR) ;
         $AGRESONR +=1;
         my $zetin = "INSERT INTO $settings{'ascard_fil'} values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
           my $sth= $dbh ->prepare($zetin);
                  $sth->bind_param(1,$zkf);
                  $sth->bind_param(2,$extern);
                  $sth->bind_param(3,$rr_nr);
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
                  $sth -> finish();
         print "ingezet $zkf->$extern rrnr -> $rr_nr\n";
         return ($AGRESONR);
     }

}

sub maak_xml_file {
     my $nr_zkf = shift @_;
     my $aantal_blok = shift @_;
     my $xsd = $agresso_instellingen->{plaats_ABWSupplierCustomer_xsd};
     my $schema = XML::Compile::Schema->new($xsd);
     #my $schema = XML::Compile::Schema->new($xsd);
     $schema->importDefinitions($agresso_instellingen->{plaats_ABWSchemaLib_xsd});
     $schema->printIndex();
     warn $schema->template('PERL', 'ABWSupplierCustomer');
     my $doc    = XML::LibXML::Document->new('1.0', 'UTF-8');
     my $write  = $schema->compile(WRITER => 'ABWSupplierCustomer');
     my $xml    = $write->($doc, {%DATA});
     my $xml_file = "$agresso_instellingen->{plaats_file}\\klanten_naar_agresso_$nr_zkf\_B$aantal_blok.xml";
     $mail = $mail."\nxml gemaakt deze kan je vinden op:\n$xml_file";
     unlink $xml_file ;
     $doc->setDocumentElement($xml);
     open XMLFILE,"> $xml_file" or die "can not open file $xml_file ";
     select XMLFILE;
     print $doc->toString(1); # 1 indicates "pretty print"
     close XMLFILE;
     select STDOUT;
     undef %DATA;
     print "";
}
sub verander_xml_file {
     my $nr_zkf = shift @_;
     my $aantal_blok = shift @_;
     $cdata='';
     $cdata= read_file("$agresso_instellingen->{plaats_file}\\klanten_naar_agresso_$nr_zkf\_B$aantal_blok.xml");
     $cdata=~ s%^<\?xml%<imp:Xml><![CDATA[<\?xml%;
     $cdata=~ s%</ABWSupplierCustomer>$%</ABWSupplierCustomer>]]></imp:Xml>%;
     #print "\n$cdata\n";
     #print "";
}
sub send_via_webserv_client {
     my $aantal_blok = shift @_;
     use SOAP::Lite
     +trace => [ transport => sub { print $_[0]->as_string } ];
     use XML::Compile::SOAP12::Client;
     use XML::Writer;
     use XML::Writer::String;
     $ENV{HTTPS_DEBUG} = 1;
     $ENV{HTTP_DEBUG} = 1;
     my $ip = $main::agresso_instellingen->{"Agresso_IP_$main::test_prod"};      
     my $serverProcessId = 'CS15';
     my $menuId = 'BI192';
     my $variant = 7;  #oud 7 10 is voor test
     my $username = 'WEBSERV';
     my $client = 'VMOB';
     my $password = 'WEBSERV';
     my $Username = SOAP::Data->name('imp:Username' => $username)->type('');
     my $Password = SOAP::Data->name('imp:Password' => $password)->type('');
     my $Client  = SOAP::Data->name('imp:Client' => $client)->type('');
     my $ServerProcessId = SOAP::Data->name('imp:ServerProcessId' => $serverProcessId)->type('');
     my $MenuId = SOAP::Data->name('imp:MenuId' => $menuId)->type('');
     my $Variant = SOAP::Data->name('imp:Variant' => $variant)->type('');
     my $Xml = SOAP::Data->name('imp:Xml' =>$cdata)->type('xml');
     my $Input = SOAP::Data->name('imp:input')
            ->value(\SOAP::Data->value($ServerProcessId,$MenuId,$Variant,$Xml));
     my $Credentials = SOAP::Data->name('imp:credentials')
            ->value(\SOAP::Data->value($Username, $Client,$Password));
     my $soap = SOAP::Lite
     #-> proxy('http://S200WP1XXL01.mutworld.be/BusinessWorld-webservices/service.svc?ImportService/ImportV200606') #productie
     -> proxy("http://$ip/BusinessWorld-webservices/service.svc?ImportService/ImportV200606")
     ->ns('http://services.agresso.com/ImportService/ImportV200606','imp')
     ->on_action( sub { return 'ExecuteServerProcessAsynchronously' } );

     my $response = $soap->ExecuteServerProcessAsynchronously($Input,$Credentials);
     my $antwoord ='';
     my $ordernr = $response->{_content}[4]->{Body}->{ExecuteServerProcessAsynchronouslyResponse}
     ->{ExecuteServerProcessAsynchronouslyResult}->{OrderNumber};
     my $fault = $response->{_content}[4]->{Body}->{Fault}->{faultstring};
     if ($ordernr =~ m/\d+/) {
         $antwoord ="OK odernr = $ordernr";#code
     }else {
         $antwoord ="ERROR !! -> $fault";
     }

     $mail = $mail."\n XML verzonden naar agresso:\nAntwoord van agresso: -> $antwoord\n";

     print "$response\n";
}
sub mail_bericht {
     #print "mail-start\n";
     my $aan = $agresso_instellingen->{mail_verslag_naar};
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
         $smtp->datasend("Subject: Agresso klanten synchronisatie $vandaag");
         $smtp->datasend("\n");
         $smtp->datasend("$mail\nvriendelijke groeten\nHarry Conings");
         $smtp->dataend;
         $smtp->quit;
         print "mail aan $geadresseerde  gezonden\n";
        }
    }
1;