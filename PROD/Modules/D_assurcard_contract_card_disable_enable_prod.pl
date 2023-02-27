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
use warnings;
use strict;
use Data::Dumper;
use XML::Compile::Schema;
use XML::LibXML::Reader;
require 'package_sql_toegang_agresso_prod.pl';
# Describing complex BlockedContracts
#     BlockedContracts
#
# Produced by XML::Compile::Translate::Template version 1.42
#          on Wed Apr 27 14:20:06 2016
#
# BE WARNED: in most cases, the example below cannot be used without
# interpretation.  The comments will guide you.
#
# xmlns:          (none)

# is an unnamed complex
#{ # sequence of BlockedContract
#
#  # is an unnamed complex
#  BlockedContract =>
#  { # sequence of BlockingDate, KioskMessage, DeskMessage, Method
#
#    # is a xs:date
#    BlockingDate => "2006-10-06",
#
#    # is a xs:string
#    # length <= 50
#    KioskMessage => "example",
#
#    # is a xs:string
#    # length <= 50
#    DeskMessage => "example",
#
#    # is an unnamed complex
#    # Method is simple value with attributes
#    Method =>
#    { # is a xs:string
#      # attribute FunctionTypeName is required
#      # Enum: add delete update
#      # white-space collapse
#      FunctionTypeName => "add",
#
#      # is a xs:string
#      # string content of the container
#      _ => "example", }, },
#
#  # is a xs:string
#  # attribute AssurCardIdentifier is required
#  AssurCardIdentifier => "example", }
#KioskMessage Blokkering openstaande schuld
#DeskMessage Blokkering openstaande schuld
package main;
     use XML::Simple;
     use Date::Manip::DM5 ;
     use Data::Dumper;
     use XML::Compile::Schema;
     use XML::LibXML::Reader;
     use Net::SMTP;
     use Date::Calc qw(:all);
     use Array::Diff;
     use List::MoreUtils qw(uniq);
     use File::Copy;
     use File::Slurp;
     #use Win32::FileOp;
     our $vandaag = ParseDate("today");
     our $huidig_jaar = substr ($vandaag,0,4);     
     our $huidige_maand = substr ($vandaag,4,2);
     our $huidige_dag = substr ($vandaag,6,2);
     our $vandaag_dag = $huidig_jaar*10000+$huidige_maand*100+$huidige_dag;
     our $vandaag_streep =  "$huidig_jaar-$huidige_maand-$huidige_dag";
     our $mail_contract ="BLOKKEER EN DEBLOKKEER KAARTEN OPENSTAANDE REKENINGEN AGRESSO\n";
     $mail_contract = $mail_contract."======================================================================\n======================================================================\n\n";
     our $contract_cardinstellingen=main->load_assurcard_generation_setting_contact_a('D:\OGV\ASSURCARD_PROG\assurcard_settings_xml\assurcard_card_generation_settings.xml');
     my $dbh = sql_toegang_agresso->setup_mssql_connectie;
     my ($to_Block_Contracts,$aantal) = sql_toegang_agresso->Get_to_Blockcustassurcard($dbh);
     my $data;
     $data->{InsurerAssurCardIdentifier} = "$contract_cardinstellingen->{nr_verzekeraar}";
     # my $data = {
     #BlockedContracts =>
     #[
     #BlockedContract =>
     #{ BlockingDate => "2006-10-06",
     #  KioskMessage => "example",
     #  DeskMessage => "example",
     #  Method => {FunctionTypeName => "add"},
     #  AssurCardIdentifier => "example", },
     #]
     #InsurerAssurCardIdentifier => "014",
     #}
     my $openstaande_fact_bericht = $contract_cardinstellingen->{openstaande_factuur_blocked_contract_message};
     my $prefix = $contract_cardinstellingen->{kaart_nummer_prefix};
     if ($aantal > 0 ) {
          $mail_contract = $mail_contract."\nEr zijn vandaag $aantal contracten te blokkeren of vrij te geven\n";
          print "\nEr zijn vandaag $aantal contracten te blokkeren of vrij te geven\n";
          foreach my $inz (sort keys $to_Block_Contracts) {
             if ($to_Block_Contracts->{$inz}->{Action} eq 'Block') {
                 my $piece = { BlockingDate => "$vandaag_streep",
                    KioskMessage => "$openstaande_fact_bericht",
                    DeskMessage => "$openstaande_fact_bericht",
                    Method => {FunctionTypeName => "add"},
                    AssurCardIdentifier => "$prefix$inz",
                 };
                 push (@{$data->{BlockedContract}},$piece);
                 $mail_contract = $mail_contract."$vandaag_streep -> Block -> $inz -> $openstaande_fact_bericht -> add\n";
                 print "$vandaag_streep -> Block -> $inz -> $openstaande_fact_bericht -> add\n";
                }elsif  ($to_Block_Contracts->{$inz}->{Action} eq 'Free') {
                 my $piece = { BlockingDate => "$vandaag_streep",
                    KioskMessage => "$openstaande_fact_bericht",
                    DeskMessage => "$openstaande_fact_bericht",
                    Method => {FunctionTypeName => "delete"},
                    AssurCardIdentifier => "$prefix$inz",
                 };
                 $mail_contract = $mail_contract."$vandaag_streep -> Free -> $inz -> $openstaande_fact_bericht -> delete\n";
                 print "$vandaag_streep -> Free -> $inz -> $openstaande_fact_bericht -> delete\n";
                 push (@{$data->{BlockedContract}},$piece);
                }             
             print '';
             #sql_toegang_agresso->Delete_Blockcustassurcard($dbh,$to_Block_Contracts->{$inz}->{ Apar_Id});
            }
         my $xml_file= main->maak_xml;
         #my $xml = read_file( $xml_file ) ;
         #webservice->UploadXMLFile($xml);
         my $is_gemaakt = ftp->copy_file_to_assurcard_upload($xml_file);
         if ($is_gemaakt eq 'error') {
             $mail_contract = $mail_contract."File niet gemaakt op $contract_cardinstellingen->{plaats_assurcard_upload}\nDus data niet uit database verwijderd\n";
             print "File niet gemaakt op $contract_cardinstellingen->{plaats_assurcard_upload}\nDus data niet uit database verwijderd\n";
            }else {
             main->zet_update_in_database($is_gemaakt);
             }
        }else {
          $mail_contract = $mail_contract."\nEr zijn vandaag $aantal contracten te blokkeren of vrij te geven\n";
          print "\nEr zijn vandaag $aantal contracten te blokkeren of vrij te geven\n";
        }
     
     
     
     mail->mail_contract_bericht_contract;
     print'';
     sub load_assurcard_generation_setting_contact_a  {
         my ($class,$file_name) = @_;
         my $contract_cardinstellingen = XMLin("$file_name");
         print "settings ingelezen\n";
         $mail_contract = $mail_contract."settings ingelezen\n";
         #maak verzekeringen
         return($contract_cardinstellingen); 
        }
     sub maak_xml {
        my $tijd = substr ($main::vandaag,8,8);
        $tijd =~ s/://g;
        my $vandaag_xml  = substr ($vandaag,0,8);  # vandaag in YYYYMMDD
        my $plaatsxml= $contract_cardinstellingen->{plaats_file};
        my $nrverzekeraar = $contract_cardinstellingen->{nr_verzekeraar};
        my $naam_file = "$plaatsxml\\BlockedContracts.$nrverzekeraar.$vandaag_xml.$tijd.xml";
        my $xsd = $main::contract_cardinstellingen->{plaats_blockedcontract_xsd};
        my $schema = XML::Compile::Schema->new($xsd);
        # This will print a very basic description of what the schema describes
        $schema->printIndex();
        warn $schema->template('PERL', 'BlockedContracts');
        my $doc    = XML::LibXML::Document->new('1.0', 'UTF-8');
        my $write  = $schema->compile(WRITER => 'BlockedContracts');
        my $xml    = $write->($doc,$data);
        $doc->setDocumentElement($xml);
        my $xml_file= $naam_file;
        open XMLFILE,"> $xml_file" or die "can not open file $xml_file ";
        select XMLFILE;
        print $doc->toString(1); # 1 indicates "pretty print"
        close XMLFILE;
        select STDOUT;
        print '';
        return ($xml_file);
    }

    sub zet_update_in_database {
          my ($class,$file_name) = @_;
          my $updates_in_xml = XMLin("$file_name");
          print "file ingelezen\n";
    #     $mail_contract = $mail_contract."settings ingelezen";
    #     #maak verzekeringen
         eval {foreach my $volgnr (keys @{$updates_in_xml->{BlockedContract}}) {}};
         if (!$@) {
             foreach my $volgnr (keys @{$updates_in_xml->{BlockedContract}}) {
                    my $Apar_Id = $updates_in_xml->{BlockedContract}->[$volgnr]->{AssurCardIdentifier};
                    $Apar_Id =~ s/^8//;
                    my $delete_this = sql_toegang_agresso->Delete_Blockcustassurcard($dbh,$Apar_Id);
                    if ( $delete_this == 1) {
                        $mail_contract = $mail_contract."$Apar_Id uit database Blockcustassurcard verwijdert\n";
                        print "$Apar_Id uit database Blockcustassurcard verwijdert\n";
                    }else {
                        $mail_contract = $mail_contract."Fout ->$Apar_Id kon niet uit database Blockcustassurcard verwijderd worden\n";
                        print "Fout ->$Apar_Id kon niet uit database Blockcustassurcard verwijderd worden\n";
                    }
                    
                    print '';
                }
            }else {
                my $Apar_Id = $updates_in_xml->{BlockedContract}->{AssurCardIdentifier};
                $Apar_Id =~ s/^8//;
                my $delete_this = sql_toegang_agresso->Delete_Blockcustassurcard($dbh,$Apar_Id);
                 if ( $delete_this == 1) {
                    $mail_contract = $mail_contract."$Apar_Id uit database Blockcustassurcard verwijdert\n";
                    print "$Apar_Id uit database Blockcustassurcard verwijdert\n";
                }else {
                    $mail_contract = $mail_contract."Fout ->$Apar_Id kon niet uit database Blockcustassurcard verwijderd worden\n";
                    print "Fout ->$Apar_Id kon niet uit database Blockcustassurcard verwijderd worden\n";
                }
                
                print '';
            }
         
         
        
         print "\nASCARD aangepast\nxml file => $file_name \nKijk na of deze file werd afgeleverd aan assurcard!\nKijk de fouten na!\n Volgende file bevat blokkering van klanten";
         $mail_contract = $mail_contract."\nASCARD aangepast\nxml file => $file_name \nKijk na of deze file werd afgeleverd aan assurcard!\nKijk de fouten na!\n Volgende file bevat blokkering  klanten";
        }

