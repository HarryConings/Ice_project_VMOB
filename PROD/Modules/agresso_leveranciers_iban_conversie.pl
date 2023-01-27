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
require 'agresso_bban_iban_bic_leveranciers_db.pl';
#&send_via_webserv_client ('BE35001705787537');BE16 0014 5510 4474
#&iban__via_webserv_client('001-4551044-74');

sub iban__via_webserv_client {
     use SOAP::Lite 
         +trace => [ transport => sub { print $_[0]->as_string } ];
     use XML::Compile::SOAP12::Client;
     use XML::Writer;
     use XML::Writer::String;
     my $BBan = shift @_;
     $BBan  =~ s/\s//g;
     $BBan =~ s/-//g;
     my $IBAN ='';
     my $BIC = '';
     if ($BBan =~ m/BE\d+/) {
         $IBAN = $&;#code
         $BBan = substr ($IBAN,4,12);
         my ($iban,$swift)= &zoek_conversie_bban_lev ($BBan );
         if ($iban eq 'NOT_IN_DB') {
             my $soap = SOAP::Lite
                 -> proxy('http://www.ibanbic.be/IBANBIC.asmx?op=BBANtoBIC')
                 -> uri('http://tempuri.org/')
                 -> on_action( sub { return 'http://tempuri.org/BBANtoBIC' } );
             my $Value1 = SOAP::Data->name('Value' => $BBan)->type('');
             my $response = '';                
             eval {$response = $soap->BBANtoBIC($Value1);};
             if (!$@) {
                 $BIC = $response->{_content}[4]->{Body}->{BBANtoBICResponse}->{BBANtoBICResult};
                 $BIC =~ s/\s//g;
                 print "not @ dus bic => $BIC";
                 &maak_nieuwe_conversie_lev ($BBan,$IBAN,$BIC);
                 return ($IBAN,$BIC);
                }else {
                  return ('','');
                }
            }else {
              return ($iban,$swift);
            }
        }else {        #BBAN
         my ($iban,$swift)= &zoek_conversie_bban_lev ($BBan );
         if ($iban eq 'NOT_IN_DB') {
             #print"niet in db opzoeken->";
             my $soap = SOAP::Lite
                 -> proxy('http://www.ibanbic.be/IBANBIC.asmx?op=BBANtoIBAN')
                 ->uri('http://tempuri.org/')
                 ->on_action( sub { return 'http://tempuri.org/BBANtoIBAN' } );
             my $Value = SOAP::Data->name('Value' => $BBan)->type('');
             my $response = '';
             eval {$response = $soap->BBANtoIBAN($Value);};
             my $opzoeking = 0;
             if (!$@) {
                 $IBAN = $response->{_content}[4]->{Body}->{BBANtoIBANResponse}->{BBANtoIBANResult};
                 $IBAN =~ s/\s//g;
                 $opzoeking +=1;
                 print "not @ dus iban => $IBAN";
                 $soap = SOAP::Lite
                     -> proxy('http://www.ibanbic.be/IBANBIC.asmx?op=BBANtoBIC')
                     -> uri('http://tempuri.org/')
                     -> on_action( sub { return 'http://tempuri.org/BBANtoBIC' } );
                 my $Value1 = SOAP::Data->name('Value' => $BBan)->type('');
                 $response = '';                
                 eval {$response = $soap->BBANtoBIC($Value1);};
                 if (!$@) {
                     $BIC = $response->{_content}[4]->{Body}->{BBANtoBICResponse}->{BBANtoBICResult};
                     $BIC =~ s/\s//g;
                     print "not @ dus bic => $BIC";
                     &maak_nieuwe_conversie_lev ($BBan,$IBAN,$BIC);
                     $opzoeking +=1;
                     return ($IBAN,$BIC);
                    }else {
                     return ('','');
                    }                             
                }else {
                  print "@\n";
                  return ('','');
                }
             
             
            }else {
             # print "in db $iban,$swift\n";
             return ($iban,$swift);
            }
        }
     
      
        # if ($BIC) {
        #     $BIC =~ s/\s//g;
        #     &maak_nieuwe_conversie($dbh,$iban_nr,$BIC) if ($BIC ne 'WEETNIET') ;
        #     return ($BIC) ;
        #    }else {
        #     #&maak_nieuwe_conversie($dbh,$iban_nr,'WEETNIET'); enkele keer voor circulaire checks
        #     return ('WEETNIET') ;
        #    }
        #}
    }
1;
