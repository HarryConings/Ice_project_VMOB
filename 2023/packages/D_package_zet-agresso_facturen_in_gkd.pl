#!/usr/bin/perl -w
use strict;
require 'Decryp_Encrypt_prod.pl';
package main;
     use Date::Manip::DM5 ;
     use Date::Calc qw(:all);
     use XML::Simple;
     use Net::SMTP;
     our $vanaf_wanneer = '';
     our $tot_wanneer = '';
     our $vandaag = ParseDate("today");
     
     our $mail = "V7 FACTUREN DIE WE IN HET GKD GEZET HEBBEN\n___________________________________________________\n\n";
     our $mail_niet_gelukt = "\n\nV7 FACTUREN DIE WE NIET IN HET GKD HEBBEN KUNNEN ZETTEN\n___________________________________________________\n\n";
     #$ARGV[1] = 20200120;
     #$ARGV[2] = 20200122;
     our $mode = 'TEST';
     $mode = $ARGV[0] if (defined $ARGV[0]);
     if ( $mode eq 'TEST' or $mode eq 'PROD'){}else{die}
     if ($ARGV[1]) {
         $vanaf_wanneer = $ARGV[1];
         if ($ARGV[2]) {
             $tot_wanneer = $ARGV[2];
            }else {         
             $tot_wanneer = 20991231;
            }
     }else {
         $vanaf_wanneer = $vandaag;
         $vanaf_wanneer = substr($vanaf_wanneer,0,8);
         $tot_wanneer = 20991231;
         #$vanaf_wanneer = 20140101;
     }
     our $agresso_instellingen = XMLin('D:\OGV\ASSURCARD_2023\assurcard_settings_xml\agresso_settings.xml');
     our $PdfToAgresso_instellingen = XMLin('D:\OGV\ASSURCARD_2023\assurcard_settings_xml\PdfToAgresso_settings.xml');
     my $dbh = as400->cnnectdb(203);
     as400->dscnnectdb($dbh);
     $dbh = as400->cnnectdb(235);
     as400->dscnnectdb($dbh);
     my $alle_facturen = webservice->haal_de_klantenfacturen_uit_agresso();
     foreach my $DocId (keys $alle_facturen) {
          print "\t\t-> $DocId -> $alle_facturen->{$DocId}->{LastUpdate} \n";
         if ($alle_facturen->{$DocId}->{LastUpdate} >= $vanaf_wanneer and $alle_facturen->{$DocId}->{LastUpdate} < $tot_wanneer ) {
               print "$DocId -> $alle_facturen->{$DocId}->{LastUpdate} \n";
               webservice->haal_detail_factuur($DocId);                
              
            }
         
        }
     $mail = $mail."\n<-><-><-><-><-><-><-><-><-><-><-><-><-><-><-><->\n".$mail_niet_gelukt;
     &mail_bericht;
     sub mail_bericht {
            #print "mail-start\n";
            my $aan = $agresso_instellingen->{mail_verslag_naar};
            my @aan_lijst = split (/\,/,$aan);
            my $van = 'harry.conings@vnz.be';
            my $vandaag = ParseDate("today");
            my $mail = $main::mail ;
            $vandaag = substr ($vandaag,0,8);  # vandaag in YYYYMMDD
            $vandaag = sprintf "%04d-%02d-%02d",substr ($vandaag,0,4),substr ($vandaag,4,2),substr ($vandaag,6,2);
            foreach my $geadresseerde (@aan_lijst) {
                #my $smtp = Net::SMTP->new('10.63.120.3',
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
                $smtp->datasend("Subject: Facturen in het GKD gezet $vandaag");
                $smtp->datasend("\n");
                $smtp->datasend("$mail\nvriendelijke groeten\nHarry Conings");
                $smtp->dataend;
                $smtp->quit;
                print "mail aan $geadresseerde  gezonden\n";
            }
        }
     sub wrong_password {
         $mail =  $mail."FOUT PASSWOORD PAS PASWOORD FILE AAN IN SETTINGS\n";
         $mail =  $mail."--------------------------------------------------------\n\n";
         $mail =  $mail.'D:\OGV\ASSURCARD_PROG\assurcard_settings_xml\PdfToAgresso_settings.xml'."\n\n";
         print "FOUT PASSWOORD PAS PASWOORD FILE AAN IN SETTINGS\n";
         print "--------------------------------------------------------\n\n";
         &mail_bericht;
         die;
        }

