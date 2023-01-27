#!/usr/bin/perl -w
use strict;
use DBI;
use DBD::ODBC;
require 'package_cnnectdb_prod.pl';
my $placeholders= '301011, 301033, 301055, 301070, 301092, 301114, 301151, 301173, 301195, 301210, 301254,
	 301276, 301291, 301313, 301335, 301350, 301372, 301593, 301696, 301711, 301733, 301755, 301770, 301976, 302153, 302175,
	 302190, 302212, 302234, 303575, 303590, 303612, 303774, 304135, 304150, 304172, 304194, 304312, 304371, 304393, 304415,
	 304430, 304452, 304533, 304555, 304570, 304754, 304776, 304850, 304872, 304894, 304916, 304931, 305012, 305034, 305056,
	 305071, 305211, 305233, 305255, 305270, 305292, 305550, 305572, 305616, 305631, 305653, 305675, 305734, 305830, 305852,
	 305874, 305911, 305933, 305955, 306832, 306854, 306876, 306891, 306913, 306935, 307016, 307031, 307053, 307090, 307112,
	 307134, 307230, 307252, 307274, 307731, 307753, 307775, 307790, 307812, 307834, 307856, 307871, 307893, 307915, 307930,
	 307952, 307974, 307996, 308011, 308033, 308055, 308070, 308092, 308114, 308136, 308151, 308335, 308350, 308512, 308534,
	 309013, 309035, 309050, 309072, 309094, 309116, 309131, 309153, 309514, 309536, 309551, 309573, 309595, 309610, 309632,
	 309654, 309676, 309691, 309713, 309735, 309750, 371011, 371033, 371055, 371070, 371092, 371114, 371151, 371195, 371254,
	 371571, 371615, 371696, 371711, 371733, 371755, 371770, 372514, 372536, 373575, 373590, 373612, 373634, 373656, 373774,
	 373811, 373833, 373855, 373892, 373914, 373936, 373951, 373973, 373135, 374150, 374172, 374194, 374312, 374356, 374371,
	 374393, 374415, 374430, 374452, 374474, 374533, 374555, 374570, 374754, 374776, 374850, 374872, 374931, 375012, 375034,
	 375056, 375071, 375211, 375233, 375255, 375270, 375292, 377016, 377031, 377053, 377090, 377112, 377134, 377230, 377274,
	 378335, 378350, 378954, 378976, 379013, 379035, 379050, 379072, 379094, 379116, 379131, 379153, 379514, 379536, 379551,
	 389631, 389653, 389675, 389690, 389712, 389734, 389756, 389771, 389793, 389815, 389830, 389852, 389874, 389896, 389911';
$placeholders =~ s/\n//g;
$placeholders =~ s/\t//g;
$placeholders =~ s/\s+//g;
my $ext=10917920276;
#my $dbh = connectdb->connect_as400('M235CGK2','cegeka2016','AIRBUS');
my $dbh = connectdb->connect_as400('M203CGK2','CKG2M203','AIRBUS');
my $basis_fil= "libcxcom20.PHBE42";    #zoeken op ziekenfondsnr + externnummer is snel
my $preni_fil= "libcxcom20.PRENI1";    #herieuwingen
my $nomenclatuurcheck = ("SELECT  *
                             FROM  $basis_fil WHERE EXID42= $ext and IDFD42=203 and XB8042 IN (2021,2020,2019)
                             and YN0142 IN ($placeholders) ORDER BY XB1142,XB1242 asc");
                            #and YN0142 IN ($placeholders)  XB8042 >= 2006 andXB8042 IN ($berekeningsjaren) and IDFD42=$zkf and
                             
    my $sth = $dbh->prepare( $nomenclatuurcheck );
    $sth->execute();
    my $teller =0;
    print "$basis_fil\n___________________\nvoor extern nr $ext\n";
    
    while (my @basisstuknrs = $sth->fetchrow_array)  {
            $teller +=1;
            #print "$teller -> @basisstuknrs\n";
            print "$teller->$basisstuknrs[0]$basisstuknrs[1]$basisstuknrs[2]$basisstuknrs[3]$basisstuknrs[4 ] remgeld $basisstuknrs[13] prestatiedatum $basisstuknrs[6] $basisstuknrs[7] $basisstuknrs[8] nomenclatuur  $basisstuknrs[5]  \n" ;
            print '';            
        }
   print "\n\n";
     #PRENI1 in libcxcom20
    #IDFDI1 = nummer van het ziekenfonds
    #EXIDI1 = extern nummer
    #YN01I1 = nummer van de nomenclatuur
    #XB81I1 = datum verstrekkin
    #EABFI1 = nummer van het hospitaal
    #XB86I1 = basisstuknummer
    #XB85I1 = tarrificatiedatum
    #XB13I1 = aantal gevallen
    #XB27I1 = verzekeringskode
    #XB45I1 = prestatiecode
    #IDENI1 = identieficatienummer van de gerechtigde
    #YN01I1              CODE NOMENCLATURE       /NOMEN
    #XB15I1              MONTANT SOINS SANTE C.C./BEDRA
    #SUBSTR(XB86I1,1,12),SUBSTR(XB86I1,12,7),YN01I1,XB81I1,XB13I1,XB15I1,
    my $sqlher =("SELECT * FROM $preni_fil WHERE IDFDI1= 235 and EXIDI1 = $ext and YN01I1 IN ($placeholders)
                 and SUBSTR(XB81I1,1,4)IN (2021,2020,2019)  ");
    #and  EXIDI1 = 810003964837and (EXIDI1 =810002007861 or EXIDI1=810002058280) and (EXIDI1 =810002704544 or EXIDI1 =810002692824 or EXIDI1=810001941678 or EXIDI1=10945780292) 
    my $sthher = $dbh->prepare( $sqlher );
    $sthher->execute();
    my $aantalrij_her=0;
      while(my @mijnrijher=$sthher->fetchrow_array)  {
                $aantalrij_her +=1;
                print "$aantalrij_her -> @mijnrijher\n";
        }
    print "\n\n";