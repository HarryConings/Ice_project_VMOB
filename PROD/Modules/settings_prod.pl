#!/usr/bin/perl -w
#OPGELET!!!!!!
#Dit programma is auteursrechtelijk beschermd.
#Deze code is voor 50% eigendom van Hospiplus en voor 50% eigendom van de Firma  I.C.E. (liebroekstraat 43 3545 Halen BE0446888007) .
#Deze code mag niet aan derden (ook niet VNZ en NZVL) getoond worden tenzij met uitdrukkelijke en schriftelijke toestemming van Hospiplus en I.C.E. bvba .
#Indien dit toch gebeurt is er een boete verschuldigd van 250.000 € exclusief btw aan de Firma  I.C.E.
#Dit geldt ook voor het kopieren van een stuk code of het repliceren van technieken gehanteerd in dit programma
#I.C.E. beheert de broncode je mag  veranderingen aanbrengen aan het programma . Deze worden samen met de documentatie overgedragen aan I.C.E. .
#I.C.E. beslist dan op deze veranderingen worden doorgevoerd.

#Door het openen van deze broncode stem je in met de voorgaande voorwaarden.

#De gerechtigden om deze broncode te bekijken zijn Christian Bruyninckx , Michel Gielens en Ben Van Massenhoven.
#Harry Conings beheert voor I.C.E de broncode
use strict;
use vars qw(%settings);

