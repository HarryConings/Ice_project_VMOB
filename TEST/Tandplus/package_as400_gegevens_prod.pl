#!/usr/bin/perl -w
#OPGELET!!!!!!
#Dit programma is auteursrechtelijk beschermd.
#Deze code is volledig eigendom van de Firma  I.C.E. (liebroekstraat 43 3545 Halen BE0446888007) .
#Deze code mag enkel gebruikt worden met jaarlijkse toestemming van Harry Conings 0475464286 harry@ice.be harry@icebutler.com
#Indien dit toch gebeurt is er een boete verschuldigd van 250.000 EUR exclusief btw aan de Firma  I.C.E.
#Deze code mag niet aan derden (ook niet VNZ en NZVL) getoond worden tenzij met uitdrukkelijke en schriftelijke toestemming van I.C.E. bvba .
#Indien dit toch gebeurt is er een boete verschuldigd van 250.000 EUR exclusief btw aan de Firma  I.C.E.
#Dit geldt ook voor het kopieren van een stuk code of het repliceren van technieken gehanteerd in dit programma
#I.C.E. beheert de broncode je mag geen veranderingen aanbrengen aan het programma .

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
              my $volgnummer = $dbh->selectrow_array ("SELECT CONTACTID FROM $settings->{'gkd_hist_fil'} WHERE ORG =  $settings->{'zkfnummer'} ORDER BY CONTACTID DESC");
              $volgnummer +=1 ;
              my $zetin = "INSERT INTO $settings->{'gkd_hist_fil'} values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
              my $sth = $dbh ->prepare($zetin);
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
       my $zkf1 = "ZKF$zkf" if ($zkf !~ m/^ZKF/);
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
       my $dbh = connectdb->connect_as400($instellingen->{as400}->{$zkf1}->{username},$instellingen->{as400}->{$zkf1}->{password},$instellingen->{as400}->{$zkf1}->{as400_name});
       my $library = $instellingen->{as400}->{$zkf1}->{libcxcom};
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
      my $zkf1 = "ZKF$zkf" if ($zkf !~ m/^ZKF/);
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
      my $dbh = connectdb->connect_as400($instellingen->{as400}->{$zkf1}->{username},$instellingen->{as400}->{$zkf1}->{password},$instellingen->{as400}->{$zkf1}->{as400_name});
      my $library = $instellingen->{as400}->{$zkf1}->{libcxcom};
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
          my $zkf1 = "ZKF$zkf" if ($zkf !~ m/^ZKF/);
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
          my $dbh = connectdb->connect_as400($instellingen->{as400}->{$zkf1}->{username},$instellingen->{as400}->{$zkf1}->{password},$instellingen->{as400}->{$zkf1}->{as400_name});
          my $library = $instellingen->{as400}->{$zkf1}->{libcxfil};
          my $file = "$library.PFYSL8";     
          my ($ext,$geboortejaar,$geboorte_maand) = $dbh->selectrow_array("SELECT EXIDL8,NAIYL8,NAIML8 FROM $file WHERE KNRNL8=$inz");
          connectdb->disconnect($dbh);
          return ($ext,$geboortejaar,$geboorte_maand);

}