print'';
package ftp;
     use File::Copy;
     use Win32::FileOp;
     sub copy_file_to_assurcard_upload {
         my ($class,$file) = @_;
         my $smbuser = 'assurcard';
         my $smbpasswd = 'Hospiplus';
         my $cifs= $contract_cardinstellingen->{plaats_assurcard_upload};
         my $cifs_readable =$cifs;
         $cifs_readable =~ s/\\/\\\\/g;
         Connect $cifs,{user=>$smbuser,passwd=>$smbpasswd} ;
         my $ret = "";
         if (-e "$cifs\\test.txt") {
             my $test_copy=0;
             copy ("$file"  => $cifs) or $test_copy=&error_mail_copy ("$file" ,$cifs);
             if ($test_copy==0) {
                 $mail_contract=$mail_contract."file $file gekopieerd naar $cifs_readable\n" ;
                 print "file $file gekopieerd naar $cifs_readable\n" ;
                 $file =~ m/BlockedContracts.*\.xml/;
                 my $file_name = $&;
                 $ret = "$cifs\\$file_name";
                }else {
                 $mail_contract=$mail_contract."ERROR !! =>file $file kon niet gekopieerd worden naar $cifs_readable\n" ;
                 print "ERROR !! =>file $file kon niet gekopieerd worden naar $cifs_readable\n" ;
                 $ret = "error";
                }
            }else {
             print "map niet gemaakt";
             my $cifs_leesbaar = $cifs;
             $cifs_leesbaar =~ s/\\/\\\\/g;
             $mail_contract = $mail_contract."\nKAN NETWERK MAP NIET MAKEN $cifs_leesbaar !!!!!\n--------------------------------------------\n";
             print "\nKAN NETWERK MAP NIET MAKEN $cifs_leesbaar !!!!!\n--------------------------------------------\n";
             $mail_contract = $mail_contract."of bestand test.txt staat niet op $cifs_leesbaar \n maak het aan\n";
             print "of bestand test.txt staat niet op $cifs_leesbaar \n maak het aan\n";
             $ret = "error";
            }
         return ($ret);
        }
