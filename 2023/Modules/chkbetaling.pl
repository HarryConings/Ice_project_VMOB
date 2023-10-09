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
use DBD::ODBC;
use DBI;
#versie 5
# we hebben nodig als input
#my $nr_zkf = shift @_ ;
#     my $type_verz= shift @_;
#     my $externnummer = shift @_;
#     my $betaling_fil = shift @_;
#     my $dbh = shift @_;
# subroutine geeft terug  nr-zkf,nr_extern,type_verz,jaar laatste bet,maandlaatste bet, bedrag,saldo,totaal al gestord

sub checkbetaling {
     my $nr_zkf = shift @_ ;
     my $type_verz= shift @_;
     my $externnummer = shift @_;
     my $betaling_fil = shift @_;
     my $dbh = shift @_;
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
     my $sqlbetaling =("SELECT IDFDKQ,EXIDKQ,ABTVKQ,ABVYKQ,ABVMKQ,ABCNKQ,ABCOKQ,AT79KQ FROM $betaling_fil WHERE IDFDKQ = $nr_zkf and EXIDKQ  = $externnummer and ABTVKQ  = $type_verz ");
     my $sthbetaling = $dbh->prepare( $sqlbetaling );
     $sthbetaling ->execute();
     my @betalingen = () ;
     my @laatstebetaling=();
     my $rijenteller = 0;
     my $hebben_nooit_betaald =0;
     my %betalingenh = ();
     my $k;
     my $kold =0;
     my $eerste = 1;
     my $jaarb =0;
     my $maandb = 0;
     my $bedragb = 0;
     my $saldob =0;
     my $totb =0;
     while(@betalingen =$sthbetaling ->fetchrow_array)  {
         $betalingenh{($betalingen[3]*100+$betalingen[4])}{'betaald'} += $betalingen[5]; #zien of er gecrditeerd wordt        
         $betalingenh{($betalingen[3]*100+$betalingen[4])}{'jaar'} = $betalingen[3]; 
         $betalingenh{($betalingen[3]*100+$betalingen[4])}{'maand'} = $betalingen[4];
         $betalingenh{($betalingen[3]*100+$betalingen[4])}{'bedrag'} = $betalingen[5];
         $betalingenh{($betalingen[3]*100+$betalingen[4])}{'saldo'} = $betalingen[6];
         $betalingenh{($betalingen[3]*100+$betalingen[4])}{'totaal'} = $betalingen[7];
         #print "@betalingen->\n";
         if ($rijenteller== 0) {
           $jaarb = $betalingen[3]; #code
           $maandb =$betalingen[4];
           $hebben_nooit_betaald =1;
         }
         
         $rijenteller +=1;
         
        }
     foreach $k (sort keys %betalingenh) {
          
         if (($eerste == 1) and ($betalingenh{$k}{'saldo'} == 0 ) or $betalingenh{$k}{'betaald'} == 0  ) {
            $kold = $k;
            #print "->eerste -kold $kold \n";
            $jaarb = $betalingenh{$k}{'jaar'} ;
            $maandb = $betalingenh{$k}{'maand'};
            $bedragb = $betalingenh{$k}{'bedrag'};
            $saldob = $betalingenh{$k}{'saldo'};
            $totb = $betalingenh{$k}{'totaal'};
            $eerste = 0;
            $hebben_nooit_betaald =0;
         }
         if (($k > $kold) and  ($betalingenh{$k}{'saldo'} == 0  or $betalingenh{$k}{'betaald'} == 0 ) ){
            $kold = $k;
            #print "->tweede -kold $kold \n";
            $jaarb = $betalingenh{$k}{'jaar'} ;
            $maandb = $betalingenh{$k}{'maand'};
            $bedragb = $betalingenh{$k}{'bedrag'};
            $saldob = $betalingenh{$k}{'saldo'};
            $totb = $betalingenh{$k}{'totaal'};
            $hebben_nooit_betaald = 0;
        }
      #print "$betalingenh{$k}{'jaar'} $betalingenh{$k}{'maand'} $betalingenh{$k}{'bedrag'}  $betalingenh{$k}{'saldo'} $betalingenh{$k}{'totaal'}\n";
      #print  "->$jaarb,$maandb,$bedragb,$saldob,$totb\n";    
     }
     return ($jaarb,$maandb,$bedragb,$saldob,$totb,$hebben_nooit_betaald );
    }
1;