sub get_remgelden_tandplus_vp { #tandplus
       my ($class,$zkf,$ext,$instellingen,$berekeningsjaren,$agresso_instellingen,$klant) = @_;
       my @remgeld_nomenclaturen = split (/,/,"$agresso_instellingen->{Tandplus_remgeld_nomeclaturen}");
       foreach my $teller (keys @remgeld_nomenclaturen) {
           $remgeld_nomenclaturen[$teller] =~ s/\n//g;
           $remgeld_nomenclaturen[$teller] =~ s/\t//g;
       }
       my $placeholders = join ",", (@remgeld_nomenclaturen);       
       my $zkf1 = "ZKF$zkf" if ($zkf !~ m/^ZKF/);
       my $kwijtingen;
       my $kwijtingen_archief;
       my $kwijtingen_prestatie_jaar;
       my $kwijtingen_prestatie_jaar_archief;       
       my $ContactDatumsTandplus;     
       my $berekenen = 'no';
       my $cont_teller=0;
       foreach my $nr_cont (keys $klant->{contracten}) {
          eval { if ($klant->{contracten}->[$nr_cont]->{naam} =~ m/TANDPLUS/i) {}};
          if (!$@) {
               if ($klant->{contracten}->[$nr_cont]->{naam} =~ m/TANDPLUS/i) {
                    my $tempstart =$klant->{contracten}->[$nr_cont]->{startdatum};
                    my ($startdag,$startmaand,$startjaar) = split(/\//,$tempstart);
                    my $tempwacht =$klant->{contracten}->[$nr_cont]->{wachtdatum};
                    my ($wachtdag,$wachtmaand,$wachtjaar) = split(/\//,$tempwacht);
                    my $tempeind =$klant->{contracten}->[$nr_cont]->{einddatum};
                    my ($einddag,$eindmaand,$eindjaar) = split(/\//,$tempeind);
                    $ContactDatumsTandplus->{$cont_teller}->{startdatum} =$startjaar*10000+$startmaand*100+$startdag;
                    $ContactDatumsTandplus->{$cont_teller}->{wachtdatum} =$wachtjaar*10000+$wachtmaand*100+$wachtdag;
                    $ContactDatumsTandplus->{$cont_teller}->{einddatum} =$eindjaar*10000+$eindmaand*100+$einddag;
                    $cont_teller+=1;
                    print '';
               }
          }
          
       }
       print '';
       #print "geen achief $nrzkfcheck $beginprestdatcheck $eindprestdatcheck $begintarifdatcheck $eindtarifdatcheck $nomenclatuurcheck $onderzoek_file $output_fil \n";
            # we openen LHBE42H in libcxcom om de verstrekker te gaan zoeken
            # IDFD42 = nummer ziekenfonds 
            # XB0942 = jaar basisstuknr
            # XB1042 = oorsprong basisstuk
            # XB1142 = nr basisstuknr
            # XB1242 = lijnnummer basisstuknr
            # YN0142 = nomenclatuurnummer
            # XB8442 = tarrificatiejaar
            # XB3342 = tarrificatiemaand
            # XB3243 = tarrificatiedag
            # XB8042 = prestatiejaar
            # XB0542 = prestatiemaand
            # XB0442 = prestatiedag
            # YP0142 = nummer verstrekker
            # EXID42 = extern nummer
            # XC1842 = ctx veld
            # XD0142 = CODE ETAT PRESTATION    /KODE STAAT VERSTR code geannuleerd is 9 dus er mag geen 9 instaan
            #A.IDFD42                      NUMERO MUTUELLE         /NUMME 
            #A.XB0842                      MOTIF PIECE DE BASE     /MOTIE  --> basistuknr1
            #A.XB0942                      ANNEE PIECE DE BASE     /JAAR  ---> basistuknr2
            #A.XB1042                      ORIGINE PIECE DE BASE   /OORSP ---> basistuknr3
            #A.XB1142                      NO SUITE PIECE DE BASE  /VOLGN ---> basistuknr4
            #A.XB1242                      NO LIGNE PIECE DE BASE  /LIJNN ---> hebben we nodig om de lijnen te voorzien
            #A.YN0142                      CODE NOMENCLATURE       /NOMEN ----> nomenclatuur 
            #A.DVOR42                      DEVISE ORIGINE /ORIGINELE MUNT 
            #A.DVRP42                      DEVISE REPORTING / REPORTING M 
            #A.XB8042                      ANNEE PRESTATION        /JAAR  -->datum 
            #A.XB0542                      MOIS PRESTATION         /MAAND -->datum
            #A.XB0442                      JOUR PRESTATION         /DAG V -->datum  dd//mm/jj
            #A.XB8442                      AN TARIFICATION         /TARIF 
            #A.XB3342                      MS TARIFICATION         /TARIF 
            #A.XB3242                      JR TARIFICATION         /TARIF 
            #A.A14042                      DATE DERNIERE MAJ       /DATUM 
            #A.SSDD42                      DATE ORIGINE MOUVEMENT  /DATUM 
            #A.XB6842                      DATE PRESCRIPTION       /DATUM 
            #A.XB8342                      DATE FIN SEJOUR HOSPITAL/EINDD 
            #A.XB1342                      NOMBRE DE CAS           /AANTA  --> aantal 
            #A.XB1442                      NOMBRE DE JOURS         /AANTA 
            #A.XB1642                      CODE POINT DE CONTROLE  /KODE  
            #A.XB2642                      CODE CONVENTION PRESTAT./KONVE 
            #A.YP0042                      PREF DISPENSAT./               
            #A.YP0142                      NUMERO PRESTATAIRE      /NUMME  --> nummer van de zorgverstrekker daar moeten we de naam gaan zoekne
            #A.XB1742                      NORME PRESTATAIRE       /NORM 
            #A.EABJ42                      PREF N° PRESCRIPT./PREF.VOORSC 
            #A.XB1842                      NO PRESCRIPTEUR         /NR VO 
            #A.XB1942                      NORME PRESCRIPTEUR      /NORM  
            #A.YH0042                      PREF N° HOPITAL./              
            #A.YH0142                      NUMERO D'HOPITAL        /HOSPI 
            #A.YH0742                      NUMERO SERVICE          /DIENS 
            #A.EAA542                      SUFFIXE N° SERVICE / SUFF.DIEN 
            #A.EABH42                      PREF N° LIEU PREST./PREF.PLAAT 
            #A.XB2042                      LIEU DE LA PRESTATION   /PLAAT 
            #A.XB2742                      CODE ASSURANCE S.S.     /VERZE 
            #A.XB2342                      CODE RELATIF            /RELAT 
            #A.BBUR42                      NUM.BUREAU MOUVEMENT 0  /BUREE 
            #A.BSEC42                      NUMERO SECTION MOUVEMENT/SEKTI 
            #A.BGUI42                      NUM GUICHET DU MOUVEMENT/LOKET 
            #A.GEST42                      IDENTIFICATION GESTION. /IDENT 
            #A.XC1842                      NUMERO SUITE CTX MEMBRE /VOLGN 
            #A.XB0142                      CODE TIT. 1 SOINS SANTE /KODE  -->titularis
            #A.XB0242                      CODE TIT.2 SOINS SANTE  /KODEG 
            #A.XD0142                      CODE ETAT PRESTATION    /KODE  
            #A.XC1742                      NO SUITE ACCIDENT       /VOLGN 
            #A.XB4342                      CODE PRODUIT            /KODEP 
            #A.XB4542                      CODE PRESTATION RELATIF /RELAT 
            #A.XB4642                      CODE NORME PLAFOND      /KODE  
            #A.XB4742                      CODE ACCOUCHEMENT       /KODE  
            #A.XB4842                      CODE NUIT,W-E OU NON    /KODEN 
            #A.NN2742                      NUMERO DE REGLE         /NUMME 
            #A.XS1542                      TRIMESTRE 312 BIS       / KWAR 
            #A.XB5642                      TYPE DEPENSE 312BIS     /TYPE  
            #A.ABNO42                      NUMERO DOSSIER          /DOSSI 
            #A.ABMS42                      SOCIETE / MAATSCHPIJ           
            #A.EABR42                      EXCEPTION TIERS PAYANT  /UITZO 
            #A.EABS42                      TRANSPLANTATION         /TRANS 
            #A.EABT42                      CODE EXCEPT. PROPHYLAXIE/UITZO 
            #A.EABU42                      NUMÉRO DE O.T.          /O.T.N 
            #A.EABX42                      COUPES, DENTS, MEMBRES  /SNIJD 
            #A.EABY42                      CODE NORME PRESTATION   /KODE  
            #A.EACA42                      HEURE DE PRESTATION     /UUR V 
            #A.GD1442                      CODE IDENTIFICATION PRODUIT /I 
            #A.GFDI42                      CD GFDI                 /CD GF 
            #A.XB4442                      MONT QUOTE-PART PRODUIT /      
            #A.SS4442                      MONTANT AMI2 DEMANDÉ    /GEVRA 
            #A.XB2842                      MONTANT INITIAL PRESTAT./INIT. 
            #A.SSGJ42                      MONTANT AMI1 REMBOURSÉ  /TERUG 
            #A.XB1542                      MONTANT SOINS SANTE C.C./BEDRA ---> terug beetaling ?
            #A.SSGD42                      MONTANT AMI2 REMBOURSÉ  /TERUG 
            #A.XB3942                      MONTANT UNITAIRE        /EENHE  -->terugebetaling 4 cijfers achter de komma ?
            #A.SSGK42                      MT REPORTING UNITAIRE   /      
            #A.TM7642                      MONT. REEL. PAYE ME  MBRE       -->Honorarium Riziv 
            #A.SSGL42                      CODE HONORAIRE          /HONOR 
            #A.TM7742                      MONT TICKET MODERAT PAYE MBR   -->Remgeld   
            #A.SSGM42                      MT REPORTING TM PAYE MBR.      
            #A.EABV42                      MONT SUPPLEMENTAIRE            
            #A.EABW42                      MT REPORTING SUPPLEMENTAIRE    
            #A.EACD42                      MONT INTERV PERS PAT THEOR     
            #A.EACE42                      MT REPOR INTER PERS PAT THEO   
            #A.EXID42                      NUMERO EXTERNE          /EXTER -->EXTERN -> nr
            #A.IDMT42                      NUMERO MUTUELLE DU BEN  /NUMME 
            #A.IDNO42                      NUMERO MATRICULE DU BEN /STAMN 
            #A.IDNS42                      NUMERO DE BENEFICIAIRE  /VOLGN 
            #A.YK0642                      NO.OFFICINA             /NR.OF 
            #A.YK2342                      UNITE                   /EENHE 
            #A.YK3742                      FORME GALENETIQUE       /GELEN 
            #A.YK4342                      CLASSEMENT MED.CONS.    /KLASS 
            #A.SSN242                      NUMERO MUTUELLE PAYEUR  /NUMME 
            #BCXCOM20.PHBE42-- ALL         LIBCXCOM20.PHBE42-- ALL
            ########################################################################
            #A.XB0842                      MOTIF PIECE DE BASE     /MOTIE  --> basistuknr1
            #A.XB0942                      ANNEE PIECE DE BASE     /JAAR  ---> basistuknr2
            #A.XB1042                      ORIGINE PIECE DE BASE   /OORSP ---> basistuknr3
            #A.XB1142                      NO SUITE PIECE DE BASE  /VOLGN ---> basistuknr4
            #A.XB1242                      NO LIGNE PIECE DE BASE  /LIJNN ---> hebben we nodig om de lijnen te voorzien
            #A.YN0142                      CODE NOMENCLATURE       /NOMEN ----> nomenclatuur
            #A.XB8042                      ANNEE PRESTATION        /JAAR  -->datum 
            #A.XB0542                      MOIS PRESTATION         /MAAND -->datum
            #A.XB0442                      JOUR PRESTATION         /DAG V -->datum  dd//mm/jj
            #A.XB1342                      NOMBRE DE CAS           /AANTA  --> aantal
            #A.XB1542                      MONTANT SOINS SANTE C.C./BEDRA ---> terug beetaling ?       
            #A.XB3942                      MONTANT UNITAIRE        /EENHE  -->terugebetaling 4 cijfers achter de komma ?
            #A.TM7642                      MONT. REEL. PAYE ME  MBRE       -->Honorarium Riziv 
            #A.TM7742                      MONT TICKET MODERAT PAYE MBR   -->Remgeld
           # XD0142 = CODE ETAT PRESTATION    /KODE STAAT VERSTR code geannuleerd is 9 dus er mag geen 9 instaan
    my $basis_fil= "libcxcom20.PHBE42";    #zoeken op ziekenfondsnr + externnummer is snel
    my $basis_fil1 = "libcxarh20.PXBE42";  # data van de laatste 3 jaar
    my $basis_fil2 = "libcxari20.PYBE41";  #data van langer dan 3 jaar geleden
    my $dbh = connectdb->connect_as400($instellingen->{as400}->{$zkf1}->{username},$instellingen->{as400}->{$zkf1}->{password},$instellingen->{as400}->{$zkf1}->{as400_name});
    #my $nomenclatuurcheck = ("SELECT * FROM  $basis_fil a FULL OUTER JOIN $basis_fil1 b ON CONCAT (a. IDFD42, a.EXID42) = CONCAT (b.IDFD42, b.EXID42) WHERE a.EXID42 = $ext");#versie 4.1 nieuwe nomenclaturen 305852 305896
    #print "SELECT * FROM  $basis_fil a FULL OUTER JOIN $basis_fil1 b ON CONCAT (a. IDFD42, a.EXID42) = CONCAT (b.IDFD42, b.EXID42) WHERE a.EXID42 = $ext\n";
    #my $nomenclatuurcheck = ("SELECT * FROM  $basis_fil a WHERE a.EXID42 = $ext and a.IDFD42 =$zkf and  XD0142 != 9 and a.YN0142 IN ($placeholders)");
    my $nomenclatuurcheck = ("SELECT XB0842,XB0942,XB1042,XB1142,XB1242,YN0142,XB8042,XB0542,XB0442,XB1342,XB1542,XB3942,TM7642,TM7742,
                             EXID42,XD0142,YP0142,GEST42,XB3242,XB3342,XB8442,TM7742
                             FROM  $basis_fil WHERE  EXID42 = $ext and  XB8042 IN ($berekeningsjaren) and IDFD42=$zkf and
                             YN0142 IN ($placeholders) ORDER BY XB1142,XB1242 asc");#and YN0142 IN ($placeholders) XB8042 >= 2006 andXB8042 IN ($berekeningsjaren) and IDFD42=$zkf and
                             
    my $sth = $dbh->prepare( $nomenclatuurcheck );
    $sth->execute();
    my $teller =0;
    print "$basis_fil\n___________________\nvoor extern nr $ext\n";
    while (my @basisstuknrs = $sth->fetchrow_array)  {                        
                         $teller +=1;
                         print "$teller ->remgeld $basisstuknrs[13] prestatiedatum $basisstuknrs[6] $basisstuknrs[7] $basisstuknrs[8] basisstuknr $basisstuknrs[0] $basisstuknrs[1] $basisstuknrs[2] $basisstuknrs[3] $basisstuknrs[4] nomenclatuur  $basisstuknrs[5]  \n" ;
                         my $geannuleerd = $basisstuknrs[15];                       
                         if ($geannuleerd =~ m/9/g) {
                                print "geannuleerd $teller ->remgeld $basisstuknrs[13] prestatiedatum $basisstuknrs[6] $basisstuknrs[7] $basisstuknrs[8] basisstuknr $basisstuknrs[0] $basisstuknrs[1] $basisstuknrs[2] $basisstuknrs[3] $basisstuknrs[4] nomenclatuur  $basisstuknrs[5]  \n" ; ;
                         }else {
                                 my $prestiedatum_test = $basisstuknrs[6]*10000+$basisstuknrs[7]*100+$basisstuknrs[8];
                                 my $valt_binnen_contract =0;
                                 foreach my $teller (keys $ContactDatumsTandplus) {
                                    my $wacht = $ContactDatumsTandplus->{$teller}->{wachtdatum};
                                    my $eind = $ContactDatumsTandplus->{$teller}->{einddatum};
                                    $valt_binnen_contract = 1 if ($prestiedatum_test >= $wacht and $prestiedatum_test <= $eind );
                                    print '';
                                   }
                                 
                                 if ($valt_binnen_contract == 1) {                                   
                                        my $basisstuknr = $basisstuknrs[0]*10000000000000+$basisstuknrs[1]*100000000+$basisstuknrs[2]*10000000+$basisstuknrs[3];
                                        my $lijn_nr = $basisstuknrs[4];
                                        my $nomenclatuur =  $basisstuknrs[5];
                                        my $prestiedatum = "$basisstuknrs[8]/$basisstuknrs[7]/$basisstuknrs[6]";                                 
                                        my $terugbetaling = $basisstuknrs[10]+0;
                                        my $aantal_keer = $basisstuknrs[9];                               
                                        #my $honorarium = $basisstuknrs[13]+$basisstuknrs[10];
                                        my $honorarium = $basisstuknrs[12];
                                        my $betaald_door_lid = $basisstuknrs[12];
                                        $betaald_door_lid = $honorarium if ($betaald_door_lid == 0);
                                        my $remgeld = $basisstuknrs[13]+0;
                                        my $extern_nr = $basisstuknrs[14];
                                        my $nr_zorgverstrekker =  $basisstuknrs[16];
                                        my $gebruiker =  $basisstuknrs[17];
                                        my $extern_nr_bank =0;                                 
                                        my ($omschrijving_nom_nederlands,$omschrijving_nom_frans) =as400_gegevens->beschrijving_nom($dbh,$nomenclatuur);
                                        if (!$kwijtingen->{$basisstuknr}) {  
                                             #$kwijtingen->{$basisstuknr}->{klant}= $klant ;
                                             $kwijtingen->{$basisstuknr}->{datum} = "$basisstuknrs[18]/$basisstuknrs[19]/$basisstuknrs[20]";                                    
                                        }                                                                
                                        my $tabel_inz_nr = $klant->{Rijksreg_Nr};
                                        my $tabel_naam = $klant->{naam};                                
                                        $kwijtingen->{$basisstuknr}->{totalen}->{totaal_remgeld}  += $remgeld;
                                        $kwijtingen->{$basisstuknr}->{totalen}->{totaal_honorarium} +=$honorarium;
                                        $kwijtingen->{$basisstuknr}->{totalen}->{totaal_betaald_door_lid} +=$betaald_door_lid;
                                        $kwijtingen->{$basisstuknr}->{totalen}->{totaal_terugbetaling} += $terugbetaling;
                                        if (!$kwijtingen->{$basisstuknr}->{tabel}->{$tabel_inz_nr}) {
                                                  $kwijtingen->{$basisstuknr}->{tabel}->{$tabel_inz_nr} = {
                                                  'inz' => $tabel_inz_nr,
                                                  'naam' => $tabel_naam,
                                             }                                 
                                        }
                                        $kwijtingen_prestatie_jaar->{$basisstuknrs[6]}->{$basisstuknr}->{lijnen}->{$lijn_nr}= {
                                                  'nomenclatuur' => $nomenclatuur,
                                                  'prestatiedatum' => $prestiedatum,
                                                  'terugbetaling' => $terugbetaling,
                                                  'aantal_keer' => $aantal_keer,
                                                  'betaald_door_lid' => $betaald_door_lid ,
                                                  'honorarium' => $honorarium,
                                                  'remgeld' => $remgeld,
                                                  'extern_nr' => $extern_nr,
                                                  'nr_zorgverstrekker' => $nr_zorgverstrekker,
                                                  'omschrijving_nl' => $omschrijving_nom_nederlands,
                                                  'omschrijving_fr' =>$omschrijving_nom_frans,
                                            
                                             } ;
                                        $kwijtingen_prestatie_jaar->{$basisstuknrs[6]}->{$basisstuknr}->{totalen}->{totaal_remgeld}  += $remgeld;
                                        $kwijtingen_prestatie_jaar->{$basisstuknrs[6]}->{$basisstuknr}->{totalen}->{totaal_honorarium} +=$honorarium;
                                        $kwijtingen_prestatie_jaar->{$basisstuknrs[6]}->{$basisstuknr}->{totalen}->{totaal_betaald_door_lid} +=$betaald_door_lid;
                                        $kwijtingen_prestatie_jaar->{$basisstuknrs[6]}->{$basisstuknr}->{totalen}->{totaal_terugbetaling} += $terugbetaling;
                                        $kwijtingen->{$basisstuknr}->{tabel}->{$tabel_inz_nr}->{totalen}->{totaal_remgeld}  += $remgeld;
                                        $kwijtingen->{$basisstuknr}->{tabel}->{$tabel_inz_nr}->{totalen}->{totaal_honorarium} +=$honorarium;
                                        $kwijtingen->{$basisstuknr}->{tabel}->{$tabel_inz_nr}->{totalen}->{totaal_betaald_door_lid} +=$betaald_door_lid;
                                        $kwijtingen->{$basisstuknr}->{tabel}->{$tabel_inz_nr}->{totalen}->{totaal_terugbetaling} += $terugbetaling;
                                        $kwijtingen->{$basisstuknr}->{tabel}->{$tabel_inz_nr}->{lijnen}->{$lijn_nr}= {
                                                  'nomenclatuur' => $nomenclatuur,
                                                  'prestatiedatum' => $prestiedatum,
                                                  'terugbetaling' => $terugbetaling,
                                                  'aantal_keer' => $aantal_keer,
                                                  'betaald_door_lid' => $betaald_door_lid ,
                                                  'honorarium' => $honorarium,
                                                  'remgeld' => $remgeld,
                                                  'extern_nr' => $extern_nr,
                                                  'nr_zorgverstrekker' => $nr_zorgverstrekker,
                                                  'omschrijving_nl' => $omschrijving_nom_nederlands,
                                                  'omschrijving_fr' =>$omschrijving_nom_frans,
                                                  
                                             } ;
                                   }
                         }
               
          }
          print '';
    my $nomenclatuurcheck_oud = ("SELECT XB0842,XB0942,XB1042,XB1142,XB1242,YN0142,XB8042,XB0542,XB0442,XB1342,XB1542,XB3942,TM7642,TM7742,
                        EXID42,XD0142,YP0142,GEST42,XB3242,XB3342,XB8442,TM7742
                        FROM  $basis_fil1 WHERE IDFD42=$zkf and EXID42 = $ext and 
                        XB8042 IN ($berekeningsjaren) and YN0142 IN ($placeholders) ORDER BY XB1142,XB1242 asc");#and YN0142 IN ($placeholders)
                             
    my $sth_oud = $dbh->prepare($nomenclatuurcheck_oud );
    $sth_oud->execute();
    $teller =0;
    print "$basis_fil1\n___________________\n";
    my @meetellen_basistuknrs;
    while (my @basisstuknrs = $sth_oud->fetchrow_array)  {
                         $teller +=1;
                         #print "$teller ->@basisstuknrs \n" ;
                         print "$teller ->remgeld $basisstuknrs[13] prestatiedatum $basisstuknrs[6] $basisstuknrs[7] $basisstuknrs[8] basisstuknr $basisstuknrs[0] $basisstuknrs[1] $basisstuknrs[2] $basisstuknrs[3] $basisstuknrs[4] nomenclatuur  $basisstuknrs[5]  \n" ;
                         my $geannuleerd = $basisstuknrs[15];                       
                         if ($geannuleerd =~ m/9/g) {
                                print "geannuleerd  @basisstuknrs\n" ;
                         }else {
                                 my $prestiedatum_test = $basisstuknrs[6]*10000+$basisstuknrs[7]*100+$basisstuknrs[8];
                                 my $valt_binnen_contract =0;
                                 foreach my $teller (keys $ContactDatumsTandplus) {
                                    my $wacht = $ContactDatumsTandplus->{$teller}->{wachtdatum};
                                    my $eind = $ContactDatumsTandplus->{$teller}->{einddatum};
                                    $valt_binnen_contract = 1 if ($prestiedatum_test >= $wacht and $prestiedatum_test <= $eind );
                                   }                                 
                                 if ($valt_binnen_contract == 1) {  
                                        my $lijn_nr = $basisstuknrs[4];
                                        my $nomenclatuur =  $basisstuknrs[5];
                                        my $prestiedatum = "$basisstuknrs[8]/$basisstuknrs[7]/$basisstuknrs[6]";
                                        my $terugbetaling = $basisstuknrs[10]+0;
                                        my $aantal_keer = $basisstuknrs[9];                               
                                        #my $honorarium = $basisstuknrs[13]+$basisstuknrs[10];
                                        my $honorarium = $basisstuknrs[12];
                                        my $betaald_door_lid = $basisstuknrs[12];
                                        $betaald_door_lid = $honorarium if ($betaald_door_lid == 0);
                                        my $remgeld = $basisstuknrs[13]+0;
                                        my $extern_nr = $basisstuknrs[14];
                                        my $nr_zorgverstrekker =  $basisstuknrs[16];
                                        my $gebruiker =  $basisstuknrs[17];
                                        my $extern_nr_bank =0;                                 
                                        my ($omschrijving_nom_nederlands,$omschrijving_nom_frans) =as400_gegevens->beschrijving_nom($dbh,$nomenclatuur); 
                                        my $basisstuknr = $basisstuknrs[0]*10000000000000+$basisstuknrs[1]*100000000+$basisstuknrs[2]*10000000+$basisstuknrs[3];
                                        if ($kwijtingen->{$basisstuknr} and $basisstuknr !~ @meetellen_basistuknrs) {
                                             if (!$kwijtingen_archief->{$basisstuknr}) {  
                                                #$kwijtingen->{$basisstuknr}->{klant}= $klant ;
                                                $kwijtingen_archief->{$basisstuknr}->{datum} = "$basisstuknrs[18]/$basisstuknrs[19]/$basisstuknrs[20]";                                    
                                               }                                                                
                                             my $tabel_inz_nr = $klant->{Rijksreg_Nr};
                                             my $tabel_naam = $klant->{naam};                                
                                             $kwijtingen_archief->{$basisstuknr}->{totalen}->{totaal_remgeld}  += $remgeld;
                                             $kwijtingen_archief->{$basisstuknr}->{totalen}->{totaal_honorarium} +=$honorarium;
                                             $kwijtingen_archief->{$basisstuknr}->{totalen}->{totaal_betaald_door_lid} +=$betaald_door_lid;
                                             $kwijtingen_archief->{$basisstuknr}->{totalen}->{totaal_terugbetaling} += $terugbetaling;
                                             if (!$kwijtingen_archief->{$basisstuknr}->{tabel}->{$tabel_inz_nr}) {
                                                 $kwijtingen_archief->{$basisstuknr}->{tabel}->{$tabel_inz_nr} = {
                                                      'inz' => $tabel_inz_nr,
                                                      'naam' => $tabel_naam,                                                      
                                                 }                                 
                                             }
                                             $kwijtingen_prestatie_jaar_archief->{$basisstuknrs[6]}->{$basisstuknr}->{lijnen}->{$lijn_nr}= {
                                                       'nomenclatuur' => $nomenclatuur,
                                                       'prestatiedatum' => $prestiedatum,
                                                       'terugbetaling' => $terugbetaling,
                                                       'aantal_keer' => $aantal_keer,
                                                       'betaald_door_lid' => $betaald_door_lid ,
                                                       'honorarium' => $honorarium,
                                                       'remgeld' => $remgeld,
                                                       'extern_nr' => $extern_nr,
                                                       'nr_zorgverstrekker' => $nr_zorgverstrekker,
                                                       'omschrijving_nl' => $omschrijving_nom_nederlands,
                                                       'omschrijving_fr' =>$omschrijving_nom_frans,
                                                  } ;            
                                             $kwijtingen_prestatie_jaar_archief->{$basisstuknrs[6]}->{$basisstuknr}->{totalen}->{totaal_remgeld}  += $remgeld;
                                             $kwijtingen_prestatie_jaar_archief->{$basisstuknrs[6]}->{$basisstuknr}->{totalen}->{totaal_honorarium} +=$honorarium;
                                             $kwijtingen_prestatie_jaar_archief->{$basisstuknrs[6]}->{$basisstuknr}->{totalen}->{totaal_betaald_door_lid} +=$betaald_door_lid;
                                             $kwijtingen_prestatie_jaar_archief->{$basisstuknrs[6]}->{$basisstuknr}->{totalen}->{totaal_terugbetaling} += $terugbetaling;
                                             $kwijtingen_archief->{$basisstuknr}->{tabel}->{$tabel_inz_nr}->{totalen}->{totaal_remgeld}  += $remgeld;
                                             $kwijtingen_archief->{$basisstuknr}->{tabel}->{$tabel_inz_nr}->{totalen}->{totaal_honorarium} +=$honorarium;
                                             $kwijtingen_archief->{$basisstuknr}->{tabel}->{$tabel_inz_nr}->{totalen}->{totaal_betaald_door_lid} +=$betaald_door_lid;
                                             $kwijtingen_archief->{$basisstuknr}->{tabel}->{$tabel_inz_nr}->{totalen}->{totaal_terugbetaling} += $terugbetaling;
                                             $kwijtingen_archief->{$basisstuknr}->{tabel}->{$tabel_inz_nr}->{lijnen}->{$lijn_nr}= {
                                                        'nomenclatuur' => $nomenclatuur,
                                                        'prestatiedatum' => $prestiedatum,
                                                        'terugbetaling' => $terugbetaling,
                                                        'aantal_keer' => $aantal_keer,
                                                        'betaald_door_lid' => $betaald_door_lid ,
                                                        'honorarium' => $honorarium,
                                                        'remgeld' => $remgeld,
                                                        'extern_nr' => $extern_nr,
                                                        'nr_zorgverstrekker' => $nr_zorgverstrekker,
                                                        'omschrijving_nl' => $omschrijving_nom_nederlands,
                                                        'omschrijving_fr' =>$omschrijving_nom_frans,
                                                        
                                                    } ;
                                        }else {
                                                  if (!$kwijtingen->{$basisstuknr}) {  
                                                     #$kwijtingen->{$basisstuknr}->{klant}= $klant ;
                                                     $kwijtingen->{$basisstuknr}->{datum} = "$basisstuknrs[18]/$basisstuknrs[19]/$basisstuknrs[20]";
                                                     push (@meetellen_basistuknrs,$basisstuknr);
                                                    }                                                                
                                                    my $tabel_inz_nr = $klant->{Rijksreg_Nr};
                                                    my $tabel_naam = $klant->{naam};                                
                                                    $kwijtingen->{$basisstuknr}->{totalen}->{totaal_remgeld}  += $remgeld;
                                                    $kwijtingen->{$basisstuknr}->{totalen}->{totaal_honorarium} +=$honorarium;
                                                    $kwijtingen->{$basisstuknr}->{totalen}->{totaal_betaald_door_lid} +=$betaald_door_lid;
                                                    $kwijtingen->{$basisstuknr}->{totalen}->{totaal_terugbetaling} += $terugbetaling;
                                                    if (!$kwijtingen->{$basisstuknr}->{tabel}->{$tabel_inz_nr}) {
                                                        $kwijtingen->{$basisstuknr}->{tabel}->{$tabel_inz_nr} = {
                                                             'inz' => $tabel_inz_nr,
                                                             'naam' => $tabel_naam,
                                                             
                                                        }                                 
                                                    }
                                                    $kwijtingen_prestatie_jaar->{$basisstuknrs[6]}->{$basisstuknr}->{totalen}->{totaal_remgeld}  += $remgeld;
                                                    $kwijtingen_prestatie_jaar->{$basisstuknrs[6]}->{$basisstuknr}->{totalen}->{totaal_honorarium} +=$honorarium;
                                                    $kwijtingen_prestatie_jaar->{$basisstuknrs[6]}->{$basisstuknr}->{totalen}->{totaal_betaald_door_lid} +=$betaald_door_lid;
                                                    $kwijtingen_prestatie_jaar->{$basisstuknrs[6]}->{$basisstuknr}->{totalen}->{totaal_terugbetaling} += $terugbetaling;
                                                    $kwijtingen->{$basisstuknr}->{tabel}->{$tabel_inz_nr}->{totalen}->{totaal_remgeld}  += $remgeld;
                                                    $kwijtingen->{$basisstuknr}->{tabel}->{$tabel_inz_nr}->{totalen}->{totaal_honorarium} +=$honorarium;
                                                    $kwijtingen->{$basisstuknr}->{tabel}->{$tabel_inz_nr}->{totalen}->{totaal_betaald_door_lid} +=$betaald_door_lid;
                                                    $kwijtingen->{$basisstuknr}->{tabel}->{$tabel_inz_nr}->{totalen}->{totaal_terugbetaling} += $terugbetaling;
                                                    $kwijtingen->{$basisstuknr}->{tabel}->{$tabel_inz_nr}->{lijnen}->{$lijn_nr}= {
                                                               'nomenclatuur' => $nomenclatuur,
                                                               'prestatiedatum' => $prestiedatum,
                                                               'terugbetaling' => $terugbetaling,
                                                               'aantal_keer' => $aantal_keer,
                                                               'betaald_door_lid' => $betaald_door_lid ,
                                                               'honorarium' => $honorarium,
                                                               'remgeld' => $remgeld,
                                                               'extern_nr' => $extern_nr,
                                                               'nr_zorgverstrekker' => $nr_zorgverstrekker,
                                                               'omschrijving_nl' => $omschrijving_nom_nederlands,
                                                               'omschrijving_fr' =>$omschrijving_nom_frans,
                                                               
                                                           } ;
                                        }  
                                   }
                         }            
                               
               
          }
     print '';
     eval{foreach my $basisstuknummer (sort keys $kwijtingen) {} };
     if (!$@) {
               foreach my $basisstuknummer (sort keys $kwijtingen) {        
                    $klant->{TandPlus}->{totalen}->{totaal_remgeld}  += $kwijtingen->{$basisstuknummer}->{totalen}->{totaal_remgeld} ;
                    $klant->{TandPlus}->{totalen}->{totaal_honorarium} += $kwijtingen->{$basisstuknummer}->{totalen}->{totaal_honorarium};
                    $klant->{TandPlus}->{totalen}->{totaal_betaald_door_lid} += $kwijtingen->{$basisstuknummer}->{totalen}->{totaal_betaald_door_lid};
                    $klant->{TandPlus}->{totalen}->{totaal_terugbetaling} +=  $kwijtingen->{$basisstuknummer}->{totalen}->{totaal_terugbetaling};
               }
     }else {
           $klant->{TandPlus}->{totalen}->{totaal_remgeld} =0;
           $klant->{TandPlus}->{totalen}->{totaal_honorarium} =0;
           $klant->{TandPlus}->{totalen}->{totaal_betaald_door_lid} =0;
           $klant->{TandPlus}->{totalen}->{totaal_terugbetaling} =0;
     }
     eval {foreach my $presjaar (sort keys $kwijtingen_prestatie_jaar) {}};
     if (!$@) {
          foreach my $presjaar (sort keys $kwijtingen_prestatie_jaar) {
               foreach my $basisstuknr (sort keys $kwijtingen_prestatie_jaar->{$presjaar}) {
                $klant->{TandPlus}->{$presjaar}->{totalen}->{totaal_remgeld} += $kwijtingen_prestatie_jaar->{$presjaar}->{$basisstuknr}->{totalen}->{totaal_remgeld};
                $klant->{TandPlus}->{$presjaar}->{totalen}->{totaal_honorarium} += $kwijtingen_prestatie_jaar->{$presjaar}->{$basisstuknr}->{totalen}->{totaal_honorarium};
                $klant->{TandPlus}->{$presjaar}->{totalen}->{totaal_betaald_door_lid} += $kwijtingen_prestatie_jaar->{$presjaar}->{$basisstuknr}->{totalen}->{totaal_betaald_door_lid};
                $klant->{TandPlus}->{$presjaar}->{totalen}->{totaal_terugbetaling} += $kwijtingen_prestatie_jaar->{$presjaar}->{$basisstuknr}->{totalen}->{totaal_terugbetaling};
               }
          }
     }else {
          my ($presjaar1,$presjaar2,$presjaar3) = split(/,/,$berekeningsjaren);
               $klant->{TandPlus}->{$presjaar1}->{totalen}->{totaal_remgeld}=0;
               $klant->{TandPlus}->{$presjaar1}->{totalen}->{totaal_honorarium} =0;
               $klant->{TandPlus}->{$presjaar1}->{totalen}->{totaal_betaald_door_lid}=0;
               $klant->{TandPlus}->{$presjaar1}->{totalen}->{totaal_terugbetaling} =0;
               $klant->{TandPlus}->{$presjaar2}->{totalen}->{totaal_remgeld}=0;
               $klant->{TandPlus}->{$presjaar2}->{totalen}->{totaal_honorarium} =0;
               $klant->{TandPlus}->{$presjaar2}->{totalen}->{totaal_betaald_door_lid}=0;
               $klant->{TandPlus}->{$presjaar2}->{totalen}->{totaal_terugbetaling} =0;
               $klant->{TandPlus}->{$presjaar3}->{totalen}->{totaal_remgeld}=0;
               $klant->{TandPlus}->{$presjaar3}->{totalen}->{totaal_honorarium} =0;
               $klant->{TandPlus}->{$presjaar3}->{totalen}->{totaal_betaald_door_lid}=0;
               $klant->{TandPlus}->{$presjaar3}->{totalen}->{totaal_terugbetaling} =0;
          
     }
     
     print '';
     eval {foreach my $basisstuknummer (sort keys $kwijtingen_archief) {}};
     if (!$@) {
          foreach my $basisstuknummer (sort keys $kwijtingen_archief) {
               $klant->{TandPlus_archief}->{totalen}->{totaal_remgeld}  += $kwijtingen_archief->{$basisstuknummer}->{totalen}->{totaal_remgeld} ;
               $klant->{TandPlus_archief}->{totalen}->{totaal_honorarium} += $kwijtingen_archief->{$basisstuknummer}->{totalen}->{totaal_honorarium};
               $klant->{TandPlus_archief}->{totalen}->{totaal_betaald_door_lid} += $kwijtingen_archief->{$basisstuknummer}->{totalen}->{totaal_betaald_door_lid};
               $klant->{TandPlus_archief}->{totalen}->{totaal_terugbetaling} +=  $kwijtingen_archief->{$basisstuknummer}->{totalen}->{totaal_terugbetaling};
          }
     }else {
          $klant->{TandPlus_archief}->{totalen}->{totaal_remgeld} =0 ;
          $klant->{TandPlus_archief}->{totalen}->{totaal_honorarium} = 0;
          $klant->{TandPlus_archief}->{totalen}->{totaal_betaald_door_lid} = 0;
          $klant->{TandPlus_archief}->{totalen}->{totaal_terugbetaling} = 0; 
     }
     eval {foreach my $presjaar (sort keys $kwijtingen_prestatie_jaar) {}};
     if (!$@) {
          foreach my $presjaar (sort keys $kwijtingen_prestatie_jaar) {
                 foreach my $basisstuknr (sort keys $kwijtingen_prestatie_jaar->{$presjaar}) {
                  $klant->{TandPlus_archief}->{$presjaar}->{totalen}->{totaal_remgeld} += $kwijtingen_prestatie_jaar_archief->{$presjaar}->{$basisstuknr}->{totalen}->{totaal_remgeld};
                  $klant->{TandPlus_archief}->{$presjaar}->{totalen}->{totaal_honorarium} += $kwijtingen_prestatie_jaar_archief->{$presjaar}->{$basisstuknr}->{totalen}->{totaal_honorarium};
                  $klant->{TandPlus_archief}->{$presjaar}->{totalen}->{totaal_betaald_door_lid} += $kwijtingen_prestatie_jaar_archief->{$presjaar}->{$basisstuknr}->{totalen}->{totaal_betaald_door_lid};
                  $klant->{TandPlus_archief}->{$presjaar}->{totalen}->{totaal_terugbetaling} += $kwijtingen_prestatie_jaar_archief->{$presjaar}->{$basisstuknr}->{totalen}->{totaal_terugbetaling};
                 }
               }
     }else{
           my ($presjaar1,$presjaar2,$presjaar3) = split(/,/,$berekeningsjaren);
               $klant->{TandPlus_archief}->{$presjaar1}->{totalen}->{totaal_remgeld}=0;
               $klant->{TandPlus_archief}->{$presjaar1}->{totalen}->{totaal_honorarium} =0;
               $klant->{TandPlus_archief}->{$presjaar1}->{totalen}->{totaal_betaald_door_lid}=0;
               $klant->{TandPlus_archief}->{$presjaar1}->{totalen}->{totaal_terugbetaling} =0;
               $klant->{TandPlus_archief}->{$presjaar2}->{totalen}->{totaal_remgeld}=0;
               $klant->{TandPlus_archief}->{$presjaar2}->{totalen}->{totaal_honorarium} =0;
               $klant->{TandPlus_archief}->{$presjaar2}->{totalen}->{totaal_betaald_door_lid}=0;
               $klant->{TandPlus_archief}->{$presjaar2}->{totalen}->{totaal_terugbetaling} =0;
               $klant->{TandPlus_archief}->{$presjaar3}->{totalen}->{totaal_remgeld}=0;
               $klant->{TandPlus_archief}->{$presjaar3}->{totalen}->{totaal_honorarium} =0;
               $klant->{TandPlus_archief}->{$presjaar3}->{totalen}->{totaal_betaald_door_lid}=0;
               $klant->{TandPlus_archief}->{$presjaar3}->{totalen}->{totaal_terugbetaling} =0;
     }
     print '';
     $klant->{kwijtingen_jaar}=$kwijtingen_prestatie_jaar;
     $klant->{kwijtingen_jaar_archief}=$kwijtingen_prestatie_jaar_archief;
     return ($klant);
     }
sub beschrijving_nom {
              my ($self,$dbh,$nomenclatuur) = @_;
              my $nomenclatuur_family_file ='libcxref.LREFCYC';
              my $lrefh3a = 'libcxref.lrefh3a';
              my $lrefj7a = 'libcxref.lrefj7a';
              my $lrefn6a = 'libcxref.lrefn6a';             
              my $lrefcyc = 'libcxref.LREFcyc';
              #$nomenclatuur =249233;
              my ($yn01h3,$ZE02J7,$omschrijving_nederlands,$omschrijving_frans);
              #harry poging
              my ($NN08CY)=$dbh->selectrow_array("SELECT NN08CY FROM $nomenclatuur_family_file WHERE YN01CY=$nomenclatuur and IX05CY = 99999999");
              my $subtest_nom = substr($NN08CY,0,5);
              #my @test1 = $dbh->selectrow_array("SELECT YN01CY, NN08CY, ZG90CY, ZG07CY,T005CY FROM $lrefcyc WHERE YN01CY = $nomenclatuur and IX05CY = 99999999");
              #my @test1 = $dbh->selectrow_array("SELECT * FROM $lrefcyc WHERE YN01CY = $nomenclatuur and IX05CY = 99999999"); 
              my @test =$dbh->selectrow_array("SELECT CONCAT(CONCAT(N758J7, R758J7),N458J7),N758J7, R758J7,N458J7,ZOLNJ7,ZOLFJ7 FROM  $lrefj7a where IX05J7=99999999 and CONCAT(N758J7, R758J7)
                                               = '$subtest_nom' and YN48J7 = 0"); # ZOLNJ7 = 'OPHTALMOLOGIE'
              $omschrijving_frans = $test[5];
              $omschrijving_nederlands = $test[4];
              if (!$omschrijving_nederlands) {
                       my @test1 = $dbh->selectrow_array("SELECT ZE01N6,ZE02N6 FROM $lrefn6a where YN01N6 = $nomenclatuur and IX05N6=99999999");
                       $omschrijving_frans = $test1[0];
                       $omschrijving_nederlands = $test1[1];
                       print '';
              }             
              return ($omschrijving_nederlands,$omschrijving_frans);
              
        }
1;
