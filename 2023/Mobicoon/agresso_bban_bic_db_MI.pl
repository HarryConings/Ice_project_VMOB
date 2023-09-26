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
use strict;
use vars qw($settings);
#&settings(203);
##&update_conversie;
#my $dbconnectie = &cnnectdb ($settings{user_name},$settings{password},$settings{name_as400});
#&delete_this ($dbconnectie);
#&update_conversie($dbconnectie);
##&verleng_swift($dbconnectie);
##&maakdatabase_bban_bic($settings{'aswift_fil'},$dbconnectie);
sub maakdatabase_bban_bic{
     my $mob_cardinfo = shift @_ ;
     my $dbh = shift @_;
     #IBAN
     #swift
      my $sql = $dbh ->do ("CREATE TABLE $mob_cardinfo (
             IBAN   VARCHAR(30) ,
             SWIFT  VARCHAR(10) 
               )");
     print "Returns $sql\n";
     return ($sql); 
}
sub maak_nieuwe_conversie {
      my $dbh = shift @_;
      my $iban = shift @_;
      $iban =~ s/\s//g;
      my $swift = shift @_;
      my $zetin = "INSERT INTO $settings->{'aswift_fil'} values (?,?)";
      my $sth= $dbh ->prepare($zetin);
      $sth->bind_param(1,$iban);
      $sth->bind_param(2,$swift);
      $sth -> execute();
      $sth -> finish()
}
sub zoek_conversie {
     my $dbh = shift @_;
     my $iban = shift @_;
     my $swift = $dbh->selectrow_array("SELECT SWIFT FROM $settings->{'aswift_fil'} WHERE IBAN ='$iban'");
     if (defined $swift) {
         #print "IBAN $iban   BIC ->$swift gevonden in locale DB\n";
         return ($swift);#code
     }else {
         return ('NOT_IN_DB');
     }
     
}
sub update_conversie {
     my $dbh = shift @_;
     #my $updatethis = $dbh ->do("UPDATE $settings{'aswift_fil'} set SWIFT  = 'WEETNIET' WHERE IBAN='BE18990000000065'");
     my $updatethis = $dbh ->do("UPDATE $settings->{'aswift_fil'} set SWIFT  = 'WEETNIET' WHERE IBAN='BE00990000000065'");
}
sub verleng_swift {
     my $dbh = shift @_;
     my $updatethis = $dbh ->do("ALTER TABLE $settings->{'aswift_fil'} ALTER COLUMN SWIFT SET DATA TYPE VARCHAR(34) ");
}

sub delete_this {
      my $dbh = shift @_;
      my $sql =("DELETE FROM $settings->{'aswift_fil'} WHERE SWIFT ='niet_gevonden' ");
      #print "$sql";
      my $sth = $dbh->prepare( $sql );
      $sth->execute();
}
1;