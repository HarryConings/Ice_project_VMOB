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
use Date::Manip::DM5;        
use Date::Manip::Date;
use Date::Calc qw(:all);
use Scalar::Util;
use LWP::UserAgent;
use LWP::UserAgent::JSON;
use JSON::PP qw(decode_json);
use URI;
my $settings = settings->mut203('PROD');
($settings->{access_token},$settings->{token_type}) = get_token->app_token($settings->{uri_fes},$settings->{Authorization});
my ($aantal,$persons) = webservice->GetPersonByName($settings,'WESLEY','KENIS');
#my $klant->{referenceID}=$persons->[0]->{referenceID};
#my $klant->{ext_nummer}= 810004498135;
#$klant = webservice->GetPersonData_external_nr($settings,$klant); #by external number
my $klant->{inz_nr_g_sp}=89080306722;#88072809292;#60073024369; #65012526170;#61092320957; #60073024369; #89052631533;
$klant->{referenceID}=2000001436099;
#$klant =  webservice->GetPersonData_national_nr($settings,$klant); #by rijksregnr
$klant =  webservice->GetPersonData_referenceID($settings,$klant); #by {referenceID
#$klant =  webservice->GetPersonData_emailaddress($settings,$klant); #by {referenceID -> email
#$klant =  webservice->GetPersonAddress_referenceID($settings,$klant); #by {referenceID
$klant =  webservice->GetLegalFamilyMembers($settings,$klant); #by {referenceID
#$klant =  webservice->GetBankaccounts($settings,$klant); #by {referenceID not authorized error by systtem user
$klant =  webservice->GetInsurencesPerson($settings,$klant); #by {referenceID
#$klant =  webservice->GetInsurenceMandatoryFull($settings,$klant); #by {referenceID #not authorized
#$klant = webservice->Get_fildata_files_refId($settings,$klant); #forbidden
$klant = webservice->Get_indemnitydata_PersonsrefId($settings,$klant);
#$klant = webservice->Get_indemnitydata_PersonsrefId_indemnitieref($settings,$klant,"c0C7xHeqyIG1-e5Y41rouw");# result same as Get_indemnitydata_PersonsrefId
#$klant = webservice->uitkeringen_sort($settings,$klant);
#$klant = webservice->Get_ContactInformation($settings,$klant); #tel mail adsre
$klant = webservice->Get_user_preferences($settings,$klant);
print '';
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
        #if ($res->{_msg} eq 'OK') {
            # do stuff with content
            my @content = split /,/,$res->{_content};
            my @access_token_1 = split /:/,$content[0];
            $access_token= $access_token_1[1];
            $access_token =~ s/"//g;
            my @token_type_1=  split /:/,$content[2];
            $token_type= $token_type_1[1];
            $token_type =~ s/"//g;
            print "";
        #} else {
        #    # request failed
        #    $access_token= $res->{_msg};
        #    $token_type=$res->{_content};
        #    print "";
        #}
        return($access_token,$token_type);
    }