package webservice;

use SOAP::Lite ;
 #+trace => [ transport => sub { print $_[0]->as_string } ];
use MIME::Base64;
use LWP::Simple;
use DateTime::Format::Strptime;
use DateTime;
use Date::Manip::DM5 ;
    sub convert_base64 {
         my ($class,$infile) = @_;
         open INFILE, '<', $infile;        
         binmode INFILE;
         my $buf;
         my $encode ='';
         while ( read( INFILE, $buf, 480 * 57 ) ) {
             $encode .= sprintf (encode_base64( $buf ));
            }
         close INFILE;
         return ($encode);     
        }
    sub Cataloog_createEventWithWarning {      
         my ($class,$extern_nummer,$zkf,$file_name,$file_encode64) = @_;
         my $catalog_Key =$main::PdfToAgresso_instellingen->{Catalog_key_Agresso_fact};   
         $extern_nummer = sprintf("%013s", $extern_nummer );
         my $request = 'createEventWithWarning';
         my $user = $main::PdfToAgresso_instellingen->{ziekenfondsen}->{"zkf$zkf"}->{as400_user}; 
         my $domain = "$zkf";
         my $pass = decrypt->new($main::PdfToAgresso_instellingen->{ziekenfondsen}->{"zkf$zkf"}->{as400_paswoord}); 
         #my $host = 'rfapps.jablux.cpc998.be/RFND_GRP200b_1407.02_20150118_03:80';  # always include the port
         #my $wsdlfn='C:\macros\ClientTool\GEDCatalogService.xml';
         my $endpoint_data = get("http://rfapps.jablux.cpc998.be/WebStartWeb/Jade2Properties/$zkf/connectionspec.properties");
         $endpoint_data =~ m/environment\.name=\d{3}/;
         my $environment_name = $&;
         $environment_name =~ s/environment\.name=//;
         $endpoint_data =~ m/host=[a-zA-Z\d\.\_]+/;
         my $host  = $&;
         $host  =~ s/host=//;
         $endpoint_data =~ m/contextPath=[a-zA-Z\d\_\.]+/;
         my $contextPath= $&;
         $contextPath  =~ s/contextPath=//;
         $endpoint_data =~ m/port=\d+/;
         my $port = $&;
         $port =~ s/port=//;
         my $vandaag = ParseDate("today");
         my $endpoint = "$host:$port/$contextPath/remoting/$environment_name/GEDCatalogService";
         my $folderRef_text = $file_name;       
         $folderRef_text = $main::PdfToAgresso_instellingen->{Catalog_Text};        
         #http://rfapps.jablux.cpc998.be/WebStartWeb/Jade2Properties/203/connectionspec.properties
         #"http://" + serverName + ":" + port + "/" + contextPath + "/remoting/" + environment + "/" + service
         #
         #Servername -> rfapps.ref.cpc998.be
         #Port -> 80
         #contextPath -> RFND_GRP200b_1407.02_20150208_12
         #environment -> 203
         #service -> GEDCatalogService (dit is hardcoded)
         # Jade2 Connection Specs property file for environment 203
         # generated 10-feb-2015  by rfapps.jablux.cpc998.be
         #environment.name=203
         #host=rfapps.jablux.cpc998.be
         #port=80
         #contextPath=RFND_GRP200b_1407.02_20150208_12
         #my $endpoint = "http://rfapps.jablux.cpc998.be:80/RFND_GRP200b_1407.02_20150208_12/remoting/203/GEDCatalogService";
         my $uri   = 'http://ged.services.common.com.gfdi.be';
         my $soap = SOAP::Lite
             ->proxy("http://$user:$pass\@$endpoint")
             ->ns($uri)
             ->on_action( sub { join '/','http://ged.services.common.com.gfdi.be',$request } )
            ;
          #   'credentials => [
          #  'services.soaplite.com:80',        # host:port
          #  'SOAP::Lite authentication tests', # realm
          #  'soaplite' => 'authtest',          # user, password
          #]   
             #return svc.createEventWithWarning(new wsCatalog.CreateEventRequest()
             #          {
             #              docType = docType,
             #              thirdCodeType = "EXID",
             #              thirdCodeValue = externalNumber,
             #              thirdOrg = this.MUTNr,
             #              thirdParType = "MUTUALITYPERSON",
             #              imageMimeType = "application/pdf",
             #              imageName = filename,
             #              imageBytes = buffer
             #          });
             #   }
             
              
              my $docType    = SOAP::Data->name('docType' => "$catalog_Key")->type('');
              my $folderRef  = SOAP::Data->name('folderRef'=> "$folderRef_text")->type('');
              my $thirdCodeType = SOAP::Data->name('thirdCodeType' => "EXID")->type('');
              my $thirdCodeValue = SOAP::Data->name('thirdCodeValue' => "$extern_nummer")->type('');
              my $thirdOrg = SOAP::Data->name('thirdOrg' => $zkf)->type('');
              my $thirdParType = SOAP::Data->name('ThirdParType' =>"MUTUALITYPERSON")->type('');
              my $imageMimeType = SOAP::Data->name('imageMimeType' => "application/pdf")->type('');
              my $imageName  = SOAP::Data->name('imageName' => "$file_name")->type('');
              my $imageBytes = SOAP::Data->name('imageBytes' => "$file_encode64")->type('');
              #my $folderType = SOAP::Data->name('folderType' => "Zorgverzekering")->type('');
              #my $folderRef  = SOAP::Data->name('folderRef' => "00NoRefDossier")->type('');
              my $createEventWithWarning = SOAP::Data->name('createEventWithWarning') ->attr({xmlns => "$uri"});
              my $in0 = SOAP::Data->name('in0')
              ->value(\SOAP::Data->value($docType,$folderRef,$thirdCodeType,$thirdCodeValue,
                                         $thirdOrg,$thirdParType,$imageMimeType,$imageName,$imageBytes));
              my $response ;
              eval{$response= $soap->call($createEventWithWarning,$in0)};
              print "$@\n";
              if ($@){
                print "tweede poging\n";
                eval{$response= $soap->call($createEventWithWarning,$in0)};
              }
               
              eval {my $key = $response->{_content}->[2]->[0]->[2]->[0]->[4]->{out}->{key}};
             
              if (!$@) {
                 my $key = $response->{_content}->[2]->[0]->[2]->[0]->[4]->{out}->{key};
                 return ('gelukt',$key);
              }else {
                 return ('mislukt');
              }
              
              
         }
    sub haal_de_klantenfacturen_uit_agresso {
        my ($class ) = @_;
        my $clientnummer = $main::klant->{Agresso_nummer};
        my $alle_facturen;
        my $agresso_proxy = $main::agresso_instellingen->{"Agresso_IP_$main::mode"};
        my $zoekjaar=substr($vandaag,0,8);
        my $eindjaartest = substr($zoekjaar,4,4);
        if ($eindjaartest == 101) {
             $zoekjaar  = substr($zoekjaar,0,4)-1;
             $vanaf_wanneer=$zoekjaar*10000+1231;             
        }else {
               $zoekjaar  = substr($zoekjaar,0,4);               
        }
        ##$clientnummer = 67122533419;#;100048 100248 166516
        use SOAP::Lite ;
        #my $proxy = 'http://10.198.205.8/AgressoWSHost/service.svc';
        my $proxy = "http://$agresso_proxy/service.svc?ImportService/ImportV200606";
        my $uri   = 'http://services.agresso.com/DocArchiveService/DocArchiveV201101';
        my $soap = SOAP::Lite
              ->proxy($proxy)
              ->ns($uri,'doc')
              ->on_action( sub { return 'GetDocumentProperties' } );
       my $DocType = SOAP::Data->name('doc:DocType'=> "KLANTFACTUUR")->type('');
       my $Status = SOAP::Data->name('doc:Status'=> "N")->type('');
       my $GetIndexValues = SOAP::Data->name('doc:GetIndexValues'=> "false")->type('');
       my $string = SOAP::Data->name('doc:string'=> 'VMOB')->type('');
       my $string1 = SOAP::Data->name('doc:string'=> '')->type('');
       my $string2 = SOAP::Data->name('doc:string'=> $zoekjaar)->type('');
       my $IndexValues = SOAP::Data->name('doc:IndexValues')->value(\SOAP::Data->value($string,$string1,$string2));
       my $request =  SOAP::Data->name('doc:request')->value(\SOAP::Data->value($DocType,$Status,
                          $GetIndexValues,$IndexValues));
       my $Username    = SOAP::Data->name('doc:Username' => 'WEBSERV')->type('');
       my $Client      = SOAP::Data->name('doc:Client'   => 'VMOB')->type('');
       my $Password    = SOAP::Data->name('doc:Password' => 'WEBSERV')->type('');
       my $credentials = SOAP::Data->name('doc:credentials') ->value(\SOAP::Data->value($Username, $Client, $Password));
       #my $AddDocument = SOAP::Data->name('doc:AddDocument')->value(\SOAP::Data->value($newDocument,$credentials));
       my $response = $soap->GetDocumentProperties($request,$credentials);
       print "";
       my $link = $response->{_content}->[2]->[0]->[2]->[0]->[4]->{GetDocumentPropertiesResult}->{Properties}->{DocumentProperties};
       eval {foreach my $key (keys $link) {}};
       if (!$@) {
         foreach my $key (keys $link) {
             my $DocId = $link->[$key]->{DocId};
             my $LastUpdate = $link->[$key]->{LastUpdate};
             $LastUpdate = substr ($LastUpdate,0,10);
             $LastUpdate =~ s/-//g;
             $alle_facturen->{$DocId} = {
                 'LastUpdate' => $LastUpdate,
                 'MimeType' => $link->[$key]->{MimeType},                 
                };
            }#code
         print "";
       }
      return ($alle_facturen); 
       
    }
     sub haal_detail_factuur {
        my ($class,$DocId_nr ) = @_;
        my $clientnummer = $main::klant->{Agresso_nummer};
        my $alle_facturen;
        ##$clientnummer = 67122533419;#;100048 100248 166516
        use SOAP::Lite ;
       # my $proxy = 'http://10.198.205.8/AgressoWSHost/service.svc';
        my $proxy = 'http://S200WP1XXL01.mutworld.be/BusinessWorld-webservices/service.svc';
        #my $proxy ='http://S200WR2XXL01.mutworld.be/BusinessWorld-webservices/service.svc';
        #my $proxy = 'http://10.198.206.217/AgressoWSHost/service.svc';
        my $uri   = 'http://services.agresso.com/DocArchiveService/DocArchiveV201101';
        my $soap = SOAP::Lite
              ->proxy($proxy)
              ->ns($uri,'doc')
              ->on_action( sub { return 'GetDocumentRevision' } );
       my $DocId = SOAP::Data->name('doc:DocId'=> $DocId_nr)->type('');      
       my $DocType = SOAP::Data->name('doc:DocType'=> "KLANTFACTUUR")->type('');
       my $RevisionNo = SOAP::Data->name('doc:RevisionNo'=> 0)->type('');
       my $PageNo = SOAP::Data->name('doc:PageNo'=> 1)->type('');       
       my $request =  SOAP::Data->name('doc:request')->value(\SOAP::Data->value($DocId,$DocType,$RevisionNo,$PageNo));
       my $Username    = SOAP::Data->name('doc:Username' => 'WEBSERV')->type('');
       my $Client      = SOAP::Data->name('doc:Client'   => 'VMOB')->type('');
       my $Password    = SOAP::Data->name('doc:Password' => 'WEBSERV')->type('');
       my $credentials = SOAP::Data->name('doc:credentials') ->value(\SOAP::Data->value($Username, $Client, $Password));
       #my $AddDocument = SOAP::Data->name('doc:AddDocument')->value(\SOAP::Data->value($newDocument,$credentials));
       my $response = $soap->GetDocumentRevision($request,$credentials);
       my $link;
       our $Description = '';
       our $FileContent = '';
       our $FileName = '';
       our $Agresso_nummer = '';
       our $RevisionDate ='';
       if ($response->{_content}->[2]->[0]->[2]->[0]->[4]->{GetDocumentRevisionResult}->{Response}->{Status} == 0) {
         $link = $response->{_content}->[2]->[0]->[2]->[0]->[4]->{GetDocumentRevisionResult}->{Revision};
         $Description = $link->{Description};
         $FileContent = $link->{FileContent};
         $FileName = $link->{FileName};
         $Agresso_nummer = $link->{IndexValues}->{string}->[1];
         $RevisionDate = $link->{RevisionDate}; 
         my ($zkf,$extnr)= as400->extern_nummer($Agresso_nummer);
         print "";
         if ($extnr > 0 and $zkf > 0) {
                #my ($class,$extern_nummer,$zkf,$file_name,$file_encode64) = @_;
                my ($gelukt,$key) = webservice->Cataloog_createEventWithWarning($extnr,$zkf,$FileName,$FileContent);
                #my ($gelukt,$key) = ('gelukt','test_key_niet_in_gkd');
                print "";
                if ($gelukt eq 'gelukt') {
                    $main::mail = $main::mail."\n"."$Agresso_nummer ->$zkf $extnr ->$Description \n";
                    print "";
                   }else {
                    $main::mail_niet_gelukt =  $main::mail_niet_gelukt."\n"."$Agresso_nummer ->$zkf $extnr ->$Description \n";
                   }
            }else {
                 $main::mail = $main::mail."\n"."geen extern nr $extnr voor agresso nr $Agresso_nummer\n";
                 print "\ngeen extern nr $extnr voor agresso nr $Agresso_nummer\n";
            }
       }
       print "";
       
       
  }