package mail;
     use Net::SMTP;
     use Date::Manip::DM5 ;
     sub mail_contract_bericht_contract {
            print "mail-start\n";
            my $aan = $contract_cardinstellingen->{mail_verslag_naar};
            my @aan_lijst = split (/\,/,$aan);
            my $van = 'harry.conings@vnz.be';
            my $vandaag = ParseDate("today");
            $vandaag = substr ($vandaag,0,8);  # vandaag in YYYYMMDD
            $vandaag = sprintf "%04d-%02d-%02d",substr ($vandaag,0,4),substr ($vandaag,4,2),substr ($vandaag,6,2);
            foreach my $geadresseerde (@aan_lijst) {
                my $smtp = Net::SMTP->new('mailservices.m-team.be',
                           Hello => 'mail.vnz.be',
                           Timeout => 60);
                #$smtp->auth('mailprogrammas','pleintje203');
                $smtp->mail($van);
                $smtp->to($geadresseerde);
                #$smtp->cc('informatica.mail@vnz.be');
                #$smtp->bcc("bar@blah.net");
                $smtp->data;
                $smtp->datasend("From: harry.conings");
                $smtp->datasend("\n");
                $smtp->datasend("To: Kaartbeheerders");
                $smtp->datasend("\n");
                $smtp->datasend("Subject: Blocked Contract xml verslag $vandaag");
                $smtp->datasend("\n");
                $smtp->datasend("$mail_contract\nvriendelijke groeten\nHarry Conings");
                $smtp->dataend;
                $smtp->quit;
                print "mail aan $geadresseerde  gezonden\n";
            }
        }   
