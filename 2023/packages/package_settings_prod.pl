#!/usr/bin/perl -w
package settings;
      require 'Decryp_Encrypt_prod.pl';
      use strict;
      use vars qw(%settings);
      use XML::Simple;
      
      sub new {
           my ($self,$zkf_nr_set)= @_;
           #my $test1 =$main::as400->{ziekenfondsen};
           #my $test2 = $main::agresso_instellingen;
           #my $test3 = $main::plaats_sjablonen;
           if ($zkf_nr_set == 203) {
              #instellingen 203
                my $as400_name = $main::as400->{ziekenfondsen}->{zkf203}->{as400}->{as400_name};
                my $libcxcom = $main::as400->{ziekenfondsen}->{zkf203}->{as400}->{libcxcom};
                my $libcxfil = $main::as400->{ziekenfondsen}->{zkf203}->{as400}->{libcxfil};
                my $libcxarh  = $main::as400->{ziekenfondsen}->{zkf203}->{as400}->{libcxarh};
                my $libcxari  = $main::as400->{ziekenfondsen}->{zkf203}->{as400}->{libcxari};
                my $libsxfil = $main::as400->{ziekenfondsen}->{zkf203}->{as400}->{libsxfil};
                my $jadebus = $main::as400->{ziekenfondsen}->{zkf203}->{as400}->{jadebus};
                my $user_name = $main::as400->{ziekenfondsen}->{zkf203}->{as400}->{username};
                my $password = $main::as400->{ziekenfondsen}->{zkf203}->{as400}->{password};
                $password =decrypt->new($password);
                my $hospiplan_ambuplan = $main::agresso_instellingen->{verzekeringen}->{ZKF203}->{hospiplan_ambuplan};
                my $ambuplan = $main::agresso_instellingen->{verzekeringen}->{ZKF203}->{ambuplan};
                my $hospiplus_ambuplus = $main::agresso_instellingen->{verzekeringen}->{ZKF203}->{hospiplus_ambuplus};
                my $ambuplus = $main::agresso_instellingen->{verzekeringen}->{ZKF203}->{ambuplus};
                my $hospiplus= $main::agresso_instellingen->{verzekeringen}->{ZKF203}->{hospiplus};
                my $hospiplan = $main::agresso_instellingen->{verzekeringen}->{ZKF203}->{hospiplan};
                my $hospiforfait = $main::agresso_instellingen->{verzekeringen}->{ZKF203}->{hospiforfait}->{hospiforfait};
                my $hospicontinu = $main::agresso_instellingen->{verzekeringen}->{ZKF203}->{hospicontinu};
                my $HF_formule1= $main::agresso_instellingen->{verzekeringen}->{ZKF203}->{hospiforfait}->{HOSPIFORFAIT50};
                my $HF_formule2= $main::agresso_instellingen->{verzekeringen}->{ZKF203}->{hospiforfait}->{HOSPIFORFAIT25};
                my $HF_formule3= $main::agresso_instellingen->{verzekeringen}->{ZKF203}->{hospiforfait}->{HOSPIFORFAIT12};
                $self = {
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
                     'zkfnummer' => 203,
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
                
             }elsif ($zkf_nr_set == 235){
              #instellingen 235
                my $as400_name = $main::as400->{ziekenfondsen}->{zkf235}->{as400}->{as400_name};
                my $libcxcom = $main::as400->{ziekenfondsen}->{zkf235}->{as400}->{libcxcom};
                my $libcxfil = $main::as400->{ziekenfondsen}->{zkf235}->{as400}->{libcxfil};
                my $libcxarh  = $main::as400->{ziekenfondsen}->{zkf235}->{as400}->{libcxarh};
                my $libcxari  = $main::as400->{ziekenfondsen}->{zkf235}->{as400}->{libcxari};
                my $libsxfil = $main::as400->{ziekenfondsen}->{zkf235}->{as400}->{libsxfil};
                my $jadebus = $main::as400->{ziekenfondsen}->{zkf235}->{as400}->{jadebus};
                my $user_name = $main::as400->{ziekenfondsen}->{zkf235}->{as400}->{username};
                my $password = $main::as400->{ziekenfondsen}->{zkf235}->{as400}->{password};
                $password =decrypt->new($password);
                my $hospiplan_ambuplan = $main::agresso_instellingen->{verzekeringen}->{ZKF235}->{hospiplan_ambuplan};
                my $ambuplan = $main::agresso_instellingen->{verzekeringen}->{ZKF235}->{ambuplan};
                my $hospiplus_ambuplus = $main::agresso_instellingen->{verzekeringen}->{ZKF203}->{hospiplus_ambuplus};
                my $ambuplus = $main::agresso_instellingen->{verzekeringen}->{ZKF235}->{ambuplus};
                my $hospiplus= $main::agresso_instellingen->{verzekeringen}->{ZKF235}->{hospiplus};
                my $hospiplan = $main::agresso_instellingen->{verzekeringen}->{ZKF235}->{hospiplan};
                my $hospiforfait = $main::agresso_instellingen->{verzekeringen}->{ZKF235}->{hospiforfait}->{hospiforfait};
                my $hospicontinu = $main::agresso_instellingen->{verzekeringen}->{ZKF235}->{hospicontinu};
                my $HF_formule1= $main::agresso_instellingen->{verzekeringen}->{ZKF235}->{hospiforfait}->{HOSPIFORFAIT50};
                my $HF_formule2= $main::agresso_instellingen->{verzekeringen}->{ZKF235}->{hospiforfait}->{HOSPIFORFAIT25};
                my $HF_formule3= $main::agresso_instellingen->{verzekeringen}->{ZKF235}->{hospiforfait}->{HOSPIFORFAIT12}; 
                $self = {
                     'user_name' => $user_name,                #username
                     'password' => $password ,                 #paswoord
                     'name_as400' =>  $as400_name,                 #naam van de as400
                     'toelating_fil' => "$libcxcom.PSDDS5 ",    #hier kan men zien of iemand in een  rusthuis is
                     'adres_fil' =>  "$libcxfil.PADRJR",      #naam van de adres file 
                     'pers_fil' =>  "$libcxfil.PFYSL8",       #naam van de file met de persoonlijke gegevens
                     'cg_fil' =>  "$libcxfil.PCCTGD",         #waar de cg1/cg2 code kan vinden
                     'basis_fil' =>  "$libcxcom.PHBE42",      #file met alle betaginen en tussen komsent
                     'basis_fil1' =>  "$libcxarh.PXBE42",  # data van de laatste 3 jaar
                     'basis_fil2' =>  "$libcxari.PYBE41",  #data van langer dan 3 jaar geleden
                     'pdoskj_fil' =>  "$libcxfil.PDOSKJ",     #file met dossier en verzekeringen
                     'phoekk_fil' =>  "$libcxfil.PHOEKK",
                     'ptaxkq_fil' =>  "$libcxfil.PTAXKQ",     # file met de betalingen in
                     'carens_fil' =>  "$libsxfil.CARENS",
                     'ascard_fil' =>  "$libcxcom.ASCARD",      #file met assuracard gegevens
                     'aswift_fil' =>  "$libcxcom.ASWIFT",
                     'bban_iban_lev_fil' =>  "$libcxcom.AIBAN", #file met omzetting bbdan iban swift leveranciers
                     'ascard_batchnr_fil' =>  "$libcxcom.ASBATCH",   #file met assuracard gegevens van de batchnrs
                     'mobgev_fil' => "$libsxfil.MOBGEVN",
                     'pben_fil' => "$libcxfil.PBEN17",
                     'prek_fil' => "$libcxfil.PREKKW",
                     'email_fil' => "$libcxfil.PEMWVL",
                     'commentaar_fil'=> "$libcxfil.PCOMGK",
                     'gkd_hist_fil' => "$jadebus.WWWCONTAC",
                     'office' => 0,
                     'section' => 0,
                     'hospiplan_051_ambuplan'=> $hospiplan_ambuplan,
                     'ambuplan_063' => $ambuplan,
                     'hospiplus_052_ambuplus'  =>  $hospiplus_ambuplus,
                     'ambuplus_064' => $ambuplus,
                     'hospiplus_062' => $hospiplus,
                     'hospiplan_061' => $hospiplan,
                     'hospiforfait' =>  $hospiforfait,
                     'hospicontinue' => $hospicontinu,
                     'zkfnummer' => 235,
                     'HF_formule1' => $HF_formule1,
                     'HF_formule2' => $HF_formule2,
                     'HF_formule3' => $HF_formule3,
                     'pathtofiles' => $main::plaats_sjablonen->{pathtofiles},
                     'sjabloonplaats' => $main::plaats_sjablonen->{sjabloonplaats},
                     'documentplaatst_brieven' => $main::plaats_sjablonen->{documentplaatst_brieven},
                     'documentplaatst_etiketten' => $main::plaats_sjablonen->{documentplaatst_etiketten},
                     'pathtoprogram' => "C:\\macros\\mob",
                     # 'pathtofiles' => "C:\\macros\\mob\\ooopslag",
                     #'sjabloonplaats' =>  "C:\\macros\\mob\\sjabloon_odt",
                     #'documentplaatst_brieven' => "C:\\macros\\mob\\ooopslag"
                    };
              
             }else {
                  die;
             }
           return ($self)  
         }
1;