sub settings {
     my $zkf_nr_set = shift @_;
     if ($zkf_nr_set == 203) {
         #instellingen 203
         %settings = (
                'user_name' => 'M203CGK2',                #username SIS203'
                'password' => 'CKG2M203',                           #paswoord SIS203
                'name_as400' =>  'airbus',                 #naam van de as400
                'toelating_fil' => "libcxcom20.PSDDS5 ",    #hier kan men zien of iemand in een  rusthuis is
                'adres_fil' =>  "libcxfil03.PADRJR",      #naam van de adres file 
                'pers_fil' =>  "libcxfil03.PFYSL8",       #naam van de file met de persoonlijke gegevens
                'cg_fil' =>  "libcxfil03.PCCTGD",         #waar de cg1/cg2 code kan vinden
                'basis_fil' =>  "libcxcom20.PHBE42",      #file met alle betaginen en tussen komsent
                'basis_fil1' =>  "libcxarh20.PXBE42",  # data van de laatste 3 jaar
                'basis_fil2' =>  "libcxari20.PYBE41",  #data van langer dan 3 jaar geleden
                'pdoskj_fil' =>  "libcxfil03.PDOSKJ",     #file met dossier en verzekeringenµ
                'phoekk_fil' =>  "libcxfil03.PHOEKK",
                'ptaxkq_fil' =>  "libcxfil03.PTAXKQ",     # file met de betalingen in
                'carens_fil' =>  "libsxfil03.CARENS",     #file met de carensdagen
                'ascard_fil' =>  "libcxcom20.ASCARD",      #file met assuracard gegevens
                'aswift_fil' =>  "libcxcom20.ASWIFT",      #file met omzetting IBAN ->swift klanten
                'bban_iban_lev_fil' =>  "libcxcom20.AIBAN", #file met omzetting bbdan iban swift leveranciers
                'ascard_batchnr_fil' =>  "libcxcom20.ASBATCH",   #file met assuracard gegevens van de batchnrs
                'mobgev_fil' => "libsxfil03.MOBGEVN",
                'pben_fil' => "libcxfil03.PBEN17",
                'prek_fil' => "libcxfil03.PREKKW",
                'commentaar_fil'=> "libcxfil03.PCOMGK",
                'gkd_hist_fil' => "jadebus203.WWWCONTAC",
                'email_fil' => "libcxfil03.PEMWVL",
                'office' => 0,
                'section' => 200,
                'hospiplan_051_ambuplan'=>  51,
                'ambuplan_063' => 63,
                'hospiplus_052_ambuplus'  =>  52,
                'ambuplus_064' => 64,
                'hospiplus_062' => 62,
                'hospiplan_061' => 61,
                'hospiforfait' =>  39,
                'hospicontinue' => 53,
                'zkfnummer' => 203,
                'HF_formule1' => 22,
                'HF_formule2' => 21,
                'HF_formule3' => 24,
                'pathtofiles' => "W:\\OGV\\UITBETALINGEN",
                'sjabloonplaats' => "W:\\OGV\\BRIEFWISSELING\\Sjablonen",
                'documentplaatst_brieven' => "W:\\OGV\\BRIEFWISSELING\\Documenten",
                'documentplaatst_etiketten' => "W:\\OGV\\BRIEFWISSELING\\etiketten",
                'pathtoprogram' => "C:\\macros\\mob",
                #'sjabloonplaats' =>  "C:\\macros\\mob\\sjabloon_odt",
                #'documentplaatst_brieven' => "C:\\macros\\mob\\ooopslag"
                
            )
        }elsif ($zkf_nr_set == 235){
         #instellingen 235
         %settings = (
                'user_name' => 'M235CGK2',                #username M235SIS
                'password' => 'cegeka2016',                 #paswoord SIS235
                'name_as400' =>  'airbus',                 #naam van de as400
                'toelating_fil' => "libcxcom20.PSDDS5 ",    #hier kan men zien of iemand in een  rusthuis is
                'adres_fil' =>  "libcxfil35.PADRJR",      #naam van de adres file 
                'pers_fil' =>  "libcxfil35.PFYSL8",       #naam van de file met de persoonlijke gegevens
                'cg_fil' =>  "libcxfil35.PCCTGD",         #waar de cg1/cg2 code kan vinden
                'basis_fil' =>  "libcxcom20.PHBE42",      #file met alle betaginen en tussen komsent
                'basis_fil1' =>  "libcxarh20.PXBE42",  # data van de laatste 3 jaar
                'basis_fil2' =>  "libcxari20.PYBE41",  #data van langer dan 3 jaar geleden
                'pdoskj_fil' =>  "libcxfil35.PDOSKJ",     #file met dossier en verzekeringen
                'phoekk_fil' =>  "libcxfil35.PHOEKK",
                'ptaxkq_fil' =>  "libcxfil35.PTAXKQ",     # file met de betalingen in
                'carens_fil' =>  "libsxfil03.CARENS",
                'ascard_fil' =>  "libcxcom20.ASCARD",      #file met assuracard gegevens
                'aswift_fil' =>  "libcxcom20.ASWIFT",
                'bban_iban_lev_fil' =>  "libcxcom20.AIBAN", #file met omzetting bbdan iban swift leveranciers
                'ascard_batchnr_fil' =>  "libcxcom20.ASBATCH",   #file met assuracard gegevens van de batchnrs
                'mobgev_fil' => "libsxfil03.MOBGEVN",
                'pben_fil' => "libcxfil35.PBEN17",
                'prek_fil' => "libcxfil35.PREKKW",
                'email_fil' => "libcxfil35.PEMWVL",
                'commentaar_fil'=> "libcxfil35.PCOMGK",
                'gkd_hist_fil' => "jadebus235.WWWCONTAC",
                'office' => 0,
                'section' => 0,
                'hospiplan_051_ambuplan'=>  51,
                'ambuplan_063' => 63,
                'hospiplus_052_ambuplus'  =>  52,
                'ambuplus_064' => 64,
                'hospiplus_062' => 62,
                'hospiplan_061' => 61,
                'hospiforfait' =>  50,
                'hospicontinue' => 53,
                'zkfnummer' => 235,
                'HF_formule1' => 10,
                'HF_formule2' => 11,
                'HF_formule3' => 12,
                'pathtofiles' => "W:\\OGV\\UITBETALINGEN",
                'sjabloonplaats' => "W:\\OGV\\BRIEFWISSELING\\Sjablonen",
                'documentplaatst_brieven' => "W:\\OGV\\BRIEFWISSELING\\Documenten",
                'documentplaatst_etiketten' => "W:\\OGV\\BRIEFWISSELING\\etiketten",
                'pathtoprogram' => "C:\\macros\\mob",
                # 'pathtofiles' => "C:\\macros\\mob\\ooopslag",
                #'sjabloonplaats' =>  "C:\\macros\\mob\\sjabloon_odt",
                #'documentplaatst_brieven' => "C:\\macros\\mob\\ooopslag"
            )
         
        }else {
             die;
        }
    }
1;

