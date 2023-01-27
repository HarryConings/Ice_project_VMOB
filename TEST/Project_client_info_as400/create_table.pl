#!/usr/bin/perl -w
#in GIT gezet
#OPGELET!!!!!!
#Dit programma is auteursrechtelijk beschermd.
#Deze code is voor 100% eigendom van de Firma  I.C.E. (liebroekstraat 43 3545 Halen BE0446888007) .
#Deze code mag niet aan derden (ook niet VNZ en NZVL) getoond worden tenzij met uitdrukkelijke en schriftelijke toestemming van Hospiplus en I.C.E. bvba .
#Indien dit toch gebeurt is er een boete verschuldigd van 250.000 € exclusief btw aan de Firma  I.C.E.
#Dit geldt ook voor het kopieren van een stuk code of het repliceren van technieken gehanteerd in dit programma
#I.C.E. beheert de broncode je mag  veranderingen aanbrengen aan het programma . Deze worden samen met de documentatie overgedragen aan I.C.E. .
#I.C.E. beslist dan op deze veranderingen worden doorgevoerd.
#Door het openen van deze broncode stem je in met de voorgaande voorwaarden.
#De gerechtigden om deze broncode te bekijken zijn Christian Bruyninckx , Michel Gielens en Ben Van Massenhoven.
#Harry Conings beheert voor I.C.E de broncode
#code weigering is 06 in PTRAXKQ
  #Field      Type       Length  Length  Position        Usage    Heading                            
  #ABPYKQ     PACKED       2  0       2       139        Both     MODE PERCEP.                       
  #                                                               WIJZE VORDERING                    
  #  Field text  . . . . . . . . . . . . . . . :  MODE DE PERCEPTION      /WIJZE VAN VORDERING       
                                           
                                                                                                    
use strict;
use XML::Simple;
use Time::Piece;
use Time::Seconds;
require 'Decryp_Encrypt.pl';
package main;
my $eind_datum;
my $zes_maanden_geleden;

my $instellingen = XMLin('P:\OGV\ASSURCARD_PROG\assurcard_settings_xml\Poject_AS400_settings.xml');
#decript password
$instellingen = main->decrypt_paswoord($instellingen);
print '';
AS400->create_GED_COUNTERDATABANG 
    

1;
    sub decrypt_paswoord {
        my ($self,$agresso_instellingen) = @_;
        foreach my $zkf (keys $agresso_instellingen->{ziekenfondsen}){
            $agresso_instellingen->{ziekenfondsen}->{$zkf}->{as400}->{password} =decrypt->new( $agresso_instellingen->{ziekenfondsen}->{$zkf}->{as400}->{password});            
        }
       return($agresso_instellingen);     
    }

 
     
package AS400;
    use DBD::ODBC;
    use DBI;  
    use Unicode::String qw(utf8 latin1 utf16le);
    sub create_GED_COUNTERDATABANG {
           my ($zkf_org,$zkf_dest) = @_;
           my $link = $instellingen->{ziekenfondsen}->{$zkf_org}->{as400};
           my $libcxfil= $link->{libcxfil},
           my $COUNTERDATABANG = "$link->{libcxfil}\.GED_COUNTERDATABANG";
           my $dbh = AS400->cnnectdb($link->{username},$link->{password},$link->{as400_name});
           my $sql =("SELECT NAME,COLTYPE,NULLS,LONGLENGTH FROM SYSIBM.SYSCOLUMNS where TBcreator =$libcxfil and TBNAME =GED_COUNTERDATABANG");
           my $sth = $dbh->prepare( $sql );
           $sth->execute();
           while(my @info =$sth->fetchrow_array)  {
             print "@info\n";
            }
           AS400->dscnnectdb($dbh);
    }
    sub create_GED_FLUXDATABANG {
           my ($zkf) = @_;
           my $link = $instellingen->{ziekenfondsen}->{$zkf}->{as400};                      
           my $dbh = AS400->cnnectdb($link->{username},$link->{password},$link->{as400_name});
           AS400->dscnnectdb($dbh);
    }
    sub create_GED_WORKFLOWS_TYPES {
           my ($zkf) = @_;
           my $link = $instellingen->{ziekenfondsen}->{$zkf}->{as400};                      
           my $dbh = AS400->cnnectdb($link->{username},$link->{password},$link->{as400_name});
          AS400->dscnnectdb($dbh);
    }
    sub create_GED_DOCTYPES  {
           my ($zkf) = @_;
           my $link = $instellingen->{ziekenfondsen}->{$zkf}->{as400};                      
           my $dbh = AS400->cnnectdb($link->{username},$link->{password},$link->{as400_name});
           AS400->dscnnectdb($dbh);
    }
    sub create_GED_DOCTYPES_WORDING  {
           my ($zkf) = @_;
           my $link = $instellingen->{ziekenfondsen}->{$zkf}->{as400};                      
           my $dbh = AS400->cnnectdb($link->{username},$link->{password},$link->{as400_name});
           AS400->dscnnectdb($dbh);
    }
    sub cnnectdb {
        my ($self,$user_name,$password,$as400) =@_;
        	     #username as400
                 #paswoord
                 #naam as400
        my $DSN="driver={iSeries Access ODBC Driver};System=$as400";
        # connect to database
        #
        my $dbh = DBI->connect("dbi:ODBC:$DSN",$user_name,$password) or die "Couldn't connect to database: " . BDI->errstr;
        #
        #  dbh->disconnect;
        return ($dbh)
    }

    sub dscnnectdb {
        my ($self,$dbh) = @_;
        $dbh->disconnect;
    }