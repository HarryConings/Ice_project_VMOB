#!/usr/bin/perl -w
#in GIT gezet
#OPGELET!!!!!!
#Dit programma is auteursrechtelijk beschermd.
#Deze code is volledig eigendom van de Firma  I.C.E. (liebroekstraat 43 3545 Halen BE0446888007) .
#Deze code mag enkel gebruikt worden met jaarlijkse toestemming van Harry Conings 0475464286 harry@ice.be harry@icebutler.com
#Indien dit toch gebeurt is er een boete verschuldigd van 250.000 EUR exclusief btw aan de Firma  I.C.E.
#Deze code mag niet aan derden (ook niet VNZ en NZVL) getoond worden tenzij met uitdrukkelijke en schriftelijke toestemming van I.C.E. bvba .
#Indien dit toch gebeurt is er een boete verschuldigd van 250.000 EUR exclusief btw aan de Firma  I.C.E.
#Dit geldt ook voor het kopieren van een stuk code of het repliceren van technieken gehanteerd in dit programma
#I.C.E. beheert de broncode je mag  veranderingen aanbrengen aan het programma . Deze worden samen met de documentatie overgedragen aan I.C.E. .
#I.C.E. beslist dan op deze veranderingen worden doorgevoerd.
use strict;

use warnings;
use LWP::UserAgent;
use LWP::UserAgent::JSON;
use JSON::PP qw(decode_json);
use URI;
my $uri_zkf = 'https://fes203.m-team.be/login/oauth2/access_token?grant_type=client_credentials&username=203-mymut-app&realm=/203';
my $Authorization_zkf ="MjAzLW15bXV0LWFwcDppenFxU1Y5WEtiRjFQa1pjN0U5aE9aUEU=";
my ($access_token,$token_type) = get_token->app_token($uri_zkf,$Authorization_zkf);
my $bigleap = 'http://api-mnnz.jablux.cpc998.be';
my ($aantal,$persons) = webservice->GetPersonByName($bigleap,$access_token,$token_type,'steven','van dessel');
webservice->GetPersonData($bigleap,$access_token,$token_type,$persons->[0]->{referenceID});
package get_token;
    sub app_token {
        my ($self,$uri_zkf,$Authorization_zkf) = @_;
        my $uri =$uri_zkf ;
        #$uri->query_form(
        #    "startTime"       => $queryStart, # these two need 
        #    "endTime"         => $queryEnd,   # to be set above
        #    "cNat"            => "True", 
        #    "cNatShowDst"     => "False", 
        #    "tuplesFile"      => "False", 
        #    "summarizeTuples" => "False",   
        #);
        my $ua = LWP::UserAgent->new;
        my $res = $ua->post(
            $uri,
            "Authorization" => "Basic $Authorization_zkf",
            "Cache-Control" => "no-cache", 
            "Content-Type" => "application/x-www-form-urlencoded", 
        );
        my $access_token;
        my $token_type;
        if ($res->{_msg} eq 'OK') {
            # do stuff with content
            my @content = split /,/,$res->{_content};
            my @access_token_1 = split /:/,$content[0];
            $access_token= $access_token_1[1];
            $access_token =~ s/"//g;
            my @token_type_1=  split /:/,$content[2];
            $token_type= $token_type_1[1];
            $token_type =~ s/"//g;
            print "";
        } else {
            # request failed
            $access_token= $res->{_msg};
            $token_type=$res->{_content};
            print "";
        }
        return($access_token,$token_type);
    }
package webservice;
    use JSON::PP qw(decode_json);
    sub GetPersonByName {
        my ($self,$bigleap,$access_token,$token_type,$voor_naam,$achter_naam) = @_;
        my $persons;
        my $aantal=0;
        my $uri ="$bigleap/mca/api/persondata/persons?firstName=$voor_naam&lastName=$achter_naam&page=1&size=50" ;
        my $ua = LWP::UserAgent::JSON->new;
        my $res = $ua->get(
            $uri,
            "Authorization" => "$token_type $access_token",
            #"Cache-Control" => "no-cache", 
            "Accept" => "application/json", 
        );
         if ($res->{_msg} eq 'OK') {
             my $json  = $res->content;
             my $PersonByName = decode_json $json;
             $persons = $PersonByName->{personSummaries};
             $aantal =  $PersonByName->{pageSize};
             print "";
  
         }
         return ($aantal,$persons);
    }
    sub GetPersonData {
        my ($self,$bigleap,$access_token,$token_type,$referenceID) = @_;
        my $uri ="$bigleap/mca/api/persondata/persons/$referenceID";
        my $ua = LWP::UserAgent::JSON->new;
        my $res = $ua->get(
            $uri,
            "Authorization" => "$token_type $access_token",
            #"Cache-Control" => "no-cache", 
            "Accept" => "application/json", 
        );
         if ($res->{_msg} eq 'OK') {
             my $json  = $res->content;
             my $PersonData = decode_json $json;
             $persons = $PersonData->{personSummaries};
             
             print "";
  
         }
         return ($aantal,$persons);
    }
