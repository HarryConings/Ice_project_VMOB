#!/usr/bin/perl -w
use strict;
#&send_via_webserv_client ('BE35001705787537');
sub bic_via_webserv_client {
     require 'agresso_bban_bic_db_prod.pl';
     use SOAP::Lite ;
     #    +trace => [ transport => sub { print $_[0]->as_string } ];
     use XML::Compile::SOAP12::Client;
     use XML::Writer;
     use XML::Writer::String;
     my $iban_nr = shift @_;
     my $dbh = shift @_;
    
     
     $iban_nr =~ s/\s//g;
     $iban_nr =~ s/-//g;
     my $BIC = &zoek_conversie ($dbh,$iban_nr);
     if ($BIC ne 'NOT_IN_DB') {
         return ($BIC);#code
     }else {     
         my $BBan = 0;
         $BIC ='WEETNIET';
         if (substr($iban_nr,0,2) eq 'BE') {
             $BBan = substr ($iban_nr,4,12);#code
            }else {
             return ('WEETNIET');
            }
         #$ENV{HTTPS_DEBUG} = 1;
         #$ENV{HTTP_DEBUG} = 1;
         my $soap = SOAP::Lite
             -> proxy('http://www.ibanbic.be/IBANBIC.asmx?op=BBANtoBIC')
             #->ns("http://tempuri.org/",'')
             ->uri('http://tempuri.org/')
            ->on_action( sub { return 'http://tempuri.org/BBANtoBIC' } );
         my $Value = SOAP::Data->name('Value' => $BBan)->type('');
         my $response = '';
         eval {$response = $soap->BBANtoBIC($Value);};
         eval {$BIC = $response->{_content}[4]->{Body}->{BBANtoBICResponse}->{BBANtoBICResult};};
         if ($BIC) {
             $BIC =~ s/\s//g;
             &maak_nieuwe_conversie($dbh,$iban_nr,$BIC) if ($BIC ne 'WEETNIET') ;
             return ($BIC) ;
            }else {
             #&maak_nieuwe_conversie($dbh,$iban_nr,'WEETNIET'); enkele keer voor circulaire checks
             return ('WEETNIET') ;
            }
        }
     
}
1;
