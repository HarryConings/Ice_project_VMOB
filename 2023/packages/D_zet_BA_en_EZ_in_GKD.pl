#!/usr/bin/perl -w
use strict;
require 'Decryp_Encrypt_prod.pl';
package main;
     use Date::Manip::DM5 ;
     use Date::Calc qw(:all);
     use XML::Simple;
     use Net::SMTP;
     use DBD::ODBC;
     use DBI;
     our $klant;
     our $vanaf_wanneer = '';
     our $tot_wanneer = '';
     our $vandaag = ParseDate("today");
     $vandaag = substr ($vandaag,0,8);     
     our $mail = "V7 zet Bestaande aandoeningen en Ernstige Ziektes in GKD\n_________________________________________________________________\n";
     our $mode = 'TEST';
     $mode = $ARGV[0] if (defined $ARGV[0]);
     if ( $mode eq 'TEST' or $mode eq 'PROD'){}else{die}
     our $agresso_instellingen = XMLin('D:\OGV\ASSURCARD_2023\assurcard_settings_xml\agresso_settings.xml');
     my $dbh_mssql = sql_toegang_agresso->setup_mssql_connectie;
     sql_toegang_agresso->afxvmobaandoen_get_rows($dbh_mssql);
     sql_toegang_agresso->afxvmobziekten_get_rows($dbh_mssql);
     my $zoekextern = as400->extern_nummer;
     my $timer = 0;
     foreach my $agresso_nr (sort keys $klant) {         
         $klant->{$agresso_nr}->{zkf} = $zoekextern->{$agresso_nr}->{zkf};
         $klant->{$agresso_nr}->{exid} = $zoekextern->{$agresso_nr}->{exid};
         $timer += 1;    
     }
    
     foreach my $agresso_nr (keys $klant) {
         my $zkf = $klant->{$agresso_nr}->{zkf};
         my $exid = $klant->{$agresso_nr}->{exid};
         #my $test =  $klant->{$agresso_nr};
         my $aandoeningen = '';
         eval{foreach my $teller (keys $klant->{$agresso_nr}->{aandoeningen}) {}};  
         if (!$@) {
            my $testhetzelfde = "";
            my $aandoening = '';
            foreach my $teller (keys $klant->{$agresso_nr}->{aandoeningen}) {
                my $verz = $klant->{$agresso_nr}->{aandoeningen}->[$teller]->{verzekering};
                my $begin = $klant->{$agresso_nr}->{aandoeningen}->[$teller]->{begindatum};
                my $eind = $klant->{$agresso_nr}->{aandoeningen}->[$teller]->{einddatum};
                my $tekst = "$verz $begin -> $eind ";
                if ($testhetzelfde !~ m/\Q$tekst/ ) {
                    $aandoening = $aandoening . $tekst;
                    $testhetzelfde = $tekst;
                    $klant->{$agresso_nr}->{GKD_tekst_aandoening} = $aandoening;
                }
            }
         }
        eval{foreach my $teller (keys $klant->{$agresso_nr}->{ziekten}) {}};
        if (!$@) {
           my $testhetzelfde = "";
           my $ziekte = '';
           foreach my $teller (keys $klant->{$agresso_nr}->{ziekten}) {            
                 my $verz = $klant->{$agresso_nr}->{ziekten}->[$teller]->{verzekering};
                 if ($testhetzelfde !~ m/\Q$verz/) {
                    $ziekte = $ziekte . $verz;
                    $testhetzelfde = $verz;
                    $klant->{$agresso_nr}->{GKD_tekst_ziekte} = $ziekte;
                 }
              }
           my $test = $klant->{$agresso_nr};          
           print ''; 
           }
          
        }
     print"";
     my $test = $klant->{'100266'};
     my $dbh = as400->cnnectdb(203);
     my $BA_fil_203 = "libsxfil03.VMOBBA";
     my $EZ_fil_203 = "libsxfil03.VMOBEZ";
     as400->delete_aandoeningen($dbh,$BA_fil_203);
     as400->delete_ziekte($dbh,$EZ_fil_203);
     as400->dscnnectdb($dbh);
     $dbh = as400->cnnectdb(235);
     my $BA_fil_235 = "libsxfil35.VMOBBA";
     my $EZ_fil_235 = "libsxfil35.VMOBEZ";
     as400->delete_aandoeningen($dbh,$BA_fil_235);
     as400->delete_ziekte($dbh,$EZ_fil_235);
     as400->dscnnectdb($dbh);
     foreach my $agresso_nr (keys $klant) {
         my $zkf = $klant->{$agresso_nr}->{zkf};
         my $exid = $klant->{$agresso_nr}->{exid};
         my $testklant = $klant->{$agresso_nr};
         eval { my $gkd_ba = $klant->{$agresso_nr}->{GKD_tekst_aandoening} };
         if (!$@ and defined $klant->{$agresso_nr}->{GKD_tekst_aandoening}) {
            my $gkd_ba = $klant->{$agresso_nr}->{GKD_tekst_aandoening};
            $gkd_ba =~ s/^\s+//;
            $gkd_ba =~ s/\s+$//;
            my $string_len = length($gkd_ba);
            if ($string_len > 95) {
                $gkd_ba = substr($gkd_ba,0,95);
                print "BA -> VERKORT  $agresso_nr $zkf  my $gkd_ba\n";
            }
           
            if ($zkf == 203) {
                $dbh = as400->cnnectdb(203);
                my ($zkf_chechk, $extern_check) = as400->search_contract($dbh,203,$agresso_nr);
                if ($zkf_chechk == 203 and $extern_check != 0) {
                    my $BA_fil = "libsxfil03.VMOBBA";
                    
                    as400->insert_bestaande_aandoening($dbh,$BA_fil,$extern_check,$gkd_ba);
                    as400->dscnnectdb($dbh);
                }else {
                     as400->dscnnectdb($dbh);
                     $dbh = as400->cnnectdb(235);
                     ($zkf_chechk, $extern_check) = as400->search_contract($dbh,235,$agresso_nr);
                     if ($zkf_chechk == 235 and $extern_check != 0) {
                         my $BA_fil = "libsxfil35.VMOBBA";
                         as400->insert_bestaande_aandoening($dbh,$BA_fil,$extern_check,$gkd_ba);
                         as400->set_correct_zkf_exit_in_ascard($dbh, $agresso_nr, $zkf_chechk, $extern_check );
                     } 
                     as400->dscnnectdb($dbh);
                }
                
            }elsif ($zkf == 235) {
                $dbh = as400->cnnectdb(235);
                my ($zkf_chechk, $extern_check) = as400->search_contract($dbh,235,$agresso_nr);
                if ($zkf_chechk == 235 and $extern_check != 0) {
                    my $BA_fil = "libsxfil35.VMOBBA";
                    as400->insert_bestaande_aandoening($dbh,$BA_fil, $extern_check,$gkd_ba);
                    as400->dscnnectdb($dbh);
                }else {
                     as400->dscnnectdb($dbh);
                     $dbh = as400->cnnectdb(203);
                     my ($zkf_chechk, $extern_check) = as400->search_contract($dbh,203,$agresso_nr);
                     if ($zkf_chechk == 203 and $extern_check != 0) {
                          my $BA_fil = "libsxfil03.VMOBBA";                
                          as400->insert_bestaande_aandoening($dbh,$BA_fil,$extern_check,$gkd_ba);
                          as400->set_correct_zkf_exit_in_ascard($dbh, $agresso_nr, $zkf_chechk, $extern_check );
                        }
                     as400->dscnnectdb($dbh);
                }
            }
         }
        eval { my $gkd_ez =  $klant->{$agresso_nr}->{GKD_tekst_ziekte}};
        if (!$@ and defined $klant->{$agresso_nr}->{GKD_tekst_ziekte}) {
            my $gkd_ez =  $klant->{$agresso_nr}->{GKD_tekst_ziekte};
            print "EZ $agresso_nr $zkf  my $gkd_ez\n";
            my $string_len = length($gkd_ez);
            if ($string_len > 95) {
                $gkd_ez = substr($gkd_ez,0,95);
                print "EZ -> VERKORT $agresso_nr $zkf  my $gkd_ez\n";
            }
             if ($zkf == 203) {
                $dbh = as400->cnnectdb(203);
                my ($zkf_chechk, $extern_check) = as400->search_contract($dbh,203,$agresso_nr);
                 if ($zkf_chechk == 203 and $extern_check != 0) {
                    my $EZ_fil = "libsxfil03.VMOBEZ";
                    as400->insert_ernstige_ziekte($dbh,$EZ_fil,$extern_check,$gkd_ez);
                    as400->dscnnectdb($dbh);
                 }else{
                     $dbh = as400->cnnectdb(235);
                     ($zkf_chechk, $extern_check) = as400->search_contract($dbh,235,$agresso_nr);
                     if ($zkf_chechk == 235 and $extern_check != 0) {
                        my $EZ_fil = "libsxfil35.VMOBEZ";
                        as400->insert_ernstige_ziekte($dbh,$EZ_fil,$extern_check,$gkd_ez);
                        as400->set_correct_zkf_exit_in_ascard($dbh, $agresso_nr, $zkf_chechk, $extern_check );
                     }
                     as400->dscnnectdb($dbh);
                 }
                
            }elsif ($zkf == 235) {                
                $dbh = as400->cnnectdb(235);
                my ($zkf_chechk, $extern_check) = as400->search_contract($dbh,235,$agresso_nr);
                if ($zkf_chechk == 235 and $extern_check != 0) {
                    my $EZ_fil = "libsxfil35.VMOBEZ";
                    as400->insert_ernstige_ziekte($dbh,$EZ_fil,$extern_check,$gkd_ez);
                    as400->dscnnectdb($dbh);
                }else {
                    $dbh = as400->cnnectdb(203);
                    ($zkf_chechk, $extern_check) = as400->search_contract($dbh,203,$agresso_nr);
                    if ($zkf_chechk == 203 and $extern_check != 0) {
                        my $EZ_fil = "libsxfil03.VMOBEZ";
                        as400->insert_ernstige_ziekte($dbh,$EZ_fil,$extern_check,$gkd_ez);
                        as400->set_correct_zkf_exit_in_ascard($dbh, $agresso_nr, $zkf_chechk, $extern_check );
                    }
                    as400->dscnnectdb($dbh); 
                }
            }             
        }
        
     }
