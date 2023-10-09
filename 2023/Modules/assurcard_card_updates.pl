#!/usr/bin/perl -w
use strict;
use vars qw(%settings $mail_contract);
use Date::Manip::DM5 ;
#require "settings.pl";
#require "cnnectdb.pl";
#&settings(203);
#my $dbconnectie = &cnnectdb ($settings{user_name},$settings{password},$settings{name_as400});
#
#&card_lost (99090632486,$dbconnectie);
sub card_lost {
     #card_lost (rijkregisternr,dbh)
     my $rijks_reg_nr = shift @_;
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
     #ONTSLAGO  VARCHAR(1) Y = onderzozk of het om een onstlag gaat contract xml N = niets doen
     #CXMLINIT VARCHAR(1) Y = deze is al opgenomen in contract xml N = moet nog doorgestuurd worden
     #CXMLUPDA VARCHAR(1) Y = er is iets veranderd en deze moet doorgestuurd N = moet niet doorgestuurd worden
      #WANBET VARCHAR(1) Y = het is een wanbetaler kaart geblokkeerd N = geen wanbetaler kaart niet geblokkeerd
     my $updatethis = $dbh ->do("UPDATE $settings{'ascard_fil'} set (LOSTCARD ) = (1) WHERE KNRN52= $rijks_reg_nr");
     }
sub card_lost_reset {
     #card_lost (rijkregisternr,dbh)
     my $rijks_reg_nr = shift @_;
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
     #ONTSLAGO  VARCHAR(1) Y = onderzozk of het om een onstlag gaat contract xml N = niets doen
     #CXMLINIT VARCHAR(1) Y = deze is al opgenomen in contract xml N = moet nog doorgestuurd worden
     #CXMLUPDA VARCHAR(1) Y = er is iets veranderd en deze moet doorgestuurd N = moet niet doorgestuurd worden
      #WANBET VARCHAR(1) Y = het is een wanbetaler kaart geblokkeerd N = geen wanbetaler kaart niet geblokkeerd
     my $updatethis = $dbh ->do("UPDATE $settings{'ascard_fil'} set (LOSTCARD ) = (0) WHERE KNRN52= $rijks_reg_nr");
     }

sub einddatum_kaart {
     #einddatum rijksregisternummer,dbh
     my $einddatum = shift @_;
     my $rijks_reg_nr = shift @_;
     my $dbh = shift @_;
     my $vandaag = ParseDate("today");
     $vandaag = substr ($vandaag,0,8);  # vandaag in YYYYMMDD
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
     #ONTSLAG VARCHAR(1) Y = ontslagen kaart geblokkeerd N = niet ontslagen 
     my $updatethis;
     $updatethis = $dbh ->do("UPDATE $settings{'ascard_fil'} set (EINDAT,EINCON,OKNOW,DTCGOK,CXMLUPDA) = ($einddatum,$einddatum,'N',$vandaag,'Y') WHERE KNRN52= $rijks_reg_nr");
    
    }
sub einddatum_contract {
     #einddatum rijksregisternummer,dbh
     my $einddatum = shift @_;
     my $rijks_reg_nr = shift @_;
     my $dbh = shift @_;
     my $vandaag = ParseDate("today");
     $vandaag = substr ($vandaag,0,8);  # vandaag in YYYYMMDD
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
     my $updatethis;
     $updatethis = $dbh ->do("UPDATE $settings{'ascard_fil'} set (EINCON,OKNOW,DTCGOK) = ($einddatum,'Y',$vandaag) WHERE KNRN52= $rijks_reg_nr");
    
    }
