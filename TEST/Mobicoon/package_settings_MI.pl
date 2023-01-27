#!/usr/bin/perl -w
require 'Decryp_Encrypt_MI.pl';
package settings;
     
      use strict;
      use vars qw(%settings);
      use XML::Simple;
      
      sub new {
           my ($self,$zkf,$zkf_test)= @_;
           #my $test1 =$main::as400->{ziekenfondsen};
           #my $test2 = $main::agresso_instellingen;
           #my $test3 = $main::plaats_sjablonen;
            $zkf_test="ZKF$zkf" if (!defined $zkf_test);
            my $user= $main::agresso_instellingen->{as400}->{"$zkf_test"}->{username};     	     #username as400
            my $pass=$main::agresso_instellingen->{as400}->{"$zkf_test"}->{password};
            $pass =decrypt->new($pass);         
            my $as400_name = $main::agresso_instellingen->{as400}->{"$zkf_test"}->{as400_name};
            my $libcxcom = $main::agresso_instellingen->{as400}->{"$zkf_test"}->{libcxcom};
            my $libcxfil = $main::agresso_instellingen->{as400}->{"$zkf_test"}->{libcxfil};
            my $libcxarh  = $main::agresso_instellingen->{as400}->{"$zkf_test"}->{libcxarh};
            my $libcxari  = $main::agresso_instellingen->{as400}->{"$zkf_test"}->{libcxari};
            my $libsxfil = $main::agresso_instellingen->{as400}->{"$zkf_test"}->{libsxfil};
            my $jadebus = $main::agresso_instellingen->{as400}->{"$zkf_test"}->{jadebus};
            my $user_name = $user;
            my $password = $pass;               
            my $hospiplan_ambuplan = $main::agresso_instellingen->{verzekeringen}->{$zkf_test}->{hospiplan_ambuplan};
            my $ambuplan = $main::agresso_instellingen->{verzekeringen}->{$zkf_test}->{ambuplan};
            my $hospiplus_ambuplus = $main::agresso_instellingen->{verzekeringen}->{$zkf_test}->{hospiplus_ambuplus};
            my $ambuplus = $main::agresso_instellingen->{verzekeringen}->{$zkf_test}->{ambuplus};
            my $hospiplus= $main::agresso_instellingen->{verzekeringen}->{$zkf_test}->{hospiplus};
            my $hospiplan = $main::agresso_instellingen->{verzekeringen}->{$zkf_test}->{hospiplan};
            my $hospiforfait = $main::agresso_instellingen->{verzekeringen}->{$zkf_test}->{hospiforfait}->{hospiforfait};
            my $hospicontinu = $main::agresso_instellingen->{verzekeringen}->{$zkf_test}->{hospicontinu};
            my $HF_formule1= $main::agresso_instellingen->{verzekeringen}->{$zkf_test}->{hospiforfait}->{HOSPIFORFAIT50};
            my $HF_formule2= $main::agresso_instellingen->{verzekeringen}->{$zkf_test}->{hospiforfait}->{HOSPIFORFAIT25};
            my $HF_formule3= $main::agresso_instellingen->{verzekeringen}->{$zkf_test}->{hospiforfait}->{HOSPIFORFAIT12};
            my $settings = {
                     'user' => $user,
                     'pass' => $pass,
                     'user_name' => $user_name,                #username
                     'password' => $password,                 #paswoord
                     'name_as400' =>  "$as400_name",                 #naam van de as400
                     'toelating_fil' => "$libcxcom.PSDDS5 ",    #hier kan men zien of iemand in een  rusthuis is
                     'adres_fil' =>  "$libcxfil.PADRJR",      #naam van de adres file 
                     'pers_fil' =>  "$libcxfil.PFYSL8",       #naam van de file met de persoonlijke gegevens
                     'cg_fil' =>  "$libcxfil.PCCTGD",         #waar de cg1/cg2 code kan vinden
                     'basis_fil' =>  "$libcxcom.PHBE42",      #file met alle betaginen en tussen komsent
                     'basis_fil1' =>  "$libcxarh .PXBE42",  # data van de laatste 3 jaar
                     'basis_fil2' =>  "$libcxari .PYBE41",  #data van langer dan 3 jaar geleden
                     'pdoskj_fil' =>  "$libcxfil.PDOSKJ",     #file met dossier en verzekeringenµ
                     'phoekk_fil' =>  "$libcxfil.PHOEKK",
                     'ptaxkq_fil' =>  "$libcxfil.PTAXKQ",     # file met de betalingen in
                     'carens_fil' =>  "$libsxfil.CARENS",     #file met de carensdagen
                     'ascard_fil' =>  "$libcxcom.ASCARD",      #file met assuracard gegevens
                     'aswift_fil' =>  "$libcxcom.ASWIFT",      #file met omzetting IBAN ->swift klanten
                     'bban_iban_lev_fil' =>  "$libcxcom.AIBAN", #file met omzetting bbdan iban swift leveranciers
                     'ascard_batchnr_fil' =>  "$libcxcom.ASBATCH",   #file met assuracard gegevens van de batchnrs
                     'mobgev_fil' => "$libsxfil.MOBGEVN",
                     'pben_fil' => "$libcxfil.PBEN17",
                     'prek_fil' => "$libcxfil.PREKKW",
                     'commentaar_fil'=> "$libcxfil.PCOMGK",
                     'gkd_hist_fil' => "$jadebus.WWWCONTAC",
                     'gkd_contactId_fil' => "$jadebus.wwwcountercontact", 
                     'email_fil' => "$libcxfil.PEMWVL",
                     'office' => 0,
                     'section' => 200,
                     'hospiplan_051_ambuplan'=>  $hospiplan_ambuplan,
                     'ambuplan_063' => $ambuplan,
                     'hospiplus_052_ambuplus'  =>  $hospiplus_ambuplus,
                     'ambuplus_064' => $ambuplus,
                     'hospiplus_062' => $hospiplus,
                     'hospiplan_061' => $hospiplan,
                     'hospiforfait' =>  $hospiforfait,
                     'hospicontinue' => $hospicontinu,
                     'zkfnummer' => $zkf,
                     'HF_formule1' => $HF_formule1,
                     'HF_formule2' => $HF_formule2,
                     'HF_formule3' => $HF_formule3,
                     'pathtofiles' => $main::plaats_sjablonen->{pathtofiles},
                     'sjabloonplaats' => $main::plaats_sjablonen->{sjabloonplaats},
                     'documentplaatst_brieven' => $main::plaats_sjablonen->{documentplaatst_brieven},
                     'documentplaatst_etiketten' => $main::plaats_sjablonen->{documentplaatst_etiketten},
                     'pathtoprogram' => "C:\\macros\\mob",
                     #'sjabloonplaats' =>  "C:\\macros\\mob\\sjabloon_odt",
                     #'documentplaatst_brieven' => "C:\\macros\\mob\\ooopslag"
                     
                    };                
       
           return ($settings)  ;
         }
1;