package as400;
     use DBD::ODBC;
     use DBI;
     use MIME::Base64;
     sub extern_nummer {
         my ($class,$Agresso_nummer) = @_; # tzst
         my $ascard_fil = "libcxcom20.ASCARD",
         my $dbh = as400->cnnectdb(203);
         my $zoekextern;
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
         my $sql =("SELECT ZKF,EXID52, AGRESONR FROM $ascard_fil") ;
         my $sth = $dbh->prepare($sql);
         $sth->execute();
         while (my @omzetting = $sth->fetchrow_array) {
              $zoekextern->{$omzetting[2]}->{exid} = $omzetting[1];
              $zoekextern->{$omzetting[2]}->{zkf} = $omzetting[0];
            }
         #my ($ZKF,$EXID52) =$dbh->selectrow_array("SELECT ZKF,EXID52 FROM $ascard_fil WHERE AGRESONR = $Agresso_nummer");
         as400->dscnnectdb($dbh);
         return ($zoekextern);
        }
     sub cnnectdb {
         use strict;
         use DBD::ODBC;
         use DBI;
         my ($self,$zkf_nr) = @_;
         my $user_name= $main::agresso_instellingen->{AS400_settings}->{"ZKF$zkf_nr"}->{username};     	     #username as400
         my $password=decrypt->new($main::agresso_instellingen->{AS400_settings}->{"ZKF$zkf_nr"}->{password});              #paswoord
         my $as400= $main::agresso_instellingen->{AS400_settings}->{"ZKF$zkf_nr"}->{as400_name};                 #naam as400
         my $DSN="driver={iSeries Access ODBC Driver};System=$as400";
         # connect to database
         #
         my $dbh = DBI->connect("dbi:ODBC:$DSN",$user_name,$password) or main->wrong_password ;
         #
         #  dbh->disconnect;
         return ($dbh)
        }
     sub dscnnectdb {
         my ($self,$dbh)= @_;
         $dbh->disconnect;
        } 
     sub insert_bestaande_aandoening {
        my ($self, $dbh, $BA_fil,$exid, $text) = @_;
        #$BA_fil = "libsxfil03.VMOBBA",
        my $zetin = ("INSERT INTO $BA_fil values (?,?) ");
        my $sth= $dbh ->prepare($zetin);
        $sth->bind_param(1,$exid);
        $sth->bind_param(2,$text);
        $sth -> execute();
        $sth -> finish();
     }
     sub insert_ernstige_ziekte {
        my ($self, $dbh, $ZIEKTE_fil,$exid, $text) = @_;
        #$BA_fil = "libsxfil03.VMOBBA",
        my $zetin = ("INSERT INTO $ZIEKTE_fil values (?,?) ");
        my $sth= $dbh ->prepare($zetin);
        $sth->bind_param(1,$exid);
        $sth->bind_param(2,$text);
        $sth -> execute();
        $sth -> finish();
     }
     sub delete_aandoeningen {
        my ($self, $dbh, $BA_fil) = @_;
        my $delete = ("DELETE FROM $BA_fil");
        my $sth= $dbh ->prepare($delete);
        $sth -> execute();
        $sth -> finish();
     }
     sub delete_ziekte {
        my ($self, $dbh, $ZIEK_fil) = @_;
        my $delete = ("DELETE FROM $ZIEK_fil");
        my $sth= $dbh ->prepare($delete);
        $sth -> execute();
        $sth -> finish();
     }
     
     sub search_contract {
        my ($self,$dbh,$zkf,$agresso_nr) = @_;
        my $ZKF_TEXT = "ZKF$zkf";
        my $link = $main::agresso_instellingen->{'AS400_settings'}->{$ZKF_TEXT};
        my $verzekeringen =  $main::agresso_instellingen->{'verzekeringen'}->{$ZKF_TEXT};
        my $placeholders = "";
        my $teller =0;
        for my $verz (sort keys $verzekeringen) {
            if (uc($verz) ne "HOSPIFORFAIT"){
                #print "$teller $verz $verzekeringen->{$verz}\n";
                if ($teller == 0) {
                   $placeholders = "$verzekeringen->{$verz}";               
                }else {
                   $placeholders = $placeholders.","."$verzekeringen->{$verz}";
                }
               $teller +=1;
            }
        }
        #my $placeholders = join ",", (@{$verzekeringen});
        my $ASCARD="$link->{libcxcom}\.ASCARD";
        my $PFYSL8= "$link->{libcxfil}\.PFYSL8";
        my $PHOEKK= "$link->{libcxfil}\.PHOEKK";
        my $PADRJR = "$link->{libcxfil}\.PADRJR";
        my $PTAXKQ = "$link->{libcxfil}\.PTAXKQ";
        my $PPADKO =  "$link->{libcxfil}\.PPADKO";
        print("");
        my $sql =("SELECT b.IDFDKK,a.AGRESONR,a.KNRN52,a.ZKF,c.EXIDL8,
                       b.ABTVKK,b.ABPRKK,b.ABADKK,b.ABPEKK,b.ABEDKK,b.ABNOKK,a.ZKF,b.ABACKK,b.AB2AKK,b.ABOCKK,b.AB2OKK,
                       c.NAMBL8,c.PRNBL8,b.ABCTKK
                       FROM $ASCARD a
                       JOIN $PFYSL8 c ON a.KNRN52 = c.KNRNL8 
                       JOIN $PHOEKK  b ON c.EXIDL8=b.EXIDKK
                       WHERE a.KNRN52 != 0 and AGRESONR = $agresso_nr and b.ABTVKK IN ($placeholders)
                       and b.ABADKK < $main::vandaag and b.ABEDKK > $main::vandaag and b.ABOCKK = ''
                       ORDER BY a.AGRESONR,b.ABTVKK ASC" );#fetch first 10 rows only a.KNRN52 != 0 AGRESONR != 0
        my $sth = $dbh->prepare( $sql );
        $sth ->execute();
        my $zkf_found = 0;
        my $extern_found = 0;
        while(my @agresso_klant =$sth->fetchrow_array)  {
            $zkf_found  = $agresso_klant[0];
            $extern_found =  $agresso_klant[4];
        }    
        return($zkf_found, $extern_found);   
     }
     sub set_correct_zkf_exit_in_ascard {
         my ($self,$dbh,$agresso_nr,$zkf,$exid ) = @_;
         my $ZKF_TEXT = "ZKF$zkf";
         my $link = $main::agresso_instellingen->{'AS400_settings'}->{$ZKF_TEXT};
         my $ASCARD="$link->{libcxcom}\.ASCARD";
         my $sql =("UPDATE $ASCARD SET ZKF = $zkf, EXID52= $exid  WHERE AGRESONR = $agresso_nr");
         my $sth = $dbh->prepare( $sql );
         $sth ->execute();
         
     }
package sql_toegang_agresso;
      sub setup_mssql_connectie {
        my ($self,$mode_con) = @_;
        my $dbh_mssql;
        my $dsn_mssql;
        my $user = 'HOSPIPLUS';
        my $passwd = 'ihuho4sdxn';      
        $dsn_mssql = join "", (
         "dbi:ODBC:",
         "Driver={SQL Server};",
         "Server=S000WP1XXLSQL01.mutworld.be\\i200;", # nieuwe database server 2016 05
         #"Server=S998XXLSQL01.CPC998.BE\\i200;",
         "UID=HOSPIPLUS;",
         "PWD=ihuho4sdxn;",
          "Database=agrprod",            
        );
        my $db_options = {
            PrintError => 1,
            RaiseError => 1,
            AutoCommit => 1, #0 werkt niet in
            LongReadLen =>2000,
        };   
       $dbh_mssql = DBI->connect($dsn_mssql, $user, $passwd, $db_options) or exit_msg("Can't connect: $DBI::errstr");
       return ($dbh_mssql)
      }
    # sub setup_mssql_connectie {
    #      my $mode = $main::mode;
    #      my $database;
    #      $database = $main::agresso_instellingen->{"Agresso_Database_$mode"};          
    #      my $ip = $main::agresso_instellingen->{"Agresso_SQL_$mode"};
    #      my $dbh_mssql;
    #      my $dsn_mssql = join "", (
    #          "dbi:ODBC:",
    #          "Driver={SQL Server};",
    #          #"Server=S998XXLSQL01.CPC998.BE\\i200;",
    #          "Server=$ip;", # nieuwe database server 2016 05 S000WP1XXLSQL01.mutworld.be\i200
    #          "UID=HOSPIPLUS;",
    #          "PWD=ihuho4sdxn;",
    #          "Database=$database",
    #          #"Database=agraccept",
    #         );
    #       my $user = 'HOSPIPLUS';
    #       my $passwd = 'ihuho4sdxn';
    #      
    #       my $db_options = {
    #          PrintError => 1,
    #          RaiseError => 1,
    #          AutoCommit => 1, #0 werkt niet in
    #          LongReadLen =>2000,
    # 
    #         };
    #      #
    #      # connect to database
    #      #
    #      $dbh_mssql = DBI->connect($dsn_mssql, $user, $passwd, $db_options) or exit_msg("Can't connect: $DBI::errstr");
    #      return ($dbh_mssql)
    #}
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
        sub afxvmobaandoen_get_rows {
             my ($class,$dbh) = @_;
             my $client ='VMOB';
             my $sql =("SELECT a.line_no,a.product,a.aandoening,a.begindatum,a.einddatum,a.last_update,a.user_id,a.dim_value,b.ext_apar_ref
                      FROM afxvmobaandoen a JOIN acuheader b on a.client = b.client and a.dim_value = b.apar_id WHERE a.client = '$client' and a.einddatum > getdate()
                      "); #and a.dim_value  = 100266
             my $sth = $dbh->prepare($sql);
             $sth->execute();
             my $nr=0;
             while (my @aandoeningen = $sth->fetchrow_array) {
                 my $inz = $aandoeningen[8];
                 my $agressonr =  $aandoeningen[7];
                 $nr = $aandoeningen[0];
                 $main::klant->{$agressonr}->{aandoeningen}->[$nr]->{verzekering} = $aandoeningen[1];
                 $main::klant->{$agressonr}->{aandoeningen}->[$nr]->{aandoening}= $aandoeningen[2];
                 $main::klant->{$agressonr}->{aandoeningen}->[$nr]->{verzekering} = $aandoeningen[1];
                 $main::klant->{$agressonr}->{aandoeningen}->[$nr]->{aandoening}= $aandoeningen[2];
                 my $begindatum = $aandoeningen[3];
                 $begindatum = substr ($begindatum,0,10);
                 my @begindat = split (/\-/,$begindatum);
                 $main::klant->{$agressonr}->{aandoeningen}->[$nr]->{begindatum} =$begindat[2]."-".$begindat[1]."-".$begindat[0];
                 my $einddatum = $aandoeningen[4];
                 $einddatum = substr ($einddatum,0,10);
                 my @einddat = split (/\-/,$einddatum);
                 $main::klant->{$agressonr}->{aandoeningen}->[$nr]->{einddatum}=$einddat[2]."-".$einddat[1]."-".$einddat[0];
             }
        }
        sub afxvmobziekten_get_rows {
             my ($class,$dbh) = @_;
             my $client ='VMOB';
             my $sql =("SELECT a.line_no,a.product,a.ziekte,a.last_update,a.user_id,a.dim_value,b.ext_apar_ref
                      FROM afxvmobziekten a JOIN acuheader b on a.client = b.client and a.dim_value = b.apar_id WHERE a.client = '$client'
                      "); #and a.dim_value  = 100266
             my $sth = $dbh->prepare($sql);
             $sth->execute();
             my $nr=0;
             while (my @aandoeningen = $sth->fetchrow_array) {
                 my $inz = $aandoeningen[6];
                 my $agressonr =  $aandoeningen[5];
                 $nr = $aandoeningen[0];
                 $main::klant->{$agressonr}->{ziekten}->[$nr]->{verzekering} = $aandoeningen[1];
                 $main::klant->{$agressonr}->{ziekten}->[$nr]->{ziekte}= $aandoeningen[2];
                }
            }