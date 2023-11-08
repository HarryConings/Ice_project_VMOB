#!/usr/bin/perl -w
#OPGELET!!!!!!
#Dit programma is auteursrechtelijk beschermd.
#Deze code is volledig eigendom van de Firma  I.C.E. (liebroekstraat 43 3545 Halen BE0446888007) .
#Deze code mag enkel gebruikt worden met jaarlijkse toestemming van Harry Conings 0475464286 harry@ice.be harry@icebutler.com
#Indien dit toch gebeurt is er een boete verschuldigd van 250.000 EUR exclusief btw aan de Firma  I.C.E.
#Deze code mag niet aan derden (ook niet VNZ en NZVL) getoond worden tenzij met uitdrukkelijke en schriftelijke toestemming van I.C.E. bvba .
#Indien dit toch gebeurt is er een boete verschuldigd van 250.000 EUR exclusief btw aan de Firma  I.C.E.
#Dit geldt ook voor het kopieren van een stuk code of het repliceren van technieken gehanteerd in dit programma
#I.C.E. beheert de broncode je mag  veranderingen aanbrengen aan het programma . Deze worden samen met de documentatie overgedragen aan I.C.E. .
#I.C.E. beslist dan op deze veranderingen worden doorgevoerd.
use strict;
use strict;
use XML::LibXML::Reader;     
use XML::Simple;
use Date::Manip::DM5 ;
use Time::Piece ();
use Time::Seconds;
use DateTime;
use DateTime::Format::Strptime;
use Net::SMTP;
use Date::Calc qw(:all);
require 'Decryp_Encrypt.pl';
require "cnnectdb_prod.pl";
use List::Util qw(first);
our $total_ok =0;
our $total_nok=0;
our $vandaag = ParseDate("today");
our $start_programma = localtime; # time piece
my $vandaag_tijd = $vandaag;
my $start_tijd = substr ($vandaag,8,8);
$vandaag_tijd =~ s/://g;
$vandaag_tijd =~ s/\s//g;
our $tijd = substr ($vandaag_tijd,8,6);
$vandaag = substr ($vandaag,0,8);
our $mail_contracten ='';
#our ($last_zkf,$last_agr_nr) = &read_stop_file;
our $last_agr_nr=0;
our $last_zkf = 'ZKF203';
package main;
      #bepalen TEST PROD
      our $version = 'v202105'; # EXTRA VELDEN
      our $mode = 'PROG'; #TEST voor test   PROG voor productie
      our $volledig = 'FULL'; #alle contracten worden verwijderd en opnieuw ingezet
      our $enkel_jo = 'JA' ; #NEE is ook SQL
      $mode = $ARGV[0] if (defined $ARGV[0]);
      $volledig ='UPDATE' if ($ARGV[0] eq 'UPDATE');
      if ( $mode eq 'TEST' or $mode eq 'PROG'){}else{die}
      BEGIN { $ENV{HARNESS_ACTIVE} = 1 }
      our $agresso_instellingen = XMLin("P:\\OGV\\ASSURCARD_$mode\\assurcard_settings_xml\\insert_contracten_settings.xml");
      our $file_voor_jo = "P:\\OGV\\ASSURCARD_$mode\\CONTRACTEN\\contracten_$vandaag.csv";
      our $file_agresso = '';
      $file_agresso = "\\\\S200WP1XXL01.mutworld.be\\AgressoFiles235\\VMOB\\Data Import\\Contracten" if  ($mode eq 'PROG');
      $file_agresso = "\\\\S200WR2XXL01.mutworld.be\\AgressoFiles235\\VMOB\\Data Import\\contracten" if  ($mode eq 'TEST');
      unlink $file_voor_jo;                 
      $mail_contracten  = $mail_contracten."Programma contracten naar $mode versie $version\n\n";
      $mail_contracten  = $mail_contracten."WE GAAN CONTRACTEN IN AGRESSO INZETTEN\n";
      $mail_contracten  = $mail_contracten."------------------------------------------------------------------------\n";
      $mail_contracten  = $mail_contracten."\nstartijd : $start_tijd\n";
      print "Programma contracten naar $mode versie $version\n\n";
      print "WE GAAN CONTRACTEN IN AGRESSO INZETTEN\n";
      print "------------------------------------------------------------------------\n";
      print "\nstartijd : $start_tijd\n";
      my $end_time = $main::agresso_instellingen->{stop_tijd_contracten};
      my $numdays = 1; #  dag bijtellen
      my $dt = Time::Piece->strptime( $vandaag , '%Y%m%d');
      $dt += ONE_DAY * $numdays;
      my $end_prog = $dt->strftime('%Y%m%d');
      $end_prog = "$end_prog $end_time";
      our $stoptijd_programma = Time::Piece->strptime( $end_prog , '%Y%m%d %H:%M:%S');
      print $stoptijd_programma->strftime('%Y%m%d %H:%M:%S');
      print "\n";
      ($last_zkf,$last_agr_nr) = control->read_stop_file;
      my $dbh_agresso = agresso->setup_mssql_connectie($mode);
      our (@agressonrs_slechte_betalers_ubw) = agresso->open_factuur($dbh_agresso);
      my $backup_gedaan = "Uitgeschakeld import via Jo\n";#agresso->backup_contract($dbh_agresso);
      $mail_contracten  = $mail_contracten."$backup_gedaan\n\n";
      print "$backup_gedaan\n\n";
      my @ziekenfondsen = main->zoek_ziekenfondsen;
      my $verzekeringen = main->zoek_verzekeringen($agresso_instellingen);
      AS400->zoek_verzekerden($dbh_agresso,$agresso_instellingen,$verzekeringen,$vandaag);
      sub zoek_ziekenfondsen {
         my @ziekenfondsen;
         foreach my $zkf (sort keys $agresso_instellingen->{verzekeringen}){
             my $ziekenfondsnr = $& if ($zkf =~ m/\d{3}/);
             push(@ziekenfondsen,$ziekenfondsnr);
            }
         return(@ziekenfondsen);
         }
      sub zoek_verzekeringen {
         my ($self,$agresso_instellingen)= @_;
         my $verzekeringen;
          foreach my $zkf (keys $agresso_instellingen->{verzekeringen}){
             
              @{$verzekeringen->{$zkf}}=();
              my $ziekenfondsnr = $& if ($zkf =~ m/\d{3}/);
              $mail_contracten = $mail_contracten."$zkf -> volgende verzekeringen:\n";
              $mail_contracten=$mail_contracten."--------------------------------\n";
              foreach my $verzekerings_naam (keys $agresso_instellingen->{verzekeringen}->{$zkf}){
                  my $verzekerings_nummer = $agresso_instellingen->{verzekeringen}->{$zkf}->{$verzekerings_naam};
                  eval {$verzekerings_nummer = $agresso_instellingen->{verzekeringen}->{$zkf}->{$verzekerings_naam}->{$verzekerings_naam}};
             
                  push (@{$verzekeringen->{$zkf}},$verzekerings_nummer);
                  $mail_contracten = $mail_contracten."$verzekerings_naam ->$verzekerings_nummer \n";
                 }
              #print "";
              $mail_contracten = $mail_contracten."\n";
              #zoek de mensen met deze verzekering
             
             }
          return ($verzekeringen);
        }
      sub zoek_naam_verzekering {
               my ($self,$verz_nr,$produktnummer,$ziekenfonds) = @_;
               if ($produktnummer == 1) {
                   foreach my $naam_verzekering (keys $agresso_instellingen->{verzekeringen}->{$ziekenfonds}) {
                       if ($agresso_instellingen->{verzekeringen}->{$ziekenfonds}->{$naam_verzekering} == $verz_nr) {
                           my $voorlopige_naam = uc $naam_verzekering;
                           #print "naam verz $voorlopige_naam -> input $verz_nr,$produktnummer,$ziekenfonds\n";
                           return ($voorlopige_naam);
                          }
                      }
                  }else {
                   foreach my $naam_verzekering (keys $agresso_instellingen->{verzekeringen}->{$ziekenfonds}) {                     
                       if (eval {$agresso_instellingen->{verzekeringen}->{$ziekenfonds}->{$naam_verzekering}->{$naam_verzekering} == $verz_nr}) {
                            foreach my $naam_product (keys $agresso_instellingen->{verzekeringen}->{$ziekenfonds}->{$naam_verzekering}) {
                               if ($agresso_instellingen->{verzekeringen}->{$ziekenfonds}->{$naam_verzekering}->{$naam_product} == $produktnummer) {
                                   my $voorlopige_naam = uc $naam_product;
                                   #print "naam verz $voorlopige_naam -> input $verz_nr,$produktnummer,$ziekenfonds\n";
                                   return ($voorlopige_naam);
                                  }
                              }
                          }
                      }
                  }
               
            }    
