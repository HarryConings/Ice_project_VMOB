#!/usr/bin/perl -w
use strict;
require 'package_maak_brief_MI.pl';
require 'agresso_bban_bic_db_MI.pl';
require 'bban_to_bic_MI.pl';
require 'Decryp_Encrypt_MI.pl';
require "package_cnnectdb_MI.pl";
require "package_settings_MI.pl";
require "package_sql_toegang_agresso_MI.pl";    
#require 'package_as400_gegevens.pl';
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
package main;
     our $test_prod = 'TEST'; # test = 'TEST' productie = 'PROD'
     BEGIN { $ENV{HARNESS_ACTIVE} = 1 }
     use strict;
     use MIME::Base64;
     use XML::Simple;
     use Date::Manip::DM5 ;
     use Date::Calc qw(:all);
     use Scalar::MoreUtils qw(empty);
     use Data::Dumper;
     #use XML::Simple;
     use XML::Compile::Schema;
     use XML::Compile::Translate;
     use XML::LibXML::Reader;
     use XML::SAX;
     use Net::SMTP;
     use File::Slurp;
     use utf8;
     use Text::Unidecode;
     use Wx qw(:everything);
     use base qw(Wx::Frame);
     use Data::Dumper;
     use Wx::Locale gettext => '_T';
     use Proc::Forkfunc;
     use IO::Socket::INET;
     use Storable;
     use Data::Dumper;
     #require "settings.pl";
     #require "cnnectdb.pl";
     #require "bban_to_bic.pl";
     #require "chkbetaling_prod.pl";
     #require 'agresso_bban_bic_db_prod.pl';
     our $version = "20231006-$test_prod"; #vorige '20200625'
     our $frame;     
     our $welke_brieven_maken;   
     our $settings;
     our @verzekeringen = ();
     our %DATA;
     our $cdata='';
     our $ziekenfonds_nummer;
     our $externnummer;
     our $klant;
     our $total_ok =0;
     our $total_nok=0;
     our $vandaag = ParseDate("today");
         my $td_1=substr($vandaag,0,4);
         my $td_2=substr($vandaag,4,2);
         my $td_3=substr($vandaag,6,2);
         my $td_4 = substr($vandaag,8,2);
         my $td_5 = substr($vandaag,11,2);
         my $td_6 = substr($vandaag,14,2);
     our $tech_creation_date = "$td_1-$td_2-$td_3-$td_4.$td_5.$td_6.000000";
     our $verzekeringen_in_xml_org;
     our @verzekeringen_in_xml;
     our $ApArGroup;
     our $bestaande_klant =0;
     our @contracts_brieven_check;
     our $premie = 0;
     our $appdialog;
     our $rijks_register_nummer;
     our $dbh_agresso;
     our $bolean_wachttijd;
     our $al_opgestart =0;
     my $vandaag_tijd = $vandaag;
     my $start_tijd = substr ($vandaag,8,8);
     $vandaag_tijd =~ s/://g;
     $vandaag_tijd =~ s/\s//g;
     our $tijd = substr ($vandaag_tijd,8,6);
     $vandaag = substr ($vandaag,0,8);  
     our $agresso_instellingen = main->load_settings("\\\\s298file101.zkf200mut.prd\\250-B\\Applicaties\\Assurcard\\assurcard_settings_xml_$test_prod\\mobicoon_settings.xml"); #is nagezien
     our $brieven_instellingen = main->load_settings("\\\\s298file101.zkf200mut.prd\\250-B\\Applicaties\\Assurcard\\assurcard_settings_xml_$test_prod\\mobicoon_brieven_settings.xml"); #is nagezien
     our $brieven_vervang_teksten = main->load_settings("\\\\s298file101.zkf200mut.prd\\250-B\\Applicaties\\Assurcard\\assurcard_settings_xml_$test_prod\\mobicoon_brieven_vervang_tekst.xml"); #nagezien
     our $teksten_GKD = main->load_settings("\\\\s298file101.zkf200mut.prd\\250-B\\Applicaties\\Assurcard\\assurcard_settings_xml_$test_prod\\mobicoon_UBW_Teksten.xml");
     #our $agresso_instellingen = main->load_settings("C:\\OGV\\ASSURCARD_$test_prod\\assurcard_settings_xml\\zet_klant_in_agresso_settings_new.xml"); #is nagezien
     #our $brieven_instellingen = main->load_settings("C:\\OGV\\ASSURCARD_$test_prod\\assurcard_settings_xml\\zet_klant_in_brieven_settings_new.xml"); #is nagezien
     #our $brieven_vervang_teksten = main->load_settings("C:\\OGV\\ASSURCARD_$test_prod\\assurcard_settings_xml\\zet_klant_in_brieven_vervang_tekst_new.xml"); #nagezien
     #our $teksten_GKD = main->load_settings("C:\\OGV\\ASSURCARD_$test_prod\\assurcard_settings_xml\\zet_klant_in_agresso_settings_Teksten_new.xml");
     our $gebruikersnaam = main->gebruikersnaam();
     $gebruikersnaam = uc $gebruikersnaam ;
     our $variant_LG04 =3;
     #$variant_LG04 = main->variant_LG04($gebruikersnaam);
     my $macro_pdf_openoffice ='';
     if (-e "$ENV{APPDATA}\\OpenOffice.org\\3" ) {
          $macro_pdf_openoffice ="$ENV{APPDATA}\\OpenOffice.org\\3\\user\\basic\\ConversionLibrary\\PDFConversion.xba";
     }elsif ("$ENV{APPDATA}\\OpenOffice\\4") {
          $macro_pdf_openoffice ="$ENV{APPDATA}\\OpenOffice\\4\\user\\basic\\ConversionLibrary\\PDFConversion.xba";          
     }
     
     our $pdfconversiemacro_bestaat;
     if (-e $macro_pdf_openoffice) {
          $pdfconversiemacro_bestaat = 1;
     }else {
          $pdfconversiemacro_bestaat = 0;
          #openofficemacro->maak_pdf_conversion($macro_pdf_openoffice);
     }
     foreach my $zkf_test (keys $main::agresso_instellingen->{as400}) {
          my $settings = settings->new('',$zkf_test);
          my $condb =connectdb->connect_as400 ($settings->{user},$settings->{pass},$settings->{name_as400});
          connectdb->disconnect($condb) if (defined $condb);
     }  
   
     #$ARGV[0] =02062615056;
     print "\nARGV[0] $ARGV[0] ARGV[1] $ARGV[1]\n";
     if (!defined $ARGV[0]) {
           main->new;
     }else {
        if ($main::al_opgestart ==0  ) {
            $main::al_opgestart =1;
            print "\n\nstart socket op\n____________________\n";
            my   $sock = IO::Socket::INET->new(Listen    => 5,  LocalAddr => 'localhost',
                                 LocalPort => 9000,  Proto     => 'tcp');
            while( my $s = $sock->accept ) {
                my $struct = Storable::fd_retrieve($s);
                #undef $main::klant;
                my $rrrnr= $struct->{Rijksreg_Nr};
                #print "\nontvangen - RRR = $rrrnr\n";
                Lid_Opname_Verzekering->ArgV_RijksRegister_Nummer($rrrnr);
                my $ontop= $main::agresso_instellingen->{plaats_mobicoon_on_top};
                my $test4 =system(1,"$ontop");
                print Dumper($struct);
               }
            #Lid_Opname_Verzekering->ArgV_RijksRegister_Nummer($ARGV[0]);
        }

     }
     sub gebruikersnaam {
          my $self = @_;
           my $name;
          $name = Win32::LoginName(); # or whatever function you'd like
          $name = lc($name);
          #print "gebruikersnaam = $name\n";
          return ($name) ;    
     }
     sub new {
         my $class;
         ($class,$externnummer,$ziekenfonds_nummer) = @_;
         undef $frame;
         undef $settings;
         @verzekeringen = ();
         undef %DATA;
         $cdata='';
         undef $klant;
         $total_ok =0;
         $total_nok=0;
         undef $verzekeringen_in_xml_org;
         undef @verzekeringen_in_xml=();
         undef $ApArGroup;
         $bestaande_klant =0;
         undef @contracts_brieven_check;
         undef $appdialog;
         undef $rijks_register_nummer;
         undef $dbh_agresso;
         undef $maak_brief::personen_zelfdeadres;
         undef $maak_brief::personen_zelfdedoss;
         $premie = 0;

         if ($externnummer =~ m/\d+/ and $ziekenfonds_nummer =~ m/\d+/) {
          
             #print "we zoeken niet op clipbord\n";
             #print "externnummer $externnummer voor spr\n";
             $externnummer = sprintf("%013s",$externnummer);
             #print "externnummer $externnummer na spr\n";
             $main::klant->{ExternNummer}=$externnummer;
             $ziekenfonds_nummer  = sprintf("%03d",$ziekenfonds_nummer);
             #$main::klant->{zkf_nr} =$ziekenfonds_nummer;
             #$main::klant->{Ziekenfonds} =$ziekenfonds_nummer;
             #print "externnummer $externnummer ziekenfonds_nummer $ziekenfonds_nummer \n";
            }else {
             zoek_extern_nr->clipboard;
             my $dialogtest=0;
             #print "externnummer $externnummer ziekenfonds_nummer $ziekenfonds_nummer \n";
             if ($externnummer !~ m/\d{13}/ or $ziekenfonds_nummer !~ m/\d{3}/) {
                 #print "match heeft niet gewerkt\n";
                 #print "externnummer $externnummer ziekenfonds_nummer $ziekenfonds_nummer \n";
                 $dialogtest=1;
                 $appdialog = AppDialog->new;
                 $appdialog->MainLoop;
                }
            }
         $settings=settings->new($ziekenfonds_nummer);
         main->zoek_verzekeringen($ziekenfonds_nummer);
         $main::klant->{Ziekenfonds} =$ziekenfonds_nummer;
         my $dbconnectie = connectdb->connect_as400 ($settings->{user_name},$settings->{password},$settings->{name_as400});
         $dbh_agresso = sql_toegang_agresso->setup_mssql_connectie($main::test_prod);
         $rijks_register_nummer = &checknaamextern($dbconnectie,$externnummer);
         if ($rijks_register_nummer eq 'nok') {
             undef $klant;
            }else {
             $rijks_register_nummer = sprintf("%011s",$rijks_register_nummer);
                my $bestaat_in_agresso = main->agresso_get_customer_info_rr_nr($rijks_register_nummer);
                $main::klant->{aansluit_datum_zkf}= main->aansluit_datum_zkf_externnr($dbconnectie,$ziekenfonds_nummer,$externnummer);
                my $gevonden = 'nok';
                if ($main::klant->{Agresso_nummer} ) {
                    $main::ApArGroup = $main::klant->{CustomerGroupID};
                    $bestaande_klant =1;
                    $gevonden = main->zoek_verzekerden ($dbconnectie,$ziekenfonds_nummer,$externnummer) ;#te traag maar nodig
                    $gevonden = 'ok';
                    #die if ($gevonden eq 'nok');

                   }else {
                    $main::ApArGroup = 2;
                    $gevonden = main->zoek_verzekerden ($dbconnectie,$ziekenfonds_nummer,$externnummer) ;#if ($zkf eq 'ZKF203')
                    #die if (gevonden eq 'nok');
                    my $is_ingezet = 'nok';
                    my $sleep_teller = 0;
                    while ($is_ingezet eq 'nok') {
                       sleep 5;
                       $is_ingezet = main->agresso_get_customer_info_rr_nr($rijks_register_nummer);
                       $sleep_teller += 5;
                       print "sleep_teller $sleep_teller\n";
                       if ($sleep_teller > 45) {
                          Wx::MessageBox( _T("Kan $rijks_register_nummer \n\nNiet inzetten\ncheck CS15 of RijksRegnr "),
                                    _T("Klant naar Agresso"),
                                     wxOK|wxCENTRE,
                                   $main::frame
                              );#cod
                          last;
                       }
                    }

                   }

                if ($gevonden eq 'ok') {
                     #forkfunc(\&child_func, $rijks_register_nummer) if ($bestaande_klant !=1);
                     main->zoek_contracten ($ziekenfonds_nummer,$externnummer)  ;
                     sql_toegang_agresso->afxvmobaandoen_get_rows($dbh_agresso,$main::klant->{Agresso_nummer});
                     sql_toegang_agresso->afxvmobziekten_get_rows($dbh_agresso,$main::klant->{Agresso_nummer});#code
                   }else {
                     undef $klant;
                   }
            }




         #foreach my $verz_naam (keys $verzekeringen_in_xml_org) {
         #    push (@verzekeringen_in_xml,$verz_naam);
         #}
         my $app = App->new();
         $app->MainLoop;

        }

     sub child_func {
         my $rijks_register_nummer1 = @_;
           print "child func -> rr $main::klant->{Rijksreg_Nr} ->argv0 $ARGV[0] $ARGV[1]\n";
           sleep 25;
         print "func voor $rijks_register_nummer1\n------------------------------------\n-----------------------------------\n";
         main->agresso_get_customer_info_rr_nr($main::klant->{Rijksreg_Nr});
         print "func na $rijks_register_nummer1\n\n------------------------------------\n-----------------------------------\n";
     }
     sub load_settings  {
         my ($class,$file_name) =  @_;
         print "$file_name ->";
         my $agresso_instellingen = XMLin("$file_name");
         print "ingelezen \n";
         return ($agresso_instellingen);
        }
    
   
    
    
   

 
     sub zoek_verzekeringen {
         my ($class,$zkf_nr) = @_;
         my $zkf = "ZKF$zkf_nr";
         foreach my $verzekerings_naam (keys $agresso_instellingen->{verzekeringen}->{$zkf}){
             my $verzekerings_nummer = $agresso_instellingen->{verzekeringen}->{$zkf}->{$verzekerings_naam};
             eval {$verzekerings_nummer = $agresso_instellingen->{verzekeringen}->{$zkf}->{$verzekerings_naam}->{$verzekerings_naam}};
             push (@verzekeringen,$verzekerings_nummer);
            }
         print "";
        }

     sub aansluit_datum_zkf_externnr {
      my ($self,$dbh,$zkf,$externr) =  @_;
      #print "";
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
      #openen van PFYSL8
      # EXIDL8 = extern nummer
      # KNRNL8 = nationaalt register nummer
      # NAMBL8 = naam van de gerechtigde
      # PRNBL8 = voornaam van de gerechtigde
      # SEXEL8 = code van het geslacht
      # NAIYL8 = geboortejaat
      # NAIML8 = geboortemaand
      # NAIJL8 = geboortedag
      my $sql = ("SELECT a.KNRNL8,b.ABADKK,b.ABEDKK FROM $settings->{'pers_fil'} a JOIN $settings->{'phoekk_fil'} b ON a.EXIDL8 = b.EXIDKK
                 WHERE a.EXIDL8=$externr and b.ABTVKK = 11 and b.ABOCKK =''");
      my $sth = $dbh->prepare( $sql );
      $sth->execute();
      my @aodatums =();
      my $datem = 19000101;
      while(@aodatums = $sth->fetchrow_array)  {
           #print "$zkf @aodatums\n";
           $datem = $aodatums[1];
        }

      if ($datem != 19000101) {
           return ($datem);
          }else {
           if ($zkf == 235) {
                $zkf =203;
            }else {
                $zkf =235;
            }
           my $settings1 = settings->new($zkf);
           my $dbh = connectdb->connect_as400 ($settings1->{user_name},$settings1->{password},$settings1->{name_as400});
           my $sql = ("SELECT a.KNRNL8,b.ABADKK FROM $settings1->{'pers_fil'} a JOIN $settings1->{'phoekk_fil'} b ON a.EXIDL8 = b.EXIDKK
                 WHERE a.EXIDL8=$externr and b.ABTVKK = 11 and b.ABOCKK =''");
           my $sth = $dbh->prepare( $sql );
           $sth->execute();
           my @aodatums =();
           while(@aodatums = $sth->fetchrow_array)  {
                #print "$zkf @aodatums\n";
                $datem = $aodatums[1];
               }
           return ($datem);
          }


}
     sub zoek_verzekerden {
         my $self = shift@_;
         my $dbh = shift @_;
         my $nrzkfcheck = shift @_;
         my $externnummer = shift @_;
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
         #26-28 and a.EXIDKK = $externnummer
         my $een_jaar_geleden = $vandaag -10000;
         my $twee_jaar_terug = $vandaag -20000;
         my $placeholders = join ",", (@verzekeringen);
         my $sqlmutuitdet =("SELECT DISTINCT a.EXIDKK,b.NAIYL8,b.NAIML8,b.NAIJL8,c.ABSTJR,c.ABNTJR,c.ABBTJR,c.ABPTJR,c.ABWTJR,c.IV00JR,c.ABGIJR,c.KGERJR,
                           a.ABNOKK,a.EXIDKK,b.KNRNL8,a.IDFDKK,a.ABTVKK,a.ABEDKK,a.ABOCKK,a.AB2OKK,a.ABFDKK,a.A140KK,a.ABACKK,a.AB2AKK,a.ABOCKK,a.AB2OKK,a.ABPEKK,
                           b.NAMBL8,b.PRNBL8,b.LANGL8,b.SEXEL8,c.ABGIJR,c.ABKTJR,c.ABTPJR,c.ABTEJR,c.PGSMJR,c.NGSMJR
                           FROM $settings->{'phoekk_fil'} a JOIN $settings->{'pers_fil'} b ON a.EXIDKK=b.EXIDL8 JOIN $settings->{'adres_fil'} c ON a.EXIDKK=EXIDJR
                           WHERE b.KNRNL8 != 0  and a.EXIDKK=$externnummer and IDFDKK = $nrzkfcheck   and ABEDKK > $een_jaar_geleden
                           and ABTVKK IN ($placeholders)
                           and (c.ABGIJR = (SELECT max( d.ABGIJR ) FROM $settings->{'adres_fil'} d  WHERE d.EXIDJR =a.EXIDKK)  )
                           ORDER BY a.EXIDKK,c.IV00JR,c.KGERJR,c.ABPTJR,c.ABNTJR,c.ABBTJR,b.NAIYL8,b.NAIML8,b.NAIJL8 ASC" );#and ABEDKK > $vandaag fetch first 10 rows only  ABOCKK  = '' bijgevoegd probleem circ cheque and ABADKK <= $vandaag
         #versie 1.8 and ABOCKK = '' de ontslagen ook  #and ABTVKK IN ($placeholders) zonder contract inzetten
        my $sthmutuitdet = $dbh->prepare( $sqlmutuitdet );
        $sthmutuitdet ->execute();
        my  $record_teller =0;
        my @agresso_klant =();
        my $klantteller = 0;
        my $oud_exid = 0;
        my $blok_grootte = $agresso_instellingen->{blok_grootte};
        my $blok_teller = 0;
        my $aantal_blokken = 0;
        while(@agresso_klant =$sthmutuitdet->fetchrow_array)  {
            #@ext_nr=&checknaamextern ($agresso_klant[1]);
            foreach my $element (@agresso_klant) { #verwijder de leading en trailing spaces
                $element =~ s/^\s+//;
                $element =~ s/\s+$//;
               }
            if ($blok_teller ==$blok_grootte  ) {  #versie 1.4
                 $aantal_blokken +=1;
                 &maak_xml_file ($nrzkfcheck,$aantal_blokken);
                 #my $datestring = localtime();
                 #print "\n479 voor verander Local date and time $datestring\n_______________\n";
                 &verander_xml_file($nrzkfcheck,$aantal_blokken);
                 #$datestring = localtime();
                 #print "\n482 voor webserv Local date and time $datestring\n_______________\n";
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
                $main::klant->{Agresso_nummer} = $ApArNo;
                my $dossier_nr = $agresso_klant[12];
                my $verzek_nr =  $agresso_klant[16];
                my $Address ='';
                my $Name = "$agresso_klant[28] $agresso_klant[27]";
                $main::klant->{naam} =$Name ;
                $Name = unidecode ($Name); #versie 1.8 umlaut weg
                my $ExternalRef = sprintf("%011s",$agresso_klant[14]);
                $main::klant->{Rijksreg_Nr}=$ExternalRef ;
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
                   }elsif ($CountryCode eq 'EAU' or $CountryCode eq 'eau'){
                        $CountryCode = 'AE';
                   }elsif ($CountryCode eq 'RUS' or $CountryCode eq 'rus'){
                     $CountryCode = 'RU';
                   }elsif ($CountryCode eq 'COR' or $CountryCode eq 'cor'){
                     $CountryCode = 'CR';
                   }elsif ($CountryCode eq 'BRE' or $CountryCode eq 'bre'){
                     $CountryCode = 'BE';
                   }elsif ($CountryCode eq 'QAT' or $CountryCode eq 'qat'){
                     $CountryCode = 'QA';
                   }elsif ($CountryCode eq 'SUR' or $CountryCode eq 'sur'){
                     $CountryCode = 'SR';
                   }elsif ($CountryCode eq 'SLO' or $CountryCode eq 'slo'){
                     $CountryCode = 'SL';
                   }elsif ($CountryCode eq 'FIN' or $CountryCode eq 'fin'){
                     $CountryCode = 'FI';
                   }elsif ($CountryCode eq 'OUG' or $CountryCode eq 'oug'){
                     $CountryCode = 'UG';
                   }elsif ($CountryCode eq 'LIT' or $CountryCode eq 'lit'){
                     $CountryCode = 'LT';                   
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
                       }elsif ($CountryCode eq 'COR' or $CountryCode eq 'cor'){
                         $CountryCode = 'CR';
                       }elsif ($CountryCode eq 'BRE' or $CountryCode eq 'bre'){
                         $CountryCode = 'BE';
                       }elsif ($CountryCode eq 'QAT' or $CountryCode eq 'qat'){
                         $CountryCode = 'QA';
                       }elsif ($CountryCode eq 'SUR' or $CountryCode eq 'sur'){
                         $CountryCode = 'SR';
                       }elsif ($CountryCode eq 'SLO' or $CountryCode eq 'slo'){
                         $CountryCode = 'SL';
                       }elsif ($CountryCode eq 'FIN' or $CountryCode eq 'fin'){
                         $CountryCode = 'FI';
                       }elsif ($CountryCode eq 'OUG' or $CountryCode eq 'oug'){
                         $CountryCode = 'UG';
                       }elsif ($CountryCode eq 'LIT' or $CountryCode eq 'lit'){
                         $CountryCode = 'LT';
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
                   }
                $adres_onderdeel ='';
                }
                #aanmaken  SupplierCustomer
                my $SupplierCustomer_onderdeel ;
                if (1==1) {
                if (!defined $Swift or $Swift eq '') {
                    $Swift=&bic_via_webserv_client($IBAN,$dbh);
                   }

                $Swift =~ s/\s//g;
                $SupplierCustomer_onderdeel = {
                    UpdateFlag => 0,
                    Name =>$Name,
                    ApArGroup => $main::ApArGroup,
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
                $masterfile_onderdeel{CompanyCode}='VMOB';
                $masterfile_onderdeel{ApArType} ='R';
                $masterfile_onderdeel{ApArNo} = $ApArNo;
                #print "";
                push (@{$DATA{MasterFile}},{%masterfile_onderdeel});
                #print"";
                $klantteller +=1;
               }

          }
         if  ($klantteller == 0) {
              my $sqlmutuitdet =("SELECT DISTINCT a.EXIDKK,b.NAIYL8,b.NAIML8,b.NAIJL8,c.ABSTJR,c.ABNTJR,c.ABBTJR,c.ABPTJR,c.ABWTJR,c.IV00JR,c.ABGIJR,c.KGERJR,
                           a.ABNOKK,a.EXIDKK,b.KNRNL8,a.IDFDKK,a.ABTVKK,a.ABEDKK,a.ABOCKK,a.AB2OKK,a.ABFDKK,a.A140KK,a.ABACKK,a.AB2AKK,a.ABOCKK,a.AB2OKK,a.ABPEKK,
                           b.NAMBL8,b.PRNBL8,b.LANGL8,b.SEXEL8,c.ABGIJR,c.ABKTJR,c.ABTPJR,c.ABTEJR,c.PGSMJR,c.NGSMJR
                           FROM $settings->{'phoekk_fil'} a JOIN $settings->{'pers_fil'} b ON a.EXIDKK=b.EXIDL8 JOIN $settings->{'adres_fil'} c ON a.EXIDKK=EXIDJR
                           WHERE b.KNRNL8 != 0  and a.EXIDKK=$externnummer and IDFDKK = $nrzkfcheck  and ABEDKK > $twee_jaar_terug
                           and (c.ABGIJR = (SELECT max( d.ABGIJR ) FROM $settings->{'adres_fil'} d  WHERE d.EXIDJR =a.EXIDKK)  )
                           ORDER BY a.EXIDKK,c.IV00JR,c.KGERJR,c.ABPTJR,c.ABNTJR,c.ABBTJR,b.NAIYL8,b.NAIML8,b.NAIJL8 ASC" );#and ABEDKK > $vandaag fetch first 10 rows only  ABOCKK  = '' bijgevoegd probleem circ cheque and ABADKK <= $vandaag
                    #versie 1.8 and ABOCKK = '' de ontslagen ook  #and ABTVKK IN ($placeholders) zonder contract inzetten and ABEDKK > $een_jaar_geleden
                   my $sthmutuitdet = $dbh->prepare( $sqlmutuitdet );
                   $sthmutuitdet ->execute();
                   my  $record_teller =0;
                   my @agresso_klant =();
                   my $klantteller = 0;
                   my $oud_exid = 0;
                   my $blok_grootte = $agresso_instellingen->{blok_grootte};
                   my $blok_teller = 0;
                   my $aantal_blokken = 0;
                   while(@agresso_klant =$sthmutuitdet->fetchrow_array)  {
                       #@ext_nr=&checknaamextern ($agresso_klant[1]);
                       foreach my $element (@agresso_klant) { #verwijder de leading en trailing spaces
                           $element =~ s/^\s+//;
                           $element =~ s/\s+$//;
                          }
                       if ($blok_teller ==$blok_grootte  ) {  #versie 1.4
                            $aantal_blokken +=1;
                            &maak_xml_file ($nrzkfcheck,$aantal_blokken);
                            #my $datestring = localtime();
                            #print "\n873 voor verander Local date and time $datestring\n_______________\n";
                            &verander_xml_file($nrzkfcheck,$aantal_blokken);
                            #my $datestring = localtime();
                            #print "\n876 voor webserv Local date and time $datestring\n_______________\n";
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
                           $main::klant->{Agresso_nummer} = $ApArNo;
                           my $dossier_nr = $agresso_klant[12];
                           my $verzek_nr =  $agresso_klant[16];
                           my $Address ='';
                           my $Name = "$agresso_klant[28] $agresso_klant[27]";
                           $main::klant->{naam} =$Name ;
                           $Name = unidecode ($Name); #versie 1.8 umlaut weg
                           my $ExternalRef = sprintf("%011s",$agresso_klant[14]);
                           $main::klant->{Rijksreg_Nr}=$ExternalRef ;
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
                              }elsif ($CountryCode eq 'EAU' or $CountryCode eq 'eau'){
                                   $CountryCode = 'AE';
                              }elsif ($CountryCode eq 'RUS' or $CountryCode eq 'rus'){
                                    $CountryCode = 'RU';
                              }elsif ($CountryCode eq 'COR' or $CountryCode eq 'cor'){
                                    $CountryCode = 'CR';
                              }elsif ($CountryCode eq 'BRE' or $CountryCode eq 'bre'){
                                   $CountryCode = 'BE';
                              }elsif ($CountryCode eq 'QAT' or $CountryCode eq 'qat'){
                                   $CountryCode = 'QA';
                              }elsif ($CountryCode eq 'SUR' or $CountryCode eq 'sur'){
                                   $CountryCode = 'SR';
                              }elsif ($CountryCode eq 'SLO' or $CountryCode eq 'slo'){
                                   $CountryCode = 'SL';
                              }elsif ($CountryCode eq 'FIN' or $CountryCode eq 'fin'){
                                   $CountryCode = 'FI';
                              }elsif ($CountryCode eq 'OUG' or $CountryCode eq 'oug'){
                                   $CountryCode = 'UG';
                              }elsif ($CountryCode eq 'LIT' or $CountryCode eq 'lit'){
                                   $CountryCode = 'LT';
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
                                  }elsif ($CountryCode eq 'COR' or $CountryCode eq 'cor'){
                                        $CountryCode = 'CR';
                                  }elsif ($CountryCode eq 'BRE' or $CountryCode eq 'bre'){
                                        $CountryCode = 'BE';
                                   }elsif ($CountryCode eq 'QAT' or $CountryCode eq 'qat'){
                                        $CountryCode = 'QA';
                                   }elsif ($CountryCode eq 'SUR' or $CountryCode eq 'sur'){
                                        $CountryCode = 'SR';
                                   }elsif ($CountryCode eq 'SLO' or $CountryCode eq 'slo'){
                                        $CountryCode = 'SL';
                                   }elsif ($CountryCode eq 'FIN' or $CountryCode eq 'fin'){
                                        $CountryCode = 'FI';
                                   }elsif ($CountryCode eq 'OUG' or $CountryCode eq 'oug'){
                                        $CountryCode = 'UG';
                                   }elsif ($CountryCode eq 'LIT' or $CountryCode eq 'lit'){
                                        $CountryCode = 'LT';
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
                              }
                           $adres_onderdeel ='';
                           }
                           #aanmaken  SupplierCustomer
                           my $SupplierCustomer_onderdeel ;
                           if (1==1) {
                           if (!defined $Swift or $Swift eq '') {
                               $Swift=&bic_via_webserv_client($IBAN,$dbh);
                              }

                           $Swift =~ s/\s//g;
                           $SupplierCustomer_onderdeel = {
                               UpdateFlag => 0,
                               Name =>$Name,
                               ApArGroup => $main::ApArGroup,
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
                           $masterfile_onderdeel{CompanyCode}='VMOB';
                           $masterfile_onderdeel{ApArType} ='R';
                           $masterfile_onderdeel{ApArNo} = $ApArNo;
                           #print "";
                           push (@{$DATA{MasterFile}},{%masterfile_onderdeel});
                           #print"";
                           $klantteller +=1;
                          }
                      }
         }
         if (!%DATA) {
              Wx::MessageBox( _T("Deze Persoon is geen lid!"),
                 _T("Persoon opzoeken"),
                 wxOK|wxCENTRE,
                 $main::frame
               );#code
              #die;
              return ('nok')
         }else {
             $aantal_blokken +=1;
             &maak_xml_file ($nrzkfcheck,$aantal_blokken);
             #my $datestring = localtime();
             #print "\1251 voor verander Local date and time $datestring\n_______________\n";
             &verander_xml_file($nrzkfcheck,$aantal_blokken);
             #$datestring = localtime();
             #print "\n154 voor verander Local date and time $datestring\n_______________\n";
             &send_via_webserv_client($nrzkfcheck,$aantal_blokken);
             return ('ok');
         }



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
                                                  FROM $settings->{'adres_fil'} WHERE EXIDJR= $extern_nummer and IDFDJR = $zkf_nummer and ABGIJR = '01'");
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
            my $heeft_nr =$dbh->selectrow_array("SELECT AGRESONR FROM $settings->{'ascard_fil'} WHERE KNRN52 =$rr_nr");
            if (defined $heeft_nr) {
                #print "$heeft_nr bestaat \n";
                return ($heeft_nr);#code
            }else {
                my $AGRESONR = $dbh->selectrow_array("SELECT MAX(AGRESONR) FROM $settings->{'ascard_fil'}");
                $AGRESONR = 100000 if(!defined $AGRESONR) ;
                $AGRESONR +=1;
                my $zetin = "INSERT INTO $settings->{'ascard_fil'} values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
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
            my $emailadressenselect = ("SELECT IDFDVL,ABVDVL,ABTDVL,EXIDVL,AJW1VL,AJW2VL FROM $settings->{'email_fil'}  WHERE IDFDVL = $nrzkfcheck and ABVDVL !> $vandaag_dag and ABTDVL !< $vandaag_dag and AJW2VL != '' and EXIDVL = $externnummer ");
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
            my $sql =("SELECT ABNOKK,ABTVKK FROM $settings->{'phoekk_fil'} WHERE EXIDKK = $extern_nummer and ABOCKK = '' ");
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
             #@rek= $dbh->selectrow_array("SELECT SR93KW,CPETKW,ABRCKW  FROM $settings->{'prek_fil'} WHERE ABNOKW  = $dossiernr and ABTDKW  =  99999999 and ABTVKW = $verz");
             $sql =("SELECT SR93KW,CPETKW,ABRCKW,ADBRKW  FROM $settings->{'prek_fil'} WHERE ABNOKW  = $dossiernr and ABTDKW  =  99999999 and ABTVKW = $verz ORDER BY ADBRKW DESC ");
             $sth = $dbh->prepare( $sql );
             $sth ->execute();
             while(my @rek_voorlopig =$sth->fetchrow_array)  {
                  foreach my $element (@rek_voorlopig) { #verwijder de leading en trailing spaces
                       $element =~ s/^\s+//;
                       $element =~ s/\s+$//;
                      }
                  print "rek_voorlopig @rek_voorlopig\n";
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
                 print "rek @rek\n" ;
             if ($rek[1] eq 'BE18990000000065' or $rek[1] eq 'BE00990000000065' or !defined $rek[1]) {
                  #print "$rek[1] -> nemen verzekering 1\n";
                  #@rek= $dbh->selectrow_array("SELECT SR93KW,CPETKW,ABRCKW  FROM $settings->{'prek_fil'} WHERE ABNOKW  = $dossiernr and ABTDKW  =  99999999 and ABTVKW = 1");#code
                   $sql =("SELECT SR93KW,CPETKW,ABRCKW,ADBRKW  FROM $settings->{'prek_fil'} WHERE ABNOKW  = $dossiernr and ABTDKW  =  99999999 and ABTVKW = 1 ORDER BY ADBRKW DESC ");
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
                  print "rek 1 @rek\n";
                  if (!defined $rek[1] or $rek[1] eq 'BE18990000000065' or $rek[1] eq 'BE00990000000065') {
                       #print " kan geen rekening vinden 1 -> @rek\n";
                       my $dossier = as400_gegevens->zoekdossier($dbh,$extern_nummer);
                       #print "dossier  $dossier\n";
                       if ($dossier) {
                            #@rek= $dbh->selectrow_array("SELECT SR93KW,CPETKW,ABRCKW  FROM $settings->{'prek_fil'} WHERE ABNOKW  = $dossier and ABTDKW  =  99999999 and ABTVKW = 1");#code
                            $sql =("SELECT SR93KW,CPETKW,ABRCKW,ADBRKW  FROM $settings->{'prek_fil'} WHERE ABNOKW  = $dossier and ABTDKW  =  99999999 and ABTVKW = 1 ORDER BY ADBRKW DESC ");
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
            unlink $xml_file ;
            $doc->setDocumentElement($xml);
            open XMLFILE,"> $xml_file" or die "can not open file $xml_file ";
            select XMLFILE;
            print $doc->toString(1); # 1 indicates "pretty print"
            close XMLFILE;
            select STDOUT;
            undef %DATA;
            #print "";
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
            use SOAP::Lite #;
            trace => [ transport => sub { print $_[0]->as_string } ];
            use XML::Compile::SOAP12::Client;
            use XML::Writer;
            use XML::Writer::String;
            $ENV{HTTPS_DEBUG} = 0;
            $ENV{HTTP_DEBUG} = 0;
            my $serverProcessId = 'CS15';
            my $menuId = 'BI192';
            #my $variant = 7;  #oud 7 10 is voor test
            my $variant = 7;
            #$variant = $main::variant_LG04;
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
            my $ip = $main::agresso_instellingen->{"Agresso_IP_$main::test_prod"};;      
            my $soap = SOAP::Lite           
            #productie http://S200WP1XXL01.mutworld.be/BusinessWorld-webservices/service.svc?ImportService/ImportV200606
            -> proxy("http://$ip/service.svc?ImportService/ImportV200606")          
            ->ns('http://services.agresso.com/ImportService/ImportV200606','imp')
            ->on_action( sub { return 'ExecuteServerProcessAsynchronously' } );
               #my $datestring = localtime();
               #print "1624 voor response Local date and time $datestring\n";
            my $response = $soap->ExecuteServerProcessAsynchronously($Input,$Credentials);
               #$datestring = localtime();
               #print "1627 na resopnse Local date and time $datestring\n";
            #die;
            my $antwoord ='';
            my $ordernr = $response->{_content}[4]->{Body}->{ExecuteServerProcessAsynchronouslyResponse}
            ->{ExecuteServerProcessAsynchronouslyResult}->{OrderNumber};
            my $fault = $response->{_content}[4]->{Body}->{Fault}->{faultstring};
            if ($ordernr =~ m/\d+/) {
                $antwoord ="OK odernr = $ordernr";#code
            }else {
                $antwoord ="ERROR !! -> $fault";
            }

            print "$antwoord\n \n";
            return($antwoord);
        }
     sub variant_LG04 {
           my ($self,$user) = @_;
           use SOAP::Lite ;
            #+trace => [ transport => sub { print $_[0]->as_string } ];
           #+trace => [ transport => sub { print $_[0]->as_string } ];
            my $ip = $main::agresso_instellingen->{"Agresso_IP_$main::test_prod"};;
            my $proxy = "http://$ip/service.svc?QueryEngineService/QueryEngineV201101";  
            my $uri   = 'http://services.agresso.com/QueryEngineService/QueryEngineV201101';
            my $soap = SOAP::Lite
             ->proxy($proxy)
             ->ns($uri,'query')
             ->on_action( sub { return 'GetTemplateResultAsDataSet' } );    
            my $template    = SOAP::Data->name('query:TemplateId' => "4658")->type(''); #prod
            my $pipeline    = SOAP::Data->name('query:PipelineAssociatedName' => "false")->type('');
            my $ColumnName  = SOAP::Data->name('query:ColumnName'=> "att_value")->type('');
            my $RestrictionType= SOAP::Data->name('query:RestrictionType' => "=")->type('');
            my $FromValue = SOAP::Data->name('query:FromValue' => "$user")->type('');
            my $ToValue = SOAP::Data->name('query:ToValue' => "$user")->type('');
            my $DataType = SOAP::Data->name('query:DataType' => "10")->type('');
            my $DataLength = SOAP::Data->name('query:DataLength' => "25")->type('');
            my $DataCase = SOAP::Data->name('query:DataCase' => "2")->type('');
            my $IsParameter = SOAP::Data->name('query:IsParameter' => "true")->type('');
            my $IsVisible =SOAP::Data->name('query:IsVisible' => "true")->type('');
            my $IsPrompt =SOAP::Data->name('query:IsPrompt' => "true")->type('');
            my $IsMandatory =SOAP::Data->name('query:IsMandatory' => "true")->type('');
            my $CanBeOverridden =SOAP::Data->name('query:CanBeOverridden' => "true")->type('');
            #/query:SearchCriteriaProperties>
            my $SearchCriteriaProperties = SOAP::Data->name('query:SearchCriteriaProperties')           
                 ->value(\SOAP::Data->value($ColumnName, $RestrictionType,$FromValue,$ToValue,$DataType,$DataLength
                                     ,$DataCase,$IsParameter,$IsVisible,$IsPrompt,$IsMandatory,$CanBeOverridden));
            my $SearchCriteriaPropertiesList=  SOAP::Data->name('query:SearchCriteriaPropertiesList')
                    ->value(\SOAP::Data->value($SearchCriteriaProperties));     
            my $input       = SOAP::Data->name('query:input') ->value(\SOAP::Data->value($template, $pipeline,$SearchCriteriaPropertiesList));
            my $Username    = SOAP::Data->name('query:Username' => 'WEBSERV')->type('');
            my $Client      = SOAP::Data->name('query:Client'   => 'VMOB')->type('');
            my $Password    = SOAP::Data->name('query:Password' => 'WEBSERV')->type('');
            my $credentials = SOAP::Data->name('query:credentials') ->value(\SOAP::Data->value($Username, $Client, $Password));
            my $response = $soap->mySOAPFunction($input,$credentials);
            my $resultaten;
            eval {my $returncode =$response->{_content}[2][0][2][0][4]->{GetTemplateResultAsDataSetResult}->{ReturnCode}};
            if ($response->{_content}[2][0][2][0][4]->{GetTemplateResultAsDataSetResult}->{ReturnCode}==0 and !$@) {
                 eval {my $antwoord_niet_leeg = $response->{_content}[2][0][2][0][4]->{GetTemplateResultAsDataSetResult}->{TemplateResult}->{diffgram}->{Agresso}->{AgressoQE}};
                 if ($@) {
                     #leeg antwoord
                    }else {
                     my $link = $response->{_content}[2][0][2][0][4]->{GetTemplateResultAsDataSetResult}->{TemplateResult}->{diffgram}->{Agresso}->{AgressoQE};
                     eval {$resultaten = $link->{rel_value}};
                     if ($@) {
                          #geen nomenclaturen
                         }else {
                           $resultaten = $link->{rel_value}
                         }
                    }
         
               }
            return($resultaten);
         
          }
     sub zoek_contracten {
            my ($self,$zkf,$externnummer) = @_;
            my $jaar = substr ($vandaag,0,4);
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
             # ext nr =0200085650058
             #&settings (235);
             # my $dbh = connectdb->connect_as400 ($settings->{user_name},$settings->{password},$settings->{name_as400});
             # my $sql =("SELECT * FROM $settings->{'phoekk_fil'} WHERE EXIDKK = 0200085650058");
             # my $sth = $dbh->prepare( $sql );
             # $sth ->execute();
             # while(my @agresso_klant = $sth->fetchrow_array)  {
             #      print "@agresso_klant\n";
             #    }
             my $zkf_naam ="ZKF$zkf";
             print "$settings->{name_as400}\n";
             my $dbh = connectdb->connect_as400 ($settings->{user_name},$settings->{password},$settings->{name_as400});
             my $placeholders = join ",", (@verzekeringen);
             my $sql =("SELECT a.AGRESONR,a.KNRN52,a.ZKF,c.EXIDL8,
                           b.ABTVKK,b.ABPRKK,b.ABADKK,b.ABPEKK,b.ABEDKK,b.ABNOKK,a.ZKF,b.ABACKK,b.AB2AKK,b.ABOCKK,b.AB2OKK
                           FROM $settings->{'ascard_fil'} a
                           JOIN $settings->{'pers_fil'} c ON a.KNRN52 = c.KNRNL8
                           JOIN $settings->{'phoekk_fil'}  b ON c.EXIDL8=b.EXIDKK
                           WHERE b.ABTVKK IN ($placeholders) and b.EXIDKK = $externnummer
                           ORDER BY b.ABEDKK DESC" );#fetch first 10 rows only
            my $sth = $dbh->prepare( $sql );
            $sth ->execute();
            my  $record_teller =0;
            my $oud_agresso_nr =0;
            my @agresso_klant =();
            my $xml ='';
            my $ver_teller =0;
            #my $kltest = $main::klant;            
            #foreach my $key (keys $main::klant->{contracten}) {
            #     $main::klant->{contracten}->[$key]->{naam} ='';
            #     $main::klant->{contracten}->[$key]->{zkf_nr}= '';
            #     $main::klant->{contracten}->[$key]->{startdatum} = '';
            #     $main::klant->{contracten}->[$key]->{wachtdatum} = '';
            #     $main::klant->{contracten}->[$key]->{einddatum}= '';
            #     $main::klant->{contracten}->[$key]->{zkf_nr}= '';
            #    }
          #  my $is_er_een_geldig_contract= 0;
          #while(@agresso_klant =$sth->fetchrow_array)  {
          #       $is_er_een_geldig_contract= 1 if ($agresso_klant[8] >= $vandaag);
          #     }
         
            while(@agresso_klant =$sth->fetchrow_array)  {
                print "@agresso_klant\n";
                my $naam= &zoek_naam_verzekering($agresso_klant[4],$agresso_klant[5],$zkf_naam);
                my $NAAM= uc $naam;
                $NAAM =~ s/\s//g;
                #$main::verzekeringen_in_xml_org->{$NAAM}= 'yes';
                $main::klant->{contracten}->[$ver_teller]->{naam} =$NAAM;
                $main::klant->{contracten}->[$ver_teller]->{zkf_nr}= $zkf_naam;
                push (@main::verzekeringen_in_xml,$NAAM) if !($NAAM ~~ @main::verzekeringen_in_xml);
                my $start_jaar= substr($agresso_klant[6],0,4);
                my $start_maand= substr($agresso_klant[6],4,2);
                my $start_dag= substr($agresso_klant[6],6,2);
                my $agresso_start_datum = "$start_dag-$start_maand-$start_jaar";
                $main::klant->{contracten}->[$ver_teller]->{startdatum} =$agresso_start_datum;
                my $wacht_jaar= substr($agresso_klant[7],0,4);
                my $wacht_maand= substr($agresso_klant[7],4,2);
                my $wacht_dag= substr($agresso_klant[7],6,2);
                my $agresso_wacht_datum = "$wacht_dag-$wacht_maand-$wacht_jaar";
                $main::klant->{contracten}->[$ver_teller]->{wachtdatum} =$agresso_wacht_datum;
                $agresso_klant[8] = 20991231 if ($agresso_klant[8] > 50000000);
                my $eind_jaar= substr($agresso_klant[8],0,4);
                my $eind_maand= substr($agresso_klant[8],4,2);
                my $eind_dag= substr($agresso_klant[8],6,2);
                my $agresso_eind_datum = "$eind_dag-$eind_maand-$eind_jaar";
                $main::klant->{contracten}->[$ver_teller]->{einddatum}=$agresso_eind_datum ;
                my $info = ''; #&zoek_info($agresso_klant[1],$agresso_klant[4]);oud
                my $aansluitingscode= "$agresso_klant[11]$agresso_klant[12]";
                my $ontslagcode= "$agresso_klant[13]$agresso_klant[14]";
                $aansluitingscode =~ s/^\s+//;
                $aansluitingscode =~ s/\s+$//;
                $ontslagcode =~ s/^\s+//;
                $ontslagcode =~ s/\s+$//;
                $ver_teller +=1;
                if ($oud_agresso_nr != $agresso_klant[0] ) {
                    if ($xml ne '') {
                        $xml = $xml."</cus:FlexiFieldRowList></cus:FlexiGroupUnitType></cus:flexiGroupList>
                             <cus:includeDataInResponse>1</cus:includeDataInResponse>
                             <cus:credentials>
                                <cus:Username>WEBSERV</cus:Username>
                                <cus:Client>VMOB</cus:Client>
                                <cus:Password>WEBSERV</cus:Password>
                             </cus:credentials>";
                        $xml =" <cus:company>VMOB</cus:company>
                            <cus:customerId>$oud_agresso_nr</cus:customerId>
                            <cus:flexiGroupList><cus:FlexiGroupUnitType>
                            <cus:FlexiGroup>VMOBCONTRACT</cus:FlexiGroup>
                            <cus:FlexiFieldRowList>".$xml;
                        my $bestaande_rij =0;
                        &delete_contracten($oud_agresso_nr);
                        my ($returncode,$ReturnText)= &insert_contracten($xml) ;
                        while ($ReturnText =~ m/Save Failed/) {
                            $xml = &change_row_numbers ($record_teller,$bestaande_rij,$xml);
                            $bestaande_rij +=1;
                            ($returncode,$ReturnText)= &insert_contracten($xml);
                             $ReturnText = 'teveel gprobeerd' if ($bestaande_rij >15);
                             print "contract-> $oud_agresso_nr ->bestaande_rij $bestaande_rij\n";
                           }
                        if ($returncode == 0) {
                            $total_ok +=1;
                            print  "contract-> $oud_agresso_nr  ->$ReturnText\n";
                           }else {
                            $total_nok +=1;
                            print  "contract-> $oud_agresso_nr->$ReturnText\n";
                           }
                       }
                    $oud_agresso_nr = $agresso_klant[0] ;
                    $xml ='';
                    $record_teller =0;#code
                    $xml = $xml."<cus:FlexiRowUnitType>
                            <cus:RowNo>$record_teller</cus:RowNo>
                            <cus:FlexiFieldList>
                                <cus:FlexiFieldUnitType>
                                    <cus:ColumnName>product</cus:ColumnName>
                                    <cus:Value>$naam</cus:Value>
                                </cus:FlexiFieldUnitType>
                                <cus:FlexiFieldUnitType>
                                    <cus:ColumnName>startdatum</cus:ColumnName>
                                    <cus:Value>$agresso_start_datum</cus:Value>
                                </cus:FlexiFieldUnitType>
                                <cus:FlexiFieldUnitType>
                                    <cus:ColumnName>wachtdatum</cus:ColumnName>
                                    <cus:Value>$agresso_wacht_datum</cus:Value>
                                </cus:FlexiFieldUnitType>
                                <cus:FlexiFieldUnitType>
                                    <cus:ColumnName>einddatum</cus:ColumnName>
                                    <cus:Value>$agresso_eind_datum</cus:Value>
                                </cus:FlexiFieldUnitType>
                                <cus:FlexiFieldUnitType>
                                    <cus:ColumnName>contract_nr</cus:ColumnName>
                                    <cus:Value>$agresso_klant[9]</cus:Value>
                                </cus:FlexiFieldUnitType>
                                <cus:FlexiFieldUnitType>
                                    <cus:ColumnName>zkf_nr</cus:ColumnName>
                                    <cus:Value>$zkf</cus:Value>
                                </cus:FlexiFieldUnitType>
                                <cus:FlexiFieldUnitType>
                                    <cus:ColumnName>info</cus:ColumnName>
                                    <cus:Value>$info</cus:Value>
                                </cus:FlexiFieldUnitType>
                                <cus:FlexiFieldUnitType>
                                    <cus:ColumnName>aansluitingscode_fx</cus:ColumnName>
                                    <cus:Value>$aansluitingscode</cus:Value>
                                </cus:FlexiFieldUnitType>
                                <cus:FlexiFieldUnitType>
                                   <cus:ColumnName>ontslagcode_fx</cus:ColumnName>
                                   <cus:Value>$ontslagcode</cus:Value>
                                </cus:FlexiFieldUnitType>
                            </cus:FlexiFieldList>
                             </cus:FlexiRowUnitType>";
                    $record_teller +=1;
                   }else {
                    $xml = $xml."<cus:FlexiRowUnitType>
                            <cus:RowNo>$record_teller</cus:RowNo>
                            <cus:FlexiFieldList>
                                <cus:FlexiFieldUnitType>
                                    <cus:ColumnName>product</cus:ColumnName>
                                    <cus:Value>$naam</cus:Value>
                                </cus:FlexiFieldUnitType>
                                <cus:FlexiFieldUnitType>
                                    <cus:ColumnName>startdatum</cus:ColumnName>
                                    <cus:Value>$agresso_start_datum</cus:Value>
                                </cus:FlexiFieldUnitType>
                                <cus:FlexiFieldUnitType>
                                    <cus:ColumnName>wachtdatum</cus:ColumnName>
                                    <cus:Value>$agresso_wacht_datum</cus:Value>
                                </cus:FlexiFieldUnitType>
                                <cus:FlexiFieldUnitType>
                                    <cus:ColumnName>einddatum</cus:ColumnName>
                                    <cus:Value>$agresso_eind_datum</cus:Value>
                                </cus:FlexiFieldUnitType>
                                <cus:FlexiFieldUnitType>
                                    <cus:ColumnName>contract_nr</cus:ColumnName>
                                    <cus:Value>$agresso_klant[9]</cus:Value>
                                </cus:FlexiFieldUnitType>
                                <cus:FlexiFieldUnitType>
                                    <cus:ColumnName>zkf_nr</cus:ColumnName>
                                    <cus:Value>$zkf</cus:Value>
                                </cus:FlexiFieldUnitType>
                                <cus:FlexiFieldUnitType>
                                    <cus:ColumnName>info</cus:ColumnName>
                                    <cus:Value>$info</cus:Value>
                                </cus:FlexiFieldUnitType>
                                <cus:FlexiFieldUnitType>
                                    <cus:ColumnName>aansluitingscode_fx</cus:ColumnName>
                                    <cus:Value>$aansluitingscode</cus:Value>
                                </cus:FlexiFieldUnitType>
                                     <cus:FlexiFieldUnitType>
                                     <cus:ColumnName>ontslagcode_fx</cus:ColumnName>
                                     <cus:Value>$ontslagcode</cus:Value>
                                </cus:FlexiFieldUnitType>
                            </cus:FlexiFieldList>
                             </cus:FlexiRowUnitType>";
                    $record_teller +=1;
                   }

               }
             if ($xml ne '') {
                $xml = $xml."</cus:FlexiFieldRowList></cus:FlexiGroupUnitType></cus:flexiGroupList>
                             <cus:includeDataInResponse>1</cus:includeDataInResponse>
                             <cus:credentials>
                                <cus:Username>WEBSERV</cus:Username>
                                <cus:Client>VMOB</cus:Client>
                                <cus:Password>WEBSERV</cus:Password>
                             </cus:credentials>";
                $xml =" <cus:company>VMOB</cus:company>
                            <cus:customerId>$oud_agresso_nr</cus:customerId>
                            <cus:flexiGroupList><cus:FlexiGroupUnitType>
                            <cus:FlexiGroup>VMOBCONTRACT</cus:FlexiGroup>
                            <cus:FlexiFieldRowList>".$xml;
                my $bestaande_rij =0;
                &delete_contracten($oud_agresso_nr);
                my ($returncode,$ReturnText)= &insert_contracten($xml) ;
                print "\n\nreturncode  $returncode, ReturnText,$ReturnText\n$xml\n\n";
                while ($ReturnText =~ m/Save Failed/) {
                    $xml = &change_row_numbers ($record_teller,$bestaande_rij,$xml);
                    $bestaande_rij +=1;
                    ($returncode,$ReturnText)= &insert_contracten($xml);
                     $ReturnText = 'teveel gprobeerd' if ($bestaande_rij >15);
                     print "contract-> $oud_agresso_nr ->bestaande_rij $bestaande_rij\n";
                   }
                 if ($returncode == 0) {
                        $total_ok +=1;
                        print  "contract-> $oud_agresso_nr  ->$ReturnText\n";
                    }else {
                        $total_nok +=1;
                        print  "contract->$oud_agresso_nr  ->$ReturnText\n";
                    }
               }

            my $totaal = $total_ok + $total_nok ;
            print "We hebben in het totaal voor $totaal klanten contracten ingezet.\nVoor $total_ok klanten is dat gelukt.\nVoor $total_nok klanten is dat niet gelukt\n" ;
            print '';
          
           }
     sub change_row_numbers {
            my $record_teller = shift @_;
            my $start_row = shift @_;
            my $xml = shift @_;
            my $teller = 0;
            my $oude_rij =0;
            my $nieuwe_teller;
            while ($teller < $record_teller) {
                $nieuwe_teller= $teller+$start_row+1;
                $oude_rij = $teller+$start_row;
                my $vervangstring = "<cus:RowNo>$nieuwe_teller</cus:RowNo>";
                my $teststring ="<cus:RowNo>$oude_rij</cus:RowNo>";
                $xml =~ s/$teststring/$vervangstring/;
                $teller +=1;
               }
            return ($xml);
        }
     sub insert_contracten {
            my $xml_content = shift @_;
            my $ip = $main::agresso_instellingen->{"Agresso_IP_$main::test_prod"};;
            my $proxy = "http://$ip/service.svc?CustomerService/Customer";           
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
     sub delete_contracten {
            my $agresonr = shift @_;
            my $dbh = sql_toegang_agresso->setup_mssql_connectie($main::test_prod);
            my $client = 'VMOB';
             my $sql =("SELECT * FROM afxvmobcontract WHERE client = '$client' and dim_value = $agresonr" );#fetch first 10 rows only
            my $sth = $dbh->prepare( $sql );
            $sth ->execute();
             while(my @agresso_klant_contract =$sth->fetchrow_array)  {
                 print "@agresso_klant_contract\n";
                }
            $dbh->do("DELETE FROM afxvmobcontract WHERE client = '$client' and  dim_value = $agresonr ");
        }
     sub zoek_info {
            my $rijksregnr =shift @_;
            my $verzekering = shift @_;
            my $dbh = connectdb->connect_as400 ('SIS203','SIS203','airbus');
            my @info= $dbh->selectrow_array("SELECT INFO52,INFO62,INFO64,INFO51,INFO61,INFO63,INFOFOR,INFOCON FROM libsxfil03.MOBGEVN
                                             WHERE KNRN52 = '$rijksregnr'");
            foreach my $info1 (@info) {
                if (defined $info1) {
                    $info1 =~ s/^\s+//;
                    $info1 =~ s/\s+$//;
                   }
               }
            my $info_terug = '';
            if ($verzekering == 52) {
                $info_terug = $info[0];
            }elsif ($verzekering == 62) {
                $info_terug = $info[1];
            }elsif ($verzekering == 64) {
                $info_terug = $info[2];
            }elsif ($verzekering == 51) {
                $info_terug = $info[3];
            }elsif ($verzekering == 61) {
                $info_terug = $info[4];
            }elsif ($verzekering == 63) {
                $info_terug = $info[5];
            }elsif ($verzekering == 53) {
                $info_terug = $info[7];
            }elsif ($verzekering == 50 or $verzekering == 39) {
                $info_terug = $info[6];
            }else {
                 $info_terug ='';
            }
            connectdb->disconnect($dbh);
            return ($info_terug );
        }
     sub zoek_naam_verzekering {
            my $verz_nr = shift @_;
            my $produktnummer = shift @_;
            my $ziekenfonds = shift @_;
            if ($produktnummer == 1 and $verz_nr != 50) {
                foreach my $naam_verzekering (keys $agresso_instellingen->{verzekeringen}->{$ziekenfonds}) {
                         if ($agresso_instellingen->{verzekeringen}->{$ziekenfonds}->{$naam_verzekering} == $verz_nr) {
                             my $voorlopige_naam = uc $naam_verzekering;
                             return ($voorlopige_naam);
                         }
                    }
            }elsif ($produktnummer == 1 and $verz_nr = 50) {
                return ('HOSPIFORFAIT25');
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
     sub checknaamextern {
            my ($dbh,$nummer) = @_;
            #openen van PFYSL8
            # EXIDL8 = extern nummer
            # KNRNL8 = nationaalt register nummer
            # NAMBL8 = naam van de gerechtigde
            # PRNBL8 = voornaam van de gerechtigde
            # SEXEL8 = code van het geslacht
            # NAIYL8 = geboortejaat
            # NAIML8 = geboortemaand
            # NAIJL8 = geboortedag
            #print "";
            my @naamrij = $dbh->selectrow_array("SELECT EXIDL8,KNRNL8,NAMBL8,PRNBL8,SEXEL8,NAIYL8,NAIML8,NAIJL8,KVPSL8 FROM $settings->{'pers_fil'} WHERE EXIDL8=$nummer");
            #print "inz = $naamrij[1]\n";
            #print "extern = $naamrij[0]\n";
            #print "@naamrij\n";
            #print "\n";
            if (!$naamrij[1]) {
                Wx::MessageBox( _T("Deze Persoon is geen lid!"),
                     _T("Persoon opzoeken"),
                     wxOK|wxCENTRE,
                     $main::frame
                );#code
                #die;
             return ('nok');  #code
            }

            return ($naamrij[1]);
        }
     sub agresso_get_customer_info_rr_nr {
            use SOAP::Lite ;#'trace', 'debug' ;
            my ($class,$clientnummer ) = @_;
            #$clientnummer = 67122533419;#;100048 100248 166516
            my $ip = $main::agresso_instellingen->{"Agresso_IP_$main::test_prod"};
            my $proxy = "http://$ip/service.svc";           
            my $uri   = 'http://services.agresso.com/CustomerService/Customer';
            my $soap = SOAP::Lite
                  ->proxy($proxy)
                  ->ns($uri,'cus')
                  ->on_action( sub { return 'GetCustomers' } );
            my $company   = SOAP::Data->name('cus:Company'=> 'VMOB')->type('');
            my $customerId =  SOAP::Data->name('cus:ExternalReference'=> "$clientnummer")->type('');
            my $customerObject = SOAP::Data->name('cus:customerObject')->value(\SOAP::Data->value($company,$customerId));
            my $customerDetailsOnly =  SOAP::Data->name('cus:customerDetailsOnly'=> "0")->type('');
            my $Username    = SOAP::Data->name('cus:Username' => 'WEBSERV')->type('');
            my $Client      = SOAP::Data->name('cus:Client'   => 'VMOB')->type('');
            my $Password    = SOAP::Data->name('cus:Password' => 'WEBSERV')->type('');
            my $credentials = SOAP::Data->name('cus:credentials') ->value(\SOAP::Data->value($Username, $Client, $Password));
            #my $GetCustomer       = SOAP::Data->name('cus:GetCustomer')
            #->value(\SOAP::Data->value($company , $customerId, $customerDetailsOnly ,$credentials ));
             print (scalar localtime() . " @_\n");
             print "_______________________________\n";
            my $response = $soap->GetCustomers($customerObject, $customerDetailsOnly ,$credentials );
             print (scalar localtime() . " @_\n");
             print "_______________________________\n";
            eval {my $returncode =$response->{_content}[2][0][2][0][4]->{GetCustomersResult}->{ReturnCode}};
            if ( $response->{_content}[2][0][2][0][4]->{GetCustomersResult}->{ReturnCode} == 40 and !$@) {
                #code
            print "";
            $main::klant->{Agresso_nummer} = $response->{_content}[2][0][2][0][4]->{GetCustomersResult}->{CustomerTypeList}->{CustomerObject}->{CustomerID};
            $main::klant->{CustomerGroupID} = $response->{_content}[2][0][2][0][4]->{GetCustomersResult}->{CustomerTypeList}->{CustomerObject}->{CustomerGroupID};
            #my $test = $response->{_content}[2][0][2][0][4]->{GetCustomersResult}->{CustomerTypeList}->{CustomerObject}->{CustomerName};
            $main::klant->{naam} =$response->{_content}[2][0][2][0][4]->{GetCustomersResult}->{CustomerTypeList}->{CustomerObject}->{CustomerName};
            $main::klant->{Rijksreg_Nr} =$response->{_content}[2][0][2][0][4]->{GetCustomersResult}->{CustomerTypeList}->{CustomerObject}->{ExternalReference};
            $main::klant->{Bankrekening}=$response->{_content}[2][0][2][0][4]->{GetCustomersResult}->{CustomerTypeList}->{CustomerObject}->{BankAccount};
            $main::klant->{IBAN}=$response->{_content}[2][0][2][0][4]->{GetCustomerResult}->{CustomerType}->{IBAN};
            $main::klant->{BIC}=$response->{_content}[2][0][2][0][4]->{GetCustomerResult}->{CustomerType}->{Swift};
            $main::klant->{Taal}=$response->{_content}[2][0][2][0][4]->{GetCustomerResult}->{CustomerTypeList}->{CustomerObject}->{Language};
            $main::klant->{PTL_TIT}=$response->{_content}[2][0][2][0][4]->{GetCustomerResult}->{CustomerType}->{Text};
            eval {my $meerdere_adressen = $response->{_content}[2][0][2][0][4]->{GetCustomersResult}->{CustomerTypeList}->{CustomerObject}->{AddressList}->{AddressUnitType}->[0]->{Address}};
            if ($@) {
                 eval {$main::klant->{adres}->[0]->{Straat}=$response->{_content}[2][0][2][0][4]->{GetCustomersResult}->{CustomerTypeList}->{CustomerObject}->{AddressList}->{AddressUnitType}->{Address}};
                 if ($@) {
                         print "Geen addres";
                          Wx::MessageBox( _T("Deze Persoon heeft geen adres!"),
                         _T("Adres met de hand inzetten"),
                         wxOK|wxCENTRE,
                         $main::frame
                         );#code
                    }else {
                         $main::klant->{adres}->[0]->{Straat}=$response->{_content}[2][0][2][0][4]->{GetCustomersResult}->{CustomerTypeList}->{CustomerObject}->{AddressList}->{AddressUnitType}->{Address};
                         $main::klant->{adres}->[0]->{Stad}=$response->{_content}[2][0][2][0][4]->{GetCustomersResult}->{CustomerTypeList}->{CustomerObject}->{AddressList}->{AddressUnitType}->{Place};
                         $main::klant->{adres}->[0]->{Postcode}=$response->{_content}[2][0][2][0][4]->{GetCustomersResult}->{CustomerTypeList}->{CustomerObject}->{AddressList}->{AddressUnitType}->{ZipCode};
                         $main::klant->{adres}->[0]->{Telefoon_nr}=$response->{_content}[2][0][2][0][4]->{GetCustomersResult}->{CustomerTypeList}->{CustomerObject}->{AddressList}->{AddressUnitType}->{Telephone1};
                         $main::klant->{adres}->[0]->{e_mail}=$response->{_content}[2][0][2][0][4]->{GetCustomersResult}->{CustomerTypeList}->{CustomerObject}->{AddressList}->{AddressUnitType}->{eMail};
                         $main::klant->{adres}->[0]->{type}='Domi';
                    }                
                }else {
                 my $adres_teller = 0;
                 foreach my $nr (keys $response->{_content}[2][0][2][0][4]->{GetCustomersResult}->{CustomerTypeList}->{CustomerObject}->{AddressList}->{AddressUnitType}) {
                      $main::klant->{adres}->[$adres_teller]->{Straat}=$response->{_content}[2][0][2][0][4]->{GetCustomersResult}->{CustomerTypeList}->{CustomerObject}->{AddressList}->{AddressUnitType}->[$nr]->{Address};
                      $main::klant->{adres}->[$adres_teller]->{Stad}=$response->{_content}[2][0][2][0][4]->{GetCustomersResult}->{CustomerTypeList}->{CustomerObject}->{AddressList}->{AddressUnitType}->[$nr]->{Place};
                      $main::klant->{adres}->[$adres_teller]->{Postcode}=$response->{_content}[2][0][2][0][4]->{GetCustomersResult}->{CustomerTypeList}->{CustomerObject}->{AddressList}->{AddressUnitType}->[$nr]->{ZipCode};
                      $main::klant->{adres}->[$adres_teller]->{Telefoon_nr}=$response->{_content}[2][0][2][0][4]->{GetCustomersResult}->{CustomerTypeList}->{CustomerObject}->{AddressList}->{AddressUnitType}->[$nr]->{Telephone1};
                      $main::klant->{adres}->[$adres_teller]->{e_mail}=$response->{_content}[2][0][2][0][4]->{GetCustomersResult}->{CustomerTypeList}->{CustomerObject}->{AddressList}->{AddressUnitType}->[$nr]->{eMail};
                      my $adres_type =$response->{_content}[2][0][2][0][4]->{GetCustomersResult}->{CustomerTypeList}->{CustomerObject}->{AddressList}->{AddressUnitType}->[$nr]->{AddressType};
                      if ($adres_type == 1) {
                           $main::klant->{adres}->[$adres_teller]->{type}='Domi';
                          }else {
                           $main::klant->{adres}->[$adres_teller]->{type}='Post';
                          }

                      $adres_teller += 1;
                     }
                }


            #we gaan de verzekeringen opzoeken
            my $link =$response->{_content}[2][0][2][0][4]->{GetCustomersResult}->{CustomerTypeList}->{CustomerObject}->{FlexiGroupList}->{FlexiGroupUnitType};
            my  $cop= $main::klant;
            foreach my $nr     (keys $link){
                 if ($link->[$nr]->{FlexiGroup} eq 'VMOBCONTRACT') { # dit zijn de contracten
                      my $contract_teller=0;
                      eval {my $testeval = $link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->[0]->{FlexiFieldList} };
                      if ($@) {
                           foreach my $nr_nr_nr (keys $link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->{FlexiFieldList}->{FlexiFieldUnitType}) {
                                if ($link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{ColumnName} eq 'product') {
                                     $main::klant->{contracten}->[$contract_teller]->{naam}=$link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{Value};
                                     my $NAAM = uc $main::klant->{contracten}->[$contract_teller]->{naam};
                                     push (@main::verzekeringen_in_xml,$NAAM) if !($NAAM ~~ @main::verzekeringen_in_xml);
                                    }
                                if ($link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{ColumnName} eq 'startdatum') {
                                     $link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{Value} =~ m%\d+/\d+/\d{4}% ;
                                     $main::klant->{contracten}->[$contract_teller]->{startdatum} = $&;
                                    }
                                if ($link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{ColumnName} eq 'wachtdatum') {
                                     $link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{Value} =~ m%\d+/\d+/\d{4}%;
                                     $main::klant->{contracten}->[$contract_teller]->{wachtdatum} = $&;
                                    }
                                if ($link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{ColumnName} eq 'einddatum') {
                                     $link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{Value} =~ m%\d+/\d+/\d{4}%;
                                     $main::klant->{contracten}->[$contract_teller]->{einddatum} = $&;
                                    }
                                if ($link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{ColumnName} eq 'contract_nr') {
                                     $link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{Value} =~ m%\d+%;
                                     $main::klant->{contracten}->[$contract_teller]->{contract_nr} = $&;
                                    }
                                if ($link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{ColumnName} eq 'zkf_nr') {
                                     $link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{Value} =~ m%\d+%;
                                     $main::klant->{contracten}->[$contract_teller]->{zkf_nr} = $&;
                                    }
                               }

                      }else {
                           foreach my $nr_nr (keys $link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}) {
                                #undef $contract;
                                foreach my $nr_nr_nr (keys $link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->[$nr_nr]->{FlexiFieldList}->{FlexiFieldUnitType}) {
                                      if ($link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->[$nr_nr]->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{ColumnName} eq 'product') {
                                           $main::klant->{contracten}->[$contract_teller]->{naam}=$link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->[$nr_nr]->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{Value};
                                            my $NAAM = uc $main::klant->{contracten}->[$contract_teller]->{naam};
                                            push (@main::verzekeringen_in_xml,$NAAM) if !($NAAM ~~ @main::verzekeringen_in_xml);
                                         }
                                      if ($link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->[$nr_nr]->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{ColumnName} eq 'startdatum') {
                                          $link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->[$nr_nr]->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{Value} =~ m%\d+/\d+/\d{4}% ;
                                          $main::klant->{contracten}->[$contract_teller]->{startdatum} = $&;
                                         }
                                      if ($link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->[$nr_nr]->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{ColumnName} eq 'wachtdatum') {
                                          $link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->[$nr_nr]->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{Value} =~ m%\d+/\d+/\d{4}%;
                                          $main::klant->{contracten}->[$contract_teller]->{wachtdatum} = $&;
                                         }
                                      if ($link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->[$nr_nr]->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{ColumnName} eq 'einddatum') {
                                          $link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->[$nr_nr]->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{Value} =~ m%\d+/\d+/\d{4}%;
                                          $main::klant->{contracten}->[$contract_teller]->{einddatum} = $&;
                                         }
                                     if ($link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->[$nr_nr]->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{ColumnName} eq 'contract_nr') {
                                          $link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->[$nr_nr]->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{Value} =~ m%\d+%;
                                          $main::klant->{contracten}->[$contract_teller]->{contract_nr} = $&;
                                         }
                                     if ($link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->[$nr_nr]->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{ColumnName} eq 'zkf_nr') {
                                          $link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->[$nr_nr]->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{Value} =~ m%\d+%;
                                          $main::klant->{contracten}->[$contract_teller]->{zkf_nr} = $&;
                                         }
                                    }
                                $contract_teller +=1;
                                print;
                               }
                          }
                     }
                 if ($link->[$nr]->{FlexiGroup} eq 'VMOBZIEKTEN') { #dit zijn de ziekten
                      my $ziekten_teller =0; ;
                      eval {my $testeval = $link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->[0]->{FlexiFieldList} };
                      if ($@) {
                           foreach my $nr_nr_nr (keys $link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->{FlexiFieldList}->{FlexiFieldUnitType}) {
                                if ($link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{ColumnName} eq 'product') {
                                     $main::klant->{ziekten}->[$ziekten_teller]->{verzekering}=$link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{Value};
                                    }
                                if ($link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{ColumnName} eq 'ziekte') {
                                     $main::klant->{ziekten}->[$ziekten_teller]->{ziekte}=$link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{Value};
                                    }
                               }
                          }else {
                           foreach my $nr_nr (keys $link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}) {
                                foreach my $nr_nr_nr (keys $link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->[$nr_nr]->{FlexiFieldList}->{FlexiFieldUnitType}) {
                                     if ($link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->[$nr_nr]->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{ColumnName} eq 'product') {
                                          $main::klant->{ziekten}->[$ziekten_teller]->{verzekering}=$link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->[$nr_nr]->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{Value};
                                         }
                                     if ($link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->[$nr_nr]->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{ColumnName} eq 'ziekte') {
                                          $main::klant->{ziekten}->[$ziekten_teller]->{ziekte}=$link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->[$nr_nr]->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{Value};
                                         }
                                    }
                                $ziekten_teller +=1;
                               }
                          }

                     }
                 if ($link->[$nr]->{FlexiGroup} eq 'VMOBAANDOEN') { #dit zijn de ziekten
                      my $aandoeningen_teller = 0 ;
                      eval {my $testeval = $link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->[0]->{FlexiFieldList} };
                      if ($@) {
                           foreach my $nr_nr_nr (keys $link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->{FlexiFieldList}->{FlexiFieldUnitType}) {
                                if ($link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{ColumnName} eq 'aandoening') {
                                     $main::klant->{aandoeningen}->[$aandoeningen_teller]->{aandoening}=$link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{Value};
                                    }
                                if ($link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{ColumnName} eq 'begindatum') {
                                     $link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{Value}=~ m%\d+/\d+/\d{4}%;
                                     $main::klant->{aandoeningen}->[$aandoeningen_teller]->{begindatum}=$&;
                                    }
                                if ($link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{ColumnName} eq 'einddatum') {
                                     $link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{Value}=~ m%\d+/\d+/\d{4}%;
                                     $main::klant->{aandoeningen}->[$aandoeningen_teller]->{einddatum}=$&;
                                    }
                                if ($link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{ColumnName} eq 'product') {
                                     $main::klant->{aandoeningen}->[$aandoeningen_teller]->{verzekering}=$link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{Value};
                                    }
                               }
                          }else{
                           foreach my $nr_nr (keys $link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}) {
                                foreach my $nr_nr_nr (keys $link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->[$nr_nr]->{FlexiFieldList}->{FlexiFieldUnitType}) {
                                     if ($link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->[$nr_nr]->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{ColumnName} eq 'aandoening') {
                                          $main::klant->{aandoeningen}->[$aandoeningen_teller]->{aandoening}=$link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->[$nr_nr]->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{Value};
                                         }
                                     if ($link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->[$nr_nr]->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{ColumnName} eq 'begindatum') {
                                          $link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->[$nr_nr]->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{Value}=~ m%\d+/\d+/\d{4}%;
                                          $main::klant->{aandoeningen}->[$aandoeningen_teller]->{begindatum}=$&;
                                         }
                                     if ($link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->[$nr_nr]->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{ColumnName} eq 'einddatum') {
                                          $link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->[$nr_nr]->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{Value}=~ m%\d+/\d+/\d{4}%;
                                          $main::klant->{aandoeningen}->[$aandoeningen_teller]->{einddatum}=$&;
                                          }
                                     if ($link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->[$nr_nr]->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{ColumnName} eq 'product') {
                                          $main::klant->{aandoeningen}->[$aandoeningen_teller]->{verzekering}=$link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->[$nr_nr]->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{Value};
                                          }
                                    }
                                $aandoeningen_teller += 1 ;
                               }
                          }

                     }
                  if ($link->[$nr]->{FlexiGroup} eq 'VMOBALG1') { #geboortedatum
                   eval {if ($link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->{FlexiFieldList}->{FlexiFieldUnitType}->{ColumnName} eq 'geboortedatum') {}};
                   if (!$@) {
                      if ($link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->{FlexiFieldList}->{FlexiFieldUnitType}->{ColumnName} eq 'geboortedatum') {
                          $link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->{FlexiFieldList}->{FlexiFieldUnitType}->{Value} =~ m%\d+/\d+/\d{4}%;
                          $main::klant->{geboortedatum} = $&;
                          my $test = $&;
                        }
                   }else {
                      foreach my $key (sort keys $link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->{FlexiFieldList}->{FlexiFieldUnitType}) {
                          if ($link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->{FlexiFieldList}->{FlexiFieldUnitType}->[$key]->{ColumnName} eq 'geboortedatum') {
                              $link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->{FlexiFieldList}->{FlexiFieldUnitType}->[$key]->{Value} =~ m%\d+/\d+/\d{4}%;
                              $main::klant->{geboortedatum} = $&;
                              my $test = $&;
                              print "";
                             }
                          if ($link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->{FlexiFieldList}->{FlexiFieldUnitType}->[$key]->{ColumnName} eq 'aantal_kaarten_fx') {
                               $main::klant->{aantal_kaarten} =$link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->{FlexiFieldList}->{FlexiFieldUnitType}->[$key]->{Value};

                              }
                        }
                   }
                    }
                 if ($link->[$nr]->{FlexiGroup} eq 'VMOBTLN') { #ten laste name en commentaar
                      eval {my $testeval = $link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->[0]->{FlexiFieldList} };
                      if ($@) {
                           foreach my $nr_nr_nr (keys $link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->{FlexiFieldList}->{FlexiFieldUnitType}) {
                                if ($link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{ColumnName} eq 'ten_laste_name') {
                                     $main::klant->{ten_laste_name}->{ja_nee}=$link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{Value};
                                    }
                                if ($link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{ColumnName} eq 'commentaar') {
                                     $main::klant->{ten_laste_name}->{commentaar}=$link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{Value};
                                    }
                               }
                          }else {

                          }
                     }
                }
            my $aantal_lijnen = &sorteer_contracten;
            for (my $i = 0; $i < $aantal_lijnen; $i++) {
                 &sorteer_contracten;
                }
            return ("ok");
            }else {
                 return ("nok");
            }
            print"";
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

        }
     sub sorteer_contracten {
         my $startdatum_oud;
         my $einddatum_oud;
         my $teller = 0;
         #my $test = $main::klant->{contracten};
         eval { foreach my $nr (sort keys $main::klant->{contracten}) {}};
         if (!$@) {
             foreach my $nr (sort keys $main::klant->{contracten}) {
                if ($teller == 0) {
                     my $startdatum = $main::klant->{contracten}->[$nr]->{startdatum};
                     my ($startdag,$startmaand,$startjaar) = split (/\//,$startdatum);
                     my $einddatum = $main::klant->{contracten}->[$nr]->{einddatum};
                     my ($einddag,$eindmaand,$eindjaar) = split (/\//,$einddatum);
                     $startdatum = $startjaar*10000+$startmaand*100+$startdag;
                     $einddatum = $eindjaar*10000+$eindmaand*100+$einddag;
                     $startdatum_oud = $startdatum;
                     $einddatum_oud = $einddatum ;
                     $teller +=1;
                    }else {
                       my $startdatum = $main::klant->{contracten}->[$nr]->{startdatum};
                       my ($startdag,$startmaand,$startjaar) = split (/\//,$startdatum);
                       my $einddatum = $main::klant->{contracten}->[$nr]->{einddatum};
                       my ($einddag,$eindmaand,$eindjaar) = split (/\//,$einddatum);
                       $startdatum = $startjaar*10000+$startmaand*100+$startdag;
                       $einddatum = $eindjaar*10000+$eindmaand*100+$einddag;
                       if ($einddatum > $einddatum_oud) {
                         my $cache = $main::klant->{contracten}->[$nr-1];
                         $main::klant->{contracten}->[$nr-1] = $main::klant->{contracten}->[$nr];
                         $main::klant->{contracten}->[$nr] = $cache;
                        }else {
                         $startdatum_oud = $startdatum;
                         $einddatum_oud = $einddatum ;
                        }
                     $teller +=1;
                    }
                }
             $main::klant->{zkf_nr}= $main::klant->{contracten}->[0]->{zkf_nr};#code
             $main::klant->{Ziekenfonds}= $main::klant->{contracten}->[0]->{zkf_nr};#code
            }
         return ($teller);
        }

package zoek_extern_nr;
     use Win32;
     use Win32::Clipboard;

     sub clipboard {
         my $text = Win32::Clipboard::GetText();
         my $zoektekst=$text;
         $zoektekst=~s/(\n|\r)/ /g; #haalt de cariage returns en linfeeds eruit
         $externnummer = '';
         $ziekenfonds_nummer = substr ($zoektekst,13,8);
         $ziekenfonds_nummer =~ m/\d{3}\s/;
         $ziekenfonds_nummer = $&;
         $ziekenfonds_nummer =~ s/^\s+//;
         $ziekenfonds_nummer =~ s/\s+$//;
         $ziekenfonds_nummer =~ s/://g;
         $ziekenfonds_nummer =~ s/\s//g;
         #print "$text\n";
         $zoektekst =~ m/\s\d{13}\s/;
         $externnummer = $&;
         $externnummer =~ s/\s//g;
         print '';
         $main::klant->{ExternNummer}=$externnummer;
        }

package AppDialog;
     use strict;
     use warnings;
     use base 'Wx::App';
     sub OnInit {
         $main::dialog = FrameDialog->new();
         #$main::frame->Maximize( 1 );
         $main::dialog->SetSize(1, 1, 450, 150);
         $main::dialog->Centre();

         $main::dialog->Show(1);
        }
package FrameDialog;
     use strict;
     use warnings;
     use Wx qw(:everything);
     use base qw(Wx::Frame);
     use Data::Dumper;
     use Wx::Locale gettext => '_T';
     my $rijkregnr ='';
     my $zkf ='';
     my $FrameDialog;
     sub new {
         my($self) = @_;
         my $rijkregnr ='';
         my $zkf ='';
         $self = $self->SUPER::new(undef, -1, "$main::test_prod Geef een rijksregister nummer en een ziekenfonds in:",
                              wxDefaultPosition,[450,150],wxDEFAULT_FRAME_STYLE|wxTE_PROCESS_TAB|wxTAB_TRAVERSAL );#| wxMAXIMIZE
         $self->{Frame_Sizer_1} = Wx::FlexGridSizer->new(4,4, 10, 10);
         $self->{Frame_statictxt_Rijksregisternr}= Wx::StaticText->new($self, -1,_T("Rijksregister Nummer:"),wxDefaultPosition,wxSIZE(150,20));
         $self->{Frame_Txt_Rijksregisternr} = Wx::TextCtrl->new($self, -1, $rijkregnr,wxDefaultPosition,wxSIZE(150,20));
         $self->{Frame_statictxt_Zkf}= Wx::StaticText->new($self, -1,_T("ZKF:"),wxDefaultPosition,wxSIZE(150,20));
         $self->{Frame_Txt_Zkf} = Wx::TextCtrl->new($self, -1, $zkf,wxDefaultPosition,wxSIZE(150,20));
         $self->{Frame_Button_OK}  = Wx::Button->new($self, -1, _T("OK"),wxDefaultPosition,wxSIZE(150,20));
         $self->{Frame_Cancel}  = Wx::Button->new($self, -1, _T("Cancel"),wxDefaultPosition,wxSIZE(150,20));
         $self->{Frame_panel_1} = Wx::Panel->new($self,-1,wxDefaultPosition,wxSIZE(25,5));
         #rij2
         $self->{Frame_Sizer_1}->Add($self->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $self->{Frame_Sizer_1}->Add($self->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $self->{Frame_Sizer_1}->Add($self->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $self->{Frame_Sizer_1}->Add($self->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         #rij0
         $self->{Frame_Sizer_1}->Add($self->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $self->{Frame_Sizer_1}->Add($self->{Frame_statictxt_Rijksregisternr}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $self->{Frame_Sizer_1}->Add($self->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $self->{Frame_Sizer_1}->Add($self->{Frame_statictxt_Zkf}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         #rij1
         $self->{Frame_Sizer_1}->Add($self->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $self->{Frame_Sizer_1}->Add($self->{Frame_Txt_Rijksregisternr}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $self->{Frame_Sizer_1}->Add($self->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $self->{Frame_Sizer_1}->Add($self->{Frame_Txt_Zkf}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);

         #rij3
         $self->{Frame_Sizer_1}->Add($self->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $self->{Frame_Sizer_1}->Add($self->{Frame_Button_OK}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $self->{Frame_Sizer_1}->Add($self->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $self->{Frame_Sizer_1}->Add($self->{Frame_Cancel}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         Wx::Event::EVT_BUTTON($self,$self->{Frame_Button_OK},\&OK);
         Wx::Event::EVT_BUTTON($self,$self->{Frame_Cancel},\&Cancel);
         $self->SetSizer($self->{Frame_Sizer_1});
         $self->SetBackgroundColour(Wx::Colour->new(239, 243, 255));
         $FrameDialog = $self;
         return ($self);
        }
     sub OK {

         my $rijkregnr =  $FrameDialog->{Frame_Txt_Rijksregisternr}->GetValue();
         my $zkf = $FrameDialog->{Frame_Txt_Zkf}->GetValue();
         $rijkregnr =~ s/\s//g;
         $rijkregnr =~ s/-//g;
         $zkf =~ s/\s//g;
         if ($zkf  =~ m/\d{3}/ and $rijkregnr=~ m/\d{8}/) {
             my $settings = settings->new($zkf);
             my $dbconnectie = connectdb->connect_as400 ($settings->{user_name},$settings->{password},$settings->{name_as400});
             my $eind_cont=0;
             my $min_einddatum_contract = $vandaag -30000;
             ($externnummer,$eind_cont) =as400_gegevens->natreg_to_extern_zonder_einddatum($dbconnectie,$rijkregnr,$settings,$min_einddatum_contract);
             $main::klant->{ExternNummer}=$externnummer;
             $ziekenfonds_nummer = $zkf;
             print "";
             my $bool = $FrameDialog->Close();
             print "";
         }else {
              Wx::MessageBox("Rijkregister nummer , Ziekenfonds ?",
                                               _T("Opgelet je hebt niet alles juist ingevuld "),
                                               wxOK|wxCENTRE,
                                               $frame
                                              );
         }

         print "";
        }
     sub Cancel {
         my($self)= @_;
         die;
        }

package App;
     use strict;
     use warnings;
     use base 'Wx::App';
     sub OnInit {
         $main::frame = Frame->new();
         #$main::frame->Maximize( 1 );
         $main::frame->SetSize(1, 1, 1850, 370);
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
          my $ip = $main::agresso_instellingen->{"Agresso_IP_$main::test_prod"};
          $self = $self->SUPER::new(undef, -1, "MOBICOON v$main::version Milestone 7 -> $main::test_prod sessie voor $main::gebruikersnaam ->$ip",
                              wxDefaultPosition,wxDefaultSize,wxDEFAULT_FRAME_STYLE );#| wxMAXIMIZE
          #$self = $self->SUPER::new(undef, -1, "Berekening - Voorbeeld",
          #                    wxDefaultPosition,wxDefaultSize,wxDEFAULT_FRAME_STYLE | wxMAXIMIZE);
          #$self->{matrix}=@overzicht_matrix;
         #my $instelingen = assurcard_calculation_settings->new($self);
         #in $self->{calculation_settings} zit de xml
         my $toolbar_main_frame = ToolBarMainFrame->new($self);
         my $main_frame_notebook_boven = MainFrameNotebookBoven->new($self);
         #my $logwindow = Wx::LogWindow->new( $self , "title", !!"show" );
          $self->__do_layout();
         # $self->{Maximize}(1);
          return $self;
        }

     sub __do_layout {
            my $self =shift;
            $self->SetMenuBar($self->{main_frame_menubar});
            $self->SetToolBar($self->{frame_toolbar});
            $self->{mainframe}->{sizer_1} = Wx::BoxSizer->new(wxVERTICAL);
            $self->SetSizerAndFit( $self->{mainframe}->{sizer_1});
            $self->{MainFrameNotebookBoven_pane_lov}->SetSizer($self->{lov_sizer_1});
            $self->{MainFrameNotebookBoven_pane_BA_EZ}->SetSizer($self->{BA_EZ_sizer_1});
            $self->{MainFrameNotebookBoven_pane_EZ}->SetSizer($self->{EZ_sizer_1});
            $self->{MainFrameNotebookBoven_pane_GKD}->SetSizer($self->{GKD_sizer_1});
            $self->{MainFrameNotebookBoven_pane_brieven}->SetSizer($self->{brieven_sizer_1});
            $self->{MainFrameNotebookBoven_pane_AB}->SetSizer($self->{AB_sizer_1});
            foreach my $mogelijke_brieven (keys $main::brieven_instellingen) {
             eval {foreach my $teksten (keys $main::brieven_instellingen->{$mogelijke_brieven}->{aanvinkteksten}) {}};
             if (!$@) {
                  $self->{"MainFrameNotebookBoven_pane\_$mogelijke_brieven"}->SetSizer($self->{"$mogelijke_brieven\_sizer_1"});
                }

            }
            #$self->{mainframe}->{sizer_1}->Add($self->{MainFrameNotebookBoven}, 1, wxEXPAND, 0);
            $self->{mainframe}->{sizer_1}->Add($self->{MainFrameNotebookBoven}, 2,wxEXPAND, 0);
            $self->Layout();
       }

package MainFrameNotebookBoven;
     use Wx qw[:everything];
     use base qw(Wx::Frame);
     #use Data::Dumper

     use strict;
     use Wx::Locale gettext => '_T';
     sub new {
         my ($class, $frame) = @_;
         $frame->{MainFrameNotebookBoven} = Wx::Notebook->new($frame, wxID_ANY, wxDefaultPosition, wxDefaultSize, 0);
         $frame->{MainFrameNotebookBoven_pane_lov} = Wx::Panel->new($frame->{MainFrameNotebookBoven}, wxID_ANY, wxDefaultPosition, wxDefaultSize, );
         $frame->{MainFrameNotebookBoven_pane_BA_EZ} = Wx::Panel->new($frame->{MainFrameNotebookBoven}, wxID_ANY, wxDefaultPosition, wxDefaultSize, );
         $frame->{MainFrameNotebookBoven_pane_EZ} = Wx::Panel->new($frame->{MainFrameNotebookBoven}, wxID_ANY, wxDefaultPosition, wxDefaultSize, );
         $frame->{MainFrameNotebookBoven_pane_GKD} = Wx::Panel->new($frame->{MainFrameNotebookBoven}, wxID_ANY, wxDefaultPosition, wxDefaultSize, );
         $frame->{MainFrameNotebookBoven_pane_brieven} = Wx::Panel->new($frame->{MainFrameNotebookBoven}, wxID_ANY, wxDefaultPosition, wxDefaultSize, );
         $frame->{MainFrameNotebookBoven_pane_AB} = Wx::Panel->new($frame->{MainFrameNotebookBoven}, wxID_ANY, wxDefaultPosition, wxDefaultSize, );
         $frame->{MainFrameNotebookBoven}->AddPage($frame->{MainFrameNotebookBoven_pane_lov}, _T("Lid, Opname, Verzekering"));
         $frame->{MainFrameNotebookBoven}->AddPage($frame->{MainFrameNotebookBoven_pane_BA_EZ}, _T("Bestaande Aandoening"));
         $frame->{MainFrameNotebookBoven}->AddPage($frame->{MainFrameNotebookBoven_pane_EZ}, _T("Ernstige Ziekten"));
         $frame->{MainFrameNotebookBoven}->AddPage($frame->{MainFrameNotebookBoven_pane_GKD}, _T("GKD"));
         $frame->{MainFrameNotebookBoven}->AddPage($frame->{MainFrameNotebookBoven_pane_brieven}, _T("Brieven Maken"));
         $frame->{MainFrameNotebookBoven}->AddPage($frame->{MainFrameNotebookBoven_pane_AB}, _T("Automatische Brieven"));
         my $frame1 = Lid_Opname_Verzekering->new($frame);
         my $frame3 = BestaandeAandoening_ErnstigeZiekte->new($frame);
         my $frame4 = ErnstigeZiekte->new($frame);
         my $frame7 = gkd_tab->new($frame);
         my $frame8 = OO_brieven->new($frame);
         my $frame9 = Automatische_brieven->new($frame);

         foreach my $mogelijke_brieven (keys $main::brieven_instellingen) {
             eval {foreach my $teksten (keys  $main::brieven_instellingen->{$mogelijke_brieven}->{aanvinkteksten}) {}};
             if (!$@) {
                 $frame->{"MainFrameNotebookBoven_pane\_$mogelijke_brieven"} = Wx::Panel->new($frame->{MainFrameNotebookBoven}, wxID_ANY, wxDefaultPosition, wxDefaultSize, );
                 my $naam = $main::brieven_instellingen->{$mogelijke_brieven}->{naam};
                 $frame->{MainFrameNotebookBoven}->AddPage($frame->{"MainFrameNotebookBoven_pane\_$mogelijke_brieven"}, _T("$naam"));
                 invulteksten->new($frame,$mogelijke_brieven);
                }
            }
         $frame->{MainFrameNotebookBoven}->SetBackgroundColour(Wx::Colour->new(239, 243, 255));
         return ($frame);
        }
#!/usr/bin/perl -w
use strict;


package BestaandeAandoening_ErnstigeZiekte;
     use Wx qw[:everything]; use base qw(Wx::Frame);
     use Wx::Event qw( EVT_CHOICE );
     #use Data::Dumper
     use strict; use Wx::Locale gettext => '_T';
     sub new {
         my ($class, $frame) = @_; $frame->{BA_EZ_sizer_1} =
         Wx::FlexGridSizer->new(4,14, 10, 10);
         # $frame->{lov_label_1} =
         # Wx::Button->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1,
         # _T("Agresso Nummer:"),wxDefaultPosition,wxSIZE(75,20));
         $frame->{BA_Button_Bestaande_Aandoening} = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1,_T("Bestaande Aandoening"),wxDefaultPosition,wxSIZE(270,20));
         $frame->{BA_Button_BeginDatum} = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1,_T("BeginDatum"),wxDefaultPosition,wxSIZE(70,20));
         $frame->{BA_Button_EindDatum} = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1, _T("EindDatum"),wxDefaultPosition,wxSIZE(70,20));
         $frame->{BA_Button_Verzekering} = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1,_T("Verzekering"),wxDefaultPosition,wxSIZE(140,20));
         $frame->{BA_Button_Bestaande_Aandoening_1} = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1,_T("Bestaande Aandoening"),wxDefaultPosition,wxSIZE(270,20));
         $frame->{BA_Button_BeginDatum_1} = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1,_T("BeginDatum"),wxDefaultPosition,wxSIZE(70,20));
         $frame->{BA_Button_EindDatum_1} = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1,_T("EindDatum"),wxDefaultPosition,wxSIZE(70,20));
         $frame->{BA_Button_Verzekering_1} = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1,_T("Verzekering"),wxDefaultPosition,wxSIZE(140,20));
         $frame->{BA_Button_Bestaande_Aandoening_2} = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1,_T("Bestaande Aandoening"),wxDefaultPosition,wxSIZE(270,20));
         $frame->{BA_Button_BeginDatum_2} = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1, _T("BeginDatum"),wxDefaultPosition,wxSIZE(70,20));
         $frame->{BA_Button_EindDatum_2} =  Wx::Button->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1, _T("EindDatum"),wxDefaultPosition,wxSIZE(70,20));
         $frame->{BA_Button_Verzekering_2} = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1,_T("Verzekering"),wxDefaultPosition,wxSIZE(140,20));
         #  $frame->{lov_label_4} =
         #  Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_lov},
         #  -1,($main::klant->{naam}), wxDefaultPosition,wxSIZE(270,20));
         $frame->{BA_Txt_0_aandoening} = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1,$main::klant->{aandoeningen}->[0]->{aandoening},wxDefaultPosition,wxSIZE(270,20));
         $frame->{BA_Txt_0_begindatum} = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1,$main::klant->{aandoeningen}->[0]->{begindatum},wxDefaultPosition,wxSIZE(70,20)); $frame->{BA_Txt_0_einddatum} =
         Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1,$main::klant->{aandoeningen}->[0]->{einddatum},wxDefaultPosition,wxSIZE(70,20));
         #$frame->{lov_choice_dienst} =
         #Wx::Choice->new($frame->{MainFrameNotebookBoven_pane_lov},
         #26,wxDefaultPosition,wxSIZE(100,20),\@main::diensten);
         $frame->{BA_Txt_0_verzekering} =Wx::Choice->new($frame->{MainFrameNotebookBoven_pane_BA_EZ},-1,wxDefaultPosition,wxSIZE(140,20),\@main::verzekeringen_in_xml,,$main::klant->{aandoeningen}->[0]->{verzekering});
         $frame->{BA_Txt_0_verzekering}->SetStringSelection($main::klant->{aandoeningen}->[0]->{verzekering});
         $frame->{BA_Txt_1_aandoening} = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1,$main::klant->{aandoeningen}->[1]->{aandoening},wxDefaultPosition,wxSIZE(270,20));
         $frame->{BA_Txt_1_begindatum} = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1,$main::klant->{aandoeningen}->[1]->{begindatum},wxDefaultPosition,wxSIZE(70,20));
         $frame->{BA_Txt_1_einddatum} = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1,$main::klant->{aandoeningen}->[1]->{einddatum},wxDefaultPosition,wxSIZE(70,20));
         $frame->{BA_Txt_1_verzekering} = Wx::Choice->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1,wxDefaultPosition,wxSIZE(140,20),\@main::verzekeringen_in_xml,,$main::klant->{aandoeningen}->[1]->{verzekering});
         $frame->{BA_Txt_1_verzekering}->SetStringSelection($main::klant->{aandoeningen}->[1]->{verzekering});
         #$frame->{BA_Txt_1_verzekering} =
         #Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1,
         #$main::klant->{aandoeningen}->[1]->{verzekering},wxDefaultPosition,wxSIZE(140,20));
         $frame->{BA_Txt_2_aandoening} = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1,$main::klant->{aandoeningen}->[2]->{aandoening},wxDefaultPosition,wxSIZE(270,20));
         $frame->{BA_Txt_2_begindatum} = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1,$main::klant->{aandoeningen}->[2]->{begindatum},wxDefaultPosition,wxSIZE(70,20));
         $frame->{BA_Txt_2_einddatum} = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1,$main::klant->{aandoeningen}->[2]->{einddatum},wxDefaultPosition,wxSIZE(70,20));
         $frame->{BA_Txt_2_verzekering} = Wx::Choice->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1,wxDefaultPosition,wxSIZE(140,20),\@main::verzekeringen_in_xml,,$main::klant->{aandoeningen}->[2]->{verzekering});
         $frame->{BA_Txt_2_verzekering}->SetStringSelection($main::klant->{aandoeningen}->[2]->{verzekering});
         #$frame->{BA_Txt_2_verzekering} =
         #Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1,
         #$main::klant->{aandoeningen}->[2]->{verzekering},wxDefaultPosition,wxSIZE(140,20));
         $frame->{BA_Txt_3_aandoening} = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1,$main::klant->{aandoeningen}->[3]->{aandoening},wxDefaultPosition,wxSIZE(270,20));
         $frame->{BA_Txt_3_begindatum} = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1,$main::klant->{aandoeningen}->[3]->{begindatum},wxDefaultPosition,wxSIZE(70,20));
         $frame->{BA_Txt_3_einddatum} =  Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1,  $main::klant->{aandoeningen}->[3]->{einddatum},wxDefaultPosition,wxSIZE(70,20));
         $frame->{BA_Txt_3_verzekering} = Wx::Choice->new($frame->{MainFrameNotebookBoven_pane_BA_EZ},-1,wxDefaultPosition,wxSIZE(140,20),\@main::verzekeringen_in_xml,,$main::klant->{aandoeningen}->[3]->{verzekering});
         $frame->{BA_Txt_3_verzekering}->SetStringSelection($main::klant->{aandoeningen}->[3]->{verzekering});
         #$frame->{BA_Txt_3_verzekering} =
         #Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1,
         #$main::klant->{aandoeningen}->[3]->{verzekering},wxDefaultPosition,wxSIZE(140,20));
         $frame->{BA_Txt_4_aandoening} = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1,
         $main::klant->{aandoeningen}->[4]->{aandoening},wxDefaultPosition,wxSIZE(270,20));
         $frame->{BA_Txt_4_begindatum} = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1,$main::klant->{aandoeningen}->[4]->{begindatum},wxDefaultPosition,wxSIZE(70,20));
         $frame->{BA_Txt_4_einddatum} = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1,$main::klant->{aandoeningen}->[4]->{einddatum},wxDefaultPosition,wxSIZE(70,20));
         $frame->{BA_Txt_4_verzekering} = Wx::Choice->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1,wxDefaultPosition,wxSIZE(140,20),\@main::verzekeringen_in_xml,,$main::klant->{aandoeningen}->[4]->{verzekering});
         $frame->{BA_Txt_4_verzekering}->SetStringSelection($main::klant->{aandoeningen}->[4]->{verzekering});
         #$frame->{BA_Txt_4_verzekering} =
         #Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1,
         #$main::klant->{aandoeningen}->[4]->{verzekering},wxDefaultPosition,wxSIZE(140,20));
         $frame->{BA_Txt_5_aandoening} = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1,$main::klant->{aandoeningen}->[5]->{aandoening},wxDefaultPosition,wxSIZE(270,20));
         $frame->{BA_Txt_5_begindatum} = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1,$main::klant->{aandoeningen}->[5]->{begindatum},wxDefaultPosition,wxSIZE(70,20));
         $frame->{BA_Txt_5_einddatum} = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1, $main::klant->{aandoeningen}->[5]->{einddatum},wxDefaultPosition,wxSIZE(70,20));
         $frame->{BA_Txt_5_verzekering} = Wx::Choice->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1,wxDefaultPosition,wxSIZE(140,20),\@main::verzekeringen_in_xml,,$main::klant->{aandoeningen}->[5]->{verzekering});
         $frame->{BA_Txt_5_verzekering}->SetStringSelection($main::klant->{aandoeningen}->[5]->{verzekering});
         #$frame->{BA_Txt_5_verzekering} =
         #Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1,
         #$main::klant->{aandoeningen}->[5]->{verzekering},wxDefaultPosition,wxSIZE(140,20));
         $frame->{BA_Txt_6_aandoening} = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1,$main::klant->{aandoeningen}->[6]->{aandoening},wxDefaultPosition,wxSIZE(270,20));
         $frame->{BA_Txt_6_begindatum} = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1,$main::klant->{aandoeningen}->[6]->{begindatum},wxDefaultPosition,wxSIZE(70,20));
         $frame->{BA_Txt_6_einddatum} =  Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1,$main::klant->{aandoeningen}->[6]->{einddatum},wxDefaultPosition,wxSIZE(70,20));
         $frame->{BA_Txt_6_verzekering} = Wx::Choice->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1,wxDefaultPosition,wxSIZE(140,20),\@main::verzekeringen_in_xml,,$main::klant->{aandoeningen}->[6]->{verzekering});
         $frame->{BA_Txt_6_verzekering}->SetStringSelection($main::klant->{aandoeningen}->[6]->{verzekering});
         #$frame->{BA_Txt_6_verzekering} =
         #Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1,
         #$main::klant->{aandoeningen}->[6]->{verzekering},wxDefaultPosition,wxSIZE(140,20));
         $frame->{BA_Txt_7_aandoening} = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1,$main::klant->{aandoeningen}->[7]->{aandoening},wxDefaultPosition,wxSIZE(270,20));
         $frame->{BA_Txt_7_begindatum} = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1,$main::klant->{aandoeningen}->[7]->{begindatum},wxDefaultPosition,wxSIZE(70,20));
         $frame->{BA_Txt_7_einddatum} =  Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1,$main::klant->{aandoeningen}->[7]->{einddatum}, wxDefaultPosition,wxSIZE(70,20));
         $frame->{BA_Txt_7_verzekering} = Wx::Choice->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1,wxDefaultPosition,wxSIZE(140,20),\@main::verzekeringen_in_xml,,$main::klant->{aandoeningen}->[7]->{verzekering});
         $frame->{BA_Txt_7_verzekering}->SetStringSelection($main::klant->{aandoeningen}->[7]->{verzekering});
         #$frame->{BA_Txt_7_verzekering} =
         #Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1,
         #$main::klant->{aandoeningen}->[7]->{verzekering},wxDefaultPosition,wxSIZE(140,20));
         $frame->{BA_Txt_8_aandoening} = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1,$main::klant->{aandoeningen}->[8]->{aandoening},wxDefaultPosition,wxSIZE(270,20));
         $frame->{BA_Txt_8_begindatum} = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1,$main::klant->{aandoeningen}->[8]->{begindatum},wxDefaultPosition,wxSIZE(70,20));
         $frame->{BA_Txt_8_einddatum} = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1,$main::klant->{aandoeningen}->[8]->{einddatum},wxDefaultPosition,wxSIZE(70,20));
         $frame->{BA_Txt_8_verzekering} = Wx::Choice->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1,wxDefaultPosition,wxSIZE(140,20),\@main::verzekeringen_in_xml,,$main::klant->{aandoeningen}->[8]->{verzekering});
         $frame->{BA_Txt_8_verzekering}->SetStringSelection($main::klant->{aandoeningen}->[8]->{verzekering});
         #$frame->{BA_Txt_8_verzekering} =
         #Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1,
         #$main::klant->{aandoeningen}->[8]->{verzekering},wxDefaultPosition,wxSIZE(140,20));
         #$frame->{BA_Button_OK} =  Wx::Button->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1, _T("OK"),wxDefaultPosition,wxSIZE(140,40));
         #$frame->{BA_Button_Cancel} = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1,_T("Cancel"),wxDefaultPosition,wxSIZE(140,40));
          #BA_EZ MainFrameNotebookBoven_pane_BA_EZ
         #Rij1 kolom 1 +2+3+4
         $frame->{BA_panel_1} = Wx::Panel->new($frame->{MainFrameNotebookBoven_pane_BA_EZ},-1,wxDefaultPosition,wxSIZE(2,20));
         #$frame->{BA_EZ_sizer_1}->Add($frame->{BA_panel_1}, 0,
         #wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_Button_Bestaande_Aandoening},0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_Button_BeginDatum}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_Button_EindDatum}, 0,  wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_Button_Verzekering}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_Button_Bestaande_Aandoening_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_Button_BeginDatum_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_Button_EindDatum_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_Button_Verzekering_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_Button_Bestaande_Aandoening_2}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_Button_BeginDatum_2}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_Button_EindDatum_2}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_Button_Verzekering_2}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         #Rij2
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_Txt_0_aandoening} , 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_Txt_0_begindatum} , 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_Txt_0_einddatum} , 0,  wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_Txt_0_verzekering} , 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_Txt_3_aandoening} , 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_Txt_3_begindatum} , 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_Txt_3_einddatum} , 0,  wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_Txt_3_verzekering} , 0,  wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_Txt_6_aandoening} , 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_Txt_6_begindatum} , 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_Txt_6_einddatum} , 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_Txt_6_verzekering} , 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         #rij3
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_Txt_1_aandoening} , 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_Txt_1_begindatum} , 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_Txt_1_einddatum} , 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_Txt_1_verzekering} , 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_Txt_4_aandoening} , 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_Txt_4_begindatum} , 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_Txt_4_einddatum} , 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_Txt_4_verzekering} , 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_Txt_7_aandoening} , 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_Txt_7_begindatum} , 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_Txt_7_einddatum} , 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_Txt_7_verzekering} , 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         #
         #rij4
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_Txt_2_aandoening} , 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_Txt_2_begindatum} , 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_Txt_2_einddatum} , 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_Txt_2_verzekering} , 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_Txt_5_aandoening} , 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_Txt_5_begindatum} , 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_Txt_5_einddatum} , 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_Txt_5_verzekering} , 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_panel_1}, 0,  wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_Txt_8_aandoening} , 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_Txt_8_begindatum} , 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_Txt_8_einddatum} , 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_Txt_8_verzekering} , 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         #
         #rij5
         #$frame->{BA_panel_1} = Wx::Panel->new($frame->{MainFrameNotebookBoven_pane_BA_EZ},-1,wxDefaultPosition,wxSIZE(2,20));
         # $frame->{BA_EZ_sizer_1}->Add($frame->{BA_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         # $frame->{BA_EZ_sizer_1}->Add($frame->{BA_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         # $frame->{BA_EZ_sizer_1}->Add($frame->{BA_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         # $frame->{BA_EZ_sizer_1}->Add($frame->{BA_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         # $frame->{BA_EZ_sizer_1}->Add($frame->{BA_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         # $frame->{BA_EZ_sizer_1}->Add($frame->{BA_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         # $frame->{BA_EZ_sizer_1}->Add($frame->{BA_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         # $frame->{BA_EZ_sizer_1}->Add($frame->{BA_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         # $frame->{BA_EZ_sizer_1}->Add($frame->{BA_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         # $frame->{BA_EZ_sizer_1}->Add($frame->{BA_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         # $frame->{BA_EZ_sizer_1}->Add($frame->{BA_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         # $frame->{BA_EZ_sizer_1}->Add($frame->{BA_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         # $frame->{BA_EZ_sizer_1}->Add($frame->{BA_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         # $frame->{BA_EZ_sizer_1}->Add($frame->{BA_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         ##rij6
         #$frame->{BA_panel_2} = Wx::Panel->new($frame->{MainFrameNotebookBoven_pane_BA_EZ},-1,wxDefaultPosition,wxSIZE(2,40));
         #$frame->{BA_EZ_sizer_1}->Add($frame->{BA_panel_2}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         #$frame->{BA_EZ_sizer_1}->Add($frame->{BA_panel_2}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         #$frame->{BA_EZ_sizer_1}->Add($frame->{BA_panel_2}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         #$frame->{BA_EZ_sizer_1}->Add($frame->{BA_panel_2}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         #$frame->{BA_EZ_sizer_1}->Add($frame->{BA_panel_2}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         #$frame->{BA_EZ_sizer_1}->Add($frame->{BA_panel_2}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         #$frame->{BA_EZ_sizer_1}->Add($frame->{BA_panel_2}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         #$frame->{BA_EZ_sizer_1}->Add($frame->{BA_panel_2}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         #$frame->{BA_EZ_sizer_1}->Add($frame->{BA_panel_2}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         #$frame->{BA_EZ_sizer_1}->Add($frame->{BA_panel_2}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         #$frame->{BA_EZ_sizer_1}->Add($frame->{BA_Button_OK}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         #$frame->{BA_EZ_sizer_1}->Add($frame->{BA_panel_2}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         #$frame->{BA_EZ_sizer_1}->Add($frame->{BA_panel_2}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         #$frame->{BA_EZ_sizer_1}->Add($frame->{BA_Button_Cancel}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);


          #Wx::Event::EVT_BUTTON( $frame,$frame->{BA_Button_Bestaande_Aandoening},\&Bestaande_aandoening_save);
          #Wx::Event::EVT_BUTTON( $frame,$frame->{BA_Button_Bestaande_Aandoening_1},\&Bestaande_aandoening_save);
          #Wx::Event::EVT_BUTTON( $frame,$frame->{BA_Button_Bestaande_Aandoening_2},\&Bestaande_aandoening_save);
          #Wx::Event::EVT_TEXT_ENTER($frame,$frame->{BA_Txt_0_begindatum},\&convert_begindatum);
          Wx::Event::EVT_CHOICE($frame,$frame->{BA_Txt_0_verzekering},\&datumsinvullen0);
          Wx::Event::EVT_CHOICE($frame,$frame->{BA_Txt_1_verzekering},\&datumsinvullen1);
          Wx::Event::EVT_CHOICE($frame,$frame->{BA_Txt_2_verzekering},\&datumsinvullen2);
          Wx::Event::EVT_CHOICE($frame,$frame->{BA_Txt_3_verzekering},\&datumsinvullen3);
          Wx::Event::EVT_CHOICE($frame,$frame->{BA_Txt_4_verzekering},\&datumsinvullen4);
          Wx::Event::EVT_CHOICE($frame,$frame->{BA_Txt_5_verzekering},\&datumsinvullen5);
          Wx::Event::EVT_CHOICE($frame,$frame->{BA_Txt_6_verzekering},\&datumsinvullen6);
          Wx::Event::EVT_CHOICE($frame,$frame->{BA_Txt_7_verzekering},\&datumsinvullen7);
          Wx::Event::EVT_CHOICE($frame,$frame->{BA_Txt_8_verzekering},\&datumsinvullen8);
        }
sub  datumsinvullen0 {
     my ($frame,$test1,$test2,$test3) = @_;
     #my $test = $main::klant;
     my $selection = $frame->{BA_Txt_0_verzekering}->GetStringSelection();
     my $begindat = '';
     my $eindat = '';
     my $eindtest = 0;
     foreach my $contractvolgnr (keys $main::klant->{contracten}) {
         my $contractnaam = $main::klant->{contracten}->[$contractvolgnr]->{naam};
         if ($selection eq $contractnaam ) {
             my $tmpbegindat = $main::klant->{contracten}->[$contractvolgnr]->{startdatum};
             my $tmpeindat = $main::klant->{contracten}->[$contractvolgnr]->{einddatum};
             my $tmpeindjaar = substr ($tmpeindat,6,4);
             my $tmpeindmaand = substr ($tmpeindat,3,2);
             my $tmpeinddag = substr ($tmpeindat,0,2);
             my $tmpeindtest = $tmpeindjaar*10000+$tmpeindmaand*100+$tmpeinddag;
             if ($tmpeindtest > $eindtest) {
                 $eindtest = $tmpeindtest;
                 $begindat = $main::klant->{contracten}->[$contractvolgnr]->{startdatum};
                 $eindat = $main::klant->{contracten}->[$contractvolgnr]->{einddatum};
                }
            }
        }
     $frame->{BA_Txt_0_begindatum}->SetValue($begindat);
     $frame->{BA_Txt_0_einddatum}->SetValue($eindat);
      print "";
    }
sub  datumsinvullen1 {
     my ($frame,$test1,$test2,$test3) = @_;
     #my $test = $main::klant;
     my $selection = $frame->{BA_Txt_1_verzekering}->GetStringSelection();
     my $begindat = '';
     my $eindat = '';
     my $eindtest = 0;
     foreach my $contractvolgnr (keys $main::klant->{contracten}) {
         my $contractnaam = $main::klant->{contracten}->[$contractvolgnr]->{naam};
         if ($selection eq $contractnaam ) {
             my $tmpbegindat = $main::klant->{contracten}->[$contractvolgnr]->{startdatum};
             my $tmpeindat = $main::klant->{contracten}->[$contractvolgnr]->{einddatum};
             my $tmpeindjaar = substr ($tmpeindat,6,4);
             my $tmpeindmaand = substr ($tmpeindat,3,2);
             my $tmpeinddag = substr ($tmpeindat,0,2);
             my $tmpeindtest = $tmpeindjaar*10000+$tmpeindmaand*100+$tmpeinddag;
             if ($tmpeindtest > $eindtest) {
                 $eindtest = $tmpeindtest;
                 $begindat = $main::klant->{contracten}->[$contractvolgnr]->{startdatum};
                 $eindat = $main::klant->{contracten}->[$contractvolgnr]->{einddatum};
                }
            }
        }
     $frame->{BA_Txt_1_begindatum}->SetValue($begindat);
     $frame->{BA_Txt_1_einddatum}->SetValue($eindat);
      print "";
    }
sub  datumsinvullen2 {
     my ($frame,$test1,$test2,$test3) = @_;
     #my $test = $main::klant;
     my $selection = $frame->{BA_Txt_2_verzekering}->GetStringSelection();
     my $begindat = '';
     my $eindat = '';
     my $eindtest = 0;
     foreach my $contractvolgnr (keys $main::klant->{contracten}) {
         my $contractnaam = $main::klant->{contracten}->[$contractvolgnr]->{naam};
         if ($selection eq $contractnaam ) {
             my $tmpbegindat = $main::klant->{contracten}->[$contractvolgnr]->{startdatum};
             my $tmpeindat = $main::klant->{contracten}->[$contractvolgnr]->{einddatum};
             my $tmpeindjaar = substr ($tmpeindat,6,4);
             my $tmpeindmaand = substr ($tmpeindat,3,2);
             my $tmpeinddag = substr ($tmpeindat,0,2);
             my $tmpeindtest = $tmpeindjaar*10000+$tmpeindmaand*100+$tmpeinddag;
             if ($tmpeindtest > $eindtest) {
                 $eindtest = $tmpeindtest;
                 $begindat = $main::klant->{contracten}->[$contractvolgnr]->{startdatum};
                 $eindat = $main::klant->{contracten}->[$contractvolgnr]->{einddatum};
                }
            }
        }
     $frame->{BA_Txt_2_begindatum}->SetValue($begindat);
     $frame->{BA_Txt_2_einddatum}->SetValue($eindat);
      print "";
    }
sub  datumsinvullen3 {
     my ($frame,$test1,$test2,$test3) = @_;
     #my $test = $main::klant;
     my $selection = $frame->{BA_Txt_3_verzekering}->GetStringSelection();
     my $begindat = '';
     my $eindat = '';
     my $eindtest = 0;
     foreach my $contractvolgnr (keys $main::klant->{contracten}) {
         my $contractnaam = $main::klant->{contracten}->[$contractvolgnr]->{naam};
         if ($selection eq $contractnaam ) {
             my $tmpbegindat = $main::klant->{contracten}->[$contractvolgnr]->{startdatum};
             my $tmpeindat = $main::klant->{contracten}->[$contractvolgnr]->{einddatum};
             my $tmpeindjaar = substr ($tmpeindat,6,4);
             my $tmpeindmaand = substr ($tmpeindat,3,2);
             my $tmpeinddag = substr ($tmpeindat,0,2);
             my $tmpeindtest = $tmpeindjaar*10000+$tmpeindmaand*100+$tmpeinddag;
             if ($tmpeindtest > $eindtest) {
                 $eindtest = $tmpeindtest;
                 $begindat = $main::klant->{contracten}->[$contractvolgnr]->{startdatum};
                 $eindat = $main::klant->{contracten}->[$contractvolgnr]->{einddatum};
                }
            }
        }
     $frame->{BA_Txt_3_begindatum}->SetValue($begindat);
     $frame->{BA_Txt_3_einddatum}->SetValue($eindat);
      print "";
    }
sub  datumsinvullen4 {
     my ($frame,$test1,$test2,$test3) = @_;
     #my $test = $main::klant;
     my $selection = $frame->{BA_Txt_4_verzekering}->GetStringSelection();
     my $begindat = '';
     my $eindat = '';
     my $eindtest = 0;
     foreach my $contractvolgnr (keys $main::klant->{contracten}) {
         my $contractnaam = $main::klant->{contracten}->[$contractvolgnr]->{naam};
         if ($selection eq $contractnaam ) {
             my $tmpbegindat = $main::klant->{contracten}->[$contractvolgnr]->{startdatum};
             my $tmpeindat = $main::klant->{contracten}->[$contractvolgnr]->{einddatum};
             my $tmpeindjaar = substr ($tmpeindat,6,4);
             my $tmpeindmaand = substr ($tmpeindat,3,2);
             my $tmpeinddag = substr ($tmpeindat,0,2);
             my $tmpeindtest = $tmpeindjaar*10000+$tmpeindmaand*100+$tmpeinddag;
             if ($tmpeindtest > $eindtest) {
                 $eindtest = $tmpeindtest;
                 $begindat = $main::klant->{contracten}->[$contractvolgnr]->{startdatum};
                 $eindat = $main::klant->{contracten}->[$contractvolgnr]->{einddatum};
                }
            }
        }
     $frame->{BA_Txt_4_begindatum}->SetValue($begindat);
     $frame->{BA_Txt_4_einddatum}->SetValue($eindat);
      print "";
    }
sub  datumsinvullen5 {
     my ($frame,$test1,$test2,$test3) = @_;
     #my $test = $main::klant;
     my $selection = $frame->{BA_Txt_5_verzekering}->GetStringSelection();
     my $begindat = '';
     my $eindat = '';
     my $eindtest = 0;
     foreach my $contractvolgnr (keys $main::klant->{contracten}) {
         my $contractnaam = $main::klant->{contracten}->[$contractvolgnr]->{naam};
         if ($selection eq $contractnaam ) {
             my $tmpbegindat = $main::klant->{contracten}->[$contractvolgnr]->{startdatum};
             my $tmpeindat = $main::klant->{contracten}->[$contractvolgnr]->{einddatum};
             my $tmpeindjaar = substr ($tmpeindat,6,4);
             my $tmpeindmaand = substr ($tmpeindat,3,2);
             my $tmpeinddag = substr ($tmpeindat,0,2);
             my $tmpeindtest = $tmpeindjaar*10000+$tmpeindmaand*100+$tmpeinddag;
             if ($tmpeindtest > $eindtest) {
                 $eindtest = $tmpeindtest;
                 $begindat = $main::klant->{contracten}->[$contractvolgnr]->{startdatum};
                 $eindat = $main::klant->{contracten}->[$contractvolgnr]->{einddatum};
                }
            }
        }
     $frame->{BA_Txt_5_begindatum}->SetValue($begindat);
     $frame->{BA_Txt_5_einddatum}->SetValue($eindat);
      print "";
    }
sub  datumsinvullen6 {
     my ($frame,$test1,$test2,$test3) = @_;
     #my $test = $main::klant;
     my $selection = $frame->{BA_Txt_6_verzekering}->GetStringSelection();
     my $begindat = '';
     my $eindat = '';
     my $eindtest = 0;
     foreach my $contractvolgnr (keys $main::klant->{contracten}) {
         my $contractnaam = $main::klant->{contracten}->[$contractvolgnr]->{naam};
         if ($selection eq $contractnaam ) {
             my $tmpbegindat = $main::klant->{contracten}->[$contractvolgnr]->{startdatum};
             my $tmpeindat = $main::klant->{contracten}->[$contractvolgnr]->{einddatum};
             my $tmpeindjaar = substr ($tmpeindat,6,4);
             my $tmpeindmaand = substr ($tmpeindat,3,2);
             my $tmpeinddag = substr ($tmpeindat,0,2);
             my $tmpeindtest = $tmpeindjaar*10000+$tmpeindmaand*100+$tmpeinddag;
             if ($tmpeindtest > $eindtest) {
                 $eindtest = $tmpeindtest;
                 $begindat = $main::klant->{contracten}->[$contractvolgnr]->{startdatum};
                 $eindat = $main::klant->{contracten}->[$contractvolgnr]->{einddatum};
                }
            }
        }
     $frame->{BA_Txt_6_begindatum}->SetValue($begindat);
     $frame->{BA_Txt_6_einddatum}->SetValue($eindat);
      print "";
    }
sub  datumsinvullen7 {
     my ($frame,$test1,$test2,$test3) = @_;
     #my $test = $main::klant;
     my $selection = $frame->{BA_Txt_7_verzekering}->GetStringSelection();
     my $begindat = '';
     my $eindat = '';
     my $eindtest = 0;
     foreach my $contractvolgnr (keys $main::klant->{contracten}) {
         my $contractnaam = $main::klant->{contracten}->[$contractvolgnr]->{naam};
         if ($selection eq $contractnaam ) {
             my $tmpbegindat = $main::klant->{contracten}->[$contractvolgnr]->{startdatum};
             my $tmpeindat = $main::klant->{contracten}->[$contractvolgnr]->{einddatum};
             my $tmpeindjaar = substr ($tmpeindat,6,4);
             my $tmpeindmaand = substr ($tmpeindat,3,2);
             my $tmpeinddag = substr ($tmpeindat,0,2);
             my $tmpeindtest = $tmpeindjaar*10000+$tmpeindmaand*100+$tmpeinddag;
             if ($tmpeindtest > $eindtest) {
                 $eindtest = $tmpeindtest;
                 $begindat = $main::klant->{contracten}->[$contractvolgnr]->{startdatum};
                 $eindat = $main::klant->{contracten}->[$contractvolgnr]->{einddatum};
                }
            }
        }
     $frame->{BA_Txt_7_begindatum}->SetValue($begindat);
     $frame->{BA_Txt_7_einddatum}->SetValue($eindat);
      print "";
    }
sub  datumsinvullen8 {
     my ($frame,$test1,$test2,$test3) = @_;
     #my $test = $main::klant;
     my $selection = $frame->{BA_Txt_8_verzekering}->GetStringSelection();
     my $begindat = '';
     my $eindat = '';
     my $eindtest = 0;
     foreach my $contractvolgnr (keys $main::klant->{contracten}) {
         my $contractnaam = $main::klant->{contracten}->[$contractvolgnr]->{naam};
         if ($selection eq $contractnaam ) {
             my $tmpbegindat = $main::klant->{contracten}->[$contractvolgnr]->{startdatum};
             my $tmpeindat = $main::klant->{contracten}->[$contractvolgnr]->{einddatum};
             my $tmpeindjaar = substr ($tmpeindat,6,4);
             my $tmpeindmaand = substr ($tmpeindat,3,2);
             my $tmpeinddag = substr ($tmpeindat,0,2);
             my $tmpeindtest = $tmpeindjaar*10000+$tmpeindmaand*100+$tmpeinddag;
             if ($tmpeindtest > $eindtest) {
                 $eindtest = $tmpeindtest;
                 $begindat = $main::klant->{contracten}->[$contractvolgnr]->{startdatum};
                 $eindat = $main::klant->{contracten}->[$contractvolgnr]->{einddatum};
                }
            }
        }
     $frame->{BA_Txt_8_begindatum}->SetValue($begindat);
     $frame->{BA_Txt_8_einddatum}->SetValue($eindat);
      print "";
    }
sub Bestaande_aandoening_save {
      my ($class,$frame) = @_;
      my $agresso_nr = $main::klant->{Agresso_nummer};
      #my $test = $main::klant->{Agresso_nummer};
      my $fout = 0;
      for (my $nr =0; $nr < 9;$nr++) {
         #my $begindatum = BestaandeAandoening_ErnstigeZiekte->date_convert($frame->{"BA_Txt_$nr\_begindatum"}->GetValue())if ($frame->{"BA_Txt_$nr\_begindatum"}->GetValue() ne '');
         my ($foutbegin,$begindatum,$begindatum_nr) = ('','','');
         ($foutbegin,$begindatum,$begindatum_nr)= convert_date->new($frame->{"BA_Txt_$nr\_begindatum"}->GetValue())if ($frame->{"BA_Txt_$nr\_begindatum"}->GetValue() ne '');
         $fout =1 if ($foutbegin == 1);
         $frame->{"BA_Txt_$nr\_begindatum"}->SetValue($begindatum);
         my ($fouteind,$einddatum,$einddatum_nr) = ('','','');
         #my $einddatum = BestaandeAandoening_ErnstigeZiekte->date_convert($frame->{"BA_Txt_$nr\_einddatum"}->GetValue()) if ($frame->{"BA_Txt_$nr\_einddatum"}->GetValue() ne '');
         ($fouteind,$einddatum,$einddatum_nr) = convert_date->new($frame->{"BA_Txt_$nr\_einddatum"}->GetValue())if ($frame->{"BA_Txt_$nr\_einddatum"}->GetValue() ne '');
         $fout =1 if ($fouteind == 1);
         $frame->{"BA_Txt_$nr\_einddatum"}->SetValue($einddatum);
         $main::klant->{aandoeningen}->[$nr]->{aandoening} = $frame->{"BA_Txt_$nr\_aandoening"}->GetValue();
         $main::klant->{aandoeningen}->[$nr]->{begindatum} = $begindatum;
         $main::klant->{aandoeningen}->[$nr]->{einddatum} =  $einddatum;
         $main::klant->{aandoeningen}->[$nr]->{verzekering} = $frame->{"BA_Txt_$nr\_verzekering"}->GetStringSelection();
      }
      if ($fout ==1) {
           Wx::MessageBox("Er is iets mis met de data",
                                              _T("Begin en Eindatum :"),
                                              wxOK|wxCENTRE,
                                              $frame
                                             );
      }else {
         #my $test =$main::klant;
         my $dbh = sql_toegang_agresso->setup_mssql_connectie($main::test_prod);
         sql_toegang_agresso->afxvmobaandoen_delete_rows($dbh,$agresso_nr); #alle bestaande aandoeningen verwijderen
         sql_toegang_agresso->afxvmobaandoen_insert_row($dbh,$agresso_nr); #alle bestaande aandoeningen terug inzetten
          print "";
         sql_toegang_agresso->disconnect_mssql($dbh);
      }

     return ($fout);
}
sub date_convert {
     my ($class,$value) = @_;
     if ($value =~ m%^\d{2}-\d{2}-\d{4}$%) {
           $value= $&;

          }elsif  ($value =~ m%^\d{2}-\d{2}-\d{2}$%) {
           $value= $&;
           $value =~ s/-/\//g;
           my $deel1 = substr ($value,0,6);
           my $deel2 = substr ($value,6,2);
           $value ="$deel1"."20"."$deel2";
          }elsif  ($value =~ m%^\d{1}-\d{1}-\d{2}$%) {
           $value= $&;
           $value =~ s/-/\//g;
           my $deel1 = substr ($value,0,2);
           my $deel2 = substr ($value,2,2);
           my $deel3 = substr ($value,4,2);
           $value ="0"."$deel1"."0"."$deel2"."20"."$deel3";
          }elsif  ($value =~ m%^\d{2}-\d{1}-\d{2}$%) {
           $value= $&;
           $value =~ s/-/\//g;
           my $deel1 = substr ($value,0,3);
           my $deel2 = substr ($value,3,2);
           my $deel3 = substr ($value,5,2);
           $value ="$deel1"."0"."$deel2"."20"."$deel3";
          }elsif  ($value =~ m%^\d{1}-\d{2}-\d{2}$%) {
           $value= $&;
           $value =~ s/-/\//g;
           my $deel1 = substr ($value,0,2);
           my $deel2 = substr ($value,2,3);
           my $deel3 = substr ($value,5,2);
           $value ="0"."$deel1"."$deel2"."20"."$deel3";
          }elsif  ($value =~ m%^\d{1}-\d{1}-\d{4}$%) {
           $value= $&;
           $value =~ s/-/\//g;
           my $deel1 = substr ($value,0,2);
           my $deel2 = substr ($value,2,2);
           my $deel3 = substr ($value,4,4);
           $value ="0"."$deel1"."0"."$deel2"."$deel3";
          }elsif  ($value =~ m%^\d{2}-\d{1}-\d{4}$%) {
           $value= $&;
           $value =~ s/-/\//g;
           my $deel1 = substr ($value,0,3);
           my $deel2 = substr ($value,3,2);
           my $deel3 = substr ($value,5,4);
           $value ="$deel1"."0"."$deel2"."$deel3";
          }elsif  ($value =~ m%^\d{1}-\d{2}-\d{4}$%) {
           $value= $&;
           $value =~ s/-/\//g;
           my $deel1 = substr ($value,0,2);
           my $deel2 = substr ($value,2,3);
           my $deel3 = substr ($value,5,4);
           $value ="0"."$deel1"."$deel2"."$deel3"; #einde -
          }elsif  ($value =~ m%^\d{1}/\d{1}/\d{2}$%) {
           $value= $&;

           my $deel1 = substr ($value,0,2);
           my $deel2 = substr ($value,2,2);
           my $deel3 = substr ($value,4,2);
           $value ="0"."$deel1"."0"."$deel2"."20"."$deel3";
          }elsif  ($value =~ m%^\d{2}/\d{1}/\d{2}$%) {
           $value= $&;

           my $deel1 = substr ($value,0,3);
           my $deel2 = substr ($value,3,2);
           my $deel3 = substr ($value,5,2);
           $value ="$deel1"."0"."$deel2"."20"."$deel3";
          }elsif  ($value =~ m%^\d{1}/\d{2}/\d{2}$%) {
           $value= $&;

           my $deel1 = substr ($value,0,2);
           my $deel2 = substr ($value,2,3);
           my $deel3 = substr ($value,5,2);
           $value ="0"."$deel1"."$deel2"."20"."$deel3";
          }elsif  ($value =~ m%\d{1}/\d{1}/\d{4}$%) {
           $value= $&;

           my $deel1 = substr ($value,0,2);
           my $deel2 = substr ($value,2,2);
           my $deel3 = substr ($value,4,4);
           $value ="0"."$deel1"."0"."$deel2"."$deel3";
          }elsif  ($value =~ m%^\d{2}/\d{1}/\d{4}$%) {
           $value= $&;

           my $deel1 = substr ($value,0,3);
           my $deel2 = substr ($value,3,2);
           my $deel3 = substr ($value,5,4);
           $value ="$deel1"."0"."$deel2"."$deel3";
          }elsif  ($value =~ m%^\d{1}/\d{2}/\d{4}$%) {
           $value= $&;

           my $deel1 = substr ($value,0,2);
           my $deel2 = substr ($value,2,3);
           my $deel3 = substr ($value,5,4);
           $value ="0"."$deel1"."$deel2"."$deel3";
          }elsif ($value =~ m%^\d{2}/\d{2}/\d{4}$%){ #goed
           $value= $&;
          }elsif  ($value =~ m%^\d{2}/\d{2}/\d{2}$%) {
           $value= $&;
           my $deel1 = substr ($value,0,6);
           my $deel2 = substr ($value,6,2);
           $value ="$deel1"."20"."$deel2";
          }elsif ($value =~ m%^\d{8}$% ) {
           $value= $&;
           my $test = substr ($value,0,2);
           my $test1 = substr ($value,2,2);
           my $test2 = substr ($value,0,4);
           my $test3 = substr ($value,4,2);
           my $test4 = substr ($value,4,4);
           my $test5 = substr ($value,6,2);
           if ($test4 > 1900 and $test < 32 and $test1 < 13 ) {
                my $deel1 = substr ($value,0,2);
                my $deel2 = substr ($value,2,2);
                my $deel3 = substr ($value,4,4);#code
                $value = "$deel1"."/"."$deel2"."/"."$deel3";
               }elsif ($test4 < 1900 and $test2 > 1900 and $test3 <13 and $test5 <32) {
                my $deel1 = substr ($value,0,4);
                my $deel2 = substr ($value,4,2);
                my $deel3 = substr ($value,6,2);
                $value = "$deel3"."/"."$deel2"."/"."$deel1";
               }else {
                $value ='';
               }
          }else {
           $value ='';
          }
          return ($value);
}
     #!/usr/bin/perl -w
use strict;
package ErnstigeZiekte;
     use Wx qw[:everything];
     use base qw(Wx::Frame);
     #use Data::Dumper
     use strict;
     use Wx::Locale gettext => '_T';
     sub new {
         my ($class, $frame) = @_;
         $frame->{EZ_sizer_1} = Wx::FlexGridSizer->new(4,8, 10, 10);
         $frame->{EZ_Button_Ernstige_Ziekte}  = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_EZ}, -1, _T("Ernstige Ziekte"),wxDefaultPosition,wxSIZE(350,20));
         $frame->{EZ_Button_Verzekering}  = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_EZ}, -1, _T("Verzekering"),wxDefaultPosition,wxSIZE(200,20));
         $frame->{EZ_Button_Ernstige_Ziekte_1}  = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_EZ}, -1, _T("Ernstige Ziekte"),wxDefaultPosition,wxSIZE(350,20));
         $frame->{EZ_Button_Verzekering_1}  = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_EZ}, -1, _T("Verzekering"),wxDefaultPosition,wxSIZE(200,20));
         $frame->{EZ_Button_Ernstige_Ziekte_2}  = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_EZ}, -1, _T("Ernstige Ziekte"),wxDefaultPosition,wxSIZE(350,20));
         $frame->{EZ_Button_Verzekering_2}  = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_EZ}, -1, _T("Verzekering"),wxDefaultPosition,wxSIZE(200,20));
         $frame->{EZ_Txt_0_ziekte}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_EZ}, -1, $main::klant->{ziekten}->[0]->{ziekte},wxDefaultPosition,wxSIZE(350,20));
         $frame->{EZ_Txt_0_verzekering}  = Wx::Choice->new($frame->{MainFrameNotebookBoven_pane_EZ}, -1,wxDefaultPosition,wxSIZE(200,20),\@main::verzekeringen_in_xml,,$main::klant->{ziekten}->[0]->{verzekering});
         $frame->{EZ_Txt_0_verzekering}->SetStringSelection($main::klant->{ziekten}->[0]->{verzekering});
         #$frame->{EZ_Txt_0_verzekering}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_EZ}, -1, $main::klant->{ziekten}->[0]->{verzekering},wxDefaultPosition,wxSIZE(200,20));
         $frame->{EZ_Txt_1_ziekte}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_EZ}, -1, $main::klant->{ziekten}->[1]->{ziekte},wxDefaultPosition,wxSIZE(350,20));
         $frame->{EZ_Txt_1_verzekering}  = Wx::Choice->new($frame->{MainFrameNotebookBoven_pane_EZ}, -1,wxDefaultPosition,wxSIZE(200,20),\@main::verzekeringen_in_xml,,$main::klant->{ziekten}->[1]->{verzekering});
         $frame->{EZ_Txt_1_verzekering}->SetStringSelection($main::klant->{ziekten}->[1]->{verzekering});
        # $frame->{EZ_Txt_1_verzekering}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_EZ}, -1, $main::klant->{ziekten}->[1]->{verzekering},wxDefaultPosition,wxSIZE(200,20));
         $frame->{EZ_Txt_2_ziekte}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_EZ}, -1, $main::klant->{ziekten}->[2]->{ziekte},wxDefaultPosition,wxSIZE(350,20));
         $frame->{EZ_Txt_2_verzekering}  = Wx::Choice->new($frame->{MainFrameNotebookBoven_pane_EZ}, -1,wxDefaultPosition,wxSIZE(200,20),\@main::verzekeringen_in_xml,,$main::klant->{ziekten}->[2]->{verzekering});
         $frame->{EZ_Txt_2_verzekering}->SetStringSelection($main::klant->{ziekten}->[2]->{verzekering});
         #$frame->{EZ_Txt_2_verzekering}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_EZ}, -1, $main::klant->{ziekten}->[2]->{verzekering},wxDefaultPosition,wxSIZE(200,20));
         $frame->{EZ_Txt_3_ziekte}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_EZ}, -1, $main::klant->{ziekten}->[3]->{ziekte},wxDefaultPosition,wxSIZE(350,20));
         $frame->{EZ_Txt_3_verzekering}  = Wx::Choice->new($frame->{MainFrameNotebookBoven_pane_EZ}, -1,wxDefaultPosition,wxSIZE(200,20),\@main::verzekeringen_in_xml,,$main::klant->{ziekten}->[3]->{verzekering});
         $frame->{EZ_Txt_3_verzekering}->SetStringSelection($main::klant->{ziekten}->[3]->{verzekering});
         #$frame->{EZ_Txt_3_verzekering}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_EZ}, -1, $main::klant->{ziekten}->[3]->{verzekering},wxDefaultPosition,wxSIZE(200,20));
         $frame->{EZ_Txt_4_ziekte}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_EZ}, -1, $main::klant->{ziekten}->[4]->{ziekte},wxDefaultPosition,wxSIZE(350,20));
         $frame->{EZ_Txt_4_verzekering}  = Wx::Choice->new($frame->{MainFrameNotebookBoven_pane_EZ}, -1,wxDefaultPosition,wxSIZE(200,20),\@main::verzekeringen_in_xml,,$main::klant->{ziekten}->[4]->{verzekering});
         $frame->{EZ_Txt_4_verzekering}->SetStringSelection($main::klant->{ziekten}->[4]->{verzekering});
         #$frame->{EZ_Txt_4_verzekering}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_EZ}, -1, $main::klant->{ziekten}->[4]->{verzekering},wxDefaultPosition,wxSIZE(200,20));
         $frame->{EZ_Txt_5_ziekte}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_EZ}, -1, $main::klant->{ziekten}->[5]->{ziekte},wxDefaultPosition,wxSIZE(350,20));
         $frame->{EZ_Txt_5_verzekering}  = Wx::Choice->new($frame->{MainFrameNotebookBoven_pane_EZ}, -1,wxDefaultPosition,wxSIZE(200,20),\@main::verzekeringen_in_xml,,$main::klant->{ziekten}->[5]->{verzekering});
         $frame->{EZ_Txt_5_verzekering}->SetStringSelection($main::klant->{ziekten}->[5]->{verzekering});
         #$frame->{EZ_Txt_5_verzekering}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_EZ}, -1, $main::klant->{ziekten}->[5]->{verzekering},wxDefaultPosition,wxSIZE(200,20));
         $frame->{EZ_Txt_6_ziekte}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_EZ}, -1, $main::klant->{ziekten}->[6]->{ziekte},wxDefaultPosition,wxSIZE(350,20));
         $frame->{EZ_Txt_6_verzekering}  = Wx::Choice->new($frame->{MainFrameNotebookBoven_pane_EZ}, -1,wxDefaultPosition,wxSIZE(200,20),\@main::verzekeringen_in_xml,,$main::klant->{ziekten}->[6]->{verzekering});
         $frame->{EZ_Txt_6_verzekering}->SetStringSelection($main::klant->{ziekten}->[6]->{verzekering});
         #$frame->{EZ_Txt_6_verzekering} =
         #Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_EZ}, -1,
         #$main::klant->{ziekten}->[6]->{verzekering},wxDefaultPosition,wxSIZE(200,20));
         $frame->{EZ_Txt_7_ziekte}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_EZ}, -1, $main::klant->{ziekten}->[7]->{ziekte},wxDefaultPosition,wxSIZE(350,20));
         $frame->{EZ_Txt_7_verzekering}  = Wx::Choice->new($frame->{MainFrameNotebookBoven_pane_EZ}, -1,wxDefaultPosition,wxSIZE(200,20),\@main::verzekeringen_in_xml,,$main::klant->{ziekten}->[7]->{verzekering});
         $frame->{EZ_Txt_7_verzekering}->SetStringSelection($main::klant->{ziekten}->[7]->{verzekering});
         #$frame->{EZ_Txt_7_verzekering}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_EZ}, -1, $main::klant->{ziekten}->[7]->{verzekering},wxDefaultPosition,wxSIZE(200,20));
         $frame->{EZ_Txt_8_ziekte}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_EZ}, -1, $main::klant->{ziekten}->[8]->{ziekte},wxDefaultPosition,wxSIZE(350,20));
         $frame->{EZ_Txt_8_verzekering}  = Wx::Choice->new($frame->{MainFrameNotebookBoven_pane_EZ}, -1,wxDefaultPosition,wxSIZE(200,20),\@main::verzekeringen_in_xml,,$main::klant->{ziekten}->[8]->{verzekering});
         $frame->{EZ_Txt_8_verzekering}->SetStringSelection($main::klant->{ziekten}->[8]->{verzekering});
         #$frame->{EZ_Txt_8_verzekering}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_EZ}, -1, $main::klant->{ziekten}->[8]->{verzekering},wxDefaultPosition,wxSIZE(200,20));
         #
         #$frame->{EZ_Button_OK} =  Wx::Button->new($frame->{MainFrameNotebookBoven_pane_EZ}, -1, _T("OK"),wxDefaultPosition,wxSIZE(140,40));
         #$frame->{EZ_Button_Cancel} = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_EZ}, -1,_T("Cancel"),wxDefaultPosition,wxSIZE(140,40));
         $frame->{EZ_panel_1} = Wx::Panel->new($frame->{MainFrameNotebookBoven_pane_EZ},-1,wxDefaultPosition,wxSIZE(20,20));
         #$frame->{BA_EZ_sizer_1}->Add($frame->{BA_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         #Rij1
         $frame->{EZ_sizer_1}->Add( $frame->{EZ_Button_Ernstige_Ziekte} , 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{EZ_sizer_1}->Add($frame->{EZ_Button_Verzekering}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{EZ_sizer_1}->Add($frame->{EZ_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{EZ_sizer_1}->Add($frame->{EZ_Button_Ernstige_Ziekte_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{EZ_sizer_1}->Add($frame->{EZ_Button_Verzekering_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{EZ_sizer_1}->Add($frame->{EZ_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{EZ_sizer_1}->Add($frame->{EZ_Button_Ernstige_Ziekte_2}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{EZ_sizer_1}->Add($frame->{EZ_Button_Verzekering_2}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         #rij2
         $frame->{EZ_sizer_1}->Add($frame->{EZ_Txt_0_ziekte}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{EZ_sizer_1}->Add($frame->{EZ_Txt_0_verzekering}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{EZ_sizer_1}->Add($frame->{EZ_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{EZ_sizer_1}->Add($frame->{EZ_Txt_3_ziekte}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{EZ_sizer_1}->Add($frame->{EZ_Txt_3_verzekering}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{EZ_sizer_1}->Add($frame->{EZ_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{EZ_sizer_1}->Add($frame->{EZ_Txt_6_ziekte}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{EZ_sizer_1}->Add($frame->{EZ_Txt_6_verzekering}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         #rij3
         $frame->{EZ_sizer_1}->Add($frame->{EZ_Txt_1_ziekte}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{EZ_sizer_1}->Add($frame->{EZ_Txt_1_verzekering}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{EZ_sizer_1}->Add($frame->{EZ_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{EZ_sizer_1}->Add($frame->{EZ_Txt_4_ziekte}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{EZ_sizer_1}->Add($frame->{EZ_Txt_4_verzekering}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{EZ_sizer_1}->Add($frame->{EZ_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{EZ_sizer_1}->Add($frame->{EZ_Txt_7_ziekte}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{EZ_sizer_1}->Add($frame->{EZ_Txt_7_verzekering}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         #rij4
         $frame->{EZ_sizer_1}->Add($frame->{EZ_Txt_2_ziekte}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{EZ_sizer_1}->Add($frame->{EZ_Txt_2_verzekering}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{EZ_sizer_1}->Add($frame->{EZ_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{EZ_sizer_1}->Add($frame->{EZ_Txt_5_ziekte}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{EZ_sizer_1}->Add($frame->{EZ_Txt_5_verzekering}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{EZ_sizer_1}->Add($frame->{EZ_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{EZ_sizer_1}->Add($frame->{EZ_Txt_8_ziekte}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{EZ_sizer_1}->Add($frame->{EZ_Txt_8_verzekering}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         #rij5
          #$frame->{EZ_sizer_1}->Add($frame->{EZ_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
          #$frame->{EZ_sizer_1}->Add($frame->{EZ_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
          #$frame->{EZ_sizer_1}->Add($frame->{EZ_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
          #$frame->{EZ_sizer_1}->Add($frame->{EZ_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
          #$frame->{EZ_sizer_1}->Add($frame->{EZ_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
          #$frame->{EZ_sizer_1}->Add($frame->{EZ_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
          #$frame->{EZ_sizer_1}->Add($frame->{EZ_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
          #$frame->{EZ_sizer_1}->Add($frame->{EZ_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         #rij6
         #$frame->{EZ_sizer_1}->Add($frame->{EZ_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         #$frame->{EZ_sizer_1}->Add($frame->{EZ_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         #$frame->{EZ_sizer_1}->Add($frame->{EZ_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         #$frame->{EZ_sizer_1}->Add($frame->{EZ_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         #$frame->{EZ_sizer_1}->Add($frame->{EZ_Button_OK}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         #$frame->{EZ_sizer_1}->Add($frame->{EZ_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         #$frame->{EZ_sizer_1}->Add($frame->{EZ_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         #$frame->{EZ_sizer_1}->Add($frame->{EZ_Button_Cancel}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         #Wx::Event::EVT_BUTTON( $frame,$frame->{EZ_Button_Ernstige_Ziekte},\&Ernstige_ziekte_aandoening_save);
         #Wx::Event::EVT_BUTTON( $frame,$frame->{EZ_Button_Ernstige_Ziekte_1},\&Ernstige_ziekte_aandoening_save);
         #Wx::Event::EVT_BUTTON( $frame,$frame->{EZ_Button_Ernstige_Ziekte_2},\&Ernstige_ziekte_aandoening_save);
     }
     sub Ernstige_ziekte_aandoening_save {
         my ($class,$frame) = @_;
         my $agresso_nr = $main::klant->{Agresso_nummer};
         #my $test = $main::klant->{Agresso_nummer};
         for (my $nr =0; $nr < 9;$nr++) {
              $main::klant->{ziekten}->[$nr]->{ziekte} = $frame->{"EZ_Txt_$nr\_ziekte"}->GetValue();
              $main::klant->{ziekten}->[$nr]->{verzekering} = $frame->{"EZ_Txt_$nr\_verzekering"}->GetStringSelection();
            }
         my $dbh = sql_toegang_agresso->setup_mssql_connectie($main::test_prod);
         sql_toegang_agresso->afxvmobziekten_delete_rows($dbh,$agresso_nr); #alle bestaande aandoeningen verwijderen
         sql_toegang_agresso->afxvmobziekten_insert_row($dbh,$agresso_nr); #alle bestaande aandoeningen terug inzetten
         print "";
         sql_toegang_agresso->disconnect_mssql($dbh);
        }

package Lid_Opname_Verzekering;
     use Wx qw[:everything];
     use base qw(Wx::Frame);
     use Wx qw(wxEVT_SCROLL_TOP wxEVT_SCROLL_BOTTOM wxEVT_SCROLL_LINEUP
               wxEVT_SCROLL_LINEDOWN wxEVT_SCROLL_PAGEUP wxEVT_SCROLL_PAGEDOWN
               wxEVT_SCROLL_THUMBTRACK wxEVT_SCROLL_THUMBRELEASE );
     use Wx::Event qw( EVT_BUTTON EVT_TEXT_ENTER EVT_UPDATE_UI );

     use Wx::Perl::ListCtrl;
     #use Data::Dumper
     use strict;
     use Wx::Locale gettext => '_T';
     sub new {
         #my $test = ;
         my ($class, $frame) = @_;
         $frame->{lov_sizer_1} = Wx::FlexGridSizer->new(6,11, 10, 10);
         $frame->{lov_Button_Agresso_Nummer}  = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_lov}, -1, _T("Agresso Nummer:"),wxDefaultPosition,wxSIZE(100,20));
         $frame->{lov_Txt_Agressso_nr}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_lov}, -1,("$main::klant->{Agresso_nummer}"),wxDefaultPosition,wxSIZE(300,20));
         $frame->{lov_Button_Naam}  = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_lov}, -1, _T("Naam:"), wxDefaultPosition,wxSIZE(100,20));
         $frame->{lov_Txt_Naam}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_lov}, -1,($main::klant->{naam}), wxDefaultPosition,wxSIZE(300,20));
         $frame->{lov_Button_GeboorteDatum}  = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_lov}, -1, _T("Geboortedatum:"),wxDefaultPosition,wxSIZE(100,20));
         $frame->{lov_Txt_GeboorteDatum}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_lov}, -1,$main::klant->{geboortedatum},wxDefaultPosition,wxSIZE(300,20));
         $frame->{lov_Button_RijksReg_nr}  = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_lov}, -1, _T("Rijksreg. Nr."),wxDefaultPosition,wxSIZE(100,20));
         $frame->{lov_Txt_RijksReg_nr}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_lov}, -1,($main::klant->{Rijksreg_Nr}),wxDefaultPosition,wxSIZE(300,20));
         $frame->{lov_Txt_0_contracten_naam}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_lov}, -1,$main::klant->{contracten}->[0]->{naam},wxDefaultPosition,wxSIZE(200,20));
         $frame->{lov_Txt_0_contracten_startdatum}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_lov}, -1,$main::klant->{contracten}->[0]->{startdatum},wxDefaultPosition,wxSIZE(80,20));
         $frame->{lov_Txt_0_contracten_einddatum}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_lov}, -1,$main::klant->{contracten}->[0]->{einddatum},wxDefaultPosition,wxSIZE(80,20));
         $frame->{lov_Txt_1_contracten_naam}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_lov}, -1,$main::klant->{contracten}->[1]->{naam},wxDefaultPosition,wxSIZE(200,20));
         $frame->{lov_Txt_1_contracten_startdatum}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_lov}, -1,$main::klant->{contracten}->[1]->{startdatum},wxDefaultPosition,wxSIZE(80,20));
         $frame->{lov_Txt_1_contracten_einddatum}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_lov}, -1,$main::klant->{contracten}->[1]->{einddatum},wxDefaultPosition,wxSIZE(80,20));
         $frame->{lov_Txt_2_contracten_naam}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_lov}, -1,$main::klant->{contracten}->[2]->{naam},wxDefaultPosition,wxSIZE(200,20));
         $frame->{lov_Txt_2_contracten_startdatum}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_lov}, -1,$main::klant->{contracten}->[2]->{startdatum},wxDefaultPosition,wxSIZE(80,20));
         $frame->{lov_Txt_2_contracten_einddatum}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_lov}, -1,$main::klant->{contracten}->[2]->{einddatum},wxDefaultPosition,wxSIZE(80,20));
         $frame->{lov_Txt_3_contracten_naam}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_lov}, -1,$main::klant->{contracten}->[3]->{naam},wxDefaultPosition,wxSIZE(200,20));
         $frame->{lov_Txt_3_contracten_startdatum}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_lov}, -1,$main::klant->{contracten}->[3]->{startdatum},wxDefaultPosition,wxSIZE(80,20));
         $frame->{lov_Txt_3_contracten_einddatum}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_lov}, -1,$main::klant->{contracten}->[3]->{einddatum},wxDefaultPosition,wxSIZE(80,20));
         $frame->{lov_Txt_4_contracten_naam}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_lov}, -1,$main::klant->{contracten}->[4]->{naam},wxDefaultPosition,wxSIZE(200,20));
         $frame->{lov_Txt_4_contracten_startdatum}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_lov}, -1,$main::klant->{contracten}->[4]->{startdatum},wxDefaultPosition,wxSIZE(80,20));
         $frame->{lov_Txt_4_contracten_einddatum}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_lov}, -1,$main::klant->{contracten}->[4]->{einddatum},wxDefaultPosition,wxSIZE(80,20));


         $frame->{lov_Txt_0_contracten_dossiernr}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_lov}, -1,$main::klant->{contracten}->[0]->{contract_nr},wxDefaultPosition,wxSIZE(80,20));
         $frame->{lov_Txt_1_contracten_dossiernr}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_lov}, -1,$main::klant->{contracten}->[1]->{contract_nr},wxDefaultPosition,wxSIZE(80,20));
         $frame->{lov_Txt_2_contracten_dossiernr}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_lov}, -1,$main::klant->{contracten}->[2]->{contract_nr},wxDefaultPosition,wxSIZE(80,20));
         $frame->{lov_Txt_3_contracten_dossiernr}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_lov}, -1,$main::klant->{contracten}->[3]->{contract_nr},wxDefaultPosition,wxSIZE(80,20));
         $frame->{lov_Txt_4_contracten_dossiernr}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_lov}, -1,$main::klant->{contracten}->[4]->{contract_nr},wxDefaultPosition,wxSIZE(80,20));

         $frame->{lov_Button_Verzekering}  = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_lov}, -1, _T("Verzekering"),wxDefaultPosition,wxSIZE(200,20));
         $frame->{lov_Button_Begin}  = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_lov}, -1, _T("Begin"),wxDefaultPosition,wxSIZE(80,20));
         $frame->{lov_Button_Eind}  = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_lov}, -1, _T("Eind"),wxDefaultPosition,wxSIZE(80,20));
         $frame->{lov_Button_ZKF}  = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_lov}, -1, _T("ZKF/GKD"),wxDefaultPosition,wxSIZE(50,20));
         $frame->{lov_Button_Dossier}  = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_lov}, -1, _T("Dossier Nr"),wxDefaultPosition,wxSIZE(80,20));
          $frame->{lov_Button_Wacht}  = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_lov}, -1, _T("Wacht"),wxDefaultPosition,wxSIZE(80,20));
         $frame->{lov_Txt_0_contracten_zkfnr}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_lov}, -1,$main::klant->{contracten}->[0]->{zkf_nr},wxDefaultPosition,wxSIZE(50,20));
         $frame->{lov_Txt_1_contracten_zkfnr}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_lov}, -1,$main::klant->{contracten}->[1]->{zkf_nr},wxDefaultPosition,wxSIZE(50,20));
         $frame->{lov_Txt_2_contracten_zkfnr}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_lov}, -1,$main::klant->{contracten}->[2]->{zkf_nr},wxDefaultPosition,wxSIZE(50,20));
         $frame->{lov_Txt_3_contracten_zkfnr}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_lov}, -1,$main::klant->{contracten}->[3]->{zkf_nr},wxDefaultPosition,wxSIZE(50,20));
         $frame->{lov_Txt_4_contracten_zkfnr}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_lov}, -1,$main::klant->{contracten}->[4]->{zkf_nr},wxDefaultPosition,wxSIZE(50,20));
         $frame->{lov_Txt_0_contracten_wachtdatum}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_lov}, -1,$main::klant->{contracten}->[0]->{wachtdatum},wxDefaultPosition,wxSIZE(80,20));
         $frame->{lov_Txt_1_contracten_wachtdatum}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_lov}, -1,$main::klant->{contracten}->[1]->{wachtdatum},wxDefaultPosition,wxSIZE(80,20));
         $frame->{lov_Txt_2_contracten_wachtdatum}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_lov}, -1,$main::klant->{contracten}->[2]->{wachtdatum},wxDefaultPosition,wxSIZE(80,20));
         $frame->{lov_Txt_3_contracten_wachtdatum}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_lov}, -1,$main::klant->{contracten}->[3]->{wachtdatum},wxDefaultPosition,wxSIZE(80,20));
         $frame->{lov_Txt_4_contracten_wachtdatum}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_lov}, -1,$main::klant->{contracten}->[4]->{wachtdatum},wxDefaultPosition,wxSIZE(80,20));
         #$frame->{lov_Button_OK} =  Wx::Button->new($frame->{MainFrameNotebookBoven_pane_lov}, -1, _T("OK"),wxDefaultPosition,wxSIZE(140,40));
         #$frame->{lov_Button_Cancel} = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_lov}, -1,_T("Cancel"),wxDefaultPosition,wxSIZE(140,40));
         $frame->{lov_chk_0_Contract}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_lov}, -1,$main::contracts_check[0],wxDefaultPosition,wxSIZE(15,20));
         $frame->{lov_chk_1_Contract}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_lov}, -1,$main::contracts_check[1],wxDefaultPosition,wxSIZE(15,20));
         $frame->{lov_chk_2_Contract}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_lov}, -1,$main::contracts_check[2],wxDefaultPosition,wxSIZE(15,20));
         $frame->{lov_chk_3_Contract}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_lov}, -1,$main::contracts_check[3],wxDefaultPosition,wxSIZE(15,20));
         $frame->{lov_chk_4_Contract}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_lov}, -1,$main::contracts_check[4],wxDefaultPosition,wxSIZE(15,20));
         #Rij1
         #kolom 1 +2
         $frame->{lov_panel_1} = Wx::Panel->new($frame->{MainFrameNotebookBoven_pane_lov},-1,wxDefaultPosition,wxSIZE(20,20));
         $frame->{lov_sizer_1}->Add($frame->{lov_Button_Agresso_Nummer}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_Txt_Agressso_nr}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         #kolom 3+4+5+7+8
         $frame->{lov_sizer_1}->Add($frame->{lov_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_Button_Verzekering}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_Button_Begin}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_Button_Eind}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_Button_Wacht}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_Button_ZKF}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_Button_Dossier}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);

         #Rij2
         #kolom 1 +2
         $frame->{lov_sizer_1}->Add($frame->{lov_Button_Naam}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_Txt_Naam}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         #kolom 3+4+5+6+7+8
         $frame->{lov_sizer_1}->Add($frame->{lov_chk_0_Contract}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_Txt_0_contracten_naam}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_Txt_0_contracten_startdatum}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_Txt_0_contracten_einddatum}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_Txt_0_contracten_wachtdatum}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_Txt_0_contracten_zkfnr}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_Txt_0_contracten_dossiernr}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         #
         #Rij 3
         #kolom 1 +2
         $frame->{lov_sizer_1}->Add($frame->{lov_Button_RijksReg_nr}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_Txt_RijksReg_nr}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         #kolom 3+4+5+6+7+8
         $frame->{lov_sizer_1}->Add($frame->{lov_chk_1_Contract}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_Txt_1_contracten_naam}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_Txt_1_contracten_startdatum}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_Txt_1_contracten_einddatum}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_Txt_1_contracten_wachtdatum}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_Txt_1_contracten_zkfnr}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_Txt_1_contracten_dossiernr}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         #Rij4
         #kolom 1 +2
         $frame->{lov_sizer_1}->Add( $frame->{lov_Button_GeboorteDatum}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_Txt_GeboorteDatum} , 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         #kolom 3+4+5+6+7+8
         $frame->{lov_sizer_1}->Add($frame->{lov_chk_2_Contract}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_Txt_2_contracten_naam}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_Txt_2_contracten_startdatum}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_Txt_2_contracten_einddatum}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_Txt_2_contracten_wachtdatum}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_Txt_2_contracten_zkfnr}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{MainFrameNotebookBoven_pane_lov}->SetSizer($frame->{lov_sizer_1});
         $frame->{lov_sizer_1}->Add($frame->{lov_Txt_2_contracten_dossiernr}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         #rij 5
         $frame->{lov_sizer_1}->Add($frame->{lov_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_chk_3_Contract}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_Txt_3_contracten_naam}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_Txt_3_contracten_startdatum}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_Txt_3_contracten_einddatum}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_Txt_3_contracten_wachtdatum}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_Txt_3_contracten_zkfnr}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{MainFrameNotebookBoven_pane_lov}->SetSizer($frame->{lov_sizer_1});
         $frame->{lov_sizer_1}->Add($frame->{lov_Txt_3_contracten_dossiernr}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         ##rij 6
         $frame->{lov_sizer_1}->Add($frame->{lov_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_chk_4_Contract}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_Txt_4_contracten_naam}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_Txt_4_contracten_startdatum}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_Txt_4_contracten_einddatum}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_Txt_4_contracten_wachtdatum}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_Txt_4_contracten_zkfnr}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{MainFrameNotebookBoven_pane_lov}->SetSizer($frame->{lov_sizer_1});
         $frame->{lov_sizer_1}->Add($frame->{lov_Txt_4_contracten_dossiernr}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{lov_sizer_1}->Add($frame->{lov_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         Wx::Event::EVT_BUTTON( $frame,$frame->{lov_Button_RijksReg_nr},\&RijksRegister_Nummer);
         Wx::Event::EVT_BUTTON($frame,$frame->{lov_Button_ZKF},\&gkd);
         return ($frame);
        }

     sub RijksRegister_Nummer {
         my $rr_nr = $frame->{lov_Txt_RijksReg_nr}->GetValue;
         $rr_nr =~ s/\s//g;
         $rr_nr =~ s/-//g;
         $rr_nr = sprintf("%011s",$rr_nr);
         print "";
         $main::bolean_wachttijd= '';
         # my $test = $main::klant;
         Lid_Opname_Verzekering->Reset;
         #$main::klant = ();
         $main::gkd_commentaar =();
         #my $test1 =$main::klant;
         #print '';
         #main->agresso_get_customer_info_rr_nr($rijks_register_nummer);
         my $was_lid;
         my $was_lid_zkf = '';
         my $lid_gevonden=0;
         foreach my $zf  (keys $main::agresso_instellingen->{verzekeringen}) {
             my $zf_nr = substr($zf,3,3);
             my $settings = settings->new($zf_nr);
             my $dbconnectie = connectdb->connect_as400 ($settings->{user_name},$settings->{password},$settings->{name_as400});
             my $min_einddatum_contract = $vandaag;
             my ($externnummer,$einddatum_t) =as400_gegevens->natreg_to_extern($dbconnectie,$rr_nr,$settings,$min_einddatum_contract);
             if ($externnummer =~ m/\d+/) {
                  my $bool = $frame->Close();
                  $lid_gevonden=1;
                  main->new($externnummer,$zf_nr);
               }else {
                $min_einddatum_contract = $vandaag-30000;
                ($was_lid->{$zf_nr}->{ext_nr},$was_lid->{$zf_nr}->{einddatum}) =as400_gegevens->natreg_to_extern_zonder_einddatum($dbconnectie,$rr_nr,$settings,$min_einddatum_contract);
                print '';
               }
          }
         #zoek laatste ziekenfonds
         if ($lid_gevonden !=1) {
         my $laatste_zkf;
         my $laatse_datum=0;
         foreach my $zk (sort keys $was_lid) {
             $laatse_datum = $was_lid->{$zk}->{einddatum} if ($was_lid->{$zk}->{einddatum} >= $laatse_datum );
             $laatste_zkf =$zk if ($was_lid->{$zk}->{einddatum} >= $laatse_datum );
         }
         my $ext_nr = $was_lid->{$laatste_zkf}->{ext_nr};        
         if ($ext_nr > 0 ) {
          my $laatste_dat= $laatse_datum -10000;
          my $bool = $frame->Close();
          main->new($ext_nr,$laatste_zkf);
         }else {
               #print '';
               Wx::MessageBox( _T("Kan $rr_nr \n\nNiet inzetten\ncheck CS15 of rijskregnr"),
                                         _T("Klant naar Agresso"),
                                          wxOK|wxCENTRE,
                                        $main::frame
                                   );#cod
               #print '';
         }
         }   
          
     }
     sub ArgV_RijksRegister_Nummer {
         my ($class,$rr_nr) = @_;
         $rr_nr =~ s/\s//g;
         $rr_nr =~ s/-//g;
         $rr_nr = sprintf("%011s",$rr_nr);
         print "";
         $main::bolean_wachttijd= '';
         # my $test = $main::klant;
         $main::klant = ();
         $main::gkd_commentaar =();
         #my $test1 =$main::klant;
         #print '';
         #main->agresso_get_customer_info_rr_nr($rijks_register_nummer);
         my $was_lid_ext_nr = '';
         my $was_lid;
         my $was_lid_zkf = '';
         my $lid_gevonden=0;
         foreach my $zf  (keys $main::agresso_instellingen->{verzekeringen}) {
             my $zf_nr = substr($zf,3,3);
             my $settings = settings->new($zf_nr);
             my $dbconnectie = connectdb->connect_as400 ($settings->{user_name},$settings->{password},$settings->{name_as400});
             my $min_einddatum_contract = $vandaag;           
             my ($externnummer,$einddatum_t) =as400_gegevens->natreg_to_extern($dbconnectie,$rr_nr,$settings,$vandaag);
             if ($externnummer =~ m/\d+/) {
                  my $bool = $frame->Close();
                  $lid_gevonden=1;
                  main->new($externnummer,$zf_nr);
               }else {
                $min_einddatum_contract = $vandaag-30000;
                ($was_lid->{$zf_nr}->{ext_nr},$was_lid->{$zf_nr}->{einddatum}) =as400_gegevens->natreg_to_extern_zonder_einddatum($dbconnectie,$rr_nr,$settings,$min_einddatum_contract);
               }

          }
         #zoek laatste ziekenfonds
         if ($lid_gevonden !=1) {
         my $laatste_zkf;
         my $laatse_datum=0;
         foreach my $zk (sort keys $was_lid) {
             $laatse_datum = $was_lid->{$zk}->{einddatum} if ($was_lid->{$zk}->{einddatum} >= $laatse_datum );
             $laatste_zkf =$zk if ($was_lid->{$zk}->{einddatum} >= $laatse_datum );
         }
         my $ext_nr = $was_lid->{$laatste_zkf}->{ext_nr};        
         if ($ext_nr > 0 ) {
          my $laatste_dat= $laatse_datum -10000;
          my $bool = $frame->Close();
          main->new($ext_nr,$laatste_zkf);
         }
        }

     }

     sub gkd {
      my ($frame, $evt) = @_;
      my $test = $main::klant;
      my $externnummer =$main::klant->{ExternNummer};
      my $zkf = $main::klant->{zkf_nr};
      if ($zkf == 203) {
           system(1, 'start',"http://dgc.vnz.be/dgccaller.jsp?theexid=$externnummer");#code
          }elsif ($zkf == 235)  {
           system(1, 'start',"http://dgc.vnz235.be/dgccaller.jsp?theexid=$externnummer");#code
          }else {
            foreach my $zf  (keys $main::agresso_instellingen->{verzekeringen}) {
                my $zf_nr = substr($zf,3,3);
                my $settings = settings->new($zf_nr);
                my $dbconnectie = connectdb->connect_as400 ($settings->{user_name},$settings->{password},$settings->{name_as400});
                my $externr = as400_gegevens->check_zkf_extern($dbconnectie,$externnummer,$settings);
                if ($externr =~ m/\d+/) {
                      if ($zf_nr == 203) {
                          system(1, 'start',"http://dgc.vnz.be/dgccaller.jsp?theexid=$externnummer");#code
                          $main::klant->{zkf_nr} = $zf_nr;
                         }elsif ($zf_nr == 235)  {
                          system(1, 'start',"http://dgc.vnz235.be/dgccaller.jsp?theexid=$externnummer");#code
                          $main::klant->{zkf_nr} = $zf_nr;
                         }
                    }
               }
          }
     }
     sub Reset {
         my($class) = @_;
         undef $main::klant;
         undef %main::DATA;
         $main::cdata='';
         undef $main::ziekenfonds_nummer;
         undef $main::externnummer;
         undef $main::gkd_commentaar;
         $main::total_ok =0;
         $main::total_nok=0;
         $main::bestaande_klant =0;
         $main::premie = 0;
         undef $main::rijks_register_nummer;
         undef $main::bolean_wachttijd;
         $main::frame->{lov_Txt_Agressso_nr}->SetValue('');
         $main::frame->{lov_Txt_Naam}->SetValue('');
         $main::frame->{lov_Txt_GeboorteDatum}->SetValue('');
         $main::frame->{lov_Txt_RijksReg_nr}->SetValue('');
         $main::frame->{lov_Txt_0_contracten_startdatum}->SetValue('');
         $main::frame->{lov_Txt_1_contracten_startdatum}->SetValue('');
         $main::frame->{lov_Txt_2_contracten_startdatum}->SetValue('');
         $main::frame->{lov_Txt_3_contracten_startdatum}->SetValue('');
         $main::frame->{lov_Txt_4_contracten_startdatum}->SetValue('');
         $main::frame->{lov_Txt_0_contracten_einddatum}->SetValue('');
         $main::frame->{lov_Txt_1_contracten_einddatum}->SetValue('');
         $main::frame->{lov_Txt_2_contracten_einddatum}->SetValue('');
         $main::frame->{lov_Txt_3_contracten_einddatum}->SetValue('');
         $main::frame->{lov_Txt_4_contracten_einddatum}->SetValue('');
         $main::frame->{lov_Txt_0_contracten_naam}->SetValue('');
         $main::frame->{lov_Txt_1_contracten_naam}->SetValue('');
         $main::frame->{lov_Txt_2_contracten_naam}->SetValue('');
         $main::frame->{lov_Txt_3_contracten_naam}->SetValue('');
         $main::frame->{lov_Txt_4_contracten_naam}->SetValue('');
         $main::frame->{lov_Txt_0_contracten_dossiernr}->SetValue('');
         $main::frame->{lov_Txt_1_contracten_dossiernr}->SetValue('');
         $main::frame->{lov_Txt_2_contracten_dossiernr}->SetValue('');
         $main::frame->{lov_Txt_3_contracten_dossiernr}->SetValue('');
         $main::frame->{lov_Txt_4_contracten_dossiernr}->SetValue('');
         $main::frame->{lov_Txt_0_contracten_zkfnr}->SetValue('');
         $main::frame->{lov_Txt_1_contracten_zkfnr}->SetValue('');
         $main::frame->{lov_Txt_2_contracten_zkfnr}->SetValue('');
         $main::frame->{lov_Txt_3_contracten_zkfnr}->SetValue('');
         $main::frame->{lov_Txt_4_contracten_zkfnr}->SetValue('');
         $main::frame->{lov_Txt_0_contracten_wachtdatum}->SetValue('');
         $main::frame->{lov_Txt_1_contracten_wachtdatum}->SetValue('');
         $main::frame->{lov_Txt_2_contracten_wachtdatum}->SetValue('');
         $main::frame->{lov_Txt_3_contracten_wachtdatum}->SetValue('');
         $main::frame->{lov_Txt_4_contracten_wachtdatum}->SetValue('');
         $main::frame->{lov_chk_0_Contract}->SetValue('');
         $main::frame->{lov_chk_1_Contract}->SetValue('');
         $main::frame->{lov_chk_2_Contract}->SetValue('');
         $main::frame->{lov_chk_3_Contract}->SetValue('');

         $main::frame->{BA_Txt_0_aandoening}->SetValue('');
         $main::frame->{BA_Txt_1_aandoening}->SetValue('');
         $main::frame->{BA_Txt_2_aandoening}->SetValue('');
         $main::frame->{BA_Txt_3_aandoening}->SetValue('');
         $main::frame->{BA_Txt_4_aandoening}->SetValue('');
         $main::frame->{BA_Txt_5_aandoening}->SetValue('');
         $main::frame->{BA_Txt_6_aandoening}->SetValue('');
         $main::frame->{BA_Txt_7_aandoening}->SetValue('');
         $main::frame->{BA_Txt_8_aandoening}->SetValue('');

         $main::frame->{BA_Txt_0_begindatum}->SetValue('');
         $main::frame->{BA_Txt_1_begindatum}->SetValue('');
         $main::frame->{BA_Txt_2_begindatum}->SetValue('');
         $main::frame->{BA_Txt_3_begindatum}->SetValue('');
         $main::frame->{BA_Txt_4_begindatum}->SetValue('');
         $main::frame->{BA_Txt_5_begindatum}->SetValue('');
         $main::frame->{BA_Txt_6_begindatum}->SetValue('');
         $main::frame->{BA_Txt_7_begindatum}->SetValue('');
         $main::frame->{BA_Txt_8_begindatum}->SetValue('');

         $main::frame->{BA_Txt_0_einddatum}->SetValue('');
         $main::frame->{BA_Txt_1_einddatum}->SetValue('');
         $main::frame->{BA_Txt_2_einddatum}->SetValue('');
         $main::frame->{BA_Txt_3_einddatum}->SetValue('');
         $main::frame->{BA_Txt_4_einddatum}->SetValue('');
         $main::frame->{BA_Txt_5_einddatum}->SetValue('');
         $main::frame->{BA_Txt_6_einddatum}->SetValue('');
         $main::frame->{BA_Txt_7_einddatum}->SetValue('');
         $main::frame->{BA_Txt_8_einddatum}->SetValue('');

         $main::frame->{BA_Txt_0_verzekering}->SetSelection(wxNOT_FOUND);#     ->SetSelection(wxNOT_FOUND);
         $main::frame->{BA_Txt_1_verzekering}->SetSelection(wxNOT_FOUND);
         $main::frame->{BA_Txt_2_verzekering}->SetSelection(wxNOT_FOUND);
         $main::frame->{BA_Txt_3_verzekering}->SetSelection(wxNOT_FOUND);
         $main::frame->{BA_Txt_4_verzekering}->SetSelection(wxNOT_FOUND);
         $main::frame->{BA_Txt_5_verzekering}->SetSelection(wxNOT_FOUND);
         $main::frame->{BA_Txt_6_verzekering}->SetSelection(wxNOT_FOUND);
         $main::frame->{BA_Txt_7_verzekering}->SetSelection(wxNOT_FOUND);
         $main::frame->{BA_Txt_8_verzekering}->SetSelection(wxNOT_FOUND);

         $main::frame->{EZ_Txt_0_ziekte}->SetValue('');
         $main::frame->{EZ_Txt_1_ziekte}->SetValue('');
         $main::frame->{EZ_Txt_2_ziekte}->SetValue('');
         $main::frame->{EZ_Txt_3_ziekte}->SetValue('');
         $main::frame->{EZ_Txt_4_ziekte}->SetValue('');
         $main::frame->{EZ_Txt_5_ziekte}->SetValue('');
         $main::frame->{EZ_Txt_6_ziekte}->SetValue('');
         $main::frame->{EZ_Txt_7_ziekte}->SetValue('');
         $main::frame->{EZ_Txt_8_ziekte}->SetValue('');

         $main::frame->{EZ_Txt_0_verzekering}->SetSelection(wxNOT_FOUND);
         $main::frame->{EZ_Txt_1_verzekering}->SetSelection(wxNOT_FOUND);
         $main::frame->{EZ_Txt_2_verzekering}->SetSelection(wxNOT_FOUND);
         $main::frame->{EZ_Txt_3_verzekering}->SetSelection(wxNOT_FOUND);
         $main::frame->{EZ_Txt_4_verzekering}->SetSelection(wxNOT_FOUND);
         $main::frame->{EZ_Txt_5_verzekering}->SetSelection(wxNOT_FOUND);
         $main::frame->{EZ_Txt_6_verzekering}->SetSelection(wxNOT_FOUND);
         $main::frame->{EZ_Txt_7_verzekering}->SetSelection(wxNOT_FOUND);
         $main::frame->{EZ_Txt_8_verzekering}->SetSelection(wxNOT_FOUND);

         $main::frame->{GKD_chk_0}->SetValue('');
         $main::frame->{GKD_chk_1}->SetValue('');
         $main::frame->{GKD_chk_2}->SetValue('');
         $main::frame->{GKD_chk_3}->SetValue('');
         $main::frame->{GKD_chk_4}->SetValue('');
         $main::frame->{GKD_chk_5}->SetValue('');
         $main::frame->{GKD_chk_6}->SetValue('');
         $main::frame->{GKD_chk_7}->SetValue('');
         $main::frame->{GKD_chk_8}->SetValue('');
         $main::frame->{GKD_chk_9}->SetValue('');

         $main::frame->{GKD_chk_10}->SetValue('');
         $main::frame->{GKD_chk_11}->SetValue('');
         $main::frame->{GKD_chk_12}->SetValue('');
         $main::frame->{GKD_chk_13}->SetValue('');
         $main::frame->{GKD_chk_14}->SetValue('');
         $main::frame->{GKD_chk_15}->SetValue('');
         $main::frame->{GKD_chk_16}->SetValue('');
         $main::frame->{GKD_chk_17}->SetValue('');
         $main::frame->{GKD_chk_18}->SetValue('');
         $main::frame->{GKD_chk_19}->SetValue('');
         $main::frame->{GKD_chk_20}->SetValue('');
         $main::frame->{GKD_chk_21}->SetValue('');
         $main::frame->{GKD_chk_22}->SetValue('');
         $main::frame->{GKD_chk_23}->SetValue('');

         $main::frame->{brieven_Txt_0_contracten_naam}->SetValue('');
         $main::frame->{brieven_Txt_0_contracten_startdatum}->SetValue('');
         $main::frame->{brieven_Txt_0_contracten_einddatum}->SetValue('');
         $main::frame->{brieven_Txt_0_contracten_wachtdatum}->SetValue('');
         $main::frame->{brieven_Txt_0_contracten_zkfnr}->SetValue('');
         $main::frame->{brieven_Txt_0_contracten_Dossiernr}->SetValue('');
         $main::frame->{brieven_chk_0_Contract}->SetValue('');

         $main::frame->{brieven_Txt_1_contracten_naam}->SetValue('');
         $main::frame->{brieven_Txt_1_contracten_startdatum}->SetValue('');
         $main::frame->{brieven_Txt_1_contracten_einddatum}->SetValue('');
         $main::frame->{brieven_Txt_1_contracten_wachtdatum}->SetValue('');
         $main::frame->{brieven_Txt_1_contracten_zkfnr}->SetValue('');
         $main::frame->{brieven_Txt_1_contracten_Dossiernr}->SetValue('');
         $main::frame->{brieven_chk_1_Contract}->SetValue('');

         $main::frame->{brieven_Txt_2_contracten_naam}->SetValue('');
         $main::frame->{brieven_Txt_2_contracten_startdatum}->SetValue('');
         $main::frame->{brieven_Txt_2_contracten_einddatum}->SetValue('');
         $main::frame->{brieven_Txt_2_contracten_wachtdatum}->SetValue('');
         $main::frame->{brieven_Txt_2_contracten_zkfnr}->SetValue('');
         $main::frame->{brieven_Txt_2_contracten_Dossiernr}->SetValue('');
         $main::frame->{brieven_chk_2_Contract}->SetValue('');

         $main::frame->{brieven_Txt_3_contracten_naam}->SetValue('');
         $main::frame->{brieven_Txt_3_contracten_startdatum}->SetValue('');
         $main::frame->{brieven_Txt_3_contracten_einddatum}->SetValue('');
         $main::frame->{brieven_Txt_3_contracten_wachtdatum}->SetValue('');
         $main::frame->{brieven_Txt_3_contracten_zkfnr}->SetValue('');
         $main::frame->{brieven_Txt_3_contracten_Dossiernr}->SetValue('');
         $main::frame->{brieven_chk_3_Contract}->SetValue('');

         $main::frame->{brieven_Txt_4_contracten_naam}->SetValue('');
         $main::frame->{brieven_Txt_4_contracten_startdatum}->SetValue('');
         $main::frame->{brieven_Txt_4_contracten_einddatum}->SetValue('');
         $main::frame->{brieven_Txt_4_contracten_wachtdatum}->SetValue('');
         $main::frame->{brieven_Txt_4_contracten_zkfnr}->SetValue('');
         $main::frame->{brieven_Txt_4_contracten_Dossiernr}->SetValue('');
         my $teller =1;
         foreach my $mogelijke_brieven (keys $main::brieven_instellingen) {
                 $main::frame->{"AB_chk$teller\_brief"}->SetValue('');
                 eval {my $bestaat = $main::brieven_instellingen->{$mogelijke_brieven}->{aanvinkteksten}};
                 if (!$@) {
                        if ($main::brieven_instellingen->{$mogelijke_brieven}->{aanvinkteksten} and $mogelijke_brieven) {
                              my $teller_invul =1;
                              foreach my $brief_tekst (sort keys $main::brieven_instellingen->{$mogelijke_brieven}->{aanvinkteksten}) {
                                        $main::frame->{"$mogelijke_brieven\_chk$teller_invul\_brief"}->SetValue('');
                                        $teller_invul +=1;
                                   }
                         }
                    }
               }
     }
package gkd_tab;

     use Wx qw[:everything];
     use base qw(Wx::Frame);
     #use Data::Dumper
     use strict;
     use Wx::Locale gettext => '_T';
     use Wx::Event qw(EVT_CHECKBOX);
     use Wx::Event qw(EVT_MENU EVT_CLOSE);
     use DateTime::Format::Strptime;
     use DateTime;
     sub new {
          my ($class, $frame) = @_;
          $frame->{GKD_sizer_1} = Wx::FlexGridSizer->new(4,19, 10, 10);
          #$frame->{GKD_static_SCHADE}  = Wx::txtText->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,_T("TEKST"),wxDefaultPosition,wxSIZE(70,20));
          #my $test11 = $main::teksten_GKD->{GKD_teksten}->{TABBLAD_GKD}->{tekst}->[11];
          #my $test1 = $main::teksten_GKD;
          $frame->{GKD_chk_0}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,$main::gkd_commentaar->{0},wxDefaultPosition,wxSIZE(15,20));
          $frame->{GKD_txt_0}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,$main::teksten_GKD->{GKD_teksten}->{TABBLAD_GKD}->{tekst}->[0],wxDefaultPosition,wxSIZE(245,20));
          $frame->{GKD_chk_1}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,$main::gkd_commentaar->{1},wxDefaultPosition,wxSIZE(15,20));
          $frame->{GKD_txt_1}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,$main::teksten_GKD->{GKD_teksten}->{TABBLAD_GKD}->{tekst}->[1],wxDefaultPosition,wxSIZE(245,20));
          $frame->{GKD_chk_2}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,$main::gkd_commentaar->{2},wxDefaultPosition,wxSIZE(15,20));
          $frame->{GKD_txt_2}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,$main::teksten_GKD->{GKD_teksten}->{TABBLAD_GKD}->{tekst}->[2],wxDefaultPosition,wxSIZE(245,20));
          $frame->{GKD_chk_3}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,$main::gkd_commentaar->{3},wxDefaultPosition,wxSIZE(15,20));
          $frame->{GKD_txt_3}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,$main::teksten_GKD->{GKD_teksten}->{TABBLAD_GKD}->{tekst}->[3],wxDefaultPosition,wxSIZE(245,20));
          $frame->{GKD_chk_4}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,$main::gkd_commentaar->{4},wxDefaultPosition,wxSIZE(15,20));
          $frame->{GKD_txt_4}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,$main::teksten_GKD->{GKD_teksten}->{TABBLAD_GKD}->{tekst}->[4],wxDefaultPosition,wxSIZE(245,20));
          $frame->{GKD_chk_5}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,$main::gkd_commentaar->{5},wxDefaultPosition,wxSIZE(15,20));
          $frame->{GKD_txt_5}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,$main::teksten_GKD->{GKD_teksten}->{TABBLAD_GKD}->{tekst}->[5],wxDefaultPosition,wxSIZE(245,20));

          #$frame->{GKD_static_AANSLUITING}  = Wx::txtText->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,_T("TEKST"),wxDefaultPosition,wxSIZE(70,20));
          $frame->{GKD_chk_6}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,$main::gkd_commentaar->{6},wxDefaultPosition,wxSIZE(15,20));
          $frame->{GKD_txt_6}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,$main::teksten_GKD->{GKD_teksten}->{TABBLAD_GKD}->{tekst}->[6],wxDefaultPosition,wxSIZE(245,20));
          $frame->{GKD_chk_7}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,$main::gkd_commentaar->{7},wxDefaultPosition,wxSIZE(15,20));
          $frame->{GKD_txt_7}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,$main::teksten_GKD->{GKD_teksten}->{TABBLAD_GKD}->{tekst}->[7],wxDefaultPosition,wxSIZE(245,20));
          $frame->{GKD_chk_8}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,$main::gkd_commentaar->{8},wxDefaultPosition,wxSIZE(15,20));
          $frame->{GKD_txt_8}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,$main::teksten_GKD->{GKD_teksten}->{TABBLAD_GKD}->{tekst}->[8],wxDefaultPosition,wxSIZE(245,20));
          $frame->{GKD_chk_9}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,$main::gkd_commentaar->{9},wxDefaultPosition,wxSIZE(15,20));
          $frame->{GKD_txt_9}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,$main::teksten_GKD->{GKD_teksten}->{TABBLAD_GKD}->{tekst}->[9],wxDefaultPosition,wxSIZE(245,20));
          $frame->{GKD_chk_10}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,$main::gkd_commentaar->{10},wxDefaultPosition,wxSIZE(15,20));
          $frame->{GKD_txt_10}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,$main::teksten_GKD->{GKD_teksten}->{TABBLAD_GKD}->{tekst}->[10],wxDefaultPosition,wxSIZE(245,20));

          #$frame->{GKD_static_DIVERSE}  = Wx::txtText->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,_T("DIVERSE"),wxDefaultPosition,wxSIZE(70,20));
          $frame->{GKD_chk_11}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,$main::gkd_commentaar->{11},wxDefaultPosition,wxSIZE(15,20));
          $frame->{GKD_txt_11}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,$main::teksten_GKD->{GKD_teksten}->{TABBLAD_GKD}->{tekst}->[11],wxDefaultPosition,wxSIZE(245,20));
          $frame->{GKD_chk_12}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,$main::gkd_commentaar->{12},wxDefaultPosition,wxSIZE(15,20));
          $frame->{GKD_txt_12}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,$main::teksten_GKD->{GKD_teksten}->{TABBLAD_GKD}->{tekst}->[12],wxDefaultPosition,wxSIZE(245,20));
          $frame->{GKD_chk_13}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,$main::gkd_commentaar->{13},wxDefaultPosition,wxSIZE(15,20));
          $frame->{GKD_txt_13}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,$main::teksten_GKD->{GKD_teksten}->{TABBLAD_GKD}->{tekst}->[13],wxDefaultPosition,wxSIZE(245,20));
          $frame->{GKD_chk_14}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,$main::gkd_commentaar->{14},wxDefaultPosition,wxSIZE(15,20));
          $frame->{GKD_txt_14}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,$main::teksten_GKD->{GKD_teksten}->{TABBLAD_GKD}->{tekst}->[14],wxDefaultPosition,wxSIZE(245,20));
          $frame->{GKD_chk_15}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,$main::gkd_commentaar->{15},wxDefaultPosition,wxSIZE(15,20));
          $frame->{GKD_txt_15}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,$main::teksten_GKD->{GKD_teksten}->{TABBLAD_GKD}->{tekst}->[15],wxDefaultPosition,wxSIZE(245,20));
          $frame->{GKD_chk_16}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,$main::gkd_commentaar->{16},wxDefaultPosition,wxSIZE(15,20));
          $frame->{GKD_txt_16}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,$main::teksten_GKD->{GKD_teksten}->{TABBLAD_GKD}->{tekst}->[16],wxDefaultPosition,wxSIZE(245,20));
          $frame->{GKD_chk_17}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,$main::gkd_commentaar->{17},wxDefaultPosition,wxSIZE(15,20));
          $frame->{GKD_txt_17}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,$main::teksten_GKD->{GKD_teksten}->{TABBLAD_GKD}->{tekst}->[17],wxDefaultPosition,wxSIZE(245,20));

          $frame->{GKD_chk_18}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,$main::gkd_commentaar->{18},wxDefaultPosition,wxSIZE(15,20));
          $frame->{GKD_txt_18}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,$main::teksten_GKD->{GKD_teksten}->{TABBLAD_GKD}->{tekst}->[18],wxDefaultPosition,wxSIZE(245,20));
          $frame->{GKD_chk_19}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,$main::gkd_commentaar->{19},wxDefaultPosition,wxSIZE(15,20));
          $frame->{GKD_txt_19}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,$main::teksten_GKD->{GKD_teksten}->{TABBLAD_GKD}->{tekst}->[19],wxDefaultPosition,wxSIZE(245,20));
          $frame->{GKD_chk_20}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,$main::gkd_commentaar->{20},wxDefaultPosition,wxSIZE(15,20));
          $frame->{GKD_txt_20}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,$main::teksten_GKD->{GKD_teksten}->{TABBLAD_GKD}->{tekst}->[20],wxDefaultPosition,wxSIZE(245,20));
          $frame->{GKD_chk_21}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,$main::gkd_commentaar->{21},wxDefaultPosition,wxSIZE(15,20));
          $frame->{GKD_txt_21}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,$main::teksten_GKD->{GKD_teksten}->{TABBLAD_GKD}->{tekst}->[21],wxDefaultPosition,wxSIZE(245,20));
          $frame->{GKD_chk_22}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,$main::gkd_commentaar->{22},wxDefaultPosition,wxSIZE(15,20));
          $frame->{GKD_txt_22}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,$main::teksten_GKD->{GKD_teksten}->{TABBLAD_GKD}->{tekst}->[22],wxDefaultPosition,wxSIZE(245,20));
          $frame->{GKD_chk_23}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,$main::gkd_commentaar->{23},wxDefaultPosition,wxSIZE(15,20));
          $frame->{GKD_txt_23}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,$main::teksten_GKD->{GKD_teksten}->{TABBLAD_GKD}->{tekst}->[23],wxDefaultPosition,wxSIZE(245,20));


         $frame->{GKD_panel_1} = Wx::Panel->new($frame->{MainFrameNotebookBoven_pane_GKD},-1,wxDefaultPosition,wxSIZE(15,20));
         #RIJ1
         #kolom   1+2+3+4
         $frame->{GKD_sizer_1}->Add($frame->{GKD_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{GKD_sizer_1}->Add($frame->{GKD_chk_0}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{GKD_sizer_1}->Add($frame->{GKD_txt_0}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{GKD_sizer_1}->Add($frame->{GKD_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         #kolom 5+6+7
         $frame->{GKD_sizer_1}->Add($frame->{GKD_chk_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{GKD_sizer_1}->Add($frame->{GKD_txt_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{GKD_sizer_1}->Add($frame->{GKD_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         #kolom 8+9+10
         $frame->{GKD_sizer_1}->Add($frame->{GKD_chk_2}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{GKD_sizer_1}->Add($frame->{GKD_txt_2}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{GKD_sizer_1}->Add($frame->{GKD_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         #kolom11+12+13
         $frame->{GKD_sizer_1}->Add($frame->{GKD_chk_3}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{GKD_sizer_1}->Add($frame->{GKD_txt_3}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{GKD_sizer_1}->Add($frame->{GKD_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         #kolom 14+15+16
         $frame->{GKD_sizer_1}->Add($frame->{GKD_chk_4}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{GKD_sizer_1}->Add($frame->{GKD_txt_4}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{GKD_sizer_1}->Add($frame->{GKD_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
          #kolom 17+18+19
         $frame->{GKD_sizer_1}->Add($frame->{GKD_chk_5}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{GKD_sizer_1}->Add($frame->{GKD_txt_5}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{GKD_sizer_1}->Add($frame->{GKD_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);


         #RIJ2
         #kolom 1 +2 +3
         #kolom   1+2+3+4
         $frame->{GKD_sizer_1}->Add($frame->{GKD_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{GKD_sizer_1}->Add($frame->{GKD_chk_6}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{GKD_sizer_1}->Add($frame->{GKD_txt_6}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{GKD_sizer_1}->Add($frame->{GKD_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         #kolom 5+6+7
         $frame->{GKD_sizer_1}->Add($frame->{GKD_chk_7}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{GKD_sizer_1}->Add($frame->{GKD_txt_7}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{GKD_sizer_1}->Add($frame->{GKD_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         #kolom 8+9+10
         $frame->{GKD_sizer_1}->Add($frame->{GKD_chk_8}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{GKD_sizer_1}->Add($frame->{GKD_txt_8}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{GKD_sizer_1}->Add($frame->{GKD_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         #kolom 11+12+13
         $frame->{GKD_sizer_1}->Add($frame->{GKD_chk_9}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{GKD_sizer_1}->Add($frame->{GKD_txt_9}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{GKD_sizer_1}->Add($frame->{GKD_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         #kolom 14+15+16
         $frame->{GKD_sizer_1}->Add($frame->{GKD_chk_10}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{GKD_sizer_1}->Add($frame->{GKD_txt_10}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{GKD_sizer_1}->Add($frame->{GKD_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         #kolom 17+18+19
         $frame->{GKD_sizer_1}->Add($frame->{GKD_chk_11}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{GKD_sizer_1}->Add($frame->{GKD_txt_11}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{GKD_sizer_1}->Add($frame->{GKD_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);

         #RIJ 3
         #kolom   1+2+3+4
         $frame->{GKD_sizer_1}->Add($frame->{GKD_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{GKD_sizer_1}->Add($frame->{GKD_chk_12}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{GKD_sizer_1}->Add($frame->{GKD_txt_12}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{GKD_sizer_1}->Add($frame->{GKD_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         #kolom 5+6+7
         $frame->{GKD_sizer_1}->Add($frame->{GKD_chk_13}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{GKD_sizer_1}->Add($frame->{GKD_txt_13}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{GKD_sizer_1}->Add($frame->{GKD_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         #kolom 8+9+10
         $frame->{GKD_sizer_1}->Add($frame->{GKD_chk_14}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{GKD_sizer_1}->Add($frame->{GKD_txt_14}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{GKD_sizer_1}->Add($frame->{GKD_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         #kolom 11+12+13
         $frame->{GKD_sizer_1}->Add($frame->{GKD_chk_15}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{GKD_sizer_1}->Add($frame->{GKD_txt_15}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{GKD_sizer_1}->Add($frame->{GKD_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
          #kolom 14+15+16
         $frame->{GKD_sizer_1}->Add($frame->{GKD_chk_16}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{GKD_sizer_1}->Add($frame->{GKD_txt_16}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{GKD_sizer_1}->Add($frame->{GKD_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
          #kolom 17+1+18+19
         $frame->{GKD_sizer_1}->Add($frame->{GKD_chk_17}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{GKD_sizer_1}->Add($frame->{GKD_txt_17}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{GKD_sizer_1}->Add($frame->{GKD_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         #RIJ4
         #schade
         $frame->{GKD_sizer_1}->Add($frame->{GKD_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{GKD_sizer_1}->Add($frame->{GKD_chk_18}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{GKD_sizer_1}->Add($frame->{GKD_txt_18}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{GKD_sizer_1}->Add($frame->{GKD_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         #kolom 5+6+7
         $frame->{GKD_sizer_1}->Add($frame->{GKD_chk_19}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{GKD_sizer_1}->Add($frame->{GKD_txt_19}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{GKD_sizer_1}->Add($frame->{GKD_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         #kolom 8+9+10
         $frame->{GKD_sizer_1}->Add($frame->{GKD_chk_20}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{GKD_sizer_1}->Add($frame->{GKD_txt_20}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{GKD_sizer_1}->Add($frame->{GKD_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         #kolom 11+12+13
         $frame->{GKD_sizer_1}->Add($frame->{GKD_chk_21}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{GKD_sizer_1}->Add($frame->{GKD_txt_21}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{GKD_sizer_1}->Add($frame->{GKD_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
          #kolom 14+15+16
         $frame->{GKD_sizer_1}->Add($frame->{GKD_chk_22}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{GKD_sizer_1}->Add($frame->{GKD_txt_22}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{GKD_sizer_1}->Add($frame->{GKD_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
          #kolom 17+1+18+19
         $frame->{GKD_sizer_1}->Add($frame->{GKD_chk_23}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{GKD_sizer_1}->Add($frame->{GKD_txt_23}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{GKD_sizer_1}->Add($frame->{GKD_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);




         Wx::Event::EVT_CHECKBOX($frame,$frame->{GKD_chk_0}, \&GKD_chk_0_clicked);
         Wx::Event::EVT_CHECKBOX($frame,$frame->{GKD_chk_1}, \&GKD_chk_1_clicked);
         Wx::Event::EVT_CHECKBOX($frame,$frame->{GKD_chk_2}, \&GKD_chk_2_clicked);
         Wx::Event::EVT_CHECKBOX($frame,$frame->{GKD_chk_3}, \&GKD_chk_3_clicked);
         Wx::Event::EVT_CHECKBOX($frame,$frame->{GKD_chk_4}, \&GKD_chk_4_clicked);
         Wx::Event::EVT_CHECKBOX($frame,$frame->{GKD_chk_5}, \&GKD_chk_5_clicked);
         #aansluiting
         Wx::Event::EVT_CHECKBOX($frame,$frame->{GKD_chk_6}, \&GKD_chk_6_clicked);
         Wx::Event::EVT_CHECKBOX($frame,$frame->{GKD_chk_7}, \&GKD_chk_7_clicked);
         Wx::Event::EVT_CHECKBOX($frame,$frame->{GKD_chk_8}, \&GKD_chk_8_clicked);
         Wx::Event::EVT_CHECKBOX($frame,$frame->{GKD_chk_9}, \&GKD_chk_9_clicked);
         Wx::Event::EVT_CHECKBOX($frame,$frame->{GKD_chk_10}, \&GKD_chk_10_clicked);
         #diverse
         Wx::Event::EVT_CHECKBOX($frame,$frame->{GKD_chk_11}, \&GKD_chk_11_clicked);
         Wx::Event::EVT_CHECKBOX($frame,$frame->{GKD_chk_12}, \&GKD_chk_12_clicked);
         Wx::Event::EVT_CHECKBOX($frame,$frame->{GKD_chk_13}, \&GKD_chk_13_clicked);

         Wx::Event::EVT_CHECKBOX($frame,$frame->{GKD_chk_14}, \&GKD_chk_14_clicked);
         Wx::Event::EVT_CHECKBOX($frame,$frame->{GKD_chk_15}, \&GKD_chk_15_clicked);
         Wx::Event::EVT_CHECKBOX($frame,$frame->{GKD_chk_16}, \&GKD_chk_16_clicked);

         Wx::Event::EVT_CHECKBOX($frame,$frame->{GKD_chk_17}, \&GKD_chk_17_clicked);
         Wx::Event::EVT_CHECKBOX($frame,$frame->{GKD_chk_18}, \&GKD_chk_18_clicked);
         Wx::Event::EVT_CHECKBOX($frame,$frame->{GKD_chk_19}, \&GKD_chk_19_clicked);

         Wx::Event::EVT_CHECKBOX($frame,$frame->{GKD_chk_20}, \&GKD_chk_20_clicked);
         Wx::Event::EVT_CHECKBOX($frame,$frame->{GKD_chk_21}, \&GKD_chk_21_clicked);
         Wx::Event::EVT_CHECKBOX($frame,$frame->{GKD_chk_22}, \&GKD_chk_22_clicked);
         Wx::Event::EVT_CHECKBOX($frame,$frame->{GKD_chk_23}, \&GKD_chk_23_clicked);
        }
     sub GKD_chk_0_clicked {
         my ($frame, $evt) = @_;
         if ($evt->IsChecked()) {
             if ($main::gkd_commentaar->{0} != 1) {
                 my $historiek_gkd = $frame->{GKD_txt_0}->GetValue();
                 #my $test = $main::klant;
                 my $gedaan = as400_gegevens->zet_history_gkd_in ($historiek_gkd);
                 if ($gedaan != 1) {
                     sleep 1;
                     $gedaan = as400_gegevens->zet_history_gkd_in ($historiek_gkd);
                     if ($gedaan != 1) {
                              Wx::MessageBox( _T("Kan $historiek_gkd\n\nNiet inzetten"),
                                    _T("Zet commentaar in het GKD"),
                                     wxOK|wxCENTRE,
                                   $main::frame
                              );#code
                         }
                    }
                 my $resultaat  = as400_gegevens->lees_history_gkd($frame);
                 my $dbh = sql_toegang_agresso->setup_mssql_connectie($main::test_prod);
                 sql_toegang_agresso->ubtstatistics_insert_row($dbh,$main::klant->{Agresso_nummer},$ziekenfonds_nummer,$historiek_gkd);
                 sql_toegang_agresso->disconnect_mssql($dbh);
                }
            }else {
             #niets doen
            }
        }
     sub GKD_chk_1_clicked {
         my ($frame, $evt) = @_;
         if ($evt->IsChecked()) {
             if ($main::gkd_commentaar->{1} != 1) {
                 my $historiek_gkd = $frame->{GKD_txt_1}->GetValue();
                 my $gedaan = as400_gegevens->zet_history_gkd_in ($historiek_gkd);
                 if ($gedaan != 1) {
                     sleep 1;
                     $gedaan = as400_gegevens->zet_history_gkd_in ($historiek_gkd);
                     if ($gedaan != 1) {
                              Wx::MessageBox( _T("Kan $historiek_gkd\n\nNiet inzetten"),
                                    _T("Zet commentaar in het GKD"),
                                     wxOK|wxCENTRE,
                                   $main::frame
                              );#code
                         }
                    }
                 my $resultaat  = as400_gegevens->lees_history_gkd($frame);
                 my $dbh = sql_toegang_agresso->setup_mssql_connectie($main::test_prod);
                 sql_toegang_agresso->ubtstatistics_insert_row($dbh,$main::klant->{Agresso_nummer},$ziekenfonds_nummer,$historiek_gkd);
                 sql_toegang_agresso->disconnect_mssql($dbh);
                }
            }else {
             #niets doen
            }
        }
     sub GKD_chk_2_clicked {
         my ($frame, $evt) = @_;
         if ($evt->IsChecked()) {
             if ($main::gkd_commentaar->{2} != 1) {
                 my $historiek_gkd = $frame->{GKD_txt_2}->GetValue();
                 my $gedaan = as400_gegevens->zet_history_gkd_in ($historiek_gkd);
                 if ($gedaan != 1) {
                     sleep 1;
                     $gedaan = as400_gegevens->zet_history_gkd_in ($historiek_gkd);
                     if ($gedaan != 1) {
                              Wx::MessageBox( _T("Kan $historiek_gkd\n\nNiet inzetten"),
                                    _T("Zet commentaar in het GKD"),
                                     wxOK|wxCENTRE,
                                   $main::frame
                              );#code
                         }
                    }
                 my $resultaat  = as400_gegevens->lees_history_gkd($frame);
                 my $dbh = sql_toegang_agresso->setup_mssql_connectie($main::test_prod);
                 sql_toegang_agresso->ubtstatistics_insert_row($dbh,$main::klant->{Agresso_nummer},$ziekenfonds_nummer,$historiek_gkd);
                 sql_toegang_agresso->disconnect_mssql($dbh);
                }
            }else {
             #niets doen
            }
        }
     sub GKD_chk_3_clicked {
         my ($frame, $evt) = @_;
         if ($evt->IsChecked()) {
             if ($main::gkd_commentaar->{3} != 1) {
                 my $historiek_gkd = $frame->{GKD_txt_3}->GetValue();
                 my $gedaan = as400_gegevens->zet_history_gkd_in ($historiek_gkd);
                 if ($gedaan != 1) {
                     sleep 1;
                     $gedaan = as400_gegevens->zet_history_gkd_in ($historiek_gkd);
                     if ($gedaan != 1) {
                              Wx::MessageBox( _T("Kan $historiek_gkd\n\nNiet inzetten"),
                                    _T("Zet commentaar in het GKD"),
                                     wxOK|wxCENTRE,
                                   $main::frame
                              );#code
                         }
                    }
                 my $resultaat  = as400_gegevens->lees_history_gkd($frame);
                 my $dbh = sql_toegang_agresso->setup_mssql_connectie($main::test_prod);
                 sql_toegang_agresso->ubtstatistics_insert_row($dbh,$main::klant->{Agresso_nummer},$ziekenfonds_nummer,$historiek_gkd);
                 sql_toegang_agresso->disconnect_mssql($dbh);
                }
            }else {
             #niets doen
            }
        }
     sub GKD_chk_4_clicked {
         my ($frame, $evt) = @_;
         if ($evt->IsChecked()) {
             if ($main::gkd_commentaar->{4} != 1) {
                 my $historiek_gkd = $frame->{GKD_txt_4}->GetValue() ;
                 my $gedaan = as400_gegevens->zet_history_gkd_in ($historiek_gkd);
                 if ($gedaan != 1) {
                     sleep 1;
                     $gedaan = as400_gegevens->zet_history_gkd_in ($historiek_gkd);
                     if ($gedaan != 1) {
                              Wx::MessageBox( _T("Kan $historiek_gkd\n\nNiet inzetten"),
                                    _T("Zet commentaar in het GKD"),
                                     wxOK|wxCENTRE,
                                   $main::frame
                              );#code
                         }
                    }
                 my $resultaat  = as400_gegevens->lees_history_gkd($frame);
                 my $dbh = sql_toegang_agresso->setup_mssql_connectie($main::test_prod);
                 sql_toegang_agresso->ubtstatistics_insert_row($dbh,$main::klant->{Agresso_nummer},$ziekenfonds_nummer,$historiek_gkd);
                 sql_toegang_agresso->disconnect_mssql($dbh);
                }
            }else {
             #niets doen
            }
        }
     sub GKD_chk_5_clicked {
         my ($frame, $evt) = @_;
         if ($evt->IsChecked()) {
             if ($main::gkd_commentaar->{5} != 1) {
                 my $historiek_gkd = $frame->{GKD_txt_5}->GetValue();
                  my $gedaan = as400_gegevens->zet_history_gkd_in ($historiek_gkd);
                 if ($gedaan != 1) {
                     sleep 1;
                     $gedaan = as400_gegevens->zet_history_gkd_in ($historiek_gkd);
                     if ($gedaan != 1) {
                              Wx::MessageBox( _T("Kan $historiek_gkd\n\nNiet inzetten"),
                                    _T("Zet commentaar in het GKD"),
                                     wxOK|wxCENTRE,
                                   $main::frame
                              );#code
                         }
                    }
                 my $resultaat  = as400_gegevens->lees_history_gkd($frame);
                 my $dbh = sql_toegang_agresso->setup_mssql_connectie($main::test_prod);
                 sql_toegang_agresso->ubtstatistics_insert_row($dbh,$main::klant->{Agresso_nummer},$ziekenfonds_nummer,$historiek_gkd);
                 sql_toegang_agresso->disconnect_mssql($dbh);
                }
            }else {
             #niets doen
            }
        }

     sub GKD_chk_6_clicked {
         my ($frame, $evt) = @_;
         if ($evt->IsChecked()) {
             if ($main::gkd_commentaar->{6} != 1) {
                 my $historiek_gkd = $frame->{GKD_txt_6}->GetValue();
                 my $gedaan = as400_gegevens->zet_history_gkd_in ($historiek_gkd);
                 if ($gedaan != 1) {
                     sleep 1;
                     $gedaan = as400_gegevens->zet_history_gkd_in ($historiek_gkd);
                     if ($gedaan != 1) {
                              Wx::MessageBox( _T("Kan $historiek_gkd\n\nNiet inzetten"),
                                    _T("Zet commentaar in het GKD"),
                                     wxOK|wxCENTRE,
                                   $main::frame
                              );#code
                         }
                    }
                 my $resultaat  = as400_gegevens->lees_history_gkd($frame);
                 my $dbh = sql_toegang_agresso->setup_mssql_connectie($main::test_prod);
                 sql_toegang_agresso->ubtstatistics_insert_row($dbh,$main::klant->{Agresso_nummer},$ziekenfonds_nummer,$historiek_gkd);
                 sql_toegang_agresso->disconnect_mssql($dbh);
                }
            }else {
             #niets doen
            }
        }
     sub GKD_chk_7_clicked {
         my ($frame, $evt) = @_;
         if ($evt->IsChecked()) {
             if ($main::gkd_commentaar->{7} != 1) {
                 my $historiek_gkd = $frame->{GKD_txt_7}->GetValue();
                 my $gedaan = as400_gegevens->zet_history_gkd_in ($historiek_gkd);
                 if ($gedaan != 1) {
                     sleep 1;
                     $gedaan = as400_gegevens->zet_history_gkd_in ($historiek_gkd);
                     if ($gedaan != 1) {
                              Wx::MessageBox( _T("Kan $historiek_gkd\n\nNiet inzetten"),
                                    _T("Zet commentaar in het GKD"),
                                     wxOK|wxCENTRE,
                                   $main::frame
                              );#code
                         }
                    }
                 my $resultaat  = as400_gegevens->lees_history_gkd($frame);
                 my $dbh = sql_toegang_agresso->setup_mssql_connectie($main::test_prod);
                 sql_toegang_agresso->ubtstatistics_insert_row($dbh,$main::klant->{Agresso_nummer},$ziekenfonds_nummer,$historiek_gkd);
                 sql_toegang_agresso->disconnect_mssql($dbh);
                }
            }else {
             #niets doen
            }
        }
     sub GKD_chk_8_clicked {
         my ($frame, $evt) = @_;
         if ($evt->IsChecked()) {
             if ($main::gkd_commentaar->{8} != 1) {
                 my $historiek_gkd = $frame->{GKD_txt_8}->GetValue();
                 my $gedaan = as400_gegevens->zet_history_gkd_in ($historiek_gkd);
                 if ($gedaan != 1) {
                     sleep 1;
                     $gedaan = as400_gegevens->zet_history_gkd_in ($historiek_gkd);
                     if ($gedaan != 1) {
                              Wx::MessageBox( _T("Kan $historiek_gkd\n\nNiet inzetten"),
                                    _T("Zet commentaar in het GKD"),
                                     wxOK|wxCENTRE,
                                   $main::frame
                              );#code
                         }
                    }
                 my $resultaat  = as400_gegevens->lees_history_gkd($frame);
                 my $dbh = sql_toegang_agresso->setup_mssql_connectie($main::test_prod);
                 sql_toegang_agresso->ubtstatistics_insert_row($dbh,$main::klant->{Agresso_nummer},$ziekenfonds_nummer,$historiek_gkd);
                 sql_toegang_agresso->disconnect_mssql($dbh);
                }
            }else {
             #niets doen
            }
        }
     sub GKD_chk_9_clicked {
         my ($frame, $evt) = @_;
         if ($evt->IsChecked()) {
             if ($main::gkd_commentaar->{9} != 1) {
                 my $historiek_gkd = $frame->{GKD_txt_9}->GetValue();
                  my $gedaan = as400_gegevens->zet_history_gkd_in ($historiek_gkd);
                 if ($gedaan != 1) {
                     sleep 1;
                     $gedaan = as400_gegevens->zet_history_gkd_in ($historiek_gkd);
                     if ($gedaan != 1) {
                              Wx::MessageBox( _T("Kan $historiek_gkd\n\nNiet inzetten"),
                                    _T("Zet commentaar in het GKD"),
                                     wxOK|wxCENTRE,
                                   $main::frame
                              );#code
                         }
                    }
                 my $resultaat  = as400_gegevens->lees_history_gkd($frame);
                 my $dbh = sql_toegang_agresso->setup_mssql_connectie($main::test_prod);
                 sql_toegang_agresso->ubtstatistics_insert_row($dbh,$main::klant->{Agresso_nummer},$ziekenfonds_nummer,$historiek_gkd);
                 sql_toegang_agresso->disconnect_mssql($dbh);
                }
            }else {
             #niets doen
            }
        }
     sub GKD_chk_10_clicked {
         my ($frame, $evt) = @_;
         if ($evt->IsChecked()) {
             if ($main::gkd_commentaar->{10} != 1) {
                 my $historiek_gkd = $frame->{GKD_txt_10}->GetValue();
                 my $gedaan = as400_gegevens->zet_history_gkd_in ($historiek_gkd);
                 if ($gedaan != 1) {
                     sleep 1;
                     $gedaan = as400_gegevens->zet_history_gkd_in ($historiek_gkd);
                     if ($gedaan != 1) {
                              Wx::MessageBox( _T("Kan $historiek_gkd\n\nNiet inzetten"),
                                    _T("Zet commentaar in het GKD"),
                                     wxOK|wxCENTRE,
                                   $main::frame
                              );#code
                         }
                    }
                 my $resultaat  = as400_gegevens->lees_history_gkd($frame);
                 my $dbh = sql_toegang_agresso->setup_mssql_connectie($main::test_prod);
                 sql_toegang_agresso->ubtstatistics_insert_row($dbh,$main::klant->{Agresso_nummer},$ziekenfonds_nummer,$historiek_gkd);
                 sql_toegang_agresso->disconnect_mssql($dbh);
                }
            }else {
             #niets doen
            }
        }
     sub GKD_chk_11_clicked {
         my ($frame, $evt) = @_;
         if ($evt->IsChecked()) {
             if ($main::gkd_commentaar->{11} != 1) {
                 my $historiek_gkd = $frame->{GKD_txt_11}->GetValue();
                 my $gedaan = as400_gegevens->zet_history_gkd_in ($historiek_gkd);
                 if ($gedaan != 1) {
                     sleep 1;
                     $gedaan = as400_gegevens->zet_history_gkd_in ($historiek_gkd);
                     if ($gedaan != 1) {
                              Wx::MessageBox( _T("Kan $historiek_gkd\n\nNiet inzetten"),
                                    _T("Zet commentaar in het GKD"),
                                     wxOK|wxCENTRE,
                                   $main::frame
                              );#code
                         }
                    }
                 my $resultaat  = as400_gegevens->lees_history_gkd($frame);
                 my $dbh = sql_toegang_agresso->setup_mssql_connectie($main::test_prod);
                 sql_toegang_agresso->ubtstatistics_insert_row($dbh,$main::klant->{Agresso_nummer},$ziekenfonds_nummer,$historiek_gkd);
                 sql_toegang_agresso->disconnect_mssql($dbh);
                }
            }else {
             #niets doen
            }
        }
     sub GKD_chk_12_clicked {
         my ($frame, $evt) = @_;
         if ($evt->IsChecked()) {
             if ($main::gkd_commentaar->{12} != 1) {
                 my $historiek_gkd = $frame->{GKD_txt_12}->GetValue();
                 my $gedaan = as400_gegevens->zet_history_gkd_in ($historiek_gkd);
                 if ($gedaan != 1) {
                     sleep 1;
                     $gedaan = as400_gegevens->zet_history_gkd_in ($historiek_gkd);
                     if ($gedaan != 1) {
                              Wx::MessageBox( _T("Kan $historiek_gkd\n\nNiet inzetten"),
                                    _T("Zet commentaar in het GKD"),
                                     wxOK|wxCENTRE,
                                   $main::frame
                              );#code
                         }
                    }
                 my $resultaat  = as400_gegevens->lees_history_gkd($frame);
                 my $dbh = sql_toegang_agresso->setup_mssql_connectie($main::test_prod);
                 sql_toegang_agresso->ubtstatistics_insert_row($dbh,$main::klant->{Agresso_nummer},$ziekenfonds_nummer,$historiek_gkd);
                 sql_toegang_agresso->disconnect_mssql($dbh);
                }
            }else {
             #niets doen
            }
        }
     sub GKD_chk_13_clicked {
         my ($frame, $evt) = @_;
         if ($evt->IsChecked()) {
             if ($main::gkd_commentaar->{13} != 1) {
                 my $historiek_gkd = $frame->{GKD_txt_13}->GetValue();
                 my $gedaan = as400_gegevens->zet_history_gkd_in ($historiek_gkd);
                 if ($gedaan != 1) {
                     sleep 1;
                     $gedaan = as400_gegevens->zet_history_gkd_in ($historiek_gkd);
                     if ($gedaan != 1) {
                              Wx::MessageBox( _T("Kan $historiek_gkd\n\nNiet inzetten"),
                                    _T("Zet commentaar in het GKD"),
                                     wxOK|wxCENTRE,
                                   $main::frame
                              );#code
                         }
                    }
                 my $resultaat  = as400_gegevens->lees_history_gkd($frame);
                 my $dbh = sql_toegang_agresso->setup_mssql_connectie($main::test_prod);
                 sql_toegang_agresso->ubtstatistics_insert_row($dbh,$main::klant->{Agresso_nummer},$ziekenfonds_nummer,$historiek_gkd);
                 sql_toegang_agresso->disconnect_mssql($dbh);

                }
            }else {
             #niets doen
            }
        }
     sub GKD_chk_14_clicked {
         my ($frame, $evt) = @_;
         if ($evt->IsChecked()) {
             if ($main::gkd_commentaar->{14} != 1) {
                 my $historiek_gkd = $frame->{GKD_txt_14}->GetValue();
                 my $gedaan = as400_gegevens->zet_history_gkd_in ($historiek_gkd);
                 if ($gedaan != 1) {
                     sleep 1;
                     $gedaan = as400_gegevens->zet_history_gkd_in ($historiek_gkd);
                     if ($gedaan != 1) {
                              Wx::MessageBox( _T("Kan $historiek_gkd\n\nNiet inzetten"),
                                    _T("Zet commentaar in het GKD"),
                                     wxOK|wxCENTRE,
                                   $main::frame
                              );#code
                         }
                    }
                 my $resultaat  = as400_gegevens->lees_history_gkd($frame);
                 my $dbh = sql_toegang_agresso->setup_mssql_connectie($main::test_prod);
                 sql_toegang_agresso->ubtstatistics_insert_row($dbh,$main::klant->{Agresso_nummer},$ziekenfonds_nummer,$historiek_gkd);
                 sql_toegang_agresso->disconnect_mssql($dbh);

                }
            }else {
             #niets doen
            }
        }
     sub GKD_chk_15_clicked {
         my ($frame, $evt) = @_;
         if ($evt->IsChecked()) {
             if ($main::gkd_commentaar->{15} != 1) {
                 my $historiek_gkd = $frame->{GKD_txt_15}->GetValue();
                 my $gedaan = as400_gegevens->zet_history_gkd_in ($historiek_gkd);
                 if ($gedaan != 1) {
                     sleep 1;
                     $gedaan = as400_gegevens->zet_history_gkd_in ($historiek_gkd);
                     if ($gedaan != 1) {
                              Wx::MessageBox( _T("Kan $historiek_gkd\n\nNiet inzetten"),
                                    _T("Zet commentaar in het GKD"),
                                     wxOK|wxCENTRE,
                                   $main::frame
                              );#code
                         }
                    }
                 my $resultaat  = as400_gegevens->lees_history_gkd($frame);
                 my $dbh = sql_toegang_agresso->setup_mssql_connectie($main::test_prod);
                 sql_toegang_agresso->ubtstatistics_insert_row($dbh,$main::klant->{Agresso_nummer},$ziekenfonds_nummer,$historiek_gkd);
                 sql_toegang_agresso->disconnect_mssql($dbh);

                }
            }else {
             #niets doen
            }
        }
     sub GKD_chk_16_clicked {
         my ($frame, $evt) = @_;
         if ($evt->IsChecked()) {
             if ($main::gkd_commentaar->{16} != 1) {
                 my $historiek_gkd = $frame->{GKD_txt_16}->GetValue();
                 my $gedaan = as400_gegevens->zet_history_gkd_in ($historiek_gkd);
                 if ($gedaan != 1) {
                     sleep 1;
                     $gedaan = as400_gegevens->zet_history_gkd_in ($historiek_gkd);
                     if ($gedaan != 1) {
                              Wx::MessageBox( _T("Kan $historiek_gkd\n\nNiet inzetten"),
                                    _T("Zet commentaar in het GKD"),
                                     wxOK|wxCENTRE,
                                   $main::frame
                              );#code
                         }
                    }
                 my $resultaat  = as400_gegevens->lees_history_gkd($frame);
                 my $dbh = sql_toegang_agresso->setup_mssql_connectie($main::test_prod);
                 sql_toegang_agresso->ubtstatistics_insert_row($dbh,$main::klant->{Agresso_nummer},$ziekenfonds_nummer,$historiek_gkd);
                 sql_toegang_agresso->disconnect_mssql($dbh);

                }
            }else {
             #niets doen
            }
        }
     sub GKD_chk_17_clicked {
         my ($frame, $evt) = @_;
         if ($evt->IsChecked()) {
             if ($main::gkd_commentaar->{17} != 1) {
                 my $historiek_gkd = $frame->{GKD_txt_17}->GetValue();
                  my $gedaan = as400_gegevens->zet_history_gkd_in ($historiek_gkd);
                 if ($gedaan != 1) {
                     sleep 1;
                     $gedaan = as400_gegevens->zet_history_gkd_in ($historiek_gkd);
                     if ($gedaan != 1) {
                              Wx::MessageBox( _T("Kan $historiek_gkd\n\nNiet inzetten"),
                                    _T("Zet commentaar in het GKD"),
                                     wxOK|wxCENTRE,
                                   $main::frame
                              );#code
                         }
                    }
                 my $resultaat  = as400_gegevens->lees_history_gkd($frame);
                 my $dbh = sql_toegang_agresso->setup_mssql_connectie($main::test_prod);
                 sql_toegang_agresso->ubtstatistics_insert_row($dbh,$main::klant->{Agresso_nummer},$ziekenfonds_nummer,$historiek_gkd);
                 sql_toegang_agresso->disconnect_mssql($dbh);
                }
            }else {
             #niets doen
            }
        }
     sub GKD_chk_18_clicked {
         my ($frame, $evt) = @_;
         if ($evt->IsChecked()) {
             if ($main::gkd_commentaar->{18} != 1) {
                 my $historiek_gkd = $frame->{GKD_txt_18}->GetValue();
                  my $gedaan = as400_gegevens->zet_history_gkd_in ($historiek_gkd);
                 if ($gedaan != 1) {
                     sleep 1;
                     $gedaan = as400_gegevens->zet_history_gkd_in ($historiek_gkd);
                     if ($gedaan != 1) {
                              Wx::MessageBox( _T("Kan $historiek_gkd\n\nNiet inzetten"),
                                    _T("Zet commentaar in het GKD"),
                                     wxOK|wxCENTRE,
                                   $main::frame
                              );#code
                         }
                    }
                 my $resultaat  = as400_gegevens->lees_history_gkd($frame);
                 my $dbh = sql_toegang_agresso->setup_mssql_connectie($main::test_prod);
                 sql_toegang_agresso->ubtstatistics_insert_row($dbh,$main::klant->{Agresso_nummer},$ziekenfonds_nummer,$historiek_gkd);
                 sql_toegang_agresso->disconnect_mssql($dbh);
                }
            }else {
             #niets doen
            }
        }
     sub GKD_chk_19_clicked {
         my ($frame, $evt) = @_;
         if ($evt->IsChecked()) {
             if ($main::gkd_commentaar->{19} != 1) {
                 my $historiek_gkd = $frame->{GKD_txt_19}->GetValue();
                  my $gedaan = as400_gegevens->zet_history_gkd_in ($historiek_gkd);
                 if ($gedaan != 1) {
                     sleep 1;
                     $gedaan = as400_gegevens->zet_history_gkd_in ($historiek_gkd);
                     if ($gedaan != 1) {
                              Wx::MessageBox( _T("Kan $historiek_gkd\n\nNiet inzetten"),
                                    _T("Zet commentaar in het GKD"),
                                     wxOK|wxCENTRE,
                                   $main::frame
                              );#code
                         }
                    }
                 my $resultaat  = as400_gegevens->lees_history_gkd($frame);
                 my $dbh = sql_toegang_agresso->setup_mssql_connectie($main::test_prod);
                 sql_toegang_agresso->ubtstatistics_insert_row($dbh,$main::klant->{Agresso_nummer},$ziekenfonds_nummer,$historiek_gkd);
                 sql_toegang_agresso->disconnect_mssql($dbh);
                }
            }else {
             #niets doen
            }
        }
     sub GKD_chk_20_clicked {
         my ($frame, $evt) = @_;
         if ($evt->IsChecked()) {
             if ($main::gkd_commentaar->{20} != 1) {
                 my $historiek_gkd = $frame->{GKD_txt_20}->GetValue();
                 my $gedaan = as400_gegevens->zet_history_gkd_in ($historiek_gkd);
                 if ($gedaan != 1) {
                     sleep 1;
                     $gedaan = as400_gegevens->zet_history_gkd_in ($historiek_gkd);
                     if ($gedaan != 1) {
                              Wx::MessageBox( _T("Kan $historiek_gkd\n\nNiet inzetten"),
                                    _T("Zet commentaar in het GKD"),
                                     wxOK|wxCENTRE,
                                   $main::frame
                              );#code
                         }
                    }
                 my $resultaat  = as400_gegevens->lees_history_gkd($frame);
                 my $dbh = sql_toegang_agresso->setup_mssql_connectie($main::test_prod);
                 sql_toegang_agresso->ubtstatistics_insert_row($dbh,$main::klant->{Agresso_nummer},$ziekenfonds_nummer,$historiek_gkd);
                 sql_toegang_agresso->disconnect_mssql($dbh);
                }
            }else {
             #niets doen
            }
        }
     sub GKD_chk_21_clicked {
         my ($frame, $evt) = @_;
         if ($evt->IsChecked()) {
             if ($main::gkd_commentaar->{21} != 1) {
                 my $historiek_gkd = $frame->{GKD_txt_21}->GetValue();
                  my $gedaan = as400_gegevens->zet_history_gkd_in ($historiek_gkd);
                 if ($gedaan != 1) {
                     sleep 1;
                     $gedaan = as400_gegevens->zet_history_gkd_in ($historiek_gkd);
                     if ($gedaan != 1) {
                              Wx::MessageBox( _T("Kan $historiek_gkd\n\nNiet inzetten"),
                                    _T("Zet commentaar in het GKD"),
                                     wxOK|wxCENTRE,
                                   $main::frame
                              );#code
                         }
                    }
                 my $resultaat  = as400_gegevens->lees_history_gkd($frame);
                 my $dbh = sql_toegang_agresso->setup_mssql_connectie($main::test_prod);
                 sql_toegang_agresso->ubtstatistics_insert_row($dbh,$main::klant->{Agresso_nummer},$ziekenfonds_nummer,$historiek_gkd);
                 sql_toegang_agresso->disconnect_mssql($dbh);
                }
            }else {
             #niets doen
            }
        }
     sub GKD_chk_22_clicked {
         my ($frame, $evt) = @_;
         if ($evt->IsChecked()) {
             if ($main::gkd_commentaar->{22} != 1) {
                 my $historiek_gkd = $frame->{GKD_txt_22}->GetValue();
                  my $gedaan = as400_gegevens->zet_history_gkd_in ($historiek_gkd);
                 if ($gedaan != 1) {
                     sleep 1;
                     $gedaan = as400_gegevens->zet_history_gkd_in ($historiek_gkd);
                     if ($gedaan != 1) {
                              Wx::MessageBox( _T("Kan $historiek_gkd\n\nNiet inzetten"),
                                    _T("Zet commentaar in het GKD"),
                                     wxOK|wxCENTRE,
                                   $main::frame
                              );#code
                         }
                    }
                 my $resultaat  = as400_gegevens->lees_history_gkd($frame);
                 my $dbh = sql_toegang_agresso->setup_mssql_connectie($main::test_prod);
                 sql_toegang_agresso->ubtstatistics_insert_row($dbh,$main::klant->{Agresso_nummer},$ziekenfonds_nummer,$historiek_gkd);
                 sql_toegang_agresso->disconnect_mssql($dbh);
                }
            }else {
             #niets doen
            }
        }
     sub GKD_chk_23_clicked {
         my ($frame, $evt) = @_;
         if ($evt->IsChecked()) {
             if ($main::gkd_commentaar->{23} != 1) {
                 my $historiek_gkd = $frame->{GKD_txt_23}->GetValue();
                  my $gedaan = as400_gegevens->zet_history_gkd_in ($historiek_gkd);
                 if ($gedaan != 1) {
                     sleep 1;
                     $gedaan = as400_gegevens->zet_history_gkd_in ($historiek_gkd);
                     if ($gedaan != 1) {
                              Wx::MessageBox( _T("Kan $historiek_gkd\n\nNiet inzetten"),
                                    _T("Zet commentaar in het GKD"),
                                     wxOK|wxCENTRE,
                                   $main::frame
                              );#code
                         }
                    }
                 my $resultaat  = as400_gegevens->lees_history_gkd($frame);
                 my $dbh = sql_toegang_agresso->setup_mssql_connectie($main::test_prod);
                 sql_toegang_agresso->ubtstatistics_insert_row($dbh,$main::klant->{Agresso_nummer},$ziekenfonds_nummer,$historiek_gkd);
                 sql_toegang_agresso->disconnect_mssql($dbh);
                }
            }else {
             #niets doen
            }
        }
     sub set_values_gkd {
         my ($class,$frame);
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
        }
package OO_brieven;

use Wx qw[:everything];
use base qw(Wx::Frame);
#use Data::Dumper
use strict;
use Wx::Locale gettext => '_T';
use Wx::Event qw(EVT_CHECKBOX);
use Wx::Event qw(EVT_MENU EVT_CLOSE);
use Wx::FS;
use DateTime::Format::Strptime;
use DateTime;
    sub new {
        my ($class, $frame) = @_;
        $frame->{brieven_sizer_1} = Wx::FlexGridSizer->new(6,9, 10, 10);
        $frame->{brieven_Button_MaakBrieven}  = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_brieven}, -1, _T("Kies een Verzekering en maak een Brief"),wxDefaultPosition,wxSIZE(250,20));
        $frame->{brieven_Button_Verzekering}  = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_brieven}, -1, _T("Verzekering"),wxDefaultPosition,wxSIZE(200,20));
        $frame->{brieven_Button_Begin}  = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_brieven}, -1, _T("Begin"),wxDefaultPosition,wxSIZE(80,20));
        $frame->{brieven_Button_Eind}  = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_brieven}, -1, _T("Eind"),wxDefaultPosition,wxSIZE(80,20));
        $frame->{brieven_Button_Wacht}  = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_brieven}, -1, _T("Wacht"),wxDefaultPosition,wxSIZE(80,20));
        $frame->{brieven_Button_ZKF}  = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_brieven}, -1, _T("ZKF/GKD"),wxDefaultPosition,wxSIZE(50,20));
        $frame->{brieven_Button_Dossier}  = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_brieven}, -1, _T("Dossier Nr"),wxDefaultPosition,wxSIZE(80,20));
        $frame->{brieven_Txt_0_contracten_naam}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_brieven}, -1,$main::klant->{contracten}->[0]->{naam},wxDefaultPosition,wxSIZE(200,20));
        $frame->{brieven_Txt_0_contracten_startdatum}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_brieven}, -1,$main::klant->{contracten}->[0]->{startdatum},wxDefaultPosition,wxSIZE(80,20));
        $frame->{brieven_Txt_0_contracten_einddatum}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_brieven}, -1,$main::klant->{contracten}->[0]->{einddatum},wxDefaultPosition,wxSIZE(80,20));
        $frame->{brieven_Txt_1_contracten_naam}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_brieven}, -1,$main::klant->{contracten}->[1]->{naam},wxDefaultPosition,wxSIZE(200,20));
        $frame->{brieven_Txt_1_contracten_startdatum}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_brieven}, -1,$main::klant->{contracten}->[1]->{startdatum},wxDefaultPosition,wxSIZE(80,20));
        $frame->{brieven_Txt_1_contracten_einddatum}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_brieven}, -1,$main::klant->{contracten}->[1]->{einddatum},wxDefaultPosition,wxSIZE(80,20));
        $frame->{brieven_Txt_2_contracten_naam}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_brieven}, -1,$main::klant->{contracten}->[2]->{naam},wxDefaultPosition,wxSIZE(200,20));
        $frame->{brieven_Txt_2_contracten_startdatum}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_brieven}, -1,$main::klant->{contracten}->[2]->{startdatum},wxDefaultPosition,wxSIZE(80,20));
        $frame->{brieven_Txt_2_contracten_einddatum}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_brieven}, -1,$main::klant->{contracten}->[2]->{einddatum},wxDefaultPosition,wxSIZE(80,20));
        $frame->{brieven_Txt_3_contracten_naam}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_brieven}, -1,$main::klant->{contracten}->[3]->{naam},wxDefaultPosition,wxSIZE(200,20));
        $frame->{brieven_Txt_3_contracten_startdatum}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_brieven}, -1,$main::klant->{contracten}->[3]->{startdatum},wxDefaultPosition,wxSIZE(80,20));
        $frame->{brieven_Txt_3_contracten_einddatum}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_brieven}, -1,$main::klant->{contracten}->[3]->{einddatum},wxDefaultPosition,wxSIZE(80,20));
        $frame->{brieven_Txt_4_contracten_naam}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_brieven}, -1,$main::klant->{contracten}->[4]->{naam},wxDefaultPosition,wxSIZE(200,20));
        $frame->{brieven_Txt_4_contracten_startdatum}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_brieven}, -1,$main::klant->{contracten}->[4]->{startdatum},wxDefaultPosition,wxSIZE(80,20));
        $frame->{brieven_Txt_4_contracten_einddatum}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_brieven}, -1,$main::klant->{contracten}->[4]->{einddatum},wxDefaultPosition,wxSIZE(80,20));
        $frame->{brieven_Txt_0_contracten_wachtdatum}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_brieven}, -1,$main::klant->{contracten}->[0]->{wachtdatum},wxDefaultPosition,wxSIZE(80,20));
        $frame->{brieven_Txt_1_contracten_wachtdatum}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_brieven}, -1,$main::klant->{contracten}->[1]->{wachtdatum},wxDefaultPosition,wxSIZE(80,20));
        $frame->{brieven_Txt_2_contracten_wachtdatum}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_brieven}, -1,$main::klant->{contracten}->[2]->{wachtdatum},wxDefaultPosition,wxSIZE(80,20));
        $frame->{brieven_Txt_3_contracten_wachtdatum}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_brieven}, -1,$main::klant->{contracten}->[3]->{wachtdatum},wxDefaultPosition,wxSIZE(80,20));
        $frame->{brieven_Txt_4_contracten_wachtdatum}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_brieven}, -1,$main::klant->{contracten}->[4]->{wachtdatum},wxDefaultPosition,wxSIZE(80,20));
        $frame->{brieven_Txt_0_contracten_zkfnr}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_brieven}, -1,$main::klant->{contracten}->[0]->{zkf_nr},wxDefaultPosition,wxSIZE(50,20));
        $frame->{brieven_Txt_1_contracten_zkfnr}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_brieven}, -1,$main::klant->{contracten}->[1]->{zkf_nr},wxDefaultPosition,wxSIZE(50,20));
        $frame->{brieven_Txt_2_contracten_zkfnr}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_brieven}, -1,$main::klant->{contracten}->[2]->{zkf_nr},wxDefaultPosition,wxSIZE(50,20));
        $frame->{brieven_Txt_3_contracten_zkfnr}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_brieven}, -1,$main::klant->{contracten}->[3]->{zkf_nr},wxDefaultPosition,wxSIZE(50,20));
        $frame->{brieven_Txt_4_contracten_zkfnr}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_brieven}, -1,$main::klant->{contracten}->[4]->{zkf_nr},wxDefaultPosition,wxSIZE(50,20));

        $frame->{brieven_Txt_0_contracten_Dossiernr}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_brieven}, -1,$main::klant->{contracten}->[0]->{contract_nr},wxDefaultPosition,wxSIZE(80,20));
        $frame->{brieven_Txt_1_contracten_Dossiernr}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_brieven}, -1,$main::klant->{contracten}->[1]->{contract_nr},wxDefaultPosition,wxSIZE(80,20));
        $frame->{brieven_Txt_2_contracten_Dossiernr}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_brieven}, -1,$main::klant->{contracten}->[2]->{contract_nr},wxDefaultPosition,wxSIZE(80,20));
        $frame->{brieven_Txt_3_contracten_Dossiernr}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_brieven}, -1,$main::klant->{contracten}->[3]->{contract_nr},wxDefaultPosition,wxSIZE(80,20));
        $frame->{brieven_Txt_4_contracten_Dossiernr}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_brieven}, -1,$main::klant->{contracten}->[4]->{contract_nr},wxDefaultPosition,wxSIZE(80,20));

        $frame->{brieven_chk_0_Contract}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_brieven}, -1,$main::contracts_check[0],wxDefaultPosition,wxSIZE(15,20));
        $frame->{brieven_chk_1_Contract}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_brieven}, -1,$main::contracts_check[1],wxDefaultPosition,wxSIZE(15,20));
        $frame->{brieven_chk_2_Contract}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_brieven}, -1,$main::contracts_check[2],wxDefaultPosition,wxSIZE(15,20));
        $frame->{brieven_chk_3_Contract}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_brieven}, -1,$main::contracts_check[3],wxDefaultPosition,wxSIZE(15,20));
        $frame->{brieven_chk_4_Contract}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_brieven}, -1,$main::contracts_check[4],wxDefaultPosition,wxSIZE(15,20));
        #RIJ1  1+2+3+4+5+6+7
        $frame->{brieven_panel_1} = Wx::Panel->new($frame->{MainFrameNotebookBoven_pane_brieven},-1,wxDefaultPosition,wxSIZE(20,20));
        $frame->{brieven_panel_2} = Wx::Panel->new($frame->{MainFrameNotebookBoven_pane_brieven},-1,wxDefaultPosition,wxSIZE(250,20));
        $frame->{brieven_sizer_1}->Add($frame->{brieven_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
        $frame->{brieven_sizer_1}->Add($frame->{brieven_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
        $frame->{brieven_sizer_1}->Add($frame->{brieven_Button_Verzekering}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
        $frame->{brieven_sizer_1}->Add($frame->{brieven_Button_Begin}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
        $frame->{brieven_sizer_1}->Add($frame->{brieven_Button_Eind}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
        $frame->{brieven_sizer_1}->Add($frame->{brieven_Button_Wacht}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
        $frame->{brieven_sizer_1}->Add($frame->{brieven_Button_ZKF}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
        $frame->{brieven_sizer_1}->Add($frame->{brieven_Button_Dossier}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
        $frame->{brieven_sizer_1}->Add($frame->{brieven_panel_2}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
        #RIJ2  1+2+3+4+5
        $frame->{brieven_sizer_1}->Add($frame->{brieven_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
        $frame->{brieven_sizer_1}->Add($frame->{brieven_chk_0_Contract}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
        $frame->{brieven_sizer_1}->Add($frame->{brieven_Txt_0_contracten_naam}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
        $frame->{brieven_sizer_1}->Add($frame->{brieven_Txt_0_contracten_startdatum}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
        $frame->{brieven_sizer_1}->Add($frame->{brieven_Txt_0_contracten_einddatum}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
        $frame->{brieven_sizer_1}->Add($frame->{brieven_Txt_0_contracten_wachtdatum}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
        $frame->{brieven_sizer_1}->Add($frame->{brieven_Txt_0_contracten_zkfnr}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
        $frame->{brieven_sizer_1}->Add($frame->{brieven_Txt_0_contracten_Dossiernr}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
        $frame->{brieven_sizer_1}->Add($frame->{brieven_panel_2}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
        #RIJ3  1+2+3+4+5
        $frame->{brieven_sizer_1}->Add($frame->{brieven_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
        $frame->{brieven_sizer_1}->Add($frame->{brieven_chk_1_Contract}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
        $frame->{brieven_sizer_1}->Add($frame->{brieven_Txt_1_contracten_naam}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
        $frame->{brieven_sizer_1}->Add($frame->{brieven_Txt_1_contracten_startdatum}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
        $frame->{brieven_sizer_1}->Add($frame->{brieven_Txt_1_contracten_einddatum}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
        $frame->{brieven_sizer_1}->Add($frame->{brieven_Txt_1_contracten_wachtdatum}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
        $frame->{brieven_sizer_1}->Add($frame->{brieven_Txt_1_contracten_zkfnr}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
        $frame->{brieven_sizer_1}->Add($frame->{brieven_Txt_1_contracten_Dossiernr}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
        $frame->{brieven_sizer_1}->Add($frame->{brieven_Button_MaakBrieven}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
        #RIJ4  1+2+3+4+5
        $frame->{brieven_sizer_1}->Add($frame->{brieven_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
        $frame->{brieven_sizer_1}->Add($frame->{brieven_chk_2_Contract}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
        $frame->{brieven_sizer_1}->Add($frame->{brieven_Txt_2_contracten_naam}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
        $frame->{brieven_sizer_1}->Add($frame->{brieven_Txt_2_contracten_startdatum}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
        $frame->{brieven_sizer_1}->Add($frame->{brieven_Txt_2_contracten_einddatum}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
        $frame->{brieven_sizer_1}->Add($frame->{brieven_Txt_2_contracten_wachtdatum}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
        $frame->{brieven_sizer_1}->Add($frame->{brieven_Txt_2_contracten_zkfnr}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
        $frame->{brieven_sizer_1}->Add($frame->{brieven_Txt_2_contracten_Dossiernr}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
        $frame->{brieven_sizer_1}->Add($frame->{brieven_panel_2}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
        #RIJ5  1+2+3+4+5
        $frame->{brieven_sizer_1}->Add($frame->{brieven_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
        $frame->{brieven_sizer_1}->Add($frame->{brieven_chk_3_Contract}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
        $frame->{brieven_sizer_1}->Add($frame->{brieven_Txt_3_contracten_naam}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
        $frame->{brieven_sizer_1}->Add($frame->{brieven_Txt_3_contracten_startdatum}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
        $frame->{brieven_sizer_1}->Add($frame->{brieven_Txt_3_contracten_einddatum}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
        $frame->{brieven_sizer_1}->Add($frame->{brieven_Txt_3_contracten_wachtdatum}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
        $frame->{brieven_sizer_1}->Add($frame->{brieven_Txt_3_contracten_zkfnr}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
        $frame->{brieven_sizer_1}->Add($frame->{brieven_Txt_3_contracten_Dossiernr}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
        $frame->{brieven_sizer_1}->Add($frame->{brieven_panel_2}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
        #RIJ6  1+2+3+4+5
        $frame->{brieven_sizer_1}->Add($frame->{brieven_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
        $frame->{brieven_sizer_1}->Add($frame->{brieven_chk_4_Contract}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
        $frame->{brieven_sizer_1}->Add($frame->{brieven_Txt_4_contracten_naam}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
        $frame->{brieven_sizer_1}->Add($frame->{brieven_Txt_4_contracten_startdatum}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
        $frame->{brieven_sizer_1}->Add($frame->{brieven_Txt_4_contracten_einddatum}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
        $frame->{brieven_sizer_1}->Add($frame->{brieven_Txt_4_contracten_wachtdatum}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
        $frame->{brieven_sizer_1}->Add($frame->{brieven_Txt_4_contracten_zkfnr}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
        $frame->{brieven_sizer_1}->Add($frame->{brieven_Txt_4_contracten_Dossiernr}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
        $frame->{brieven_sizer_1}->Add($frame->{brieven_panel_2}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         Wx::Event::EVT_BUTTON($frame,$frame->{brieven_Button_MaakBrieven},\&Maak_Brief);
         Wx::Event::EVT_CHECKBOX($frame,$frame->{brieven_chk_0_Contract}, \&checkbox_0_Contract_clicked);
         Wx::Event::EVT_CHECKBOX($frame,$frame->{brieven_chk_1_Contract}, \&checkbox_1_Contract_clicked);
         Wx::Event::EVT_CHECKBOX($frame,$frame->{brieven_chk_2_Contract}, \&checkbox_2_Contract_clicked);
         Wx::Event::EVT_CHECKBOX($frame,$frame->{brieven_chk_3_Contract}, \&checkbox_3_Contract_clicked);
         Wx::Event::EVT_CHECKBOX($frame,$frame->{brieven_chk_4_Contract}, \&checkbox__Contract_clicked);
      }
    sub checkbox_0_Contract_clicked {
        my ($frame, $evt) = @_;
        if ($evt->IsChecked()) {
            for (my $i=0; $i < 5; $i++) {
                 $frame->{"brieven_chk_$i\_Contract"}->SetValue(0);
                 $main::contracts_brieven_check[$i] = 0;
            }
            $main::contracts_brieven_check[0] = 1;
            $frame->{"brieven_chk_0_Contract"}->SetValue (1);

         }else {
          for (my $i=0; $i < 5; $i++) {
             $frame->{"brieven_chk_$i\_Contract"}->SetValue(0);
             $main::contracts_brieven_check[$i] = 0;
            }
         }

      }
    sub checkbox_1_Contract_clicked {
       my ($frame, $evt) = @_;
       if ($evt->IsChecked()) {
          for (my $i=0; $i < 5; $i++) {
             $frame->{"brieven_chk_$i\_Contract"}->SetValue(0);
             $main::contracts_brieven_check[$i] = 0;
            }
          $main::contracts_brieven_check[1] = 1;
          $frame->{"brieven_chk_1_Contract"}->SetValue (1);

         }else {
          for (my $i=0; $i < 5; $i++) {
             $frame->{"brieven_chk_$i\_Contract"}->SetValue(0);
             $main::contracts_brieven_check[$i] = 0;
            }
         }
      }
    sub checkbox_2_Contract_clicked {
       my ($frame, $evt) = @_;
       if ($evt->IsChecked()) {
          for (my $i=0; $i < 5; $i++) {
             $frame->{"brieven_chk_$i\_Contract"}->SetValue(0);
             $main::contracts_brieven_check[$i] = 0;
            }
          $main::contracts_brieven_check[2] = 1;
          $frame->{"brieven_chk_2_Contract"}->SetValue (1);

         }else {
          for (my $i=0; $i < 5; $i++) {
             $frame->{"brieven_chk_$i\_Contract"}->SetValue(0);
             $main::contracts_brieven_check[$i] = 0;
            }
         }
      }
    sub checkbox_3_Contract_clicked {
       my ($frame, $evt) = @_;
       if ($evt->IsChecked()) {
          for (my $i=0; $i < 5; $i++) {
             $frame->{"brieven_chk_$i\_Contract"}->SetValue(0);
             $main::contracts_brieven_check[$i] = 0;
            }
          $main::contracts_brieven_check[3] = 1;
          $frame->{"brieven_chk_3_Contract"}->SetValue (1);

         }else {
          for (my $i=0; $i < 5; $i++) {
             $frame->{"brieven_chk_$i\_Contract"}->SetValue(0);
             $main::contracts_brieven_check[$i] = 0;
            }
         }
      }
     sub checkbox_4_Contract_clicked {
       my ($frame, $evt) = @_;
       if ($evt->IsChecked()) {
          for (my $i=0; $i < 5; $i++) {
             $frame->{"brieven_chk_$i\_Contract"}->SetValue(0);
             $main::contracts_brieven_check[$i] = 0;
            }
          $main::contracts_brieven_check[4] = 1;
          $frame->{"brieven_chk_4_Contract"}->SetValue (1);

         }else {
          for (my $i=0; $i < 5; $i++) {
             $frame->{"brieven_chk_$i\_Contract"}->SetValue(0);
             $main::contracts_brieven_check[$i] = 0;
            }
         }
      }
    sub Maak_Brief {
        my ($frame) = @_;
        my $ext_nr = $main::klant->{ExternNummer};
        my $rrn_nr = $main::klant->{Rijksreg_Nr};
        my $zkf = $main::klant->{Ziekenfonds};
        #my $test =$main::klant;
        #my @test = @main::contracts_brieven_check;
        if (!defined $ext_nr or !defined $zkf) {
            Wx::MessageBox( _T("Je moet een persoon opzoeken\nom een brief te maken !"),
                 _T("Brieven Maken"),
                 wxOK|wxCENTRE,
                $frame
               );
         }else {
           my $volgnr_contract = '';
           for (my $i=0; $i < 5; $i++) {
              my $is_checked = $main::contracts_brieven_check[$i];
              $volgnr_contract = $i if ($is_checked == 1);
            }
           if ($volgnr_contract eq '') {
             Wx::MessageBox( _T("Gelieve een verzekering te kiezen"),
                 _T("Brieven Maken"),
                  wxOK|wxCENTRE,
                 $frame
               );
            }else {
             # Open a filedialog where a file can be opened
             my $naam_contract = $main::klant->{contracten}->[$volgnr_contract]->{naam};
             my $contract_nr = $main::klant->{contracten}->[$volgnr_contract]->{contract_nr};
             my $naam_verzekering = $main::klant->{contracten}->[$volgnr_contract]->{naam};
             $naam_verzekering = lc $naam_verzekering;
             my $nummer_verzekering = '';
             if ($naam_verzekering =~ m/hospiforfait/i ) {
                 $naam_verzekering = uc $naam_verzekering;
                 $nummer_verzekering = $main::agresso_instellingen->{verzekeringen}->{"ZKF$zkf"}->{hospiforfait}->{hospiforfait};
             }else {
                 $nummer_verzekering = $main::agresso_instellingen->{verzekeringen}->{"ZKF$zkf"}->{$naam_verzekering};
             }


             print "";
             my $settings = settings->new($zkf);
             my $dbconnectie = connectdb->connect_as400 ($settings->{user_name},$settings->{password},$settings->{name_as400});
             $main::premie =  as400_gegevens->zoek_bijdrage($zkf,$nummer_verzekering,$externnummer,$settings->{ptaxkq_fil},$dbconnectie); #  my $nr_zkf $type_verz= ; my $externnummer; my $betaling_fil; my $dbh = shift @_;
             my $filedlg = Wx::FileDialog->new(  $frame,         # parent
                                          'Open File',   # Caption
                                          '',            # Default directory
                                          '',            # Default file
                                          "Openoffice (*.od)|*.od*", # wildcard
                                          wxFD_OPEN);        # style
             # If the user really selected one
             if ($filedlg->ShowModal==wxID_OK)   {
                 my $filename = $filedlg->GetPath;
                 # my ($class,$ext_nr,$rijksregisternummer,$zkf,$verz_doorgeef,$contract_nr,$sjabloon,$moet_geprint,$printer,@wat_binnenbrengen) = @_;
                my $parser = DateTime::Format::Strptime->new(pattern => '%d-%m-%Y');
                my $wachtdatum = '';
                my $wacht_datum = $main::klant->{contracten}->[$volgnr_contract]->{wachtdatum};
                my $aansluitings_datum = $main::klant->{contracten}->[$volgnr_contract]->{startdatum};
                if ($wacht_datum) {
                     $wachtdatum = $parser->parse_datetime($wacht_datum);
                     $wachtdatum = $wachtdatum->strftime('%Y%m%d');
                     $wachtdatum = substr ($wachtdatum,0,8);
                     my $aansluitingsdatum = $parser->parse_datetime($aansluitings_datum);
                     $aansluitingsdatum = $aansluitingsdatum->strftime('%Y%m%d');
                     $aansluitingsdatum = substr ($aansluitingsdatum,0,8);
                     $vandaag = substr ($vandaag,0,8);
                     if ( $aansluitingsdatum  < $wachtdatum) {
                          $main::bolean_wachttijd = 'met';
                         }else {
                          $bolean_wachttijd = 'zonder';
                         }
                    }
                 maak_brief->maak_oodoc_variabelen($ext_nr,$rrn_nr,$zkf,$naam_contract,$contract_nr,$filename,'nee');
                 print "";
                 # do something useful
               }
            }
         }

      }
package Automatische_brieven;
     use Wx qw(:everything);
     use base qw(Wx::Frame);
     use Wx qw(wxEVT_SCROLL_TOP wxEVT_SCROLL_BOTTOM wxEVT_SCROLL_LINEUP
               wxEVT_SCROLL_LINEDOWN wxEVT_SCROLL_PAGEUP wxEVT_SCROLL_PAGEDOWN
               wxEVT_SCROLL_THUMBTRACK wxEVT_SCROLL_THUMBRELEASE );
     use Wx::Event qw( EVT_BUTTON EVT_TEXT_ENTER EVT_UPDATE_UI );
     #use Wx::ScrolledWindow;
     use Wx::Perl::ListCtrl;
     #use Data::Dumper
     use strict;
     use Wx::Locale gettext => '_T';
     sub new {
         my ($class, $frame) = @_;
         my $teller = 1;
         my $aantal_rij = 8;
         my $btest = $main::brieven_instellingen;
         foreach my $mogelijke_brieven (sort keys $main::brieven_instellingen) {
             my $naambrief = $main::brieven_instellingen->{$mogelijke_brieven}->{naam};
             $frame->{"AB_chk$teller\_brief"}= Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_AB}, -1,$main::welke_brieven_maken->{$mogelijke_brieven}->{moet_gemaakt},wxDefaultPosition,wxSIZE(20,20));
             $frame->{"AB_Txt$teller\_brief"}= Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_AB}, -1,$main::brieven_instellingen->{$mogelijke_brieven}->{naam},wxDefaultPosition,wxSIZE(350,20));
             eval {my $bestaat = $main::brieven_instellingen->{$mogelijke_brieven}->{aanvinkteksten}};
             if (!$@) {
                 if ($main::brieven_instellingen->{$mogelijke_brieven}->{aanvinkteksten} and $mogelijke_brieven) {
                        invulteksten->new($frame,$mogelijke_brieven);#code om extra panes te maken
                    }#code
                }
             $teller +=1;
            }
         $frame->{AB_sizer_1} = Wx::FlexGridSizer->new($aantal_rij,11, 10, 10);
         #$frame->{AB_panel_1} = Wx::VScrolledWindow->new($frame->{MainFrameNotebookBoven_pane_AB},-1,wxDefaultPosition,wxSIZE(25,20));
         $frame->{AB_panel_1} = Wx::Panel->new( $frame->{MainFrameNotebookBoven_pane_AB},-1,wxDefaultPosition,wxSIZE(25,20));
         #$frame->{AB_panel_1}->{scroll} = Wx::ScrolledWindow->new($frame->{AB_panel_1}, wxID_ANY, wxDefaultPosition, wxDefaultSize, wxHSCROLL|wxVSCROLL );
         $frame->{"AB_TXT_brief"}=Wx::StaticText->new($frame->{MainFrameNotebookBoven_pane_AB}, -1,
                                                                           _T("Welke brieven moeten automatisch verzonden worden?"),wxDefaultPosition,wxSIZE(350,20));

         $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{AB_sizer_1}->Add($frame->{"AB_TXT_brief"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);

         $teller =1;
         if ($frame->{"AB_chk$teller\_brief"}) {
             $frame->{AB_sizer_1}->Add($frame->{"AB_chk$teller\_brief"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
             $frame->{AB_sizer_1}->Add($frame->{"AB_Txt$teller\_brief"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
            }else {
             $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
             $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
            }
         $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $teller = 2;
         if ($frame->{"AB_chk$teller\_brief"}) {
             $frame->{AB_sizer_1}->Add($frame->{"AB_chk$teller\_brief"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
             $frame->{AB_sizer_1}->Add($frame->{"AB_Txt$teller\_brief"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
            }else {
             $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
             $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
            }
         $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         #$frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $teller = 3 ;
         if ($frame->{"AB_chk$teller\_brief"}) {
             $frame->{AB_sizer_1}->Add($frame->{"AB_chk$teller\_brief"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
             $frame->{AB_sizer_1}->Add($frame->{"AB_Txt$teller\_brief"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
            }else {
             $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
             $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
            }
         $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $teller = 4;
         if ($frame->{"AB_chk$teller\_brief"}) {
             $frame->{AB_sizer_1}->Add($frame->{"AB_chk$teller\_brief"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
             $frame->{AB_sizer_1}->Add($frame->{"AB_Txt$teller\_brief"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
            }else {
             $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
             $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
            }
         $teller = 5;
         if ($frame->{"AB_chk$teller\_brief"}) {
             $frame->{AB_sizer_1}->Add($frame->{"AB_chk$teller\_brief"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
             $frame->{AB_sizer_1}->Add($frame->{"AB_Txt$teller\_brief"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
            }else {
             $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
             $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
            }
         $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $teller = 6;
         if ($frame->{"AB_chk$teller\_brief"}) {
             $frame->{AB_sizer_1}->Add($frame->{"AB_chk$teller\_brief"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
             $frame->{AB_sizer_1}->Add($frame->{"AB_Txt$teller\_brief"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
            }else {
             $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
             $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
            }
         $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $teller = 7;
         if ($frame->{"AB_chk$teller\_brief"}) {
             $frame->{AB_sizer_1}->Add($frame->{"AB_chk$teller\_brief"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
             $frame->{AB_sizer_1}->Add($frame->{"AB_Txt$teller\_brief"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
            }else {
             $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
             $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
            }
         $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $teller = 8;
         if ($frame->{"AB_chk$teller\_brief"}) {
             $frame->{AB_sizer_1}->Add($frame->{"AB_chk$teller\_brief"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
             $frame->{AB_sizer_1}->Add($frame->{"AB_Txt$teller\_brief"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
            }else {
             $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
             $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
            }
         $teller = 9;
         if ($frame->{"AB_chk$teller\_brief"}) {
             $frame->{AB_sizer_1}->Add($frame->{"AB_chk$teller\_brief"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
             $frame->{AB_sizer_1}->Add($frame->{"AB_Txt$teller\_brief"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
            }else {
             $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
             $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
            }
         $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $teller = 10;
         if ($frame->{"AB_chk$teller\_brief"}) {
             $frame->{AB_sizer_1}->Add($frame->{"AB_chk$teller\_brief"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
             $frame->{AB_sizer_1}->Add($frame->{"AB_Txt$teller\_brief"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
            }else {
             $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
             $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
            }
          $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $teller = 11;
         if ($frame->{"AB_chk$teller\_brief"}) {
             $frame->{AB_sizer_1}->Add($frame->{"AB_chk$teller\_brief"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
             $frame->{AB_sizer_1}->Add($frame->{"AB_Txt$teller\_brief"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
            }else {
             $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
             $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
            }
          $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $teller = 12;
         if ($frame->{"AB_chk$teller\_brief"}) {
             $frame->{AB_sizer_1}->Add($frame->{"AB_chk$teller\_brief"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
             $frame->{AB_sizer_1}->Add($frame->{"AB_Txt$teller\_brief"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
            }else {
             $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
             $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
            }
          $teller = 13;
         if ($frame->{"AB_chk$teller\_brief"}) {
             $frame->{AB_sizer_1}->Add($frame->{"AB_chk$teller\_brief"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
             $frame->{AB_sizer_1}->Add($frame->{"AB_Txt$teller\_brief"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
            }else {
             $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
             $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
            }
          $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $teller = 14;
         if ($frame->{"AB_chk$teller\_brief"}) {
             $frame->{AB_sizer_1}->Add($frame->{"AB_chk$teller\_brief"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
             $frame->{AB_sizer_1}->Add($frame->{"AB_Txt$teller\_brief"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
            }else {
             $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
             $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
            }
          $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $teller = 15;
         if ($frame->{"AB_chk$teller\_brief"}) {
             $frame->{AB_sizer_1}->Add($frame->{"AB_chk$teller\_brief"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
             $frame->{AB_sizer_1}->Add($frame->{"AB_Txt$teller\_brief"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
            }else {
             $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
             $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
            }
          $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $teller = 16;
         if ($frame->{"AB_chk$teller\_brief"}) {
             $frame->{AB_sizer_1}->Add($frame->{"AB_chk$teller\_brief"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
             $frame->{AB_sizer_1}->Add($frame->{"AB_Txt$teller\_brief"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
            }else {
             $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
             $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
            }
         $teller = 17;
         if ($frame->{"AB_chk$teller\_brief"}) {
             $frame->{AB_sizer_1}->Add($frame->{"AB_chk$teller\_brief"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
             $frame->{AB_sizer_1}->Add($frame->{"AB_Txt$teller\_brief"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
            }else {
             $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
             $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
            }
          $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $teller = 18;
         if ($frame->{"AB_chk$teller\_brief"}) {
             $frame->{AB_sizer_1}->Add($frame->{"AB_chk$teller\_brief"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
             $frame->{AB_sizer_1}->Add($frame->{"AB_Txt$teller\_brief"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
            }else {
             $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
             $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
            }
          $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $teller = 19;
         if ($frame->{"AB_chk$teller\_brief"}) {
             $frame->{AB_sizer_1}->Add($frame->{"AB_chk$teller\_brief"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
             $frame->{AB_sizer_1}->Add($frame->{"AB_Txt$teller\_brief"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
            }else {
             $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
             $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
            }
          $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $teller = 20;
         if ($frame->{"AB_chk$teller\_brief"}) {
             $frame->{AB_sizer_1}->Add($frame->{"AB_chk$teller\_brief"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
             $frame->{AB_sizer_1}->Add($frame->{"AB_Txt$teller\_brief"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
            }else {
             $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
             $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
            }
         $teller = 21;
         if ($frame->{"AB_chk$teller\_brief"}) {
             $frame->{AB_sizer_1}->Add($frame->{"AB_chk$teller\_brief"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
             $frame->{AB_sizer_1}->Add($frame->{"AB_Txt$teller\_brief"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
            }else {
             $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
             $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
            }
         $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $teller = 22;
         if ($frame->{"AB_chk$teller\_brief"}) {
             $frame->{AB_sizer_1}->Add($frame->{"AB_chk$teller\_brief"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
             $frame->{AB_sizer_1}->Add($frame->{"AB_Txt$teller\_brief"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
            }else {
             $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
             $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
            }
         $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $teller = 23;
         if ($frame->{"AB_chk$teller\_brief"}) {
             $frame->{AB_sizer_1}->Add($frame->{"AB_chk$teller\_brief"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
             $frame->{AB_sizer_1}->Add($frame->{"AB_Txt$teller\_brief"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
            }else {
             $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
             $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
            }
         $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $teller = 24;
         if ($frame->{"AB_chk$teller\_brief"}) {
             $frame->{AB_sizer_1}->Add($frame->{"AB_chk$teller\_brief"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
             $frame->{AB_sizer_1}->Add($frame->{"AB_Txt$teller\_brief"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
            }else {
             $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
             $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
            }
         $teller = 25;
         if ($frame->{"AB_chk$teller\_brief"}) {
             $frame->{AB_sizer_1}->Add($frame->{"AB_chk$teller\_brief"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
             $frame->{AB_sizer_1}->Add($frame->{"AB_Txt$teller\_brief"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
            }else {
             $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
             $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
            }
         $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
          $teller = 26;
         if ($frame->{"AB_chk$teller\_brief"}) {
             $frame->{AB_sizer_1}->Add($frame->{"AB_chk$teller\_brief"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
             $frame->{AB_sizer_1}->Add($frame->{"AB_Txt$teller\_brief"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
            }else {
             $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
             $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
            }
         $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
          $teller = 27;
         if ($frame->{"AB_chk$teller\_brief"}) {
             $frame->{AB_sizer_1}->Add($frame->{"AB_chk$teller\_brief"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
             $frame->{AB_sizer_1}->Add($frame->{"AB_Txt$teller\_brief"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
            }else {
             $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
             $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
            }
         $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $teller = 28;
         if ($frame->{"AB_chk$teller\_brief"}) {
             $frame->{AB_sizer_1}->Add($frame->{"AB_chk$teller\_brief"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
             $frame->{AB_sizer_1}->Add($frame->{"AB_Txt$teller\_brief"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
            }else {
             $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
             $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
            }
         $teller = 29;
         if ($frame->{"AB_chk$teller\_brief"}) {
             $frame->{AB_sizer_1}->Add($frame->{"AB_chk$teller\_brief"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
             $frame->{AB_sizer_1}->Add($frame->{"AB_Txt$teller\_brief"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
            }else {
             $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
             $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
            }
         $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $teller = 30;
         if ($frame->{"AB_chk$teller\_brief"}) {
             $frame->{AB_sizer_1}->Add($frame->{"AB_chk$teller\_brief"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
             $frame->{AB_sizer_1}->Add($frame->{"AB_Txt$teller\_brief"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
            }else {
             $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
             $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
            }
         $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $teller = 31;
         if ($frame->{"AB_chk$teller\_brief"}) {
             $frame->{AB_sizer_1}->Add($frame->{"AB_chk$teller\_brief"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
             $frame->{AB_sizer_1}->Add($frame->{"AB_Txt$teller\_brief"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
            }else {
             $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
             $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
            }
         $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $teller = 32;
         if ($frame->{"AB_chk$teller\_brief"}) {
             $frame->{AB_sizer_1}->Add($frame->{"AB_chk$teller\_brief"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
             $frame->{AB_sizer_1}->Add($frame->{"AB_Txt$teller\_brief"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
            }else {
             $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
             $frame->{AB_sizer_1}->Add($frame->{AB_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
            }


          print "";
        }
package invulteksten;
 use Wx qw[:everything];
     use base qw(Wx::Frame);
     use Wx qw(wxEVT_SCROLL_TOP wxEVT_SCROLL_BOTTOM wxEVT_SCROLL_LINEUP
               wxEVT_SCROLL_LINEDOWN wxEVT_SCROLL_PAGEUP wxEVT_SCROLL_PAGEDOWN
               wxEVT_SCROLL_THUMBTRACK wxEVT_SCROLL_THUMBRELEASE );
     use Wx::Event qw( EVT_BUTTON EVT_TEXT_ENTER EVT_UPDATE_UI );

     use Wx::Perl::ListCtrl;
     #use Data::Dumper
     use strict;
     use Wx::Locale gettext => '_T';
     sub new {
          my ($class, $frame ,$mogelijke_brieven) = @_;
          my $naambrief = $main::brieven_instellingen->{$mogelijke_brieven}->{naam};
          my $teller =1;
          foreach my $brief_tekst (sort keys $main::brieven_instellingen->{$mogelijke_brieven}->{aanvinkteksten}) {
             $frame->{"$mogelijke_brieven\_chk$teller\_brief"}= Wx::CheckBox->new($frame->{"MainFrameNotebookBoven_pane\_$mogelijke_brieven"}, -1,
                                                                                  $main::welke_brieven_maken->{$mogelijke_brieven}->{aanvinkteksten}->{$brief_tekst}->{aangevinkt}
                                                                                  ,wxDefaultPosition,wxSIZE(20,20));
             $frame->{"$mogelijke_brieven\_Txt$teller\_brief"}= Wx::TextCtrl->new($frame->{"MainFrameNotebookBoven_pane\_$mogelijke_brieven"}, -1,
                                                                                  $main::brieven_instellingen->{$mogelijke_brieven}->{aanvinkteksten}->{$brief_tekst}
                                                                                  ,wxDefaultPosition,wxSIZE(650,20));

             $teller +=1;
            }
         my $aantal_rij =6;
         $frame->{"$mogelijke_brieven\_Txt\_brief"}=Wx::StaticText->new($frame->{"MainFrameNotebookBoven_pane\_$mogelijke_brieven"}, -1,
                                                                           _T("Wat moet er nog worden binnen gebracht voor -> \"$naambrief\" ?"),wxDefaultPosition,wxSIZE(650,20));
         $frame->{"$mogelijke_brieven\_sizer_1"} = Wx::FlexGridSizer->new($aantal_rij,5, 10, 10);
         $frame->{"$mogelijke_brieven\_panel_1"} = Wx::Panel->new( $frame->{"MainFrameNotebookBoven_pane\_$mogelijke_brieven"},-1,wxDefaultPosition,wxSIZE(25,20));

         $frame->{"$mogelijke_brieven\_sizer_1"}->Add($frame->{"$mogelijke_brieven\_panel_1"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{"$mogelijke_brieven\_sizer_1"}->Add($frame->{"$mogelijke_brieven\_Txt\_brief"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{"$mogelijke_brieven\_sizer_1"}->Add($frame->{"$mogelijke_brieven\_panel_1"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{"$mogelijke_brieven\_sizer_1"}->Add($frame->{"$mogelijke_brieven\_panel_1"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{"$mogelijke_brieven\_sizer_1"}->Add($frame->{"$mogelijke_brieven\_panel_1"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $teller =1;
         if ($frame->{"$mogelijke_brieven\_chk$teller\_brief"}) {
             $frame->{"$mogelijke_brieven\_sizer_1"}->Add($frame->{"$mogelijke_brieven\_chk$teller\_brief"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
             $frame->{"$mogelijke_brieven\_sizer_1"}->Add($frame->{"$mogelijke_brieven\_Txt$teller\_brief"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
            }else {
             $frame->{"$mogelijke_brieven\_sizer_1"}->Add($frame->{"$mogelijke_brieven\_panel_1"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
             $frame->{"$mogelijke_brieven\_sizer_1"}->Add($frame->{"$mogelijke_brieven\_panel_1"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
            }
         $frame->{"$mogelijke_brieven\_sizer_1"}->Add($frame->{"$mogelijke_brieven\_panel_1"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $teller =2;
         if ($frame->{"$mogelijke_brieven\_chk$teller\_brief"}) {
             $frame->{"$mogelijke_brieven\_sizer_1"}->Add($frame->{"$mogelijke_brieven\_chk$teller\_brief"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
             $frame->{"$mogelijke_brieven\_sizer_1"}->Add($frame->{"$mogelijke_brieven\_Txt$teller\_brief"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
            }else {
             $frame->{"$mogelijke_brieven\_sizer_1"}->Add($frame->{"$mogelijke_brieven\_panel_1"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
             $frame->{"$mogelijke_brieven\_sizer_1"}->Add($frame->{"$mogelijke_brieven\_panel_1"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
            }
         $teller =3;
         if ($frame->{"$mogelijke_brieven\_chk$teller\_brief"}) {
             $frame->{"$mogelijke_brieven\_sizer_1"}->Add($frame->{"$mogelijke_brieven\_chk$teller\_brief"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
             $frame->{"$mogelijke_brieven\_sizer_1"}->Add($frame->{"$mogelijke_brieven\_Txt$teller\_brief"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
            }else {
             $frame->{"$mogelijke_brieven\_sizer_1"}->Add($frame->{"$mogelijke_brieven\_panel_1"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
             $frame->{"$mogelijke_brieven\_sizer_1"}->Add($frame->{"$mogelijke_brieven\_panel_1"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
            }
         $frame->{"$mogelijke_brieven\_sizer_1"}->Add($frame->{"$mogelijke_brieven\_panel_1"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $teller =4;
         if ($frame->{"$mogelijke_brieven\_chk$teller\_brief"}) {
             $frame->{"$mogelijke_brieven\_sizer_1"}->Add($frame->{"$mogelijke_brieven\_chk$teller\_brief"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
             $frame->{"$mogelijke_brieven\_sizer_1"}->Add($frame->{"$mogelijke_brieven\_Txt$teller\_brief"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
            }else {
             $frame->{"$mogelijke_brieven\_sizer_1"}->Add($frame->{"$mogelijke_brieven\_panel_1"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
             $frame->{"$mogelijke_brieven\_sizer_1"}->Add($frame->{"$mogelijke_brieven\_panel_1"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
            }
         $teller =5;
         if ($frame->{"$mogelijke_brieven\_chk$teller\_brief"}) {
             $frame->{"$mogelijke_brieven\_sizer_1"}->Add($frame->{"$mogelijke_brieven\_chk$teller\_brief"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
             $frame->{"$mogelijke_brieven\_sizer_1"}->Add($frame->{"$mogelijke_brieven\_Txt$teller\_brief"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
            }else {
             $frame->{"$mogelijke_brieven\_sizer_1"}->Add($frame->{"$mogelijke_brieven\_panel_1"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
             $frame->{"$mogelijke_brieven\_sizer_1"}->Add($frame->{"$mogelijke_brieven\_panel_1"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
            }
         $frame->{"$mogelijke_brieven\_sizer_1"}->Add($frame->{"$mogelijke_brieven\_panel_1"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $teller =6;
         if ($frame->{"$mogelijke_brieven\_chk$teller\_brief"}) {
             $frame->{"$mogelijke_brieven\_sizer_1"}->Add($frame->{"$mogelijke_brieven\_chk$teller\_brief"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
             $frame->{"$mogelijke_brieven\_sizer_1"}->Add($frame->{"$mogelijke_brieven\_Txt$teller\_brief"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
            }else {
             $frame->{"$mogelijke_brieven\_sizer_1"}->Add($frame->{"$mogelijke_brieven\_panel_1"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
             $frame->{"$mogelijke_brieven\_sizer_1"}->Add($frame->{"$mogelijke_brieven\_panel_1"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
            }
         $teller =7;
         if ($frame->{"$mogelijke_brieven\_chk$teller\_brief"}) {
             $frame->{"$mogelijke_brieven\_sizer_1"}->Add($frame->{"$mogelijke_brieven\_chk$teller\_brief"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
             $frame->{"$mogelijke_brieven\_sizer_1"}->Add($frame->{"$mogelijke_brieven\_Txt$teller\_brief"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
            }else {
             $frame->{"$mogelijke_brieven\_sizer_1"}->Add($frame->{"$mogelijke_brieven\_panel_1"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
             $frame->{"$mogelijke_brieven\_sizer_1"}->Add($frame->{"$mogelijke_brieven\_panel_1"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
            }
         $frame->{"$mogelijke_brieven\_sizer_1"}->Add($frame->{"$mogelijke_brieven\_panel_1"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $teller =8;
         if ($frame->{"$mogelijke_brieven\_chk$teller\_brief"}) {
             $frame->{"$mogelijke_brieven\_sizer_1"}->Add($frame->{"$mogelijke_brieven\_chk$teller\_brief"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
             $frame->{"$mogelijke_brieven\_sizer_1"}->Add($frame->{"$mogelijke_brieven\_Txt$teller\_brief"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
            }else {
             $frame->{"$mogelijke_brieven\_sizer_1"}->Add($frame->{"$mogelijke_brieven\_panel_1"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
             $frame->{"$mogelijke_brieven\_sizer_1"}->Add($frame->{"$mogelijke_brieven\_panel_1"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
            }
         $teller =9;
         if ($frame->{"$mogelijke_brieven\_chk$teller\_brief"}) {
             $frame->{"$mogelijke_brieven\_sizer_1"}->Add($frame->{"$mogelijke_brieven\_chk$teller\_brief"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
             $frame->{"$mogelijke_brieven\_sizer_1"}->Add($frame->{"$mogelijke_brieven\_Txt$teller\_brief"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
            }else {
             $frame->{"$mogelijke_brieven\_sizer_1"}->Add($frame->{"$mogelijke_brieven\_panel_1"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
             $frame->{"$mogelijke_brieven\_sizer_1"}->Add($frame->{"$mogelijke_brieven\_panel_1"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
            }
         $frame->{"$mogelijke_brieven\_sizer_1"}->Add($frame->{"$mogelijke_brieven\_panel_1"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $teller =10;
         if ($frame->{"$mogelijke_brieven\_chk$teller\_brief"}) {
             $frame->{"$mogelijke_brieven\_sizer_1"}->Add($frame->{"$mogelijke_brieven\_chk$teller\_brief"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
             $frame->{"$mogelijke_brieven\_sizer_1"}->Add($frame->{"$mogelijke_brieven\_Txt$teller\_brief"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
            }else {
             $frame->{"$mogelijke_brieven\_sizer_1"}->Add($frame->{"$mogelijke_brieven\_panel_1"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
             $frame->{"$mogelijke_brieven\_sizer_1"}->Add($frame->{"$mogelijke_brieven\_panel_1"}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
            }
        }
package ToolBarMainFrame;
     use Wx qw[:everything];
     use base qw(Wx::Frame);
     use Wx::Event qw(EVT_MENU);
     use Wx::Event qw(EVT_TOOL);
     use Wx::Event qw(EVT_TOOL_ENTER);
     use Wx::Event qw(EVT_TOOL_RCLICKED);
     use Date::Manip::DM5 ;
     use Date::Calc qw(:all);
     #use Data::Dumper
     use strict;
     use Wx::Locale gettext => '_T';
     sub new {
         my ($class, $frame) = @_;

         $frame->{frame_toolbar} = Wx::ToolBar->new($frame, -1, wxDefaultPosition, wxDefaultSize, );

         $frame->{opslaan}=$frame->{frame_toolbar}->AddTool(1100, _T("Naar Agresso sturen"), Wx::Bitmap->new("\\\\s298file101.zkf200mut.prd\\250-B\\Applicaties\\Assurcard\\bitmap\\opslaan.bmp", wxBITMAP_TYPE_ANY), wxNullBitmap, wxITEM_NORMAL, _T("Naar Agresso"), "");
         $frame->{opslaan}=$frame->{frame_toolbar}->AddTool(1101, _T("Cancel"), Wx::Bitmap->new("\\\\s298file101.zkf200mut.prd\\250-B\\Applicaties\\Assurcard\\bitmap\\cancel.bmp", wxBITMAP_TYPE_ANY), wxNullBitmap, wxITEM_NORMAL, _T("Cancel"), "");
         $frame->{opslaan}=$frame->{frame_toolbar}->AddTool(1102, _T("Bestaat"), Wx::Bitmap->new("\\\\s298file101.zkf200mut.prd\\250-B\\Applicaties\\Assurcard\\bitmap\\Bestaat.bmp", wxBITMAP_TYPE_ANY), wxNullBitmap, wxITEM_NORMAL, _T("Bestaat"), "") if ($main::bestaande_klant == 1);
         $frame->{opslaan}=$frame->{frame_toolbar}->AddTool(1103, _T("Print"), Wx::Bitmap->new("\\\\s298file101.zkf200mut.prd\\250-B\\Applicaties\\Assurcard\\bitmap\\printen.bmp", wxBITMAP_TYPE_ANY), wxNullBitmap, wxITEM_NORMAL, _T("Print"), "");
         $frame->{Reset}=$frame->{frame_toolbar}->AddTool(1105, _T("Reset"), Wx::Bitmap->new("\\\\s298file101.zkf200mut.prd\\250-B\\Applicaties\\Assurcard\\bitmap\\Reset.bmp",wxBITMAP_TYPE_ANY), wxNullBitmap, wxITEM_NORMAL, _T("Reset"), "");
         #$frame->{vorige_klant_met_factuur} = $frame->{frame_toolbar}->AddTool(1101, _T("Vorige"), Wx::Bitmap->new("\\\\s298file101.zkf200mut.prd\\250-B\\Applicaties\\Assurcard\\bitmap\\vorige.bmp", wxBITMAP_TYPE_ANY), wxNullBitmap, wxITEM_NORMAL, _T("Vorige"), "");
         #$frame->{volgende_klant_met_factuur} =$frame->{frame_toolbar}->AddTool(1102, _T("Volgende"), Wx::Bitmap->new("\\\\s298file101.zkf200mut.prd\\250-B\\Applicaties\\Assurcard\\bitmap\\volgende.bmp", wxBITMAP_TYPE_ANY), wxNullBitmap, wxITEM_NORMAL, _T("Volgende"), "");
         #$frame->{factuur_ophalen}=$frame->{frame_toolbar}->AddTool(1103, _T("Factuur Ophalen"), Wx::Bitmap->new("\\\\s298file101.zkf200mut.prd\\250-B\\Applicaties\\Assurcard\\bitmap\\factuur_ophalen1.bmp",wxBITMAP_TYPE_ANY), wxNullBitmap, wxITEM_NORMAL, _T("Factuur ophalen"), "");
         #$frame->{factuur_Verwerken}=$frame->{frame_toolbar}->AddTool(1104, _T("Factuur Verwerken"), Wx::Bitmap->new("\\\\s298file101.zkf200mut.prd\\250-B\\Applicaties\\Assurcard\\bitmap\\Factuur_verwerken.bmp",wxBITMAP_TYPE_ANY), wxNullBitmap, wxITEM_NORMAL, _T("Factuur Verwerken"), "");
         #$frame->{Reset}=$frame->{frame_toolbar}->AddTool(1106, _T("Factuur niet behandelen"), Wx::Bitmap->new("\\\\s298file101.zkf200mut.prd\\250-B\\Applicaties\\Assurcard\\bitmap\\factuur_niet_behandelen.bmp",wxBITMAP_TYPE_ANY), wxNullBitmap, wxITEM_NORMAL, _T("Factuur niet behandelen"), "");
         #$frame->{Reset}=$frame->{frame_toolbar}->AddTool(1105, _T("Reset"), Wx::Bitmap->new("\\\\s298file101.zkf200mut.prd\\250-B\\Applicaties\\Assurcard\\bitmap\\Reset.bmp",wxBITMAP_TYPE_ANY), wxNullBitmap, wxITEM_NORMAL, _T("Reset"), "");
         #$frame->{Reset}=$frame->{frame_toolbar}->AddTool(1110, _T("spacer"), Wx::Bitmap->new("\\\\s298file101.zkf200mut.prd\\250-B\\Applicaties\\Assurcard\\bitmap\\spacer.bmp",wxBITMAP_TYPE_ANY), wxNullBitmap, wxITEM_NORMAL, _T("spacer"), "");
         #$frame->{frame_toolbar}->AddSeparator;
         #$frame->{Toolbar_choice_leden_met_assurcard_facturen} = Wx::Choice->new($frame->{frame_toolbar}, 26,wxDefaultPosition,wxSIZE(100,20),\@main::klanten_met_assurcard_facturen);
         #$frame->{frame_toolbar}->AddControl($frame->{Toolbar_choice_leden_met_assurcard_facturen});

         $frame->{frame_toolbar}->Realize();
         Wx::Event::EVT_MENU( $frame,1100,\&opslaan);
         Wx::Event::EVT_MENU( $frame,1101,\&cancel);
         Wx::Event::EVT_MENU( $frame,1103,\&printen);
         Wx::Event::EVT_MENU($frame,1105,\&Reset);
         #Wx::Event::EVT_MENU($frame,1103,\&haal_factuur_op);
         #Wx::Event::EVT_MENU($frame,1104,\&verwerk_factuur);
         #Wx::Event::EVT_MENU($frame,1105,\&Reset);
         #Wx::Event::EVT_MENU($frame,1106,\&factuur_vuilbak);
         #
         return ($frame);
        }
     sub cancel {
         die;
     }
     sub opslaan {
         ErnstigeZiekte->Ernstige_ziekte_aandoening_save($frame);
         BestaandeAandoening_ErnstigeZiekte->Bestaande_aandoening_save($frame);
         my $bool = $frame->Close();
         main->new($externnummer,$ziekenfonds_nummer);

        }
     sub printen {
         my $verzekeringsteller = 0;
         my $volgnr_contract = '';
         my $naam_contract ='';
         my  $contract_nr ='';
         foreach my $mog_verz (keys $main::klant->{contracten}) {
             $verzekeringsteller += 1;
         }
         if ($verzekeringsteller > 1) {
             for (my $i=0; $i < 3; $i++) {
                 my $is_checked = $main::frame->{"lov_chk_$i\_Contract"}->GetValue();
                 $volgnr_contract = $i if ($is_checked == 1);
                }
             if ($volgnr_contract eq '') {
                 Wx::MessageBox( _T("Gelieve een verzekering te kiezen"),
                     _T("Brieven Maken"),
                      wxOK|wxCENTRE,
                     $frame
                    );
                 return ();
                }else {
                 $naam_contract = $main::klant->{contracten}->[$volgnr_contract]->{naam};
                 $contract_nr = $main::klant->{contracten}->[$volgnr_contract]->{contract_nr};
                 my $contract_nr = $main::klant->{contracten}->[$volgnr_contract]->{contract_nr};
                 my $naam_verzekering = $main::klant->{contracten}->[$volgnr_contract]->{naam};
                 $naam_verzekering = lc $naam_verzekering;
                 my $nummer_verzekering = '';
                 if ($naam_verzekering =~ m/hospiforfait/i ) {
                     $naam_verzekering = uc $naam_verzekering;
                     $nummer_verzekering = $main::agresso_instellingen->{verzekeringen}->{"ZKF$ziekenfonds_nummer"}->{hospiforfait}->{hospiforfait};
                    }else {
                     $nummer_verzekering = $main::agresso_instellingen->{verzekeringen}->{"ZKF$ziekenfonds_nummer"}->{$naam_verzekering};
                    }
                 print "";
                 my $settings = settings->new($ziekenfonds_nummer);
                 my $dbconnectie = connectdb->connect_as400 ($settings->{user_name},$settings->{password},$settings->{name_as400});
                 $main::premie =  as400_gegevens->zoek_bijdrage($ziekenfonds_nummer,$nummer_verzekering,$externnummer,$settings->{ptaxkq_fil},$dbconnectie); #  my $nr_zkf $type_verz= ; my $externnummer; my $betaling_fil; my $dbh = shift @_;
                }
            }elsif ($verzekeringsteller = 1) {
                $volgnr_contract = 0;
                $naam_contract = $main::klant->{contracten}->[$volgnr_contract]->{naam};
                $contract_nr = $main::klant->{contracten}->[$volgnr_contract]->{contract_nr};
                my $naam_verzekering = $main::klant->{contracten}->[$volgnr_contract]->{naam};
                $naam_verzekering = lc $naam_verzekering;
                my $nummer_verzekering = '';
                if ($naam_verzekering =~ m/hospiforfait/i ) {
                     $naam_verzekering = uc $naam_verzekering;
                     $nummer_verzekering = $main::agresso_instellingen->{verzekeringen}->{"ZKF$ziekenfonds_nummer"}->{hospiforfait}->{hospiforfait};
                    }else {
                     $nummer_verzekering = $main::agresso_instellingen->{verzekeringen}->{"ZKF$ziekenfonds_nummer"}->{$naam_verzekering};
                    }
                 print "";
                 my $settings = settings->new($ziekenfonds_nummer);
                 my $dbconnectie = connectdb->connect_as400 ($settings->{user_name},$settings->{password},$settings->{name_as400});
                 $main::premie =  as400_gegevens->zoek_bijdrage($ziekenfonds_nummer,$nummer_verzekering,$externnummer,$settings->{ptaxkq_fil},$dbconnectie); my $class = shift @_;#  my $nr_zkf $type_verz= ; my $externnummer; my $betaling_fil; my $dbh = shift @_;
            }
          my $parser = DateTime::Format::Strptime->new(pattern => '%d-%m-%Y');
          my $wachtdatum = '';
          my $wacht_datum = $main::klant->{contracten}->[$volgnr_contract]->{wachtdatum};
          my $aansluitings_datum = $main::klant->{contracten}->[$volgnr_contract]->{startdatum};
          if ($wacht_datum) {
                $wachtdatum = $parser->parse_datetime($wacht_datum);
                $wachtdatum = $wachtdatum->strftime('%Y%m%d');
                $wachtdatum = substr ($wachtdatum,0,8);
                my $aansluitingsdatum = $parser->parse_datetime($aansluitings_datum);
                $aansluitingsdatum = $aansluitingsdatum->strftime('%Y%m%d');
                $aansluitingsdatum = substr ($aansluitingsdatum,0,8);
                $vandaag = substr ($vandaag,0,8);
                if ( $aansluitingsdatum  < $wachtdatum) {
                     $main::bolean_wachttijd = 'met';
                    }else {
                     $bolean_wachttijd = 'zonder';
                    }
               }

          my $teller = 1;
          foreach my $mogelijke_brieven (sort keys $main::brieven_instellingen) {
             my $Ischecked = $main::frame->{"AB_chk$teller\_brief"}->GetValue;
             if ($Ischecked == 1) {
                 my $sjabloon =$main::brieven_instellingen->{$mogelijke_brieven}->{sjabloon};
                 my @wat_binnenbrengen;
                 my $bestaat_in_xml = 1;
                 eval {foreach my $mogelijke_tekst (keys $main::brieven_instellingen->{$mogelijke_brieven}->{aanvinkteksten}) {}};
                 if (!$@) {
                     my $teller1 =1;
                     foreach my $mogelijke_tekst (sort keys $main::brieven_instellingen->{$mogelijke_brieven}->{aanvinkteksten}) {
                         my $Ischecked_tekst = $main::frame->{"$mogelijke_brieven\_chk$teller1\_brief"}->GetValue;
                         if ($Ischecked_tekst == 1) {
                             my $wat_moet_binnen_gebracht = $main::brieven_instellingen->{$mogelijke_brieven}->{aanvinkteksten}->{$mogelijke_tekst};
                             #sql_toegang_agresso->afxvmobtoremind_insert_row($main::dbh_agresso,$main::klant->{Agresso_nummer},$sjabloon,
                             #                                                   $wat_moet_binnen_gebracht,$dagen_eerste_herinnering,$dagen_tweede_herinnering,
                             #                                                   $dagen_nagging);
                            push (@wat_binnenbrengen,$wat_moet_binnen_gebracht);
                          }
                         $teller1 +=1;
                        }
                    }else {
                     my $wat_moet_binnen_gebracht = '';
                     #sql_toegang_agresso->afxvmobtoremind_insert_row($main::dbh_agresso,$main::klant->{Agresso_nummer},$sjabloon,
                     #                                                  $wat_moet_binnen_gebracht,$dagen_eerste_herinnering,$dagen_tweede_herinnering,
                     #                                                  $dagen_nagging);
                    }
                 my $moet_geprint= $main::brieven_instellingen->{$mogelijke_brieven}->{printen};
                 $moet_geprint= '' if(!defined $moet_geprint);
                 my $printer = $main::brieven_instellingen->{$mogelijke_brieven}->{printer};
                 $printer = '' if(!defined $printer);
                 my $popup = $main::brieven_instellingen->{$mogelijke_brieven}->{popup_brief};
                 $popup = '' if(!defined $popup );
                 my $pdf_naar_agresso = $main::brieven_instellingen->{$mogelijke_brieven}->{pdf_naar_agresso};
                 $pdf_naar_agresso = '' if (!defined $pdf_naar_agresso);
                 #oproepen brief ($class,$ext_nr,$rijksregisternummer,$zkf,$verz_doorgeef,$contract_nr,$sjabloon,$moet_geprint,$printer,@wat_binnenbrengen) = @_;

                 #($main::externnummer,$main::klant->{Rijksreg_Nr},$main::ziekenfonds_nummer,,,$sjabloon,$moet_geprint,$printer,$pdf_naar_agresso,@wat_binnenbrengen)
                 my $totsjabloon = "$main::agresso_instellingen->{plaats_sjablonen_brieven}\\$sjabloon";
                 #my $printfilename;
                 #my $gelukt_pdf;
                 my ($printfilename)=maak_brief->maak_oodoc_variabelen ($main::externnummer,$main::klant->{Rijksreg_Nr},$main::ziekenfonds_nummer,$naam_contract,$contract_nr,$totsjabloon,$moet_geprint,$printer,$pdf_naar_agresso,$bestaat_in_xml,$popup,@wat_binnenbrengen);
                 if ($printfilename eq 'error file bestaat niet') {
                     #code
                 }else {
                      sql_toegang_agresso->afxvmobtoprint_insert_row($main::dbh_agresso,$main::klant->{Agresso_nummer},$printfilename,$moet_geprint);
                        my $dagen_nagging ;
                        my $dagen_tweede_herinnering ;
                        eval {my $dagen_eerste_herinnering = $main::brieven_instellingen->{$mogelijke_brieven}->{dagen_eerste_herinnering}};
                        if (!$@) {
                            my $dagen_eerste_herinnering = $main::brieven_instellingen->{$mogelijke_brieven}->{dagen_eerste_herinnering};
                            if ($dagen_eerste_herinnering > 0) {
                                eval {$dagen_tweede_herinnering = $main::brieven_instellingen->{$mogelijke_brieven}->{dagen_tweede_herinnering}};
                                if (!$@) {
                                    $dagen_tweede_herinnering = $main::brieven_instellingen->{$mogelijke_brieven}->{dagen_tweede_herinnering};
                                    eval {my $dagen_nagging = $main::brieven_instellingen->{$mogelijke_brieven}->{dagen_nagging}};
                                     if (!$@) {
                                        $dagen_nagging = $main::brieven_instellingen->{$mogelijke_brieven}->{dagen_nagging};
                                       }else {
                                        $dagen_nagging = 14;
                                      }
                                   }else {
                                     $dagen_tweede_herinnering = 21;
                                   }
                                foreach my $wat_moet_binnen_gebracht (@wat_binnenbrengen) {
                                     sql_toegang_agresso->afxvmobtoremind_insert_row($main::dbh_agresso,$main::klant->{Agresso_nummer},$printfilename,
                                     $wat_moet_binnen_gebracht,$dagen_eerste_herinnering,$dagen_tweede_herinnering,$dagen_nagging);
                                   }
                               }
                        }
                    }


                 #if ($gelukt_pdf ne 'gelukt') {
                 #     Wx::MessageBox( _T("PDF is niet naar Agresso gestuurd"),
                 #           _T("PDF $mogelijke_brieven naar Agresso: "),
                 #           wxOK|wxCENTRE,
                 #              $frame
                 #       );##code
                 #   }

                 print "";
                }
             $teller += 1;
            }
         for (my $i=0; $i < 5; $i++) {
                 my $is_checked = $main::frame->{"lov_chk_$i\_Contract"}->SetValue(0);
                }
         for (my $i = 1;$i < 33;$i++) {
             $frame->{"AB_chk$i\_brief"}->SetValue(0) if ($frame->{"AB_chk$i\_brief"});
            }
         foreach my $mogelijke_brieven (keys $main::brieven_instellingen) {
             for (my $i = 1;$i < 11;$i++) {
                 $frame->{"$mogelijke_brieven\_chk$i\_brief"}->SetValue(0) if ($frame->{"$mogelijke_brieven\_chk$i\_brief"});
                }
            }
     }
     sub Reset {
         my($frame, $event) = @_;
         undef $main::klant;
         undef %main::DATA;
         $main::cdata='';
         undef $main::ziekenfonds_nummer;
         undef $main::externnummer;
         undef $main::gkd_commentaar;
         $main::total_ok =0;
         $main::total_nok=0;
         $main::bestaande_klant =0;
         $main::premie = 0;
         undef $main::rijks_register_nummer;
         undef $main::bolean_wachttijd;
         $main::frame->{lov_Txt_Agressso_nr}->SetValue('');
         $main::frame->{lov_Txt_Naam}->SetValue('');
         $main::frame->{lov_Txt_GeboorteDatum}->SetValue('');
         $main::frame->{lov_Txt_RijksReg_nr}->SetValue('');
         $main::frame->{lov_Txt_0_contracten_startdatum}->SetValue('');
         $main::frame->{lov_Txt_1_contracten_startdatum}->SetValue('');
         $main::frame->{lov_Txt_2_contracten_startdatum}->SetValue('');
         $main::frame->{lov_Txt_3_contracten_startdatum}->SetValue('');
         $main::frame->{lov_Txt_4_contracten_startdatum}->SetValue('');
         $main::frame->{lov_Txt_0_contracten_einddatum}->SetValue('');
         $main::frame->{lov_Txt_1_contracten_einddatum}->SetValue('');
         $main::frame->{lov_Txt_2_contracten_einddatum}->SetValue('');
         $main::frame->{lov_Txt_3_contracten_einddatum}->SetValue('');
         $main::frame->{lov_Txt_4_contracten_einddatum}->SetValue('');
         $main::frame->{lov_Txt_0_contracten_naam}->SetValue('');
         $main::frame->{lov_Txt_1_contracten_naam}->SetValue('');
         $main::frame->{lov_Txt_2_contracten_naam}->SetValue('');
         $main::frame->{lov_Txt_3_contracten_naam}->SetValue('');
         $main::frame->{lov_Txt_4_contracten_naam}->SetValue('');
         $main::frame->{lov_Txt_0_contracten_dossiernr}->SetValue('');
         $main::frame->{lov_Txt_1_contracten_dossiernr}->SetValue('');
         $main::frame->{lov_Txt_2_contracten_dossiernr}->SetValue('');
         $main::frame->{lov_Txt_3_contracten_dossiernr}->SetValue('');
         $main::frame->{lov_Txt_4_contracten_dossiernr}->SetValue('');
         $main::frame->{lov_Txt_0_contracten_zkfnr}->SetValue('');
         $main::frame->{lov_Txt_1_contracten_zkfnr}->SetValue('');
         $main::frame->{lov_Txt_2_contracten_zkfnr}->SetValue('');
         $main::frame->{lov_Txt_3_contracten_zkfnr}->SetValue('');
         $main::frame->{lov_Txt_4_contracten_zkfnr}->SetValue('');
         $main::frame->{lov_Txt_0_contracten_wachtdatum}->SetValue('');
         $main::frame->{lov_Txt_1_contracten_wachtdatum}->SetValue('');
         $main::frame->{lov_Txt_2_contracten_wachtdatum}->SetValue('');
         $main::frame->{lov_Txt_3_contracten_wachtdatum}->SetValue('');
         $main::frame->{lov_Txt_4_contracten_wachtdatum}->SetValue('');
         $main::frame->{lov_chk_0_Contract}->SetValue('');
         $main::frame->{lov_chk_1_Contract}->SetValue('');
         $main::frame->{lov_chk_2_Contract}->SetValue('');
         $main::frame->{lov_chk_3_Contract}->SetValue('');

         $main::frame->{BA_Txt_0_aandoening}->SetValue('');
         $main::frame->{BA_Txt_1_aandoening}->SetValue('');
         $main::frame->{BA_Txt_2_aandoening}->SetValue('');
         $main::frame->{BA_Txt_3_aandoening}->SetValue('');
         $main::frame->{BA_Txt_4_aandoening}->SetValue('');
         $main::frame->{BA_Txt_5_aandoening}->SetValue('');
         $main::frame->{BA_Txt_6_aandoening}->SetValue('');
         $main::frame->{BA_Txt_7_aandoening}->SetValue('');
         $main::frame->{BA_Txt_8_aandoening}->SetValue('');

         $main::frame->{BA_Txt_0_begindatum}->SetValue('');
         $main::frame->{BA_Txt_1_begindatum}->SetValue('');
         $main::frame->{BA_Txt_2_begindatum}->SetValue('');
         $main::frame->{BA_Txt_3_begindatum}->SetValue('');
         $main::frame->{BA_Txt_4_begindatum}->SetValue('');
         $main::frame->{BA_Txt_5_begindatum}->SetValue('');
         $main::frame->{BA_Txt_6_begindatum}->SetValue('');
         $main::frame->{BA_Txt_7_begindatum}->SetValue('');
         $main::frame->{BA_Txt_8_begindatum}->SetValue('');

         $main::frame->{BA_Txt_0_einddatum}->SetValue('');
         $main::frame->{BA_Txt_1_einddatum}->SetValue('');
         $main::frame->{BA_Txt_2_einddatum}->SetValue('');
         $main::frame->{BA_Txt_3_einddatum}->SetValue('');
         $main::frame->{BA_Txt_4_einddatum}->SetValue('');
         $main::frame->{BA_Txt_5_einddatum}->SetValue('');
         $main::frame->{BA_Txt_6_einddatum}->SetValue('');
         $main::frame->{BA_Txt_7_einddatum}->SetValue('');
         $main::frame->{BA_Txt_8_einddatum}->SetValue('');

         $main::frame->{BA_Txt_0_verzekering}->SetSelection(wxNOT_FOUND);#     ->SetSelection(wxNOT_FOUND);
         $main::frame->{BA_Txt_1_verzekering}->SetSelection(wxNOT_FOUND);
         $main::frame->{BA_Txt_2_verzekering}->SetSelection(wxNOT_FOUND);
         $main::frame->{BA_Txt_3_verzekering}->SetSelection(wxNOT_FOUND);
         $main::frame->{BA_Txt_4_verzekering}->SetSelection(wxNOT_FOUND);
         $main::frame->{BA_Txt_5_verzekering}->SetSelection(wxNOT_FOUND);
         $main::frame->{BA_Txt_6_verzekering}->SetSelection(wxNOT_FOUND);
         $main::frame->{BA_Txt_7_verzekering}->SetSelection(wxNOT_FOUND);
         $main::frame->{BA_Txt_8_verzekering}->SetSelection(wxNOT_FOUND);

         $main::frame->{EZ_Txt_0_ziekte}->SetValue('');
         $main::frame->{EZ_Txt_1_ziekte}->SetValue('');
         $main::frame->{EZ_Txt_2_ziekte}->SetValue('');
         $main::frame->{EZ_Txt_3_ziekte}->SetValue('');
         $main::frame->{EZ_Txt_4_ziekte}->SetValue('');
         $main::frame->{EZ_Txt_5_ziekte}->SetValue('');
         $main::frame->{EZ_Txt_6_ziekte}->SetValue('');
         $main::frame->{EZ_Txt_7_ziekte}->SetValue('');
         $main::frame->{EZ_Txt_8_ziekte}->SetValue('');

         $main::frame->{EZ_Txt_0_verzekering}->SetSelection(wxNOT_FOUND);
         $main::frame->{EZ_Txt_1_verzekering}->SetSelection(wxNOT_FOUND);
         $main::frame->{EZ_Txt_2_verzekering}->SetSelection(wxNOT_FOUND);
         $main::frame->{EZ_Txt_3_verzekering}->SetSelection(wxNOT_FOUND);
         $main::frame->{EZ_Txt_4_verzekering}->SetSelection(wxNOT_FOUND);
         $main::frame->{EZ_Txt_5_verzekering}->SetSelection(wxNOT_FOUND);
         $main::frame->{EZ_Txt_6_verzekering}->SetSelection(wxNOT_FOUND);
         $main::frame->{EZ_Txt_7_verzekering}->SetSelection(wxNOT_FOUND);
         $main::frame->{EZ_Txt_8_verzekering}->SetSelection(wxNOT_FOUND);

         $main::frame->{GKD_chk_0}->SetValue('');
         $main::frame->{GKD_chk_1}->SetValue('');
         $main::frame->{GKD_chk_2}->SetValue('');
         $main::frame->{GKD_chk_3}->SetValue('');
         $main::frame->{GKD_chk_4}->SetValue('');
         $main::frame->{GKD_chk_5}->SetValue('');
         $main::frame->{GKD_chk_6}->SetValue('');
         $main::frame->{GKD_chk_7}->SetValue('');
         $main::frame->{GKD_chk_8}->SetValue('');
         $main::frame->{GKD_chk_9}->SetValue('');

         $main::frame->{GKD_chk_10}->SetValue('');
         $main::frame->{GKD_chk_11}->SetValue('');
         $main::frame->{GKD_chk_12}->SetValue('');
         $main::frame->{GKD_chk_13}->SetValue('');
         $main::frame->{GKD_chk_14}->SetValue('');
         $main::frame->{GKD_chk_15}->SetValue('');
         $main::frame->{GKD_chk_16}->SetValue('');
         $main::frame->{GKD_chk_17}->SetValue('');
         $main::frame->{GKD_chk_18}->SetValue('');
         $main::frame->{GKD_chk_19}->SetValue('');
         $main::frame->{GKD_chk_20}->SetValue('');
         $main::frame->{GKD_chk_21}->SetValue('');
         $main::frame->{GKD_chk_22}->SetValue('');
         $main::frame->{GKD_chk_23}->SetValue('');

         $main::frame->{brieven_Txt_0_contracten_naam}->SetValue('');
         $main::frame->{brieven_Txt_0_contracten_startdatum}->SetValue('');
         $main::frame->{brieven_Txt_0_contracten_einddatum}->SetValue('');
         $main::frame->{brieven_Txt_0_contracten_wachtdatum}->SetValue('');
         $main::frame->{brieven_Txt_0_contracten_zkfnr}->SetValue('');
         $main::frame->{brieven_Txt_0_contracten_Dossiernr}->SetValue('');
         $main::frame->{brieven_chk_0_Contract}->SetValue('');

         $main::frame->{brieven_Txt_1_contracten_naam}->SetValue('');
         $main::frame->{brieven_Txt_1_contracten_startdatum}->SetValue('');
         $main::frame->{brieven_Txt_1_contracten_einddatum}->SetValue('');
         $main::frame->{brieven_Txt_1_contracten_wachtdatum}->SetValue('');
         $main::frame->{brieven_Txt_1_contracten_zkfnr}->SetValue('');
         $main::frame->{brieven_Txt_1_contracten_Dossiernr}->SetValue('');
         $main::frame->{brieven_chk_1_Contract}->SetValue('');

         $main::frame->{brieven_Txt_2_contracten_naam}->SetValue('');
         $main::frame->{brieven_Txt_2_contracten_startdatum}->SetValue('');
         $main::frame->{brieven_Txt_2_contracten_einddatum}->SetValue('');
         $main::frame->{brieven_Txt_2_contracten_wachtdatum}->SetValue('');
         $main::frame->{brieven_Txt_2_contracten_zkfnr}->SetValue('');
         $main::frame->{brieven_Txt_2_contracten_Dossiernr}->SetValue('');
         $main::frame->{brieven_chk_2_Contract}->SetValue('');

         $main::frame->{brieven_Txt_3_contracten_naam}->SetValue('');
         $main::frame->{brieven_Txt_3_contracten_startdatum}->SetValue('');
         $main::frame->{brieven_Txt_3_contracten_einddatum}->SetValue('');
         $main::frame->{brieven_Txt_3_contracten_wachtdatum}->SetValue('');
         $main::frame->{brieven_Txt_3_contracten_zkfnr}->SetValue('');
         $main::frame->{brieven_Txt_3_contracten_Dossiernr}->SetValue('');
         $main::frame->{brieven_chk_3_Contract}->SetValue('');

         $main::frame->{brieven_Txt_4_contracten_naam}->SetValue('');
         $main::frame->{brieven_Txt_4_contracten_startdatum}->SetValue('');
         $main::frame->{brieven_Txt_4_contracten_einddatum}->SetValue('');
         $main::frame->{brieven_Txt_4_contracten_wachtdatum}->SetValue('');
         $main::frame->{brieven_Txt_4_contracten_zkfnr}->SetValue('');
         $main::frame->{brieven_Txt_4_contracten_Dossiernr}->SetValue('');
         my $teller =1;
         foreach my $mogelijke_brieven (keys $main::brieven_instellingen) {
                 $main::frame->{"AB_chk$teller\_brief"}->SetValue('');
                 eval {my $bestaat = $main::brieven_instellingen->{$mogelijke_brieven}->{aanvinkteksten}};
                 if (!$@) {
                        if ($main::brieven_instellingen->{$mogelijke_brieven}->{aanvinkteksten} and $mogelijke_brieven) {
                              my $teller_invul =1;
                              foreach my $brief_tekst (sort keys $main::brieven_instellingen->{$mogelijke_brieven}->{aanvinkteksten}) {
                                        $main::frame->{"$mogelijke_brieven\_chk$teller_invul\_brief"}->SetValue('');
                                        $teller_invul +=1;
                                   }
                         }
                    }
               }
     }
package sql_toegang_agresso;

#use strict;

#our $dbh_mssql;

     sub setup_mssql_connectie {
          my $mode = $main::test_prod;
          my $database;
          $database = $main::agresso_instellingen->{"Agresso_Database_$mode"};          
          my $ip = $main::agresso_instellingen->{"Agresso_SQL_$mode"};
          my $dbh_mssql;
          my $dsn_mssql = join "", (
              "dbi:ODBC:",
              "Driver={SQL Server};",
              #"Server=S998XXLSQL01.CPC998.BE\\i200;",
              "Server=$ip;", # nieuwe database server 2016 05 S000WP1XXLSQL01.mutworld.be\i200
              "UID=HOSPIPLUS;",
              "PWD=ihuho4sdxn;",
              "Database=$database",
              #"Database=agraccept",
             );
           my $user = 'HOSPIPLUS';
           my $passwd = 'ihuho4sdxn';
          
           my $db_options = {
              PrintError => 1,
              RaiseError => 1,
              AutoCommit => 1, #0 werkt niet in
              LongReadLen =>2000,
     
             };
          #
          # connect to database
          #
          $dbh_mssql = DBI->connect($dsn_mssql, $user, $passwd, $db_options) or exit_msg("Can't connect: $DBI::errstr");
          return ($dbh_mssql)
    }
        sub cannot_connect {
             my( $self,$user_name ) = @_;
             my $info = Wx::AboutDialogInfo->new;
              $info->SetName( 'User or password' );
              $info->SetVersion( '' );
              $info->SetDescription( "User: $user_name not active on Agresso" );
              $info->SetCopyright( '' );
              Wx::AboutBox( $info );
            }
        sub disconnect_mssql {
             my ($class,$dbh_mssql) =  @_;
             $dbh_mssql->disconnect;
        }
        sub afxvmobaandoen_delete_rows {
             my ($class,$dbh,$dim_value) = @_;
             my $client ='VMOB';
             $dbh->do("DELETE FROM afxvmobaandoen WHERE dim_value = '$dim_value' and client = '$client' ");
            }
        sub afxvmobaandoen_get_rows {
             my ($class,$dbh,$dim_value) = @_;
             my $client ='VMOB';
             my $sql =("SELECT line_no,product,aandoening,begindatum,einddatum,last_update,user_id
                      FROM afxvmobaandoen WHERE dim_value = '$dim_value' and client = '$client' ");
             my $sth = $dbh->prepare($sql);
             $sth->execute();
             my $nr=0;
             while (my @aandoeningen = $sth->fetchrow_array) {
                 $nr = $aandoeningen[0];
                 $main::klant->{aandoeningen}->[$nr]->{verzekering} = $aandoeningen[1];
                 $main::klant->{aandoeningen}->[$nr]->{aandoening}= $aandoeningen[2];
                 my $begindatum = $aandoeningen[3];
                 $begindatum = substr ($begindatum,0,10);
                 my @begindat = split (/\-/,$begindatum);
                 $main::klant->{aandoeningen}->[$nr]->{begindatum} =$begindat[2]."-".$begindat[1]."-".$begindat[0];
                 my $einddatum = $aandoeningen[4];
                 $einddatum = substr ($einddatum,0,10);
                 my @einddat = split (/\-/,$einddatum);
                 $main::klant->{aandoeningen}->[$nr]->{einddatum}=$einddat[2]."-".$einddat[1]."-".$einddat[0];

             }

            }
        sub afxvmobaandoen_insert_row {
             my ($class,$dbh,$dim_value) = @_;
             my $client ='VMOB';
             # completed 0 stadium is verwerk factuur aangevinkt 1 = asuurcard verkoopsorder gemaakt 2 ass verkooporder en hospi credit aangemaakt
             my $attribute_id = 'A4';
             my $aandoening = '';
             #my $dim_value = '100001';
             my $teller=0;
             for (my $nr = 0; $nr < 9;$nr++) {
                 $aandoening = $main::klant->{aandoeningen}->[$nr]->{aandoening};
                 if ($aandoening ne '') {
                     #my $agrtid = $dbh->selectrow_array("SELECT IDENT_CURRENT('afxvmobaandoen')+1");
                     my $verzekering = uc $main::klant->{aandoeningen}->[$nr]->{verzekering};
                     my $begindatum = $main::klant->{aandoeningen}->[$nr]->{begindatum};
                     #switch maamd en dag sql mm/dd/jjjj ipv dd/mm/jjjj
                     my @begindat = split (/\//,$begindatum);
                     $begindatum = $begindat[1]."/".$begindat[0]."/".$begindat[2];
                     my $einddatum = $main::klant->{aandoeningen}->[$nr]->{einddatum};
                     my @einddat = split (/\//,$einddatum);
                     $einddatum = $einddat[1]."/".$einddat[0]."/".$einddat[2];
                     my $user_id = 'WEBSERV';
                     my $zetin = "insert into afxvmobaandoen (attribute_id,dim_value,line_no,client,product,aandoening,begindatum,einddatum,last_update,user_id)
                     values ('$attribute_id','$dim_value',$teller,'$client','$verzekering','$aandoening','$begindatum','$einddatum',getdate(),'$user_id')";
                     my $sth= $dbh ->prepare($zetin);
                     $sth -> execute();
                     $sth -> finish();
                     $teller +=1;
                    }

                }
        }
        sub afxvmobziekten_delete_rows {
             my ($class,$dbh,$dim_value) = @_;
             my $client ='VMOB';
             $dbh->do("DELETE FROM afxvmobziekten WHERE dim_value = '$dim_value' and client = '$client' ");
            }
        sub afxvmobziekten_get_rows {
             my ($class,$dbh,$dim_value) = @_;
             my $client ='VMOB';
             my $sql =("SELECT line_no,product,ziekte,last_update,user_id
                      FROM afxvmobziekten WHERE dim_value = '$dim_value' and client = '$client' ");
             my $sth = $dbh->prepare($sql);
             $sth->execute();
             my $nr=0;
             while (my @aandoeningen = $sth->fetchrow_array) {
                 $nr = $aandoeningen[0];
                 $main::klant->{ziekten}->[$nr]->{verzekering} = $aandoeningen[1];
                 $main::klant->{ziekten}->[$nr]->{ziekte}= $aandoeningen[2];
                }
            }
        sub afxvmobziekten_insert_row {
             my ($class,$dbh,$dim_value) = @_;
             my $client ='VMOB';
             # completed 0 stadium is verwerk factuur aangevinkt 1 = asuurcard verkoopsorder gemaakt 2 ass verkooporder en hospi credit aangemaakt
             my $attribute_id = 'A4';
             my $ziekte = '';
             #my $dim_value = '100001';
             my $teller=0;
             for (my $nr = 0; $nr < 9;$nr++) {
                 $ziekte = $main::klant->{ziekten}->[$nr]->{ziekte};
                 if ($ziekte ne '') {
                     #my $agrtid = $dbh->selectrow_array("SELECT IDENT_CURRENT('afxvmobziekten')+1");
                     my $verzekering = uc $main::klant->{ziekten}->[$nr]->{verzekering};
                     my $user_id = 'WEBSERV';
                     my $zetin = "insert into afxvmobziekten (attribute_id,dim_value,line_no,client,product,ziekte,last_update,user_id)
                     values ('$attribute_id','$dim_value',$teller,'$client','$verzekering','$ziekte',getdate(),'$user_id')";
                     my $sth= $dbh ->prepare($zetin);
                     $sth -> execute();
                     $sth -> finish();
                     $teller +=1;
                    }

                }
        }
        sub afxvmobtoprint_insert_row {
             my ($class,$dbh,$dim_value,$naam_sjabloon,$moet_geprint) = @_; #$dim_value is agresso nr
             my $client ='VMOB';
             my $attribute_id = 'A4';
             my $user_id = 'WEBSERV';
             my $teller = $dbh->selectrow_array("SELECT MAX(line_no) FROM afxvmobtoprint WHERE client = '$client' and dim_value = '$dim_value'");
             $teller +=1;
             my $zetin = '';
             if (uc $moet_geprint eq 'JA' or uc $moet_geprint eq 'YES'){
                     $zetin = "insert into afxvmobtoprint (attribute_id,dim_value,line_no,client,date_from,date_to,naam_sjabloon,datum_ingezet,datum_geprint,last_update,user_id)
                     values ('$attribute_id','$dim_value',$teller,'$client',getdate(),getdate(),'$naam_sjabloon',getdate(),getdate(),getdate(),'$user_id')";
             }else {
                     $zetin = "insert into afxvmobtoprint (attribute_id,dim_value,line_no,client,date_from,date_to,naam_sjabloon,datum_ingezet,datum_geprint,last_update,user_id)
                     values ('$attribute_id','$dim_value',$teller,'$client',getdate(),getdate(),'$naam_sjabloon',getdate(),'',getdate(),'$user_id')";
             }

             my $sth= $dbh ->prepare($zetin);
             $sth -> execute();
             $sth -> finish();
             print "";
            }
        sub afxvmobtoremind_insert_row {
             my ($class,$dbh,$dim_value,$naam_sjabloon,$wat_moet_binnen_gebracht,$dagen_eerste_her,$dagen_tweede_her,$dagen_nag) = @_; #$dim_value is agresso nr
             my $client ='VMOB';
             my $attribute_id = 'A4';
             my $user_id = 'WEBSERV';
             my $totaaldagen = $dagen_eerste_her+$dagen_tweede_her;
             my $nag = $totaaldagen+$dagen_nag;
             my $teller = $dbh->selectrow_array("SELECT MAX(line_no) FROM afxvmobtoremind WHERE client = '$client' and dim_value = '$dim_value'");
             $teller +=1;
             my $zetin = "insert into afxvmobtoremind (attribute_id,dim_value,line_no,client,date_from,date_to,naam_sjabloon,wat_moet_binnen_gebracht,datum_ingezet,
                     datum_eerste_her,datum_eerste_her_geprint,datum_tweede_her,datum_tweede_her_geprint,start_nagging_datum,last_update,user_id)
                     values ('$attribute_id','$dim_value',$teller,'$client',getdate(),getdate(),'$naam_sjabloon','$wat_moet_binnen_gebracht', getdate(),
                     getdate() +$dagen_eerste_her,'',getdate() +$totaaldagen,'',getdate() +$nag,getdate(),'$user_id')";
             my $sth= $dbh ->prepare($zetin);
             $sth -> execute();
             $sth -> finish();
             print "";
            }
        sub ubtstatistics_insert_row { #statistieken wat men allemaal doet
            my ($class,$dbh,$apar_id,$zkf_nr,$gkd_tekst) = @_;
            my $client ='VMOB';
            my $zetin = "insert into ubtstatistics (client,apar_id,zkf_nr,stat_text,date_insert,stat_counter)
                     values ('$client','$apar_id',$zkf_nr,'$gkd_tekst',getdate(),1)";
            my $sth= $dbh ->prepare($zetin);
            $sth -> execute();
            $sth -> finish();
            print "";
          }


package as400_gegevens;
     sub checkbetaling {
     my ($self,$nr_zkf,$type_verz,$externnummer,$betaling_fil,$dbh) =  @_ ;
  
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
     my $sqlbetaling =("SELECT IDFDKQ,EXIDKQ,ABTVKQ,ABVYKQ,ABVMKQ,ABCNKQ,ABCOKQ,AT79KQ FROM $betaling_fil WHERE IDFDKQ = $nr_zkf and EXIDKQ  = $externnummer and ABTVKQ  = $type_verz ");
     my $sthbetaling = $dbh->prepare( $sqlbetaling );
     $sthbetaling ->execute();
     my @betalingen = () ;
     my @laatstebetaling=();
     my $rijenteller = 0;
     my $hebben_nooit_betaald =0;
     my %betalingenh = ();
     my $k;
     my $kold =0;
     my $eerste = 1;
     my $jaarb =0;
     my $maandb = 0;
     my $bedragb = 0;
     my $saldob =0;
     my $totb =0;
     while(@betalingen =$sthbetaling ->fetchrow_array)  {
         $betalingenh{($betalingen[3]*100+$betalingen[4])}{'betaald'} += $betalingen[5]; #zien of er gecrditeerd wordt        
         $betalingenh{($betalingen[3]*100+$betalingen[4])}{'jaar'} = $betalingen[3]; 
         $betalingenh{($betalingen[3]*100+$betalingen[4])}{'maand'} = $betalingen[4];
         $betalingenh{($betalingen[3]*100+$betalingen[4])}{'bedrag'} = $betalingen[5];
         $betalingenh{($betalingen[3]*100+$betalingen[4])}{'saldo'} = $betalingen[6];
         $betalingenh{($betalingen[3]*100+$betalingen[4])}{'totaal'} = $betalingen[7];
         #print "@betalingen->\n";
         if ($rijenteller== 0) {
           $jaarb = $betalingen[3]; #code
           $maandb =$betalingen[4];
           $hebben_nooit_betaald =1;
         }
         
         $rijenteller +=1;
         
        }
     foreach $k (sort keys %betalingenh) {
          
         if (($eerste == 1) and ($betalingenh{$k}{'saldo'} == 0 ) or $betalingenh{$k}{'betaald'} == 0  ) {
            $kold = $k;
            #print "->eerste -kold $kold \n";
            $jaarb = $betalingenh{$k}{'jaar'} ;
            $maandb = $betalingenh{$k}{'maand'};
            $bedragb = $betalingenh{$k}{'bedrag'};
            $saldob = $betalingenh{$k}{'saldo'};
            $totb = $betalingenh{$k}{'totaal'};
            $eerste = 0;
            $hebben_nooit_betaald =0;
         }
         if (($k > $kold) and  ($betalingenh{$k}{'saldo'} == 0  or $betalingenh{$k}{'betaald'} == 0 ) ){
            $kold = $k;
            #print "->tweede -kold $kold \n";
            $jaarb = $betalingenh{$k}{'jaar'} ;
            $maandb = $betalingenh{$k}{'maand'};
            $bedragb = $betalingenh{$k}{'bedrag'};
            $saldob = $betalingenh{$k}{'saldo'};
            $totb = $betalingenh{$k}{'totaal'};
            $hebben_nooit_betaald = 0;
        }
      #print "$betalingenh{$k}{'jaar'} $betalingenh{$k}{'maand'} $betalingenh{$k}{'bedrag'}  $betalingenh{$k}{'saldo'} $betalingenh{$k}{'totaal'}\n";
      #print  "->$jaarb,$maandb,$bedragb,$saldob,$totb\n";    
     }
     return ($jaarb,$maandb,$bedragb,$saldob,$totb,$hebben_nooit_betaald );
    }
     sub zet_history_gkd_in {
         my ($class,$commentaar)  =  @_;
         my $ext_nr = $main::klant->{ExternNummer};
         my $zkf = $main::klant->{Ziekenfonds};
         if (!defined $ext_nr or !defined $zkf) {
               return ('kies lid');#code
         }
         #1 A.ORG                 organization                    CHARACTER         3
         #2 A.CONTACTID           contact id                       INTEGER           9        0
         #3 A.TYPE                contact type 1:phone,2:email     SMALLINT          4        0
         #4 A.TARGETTYPE          0=prospect, 1=member             SMALLINT          4        0
         #5 A.TARGETID            prospect id or member id         DECIMAL          13        0
         #6 A.OFFICE              office manager                   SMALLINT          4        0
         #7 A.SECTION                                               SMALLINT          4        0
         #8 A.ACTION              1=creation,2=update,3=single c   SMALLINT          4        0
         #9 A.COMMENT             manager comments                  VARCHAR        1024
         #10 A.TECHVERSIONNUMBER                                   INTEGER           9
         #11 A.TECHCREATIONUSER                                    VARCHAR          10
         #12 A.TECHCREATIONDATE                                     TIMESTAMP        26
         #13 A.TECHLASTUPDATEUSER                                    VARCHAR          10
         #14 A.TECHLASTUPDATEDATE                          TIMESTAMP        26
         #15 A.TECHORGANIZATION                             CHARACTER         3
         #16 A.COMPLAINTCOMMENT    complaints comments      VARCHAR        1024
         #17 A.IDMT                mut for fusion concern  SMALLINT          4
         # 1            2           3       4                   5           6       7       8           9                       10              11              12                          13                  14                          15
         # ORG       CONTACTID     TYPE  TARGETTYPE            TARGETID   OFFICE  SECTION   ACTION  COMMENT                 ECHVERSIONNUMBER  TECHCREATIONUSER  TECHCREATIONDATE            TECHLASTUPDATEUSER  TECHLASTUPDATEDATE           IDMT
         #203        739,735        7           1     810,003,677,473        0      200        3   test 21092011                          0   HC                2011-09-21-12.43.58.000000  HC                  2011-09-21-13.05.57.000000   0
         #                                                                                                                                                      2011-09-21-17.10.35.000000
         $commentaar =~ s/^\s+//;
         $commentaar =~ s/\s+$//;
         my $ziekf_nr = $settings->{zkfnummer};
         my $cuser =$settings->{user_name};
         my $tabel = $settings->{'gkd_contactId_fil'};
         my $dbh = connectdb->connect_as400 ($settings->{user_name},$settings->{password},$settings->{name_as400}) ;
         my $volgnummer1 = $dbh->selectrow_array ("SELECT CONTACTID FROM $settings->{'gkd_hist_fil'} WHERE ORG =  $settings->{'zkfnummer'} ORDER BY CONTACTID DESC");
         $volgnummer1 +=1 ;         
         my $volgnummer =$dbh->selectrow_array ("SELECT counter FROM $settings->{'gkd_contactId_fil'} WHERE org = $zkf ORDER BY counter DESC");
         $volgnummer = $volgnummer - $zkf*10000000000;
         $volgnummer = $volgnummer*1;
         print "volgnummer1 $volgnummer1 ->volgnummer $volgnummer\n";
         my $sth ;
         my $max_insert =1;
         until ($volgnummer1 <= $volgnummer) {
                my $volgnr = ("SELECT counter FROM NEW TABLE(insert into $tabel (org, TECHVERSIONNUMBER, TECHCREATIONUSER, TECHLASTUPDATEUSER) 
                values ($zkf, 1,'$cuser','$cuser'))");
                $sth = $dbh ->prepare($volgnr);
                $sth -> execute();
                    while(my $volg=$sth->fetchrow_array)  {
                         $volgnummer =$volg;
                         print "$volgnummer\n";
                    }
                $volgnummer = $volgnummer - $ziekenfonds_nummer*10000000000;
                $volgnummer = $volgnummer*1;
                print "$max_insert : $volgnummer\n";
                $max_insert +=1 ;
                last if ($max_insert >=10);
               }
          
          my $zetin = "INSERT INTO $settings->{'gkd_hist_fil'} values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
          $sth = $dbh ->prepare($zetin);
             #$sth->bind_param(1,999997);
             $sth->bind_param(1,$settings->{'zkfnummer'});
             $sth->bind_param(2,$volgnummer);
             $sth->bind_param(3,0);
             $sth->bind_param(4,1);
             $sth->bind_param(5,$ext_nr);
             $sth->bind_param(6,$settings->{'office'});
             $sth->bind_param(7,$settings->{'section'});
             $sth->bind_param(8,3);
             $sth->bind_param(9,$commentaar);
             $sth->bind_param(10,0);
             $sth->bind_param(11,'HOSI');
             $sth->bind_param(12,$main::tech_creation_date);
             $sth->bind_param(13,'HOSI');
             $sth->bind_param(14,$main::tech_creation_date);
             $sth->bind_param(15,'');
             $sth->bind_param(16,'');
             $sth->bind_param(17,0);
             $sth->bind_param(18,'');
          my $sthtest1 = $sth->execute();
          $sth->finish();
          connectdb->disconnect($dbh);
          return ($sthtest1);
        }
     sub lees_history_gkd {
         my ($class,$frame) = @_;
         my $ext_nr = $main::klant->{ExternNummer};
         my $zkf = $main::klant->{Ziekenfonds};
         if (!defined $ext_nr or !defined $zkf) {
               return ('kies lid');#code
            }
         #1 A.ORG                 organization                    CHARACTER         3
         #2 A.CONTACTID           contact id                       INTEGER           9        0
         #3 A.TYPE                contact type 1:phone,2:email     SMALLINT          4        0
         #4 A.TARGETTYPE          0=prospect, 1=member             SMALLINT          4        0
         #5 A.TARGETID            prospect id or member id         DECIMAL          13        0
         #6 A.OFFICE              office manager                   SMALLINT          4        0
         #7 A.SECTION                                               SMALLINT          4        0
         #8 A.ACTION              1=creation,2=update,3=single c   SMALLINT          4        0
         #9 A.COMMENT             manager comments                  VARCHAR        1024
         #10 A.TECHVERSIONNUMBER                                   INTEGER           9
         #11 A.TECHCREATIONUSER                                    VARCHAR          10
         #12 A.TECHCREATIONDATE                                     TIMESTAMP        26
         #13 A.TECHLASTUPDATEUSER                                    VARCHAR          10
         #14 A.TECHLASTUPDATEDATE                          TIMESTAMP        26
         #15 A.TECHORGANIZATION                             CHARACTER         3
         #16 A.COMPLAINTCOMMENT    complaints comments      VARCHAR        1024
         #17 A.IDMT                mut for fusion concern  SMALLINT          4
         # 1            2           3       4                   5           6       7       8           9                       10              11              12                          13                  14                          15
         # ORG       CONTACTID     TYPE  TARGETTYPE            TARGETID   OFFICE  SECTION   ACTION  COMMENT                 ECHVERSIONNUMBER  TECHCREATIONUSER  TECHCREATIONDATE            TECHLASTUPDATEUSER  TECHLASTUPDATEDATE           IDMT
         #203        739,735        7           1     810,003,677,473        0      200        3   test 21092011                          0   HC                2011-09-21-12.43.58.000000  HC                  2011-09-21-13.05.57.000000   0
         #                                                                                                                                                      2011-09-21-17.10.35.000000
         my $vandaag =$main::vandaag;
         my $checkdate = substr($main::tech_creation_date,0,10);
         my $parser = DateTime::Format::Strptime->new(pattern => '%Y-%m-%d');
         my $parser1 = DateTime::Format::Strptime->new(pattern => '%Y%m%d');
         my $gisteren =$parser1->parse_datetime($vandaag);
         $gisteren->subtract(days => 1);
         my $check_gisteren = $gisteren->strftime('%Y-%m-%d');;
         $check_gisteren =substr($check_gisteren,0,10);
         print "checkdate $checkdate :  $gisteren\n";
         my $dbh = connectdb->connect_as400 ($settings->{user_name},$settings->{password},$settings->{name_as400});
         my $sql =("SELECT COMMENT,TARGETID,TECHCREATIONDATE,TECHCREATIONUSER FROM $settings->{'gkd_hist_fil'} WHERE TARGETID= $ext_nr and TECHCREATIONUSER = 'HOSI' and
                   (substr(char(TECHCREATIONDATE),1,10) = '$checkdate' or substr(char(TECHCREATIONDATE),1,10) = '$check_gisteren') "); #and TECHCREATIONDATE='$tech_creation_date'
         my $sth = $dbh->prepare( $sql );
         $sth->execute();
         my @mijncomment =();
         foreach my $key (keys $main::gkd_commentaar) {
               $main::gkd_commentaar->{$key} = 0;
         }
         #my $test = $main::gkd_commentaar;
         while(@mijncomment =$sth->fetchrow_array)  {
             print "@mijncomment - $checkdate\n";
             $main::gkd_commentaar->{0} = 1 if ( $mijncomment[0] eq $frame->{GKD_txt_0}->GetValue() );
             $main::gkd_commentaar->{1} = 1 if ( $mijncomment[0] eq $frame->{GKD_txt_1}->GetValue());
             $main::gkd_commentaar->{2} = 1 if ( $mijncomment[0] eq $frame->{GKD_txt_2}->GetValue());
             $main::gkd_commentaar->{3} = 1 if ( $mijncomment[0] eq $frame->{GKD_txt_3}->GetValue());
             $main::gkd_commentaar->{4} = 1 if ( $mijncomment[0] eq $frame->{GKD_txt_4}->GetValue());
             $main::gkd_commentaar->{5} = 1 if ( $mijncomment[0] eq $frame->{GKD_txt_5}->GetValue());
             $main::gkd_commentaar->{6} = 1 if ( $mijncomment[0] eq  $frame->{GKD_txt_6}->GetValue());
             $main::gkd_commentaar->{7} = 1 if ( $mijncomment[0] eq $frame->{GKD_txt_7}->GetValue());
             $main::gkd_commentaar->{8} = 1 if ( $mijncomment[0] eq  $frame->{GKD_txt_8}->GetValue());
             $main::gkd_commentaar->{9} = 1 if ( $mijncomment[0] eq $frame->{GKD_txt_9}->GetValue());
             $main::gkd_commentaar->{10} = 1 if ( $mijncomment[0] eq $frame->{GKD_txt_10}->GetValue());
             $main::gkd_commentaar->{12} = 1 if ( $mijncomment[0] eq $frame->{GKD_txt_11}->GetValue());
             $main::gkd_commentaar->{11} = 1  if ( $mijncomment[0] eq $frame->{GKD_txt_12}->GetValue());
             $main::gkd_commentaar->{13} =1 if ( $mijncomment[0] eq  $frame->{GKD_txt_13}->GetValue());
             $main::gkd_commentaar->{14} = 1 if ( $mijncomment[0] eq $frame->{GKD_txt_14}->GetValue() );
             $main::gkd_commentaar->{15} = 1 if ( $mijncomment[0] eq $frame->{GKD_txt_15}->GetValue());
             $main::gkd_commentaar->{16} = 1 if ( $mijncomment[0] eq $frame->{GKD_txt_16}->GetValue());
             $main::gkd_commentaar->{17} = 1 if ( $mijncomment[0] eq $frame->{GKD_txt_17}->GetValue());
             $main::gkd_commentaar->{18} = 1 if ( $mijncomment[0] eq $frame->{GKD_txt_18}->GetValue());
             $main::gkd_commentaar->{19} = 1 if ( $mijncomment[0] eq $frame->{GKD_txt_19}->GetValue());
             $main::gkd_commentaar->{20} = 1 if ( $mijncomment[0] eq  $frame->{GKD_txt_20}->GetValue());
             $main::gkd_commentaar->{21} = 1 if ( $mijncomment[0] eq $frame->{GKD_txt_21}->GetValue());
             $main::gkd_commentaar->{22} = 1 if ( $mijncomment[0] eq  $frame->{GKD_txt_22}->GetValue());
             $main::gkd_commentaar->{23} = 1 if ( $mijncomment[0] eq $frame->{GKD_txt_23}->GetValue());
            }
            #$main::gkd_commentaar->{genderSA_ontvangen_vorige} = $main::gkd_commentaar->{genderSA_ontvangen} ;
            #$main::gkd_commentaar->{genderSA_fact_ontvangen_vorige} = $main::gkd_commentaar->{genderSA_fact_ontvangen};
            #$main::gkd_commentaar->{genderFACT_ontvangen_vorige} = $main::gkd_commentaar->{genderFACT_ontvangen};
            #$main::gkd_commentaar->{genderAMBU_ontvangen_vorige} = $main::gkd_commentaar->{genderAMBU_ontvangen} ;
            #$main::gkd_commentaar->{genderMV_ontvangen_vorige} = $main::gkd_commentaar->{genderMV_ontvangen};
            #$main::gkd_commentaar->{genderAV_ontvangen_vorige} = $main::gkd_commentaar->{genderAV_ontvangen};
            #$main::gkd_commentaar->{genderAV_MV_ontvangen_vorige} = $main::gkd_commentaar->{genderAV_MV_ontvangen} ;
            #$main::gkd_commentaar->{gender_MV_ontvangen_vorige} = $main::gkd_commentaar->{gender_MV_ontvangen};
            #$main::gkd_commentaar->{genderMI_ontvangen_vorige} = $main::gkd_commentaar->{genderMI_ontvangen} ;
            #$main::gkd_commentaar->{gendershade_diverse_ontvangen_vorige} = $main::gkd_commentaar->{gendershade_diverse_ontvangen};
            #$main::gkd_commentaar->{genderaansluiting_diverse_ontvangen_vorige} = $main::gkd_commentaar->{genderaansluiting_diverse_ontvangen};
            #$main::gkd_commentaar->{genderaansluiting_stopzetting_ontvangen_vorige} = $main::gkd_commentaar->{genderaansluiting_stopzetting_ontvangen};
            #$main::gkd_commentaar->{genderaansluiting_omschakeling_ontvangen_vorige} = $main::gkd_commentaar->{genderaansluiting_omschakeling_ontvangen};
            #$main::gkd_commentaar->{genderaansluiting_voetverzorging_ontvangen_vorige} = $main::gkd_commentaar->{genderaansluiting_voetverzorging_ontvangen};
           connectdb->disconnect($dbh);;

            return ('ok');
        }
     sub lees_history_gkd_agresso_order {
         my ($class,$text) = @_;
         my $ext_nr = $main::klant->{ExternNummer};
         my $zkf = $main::klant->{Ziekenfonds};
         if (!defined $ext_nr or !defined $zkf) {
               return ('kies lid');#code
         }
         #1 A.ORG                 organization                    CHARACTER         3
         #2 A.CONTACTID           contact id                       INTEGER           9        0
         #3 A.TYPE                contact type 1:phone,2:email     SMALLINT          4        0
         #4 A.TARGETTYPE          0=prospect, 1=member             SMALLINT          4        0
         #5 A.TARGETID            prospect id or member id         DECIMAL          13        0
         #6 A.OFFICE              office manager                   SMALLINT          4        0
         #7 A.SECTION                                               SMALLINT          4        0
         #8 A.ACTION              1=creation,2=update,3=single c   SMALLINT          4        0
         #9 A.COMMENT             manager comments                  VARCHAR        1024
         #10 A.TECHVERSIONNUMBER                                   INTEGER           9
         #11 A.TECHCREATIONUSER                                    VARCHAR          10
         #12 A.TECHCREATIONDATE                                     TIMESTAMP        26
         #13 A.TECHLASTUPDATEUSER                                    VARCHAR          10
         #14 A.TECHLASTUPDATEDATE                          TIMESTAMP        26
         #15 A.TECHORGANIZATION                             CHARACTER         3
         #16 A.COMPLAINTCOMMENT    complaints comments      VARCHAR        1024
         #17 A.IDMT                mut for fusion concern  SMALLINT          4
         # 1            2           3       4                   5           6       7       8           9                       10              11              12                          13                  14                          15
         # ORG       CONTACTID     TYPE  TARGETTYPE            TARGETID   OFFICE  SECTION   ACTION  COMMENT                 ECHVERSIONNUMBER  TECHCREATIONUSER  TECHCREATIONDATE            TECHLASTUPDATEUSER  TECHLASTUPDATEDATE           IDMT
         #203        739,735        7           1     810,003,677,473        0      200        3   test 21092011                          0   HC                2011-09-21-12.43.58.000000  HC                  2011-09-21-13.05.57.000000   0
         #                                                                                                                                                      2011-09-21-17.10.35.000000
         my $vandaag =$main::vandaag;
         my $checkdate = substr($main::tech_creation_date,0,10);
         my $parser = DateTime::Format::Strptime->new(pattern => '%Y-%m-%d');
         my $parser1 = DateTime::Format::Strptime->new(pattern => '%Y%m%d');
         my $gisteren =$parser1->parse_datetime($vandaag);
         $gisteren->subtract(days => 1);
         my $check_gisteren = $gisteren->strftime('%Y-%m-%d');;
         $check_gisteren =substr($check_gisteren,0,10);
         print "checkdate $checkdate :  $gisteren\n";
         my $dbh = connectdb->connect_as400 ($settings->{user_name},$settings->{password},$settings->{name_as400});
         my $sql =("SELECT COMMENT,TARGETID,TECHCREATIONDATE,TECHCREATIONUSER FROM $settings->{'gkd_hist_fil'} WHERE TARGETID= $ext_nr and TECHCREATIONUSER = 'HOSI' and
                   (substr(char(TECHCREATIONDATE),1,10) = '$checkdate' or substr(char(TECHCREATIONDATE),1,10) = '$check_gisteren') "); #and TECHCREATIONDATE='$tech_creation_date'
         my $sth = $dbh->prepare( $sql );
         $sth->execute();
         my $staat_er_al_in = 'nee';
         #my $test = $main::gkd_commentaar;
         while(my @mijncomment =$sth->fetchrow_array)  {
             $staat_er_al_in = 'ja' if ( $mijncomment[0] eq $text); ;
            }
         connectdb->disconnect($dbh);;
         return ($staat_er_al_in);
        }
     sub aansluit_datum_zkf {
          my $zkf = 203;
          my ($class,$rijksregnr) =  @_;
          &settings ($zkf);
          my $dbh = connectdb->connect_as400 ($settings->{user_name},$settings->{password},$settings->{name_as400});
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
          #openen van PFYSL8
          # EXIDL8 = extern nummer
          # KNRNL8 = nationaalt register nummer
          # NAMBL8 = naam van de gerechtigde
          # PRNBL8 = voornaam van de gerechtigde
          # SEXEL8 = code van het geslacht
          # NAIYL8 = geboortejaat
          # NAIML8 = geboortemaand
          # NAIJL8 = geboortedag
          my $sql = ("SELECT a.KNRNL8,b.ABADKK FROM $settings->{'pers_fil'} a JOIN $settings->{'phoekk_fil'} b ON a.EXIDL8 = b.EXIDKK
                     WHERE a.KNRNL8=$rijksregnr and b.ABTVKK = 11 and b.ABOCKK =''");
          my $sth = $dbh->prepare( $sql );
          $sth->execute();
          my @aodatums =();
          my $datem;
          while(@aodatums = $sth->fetchrow_array)  {
               print "$zkf @aodatums\n";
               $datem = $aodatums[1];
              }

          if (defined $datem ) {
               return ($datem);
              }else {
               $zkf =235;
               &settings ($zkf);
               my $dbh = connectdb->connect_as400 ($settings->{user_name},$settings->{password},$settings->{name_as400});
               my $sql = ("SELECT a.KNRNL8,b.ABADKK FROM $settings->{'pers_fil'} a JOIN $settings->{'phoekk_fil'} b ON a.EXIDL8 = b.EXIDKK
                     WHERE a.KNRNL8=$rijksregnr and b.ABTVKK = 11 and b.ABOCKK =''");
               my $sth = $dbh->prepare( $sql );
               $sth->execute();
               my @aodatums =();
               while(@aodatums = $sth->fetchrow_array)  {
                    print "$zkf @aodatums\n";
                    $datem = $aodatums[1];
                   }
               return ($datem);
            }


        }
     sub natreg_to_extern_zonder_einddatum {
         my ($self,$dbh,$natnummer,$settings,$datum) = @_;
         #openen van PFYSL8
         # EXIDL8 = extern nummer
         # KNRNL8 = nationaalt register nummer
         # NAMBL8 = naam van de gerechtigde
         # PRNBL8 = voornaam van de gerechtigde
         # SEXEL8 = code van het geslacht
         # NAIYL8 = geboortejaat
         # NAIML8 = geboortemaand
         # NAIJL8 = geboortedag
          #90   A    A.KVPBL8              ASSUR. AO : DATE DEBUT  /VP-VE
          #100   A    A.KVPEL8              ASSUR. AO : DATE FIN    /VP-VE

         my ($ex,$KVPBL8,$KVPEL8) = $dbh->selectrow_array("SELECT EXIDL8,KVPBL8,KVPEL8  FROM $settings->{'pers_fil'} WHERE KNRNL8=$natnummer");#and KVPEL8 >= $datum
         return ($ex,$KVPEL8);
        }
     sub natreg_to_extern {
         my ($self,$dbh,$natnummer,$settings,$datum) = @_;
         #openen van PFYSL8
         # EXIDL8 = extern nummer
         # KNRNL8 = nationaalt register nummer
         # NAMBL8 = naam van de gerechtigde
         # PRNBL8 = voornaam van de gerechtigde
         # SEXEL8 = code van het geslacht
         # NAIYL8 = geboortejaat
         # NAIML8 = geboortemaand
         # NAIJL8 = geboortedag
          #90   A    A.KVPBL8              ASSUR. AO : DATE DEBUT  /VP-VE
          #100   A    A.KVPEL8              ASSUR. AO : DATE FIN    /VP-VE

         my ($ex,$KVPBL8,$KVPEL8) = $dbh->selectrow_array("SELECT EXIDL8,KVPBL8,KVPEL8  FROM $settings->{'pers_fil'} WHERE KNRNL8=$natnummer and KVPEL8 >= $datum");#and KVPEL8 >= $datum
         return ($ex,$KVPEL8);
        }
     sub check_zkf_extern {
             my ($self,$dbh,$exnr,$settings) = @_;
            #openen van PFYSL8
            # EXIDL8 = extern nummer
            # KNRNL8 = nationaalt register nummer
            # NAMBL8 = naam van de gerechtigde
            # PRNBL8 = voornaam van de gerechtigde
            # SEXEL8 = code van het geslacht
            # NAIYL8 = geboortejaat
            # NAIML8 = geboortemaand
            # NAIJL8 = geboortedag
            #90   A    A.KVPBL8              ASSUR. AO : DATE DEBUT  /VP-VE
            #100   A    A.KVPEL8              ASSUR. AO : DATE FIN    /VP-VE
            my $ex = $dbh->selectrow_array("SELECT EXIDL8 FROM $settings->{'pers_fil'} WHERE EXIDL8 =$exnr and KVPEL8 > 0");
            return ($ex);
          }


     sub zoek_bijdrage {
            my $class = shift @_;
            my $nr_zkf = shift @_ ;
            my $type_verz= shift @_;
            my $externnummer = shift @_;
            my $betaling_fil = shift @_;
            my $dbh = shift @_;
            my $bijdragejaar = substr ($main::vandaag,0,4) ;
            my $bijdrage_premie =0;
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
            if ($type_verz != '') {
                my $sqlbetaling =("SELECT IDFDKQ,EXIDKQ,ABTVKQ,ABVYKQ,ABVMKQ,ABCNKQ,ABCOKQ,AT79KQ FROM $betaling_fil WHERE IDFDKQ = $nr_zkf and EXIDKQ  = $externnummer and ABTVKQ  = $type_verz and ABVYKQ = $bijdragejaar");
                my $sthbetaling = $dbh->prepare( $sqlbetaling );
                $sthbetaling ->execute();
                my @betalingen = () ;

                while(@betalingen =$sthbetaling ->fetchrow_array)  {
                     $bijdrage_premie += $betalingen[5];
                    }
            }
            return ($bijdrage_premie);
        }
      sub zoekdossier {
               my ($class,$dbh,$extern_tit) = @_;
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
               @dossier = $dbh->selectrow_array("SELECT ABNOKJ,ABXSKJ,ABEDKJ,ABTVKJ,ABADKJ,ABEDKJ  FROM $settings->{'pdoskj_fil'} WHERE ABXSKJ = $extern_tit and ABEDKJ  =  99999999 and ABTVKJ = 1");
               #print "dossier @dossier\n";
               return ($dossier[0]);
          }
package convert_date ;
     sub new {
             my ($self,$check_datum) = @_;
             my @splt_dat = ();
             my $laatste ='';
             my $middelste = '';
             my $eerste ='';
             my $eerste4 ='';
             my $laatste4 ='';
             my $dd='';
             my $mm = '';
             my $yyyy = '';
             my $foute_datum =0;
             my $geen_tekst = 0;
             my $nr_datum =0;
             if ($check_datum =~ m%/%) {
                @splt_dat = split (/\//,$check_datum);
                $laatste = pop  @splt_dat;
                $middelste = pop  @splt_dat;
                $eerste = pop @splt_dat;
                if ($laatste > 1300 ) { #formaat dd/mm/yyyy
                     $yyyy = $laatste;
                     $mm = $middelste;
                     $dd = $eerste;
                    }elsif ($eerste > 1300 and $eerste < 2099) {
                     $yyyy = $eerste;
                     $mm = $middelste;
                     $dd = $laatste;
                    }else {
                     $foute_datum =1;
                    }
               }elsif ($check_datum =~ m%-%) {
                      @splt_dat = split (/-/,$check_datum);
                      $laatste = pop  @splt_dat;
                      $middelste = pop  @splt_dat;
                      $eerste = pop @splt_dat;
                      if ($laatste > 1300 ) { #formaat dd/mm/yyyy
                          $yyyy = $laatste;
                          $mm = $middelste;
                          $dd = $eerste;
                         }elsif ($eerste > 1300 and $eerste < 2099) {
                          $yyyy = $eerste;
                          $mm = $middelste;
                          $dd = $laatste;
                         }else {
                          $foute_datum =1;
                         }
               }elsif ($check_datum =~ m%\d{8}%) {
                $eerste4 = substr ($check_datum,0,4);
                $laatste4 = substr ($check_datum,4,4);
                if ($laatste4 > 1300 ) { # formaat is ddmmyyyy
                     $dd = substr($check_datum,0,2);
                     $mm = substr($check_datum,2,2);
                     $yyyy = substr($check_datum,4,4);
                    }elsif ($eerste4 < 2099 and $eerste4 > 1300 ) { #formaat is yyyymmdd
                     $dd = substr($check_datum,6,2);
                     $mm = substr($check_datum,4,2);
                     $yyyy = substr($check_datum,0,4);
                    }else {
                     $foute_datum =1;
                    }
               }else {
                $foute_datum =1;
               }
             $dd = sprintf("%02d", $dd);
             $mm = sprintf("%02d", $mm);
             $yyyy = sprintf("%04d", $yyyy);
             my $testdd  =$dd;
             $testdd =~ s/^0//;
             my $testmm =$mm;
             $testmm =~ s/^0//;
             if ($testdd > 31 or $testmm >12 or $yyyy > 2099 or $yyyy < 1300) {
                 $foute_datum =1;
               }else {
                #2008-10-31T15:07:38
                $check_datum = "$dd/$mm/$yyyy";
                $nr_datum = $yyyy*10000+$mm*100+$dd;
               }
           return ($foute_datum,$check_datum,$nr_datum)
          }

package openofficemacro;
      sub maak_pdf_conversion {
               my($self,$macro_pdf_openoffice) = @_;
               #my $macro_pdf_openoffice =  "$ENV{APPDATA}\\OpenOffice.org\\3\\user\\basic\\ConversionLibrary\\PDFConversion.xba";
               open(my $fh, '>', $macro_pdf_openoffice) or die "Could not open file '$macro_pdf_openoffice' $!";
               print $fh "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
               print $fh "<!DOCTYPE script:module PUBLIC \"-//OpenOffice.org//DTD OfficeDocument 1.0//EN\" \"module.dtd\">\n";
               print $fh "<script:module xmlns:script=\"http://openoffice.org/2000/script\" script:name=\"PDFConversion\" script:language=\"StarBasic\">REM  *****  BASIC  *****\n";
               print $fh "\n";
               print $fh "Sub Main\n";
               print $fh "\n";
               print $fh "End Sub\n";
               print $fh "\n";
               print $fh "Sub ConvertWordToPDF( cSourceFile , cDestinationFile)\n";
               print $fh "   cURL = ConvertToURL( cSourceFile )\n";
               print $fh "   &apos; Open the document.\n";
               print $fh "   &apos; Just blindly assume that the document\n";
               print $fh "   &apos; is of a type that OOo will\n";
               print $fh "   &apos;  correctly recognize and open -- \n";
               print $fh "   &apos;   without specifying an import filter.\n";
               print $fh "\n";
               print $fh "   oDoc = StarDesktop.loadComponentFromURL( cURL, &quot;_blank&quot;, 0, _\n";
               print $fh "          Array(MakePropertyValue( &quot;Hidden&quot;, True ),) )\n";
               print $fh "\n";
               print $fh "   cURL = ConvertToURL( cDestinationFile )\n";
               print $fh "\n";
               print $fh "   &apos; Save the document using a filter.\n";
               print $fh "   oDoc.storeToURL( cURL, _\n";
               print $fh "   Array(MakePropertyValue( &quot;FilterName&quot;, &quot;writer_pdf_Export&quot; ),)\n";
               print $fh "\n";
               print $fh "   oDoc.close( True )\n";
               print $fh "End Sub\n";
               print $fh "\n";
               print $fh "Function MakePropertyValue( Optional cName As String, _\n";
               print $fh "   Optional uValue ) As com.sun.star.beans.PropertyValue\n";
               print $fh "   Dim oPropertyValue As New com.sun.star.beans.PropertyValue\n";
               print $fh "   If Not IsMissing( cName ) Then\n";
               print $fh "	oPropertyValue.Name = cName\n";
               print $fh "   EndIf\n";
               print $fh "   If Not IsMissing( uValue ) Then\n";
               print $fh "     oPropertyValue.Value = uValue\n";
               print $fh "   EndIf\n";
               print $fh "   MakePropertyValue() = oPropertyValue\n";
               print $fh "End Function\n";
               print $fh "\n";
               print $fh "</script:module>\n";
               close $fh;
               $main::pdfconversiemacro_bestaat =1;
          }

1;