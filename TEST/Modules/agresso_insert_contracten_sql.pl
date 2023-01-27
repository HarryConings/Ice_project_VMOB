#!/usr/bin/perl -w
use strict;
use strict;
use Data::Dumper;
#use XML::Compile::Schema;
#use XML::Compile::Cache;
use XML::LibXML::Reader;     
use XML::Simple;
use Date::Manip::DM5 ;
use Net::SMTP;
use Date::Calc qw(:all);
use SOAP::Lite ;
     #+trace => [ transport => sub { print $_[0]->as_string } ];
require "settings.pl";
require "cnnectdb.pl";
our %settings;
our $vandaag = ParseDate("today");
my $vandaag_tijd = $vandaag;
my $start_tijd = substr ($vandaag,8,8);
$vandaag_tijd =~ s/://g;
$vandaag_tijd =~ s/\s//g;
our $tijd = substr ($vandaag_tijd,8,6);
$vandaag = substr ($vandaag,0,8);
our $agresso_instellingen ;
our @ziekenfondsen = ();
our $mail_contracten ='';
our $total_ok =0;
our $total_nok=0;
our $verzekeringen;
$mail_contracten  = $mail_contracten."WE GAAN CONTRACTEN IN AGRESSO TEST INZETTEN\n";
$mail_contracten  = $mail_contracten."------------------------------------------------------------------------\n";
$mail_contracten  = $mail_contracten."\nstartijd : $start_tijd\n";
print "WE GAAN CONTRACTEN IN AGRESSO TEST INZETTEN\n";
print "------------------------------------------------------------------------\n";
print "\nstartijd : $start_tijd\n";
&load_agresso_setting('P:\OGV\ASSURCARD_TEST\assurcard_settings_xml\agresso_settings.xml');
#&delete_contracten;
&zoek_ziekenfondsen;
&zoek_verzekeringen;
print "";
&zoek_verzekerden;
&mail_bericht_contracten;
print "\neinde\n";
sub load_agresso_setting  {
     my $file_name = shift @_;
     $agresso_instellingen = XMLin("$file_name");
     print "ingelezen\n";
     #maak verzekeringen
    
    }
sub zoek_ziekenfondsen {
     foreach my $zkf (keys $agresso_instellingen->{verzekeringen}){
         my $ziekenfondsnr = $& if ($zkf =~ m/\d{3}/);
         push(@ziekenfondsen,$ziekenfondsnr);
        }
     }