package control;
    sub read_stop_file {        
       my $stopfile =$main::agresso_instellingen->{plaats_teller_insert_contracten};
       $stopfile ="$stopfile\\last_contract_inserted.txt";
       my $agr_nr=0;
       my $zkf_nr=0;
       open (my $fh, '<:encoding(UTF-8)', $stopfile) or return(0,0);
       while (my $row = <$fh>) {
           chomp $row;           
           ($zkf_nr,$agr_nr)=split /,/,$row;
          }
       return ($zkf_nr,$agr_nr);  
     }
package agresso;
   sub setup_mssql_connectie {
        my ($self,$mode_con) = @_;
        my $dbh_mssql;
        my $dsn_mssql;
        my $user = 'HOSPIPLUS';
        my $passwd = 'ihuho4sdxn';
        if ($mode_con eq 'PROG') {
           $dsn_mssql = join "", (
            "dbi:ODBC:",
            "Driver={SQL Server};",
            "Server=S000WP1XXLSQL01.mutworld.be\\i200;", # nieuwe database server 2016 05
            #"Server=S998XXLSQL01.CPC998.BE\\i200;",
            "UID=HOSPIPLUS;",
            "PWD=ihuho4sdxn;",
             "Database=agrprod",            
           );
           #print '';
        }else {
            $dsn_mssql = join "", (
            "dbi:ODBC:",
            "Driver={SQL Server};",
            "Server=S000WP1XXLSQL01.mutworld.be\\i200;", # nieuwe database server 2016 05
            #"Server=S998XXLSQL01.CPC998.BE\\i200;",
            "UID=HOSPIPLUS;",
            "PWD=ihuho4sdxn;",
            "Database=agraccept",
           );
        }
         my $db_options = {
            PrintError => 1,
            RaiseError => 1,
            AutoCommit => 1, #0 werkt niet in
            LongReadLen =>2000
           };
        #
        # connect to database
        #
        $dbh_mssql = DBI->connect($dsn_mssql, $user, $passwd, $db_options) or exit_msg("Can't connect: $DBI::errstr");
        return ($dbh_mssql)
      }
   sub backup_contract {
      my ($self,$dbh) = @_;
      my $client = 'VMOB';
      $dbh->do("DELETE FROM afxvmobcontrbu WHERE client = '$client' ");
      #exec sp_columns afxvmobcontrbu
      #attribute_id dim_value line_no client date_from date_to product startdatum wachtdatum einddatum contract_nr zkf_nr zkf_nr_datum_van zkf_nr_datum_tot info last_update user_id agrtid ontslagcode_fx
      #aansluitingscode_fx  hoedanigheid_fx bestaalstatus_fx laatste_betaaldatum_fx openstaande_premie_fx betaalwijze_fx periode_premie_fx barema_fx betaler_naam_fx betaler_rrn_fx
      $dbh->do("INSERT INTO afxvmobcontrbu (attribute_id,dim_value,line_no,client,date_from,date_to,product,startdatum,wachtdatum,einddatum,contract_nr,zkf_nr,zkf_nr_datum_van,
               zkf_nr_datum_tot,info,last_update,user_id,ontslagcode_fx,aansluitingscode_fx,hoedanigheid_fx,bestaalstatus_fx,laatste_betaaldatum_fx,openstaande_premie_fx,
               betaalwijze_fx,periode_premie_fx,barema_fx,betaler_naam_fx,betaler_rrn_fx) 
      Select attribute_id,dim_value,line_no,client,date_from,date_to,product,startdatum,wachtdatum,einddatum,contract_nr,zkf_nr,zkf_nr_datum_van,
      zkf_nr_datum_tot,info,last_update,user_id,ontslagcode_fx,aansluitingscode_fx,hoedanigheid_fx,bestaalstatus_fx,laatste_betaaldatum_fx,openstaande_premie_fx,
      betaalwijze_fx,periode_premie_fx,barema_fx,betaler_naam_fx,betaler_rrn_fx from afxvmobcontract");
      return ('Backup contracten naar afxvmobcontrbu gedaan');
   }
   sub delete_contract {
      my ($self,$agresso_nr,$zkf_nr,$dossier,$startdatum,$einddatum) =  @_;     
      my $client = 'VMOB';
      #print "SELECT COUNT(*) from afxvmobcontract where  client = $client and dim_value = $agresso_nr and zkf_nr = $zkf_nr";
      my $line_count = $dbh_agresso->selectrow_array("SELECT COUNT(*) from afxvmobcontract where  client = '$client' and dim_value = $agresso_nr and zkf_nr = '$zkf_nr'
                                                   and contract_nr = '$dossier' and startdatum = '$startdatum' and einddatum= '$einddatum'");
      if ($line_count > 0){         
         $dbh_agresso->do("DELETE FROM afxvmobcontract WHERE client = '$client' and dim_value = $agresso_nr and zkf_nr = '$zkf_nr'
                           and contract_nr = '$dossier' and startdatum = '$startdatum' and einddatum= '$einddatum'") ;
      }
       my $sql = ("SELECT line_no from afxvmobcontract where  client = '$client' and dim_value = $agresso_nr and zkf_nr = '$zkf_nr'");
       my @bezette_line_no = ();
       my $sth = $dbh_agresso->prepare( $sql );
       $sth ->execute();
       while (my @line =$sth->fetchrow_array)  {
         push (@bezette_line_no,$line[0]);
       }
       return (@bezette_line_no);
     }
   sub delete_contracten_all {
      my ($self,$dbh,$agresso_nr,$zkf_nr) =  @_;     
      my $client = 'VMOB';           
      $dbh->do("DELETE FROM afxvmobcontract WHERE client = '$client' and dim_value = $agresso_nr and zkf_nr = $zkf_nr");
      #print '';
     }
   sub open_factuur {
      my ($self,$dbh_agresso) = @_;
      my $openstaand_ubw = ("select distinct client, apar_id from acutrans where client = 'VMOB' and datediff(day, due_date, getdate()) > '45'");
      my $sthopenstaand_ubw = $dbh_agresso->prepare( $openstaand_ubw );
      $sthopenstaand_ubw ->execute();
      my @openstaand;
      my @slechte_betalers_ubw;
      while(@openstaand = $sthopenstaand_ubw ->fetchrow_array)  {
            push (@slechte_betalers_ubw,$openstaand[1]);
      }
      return (@slechte_betalers_ubw);
   }
package AS400;
    use Unicode::String qw(utf8 latin1 utf16le);
    use File::Copy;
    sub zoek_verzekerden {
      my ($self,$dbh_agresso,$instellingen,$verzekeringen,$vandaag) = @_;
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
      my $totaal_aantal_lijnen=0;
      my $link_info = $instellingen->{ziekenfondsen}->{'ZKF203'}->{as400};
      $link_info->{password} = decrypt->new($link_info->{password});
      my $dbhInfo = AS400->cnnectdb($link_info->{username},$link_info->{password},$link_info->{as400_name});
      open (JOFILE,'>>',$file_voor_jo);
      my $text= "attribute_id;dim_value;line_no;client;product;startdatum;wachtdatum;einddatum;contract_nr;zkf_nr;info;last_update;";
      $text = "$text"."user_id;aansluitingscode_fx;ontslagcode_fx;laatste_betaaldatum_fx;openstaande_premie_fx;betaalwijze_fx;barema_fx;";
      $text = "$text"."betaler_naam_fx;betaler_rrn_fx;periode_premie_fx;hoedanigheid_fx;bestaalstatus_fx";
      #print JOFILE "$text\n";
      foreach my $zkf (keys $instellingen->{ziekenfondsen}) {
                         my $zkf_nr  = substr ($zkf,3,3);
                         my $zkf_naam ="$zkf";
                         my $link = $instellingen->{ziekenfondsen}->{$zkf}->{as400};
                         my $size = length $link->{password};
                         $link->{password} = decrypt->new($link->{password}) if ($size >10);
                         my $dbh = AS400->cnnectdb($link->{username},$link->{password},$link->{as400_name});
                         my $placeholders = join ",", (@{$verzekeringen->{$zkf}});
                         my $ASCARD="$link->{libcxcom}\.ASCARD";
                         my $PFYSL8= "$link->{libcxfil}\.PFYSL8";
                         my $PHOEKK= "$link->{libcxfil}\.PHOEKK";
                         my $PADRJR = "$link->{libcxfil}\.PADRJR";
                         my $PTAXKQ = "$link->{libcxfil}\.PTAXKQ";
                         my $PPADKO =  "$link->{libcxfil}\.PPADKO";
                         #my $sql =("SELECT c.KNRNL8,c.EXIDL8,
                         #               b.ABTVKK,b.ABPRKK,b.ABADKK,b.ABPEKK,b.ABEDKK,b.ABNOKK,b.ABACKK,b.AB2AKK,b.ABOCKK,b.AB2OKK,
                         #               c.NAMBL8,c.PRNBL8,c.NAIYL8,NAIML8,NAIJL8,SEXEL8 
                         #               FROM $PFYSL8 c                                      
                         #               JOIN $PHOEKK  b ON c.EXIDL8=b.EXIDKK
                         #               WHERE c.KNRNL8 != 0 and b.ABTVKK IN ($placeholders)
                         #               and b.ABEDKK > $eind_datum and  b.ABADKK <= $zes_maanden_geleden
                         #               ORDER BY  b.ABNOKK DESC" );#fetch first 10 rows only c.KNRNL8 != 0
                         my $sql =("SELECT a.AGRESONR,a.KNRN52,a.ZKF,c.EXIDL8,
                                        b.ABTVKK,b.ABPRKK,b.ABADKK,b.ABPEKK,b.ABEDKK,b.ABNOKK,a.ZKF,b.ABACKK,b.AB2AKK,b.ABOCKK,b.AB2OKK,
                                        c.NAMBL8,c.PRNBL8,b.ABCTKK
                                        FROM $ASCARD a
                                        JOIN $PFYSL8 c ON a.KNRN52 = c.KNRNL8 
                                        JOIN $PHOEKK  b ON c.EXIDL8=b.EXIDKK
                                        WHERE a.KNRN52 != 0 and AGRESONR != 0 and b.ABTVKK IN ($placeholders)                         
                                        ORDER BY a.AGRESONR,b.ABTVKK ASC" );#fetch first 10 rows only a.KNRN52 != 0 AGRESONR != 0
                         my $sth = $dbh->prepare( $sql );
                         $sth ->execute();
                         my  $record_teller =0;                        
                         my @agresso_klant =();
                         my $line_no = 0;
                         my $last_agr_nr=0;
                         my $oud_agresso_nr =0;
                         $dbh_agresso->{RaiseError} = 1;
                         $dbh_agresso->{odbc_err_handler} = \&err_handler;
                         while(@agresso_klant =$sth->fetchrow_array)  {
                                for (my $i=0; $i <= 15; $i++) {
                                    my $item = utf8($agresso_klant[$i]);
                                    $agresso_klant[$i] = $item->latin1;
                                    #print "$i ,";
                                }
                                #print "\n______\n$line_no agressoklant @agresso_klant\n---------\n";
                                #print "\n";
                                if ($agresso_klant[0] > $last_agr_nr) {
                                       undef $klant;
                                       my $naam= main->zoek_naam_verzekering($agresso_klant[4],$agresso_klant[5],$zkf_naam);
                                       my $ext_nr = $agresso_klant[3];
                                       my $verz_nr =  $agresso_klant[4];
                                       my $prod_nr =  $agresso_klant[5];
                                       my $start_jaar= substr($agresso_klant[6],0,4);
                                       my $start_maand= substr($agresso_klant[6],4,2);
                                       my $start_dag= substr($agresso_klant[6],6,2);
                                       my $agresso_start_datum = "$start_dag-$start_maand-$start_jaar";
                                       my $wacht_jaar= substr($agresso_klant[7],0,4);
                                       my $wacht_maand= substr($agresso_klant[7],4,2);
                                       my $wacht_dag= substr($agresso_klant[7],6,2);
                                       my $agresso_wacht_datum = "$wacht_dag-$wacht_maand-$wacht_jaar";
                                       $agresso_klant[8] = 20991231 if ($agresso_klant[8] > 50000000);
                                       my $eind_jaar= substr($agresso_klant[8],0,4);
                                       my $eind_maand= substr($agresso_klant[8],4,2);
                                       my $eind_dag= substr($agresso_klant[8],6,2);
                                       my $agresso_eind_datum = "$eind_dag-$eind_maand-$eind_jaar";
                                       my $info = AS400->zoek_info($dbhInfo,$agresso_klant[1],$agresso_klant[4]);
                                       my $aansluitingscode= "$agresso_klant[11]$agresso_klant[12]";
                                       my $ontslagcode= "$agresso_klant[13]$agresso_klant[14]";                                       
                                       my  $datestring = gmtime();
                                       my $hoedanigheid= $agresso_klant[17];
                                       #print "time $datestring->";
                                       my $zkf_line_no=$zkf_nr*100+ $line_no;
                                       #$line_no = $dbh_agresso->selectrow_array("SELECT COUNT(*) from afxvmobcontract where dim_value= '$agresso_klant[0]'");                               
                                       #$klant->{$zkf_nr}->{$agresso_klant[9]}->{$ext_nr}->{$naam}->{dossier_nr}=$agresso_klant[9];
                                       $klant->{$zkf_nr}->{$agresso_klant[9]}->{$ext_nr}->{$naam}->{verzekeringsnr}=$verz_nr ;
                                       $klant->{$zkf_nr}->{$agresso_klant[9]}->{$ext_nr}->{$naam}->{produktnr}=$prod_nr ;
                                       my $einddatum = $agresso_klant[8];
                                       my $startdatum = $agresso_klant[6];
                                       my $vandaag_tweejaarterug = $vandaag - 20000;                                      
                                        if ($oud_agresso_nr != $agresso_klant[0] and $main::volledig eq 'FULL' ) {
                                             $line_no = 0;
                                             $oud_agresso_nr =$agresso_klant[0];
                                             if ($main::enkel_jo ne 'JA') {
                                                agresso->delete_contracten_all($dbh_agresso,$agresso_klant[0],$zkf_nr);
                                                #print '';
                                             }
                                          }
                                       if ($einddatum < $vandaag_tweejaarterug and $main::volledig eq 'UPDATE') {
                                             #print "\nniets doen oud contract  einddatum < vandaag_tweejaarterug -> $einddatum < $vandaag_tweejaarterug\n";
                                       }else {
                                          #print "N con $agresso_klant[0] $verz_nr $verz_nr $ext_nr $agresso_klant[9] $startdatum $einddatum\n";
                                          if ($main::enkel_jo ne 'JA') {
                                                my (@bezette_lijnen) = agresso->delete_contract($agresso_klant[0],$zkf_nr,$agresso_klant[9],$startdatum,$einddatum);
                                                #print "bezet  @bezette_lijnen zkf_line_no $zkf_line_no\n";
                                                my $gev = 0;
                                                until ($gev == 1) {
                                                   my $aangepast =0;
                                                   for (@bezette_lijnen) {
                                                      if ($_ eq $zkf_line_no) {
                                                          $zkf_line_no +=1;                                                                                                       
                                                          $aangepast =1;
                                                          last;
                                                      }
                                                   }
                                                   $gev =1 if  ($aangepast == 0);
                                                }
                                          }
                                         # print "lijn genomen $zkf_line_no \n";
                                          #if ($agresso_klant[0] == 100015) {
                                          #   print '';
                                          #}
                                          $klant = AS400->check_betaling_dossier($instellingen,$klant,$agresso_klant[0],$agresso_klant[1]) ;
                                          my $dossier = $agresso_klant[9];
                                          my $laatste_periodiciteit= '';
                                          my $betaler_naam;
                                          my $betaler_rrn;
                                          my $betaalstatus = 'OK';
                                          $betaalstatus= 'NOK_ABW' if ($agresso_klant[0] ~~ @agressonrs_slechte_betalers_ubw);
                                          if ($klant->{$zkf_nr}->{$dossier}->{$ext_nr}->{$naam}->{nooit_betaald} eq 'ja'){
                                             if ( $betaalstatus eq 'NOK_ABW') {
                                                 $betaalstatus= 'NOK_ABW_WS';
                                             }else {
                                                 $betaalstatus= 'NOK_WS'; 
                                             }
                                             #print '';
                                          }
                                          my ($laatste_betaling,$saldo,$laatste_barema,$laatste_betaalwijze,$laatste_betaler);                                          
                                          if ($klant->{$zkf_nr}->{$dossier}->{$ext_nr}->{$naam}->{betaling_gevonden} eq 'ja') {
                                                $laatste_betaling= $klant->{$zkf_nr}->{$dossier}->{$ext_nr}->{$naam}->{laatste_betaling};
                                                $laatste_betaling =  $agresso_klant[8] if ($laatste_betaling > $agresso_klant[8]);
                                                $saldo = $klant->{$zkf_nr}->{$dossier}->{$ext_nr}->{$naam}->{saldo};
                                                $laatste_barema = $klant->{$zkf_nr}->{$dossier}->{$ext_nr}->{$naam}->{laatste_barema};
                                                $laatste_betaalwijze  = $klant->{$zkf_nr}->{$dossier}->{$ext_nr}->{$naam}->{laatste_betaalwijze};
                                                $laatste_betaler = $klant->{$zkf_nr}->{$dossier}->{$ext_nr}->{$naam}->{laatste_betaler};
                                               
                                                if ($laatste_betaler eq 'zelf') {
                                                   my $nm= $agresso_klant[15];
                                                   my $vnm = $agresso_klant[16];
                                                   $nm =~ s/^\s+//;
                                                   $nm =~ s/\s+$//;
                                                   $vnm =~ s/^\s+//;
                                                   $vnm =~ s/\s+$//;
                                                   $betaler_naam = "$vnm $nm";
                                                   $betaler_rrn = "$agresso_klant[1]"
                                                }else {
                                                   ($betaler_naam,$betaler_rrn) = AS400->checknaamnextern($laatste_betaler,$dbh,$instellingen->{ziekenfondsen}->{$zkf}->{as400});
                                                }
                                                $laatste_periodiciteit = $laatste_betaler = $klant->{$zkf_nr}->{$dossier}->{$ext_nr}->{$naam}->{laatste_periodiciteit};
                                                $laatste_periodiciteit = 'JAARLIJKS' if ($laatste_periodiciteit eq '01');
                                                $laatste_periodiciteit = 'SEMESTER' if ($laatste_periodiciteit eq '02');
                                                $laatste_periodiciteit = 'KWARTAAL' if ($laatste_periodiciteit eq '04');
                                                $laatste_periodiciteit = 'MAANDELIJKS' if ($laatste_periodiciteit eq '12');
                                                $laatste_periodiciteit = 'WEIGERING' if ($laatste_periodiciteit eq '06' );
                                          }else {
                                             if ($agresso_klant[6] == $agresso_klant[8]){
                                                 $laatste_periodiciteit = 'JAARLIJKS';
                                                 $laatste_betaling =$agresso_klant[6];
                                                 $saldo = 0;
                                                 $laatste_barema = 0;
                                                 $laatste_betaalwijze = 'OVERSCHRIJVING';
                                                 my $nm= $agresso_klant[15];
                                                 my $vnm = $agresso_klant[16];
                                                 $nm =~ s/^\s+//;
                                                 $nm =~ s/\s+$//;
                                                 $vnm =~ s/^\s+//;
                                                 $vnm =~ s/\s+$//;
                                                 $betaler_naam = "$vnm $nm";
                                                 $betaler_rrn = "$agresso_klant[1]"
                                             }else {
                                                #print "ik weet niets gok";
                                                $laatste_periodiciteit = 'JAARLIJKS';
                                                 $laatste_betaling =$agresso_klant[6];
                                                 $saldo = 99999;
                                                 $laatste_barema = 0;
                                                 $laatste_betaalwijze = 'OVERSCHRIJVING';
                                                 my $nm= $agresso_klant[15];
                                                 my $vnm = $agresso_klant[16];
                                                 $nm =~ s/^\s+//;
                                                 $nm =~ s/\s+$//;
                                                 $vnm =~ s/^\s+//;
                                                 $vnm =~ s/\s+$//;
                                                 $betaler_naam = "$vnm $nm";
                                                 $betaler_rrn = "$agresso_klant[1]"
                                             }
                                          }
                                          #print "INSERT INTO afxvmobcontract (attribute_id,dim_value,line_no,client,product,startdatum,wachtdatum,einddatum,contract_nr,
                                          #zkf_nr,info,last_update,user_id,aansluitingscode_fx,ontslagcode_fx) VALUES
                                          #(A4,$agresso_klant[0],$zkf_line_no,VMOB,$naam,$agresso_klant[6],$agresso_klant[7],$agresso_klant[8],$agresso_klant[9],
                                          #$zkf,$info,getdate(),WEBSERV,$aansluitingscode,$ontslagcode)\n";
                                          my $ok=1;
                                          $betaler_naam =~ s/'/''/;
                                          if ($main::enkel_jo ne 'JA') {
                                             $ok = $dbh_agresso->do("INSERT INTO afxvmobcontract (attribute_id,dim_value,line_no,client,product,startdatum,
                                                                    wachtdatum,einddatum,contract_nr,zkf_nr,info,last_update,user_id,aansluitingscode_fx,
                                                                    ontslagcode_fx,laatste_betaaldatum_fx,openstaande_premie_fx,betaalwijze_fx,barema_fx,
                                                                    betaler_naam_fx,betaler_rrn_fx,periode_premie_fx,hoedanigheid_fx,bestaalstatus_fx) VALUES
                                                                    ('A4',$agresso_klant[0],$zkf_line_no,'VMOB','$naam','$agresso_klant[6]','$agresso_klant[7]',
                                                                    '$agresso_klant[8]',$agresso_klant[9],'$zkf_nr','$info',getdate(),'WEBSERV',
                                                                    '$aansluitingscode','$ontslagcode','$laatste_betaling',$saldo,'$laatste_betaalwijze',
                                                                    $laatste_barema,'$betaler_naam','$betaler_rrn','$laatste_periodiciteit','$hoedanigheid','$betaalstatus')") ;                    
                                          }
                                          
                                          $datestring = gmtime();                              
                                          #print " time $datestring-> ok->$ok";
                                          my $laatste_betaling_jo = $laatste_betaling;
                                          if ($laatste_betaling < 19500101 or $laatste_betaling eq ''){
                                              $laatste_betaling_jo = 19000101 ;
                                              #print '';
                                          }
                                          
                                         
                                          my $jodata = "A4;$agresso_klant[0];$zkf_line_no;VMOB;$naam;$agresso_klant[6];$agresso_klant[7];";
                                          $jodata= "$jodata"."$agresso_klant[8];$agresso_klant[9];$zkf_nr;$info;$vandaag;WEBSERV;";
                                          $jodata= "$jodata"."$aansluitingscode;$ontslagcode;$laatste_betaling_jo;$saldo;$laatste_betaalwijze;";
                                          $jodata= "$jodata"."$laatste_barema;$betaler_naam;$betaler_rrn;$laatste_periodiciteit;$hoedanigheid;$betaalstatus";                                          
                                          print JOFILE "$jodata\n";      
                                          #$line_no +=1;
                                          $record_teller +=1;                                          
                                          if ($ok == 1) {
                                                  #print  "contract-> $agresso_klant[0] ->$line_no $naam ingezet\n";
                                                  $total_ok +=1;
                                                 }else {
                                                  #print  "contract-> $agresso_klant[0] ->$line_no $naam fout\n";
                                                  $mail_contracten  = $mail_contracten."contract->$agresso_klant[0]->$line_no $naam fout\n";
                                                  $total_nok +=1;
                                                 }
                                       }    
                                    
                                    }
                         }
                     $dbh_agresso->{odbc_err_handler} = undef; # cancel the handler    
                                        #print '';
                AS400->dscnnectdb($dbh);
                
               }
           close (JOFILE);
           copy ($file_voor_jo,$file_agresso);
           my $totaal = $total_ok + $total_nok ;
           $mail_contracten  = $mail_contracten."We hebben in het totaal voor $totaal klanten contracten ingezet.\nVoor $total_ok klanten is dat gelukt.\nVoor $total_nok klanten is dat niet gelukt\n" ;
           print "We hebben in het totaal voor $totaal klanten contracten ingezet.\nVoor $total_ok klanten is dat gelukt.\nVoor $total_nok klanten is dat niet gelukt\n" ;
           my $stopfile =$main::agresso_instellingen->{plaats_teller_insert_contracten};
           $stopfile ="$stopfile\\last_contract_inserted.txt";
           unlink $stopfile;
                             
      }

    sub checknaamnextern {
                  my ($class,$extern_nummer,$dbh,$settings) = @_;
                  #openen van PFYSL8
                  # EXIDL8 = extern nummer
                  # KNRNL8 = nationaalt register nummer
                  # NAMBL8 = naam van de gerechtigde
                  # PRNBL8 = voornaam van de gerechtigde
                  # SEXEL8 = code van het geslacht
                  # NAIYL8 = geboortejaat
                  # NAIML8 = geboortemaand
                  # NAIJL8 = geboortedag
                  my $pers_fil = "$settings->{libcxfil}.PFYSL8";
                  my @naamrij = $dbh->selectrow_array("SELECT EXIDL8,KNRNL8,NAMBL8,PRNBL8,SEXEL8,NAIYL8,NAIML8,NAIJL8,KVPSL8 FROM $pers_fil WHERE EXIDL8=$extern_nummer");
                  $naamrij[1]=~ s/^\s+//;
                  $naamrij[3]=~ s/^\s+//;
                  $naamrij[3]=~ s/\s+$//;
                  $naamrij[2]=~ s/^\s+$//;
                  $naamrij[2]=~ s/\s+$//;
                  $naamrij[8]=~ s/^\s+$//; #versie 3.3 neuw id
                  $naamrij[8]=~ s/\s+$//;
                  $naamrij[8]=~ s/^203//;
                  my $naam = "$naamrij[3] $naamrij[2]";
                  #rijksregisternummer
                  my $inz_nr_g_sp = $naamrij[1];
                  my $splitinz=$naamrij[1];
                  $splitinz=~ s%\d{2}$% $&%;
                  $splitinz=~ s%\d{3}\s\d{2}$% $&%;
                  my $inz_nr_spatie = sprintf ('%013s',$splitinz);  #voorafgaande nullen terug zetten
                  #new id
                  my $split_new_id  = $naamrij[8];
                  $split_new_id =~ s%\d{2}$% $&%;
                  $split_new_id =~ s%\d{2}\s\d{2}$% $&%;
                  $split_new_id =~ s%\d{6}\s\d{2}\s\d{2}$% $&%;
                  my $new_id_nr_spatie = sprintf ('%015s', $split_new_id );  #voorafgaande nullen terug zetten
                    #extern nummer
                  $extern_nummer = sprintf ('%013s',$naamrij[0]);  #voorafgaande nullen terug zetten
                  #geboortedatum
                
                      
                  return ($naam,$inz_nr_g_sp);
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
    sub check_betaling_dossier {
        my ($self,$instellingen,$klanten,$argresso_client_id,$rr) = @_;
        if ($argresso_client_id == 100015) {
         #print '';
        }
        my ($laatste_betaling,$saldo,$laatste_barema,$laatste_betaalwijze,$laatste_betaler,$laatste_periodiciteit,$betaling_gevonden,$nooit_betaald);
        foreach my $zkf_nr (sort keys $klanten) {
                  my $link = $instellingen->{ziekenfondsen}->{"ZKF$zkf_nr"}->{as400};
                  my $verz_link = $instellingen->{verzekeringen}->{"ZKF$zkf_nr"};
                  my $dbh = AS400->cnnectdb($link->{username},$link->{password},$link->{as400_name});
                   my $PTAXKQ = "$link->{libcxfil}\.PTAXKQ";
                   my $PPADKO = "$link->{libcxfil}\.PPADKO";
                  foreach my $dossier (sort keys $klanten->{$zkf_nr}) {
                      my $dossier_niet_betaald;
                      foreach my $ext_nr (keys $klanten->{$zkf_nr}->{$dossier} ) {
                            my $verzekeringen_genomen ;
                            foreach my $verz_naam (keys $klanten->{$zkf_nr}->{$dossier}->{$ext_nr} ) {
                                  if ($verz_naam !~ m/klantinfo/i) {
                                    my $vz_nr = $klanten->{$zkf_nr}->{$dossier}->{$ext_nr}->{$verz_naam}->{verzekeringsnr};
                                    my $prod_nr = $klanten->{$zkf_nr}->{$dossier}->{$ext_nr}->{$verz_naam}->{produktnr};
                                    $verzekeringen_genomen->{$verz_naam}->{verzekeringsnr} = $vz_nr ;
                                    $verzekeringen_genomen->{$verz_naam}->{produktnr} = $prod_nr ;
                                  }
                              }
                           foreach my $verznaam (sort keys $verzekeringen_genomen) {
                                    my $verz_nr = $verzekeringen_genomen->{$verznaam}->{verzekeringsnr};
                                    my $prod_nr  = $verzekeringen_genomen->{$verznaam}->{produktnr};
                                    ($laatste_betaling,$saldo,$laatste_barema,$laatste_betaalwijze,$laatste_betaler,$laatste_periodiciteit,$betaling_gevonden,$nooit_betaald)=
                                    AS400->checkbetaling($dbh,$PTAXKQ,$PPADKO,$zkf_nr,$dossier, $ext_nr,$verz_nr,$prod_nr,$argresso_client_id,$rr);
                                    #print "$dossier verz_nr ->  $laatste_betaling,$saldo,$laatste_barema,$laatste_betaalwijze,$laatste_betaler\n";
                                    if ($betaling_gevonden eq 'ja') {
                                       $klanten->{$zkf_nr}->{$dossier}->{$ext_nr}->{$verznaam}->{laatste_betaling}=$laatste_betaling;
                                       $klanten->{$zkf_nr}->{$dossier}->{$ext_nr}->{$verznaam}->{saldo}=$saldo;
                                       $klanten->{$zkf_nr}->{$dossier}->{$ext_nr}->{$verznaam}->{laatste_barema}=$laatste_barema;
                                       $klanten->{$zkf_nr}->{$dossier}->{$ext_nr}->{$verznaam}->{laatste_betaalwijze}=$laatste_betaalwijze;
                                       $klanten->{$zkf_nr}->{$dossier}->{$ext_nr}->{$verznaam}->{laatste_betaler}=$laatste_betaler;
                                       $klanten->{$zkf_nr}->{$dossier}->{$ext_nr}->{$verznaam}->{laatste_periodiciteit}=$laatste_periodiciteit;
                                       $klanten->{$zkf_nr}->{$dossier}->{$ext_nr}->{$verznaam}->{betaling_gevonden} = 'ja';
                                       $klanten->{$zkf_nr}->{$dossier}->{$ext_nr}->{$verznaam}->{nooit_betaald} = $nooit_betaald;
                                    }else {
                                       $klanten->{$zkf_nr}->{$dossier}->{$ext_nr}->{$verznaam}->{betaling_gevonden} = 'nee';
                                       $klanten->{$zkf_nr}->{$dossier}->{$ext_nr}->{$verznaam}->{nooit_betaald} = 'ja';
                                    }
                                    
                              }
                        }
                  }
                AS400->dscnnectdb($dbh);
            }
        
     return ($klanten);  
    }
    sub checkbetaling {
     my ($self,$dbh,$betaling_fil,$PPADKO,$nr_zkf,$dossier,$externnummer,$verz_nr,$prod_nr,$argresso_client_id,$rr,$begindatum,$einddatum) = @_ ;   
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
     #ABNOKQ            osrriernr
     #ABBNKQ              NO.EXTERNE PAYEUR
     #ABVCKQ              CODE VORDERING / CODE AVIS
     #A.ABBXKQ              BEH.SLECHTE BET.NA(CD)/GEST.     
      #A.ABDXKQ              BEH.SLECHTE BET.FI(DT)/GEST.     
      #A.ABNXKQ              BEH.SLECHTE BET.NA(DT)/GEST.     
      #A.ABSVKQ              STATUTAIR OBLIGATOIR    /STATU   
      #A.ABPYKQ              MODE DE PERCEPTION      /WIJZE   
      #A.ABNBKQ              TAX.BARÈME NORM./ÉCAR./TAX. BA
      #A.ABAUKQ              ANNEE-TRIMESTRE         /KWART
      #A.ABXDKQ              DATE TAXATION           /DATUM   
      #A.ABUDKQ              DATE ANNULATION TAXATION/ANNUL
      #A.ABZDKQ              DATE COMPTABILITE       /DATUM
      #ABPYKQ                 MODE DE PERCEPTION 
     my $sqlbetaling =("SELECT IDFDKQ,EXIDKQ,ABTVKQ,ABVYKQ,ABVMKQ,ABCNKQ,ABCOKQ,AT79KQ,ABBAKQ,ABBNKQ,ABAUKQ,ABBXKQ,ABDXKQ,ABNXKQ,
                      ABXDKQ,ABUDKQ,ABZDKQ,ABPYKQ,b.ABP0KO FROM $betaling_fil JOIN $PPADKO b ON ABNOKQ = b.ABNOKO
                      WHERE IDFDKQ = $nr_zkf and EXIDKQ  = $externnummer and ABNOKQ  = $dossier and ABTVKQ =$verz_nr and b.ABTVKO = $verz_nr  ");
     my $sthbetaling = $dbh->prepare( $sqlbetaling );
     $sthbetaling ->execute();
     my @betalingen = () ;
     my @laatstebetaling=();
     my $totaal_over_alles =0;
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
     my $nooit_betaald= 'ja';
     while(@betalingen =$sthbetaling ->fetchrow_array)  {
         $totaal_over_alles +=  $betalingen[5];
         $betalingenh->{($betalingen[3]*100+$betalingen[4])}->{'betaald'} += $betalingen[5]; #zien of er gecrditeerd wordt        
         $betalingenh->{($betalingen[3]*100+$betalingen[4])}->{'jaar'} = $betalingen[3]; 
         $betalingenh->{($betalingen[3]*100+$betalingen[4])}->{'maand'} = $betalingen[4];
         $betalingenh->{($betalingen[3]*100+$betalingen[4])}->{'bedrag'} = $betalingen[5];
         $betalingenh->{($betalingen[3]*100+$betalingen[4])}->{'saldo'} = $betalingen[6];
         $betalingenh->{($betalingen[3]*100+$betalingen[4])}->{'totaal'} = $betalingen[7];
         $betalingenh->{($betalingen[3]*100+$betalingen[4])}->{'barema'} = $betalingen[8];
         $betalingenh->{($betalingen[3]*100+$betalingen[4])}->{'betaler'} = $betalingen[9];
         $betalingenh->{($betalingen[3]*100+$betalingen[4])}->{'jaar_tri'} = $betalingen[10];
         $betalingenh->{($betalingen[3]*100+$betalingen[4])}->{'Slechte_betaler_NA1'} = $betalingen[11];
         $betalingenh->{($betalingen[3]*100+$betalingen[4])}->{'Slechte_betaler_FI'} = $betalingen[12];
         $betalingenh->{($betalingen[3]*100+$betalingen[4])}->{'Slechte_betaler_NA2'} = $betalingen[13];
         $betalingenh->{($betalingen[3]*100+$betalingen[4])}->{'Datum_taxatie'} = $betalingen[14];
         $betalingenh->{($betalingen[3]*100+$betalingen[4])}->{'Datum_annulatie_taxatie'} = $betalingen[15];
         $betalingenh->{($betalingen[3]*100+$betalingen[4])}->{'Betaaldatum'} = $betalingen[16];
         $betalingenh->{($betalingen[3]*100+$betalingen[4])}->{'BetaalWijze'} = $betalingen[17];
         $betalingenh->{($betalingen[3]*100+$betalingen[4])}->{'Betalings_periodiciteit'} = $betalingen[18];
         #print "@betalingen->\n";
         if ($rijenteller== 0) {
           $jaarb = $betalingen[3]; #code
           $maandb =$betalingen[4];
           $hebben_nooit_betaald =1;
         }
         
         $rijenteller +=1;
         
        }
     my $laatste_betaling;
     my $laaste_betaling_gevonden=0;
     my $laatste_barema;
     my $laaste_barema_gevonden=0;
     my $laatste_betaalwijze;
     my $laatste_betaalwijze_gevonden=0;
     my $saldo=0;
     my $laatste_betaler;
     my $laatste_betaler_gevonden=0;
     my $laatste_periodiciteit;
     my $laatste_betalings_periodiciteit_gevonden =0;
     my $betalingen_gevonden = 'ja';
     eval { foreach my $jaarmaand (reverse sort keys $betalingenh) {}};
     if ($@) {
         #print "\ngeen betalingen $argresso_client_id rijksreg $rr\n";
         #print "SQL $betaling_fil JOIN $PPADKO b ON ABNOKQ = b.ABNOKO  WHERE IDFDKQ = $nr_zkf and EXIDKQ  = $externnummer and ABNOKQ  = $dossier and ABTVKQ =$verz_nr and b.ABTVKO = $verz_nr \n";
         $betalingen_gevonden = 'nee';
     }else {
         foreach my $jaarmaand (reverse sort keys $betalingenh) {
            if ( $jaarmaand  > 0 and $laaste_betaling_gevonden == 0 and $betalingenh->{$jaarmaand}->{'saldo'} == 0) {
                  $laaste_betaling_gevonden=1;
                  $nooit_betaald ='nee';
                  my $year = substr ($jaarmaand,0,4);
                  my $month = substr ($jaarmaand,4,2);
                  my $date = DateTime->new(
                        year  =>  $year,
                        month => $month,
                        day   => 1,
                    );
                  my $paydate = $date->clone;
                  $paydate->add( months => 1 )->subtract( days => 1 );
                  $laatste_betaling = $paydate->ymd;
                  $laatste_betaling =~ s/-//g;
            }
            if ( $betalingenh->{$jaarmaand}->{'barema'}  > 0 and $laaste_barema_gevonden == 0) {
                  $laaste_barema_gevonden =1;
                  $laatste_barema =  $betalingenh->{$jaarmaand}->{'barema'};   
            }
            if ( $betalingenh->{$jaarmaand}->{'BetaalWijze'}  >= 0 and $laatste_betaalwijze_gevonden == 0) {
                  $laatste_betaalwijze_gevonden = 1;
                  $laatste_betaalwijze = 'DOMI' if ($betalingenh->{$jaarmaand}->{'BetaalWijze'} ==1);
                  $laatste_betaalwijze = 'OVERSCHRIJVING' if ($betalingenh->{$jaarmaand}->{'BetaalWijze'} ==0);              
            }
            if ( $betalingenh->{$jaarmaand}->{'betaler'}  >= 0 and  $laatste_betaler_gevonden == 0) {
                  $laatste_betaler_gevonden = 1;
                  $laatste_betaler = $betalingenh->{$jaarmaand}->{'betaler'};
                  $laatste_betaler = 'zelf' if ($betalingenh->{$jaarmaand}->{'betaler'} == $externnummer);         
            }
            if ( $betalingenh->{$jaarmaand}->{'betaler'}  >= 0 and  $laatste_betalings_periodiciteit_gevonden == 0) {
                  $laatste_betalings_periodiciteit_gevonden = 1;
                  $laatste_periodiciteit =  $betalingenh->{$jaarmaand}->{'Betalings_periodiciteit'};     
            }
            $saldo +=  $betalingenh->{$jaarmaand}->{'saldo'};
         }
      }
     return ($laatste_betaling,$saldo,$laatste_barema,$laatste_betaalwijze,$laatste_betaler,$laatste_periodiciteit,$betalingen_gevonden,$nooit_betaald);
    }
    sub zoek_info {
         my ($self,$dbhInfo,$rijksregnr,$verzekering,$dbh) = @_;
         #my $dbhInfo = AS400->cnnectdb($link_info->{username},$link_info->{password},$link_info->{as400_name});
         my $info_terug = '';
         if ($rijksregnr =~ m/^\d{3,12}/ ) {
              my @info= $dbhInfo->selectrow_array("SELECT INFO52,INFO62,INFO64,INFO51,INFO61,INFO63,INFOFOR,INFOCON FROM libsxfil03.MOBGEVN
                                      WHERE KNRN52 = $rijksregnr");
               foreach my $info1 (@info) {
                    if (defined $info1) {
                         $info1 =~ s/^\s+//;
                         $info1 =~ s/\s+$//;
                        }
                   }
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
                  #AS400->dscnnectdb($dbhInfo);
              }
           return ($info_terug );
        }
   
    sub err_handler {
      my @err_h = @_;
      print "\nerror instert\n____________";
      print "@err_h\n";
      return 0;
    }