sub activeer_de_kaart {
     my $dbh = shift @_;
     my $rijks_reg_nr = shift @_;
     my $dossier = shift @_;
     my $zkf_nr = shift @_;
     my $vandaag = ParseDate("today");
     $vandaag = substr ($vandaag,0,8);  # vandaag in YYYYMMDD
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
     my $updatethis;
     print "activeer_de_kaart 1111310817 " if ($rijks_reg_nr == 1111310817);
     $updatethis = $dbh ->do("UPDATE $settings{'ascard_fil'} set (DOSSNR,EINDAT,EINCON,OKNOW,DTCGOK,CXMLUPDA,WANBET) = ($dossier,99999999,99999999,'Y',$vandaag,'Y','N') WHERE KNRN52= $rijks_reg_nr");
}
sub zet_onderzoek_onslag {
     # zet onderzoek onstlag in ascard file 
     my $dbh = shift @_;   
     my $nrzkfcheck = shift @_;
     my $rijks_register_nr = shift @_;
     my $vandaag = ParseDate("today");
     $vandaag = substr ($vandaag,0,8);  # vandaag in YYYYMMDD
     $vandaag ='20140401';
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
     my $updatethis;
     $updatethis = $dbh ->do("UPDATE $settings{'ascard_fil'} set ONTSLAGO = 'Y' WHERE KNRN52= $rijks_register_nr");
     
}
sub delete_onderzoek_onslag_verander_zkf_dossiernr_lostcard {
     # zet onderzoek onstlag in ascard file 
     my $dbh = shift @_;   
     my $nrzkfcheck = shift @_;
     my $rijks_register_nr = shift @_;
     my $dos_nr =shift @_;
     my $exid_id = shift @_;
     my $vandaag = ParseDate("today");
     $vandaag = substr ($vandaag,0,8);  # vandaag in YYYYMMDD
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
     #OKNOW  is nu ok als Y niet ok als nee
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
     my $updatethis;
     $updatethis = $dbh ->do("UPDATE $settings{'ascard_fil'} set (ONTSLAGO,ZKF,DOSSNR,LOSTCARD,DTCATY,EINCON,CXMLUPDA,EXID52) = ('N',$nrzkfcheck,$dos_nr,1,$vandaag,99999999,'N',$exid_id) WHERE KNRN52= $rijks_register_nr");
     
}
sub  zet_wanbetaler_in {
     # zet onderzoek onstlag in ascard file 
     my $dbh = shift @_;   
     my $nrzkfcheck = shift @_;
     my $rijks_register_nr = shift @_;
     #my $dos_nr =shift @_;
     my $vandaag = ParseDate("today");
     $vandaag = substr ($vandaag,0,8);  # vandaag in YYYYMMDD
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
     #OKNOW  is nu ok als 'Y'
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
     my $oknow = $dbh->selectrow_array("SELECT OKNOW FROM $settings{'ascard_fil'} WHERE KNRN52= $rijks_register_nr"); 
     my $updatethis;
     $updatethis = $dbh ->do("UPDATE $settings{'ascard_fil'} set (EINDAT,EINCON,OKNOW,CXMLUPDA,WANBET) = ($vandaag,$vandaag,'N','Y','Y') WHERE KNRN52= $rijks_register_nr") if ($oknow =~ m/Y/i);
     #print "$updatethis";
     
}
sub  reset_wanbetaler {
     # zet onderzoek onstlag in ascard file 
     my $dbh = shift @_;   
     my $nrzkfcheck = shift @_;
     my $rijks_register_nr = shift @_;
     my $teller_wanbetaler =shift @_;
     my $vandaag = ParseDate("today");
     $vandaag = substr ($vandaag,0,8);  # vandaag in YYYYMMDD
     my $oknow = 'Y';
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
     #OKNOW  is nu ok als 'Y'
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
     $oknow = $dbh->selectrow_array("SELECT OKNOW FROM $settings{'ascard_fil'} WHERE KNRN52= $rijks_register_nr and WANBET = 'Y'  and OKNOW = 'N' ");
     if (!$oknow) {
       $oknow = 'Y';   #code
     }
     print "reset_wanbetaler 1111310817 " if ($rijks_register_nr == 1111310817);
     my $updatethis;
     if ($oknow =~ m/N/i) {
           $updatethis = $dbh ->do("UPDATE $settings{'ascard_fil'} set (EINDAT,EINCON,OKNOW,CXMLUPDA,WANBET) = (99999999,99999999,'Y','Y','N') WHERE KNRN52= $rijks_register_nr") ;
           #print "$updatethis\n";
           #print "$teller_wanbetaler $rijks_register_nr -> ex wanbetaler terug geactiveerd\n";
           #$mail_contract = $mail_contract."$teller_wanbetaler $rijks_register_nr -> ex wanbetaler terug geactiveerd\n";
     }
     
     
}
sub verander_rijksregister_nummer {
     #
     my $dbh = shift @_;   
     my $nrzkfcheck = shift @_;
     my $rijks_register_nr = shift @_;
     my $externnr =shift @_;
     my $vandaag = ParseDate("today");
     $vandaag = substr ($vandaag,0,8);  # vandaag in YYYYMMDD
     #$vandaag ='20140401';
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
     my $updatethis;
     $updatethis = $dbh ->do("UPDATE $settings{'ascard_fil'} set KNRN52  = $rijks_register_nr WHERE EXID52= $externnr and ZKF=$nrzkfcheck");
     print "einde verander rijksregnr\n";
}

sub verander_agresso_lid_naar_kaart {
      #
      my $dbh = shift @_;   
      my ($KNRN52,$ZKF,$EXID52,$DOSSNR,$INZDAT,$CREDAT,$EINDAT,$EINCON,$CARDNR,$ASSNR,
       $OKNOW,$DTCGOK,$CARDTY,$DTCATY,$LOSTCARD,$BATCHNR,$TESTPROD,$ONTSLAGO,$CXMLINIT,$CXMLUPDA,$WANBET,$ONTSLAG) = @_;
      my $updatethis = $dbh ->do("UPDATE $settings{'ascard_fil'}
       set DOSSNR =$DOSSNR,INZDAT =$INZDAT,CREDAT=$CREDAT,EINDAT=$EINDAT,EINCON=$EINCON,
       BATCHNR=$BATCHNR,TESTPROD='$TESTPROD',ONTSLAGO='$ONTSLAGO',CXMLINIT='$CXMLINIT',CXMLUPDA='$CXMLUPDA',
       CARDNR=$CARDNR,ASSNR=$ASSNR,OKNOW='$OKNOW',DTCGOK =$DTCGOK,CARDTY=$CARDTY,DTCATY=$DTCATY,LOSTCARD=$LOSTCARD,
       WANBET='$WANBET',ONTSLAG='$ONTSLAG'  WHERE KNRN52=$KNRN52");
       print "";
       
     }
1;
                     