package webservice;
    use Date::Manip::DM5;        
    use Date::Manip::Date;
    use Date::Calc qw(:all);
    use JSON::PP qw(decode_json);
    sub GetPersonByName {
        my ($self,$settings,$voor_naam,$achter_naam) = @_;
        my $persons;
        my $aantal=0;
        my $uri ="$settings->{uri_bigleap}/mca/api/persondata/persons?firstName=$voor_naam&lastName=$achter_naam&page=1&size=50" ;
        my $ua = LWP::UserAgent::JSON->new;
        my $res = $ua->get(
            $uri,
            "Authorization" => "$settings->{token_type} $settings->{access_token}",
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
    sub GetPersonData_referenceID {
        my ($self,$settings,$klant) = @_;
        my $uri ="$settings->{uri_bigleap}/mca/api/persondata/persons/$klant->{referenceID}";
        my $ua = LWP::UserAgent::JSON->new;
        my $res = $ua->get(
            $uri,
            "Authorization" => "$settings->{token_type} $settings->{access_token}",
            #"Cache-Control" => "no-cache", 
            "Accept" => "application/json", 
        );
         if ($res->{_msg} eq 'OK') {
             my $json  = $res->content;
             my $PersonData = decode_json $json;            
             $klant->{naam} =  $PersonData->{lastName};
             $klant->{voornaam} = $PersonData->{firstName};
             $klant->{inz_nr_g_sp} = $PersonData->{nationalNumber};
             my $splitinz= $klant->{inz_nr_g_sp};
             $splitinz=~ s%\d{2}$% $&%;
             $splitinz=~ s%\d{3}\s\d{2}$% $&%;
             $klant->{inz_nr_spatie} = sprintf ('%013s',$splitinz);
             $klant->{ext_nummer} = $PersonData->{externalNumber};
             $klant->{ge_slacht} =  $PersonData->{gender};
             $klant->{taal} =  $PersonData->{language};
             $klant->{nationaliteit} = $PersonData->{nationality};
             $klant->{ext_nummer_partner}=$PersonData->{partnerExternalNumber};
             $klant->{bureel}=$PersonData->{office};
             $klant->{geboortedatum}= substr($PersonData->{birthDate},0,10);
             $klant->{burgelijke_stand} = $PersonData->{civilStatus};
             $klant->{protectiecode} = $PersonData->{protectionCode};
             
             print "";
  
         }
         return ($klant);
    }
    sub GetPersonData_external_nr {
        my ($self,$settings,$klant) = @_;
        my $ext =sprintf ('%013s',$klant->{ext_nummer});
        my $uri ="$settings->{uri_bigleap}/mca/api/persondata/persons?externalNumber=$ext";
        print "$uri\n";
        my $ua = LWP::UserAgent::JSON->new;
        my $res = $ua->get(
            $uri,
            "Authorization" => "$settings->{token_type} $settings->{access_token}",
            #"Cache-Control" => "no-cache", 
            "Accept" => "application/json", 
        );
         if ($res->{_msg} eq 'OK') {
             my $json  = $res->content;
             my $Person = decode_json $json;
             my $PersonData = $Person->{personSummaries}->[0];
             $klant->{naam} =  $PersonData->{lastName};
             $klant->{voornaam} = $PersonData->{firstName};
             $klant->{inz_nr_g_sp} = $PersonData->{nationalNumber};
             my $splitinz= $klant->{inz_nr_g_sp};
             $splitinz=~ s%\d{2}$% $&%;
             $splitinz=~ s%\d{3}\s\d{2}$% $&%;
             $klant->{inz_nr_spatie} = sprintf ('%013s',$splitinz);
             $klant->{ext_nummer} = $PersonData->{externalNumber};
             $klant->{ge_slacht} =  $PersonData->{gender};
             $klant->{taal} =  $PersonData->{language};
             $klant->{nationaliteit} = $PersonData->{nationality};
             $klant->{ext_nummer_partner}=$PersonData->{partnerExternalNumber};
             $klant->{bureel}=$PersonData->{office};
             $klant->{geboortedatum}= substr($PersonData->{birthDate},0,10);
             $klant->{burgelijke_stand} = $PersonData->{civilStatus};
             $klant->{protectiecode} = $PersonData->{protectionCode};
             $klant->{referenceID}=$PersonData->{referenceID};
             print "";
  
         }
         return ($klant);
    }
    sub GetPersonData_national_nr {
        my ($self,$settings,$klant) = @_;
        my $nat =sprintf ('%011s',$klant->{inz_nr_g_sp});
        my $uri ="$settings->{uri_bigleap}/mca/api/persondata/persons?nationalNumber=$nat";
        print "$uri\n";
        my $ua = LWP::UserAgent::JSON->new;
        my $res = $ua->get(
            $uri,
            "Authorization" => "$settings->{token_type} $settings->{access_token}",
            #"Cache-Control" => "no-cache", 
            "Accept" => "application/json", 
        );
         if ($res->{_msg} eq 'OK') {
             my $json  = $res->content;
             my $Person = decode_json $json;
             my $PersonData = $Person->{personSummaries}->[0];
             $klant->{naam} =  $PersonData->{lastName};
             $klant->{voornaam} = $PersonData->{firstName};
             $klant->{inz_nr_g_sp} = $PersonData->{nationalNumber};
             my $splitinz= $klant->{inz_nr_g_sp};
             $splitinz=~ s%\d{2}$% $&%;
             $splitinz=~ s%\d{3}\s\d{2}$% $&%;
             $klant->{inz_nr_spatie} = sprintf ('%013s',$splitinz);
             $klant->{ext_nummer} = $PersonData->{externalNumber};
             $klant->{ge_slacht} =  $PersonData->{gender};
             $klant->{taal} =  $PersonData->{language};
             $klant->{nationaliteit} = $PersonData->{nationality};
             $klant->{ext_nummer_partner}=$PersonData->{partnerExternalNumber};
             $klant->{bureel}=$PersonData->{office};
             $klant->{geboortedatum}= substr($PersonData->{birthDate},0,10);
             $klant->{burgelijke_stand} = $PersonData->{civilStatus};
             $klant->{protectiecode} = $PersonData->{protectionCode};
             $klant->{referenceID}=$PersonData->{referenceID};
             print "";
  
         }
         return ($klant);
    } 
    sub GetPersonAddress_referenceID {
        my ($self,$settings,$klant) = @_;      
        my $uri ="$settings->{uri_bigleap}/mca/api/persondata/persons/$klant->{referenceID}/addresses";
     
        my $ua = LWP::UserAgent::JSON->new;
        my $res = $ua->get(
            $uri,
            "Authorization" => "$settings->{token_type} $settings->{access_token}",
            #"Cache-Control" => "no-cache", 
            "Accept" => "application/json", 
        );
         if ($res->{_msg} eq 'OK') {
             my $json  = $res->content;
             my $PersonData = decode_json $json;
             my $link = $PersonData->{contactInformationAddresses}->[0];
             my $test = $link->{type};
             if ($link->{type} eq 'HOME') {                
                 $klant->{adres}->{domi} = {
                     soort_adres =>$link->{type},
                     straat_naam =>$link->{street},
                     huis_nummer =>$link->{number},
                     bus_nummer => $link->{boxNumber},
                     land_code => $link->{country},
                     post_nummer =>$link->{zip},
                     stad =>$link->{city},
                     straatcode => '',
                     referenceID => $link->{referenceId},
                    };
                }else {
                     if ($link->{type} eq 'POSTAL') {                
                            $klant->{adres}->{post} = {
                            bewoner => $link->{co},    
                            soort_adres =>$link->{type},
                            straat_naam =>$link->{street},
                            huis_nummer =>$link->{number},
                            bus_nummer => $link->{boxnumber},
                            land_code => $link->{country},
                            post_nummer =>$link->{zip},
                            stad =>$link->{city},
                            straatcode => '',
                            referenceID => $link->{referenceId},
                           };
                         $link = $PersonData->{contactInformationAddresses}->[1];
                         if ($link->{type} eq 'HOME') {                
                                $klant->{adres}->{domi} = {
                                soort_adres =>$link->{type},
                                straat_naam =>$link->{street},
                                huis_nummer =>$link->{number},
                                bus_nummer => $link->{boxNumber},
                                land_code => $link->{country},
                                post_nummer =>$link->{zip},
                                stad =>$link->{city},
                                straatcode => '',
                                referenceID => $link->{referenceId},
                               };
                            }
                        }
                 print '';
                }
            }
         return($klant);
    }
    sub GetPersonData_emailaddress {
        my ($self,$settings,$klant) = @_;      
        my $uri ="$settings->{uri_bigleap}/mca/api/persondata/persons/$klant->{referenceID}/emailAddresses";
        my $ua = LWP::UserAgent::JSON->new;
        my $res = $ua->get(
            $uri,
            "Authorization" => "$settings->{token_type} $settings->{access_token}",
            #"Cache-Control" => "no-cache", 
            "Accept" => "application/json", 
            );
         if ($res->{_msg} eq 'OK') {
                 my $json  = $res->content;
                my $Person = decode_json $json;
                $klant->{email}->{adres}=$Person->{contactInformationEmails}->[0]->{email};
                $klant->{email}->{referenceId}=$Person->{contactInformationEmails}->[0]->{referenceId};
                print '';
            }elsif ($res->{_msg} eq 'No Content'){
             $klant->{email}->{adres}='';
             $klant->{email}->{referenceId}='';
            
            }
         return ($klant);
    }
    sub GetLegalFamilyMembers {
        my ($self,$settings,$klant) = @_;
        my $uri ="$settings->{uri_bigleap}/mca/api/familydata/persons/$klant->{referenceID}/legalFamilyMembers";
        my $ua = LWP::UserAgent::JSON->new;
        my $res = $ua->get(
            $uri,
            "Authorization" => "$settings->{token_type} $settings->{access_token}",
            #"Cache-Control" => "no-cache", 
            "Accept" => "application/json", 
        );
        if ($res->{_msg} eq 'OK') {
             my $json  = $res->content;
             my $PersonData = decode_json $json;
             foreach my $nr (keys $PersonData->{legalFamilyMembers}) {
                 my $geboortedatum = $PersonData->{legalFamilyMembers}->[$nr]->{birthDate};
                 if ($geboortedatum ne '') {
                    my $inz = $PersonData->{legalFamilyMembers}->[$nr]->{nationalNumber};
                    $klant->{famillie}->{$inz}->{inz_nr_g_sp} = $inz;
                    $klant->{famillie}->{$inz}->{voor_naam} =$PersonData->{legalFamilyMembers}->[$nr]->{firstName};
                    $klant->{famillie}->{$inz}->{achter_naam} =$PersonData->{legalFamilyMembers}->[$nr]->{lastName};
                    $klant->{famillie}->{$inz}->{burgelijke_stand} =$PersonData->{legalFamilyMembers}->[$nr]->{civilStatus};
                    $klant->{famillie}->{$inz}->{ge_slacht} =$PersonData->{legalFamilyMembers}->[$nr]->{gender};
                    $klant->{famillie}->{$inz}->{geboorte_datum} = substr($geboortedatum,0,10);
                 }
             }
             print '';
             }
        return ($klant);
    }
    sub GetBankaccounts { # not authorized error
         my ($self,$settings,$klant) = @_;
        my $uri ="$settings->{uri_bigleap}/mca/api/financialdata/persons/$klant->{referenceID}/bankaccounts?history=false ";
        my $ua = LWP::UserAgent::JSON->new;
        my $res = $ua->get(
            $uri,
            "Authorization" => "$settings->{token_type} $settings->{access_token}",
            #"Cache-Control" => "no-cache", 
            "Accept" => "application/json", 
        );
        if ($res->{_msg} eq 'OK') {
             my $json  = $res->content;
             my $PersonData = decode_json $json;
             print '';
        }
    }
    sub GetInsurencesPerson {
        my ($self,$settings,$klant) = @_;
        my $uri ="$settings->{uri_bigleap}/mca/api/insurancedata/persons/$klant->{referenceID}/insurances?history=false ";
        my $ua = LWP::UserAgent::JSON->new;
        my $res = $ua->get(
            $uri,
            "Authorization" => "$settings->{token_type} $settings->{access_token}",
            #"Cache-Control" => "no-cache", 
            "Accept" => "application/json", 
        );
        if ($res->{_msg} eq 'OK') {
             my $json  = $res->content;
             my $PersonData = decode_json $json;
             print '';
            #verzekeringen opzoeken die we hebben
            foreach my $nr (keys $PersonData->{insurances}) {
                      my $verz_nr =$PersonData->{insurances}->[$nr]->{productType}->{backendCode};
                      $klant->{verzekeringen}->{$verz_nr}->{begin_datum} =substr($PersonData->{insurances}->[$nr]->{affiliationDate},0,10);
                      $klant->{verzekeringen}->{$verz_nr}->{eind_datum} =substr($PersonData->{insurances}->[$nr]->{cancellationDate},0,10);
                      $klant->{verzekeringen}->{$verz_nr}->{agent_nr} =$PersonData->{insurances}->[$nr]->{idAgent1};
                      $klant->{verzekeringen}->{$verz_nr}->{insuranceRefId} =$PersonData->{insurances}->[$nr]->{insuranceRefId} ;
                      $klant = webservice->GetInsurenceBeneficiaryDetails($settings,$klant,$PersonData->{insurances}->[$nr]->{insuranceRefId}); # werkt niet
                      $klant->{verzekeringen}->{$verz_nr}->{dossier_nr} =$PersonData->{insurances}->[$nr]->{policyNumber} ;
                      $klant->{verzekeringen}->{$verz_nr}->{Titularis}->{ext_nummer} =$PersonData->{insurances}->[$nr]->{titularInformation}->{externalNumber};
                      $klant->{verzekeringen}->{$verz_nr}->{Titularis}->{RefId} =$PersonData->{insurances}->[$nr]->{titularRefId};
            }
        }
        return ($klant);
    }
    sub GetInsurenceSummary {
         my ($self,$settings,$insurancerefId) = @_; # werkt niet 
         my $uri ="$settings->{uri_bigleap}/mca/api/insurancedata/insuranceSummary/$insurancerefId";
         my $ua = LWP::UserAgent::JSON->new;
         my $res = $ua->get(
            $uri,
            "Authorization" => "$settings->{token_type} $settings->{access_token}",
            #"Cache-Control" => "no-cache", 
            "Accept" => "application/json", 
        );
         if ($res->{_msg} eq 'OK') { }
         print "";
    }
    sub  GetInsurenceBeneficiaryDetails{ # bankrekeningen invullen
         my ($self,$settings,$klant,$insuranceRefId) = @_;
         my $uri ="$settings->{uri_bigleap}/mca/api/insurancedata/persons/$klant->{referenceID}/beneficiaryDetails/$insuranceRefId";
         my $ua = LWP::UserAgent::JSON->new;
         my $res = $ua->get(
                $uri,
                "Authorization" => "$settings->{token_type} $settings->{access_token}",
                #"Cache-Control" => "no-cache", 
                "Accept" => "application/json", 
            );
         if ($res->{_msg} eq 'OK') {
                my $json  = $res->content;
                my $PersonData = decode_json $json;
                print '' ;
                my $verz =  $PersonData->{insuranceType}->{backendCode};              
                $klant->{bankrekeningen}->{"verz_$verz"}->{BBan} = $PersonData->{insurancePayments}->[0]->{bankAccountInfo}->{BBAN};
                $klant->{bankrekeningen}->{"verz_$verz"}->{Bic_Code} = $PersonData->{insurancePayments}->[0]->{bankAccountInfo}->{BIC};
                $klant->{bankrekeningen}->{"verz_$verz"}->{Iban} = $PersonData->{insurancePayments}->[0]->{bankAccountInfo}->{IBAN};
                $klant->{bankrekeningen}->{"verz_$verz"}->{ext_betaler} = $PersonData->{insurancePayments}->[0]->{payer}->{externalNumber};
                $klant->{bankrekeningen}->{"verz_$verz"}->{voornaam_betaler}  = $PersonData->{insurancePayments}->[0]->{payer}->{firstName};
                $klant->{bankrekeningen}->{"verz_$verz"}->{naam_betaler} = $PersonData->{insurancePayments}->[0]->{payer}->{lastName}; 
            }
         return ($klant);
    }
    sub GetInsurenceMandatoryFull{
        my ($self,$settings,$klant) = @_;
        my $uri ="$settings->{uri_bigleap}/mca/api/insurancedata/persons/$klant->{referenceID}/beneficiaryDetails/mandatoryFull ";
        my $ua = LWP::UserAgent::JSON->new;
        my $res = $ua->get(
            $uri,
            "Authorization" => "$settings->{token_type} $settings->{access_token}",
            #"Cache-Control" => "no-cache", 
            "Accept" => "application/json", 
        );
         if ($res->{_msg} eq 'OK') {
             my $json  = $res->content;
             my $PersonData = decode_json $json;
             my $verz_nr = $PersonData->{insuranceType}->{backendCode}; #1
             $klant->{nr_oud_zkf} = $PersonData->{oldFedration}->{number};
             $klant->{refId_oud_zkf} = $PersonData->{oldFedration}->{referenceID};
             my $cg1_cg2 = $PersonData->{ct1ct2};
             my $cg1 = substr($cg1_cg2,0,3);
             my $cg2 = substr($cg1_cg2,3,3);
             $klant->{cg1_cg2} ="$cg1/$cg2";
             $klant->{Titularis}->{ext_nummer}  =$PersonData->{titularInformation}->{externalNumber};
             $klant->{Titularis}->{refId} =$PersonData->{titularInformation}->{beneficiaryRefId};
             $klant->{Agent}->{nummer} = $PersonData->{idAgent1};             
             print'';# bank betalingen kan ook
            
            }
        return ($klant);  
    }
    sub Get_fildata_files_refId {
        my ($self,$settings,$klant) = @_;
        my $persons;
        my $aantal=0;
        #http://s298lr2wseb01.ref.cpc998.be:21120/mca/api/filedata/filemetadata/persons/KkrlzVBTKsW0S8tiwFvCjw/files?page=1&size=50
        my $refId= $klant->{referenceID};
        my $uri ="$settings->{uri_bigleap}/mca/api/filedata/filemetadata/persons/$refId/files?page=1&size=50" ;
        my $ua = LWP::UserAgent::JSON->new;
        my $res = $ua->get(
            $uri,
            "Authorization" => "$settings->{token_type} $settings->{access_token}",
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
         return ($klant);
    }
    sub Get_indemnitydata_PersonsrefId {
        my ($self,$settings,$klant) = @_;
        my $persons;
        my $aantal=0;
        #http://s298lr2wseb01.ref.cpc998.be:21120/mca/api/filedata/filemetadata/persons/KkrlzVBTKsW0S8tiwFvCjw/files?page=1&size=50/indemnitydata/persons/{0}/indemnities
        my $refId= $klant->{referenceID};
        my $uri ="$settings->{uri_bigleap}/mca/api/indemnitydata/persons/$refId/indemnities?showAllAccountingStatusCodes=true&showRegularizations=true&page=1&size=50" ; ;
        my $ua = LWP::UserAgent::JSON->new;
        my $res = $ua->get(
            $uri,
            "Authorization" => "$settings->{token_type} $settings->{access_token}",
            #"Cache-Control" => "no-cache", 
            "Accept" => "application/json", 
        );
         if ($res->{_msg} eq 'OK') {
             my $json  = $res->content;
             my $indemnities = decode_json $json;
             $klant->{indemnities} = $indemnities->{indemnities};
             #betalingen zit in ->[0]->{indemnityPeriods}->{indemnityPayments}->[0]
         }
         return ($klant);
    }
    sub uitkeringen_sort {
        my ($self,$settings,$klant) = @_;
        my $link = $klant->{indemnities};
        eval {foreach my $nr (sort keys $link) {}};
        if(!$@) {
             foreach my $nr (sort keys $link) {
                foreach my $nr_period (sort keys $link->[$nr]->{indemnityPeriods}) {
                    my $link1 =$link->[$nr]->{indemnityPeriods}->[$nr_period];
                    my $beginperiode = substr($link1->{periodBeginDate},0,10);
                    my $eindperiode = substr($link1->{periodEndDate},0,10);             
                    my $PeriodeId = $link1->{periodID};
                    my $link2 = $link1->{indemnityPayments};
                    foreach my $nr_payment (sort keys $link2) {
                        my $link3 = $link2->[$nr_payment];
                         my $begindatum = substr($link3->{paymentBeginDate},0,10);
                         my ($bjaar,$bmaand,$bdag)= split('-',$begindatum);
                         $begindatum =~ s/-//g;
                         my $beginjaarmaand =substr($link3->{paymentBeginDate},0,7);
                         $beginjaarmaand  =~ s/-//g;
                         my $begindag= substr($link3->{paymentBeginDate},7,2);
                         my $einddatum =substr($link3->{paymentEndDate},0,10);
                         my ($ejaar,$emaand,$edag) = split ('-',$einddatum);
                         my $Periode ="$bdag/$bmaand/$bjaar-$edag/$emaand/$ejaar";
                         $einddatum  =~ s/-//g;
                         my $eindjaarmaand =substr($link3->{paymentEndDate},0,7);
                         $eindjaarmaand  =~ s/-//g;
                         my $einddag = substr($link3->{paymentEndDate},7,2);
                         my $paymentcode = $link3->{paymentTypeCode}->{backendCode};
                         my ($kolom_in_tabel,$omschrijving) = webservice->paymentcodes($paymentcode);
                         my $bruto =0;
                         my $netto =0;
                         my $dagbedrag=0;
                         my $afhouding = 0;
                         my $aantaldagen = 0;
                         if ( $kolom_in_tabel eq 'bruto_netto') {
                              $bruto =  $link3->{paidAmount};
                              $netto = $link3->{totalAmount};
                              $dagbedrag = $link3->{dailyRate};
                              $aantaldagen = $link3->{numberOfDays};
                            }elsif ( $kolom_in_tabel eq 'afhouding') {
                              $afhouding = $link3->{totalAmount};
                            }
                         $klant->{uitkeringen}->{periode}->{$Periode}->{'bruto'} += $bruto;
                         $klant->{uitkeringen}->{periode}->{$Periode}->{'netto'} += $netto;
                         $klant->{uitkeringen}->{periode}->{$Periode}->{'dagbedrag'}=$dagbedrag if ($dagbedrag >$klant->{uitkeringen}->{periode}->{$Periode}->{'dagbedrag'});
                         $klant->{uitkeringen}->{periode}->{$Periode}->{'voorheffing'} += $afhouding;
                         $klant->{uitkeringen}->{periode}->{$Periode}->{'aantaldagen'} += $aantaldagen;
                       
                        
                    }
                  
                }
            } 
        }
        eval{foreach my $periode_id (sort keys $klant->{uitkeringen}->{periode}) {}};
        if(!$@) {
            foreach my $periode_id (sort keys $klant->{uitkeringen}->{periode}) {
                my $link = $klant->{uitkeringen}->{periode}->{$periode_id};
                my $som = $link->{bruto}+$link->{netto}+$link->{voorheffing};
                my $beginjaar= substr ($periode_id,6,4);
                my $beginmaand = substr ($periode_id,3,2);
                my $begindag = substr ($periode_id,0,2);
                my $beginjaarmaand= $beginjaar*100+$beginmaand;
                my $eindjaar= substr ($periode_id,17,4);
                my $eindmaand = substr ($periode_id,14,2);
                my $eindjaarmaand= $eindjaar*100+$eindmaand;
                my $einddag = substr ($periode_id,11,2);
                my @aantaldagen_maand = ('void',31,28,31,30,31,30,31,31,30,31,30,31);
                if ($beginjaarmaand == $eindjaarmaand and $som > 0) {                       
                             $klant->{uitkeringen}->{uitkeringpermaand}->{$beginjaarmaand}->{'bruto'} += $link->{bruto};
                             $klant->{uitkeringen}->{uitkeringpermaand}->{$beginjaarmaand}->{'netto'} += $link->{netto};
                             $klant->{uitkeringen}->{uitkeringpermaand}->{$beginjaarmaand}->{'voorheffing'} += $link->{voorheffing};
                             $klant->{uitkeringen}->{uitkeringpermaand}->{$beginjaarmaand}->{'aantaldagen'} += $link->{aantaldagen};
                            }elsif ($som > 0) { #splitsen
                              my $nr_dagweek_begin = Day_of_Week($beginjaar,$beginmaand,$begindag);
                              my $nr_einddag =Day_of_Week($eindjaar,$eindmaand,$einddag);
                              my $aantal_werkdagen_in_eindmaand = 0;
                              my $totaal_aantal_werkdagen= $link->{aantaldagen};
                              my $aantal_werkdagen_in_beginmaand = $link->{aantaldagen};
                              my $laaste_teldag =$einddag;
                              if ($nr_einddag==7) {
                                    $nr_einddag = 6;
                                    $laaste_teldag -= 1;
                                }
                            while ($laaste_teldag > 0) {
                                if ($laaste_teldag >= 7) {
                                        $aantal_werkdagen_in_eindmaand +=6;
                                        $laaste_teldag -=7;
                                        $aantal_werkdagen_in_beginmaand -=6;
                                 }else {
                                        $aantal_werkdagen_in_eindmaand += $laaste_teldag;
                                        $aantal_werkdagen_in_beginmaand -= $laaste_teldag;
                                        $laaste_teldag = 0;
                                 }
                            }
                            $klant->{uitkeringen}->{uitkeringpermaand}->{$beginjaarmaand}->{'voorheffing'}+=$link->{voorheffing}/$totaal_aantal_werkdagen* $aantal_werkdagen_in_beginmaand;
                            $klant->{uitkeringen}->{uitkeringpermaand}->{$beginjaarmaand}->{'bruto'}+=$link->{bruto}/$totaal_aantal_werkdagen* $aantal_werkdagen_in_beginmaand;
                            $klant->{uitkeringen}->{uitkeringpermaand}->{$beginjaarmaand}->{'netto'}+=$link->{netto}/$totaal_aantal_werkdagen* $aantal_werkdagen_in_beginmaand;
                           #my $aantal_werkdagen_in_beginmaand  =$uitkeringen_ongesorteerd->{$per_iode}->{$teller}->{dagen};
                            }     
            }
        }
        $klant->{uitkeringen}->{tabel2}->{rij}=$klant->{uitkeringen}->{periode};
        eval { foreach my $periode_id (sort keys $klant->{uitkeringen}->{periode}) {}};
        if(!$@) {
            foreach my $periode_id (sort keys $klant->{uitkeringen}->{periode}) {
                my $link1 = $klant->{uitkeringen}->{periode}->{$periode_id};
                my $som = $link1->{bruto}+$link1->{netto}+$link1->{voorheffing};
                if ($som > 0) {
                    $klant->{uitkeringen}->{tabel2}->{rij}->{$periode_id}->{'periode'} = $periode_id ;
                    $klant->{uitkeringen}->{tabel2}->{rij}->{$periode_id}->{'bruto'} = $link1->{bruto};
                    $klant->{uitkeringen}->{tabel2}->{rij}->{$periode_id}->{'netto'} = $link1->{netto};
                    $klant->{uitkeringen}->{tabel2}->{rij}->{$periode_id}->{'voorheffing'} = $link1->{voorheffing};
                    
                }
                
            }
        }
     return ($klant);
    }
    sub paymentcodes {
        my ($self,$paymentCode) = @_;
        if ($paymentCode == 110) { return ('afhouding','Afhouding_RWP'); }
        if ($paymentCode == 111) { return  ('niet_in_tabel','BETALING_LANDSBOND'); }
        if ($paymentCode == 120) { return ('afhouding','VOORHEFFING'); }
        if ($paymentCode == 130) { return ('niet_in_tabel','ANDERE_FISKALE_LASTEN'); }
        if ($paymentCode >= 211 && $paymentCode <= 249) { return ('niet_in_tabel','ONDERHOUDSGELD'); }
        if ($paymentCode >= 301 && $paymentCode <= 349) { return ('niet_in_tabel','BESLAG_LOONAFSTAND_A_1409'); }
        if ($paymentCode >= 400 && $paymentCode <= 410) { return ('niet_in_tabel','AFHOUDING_GESCHILLEN'); }
        if ($paymentCode >= 411 && $paymentCode <= 432) { return ('niet_in_tabel','REGULARISATIE_GESCHILLEN'); }
        if ($paymentCode >= 440 && $paymentCode <= 444) { return ('niet_in_tabel','inhouding_van_10PROCENT_op_de_uitkeringen_ten_voordele_van_een_socia'); }
        if ($paymentCode == 450) { return('niet_in_tabel','BETALING_UITK_BUITENLAND'); }
        if ($paymentCode == 499) { return ('niet_in_tabel','FEDERAAL_VOORSCHOT'); }
        if ($paymentCode >= 500 && $paymentCode <= 549) { return ('niet_in_tabel','BETALING_AAN_DERDE'); }
        if ($paymentCode >= 900 && $paymentCode <= 993) { return ('niet_in_tabel','OVERLIJDINGSVERGOEDING_niet_meer_van_toepassing'); }
        if ($paymentCode == 996) { return ('niet_in_tabel','Regularisatie_bedrijfsvoorheffing'); }
        if ($paymentCode == 997) { return ('niet_in_tabel','Regularisatie_RWP'); }
        if ($paymentCode == 998) { return ('niet_in_tabel','Geen_schuldeiser_saldo'); }
        if ($paymentCode == 999) { return ('bruto_netto','Betaling_gerechtigde'); }
    }
    sub Get_indemnitydata_PersonsrefId_indemnitieref {
        my ($self,$settings,$klant,$im_refId ) = @_;
        my $persons;
        my $aantal=0;
        #get /indemnitydata/persons/{personRefID}/indemnities/{indemnityRefID}
        #http://api-mnnz.jablux.cpc998.be:21160/mca/api/indemnitydata/persons/u0JTtYuPpuRkwHKr6TlYhg/indemnities?showAllAccountingStatusCodes=false&showRegularizations=false&page=1&size=50
        #http://api-mnnz.jablux.cpc998.be:21120/mca/api/indemnitydata/persons/u0JTtYuPpuRkwHKr6TlYhg/indemnities?showAllAccountingStatusCodes=true&showRegularizations=true&page=1&size=50
        my $refId= $klant->{referenceID};
        my $uri ="$settings->{uri_bigleap}/mca/api/indemnitydata/persons/$refId/indemnitydetails/$im_refId" ;
        my $ua = LWP::UserAgent::JSON->new;
        my $res = $ua->get(
            $uri,
            "Authorization" => "$settings->{token_type} $settings->{access_token}",
            #"Cache-Control" => "no-cache", 
            "Accept" => "application/json", 
        );
         if ($res->{_msg} eq 'OK') {
             my $json  = $res->content;
             my $indemnities1 = decode_json $json;
             $klant->{indemnities} = $indemnities1->{indemnities};
  
         }
         return ($klant);
    }    
    sub Get_ContactInformation {
         my ($self,$settings,$klant) = @_;
         my $refId= $klant->{referenceID};
         my $uri ="$settings->{uri_bigleap}/mca/api/persondata/persons/$klant->{referenceID}/contactInformation ";
         my $ua = LWP::UserAgent::JSON->new;
         my $res = $ua->get(
            $uri,
            "Authorization" => "$settings->{token_type} $settings->{access_token}",
            #"Cache-Control" => "no-cache", 
            "Accept" => "application/json", 
        );
         if ($res->{_msg} eq 'OK') {            
             my $json  = $res->content;
             my $PersonData = decode_json $json;
             print '';            
             foreach my $adr_nr (sort keys $PersonData->{addresses}) {
                 my $link = $PersonData->{addresses}->[$adr_nr];
                 my $test = $link->{type};
                    if ($link->{type} eq 'HOME') {                
                        $klant->{adres}->{domi} = {
                            soort_adres =>$link->{type},
                            straat_naam =>$link->{street},
                            huis_nummer =>$link->{number},
                            bus_nummer => $link->{boxNumber},
                            land_code => $link->{country},
                            post_nummer =>$link->{zip},
                            stad =>$link->{city},
                            straatcode => '',
                            referenceID => $link->{referenceId},
                           };
                    }elsif  ($link->{type} eq 'POSTAL') { 
                            $klant->{adres}->{post} = {
                            bewoner => $link->{co},    
                            soort_adres =>$link->{type},
                            straat_naam =>$link->{street},
                            huis_nummer =>$link->{number},
                            bus_nummer => $link->{boxnumber},
                            land_code => $link->{country},
                            post_nummer =>$link->{zip},
                            stad =>$link->{city},
                            straatcode => '',
                            referenceID => $link->{referenceId},
                           };                        
                            
                    }
                 print '';
                }
             foreach my $eadr_nr (sort keys $PersonData->{emailAddresses}) {
                 if ($eadr_nr == 0) {
                       $klant->{email}->{adres}=$PersonData->{emailAddresses}->[$eadr_nr]->{email};
                       $klant->{email}->{referenceId}=$PersonData->{emailAddresses}->[$eadr_nr]->{referenceId};
                    }else {
                       $klant->{email1}->{adres}=$PersonData->{emailAddresses}->[$eadr_nr]->{email};
                       $klant->{email1}->{referenceId}=$PersonData->{emailAddresses}->[$eadr_nr]->{referenceId};                
                    }
                }
             foreach my $p_nr  (sort keys $PersonData->{phoneNumbers}) {
                 if ($PersonData->{phoneNumbers}->[$p_nr]->{type} eq 'FIXED') {
                    if  ($PersonData->{phoneNumbers}->[$p_nr]->{place} eq 'HOME') {
                        $klant->{telefoonThuis} = "$PersonData->{phoneNumbers}->[$p_nr]->{countryCode} $PersonData->{phoneNumbers}->[$p_nr]->{number}";
                    }else {
                        $klant->{telefoonWerk} = "$PersonData->{phoneNumbers}->[$p_nr]->{countryCode} $PersonData->{phoneNumbers}->[$p_nr]->{number}";
                    }
                 }elsif ($PersonData->{phoneNumbers}->[$p_nr]->{type} eq 'MOBILE') {
                     if  ($PersonData->{phoneNumbers}->[$p_nr]->{place} eq 'HOME') {
                            $klant->{gsm} = "$PersonData->{phoneNumbers}->[$p_nr]->{countryCode} $PersonData->{phoneNumbers}->[$p_nr]->{number}";
                        }else {
                            $klant->{gsmWerk} = "$PersonData->{phoneNumbers}->[$p_nr]->{countryCode} $PersonData->{phoneNumbers}->[$p_nr]->{number}";
                        }
                 }
             }
            }
         return($klant);
    }
    sub Get_user_preferences {
         #/persondata/persons/{referenceID}/userPreferences  Allows retrieval of user preferences related to a person
         my ($self,$settings,$klant) = @_;
         my $refId= $klant->{referenceID};
         my $uri ="$settings->{uri_bigleap}/mca/api/persondata/persons/$klant->{referenceID}/userPreferences ";
         #my $uri ="$settings->{uri_bigleap}/mca/api/prefscenter/persons/$klant->{referenceID}/userpreference "; forbidden
         #my $uri= "$settings->{uri_bigleap}/mca/api/taskdata/persons//$klant->{referenceID}/tasks "; # not found
         #my  $uri ="$settings->{uri_bigleap}/mca/api/signalsdata/persons/$klant->{referenceID}/signals/nl "; #timeout
         #my  $uri ="$settings->{uri_bigleap}/mca/api/signalsdata/signals/nl "; #forbidden
         #my  $uri ="$settings->{uri_bigleap}/mca/api/globalmedicalrecorddata/persons/$klant->{referenceID}/globalmedicalrecord "; #not found
         my $ua = LWP::UserAgent::JSON->new;
         my $res = $ua->get(
            $uri,
            "Authorization" => "$settings->{token_type} $settings->{access_token}",
            #"Cache-Control" => "no-cache", 
            "Accept" => "application/json", 
        );
         if ($res->{_msg} eq 'OK') {            
             my $json  = $res->content;
             my $PersonData = decode_json $json;
             print '';
             my $uri1 =$PersonData->{links}->[2]->{href};
             my $ua1 = LWP::UserAgent::JSON->new;
             my $res1 = $ua1->get(
                    $uri1,
                    "Authorization" => "$settings->{token_type} $settings->{access_token}",
                    #"Cache-Control" => "no-cache", 
                    "Accept" => "application/json", 
                );
             my $json1  = $res1->content;
             my $PersonData1 = decode_json $json1;
             print "nieuws $PersonData->{newsletter} refund mail $PersonData->{refundmail}\n";
             print '';
            }
    }
   
    #get /prefscenter/persons/{personRefID}/userpreference    


package settings;
        sub mut203 {
            my ($self,$prod_ref) = @_;
            my $settings;
            if (uc $prod_ref eq 'PROD') {
                $settings->{nr} = 203;
                $settings->{uri_fes} =  'https://fes203.m-team.be/login/oauth2/access_token?grant_type=client_credentials&username=203-mymut-app&realm=/203';
                $settings->{Authorization} ="MjAzLW15bXV0LWFwcDppenFxU1Y5WEtiRjFQa1pjN0U5aE9aUEU="; # app user
                $settings->{Content_Type} = "application/x-www-form-urlencoded";
                $settings->{uri_bigleap} = 'http://api-mnnz.jablux.cpc998.be';
            }else {
                $settings->{nr} = 203;
                $settings->{uri_fes} =  'https://fes203-ref.m-team.be/login/oauth2/access_token?grant_type=client_credentials&username=203-mymut-app&realm=/203';
                $settings->{Authorization} ="MjAzLW15bXV0LWFwcDpwYXNzd29yZA=="; # app user
                $settings->{Content_Type} = "application/x-www-form-urlencoded";
                $settings->{uri_bigleap} = 'http://s298lr2wseb01.ref.cpc998.be:21160';
            }
            return ($settings);
        };