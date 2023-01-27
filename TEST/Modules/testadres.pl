#!/usr/bin/perl -w
use strict;
use strict;
use XML::Simple;
use Date::Manip::DM5 ;
use Date::Calc qw(:all);
use Scalar::MoreUtils qw(empty);
use Data::Dumper;
use XML::Compile::Schema;
use XML::LibXML::Reader;
use XML::SAX;
use Net::SMTP;
use File::Slurp;
use utf8;
use Text::Unidecode;
require "settings_prod.pl";
require "cnnectdb_prod.pl";
require "bban_to_bic.pl";
require "chkbetaling.pl";
our $agresso_instellingen;
our $test_prod = 'TEST'; # test = 'TEST' productie = 'PROG'
&load_agresso_setting("P:\\OGV\\ASSURCARD_$test_prod\\assurcard_settings_xml\\agresso_klanten_generatie_settings.xml");
our %settings = &settings(235);
our $dbh = &cnnectdb ($settings{user_name},$settings{password},$settings{name_as400});
my $ext= &checknaamnextern;
&checkadres($ext,235);
sub load_agresso_setting  {
     my $file_name = shift @_;
     $agresso_instellingen = XMLin("$file_name");
     print "ingelezen\n";
     #maak verzekeringen

    }
sub checknaamnextern {
                 
                  #openen van PFYSL8
                  # EXIDL8 = extern nummer
                  # KNRNL8 = nationaalt register nummer
                  # NAMBL8 = naam van de gerechtigde
                  # PRNBL8 = voornaam van de gerechtigde
                  # SEXEL8 = code van het geslacht
                  # NAIYL8 = geboortejaat
                  # NAIML8 = geboortemaand
                  # NAIJL8 = geboortedag
			   my $pers_fil = $settings{pers_fil};
                  my @naamrij = $dbh->selectrow_array("SELECT EXIDL8,KNRNL8,NAMBL8,PRNBL8,SEXEL8,NAIYL8,NAIML8,NAIJL8,KVPSL8 FROM $pers_fil WHERE KNRNL8=83021910515");
                  return ($naamrij[0])
}
sub checkadres {    
     my $extern_nummer  = shift @_;
     my $zkf_nummer = shift @_;
     #openen van PADRJR op as400
     # EXIDJR = extern nummer
     # ABGIJR = soort adres post of gewoon post =02
     # ABKTJR = naam van de bewoner van het postadress
     # ABSTJR = naam van de straat
     # ABNTJR = huisnnummer
     # ABBTJR = busnummer
     # IV00JR = kode van het land
     # ABPTJR = postnummer
     # ABWTJR = woornplaats
     # IDFDJR = NUMMER ZIEKENFOND
     # ER ZIJN DUBBEL ENTRIES VOOR POSTADRES EN GEWOON ADRES WE KIJKEN OF ER EEN POSTADRES IS
     # het postadres heeft ABGIJR == 02 dit gaan we zoeken
     # KGERJR = srtaat kode
     # ABTPJR  = INTERNAT.PREFIX TELNR
     # ABTEJR  = TELEFOONNUMMER
     # PGSMJR  = INT. PREFIX GSM-NR
     # NGSMJR = GSM-NUMMER
     my $sql =("SELECT EXIDJR,ABGIJR,ABKTJR,ABSTJR,ABNTJR,ABBTJR,IV00JR,ABPTJR,ABWTJR,ABTPJR,ABTEJR,PGSMJR,NGSMJR
                                           FROM $settings{'adres_fil'} WHERE EXIDJR= $extern_nummer "); #and ABGIJR = '01'
     my $sth = $dbh->prepare( $sql );
     $sth->execute();
      while(my @mijnrij=$sth->fetchrow_array)  {
          print "@mijnrij\n";
          }
     
}