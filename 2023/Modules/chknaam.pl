#!/usr/bin/perl -w
use strict;
use DBD::ODBC;
use DBI;
use vars qw(%settings);

require "cnnectdb_prod.pl";
# subroutine om de naam en het nationaal register nummer te halen via het extern nummer
# gebruik &chknaam (externnummer,libcxfilxx.PFYSL8,databaseconnectie)
# geeft terug :
    #@naamrij   :EXIDL8 = extern nummer,KNRNL8 = nationaalt register nummer
    #           :NAMBL8 = naam van de gerechtigde,PRNBL8 = voornaam van de gerechtigde
    #           :SEXEL8 = code van het geslacht,NAIYL8 = geboortejaat,NAIML8 = geboortemaand,NAIJL8 = geboortedag
sub checknaamextern {
   my $externnummer = shift @_;
   my @naamrij;
   my $dbh = &cnnectdb ($settings{user_name},$settings{password},$settings{name_as400}); 
   #openen van PFYSL8
   # EXIDL8 = extern nummer
   # KNRNL8 = nationaalt register nummer
   # NAMBL8 = naam van de gerechtigde
   # PRNBL8 = voornaam van de gerechtigde
   # SEXEL8 = code van het geslacht
   # NAIYL8 = geboortejaat
   # NAIML8 = geboortemaand
   # NAIJL8 = geboortedag
   # LANGL8 = taal code
   @naamrij = $dbh->selectrow_array("SELECT EXIDL8,KNRNL8,NAMBL8,PRNBL8,SEXEL8,NAIYL8,NAIML8,NAIJL8,LANGL8 FROM $settings{'pers_fil'} WHERE EXIDL8=$externnummer");
   #print "inz = $naamrij[1]\n";
   #print "extern = $naamrij[0]\n";
   my $element;
   foreach $element (@naamrij) { #verwijder de leading en trailing spaces
      $element =~ s/^\s+//;
      $element =~ s/\s+$//;
    }
   &dscnnectdb ($dbh);
   return (@naamrij);
  }
1;
#