sub zoek_verzekeringen {
     foreach my $zkf (keys $agresso_instellingen->{verzekeringen}){
         @{$verzekeringen->{$zkf}}=();
         my $ziekenfondsnr = $& if ($zkf =~ m/\d{3}/);
         $mail_contracten = $mail_contracten."$zkf -> volgende verzekeringen:\n";
         $mail_contracten = $mail_contracten."--------------------------------\n";
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
    }
sub zoek_verzekerden {
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
      # my $dbh = &cnnectdb ($settings{user_name},$settings{password},$settings{name_as400});
      # my $sql =("SELECT * FROM $settings{'phoekk_fil'} WHERE EXIDKK = 0200085650058");
      # my $sth = $dbh->prepare( $sql );
      # $sth ->execute();
      # while(my @agresso_klant = $sth->fetchrow_array)  {
      #      print "@agresso_klant\n";
      #    }
      foreach my $zkf (@ziekenfondsen) {
         &settings ($zkf);
         my $zkf_naam ="ZKF$zkf";
         my $dbh = &cnnectdb ($settings{user_name},$settings{password},$settings{name_as400});
         my $placeholders = join ",", (@{$verzekeringen->{$zkf_naam}});
         my $sql =("SELECT a.AGRESONR,a.KNRN52,a.ZKF,c.EXIDL8,
                        b.ABTVKK,b.ABPRKK,b.ABADKK,b.ABPEKK,b.ABEDKK,b.ABNOKK,a.ZKF,b.ABACKK,b.AB2AKK,b.ABOCKK,b.AB2OKK
                        FROM $settings{'ascard_fil'} a
                        JOIN $settings{'pers_fil'} c ON a.KNRN52 = c.KNRNL8 
                        JOIN $settings{'phoekk_fil'}  b ON c.EXIDL8=b.EXIDKK
                        WHERE b.ABTVKK IN ($placeholders)                         
                        ORDER BY a.AGRESONR,b.ABTVKK,b.ABADKK,b.ABADKK DESC" );#fetch first 10 rows only
         my $sth = $dbh->prepare( $sql );
         $sth ->execute();
         my  $record_teller =0;
         my $oud_agresso_nr =0;
         my @agresso_klant =();
         my $xml ='';
         my $dbh_mssql =&setup_mssql_connectie;
         my $line_no = 0;
         while(@agresso_klant =$sth->fetchrow_array)  {
             my $naam= &zoek_naam_verzekering($agresso_klant[4],$agresso_klant[5],$zkf_naam);
             $naam= uc $naam;
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
             my $info = &zoek_info($agresso_klant[1],$agresso_klant[4]);
             $info = '' if (!defined $info);
             my $aansluitingscode= "$agresso_klant[11]$agresso_klant[12]";
             my $ontslagcode= "$agresso_klant[13]$agresso_klant[14]";
           
             if ($oud_agresso_nr != $agresso_klant[0] ) {
                     $line_no = 0;
                     $oud_agresso_nr =$agresso_klant[0];
                   }
               #               exec sp_columns @table_name = 'afxvmobcontract';
               #select * from afxvmobcontract where dim_value='100001';
               #Table Name	Column Name	Data Type	Type Name	Precision	Length	Scale	Radix	Nullable	Remarks	Column Def	Sql Data Type	Sql Datetime Sub	Char Octet Length	Ordinal Position	Is Nullable
               #afxvmobcontract	attribute_id	1	char	4	4	0	0	0		(' ')	1	0	4	1	NO
               #afxvmobcontract	dim_value	12	varchar	25	25	0	0	0		(' ')	12	0	25	2	NO
               #afxvmobcontract	line_no	4	int	10	4	0	10	0		((0))	4	0	0	3	NO
               #afxvmobcontract	client	12	varchar	25	25	0	0	0		(' ')	12	0	25	4	NO
               #afxvmobcontract	date_from	11	datetime	23	16	3	0	1		(CONVERT([datetime],'19000101',(112)))	9	3	0	5	YES
               #afxvmobcontract	date_to	11	datetime	23	16	3	0	1		(CONVERT([datetime],'19000101',(112)))	9	3	0	6	YES
               #afxvmobcontract	product	12	varchar	25	25	0	0	0		(' ')	12	0	25	7	NO
               #afxvmobcontract	startdatum	11	datetime	23	16	3	0	1		(CONVERT([datetime],'19000101',(112)))	9	3	0	8	YES
               #afxvmobcontract	wachtdatum	11	datetime	23	16	3	0	1		(CONVERT([datetime],'19000101',(112)))	9	3	0	9	YES
               #afxvmobcontract	einddatum	11	datetime	23	16	3	0	1		(CONVERT([datetime],'19000101',(112)))	9	3	0	10	YES
               #afxvmobcontract	contract_nr	12	varchar	20	20	0	0	0		(' ')	12	0	20	11	NO
               #afxvmobcontract	zkf_nr	12	varchar	15	15	0	0	0		(' ')	12	0	15	12	NO
               #afxvmobcontract	zkf_nr_datum_van	11	datetime	23	16	3	0	1		(CONVERT([datetime],'19000101',(112)))	9	3	0	13	YES
               #afxvmobcontract	zkf_nr_datum_tot	11	datetime	23	16	3	0	1		(CONVERT([datetime],'19000101',(112)))	9	3	0	14	YES
               #afxvmobcontract	info	12	varchar	100	100	0	0	0		(' ')	12	0	100	15	NO
               #afxvmobcontract	last_update	11	datetime	23	16	3	0	1		(CONVERT([datetime],'19000101',(112)))	9	3	0	16	YES
               #afxvmobcontract	user_id	1	char	25	25	0	0	0		(' ')	1	0	25	17	NO
               #afxvmobcontract	agrtid	-5	bigint identity	19	8	0	10	0			-5	0	0	18	NO
               #afxvmobcontract	aansluitingscode_fx	12	varchar	25	25	0	0	0		(' ')	12	0	25	19	NO
               #afxvmobcontract	ontslagcode_fx	12	varchar	25	25	0	0	0		(' ')	12	0	25	20	NO
               #print  "INSERT INTO afxvmobcontract (attribute_id,dim_value,line_no,client,product,startdatum,wachtdatum,einddatum,contract_nr,
               #     zkf_nr,info,last_update,user_id,aansluitingscode_fx,ontslagcode_fx) VALUES
               #     ('A4','$agresso_klant[0]',$line_no,'VMOB','$naam','$agresso_start_datum','$agresso_wacht_datum','$agresso_eind_datum',$agresso_klant[9],
               #     $zkf,'$info',$vandaag,'WEBSERV','$aansluitingscode','$ontslagcode'\n";
           $dbh_mssql->do("INSERT INTO afxvmobcontract (attribute_id,dim_value,line_no,client,product,startdatum,wachtdatum,einddatum,contract_nr,
                    zkf_nr,info,last_update,user_id,aansluitingscode_fx,ontslagcode_fx) VALUES
                    ('A4','$agresso_klant[0]',$line_no,'VMOB','$naam','$agresso_klant[6]','$agresso_klant[7]','$agresso_klant[8]',$agresso_klant[9],
                    $zkf,'$info',getdate(),'WEBSERV','$aansluitingscode','$ontslagcode')");
            $line_no +=1;
            $record_teller +=1;
            #print "\nal gedaan ->$record_teller\n" if ( $record_teller % 100 == 0);
          }
  
        }
     my $totaal = $total_ok + $total_nok ;
     $mail_contracten  = $mail_contracten."We hebben in het totaal voor $totaal klanten contracten ingezet.\nVoor $total_ok klanten is dat gelukt.\nVoor $total_nok klanten is dat niet gelukt\n" ;
     print "We hebben in het totaal voor $totaal klanten contracten ingezet.\nVoor $total_ok klanten is dat gelukt.\nVoor $total_nok klanten is dat niet gelukt\n" ;
    } 
  
sub zoek_info {
     my $rijksregnr =shift @_;
     my $verzekering = shift @_;
     my $dbh = &cnnectdb ('SIS203','SIS203','airbus');
     my @info= $dbh->selectrow_array("SELECT INFO52,INFO62,INFO64,INFO51,INFO61,INFO63,INFOFOR,INFOCON FROM libsxfil03.MOBGEVN
                                      WHERE KNRN52 = $rijksregnr");
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
     &dscnnectdb($dbh);
     return ($info_terug );
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
sub mail_bericht_contracten {
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
         $smtp->datasend("Subject: Agresso contracten inzetten $vandaag");
         $smtp->datasend("\n");
         $smtp->datasend("$mail_contracten\nvriendelijke groeten\nHarry Conings");
         $smtp->dataend;
         $smtp->quit;
         print "mail aan $geadresseerde  gezonden\n";
        }
    }
sub zoek_naam_verzekering {
     my $verz_nr = shift @_;
     my $produktnummer = shift @_;
     my $ziekenfonds = shift @_;
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
sub delete_contracten {
      my $dbh = &setup_mssql_connectie;
      my $client = 'VMOB';
      $dbh->do("DELETE FROM afxvmobcontrbu WHERE client = '$client' ");
      $dbh->do("INSERT INTO afxvmobcontrbu (date_from,date_to,einddatum,last_update,startdatum,wachtdatum,zkf_nr_datum_tot,zkf_nr_datum_van,attribute_id,client,contract_nr,dim_value,info,line_no,product,user_id,zkf_nr) 
      Select date_from,date_to,einddatum,last_update,startdatum,wachtdatum,zkf_nr_datum_tot,zkf_nr_datum_van,attribute_id,client,contract_nr,dim_value,info,line_no,product,user_id,zkf_nr from afxvmobcontract");
      $dbh->do("DELETE FROM afxvmobcontract WHERE client = '$client' ");      
     }
sub setup_mssql_connectie {
     my $dbh_mssql;
     my $dsn_mssql = join "", (
         "dbi:ODBC:",
         "Driver={SQL Server};",
         #"Server=S998XXLSQL01.CPC998.BE\\i200;",
         "Server=S000WP1XXLSQL01.mutworld.be\\i200;", # nieuwe database server 2016 05
         "UID=HOSPIPLUS;",
         "PWD=ihuho4sdxn;",
         "Database=agraccept",
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