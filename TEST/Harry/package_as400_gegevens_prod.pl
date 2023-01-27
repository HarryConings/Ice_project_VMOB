#!/usr/bin/perl -w
use strict;


package as400_gegevens;
#require "settings.pl";
#require "cnnectdb.pl";
require 'package_settings_prod.pl';
require 'package_cnnectdb_prod.pl';
#require 'package_as400_gegevens_prod.pl';
our $settings;

sub  get_assurcard_info_rijksregnr {
     my ($class,$rijksregnr) = @_ ;
     $settings= settings->new(203);
     my $dbh = connectdb->connect_as400($settings->{user_name},$settings->{password},$settings->{name_as400});
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
     my @ascard_info = $dbh->selectrow_array("SELECT ZKF,EXID52,CARDNR,CREDAT,OKNOW,EINCON,LOSTCARD  FROM $settings->{'ascard_fil'} WHERE KNRN52 =$rijksregnr");
     $main::klant->{Ziekenfonds} = $ascard_info[0];
     $main::klant->{ExternNummer} = $ascard_info[1];
     $main::klant->{AssurcardNummer} = $ascard_info[2];
     $main::klant->{Assurcard_Creatie_datum} = $ascard_info[3];
     $main::klant->{Verloren_kaart}=$ascard_info[6];
     if ($ascard_info[4] =~ m/Y/i) {
          $main::klant->{Assurcard_OK} = "GROEN";
     }else {
         $main::klant->{Assurcard_OK} = "ROOD";
     }
     $main::klant->{Assurcard_Einddatum} = $ascard_info[5];
}
sub card_lost {
     #card_lost (rijkregisternr,dbh)
      my ($class,$rijksregnr) = @_ ;
      $settings= settings->new(203);
      my $dbh = connectdb->connect_as400($settings->{user_name},$settings->{password},$settings->{name_as400});
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
     #ONTSLAGO  VARCHAR(1) Y = onderzozk of het om een onstlag gaat contract xml N = niets doen
     #CXMLINIT VARCHAR(1) Y = deze is al opgenomen in contract xml N = moet nog doorgestuurd worden
     #CXMLUPDA VARCHAR(1) Y = er is iets veranderd en deze moet doorgestuurd N = moet niet doorgestuurd worden
      #WANBET VARCHAR(1) Y = het is een wanbetaler kaart geblokkeerd N = geen wanbetaler kaart niet geblokkeerd
     my $updatethis = $dbh ->do("UPDATE $settings->{'ascard_fil'} set (LOSTCARD ) = (1) WHERE KNRN52= $rijksregnr");
    }


sub zet_history_gkd_in {
      my ($class,$commentaar)  =  @_;
      my $ext_nr = $main::klant->{ExternNummer};
      my $zkf = $main::klant->{Ziekenfonds};
      if (!defined $ext_nr or !defined $zkf) {
           return ('kies lid');#code
          }
      if ($main::mode eq 'PROG') {
            #&settings($zkf);
               $settings= settings->new($zkf);
               my $dbh = connectdb->connect_as400($settings->{user_name},$settings->{password},$settings->{name_as400});
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
              #my $dbh = &cnnectdb ($settings->{user_name},$settings->{password},$settings->{name_as400});
              my $volgnummer1 = $dbh->selectrow_array ("SELECT CONTACTID FROM $settings->{'gkd_hist_fil'} WHERE ORG =  $settings->{'zkfnummer'} ORDER BY CONTACTID DESC");
              $volgnummer1 +=1 ;
              my $volgnummer =$dbh->selectrow_array ("SELECT counter FROM $settings->{'gkd_contactId_fil'} WHERE org = $settings->{'zkfnummer'} ORDER BY counter DESC");
               $volgnummer = $volgnummer - $settings->{'zkfnummer'}*10000000000;
               $volgnummer = $volgnummer*1;
               print "volgnummer1 $volgnummer1 ->volgnummer $volgnummer\n";
                my $sth ;
                my $max_insert =1;
                until ($volgnummer1 <= $volgnummer) {
                my $volgnr = ("SELECT counter FROM NEW TABLE(insert into $settings->{'gkd_contactId_fil'} (org, TECHVERSIONNUMBER, TECHCREATIONUSER, TECHLASTUPDATEUSER) 
                values ($settings->{'zkfnummer'}, 1,'$settings->{user_name}','$settings->{user_name}'))");
                $sth = $dbh ->prepare($volgnr);
                $sth -> execute();
                    while(my $volg=$sth->fetchrow_array)  {
                         $volgnummer =$volg;
                         print "$volgnummer\n";
                    }
                $volgnummer = $volgnummer - $settings->{'zkfnummer'}*10000000000;
                $volgnummer = $volgnummer*1;
                print "$max_insert : $volgnummer\n";
                $max_insert +=1 ;
                last if ($max_insert >=10);
               }
          
              my $zetin = "INSERT INTO $settings->{'gkd_hist_fil'} values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
              $sth = $dbh ->prepare($zetin);
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
                  $sth -> execute();
                  $sth -> finish();
                  connectdb->disconnect($dbh);
          }else {
            print 'TEST geen GKD';
          }
     

}