package as400;
     use DBD::ODBC;
     use DBI;
     use MIME::Base64;
     sub extern_nummer {
         my ($class,$Agresso_nummer) = @_; # tzst
         my $ascard_fil = "libcxcom20.ASCARD",
         my $dbh = as400->cnnectdb(203);
         #ZKF
         #EXID52 extern nummer
         #KNRN52 rijksregister nummer
         #DOSSNR dossiernr
         #NAAM52 naam
         #VNAAM voornaam
         #INZDAT    datum caard ok en ingezet
         #CREDAT datum file naar assurcard zetes
         #EINDAT einddatum kaart
         #EINCON einddatum contract
         #CARDNR cardnummer
         #ASSNR  assurcar ensurance number
         #OKNOW  is nu ok als yes
         #DTCGOK datum waarop ok het laast werd veranderd
         #CARDTY cardtype
         #DTCATY datum waarop het cardtype het laatst verandert werd
         #LOSTCARD kaart is verloren en er moet een ieuwe gegenereerd 0 is niet verloren 1 = verloren
         #BATCHNR nummer van de batch waarmee de kaart gemaakt
         #TESTPROD  VARCHAR(1) T is test P = productie
         #ONTSLAGO  VARCHAR(1) J = onderzozk of het om een onstlag gaat contract xml N = niets doen
         #CXMLINIT VARCHAR(1) Y = deze is al opgenomen in contract xml N = moet nog doorgestuurd worden
         #CXMLUPDA VARCHAR(1) Y = er is iets veranderd en deze moet doorgestuurd N = moet niet doorgestuurd worden
         #WANBET VARCHAR(1) Y = het is een wanbetaler kaart geblokkeerd N = geen wanbetaler kaart niet geblokkeerd
         #ONTSLAG VARCHAR(1) Y = ontslagen kaart geblokkeerd N = niet ontslagen
         #AGRESONR is nummer voor agresso begint bij 100000
         my ($ZKF,$EXID52) =$dbh->selectrow_array("SELECT ZKF,EXID52 FROM $ascard_fil WHERE AGRESONR = $Agresso_nummer");
         as400->dscnnectdb($dbh);
         return ($ZKF,$EXID52);
        }

     sub cnnectdb {
         use strict;
         use DBD::ODBC;
         use DBI;
         my ($self,$zkf_nr) = @_;
         my $user_name= $main::PdfToAgresso_instellingen->{ziekenfondsen}->{"zkf$zkf_nr"}->{as400_user};     	     #username as400
         my $password=decrypt->new($main::PdfToAgresso_instellingen->{ziekenfondsen}->{"zkf$zkf_nr"}->{as400_paswoord});              #paswoord
         my $as400= $main::PdfToAgresso_instellingen->{ziekenfondsen}->{"zkf$zkf_nr"}->{name_as400};                 #naam as400
         my $DSN="driver={iSeries Access ODBC Driver};System=$as400";
         # connect to database
         #
         my $dbh = DBI->connect("dbi:ODBC:$DSN",$user_name,$password) or main->wrong_password ;
         #
         #  dbh->disconnect;
         return ($dbh)
        }
     sub dscnnectdb {
         my ($self,$dbh)= @_;
         $dbh->disconnect;
        } 
    