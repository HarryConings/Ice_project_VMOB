#!/usr/bin/perl -w
#zie of er dubbels zijn
use strict;
use DBI::DBD;
require "package_cnnectdb_MI.pl";
print '203';
 my $dbh = connectdb->connect_as400 ('sis203','sis203','airbus') ;
 my $sql =("SELECT MAX(CONTACTID) FROM jadebus203.WWWCONTAC WHERE ORG = 203 ORDER BY CONTACTID DESC fetch first 10 rows only");
  #my $sql =("SELECT CONTACTID FROM jadebus203.WWWCONTAC c1, jadebus203.WWWCONTAC c2 WHERE ORG = 203 and c1.CONTACTID=c2.CONTACTID");
  my $sth = $dbh->prepare( $sql );
 $sth->execute();
 while(my @volgnr =$sth->fetchrow_array)  {
     print "@volgnr\n";
    }
 print '203 einde';
 print "n";
 $dbh->disconnect;
 print '235';
 $dbh = connectdb->connect_as400 ('M235CGK2','cegeka2016','airbus') ;
 $sql =("SELECT * FROM jadebus235.WWWCONTAC WHERE ORG = 235  ORDER BY CONTACTID DESC fetch first 10 rows only");
  #my $sql =("SELECT CONTACTID FROM jadebus203.WWWCONTAC c1, jadebus203.WWWCONTAC c2 WHERE ORG = 203 and c1.CONTACTID=c2.CONTACTID");
 $sth = $dbh->prepare( $sql );
 $sth->execute();
 while(my @volgnr =$sth->fetchrow_array)  {
     print "@volgnr\n";
    }
 print '235 einde';
 $dbh->disconnect;