sub lees_history_gkd {
     my ($class,$frame) = @_;
     my $ext_nr = $main::klant->{ExternNummer};
     print "\n\nextern nummer= $ext_nr\n________________\n";
     my $zkf = $main::klant->{Ziekenfonds};
     if (!defined $ext_nr or !defined $zkf) {
           return ('kies lid');#code
     }
      $settings= settings->new($zkf);
      my $dbh = connectdb->connect_as400($settings->{user_name},$settings->{password},$settings->{name_as400});
     #&settings($zkf);
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
     #my $dbh = &cnnectdb ($settings->{user_name},$settings->{password},$settings->{name_as400});
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
       connectdb->disconnect($dbh);
      
        return ('ok');
}
sub lees_history_gkd_agresso_order {
     my ($class,$text) = @_;
     my $ext_nr = $main::klant->{ExternNummer};
     my $zkf = $main::klant->{Ziekenfonds};
     if (!defined $ext_nr or !defined $zkf) {
           return ('kies lid');#code
     }
      $settings= settings->new($zkf);
      my $dbh = connectdb->connect_as400($settings->{user_name},$settings->{password},$settings->{name_as400});
     #&settings($zkf);
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
     #my $dbh = &cnnectdb ($settings->{user_name},$settings->{password},$settings->{name_as400});
     my $sql =("SELECT COMMENT,TARGETID,TECHCREATIONDATE,TECHCREATIONUSER FROM $settings->{'gkd_hist_fil'} WHERE TARGETID= $ext_nr and TECHCREATIONUSER = 'HOSI' and
               (substr(char(TECHCREATIONDATE),1,10) = '$checkdate' or substr(char(TECHCREATIONDATE),1,10) = '$check_gisteren') "); #and TECHCREATIONDATE='$tech_creation_date' 
     my $sth = $dbh->prepare( $sql );
     $sth->execute();
     my $staat_er_al_in = 'nee';
     #my $test = $main::gkd_commentaar;
     while(my @mijncomment =$sth->fetchrow_array)  {
       $staat_er_al_in = 'ja' if ( $mijncomment[0] eq $text); ;
     }        
     connectdb->disconnect($dbh);      
     return ($staat_er_al_in);
}
sub maf_omzetting_newid {
       my ($class,$zkf,$inz,$geboortedatum,$instellingen) = @_;
             # PFNSO8          LIBCXCOM20       
             #Prty  A/D   Field                 Description                       
             #A.INNSO8              NUMERO INTERNE NS       /INTER    
             #A.ENRNO8              NO.REG.NAT              /NAT.R    
             #A.NAAMO8              NOM                     /NAAM     
             #A.VRNMO8              VOORNAAM                /VOORN    
             #A.NAIDO8              DATE DE NAISSANCE DU BEN/GEBOO    
             #A.SEXEO8              CODE SEXE DU BENEFIC.   /KODE     
             #A.FONAO8              NOM FONETIQUE           /FONET    
             #A.FOVNO8              PRENOM FONETIQUE        /FONET    
             #A.FNAVO8              NOM PRENOM FONETIQUE    /FONET    
             #A.FASIO8              FASE INTEGRATION FED    /FASE     
             #A.DUBAO8              REGISTRE D'INTEGRATION / REGIS    
             #A.DTMJO8              DT DERN. MAJ SIGNAL. BEN/DATUM    
             #A.GESTO8              IDENTIFICATION GESTION. /IDENT
             
       my $dbh = connectdb->connect_as400($instellingen->{as400}->{$zkf}->{username},$instellingen->{as400}->{$zkf}->{password},$instellingen->{as400}->{$zkf}->{as400_name});
       my $library = $instellingen->{as400}->{$zkf}->{libcxcom};
       my $file = "$library.PFNSO8";
       my $eeuw = $geboortedatum;
       $eeuw = substr ($geboortedatum,0,2);
       my $inz_eeuw = $eeuw*100000000000;
       $inz_eeuw  += $inz;
       my @antwoord = $dbh->selectrow_array("SELECT INNSO8,ENRNO8,NAAMO8,VRNMO8  FROM $file WHERE ENRNO8 = $inz_eeuw");
       print "@antwoord\n";
       connectdb->disconnect($dbh);
       return ($antwoord[0]);
}
sub get_betaalde_bedragen_vp { #maf
       my ($class,$zkf,$ext,$instellingen,$berekeningsjaren) = @_;
      #SELECT * FROM libcxcom20/Pptmc8 WHERE IDFDC8 = 203 and IDMTC8 = 01 and IDNOC8 = 004784 and XB80C8 = 2014                             
          #Field                 Description                      
          #IDFDC8              NUMERO MUTUELLE         /NUMME   
          #IDMTC8              NUMERO MUTUELLE DU BEN  /NUMME   
          #IDNOC8              NUMERO MATRICULE DU BEN /STAMN   
          #IDNSC8              NUMERO DE BENEFICIAIRE  /VOLGN   
          #XB84C8              AN TARIFICATION         /TARIF   
          #XB80C8              ANNEE PRESTATION        /JAAR    
          #DVORC8              DEVISE ORIGINE /ORIGINELE MUNT   
          #DVRPC8              DEVISE REPORTING / REPORTING M   
          #A140C8              DATE DERNIERE MAJ       /DATUM   
          #RG02C8              MONTANT PLAFOND T.M AO           
          #SG02C8              MT REPORTING PLAFOND T.M AO      
          #RG03C8              MONTANT PLAFOND T.M AL           
          #SG03C8              MT REPORTING PLAFOND T.M AL      
          #Field                 Description                      
          #RG04C8              MONTANT INTRO MÉNAGE A0          
          #SG04C8              MT REPORTING INTRO MÉNAGE A0     
          #RG05C8              MONTANT INTRO MÉNAGE AL          
          #SG05C8              MT REPORTING INTRO MÉNAGE AL     
          #RG06C8              MONTANT REMBOURSÉ EN AO          
          #SG06C8              MT REPORTING REMBOURSÉ EN AO     
          #GD05C8              MONT PLAFOND T.M.AO (AN+1)       
          #SD05C8              MT REPOPTING PLAFOND T.M.  AO    
          #GD06C8              MONT PLAFOND T.M.AL (AN+1)       
          #SD06C8              MT REPOPTING PLAFOND T.M.  AL    
          #GD07C8              MONT REMBOURSÉ EN AO(AN+1)       
          #SD07C8              MT REPORT REMBOURSÉ AO(AN+1)     
          #GD08C8              MONT PLAFOND T.M. AO FRANCHISE   
          #eld                 Description                      
          #SD08C8              MT REPORTING PLAFOND T.M. AO F   
          #GD09C8              MONT PLAFOND T.M. AL FRANCHISE   
          #SD09C8              MT REPORTING PLAFOND T.M. AL F   
          #GD10C8              MONT INTROD.MENAGE AO FRANCHIS   
          #SD10C8              MT REPORT INTROD.MENAGE AO FRA   
          #GD11C8              MONT INTROD.MENAGE AL FRANCHIS   
          #SD11C8              MT REPORT INTROD.MENAGE AL FRA   
          #GD12C8              MONT PLAFOND T.M. AO FRANCHISE   
          #SD12C8              MT REPORT PLAFOND T.M AO FRANC   
          #GD13C8              MONT PLAFOND T.M. AL FRANCHISE   
          #SD13C8              MT REPORT PLAFOND T.M AL FRANC   
          #RG07C8              CD.ATTESTATION ENVOYE   / KD.G   
          #GESTC8              IDENTIFICATION GESTION. /IDENT   
          #eld                 Description                      
          #GFDIC8              CD GFDI                 /CD GF   
          #EXIDC8              NUMERO EXTERNE          /EXTER   
          #TMMCC8              MT FORF.MAL.CHRON.MUTATION       
          #SD14C8              MT REP. FORF.MAL.CHRON.MUTAT.
       #my $ext =  as400_gegevens->give_extern_nummer($zkf,$inz,$instellingen);  
       my $dbh = connectdb->connect_as400($instellingen->{as400}->{$zkf}->{username},$instellingen->{as400}->{$zkf}->{password},$instellingen->{as400}->{$zkf}->{as400_name});
       my $library = $instellingen->{as400}->{$zkf}->{libcxcom};
       my $file = "$library.Pptmc8";                                          
       my $sql =("SELECT XB84C8,XB80C8,RG02C8,RG06C8,SG02C8,SG06C8,RG04C8,GD08C8  FROM $file WHERE IDFDC8 = $zkf and EXIDC8 = $ext and XB84C8 IN ($berekeningsjaren)");  
       my $sth = $dbh->prepare( $sql );
       $sth->execute();
       my $terugbetalingen;
       print "\n";
       my $mailmsg = "";
       while(my @rij =$sth->fetchrow_array)  {
            print "as400\t\t\t@rij\n";
            $mailmsg = $mailmsg."\tas400 betaling \t @rij\n";
            my $jaar = "$rij[1]\-$rij[0]";
            $terugbetalingen->{$jaar}->{tarrificatie_jaar}= $rij[0];
            $terugbetalingen->{$jaar}->{prestatie_jaar}= $rij[1];
            $terugbetalingen->{$jaar}->{bedrag_VP}= $rij[2] + $rij[6]+ $rij[7];
            $terugbetalingen->{$jaar}->{bedrag_terugbetaald}= $rij[3];
            
          }
       #print "einde\n";
       connectdb->disconnect($dbh);
       return ($terugbetalingen,$mailmsg);
}
sub get_plafond_vp {
      my ($class,$zkf,$ext,$instellingen,$berekeningsjaren) = @_;
      #SELECT * FROM libcxcom20/Psmabg WHERE IDFDBG = 203 and EXIDBG = 0010047840178
      #.IDFDBG              NUMERO MUTUELLE         /NUMME   
      #.EXIDBG              NUMERO EXTERNE          /EXTER   
      #.ABVDBG              DATE DEBUT              /DATUM   
      #.ABTDBG              DATE FIN                /DATUM   
      #.ABDWBG              CODE SPECIFIEK GEGEVEN FP/CODE   
      #.ABDZBG              WAARDE SPECIFIEK GEGEVEN FP/VA   
      #.A140BG              DATE DERNIERE MAJ       /DATUM   
      #.GESTBG              IDENTIFICATION GESTION. /IDENT   
      #.GFDIBG              CD GFDI                 /CD GF
      my @berekeningdata = split /\,/,$berekeningsjaren;
      $berekeningsjaren = "$berekeningdata[0]"."0101,$berekeningdata[1]"."0101,$berekeningdata[2]"."0101";
      my $dbh = connectdb->connect_as400($instellingen->{as400}->{$zkf}->{username},$instellingen->{as400}->{$zkf}->{password},$instellingen->{as400}->{$zkf}->{as400_name});
      my $library = $instellingen->{as400}->{$zkf}->{libcxcom};
      my $file = "$library.Psmabg";                                          
       my $sql =("SELECT  ABVDBG,ABTDBG,ABDWBG,ABDZBG FROM $file WHERE IDFDBG  = $zkf and EXIDBG = $ext and ABVDBG IN ($berekeningsjaren)" );  
       my $sth = $dbh->prepare( $sql );
       $sth->execute();
       my $plafond;
       my $mailmsg = "as400 plafond\n";
       print "as400 plafond\n";
       while(my @rij =$sth->fetchrow_array)  {
          my $jaar = substr($rij[0],0,4);
          if (!defined $plafond->{$jaar}->{einddatum} or  $plafond->{$jaar}->{einddatum} <  $rij[1]) {
                 $plafond->{$jaar}->{begindatum} = $rij[0];
                 $plafond->{$jaar}->{einddatum} = $rij[1];
                 $plafond->{$jaar}->{soort} = $rij[2];
                 $plafond->{$jaar}->{bedrag} =$rij[3]/100;
                 $mailmsg = $mailmsg."\tas400 plafond\t @rij\n";
                 print "@rij\n";
               }          
           
          }
       $mailmsg = "gedaan as400 plafond\n";
       print "gedaan as400 plafond\n";
      connectdb->disconnect($dbh); 
      #print '';
      return($plafond,$mailmsg);
}
sub give_extern_nummer {
          my ($class,$zkf,$inz,$instellingen) = @_;
          #openen van PFYSL8
          # EXIDL8 = extern nummer
          # KNRNL8 = nationaalt register nummer
          # NAMBL8 = naam van de gerechtigde
          # PRNBL8 = voornaam van de gerechtigde
          # SEXEL8 = code van het geslacht $naamrij[4]
          # NAIYL8 = geboortejaat
          # NAIML8 = geboortemaand
          # NAIJL8 = geboortedag
          # LANGL8 = taal code $naamrij[9]
          my $dbh = connectdb->connect_as400($instellingen->{as400}->{$zkf}->{username},$instellingen->{as400}->{$zkf}->{password},$instellingen->{as400}->{$zkf}->{as400_name});
          my $library = $instellingen->{as400}->{$zkf}->{libcxfil};
          my $file = "$library.PFYSL8";     
          my $ext = $dbh->selectrow_array("SELECT EXIDL8 FROM $file WHERE KNRNL8=$inz");
          connectdb->disconnect($dbh);
          return ($ext);

}

1;
