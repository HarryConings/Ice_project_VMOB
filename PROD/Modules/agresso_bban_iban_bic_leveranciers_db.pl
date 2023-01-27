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
use vars qw(%settings);
require "settings_prod.pl";
require "cnnectdb_prod.pl";
#&delete_db;
#&maakdatabase_bban_iban_bic_lev ($settings{'bban_iban_lev_fil'},$dbconnectie);
sub maakdatabase_bban_iban_bic_lev{
     my $mob_cardinfo = shift @_ ;
     my $dbh = shift @_;
     #BBAN
     #IBAN
     #swift
      my $sql = $dbh ->do ("CREATE TABLE $mob_cardinfo (
             BBAN   VARCHAR(20),
             IBAN   VARCHAR(40) ,
             SWIFT  VARCHAR(34) 
               )");
     print "Returns $sql\n";
     return ($sql);
     print "$sql";
}
sub maak_nieuwe_conversie_lev {
     my $DSN="driver={iSeries Access ODBC Driver};System=AIRBUS";
     my $dbh = DBI->connect("dbi:ODBC:$DSN",'sis203','sis203') or die "Couldn't connect to database: " . BDI->errstr;
     my $bban = shift @_;
     my $iban =shift @_;
     my $swift = shift @_;
      $iban =~ s/\s//g;
      $swift =~ s/\s//g;
      my $zetin = "INSERT INTO libcxcom20.AIBAN values (?,?,?)";
      my $sth= $dbh ->prepare($zetin);
      $sth->bind_param(1,$bban);
      $sth->bind_param(2,$iban);
      $sth->bind_param(3,$swift);
      $sth -> execute();
      $sth -> finish();
      $dbh->disconnect;
}
sub zoek_conversie_bban_lev {
     my $DSN="driver={iSeries Access ODBC Driver};System=AIRBUS";
     my $dbh = DBI->connect("dbi:ODBC:$DSN",'sis203','sis203') or die "Couldn't connect to database: " . BDI->errstr;
     my $bban = shift @_;
     $bban=~ s/\s//g;
     my ($iban,$swift) = $dbh->selectrow_array("SELECT IBAN,SWIFT FROM libcxcom20.AIBAN WHERE BBAN =$bban");
     $dbh->disconnect;
     #print"";
     if (defined $swift) {
         #print "IBAN $iban   BIC ->$swift gevonden in locale DB\n";
         return ($iban,$swift);#code
     }else {
         return ('NOT_IN_DB','NOT_IN_DB');
     }
     
}
sub zoek_conversie_iban_lev {
     my $dbh = shift @_;
     my $iban = shift @_;
     my ($bban,$swift) = $dbh->selectrow_array("SELECT IBAN,SWIFT FROM libcxcom20.AIBAN WHERE IBAN ='$iban'");
 
     if (defined $swift) {
         #print "IBAN $iban   BIC ->$swift gevonden in locale DB\n";
         return ($iban,$swift);#code
     }else {
         return ('NOT_IN_DB','NOT_IN_DB');
     }
     
}
sub delete_db {
     my $DSN="driver={iSeries Access ODBC Driver};System=AIRBUS";
     my $dbh = DBI->connect("dbi:ODBC:$DSN",'sis203','sis203') or die "Couldn't connect to database: " . BDI->errstr;
     my $sql =("DELETE  FROM libcxcom20.AIBAN "); 
     my $sth = $dbh->prepare( $sql );
     $sth->execute();
     $dbh->disconnect;
}

1;