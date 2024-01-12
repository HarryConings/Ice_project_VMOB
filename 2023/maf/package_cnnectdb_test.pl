#!/usr/bin/perl -w
#subroutine connecteerd naar de database via odbc van de as400
#gebruik &connectdb (username,password,naam van de as400)
#geeft de naam van de database terug
my $test = connectdb->connect_as400('m235paus','harry01','10.198.10.6');
package connectdb;
use strict;
use DBD::ODBC;
use DBI;
    sub connect_as400 {
        my ($class,$user_name,$password,$as400) = @_;
        #my $user_name= shift @_;     	     #username as400
        #my $password= shift @_;              #paswoord
        #my $as400= shift @_;                 #naam as400
        my $DSN="driver={iSeries Access ODBC Driver};System=$as400";
        # connect to database
        #
        my %attr = (
             PrintError => 0,
             RaiseError => 0,
            );
        my $dbh;
        my $teller=0;
        until (
             $dbh = DBI->connect("dbi:ODBC:$DSN",$user_name,$password,\%attr)
        ){
          $teller +=1;  
          print "\npoging $teller ->Can't connect: $DBI::errstr. Pausing before retrying.\n";
          sleep( 10 );
          die if ($teller > 2);          
        }
        $dbh->{RaiseError} = 1;
        $dbh->{PrintError} = 1;
        #$dbh = DBI->connect("dbi:ODBC:$DSN",$user_name,$password) or die "Couldn't connect to database: " . connectdb->errstr($user_name,$password,$as400);
        #
        #  dbh->disconnect;
        return ($dbh);
    }

    sub disconnect {
        my ($class,$dbh) = @_;
        $dbh->disconnect;
    }
    
   
1;