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
#subroutine connecteerd naar de database via odbc van de as400
#gebruik &connectdb (username,password,naam van de as400)
#geeft de naam van de database terug
use strict;
use DBD::ODBC;
use DBI;
    sub cnnectdb {

        my $user_name= shift @_;     	     #username as400
        my $password= shift @_;              #paswoord
        my $as400= shift @_;                 #naam as400
        my $DSN="driver={iSeries Access ODBC Driver};System=$as400";
        # connect to database
        #
        my $dbh = DBI->connect("dbi:ODBC:$DSN",$user_name,$password) or die "Couldn't connect to database: " . BDI->errstr;
        #
        #  dbh->disconnect;
        return ($dbh)
    }

    sub dscnnectdb {
        my $dbh = shift @_;
        $dbh->disconnect;
    }
1;