package webservice;
     use SOAP::Lite #;
     +trace => [ transport => sub { print $_[0]->as_string } ];
     use MIME::Base64;
     use LWP::Simple;
     use WWW::Mechanize;
     use Crypt::SSLeay;
     use IO::Socket::SSL qw(debug4);
     use Net::SSLeay;
     use Mozilla::CA;
     use SOAP::WSDL;
     #use SOAP::Transport;
     use SOAP::Transport::HTTP;
     sub UploadXMLFile {
         #$ENV{PERL_LWP_SSL_VERIFY_HOSTNAME}=0;
         #$ENV{HTTPS_CERT_FILE} = 'P:\agressosoap\isabelle.crt';
         #$ENV{SSL_ca_file} = 'P:\agressosoap\assurcard.crt';
         #$ENV{SSL_ca_path} = 'P:\agressosoap\\';
         ##$ENV{PERL_LWP_SSL_CA_FILE}='P:\agressosoap\assurcard_ca64.cer';
         #$ENV{HTTPS_DEBUG} = 1;
         #$ENV{HTTP_DEBUG} = 1;
         #my $proxy = 'https://testinsurer.soap.assurcard.be/insuranceservices.asmx';
         ##my $proxy = 'http://10.198.206.217/AgressoWSHost/service.svc?QueryEngineService/QueryEngineV201101';
         #my $uri   = 'https://testinsurer.soap.assurcard.be/insuranceservices.asmx?op=UploadXMLFile';
         #my $soap = SOAP::Lite
         #    ->proxy($proxy)
         #    ->ns($uri,'mes')
         #    #->on_action( sub { return 'UploadXMLFile' } );
         #    ->result;
         #print '';
         #$soap = SOAP::Lite->proxy("https://example.com:443/soapuri", ssl_opts => [ SSL_verify_mode => 0 ] );
         #my $soap = SOAP::Lite
         # -> uri('https://testinsurer.soap.assurcard.be/')
         # -> on_action( sub { join '/', 'https://testinsurer.soap.assurcard.be', $_[1] } )
         # -> proxy('https://testinsurer.soap.assurcard.be/insuranceservices.asmx',ssl_opts => {
         #            SSL_cert_file => 'P:\agressosoap\isabelle.crt',
         #            SSL_key_file  => 'P:\agressosoap\assurcard.crt',
         #           }
         #       );#ssl_opts => [ SSL_verify_mode => 1 ]
         #
         #print $soap->HelloWorld()->result;
         #print '';
         #BEGIN {
         #       #$ENV{HTTPS_CA_DIR} = 'P:\agressosoap\cert64\AssurcardCA';
         #       $ENV{PERL_LWP_SSL_VERIFY_HOSTNAME} = 0;               
         #       #$ENV{HTTPS_CERT_FILE} = 'P:\agressosoap\cert64\AssurcardCA\AssurcardCA.crt';
         #       $ENV{HTTPS_CA_FILE} = 'P:\agressosoap\cert64\AssurcardCA\AssurcardCA.crt';
         #   }
         #$ENV{HTTPS_CA_FILE} = Mozilla::CA::SSL_ca_file();
         #$ENV{HTTPS_CA_DIR} = 'P:\agressosoap\cert64\AssurcardCA';
         #my  $api_ns = "https://testinsurer.soap.assurcard.be/";
         #my $api_url = "https://testinsurer.soap.assurcard.be/insuranceservices.asmx";
         #my $action = "HelloWorld";
         #
         #my $soap = SOAP::Lite
         #       -> readable(1)
         #       -> ns($api_ns, 'tns')
         #       -> proxy($api_url,ssl_opts => {
         #              #SSL_verify_mode => 0 ,
         #              #SSL_cert_file => 'P:\agressosoap\cert64\AssurcardCA\AssurcardCA.crt',
         #              #SL_key_file  => 'P:\agressosoap\cert64\AssurcardCA\CertRequest.20140324095055432-ReqId',
         #            
         #           })
         #       -> on_action(sub { return "\"$action\""});
         #
         #print $soap->HelloWorld()->result;
         #use LWP::Simple qw(get);
         #$ENV{HTTPS_CA_FILE} = 'P:\agressosoap\cert64\AssurcardCA\AssurcardCA.crt';
         #$ENV{HTTPS_DEBUG} = 1;
         #
         #my $test = get("https://testinsurer.soap.assurcard.be/insuranceservices.asmx");
         #print "$test";
         #print '';
         
         #BEGIN {
         #        IO::Socket::SSL::set_ctx_defaults(
         #        verify_mode => Net::SSLeay->VERIFY_PEER(),
         #        #ca_file => 'P:\agressosoap\cert64\AssurcardCA\CertRequest.20140324095055432-ReqId',
         #        ca_path => 'P:\agressosoap\cert64\AssurcardCA'
         #       );
         #   }
         #use LWP::Simple qw(get);
         #warn get("https://testinsurer.soap.assurcard.be/insuranceservices.asmx");
         #my $rest = get("https://testinsurer.soap.assurcard.be/insuranceservices.asmx");
            print '';
        # my $host = "testinsurer.soap.assurcard.be";
        # my $client = IO::Socket::SSL->new(
        # PeerHost => "$host:443",
        # SSL_verify_mode => 0x02,
        #   SSL_cert_file => 'P:\agressosoap\cert64\AssurcardCA\AssurcardCA.crt',
        #   SSL_key_file  => 'P:\agressosoap\cert64\AssurcardCA\CertRequest.20140324095055432-ReqId.crt',
        #   #SSL_ca_file => Mozilla::CA::SSL_ca_file(),# geeft idem als de twee bovenste
        #    )
        #     || die "Can't connect: $@";
        #
        #     $client->verify_hostname($host, "http")
        #|| die "hostname verification failure";   
        # warn get("https://testinsurer.soap.assurcard.be/insuranceservices.asmx");
         #$ENV{PERL_LWP_SSL_VERIFY_HOSTNAME}=0;
         #$ENV{HTTPS_CERT_FILE} =  'P:\agressosoap\cert64\AssurcardCA\AssurcardCA.crt';
         #$ENV{HTTPS_KEY_FILE}  = 'P:\agressosoap\cert64\AssurcardCA\CertRequest.20140324095055432-ReqId.crt';
          #$ENV{HTTPS_CA_FILE} = Mozilla::CA::SSL_ca_file();
         #$ENV{HTTPS_DEBUG} = 1;
         #my $pemfile = do {
         #    my $path = $INC{ 'Mozilla/CA.pm' };
         #    $path =~ s#\.pm$#/cacert.pem#;
         #    $path;
         #   };
         #if ( -f $pemfile ) {
         #    $ENV{HTTPS_CA_FILE} = $pemfile;
            #$ENV{HTTPS_CERT_FILE}  = 'P:\agressosoap\cert64\AssurcardCA\AssurcardCA.crt';
            #$ENV{HTTPS_CERT_PASS} = 'assurcard':
            #$ENV{HTTPS_KEY_FILE} = 'P:\agressosoap\cert64\AssurcardCA\CertRequest.20140324095055432-ReqId.crt';
            #
         #    #$ENV{HTTPS_CA_DIR} = $pemfile;
         #    print STDERR "HTTPS_CA_FILE set to $pemfile\n";
         #   }else {
         #    warn "PEM file $pemfile missing";
         #   }
         ##warn get('https://testinsurer.soap.assurcard.be/insuranceservices.asmx?op=HelloWorld');         
         #  my $soap = SOAP::Lite
         #    ->ns('http://testinsurer.soap.assurcard.be', 'tns')
         #    -> uri('http://testinsurer.soap.assurcard.be')
         #    -> on_action( sub { join '/', 'https://testinsurer.soap.assurcard.be', $_[1] } )
         #    -> proxy('https://testinsurer.soap.assurcard.be/insuranceservices.asmx') #,
         #               #ssl_opts => {
         #               # SSL_verify_mode => "SSL_VERIFY_PEER" ,
         #               # SSL_session_cache_size => 0,
         #               # SSL_cert_file => 'P:\agressosoap\cert64\AssurcardCA\AssurcardCA.crt',
         #               # SSL_key_file  => 'P:\agressosoap\cert64\AssurcardCA\CertRequest.20140324095055432-ReqId.crt'}
         #            # )
         #   #$soap->transport->ssl_opts(
         #   #     SSL_cert_file => 'P:\agressosoap\cert64\AssurcardCA\AssurcardCA.crt',                 
         #   #     SSL_key_file  => 'P:\agressosoap\cert64\AssurcardCA\CertRequest.20140324095055432-ReqId.crt'
         #   #);
         #
         # print $soap->HelloWorld()->result;     
         #
         #print '';
      }
         