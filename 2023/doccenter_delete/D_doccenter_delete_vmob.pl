#!/usr/bin/perl -w
#in GIT gezet
#opgelet!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! versie aangepast voor download jade moet nog verder afgewerkt
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

#Door het openen van deze broncode stem je in met de voorgaande voorwaarden.
#versie 2.0 opvragen documenten uit de cataloog
use strict;
use XML::Simple;
use MIME::Base64;
require 'Decryp_Encrypt.pl';
package main;
     our $instellingen = main->load_settings('D:\OGV\ASSURCARD_2023\assurcard_settings_xml\doccenter_delete.xml');
     our @zkfnr;
     #my $test = webservice->GetCatalogKeys();
     my $app = App->new();          
     $app->MainLoop;
     sub load_settings  {
         my ($class,$file_name)= @_;
         print "$file_name";
         my $instellingen = XMLin("$file_name");
         foreach my $zkf (keys $instellingen->{ziekenfondsen}) {
            my $zkfno = $zkf;
            $zkfno =~ s/zkf//i;
            push @main::zkfnr,$zkfno;
            # print "$instellingen->{ziekenfondsen}->{$zkf}->{ziekenfondsen}->{as400_paswoord}\n";
            $instellingen->{ziekenfondsen}->{$zkf}->{as400_paswoord} = decrypt->new($instellingen->{ziekenfondsen}->{$zkf}->{as400_paswoord});
         }
         print "->ingelezen\n";
         #maak verzekeringen         
         $instellingen->{as400_paswoord} = decrypt->new($instellingen->{as400_paswoord});
         return ($instellingen);
        }
package App;
     use strict;
     use warnings;
     use base 'Wx::App';
     sub OnInit {
         $main::dialog = Frame->new();
         #$main::frame->Maximize( 1 );
         $main::dialog->SetSize(1, 1, 650, 360);
         $main::dialog->Centre();
         
         $main::dialog->Show(1);
        }
package webservice;    
     use SOAP::Lite #;
     +trace => [ transport => sub { print $_[0]->as_string } ];
     use MIME::Base64;
     use LWP::Simple;
     use DateTime::Format::Strptime;
     use DateTime;
     use Date::Manip::DM5 ;
     our $documenten;
     sub Cataloog_updateStatusForDelete {      
         my ($class,$zf,$catalog_key) = @_;
         #my $test = uc $main::instellingen->{Klant};
         #<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ged="http://ged.services.common.com.gfdi.be">
         #<soapenv:Header/>
         #   <soapenv:Body>
         #      <ged:updateStatusForDelete>
         #         <ged:in0>203-2015-203-0000000000</ged:in0>
         #      </ged:updateStatusForDelete>
         #   </soapenv:Body>
         #</soapenv:Envelope>
         my $request = 'ged:updateStatusForDelete';
         my $user = $main::instellingen->{ziekenfondsen}->{"zkf$zf"}->{as400_user}; 
         my $domain = $main::instellingen->{ziekenfondsen}->{"zkf$zf"}->{nr};        
         my $pass = $main::instellingen->{ziekenfondsen}->{"zkf$zf"}->{as400_paswoord};
         #my $host = 'rfapps.jablux.cpc998.be/RFND_GRP200b_1407.02_20150118_03:80';  # always include the port
         #my $wsdlfn='C:\macros\ClientTool\GEDCatalogService.xml';
          my $endpoint_data = get("http://rfapps.jablux.cpc998.be/WebStartWeb/Jade2Properties/$zf/connectionspec.properties");
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
          my $uri   = 'http://ged.services.common.com.gfdi.be';
          my $soap = SOAP::Lite
             ->proxy("http://$user:$pass\@$endpoint")
             ->ns($uri,'ged')
             ->autotype(0)
             #->on_action( sub { join '/','http://ged.services.common.com.gfdi.be',$request } )
              ->on_action( sub { return 'updateStatusForDelete' } );
            ;
          my $updateStatusForDelete = SOAP::Data->name('ged:updateStatusForDelete')->type('');
          #my $in0 = SOAP::Data->name('ged:in0')->value(\SOAP::Data->value($catalog_key)->type(''));
          my $in0 = SOAP::Data->name('ged:in0' =>"$catalog_key");
          my $response = $soap->updateStatusForDelete(SOAP::Data->name('ged:in0' =>"$catalog_key"));
          #my $response = $soap->call($updateStatusForDelete,$in0);
          print "";
          eval {my $key = $response->{_content}->[2]->[0]->[2]->[0]->[4]->{faultstring}};                
          if (!$@) {
             my $fout = $response->{_content}->[2]->[0]->[2]->[0]->[4]->{faultstring};
             return ($fout);
            }else {       
             return ('gelukt');
            }
            
        }
     sub Cataloog_updateStatusForDouble {      
         my ($class,$zf,$catalog_key) = @_;
         #my $test = uc $main::instellingen->{Klant};
         #<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ged="http://ged.services.common.com.gfdi.be">
         #<soapenv:Header/>
         #   <soapenv:Body>
         #      <ged:updateStatusForDelete>
         #         <ged:in0>203-2015-203-0000000000</ged:in0>
         #      </ged:updateStatusForDelete>
         #   </soapenv:Body>
         #</soapenv:Envelope>
         $catalog_key =~ s/"//g;
         my $request = 'updateStatusForDouble';
         my $user = $main::instellingen->{ziekenfondsen}->{"zkf$zf"}->{as400_user}; 
         my $domain = $main::instellingen->{ziekenfondsen}->{"zkf$zf"}->{nr};        
         my $pass = $main::instellingen->{ziekenfondsen}->{"zkf$zf"}->{as400_paswoord}; 
         #my $host = 'rfapps.jablux.cpc998.be/RFND_GRP200b_1407.02_20150118_03:80';  # always include the port
         #my $wsdlfn='C:\macros\ClientTool\GEDCatalogService.xml';
          my $endpoint_data = get("http://rfapps.jablux.cpc998.be/WebStartWeb/Jade2Properties/$zf/connectionspec.properties");
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
          my $uri   = 'http://ged.services.common.com.gfdi.be';
          my $soap = SOAP::Lite
             ->proxy("http://$user:$pass\@$endpoint")
             ->ns($uri,'ged')
             ->autotype(0)
             #->on_action( sub { join '/','http://ged.services.common.com.gfdi.be',$request } )
             ->on_action( sub { return 'updateStatusForDouble' } );
            ;
          my $updateStatusForDouble = SOAP::Data->name('ged:updateStatusForDouble') ->attr({xmlns => "$uri"});
          #my $in0 = SOAP::Data->name('ged:in0')->value(\SOAP::Data->value($catalog_key));
          my $in0 = SOAP::Data->name('ged:in0' =>"$catalog_key");
          #my $response = $soap->call($updateStatusForDouble,$in0);
          my $response = $soap->updateStatusForDouble(SOAP::Data->name('ged:in0' =>"$catalog_key"));
          print "";
          eval {my $key = $response->{_content}->[2]->[0]->[2]->[0]->[4]->{faultstring}};                
          if (!$@) {
             my $fout = $response->{_content}->[2]->[0]->[2]->[0]->[4]->{faultstring};
             return ($fout);
            }else {
             return ('gelukt');
            }
            
        }
     
     sub GetCatalogKeys {
      my ($class,$zf,$NaamBrief,$Begindatum,$Einddatum,$pagina,$frame) = @_; 
      #my ($class,$type,$extern_nummer,$doctype,$catalogstartdate,$catalogenddate,$pageNumber,$frame,$zf,$inz_nr) = @_;
     
         
         undef $documenten;
         my $pageNumber = $pagina;
         my $doctype = $NaamBrief;
         my $jaarstart = substr($Begindatum,0,4);
         my $maandstart = substr($Begindatum,4,2);
         my $dagstart = substr($Begindatum,6,2);
         my $catalogstartdate ="$jaarstart-$maandstart-$dagstart"."T00:00:01";
         my $jaarend = substr($Einddatum,0,4);
         my $maandend = substr($Einddatum,4,2);
         my $dagend = substr($Einddatum,6,2);
         my $catalogenddate ="$jaarend-$maandend-$dagend"."T23:59:59";
         #$doctype ='PSEPPRPP';
         #$catalogstartdate ='2016-01-01T11:32:52';
         #$catalogenddate ='2016-01-12T11:32:52';
         #$extern_nummer = '0014222900034';
         #$extern_nummer = '';
         #my $test = uc $main::instellingen->{Customer};
         #<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ged="http://ged.services.common.com.gfdi.be">
         #<soapenv:Header/>
         #   <soapenv:Body>
         #      <ged:updateStatusForDelete>
         #         <ged:in0>203-2015-203-0000000000</ged:in0>
         #      </ged:updateStatusForDelete>
         #   </soapenv:Body>
         #</soapenv:Envelope>
         my $request = 'findByParameters';
         my $user = $main::instellingen->{ziekenfondsen}->{"zkf$zf"}->{as400_user}; 
         my $domain = $main::instellingen->{ziekenfondsen}->{"zkf$zf"}->{nr};        
         my $pass = $main::instellingen->{ziekenfondsen}->{"zkf$zf"}->{as400_paswoord}; 
         #my $host = 'rfapps.jablux.cpc998.be/RFND_GRP200b_1407.02_20150118_03:80';  # always include the port
         #my $wsdlfn='C:\macros\ClientTool\GEDCatalogService.xml';
         my $zkf = $main::instellingen->{ziekenfondsen}->{$zf}->{nr};          
          my $endpoint_data = get("http://rfapps.jablux.cpc998.be/WebStartWeb/Jade2Properties/$zf/connectionspec.properties");
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
          my $uri   = 'http://ged.services.common.com.gfdi.be';
          my $soap = SOAP::Lite
             ->proxy("http://$user:$pass\@$endpoint")
             ->ns($uri,'ged')
             #->on_action( sub { join '/','http://ged.services.common.com.gfdi.be',$request } )
             ->on_action( sub { return 'findByParameters' } );
            ;
          my $findByParameters = SOAP::Data->name('ged:findByParameters') ->attr({xmlns => "$uri"});
          my $docType    = SOAP::Data->name('docType' => "$doctype")->type('');
          my $catalogEndDate    = SOAP::Data->name('catalogEndDate' => "$catalogenddate")->type('');
          my $catalogStartDate    = SOAP::Data->name('catalogStartDate' => "$catalogstartdate")->type('');         
          my $thirdOrg = SOAP::Data->name('thirdOrg' => $zf)->type('');
          my $pageSize  = SOAP::Data->name('pageSize' => $main::instellingen->{page_size_doccenter})->type('');
          my $setPageNumber  = SOAP::Data->name('pageNumber' => $pageNumber)->type('');
          #my $in0 = SOAP::Data->name('ged:in0')->value(\SOAP::Data->value($catalog_key));
          my $in0 = '';
     
          if ($doctype ne '') {
              $in0 = SOAP::Data->name('ged:in0')
                 ->value(\SOAP::Data->value($catalogEndDate,$catalogStartDate,$docType,$thirdOrg,$pageSize,$setPageNumber)); #$thirdCodeType,$thirdCodeValue,
          }else {
             return (0);
          }
          
         
          #my $response = $soap->call($updateStatusForDouble,$in0);
          my $response = $soap->call($findByParameters,$in0);
          print "";
          my $docteller = 0;
          #eval {my $key = $response->{_content}->[2]->[0]->[2]->[0]->[4]->{faultstring}};          
          if ($response->{_content}->[2]->[0]->[2]->[0]->[4]->{faultstring} ne '') {
             #my $fout = $response->{_content}->[2]->[0]->[2]->[0]->[4]->{faultstring};
             #  Wx::MessageBox("$fout", 
             #                _T("Error"), 
             #                wxOK|wxCENTRE, 
             #                $frame
             #               );#code
             return (0);
            }else {
             eval {my $link =  $response->{_content}->[2]->[0]->[2]->[0]->[4]->{out}->{GEDEvent}};
             if ($@) {
                 return(0);
             }
             my $locatie_log = $instellingen->{locatie_log};
             open(my $fh, ">>", "$locatie_log\\externummer$zf.txt") ;
             my $link =  $response->{_content}->[2]->[0]->[2]->[0]->[4]->{out}->{GEDEvent};
             eval {my $key = $link->[0]->{key}};
             if (!$@) {                 
                 foreach my $doc_teller (sort keys $link){
                     my $key = $link->[$doc_teller]->{key};                    
                     my $voornaam = $link->[$doc_teller]->{thirdFName};
                     my $achternaam = $link->[$doc_teller]->{thirdName};
                     my $thirdtype = $link->[$doc_teller]->{thirdPartyType};
                     my $folder = $link->[$doc_teller]->{folderType};
                     my $docType = $link->[$doc_teller]->{docType};
                     my $dcId = $link->[$doc_teller]->{dcId};
                     my $direction = $link->[$doc_teller]->{direction};
                     my $catalogdate = $link->[$doc_teller]->{catalogDate};
                     $documenten->{$key}->{VoorNaam}=$voornaam;
                     $documenten->{$key}->{AchterNaam} = $achternaam;
                     $documenten->{$key}->{thirdPartyType} = $thirdtype;
                     $documenten->{$key}->{folder} = $folder;
                     $documenten->{$key}->{doctType} =$docType;
                     $documenten->{$key}->{dcId} = $dcId;
                     $documenten->{$key}->{direction}= $direction;
                     $documenten->{$key}->{catdate}= $catalogdate;
                     $docteller += 1;
                    }
                 print '';
                }else {
                 my $key = $link->{key};               
                 my $voornaam = $link->{thirdFName};
                 my $achternaam = $link->{thirdName};
                 my $thirdtype = $link->{thirdPartyType};
                 my $folder = $link->{folderType};
                 my $docType = $link->{docType};
                 my $dcId = $link->{dcId};
                 my $direction = $link->{direction};                 
                 $documenten->{$key}->{VoorNaam}=$voornaam;
                 $documenten->{$key}->{AchterNaam} = $achternaam;
                 $documenten->{$key}->{thirdPartyType} = $thirdtype;
                 $documenten->{$key}->{folder} = $folder;
                 $documenten->{$key}->{doctType} =$docType;
                 $documenten->{$key}->{dcId} = $dcId;
                 $documenten->{$key}->{direction}= $direction;
                 $docteller += 1;
                 #my $url = webservice->make_commen_download_url();
                 #webservice->download_file($url,$key,$direction);
                 print '';
                }
             close $fh;
             return ($docteller,$documenten);
            }
     }
     sub make_commen_download_url {
         my ($class) = @_;
          my $zkf = $main::instellingen->{zkf};
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
          my $endpoint = "http://$host:$port/$contextPath/remoting/$environment_name/imageViewer?lang=fr&key=";
          return ($endpoint);
        }
     sub download_url {
         my ($class,$url,$dcId,$direction) = @_;
         my $generate = "false";
         if ($direction eq 'OUT') {
             $generate = 'true';
         }
         my $user= $main::instellingen->{as400_user};
         my $passwd = $main::instellingen->{as400_paswoord};
         my $basicauth = encode_base64("$user:$passwd");
          my $test = decode_base64($basicauth);
         my $download_url = $url."$dcId&format=pdf&generate=$generate&vl=false&basicauth=$basicauth&c_tb_img=false&c_tb_view=false&c_tb_ann=false&h_tb_ann=false&zoom=1.0&notes_enabled=false&ann_enabled=false&Scale=best";
         print "\n$download_url\n";
         return ($download_url);
    }
package Frame;
     use Wx qw[:everything];
     use base qw(Wx::Frame);
     use Date::Manip::DM5 ;
     use Wx::Locale gettext => '_T';
     #my $old_charset = odfLocalEncoding(); #versie 5.2 charset utf8 
     #odfLocalEncoding('iso-8859-15');  #versie 5.2
      sub new {
               use warnings;
               use Wx qw(:everything);
               use base qw(Wx::Frame);
               use Data::Dumper;
               use Wx::Locale gettext => '_T';
               my($frame) = @_;
               my $Delete_is_checked;
               my $Double_is_checked;
               my $Enkel_eattest_is_checked;
               my $CatalogKey;
               my $DocType = 'HA0431';
               my $begindate = substr(ParseDate("today"),0,8);
               my $enddate = substr(ParseDate("today"),0,8);
               my $getkeys_is_checked;
               $frame = $frame->SUPER::new(undef, -1,_T("Welk Catalogus item wil je bewerken"),
                                        [-1,-1],[650,360], wxDEFAULT_FRAME_STYLE | wxTAB_TRAVERSAL  );
               #$frame->Wx::Size->new(800,600) ;
               $frame->{Frame_Sizer_1} = Wx::FlexGridSizer->new(9,7, 10, 10);
               $frame->{Frame_chk_Delete}  = Wx::CheckBox->new($frame, -1, $Delete_is_checked,wxDefaultPosition,wxSIZE(80,20));
               $frame->{Frame_statictxt_Delete}= Wx::StaticText->new($frame, -1,_T("Delete ?"),wxDefaultPosition,wxSIZE(80,20));
               $frame->{Frame_chk_Double}  = Wx::CheckBox->new($frame, -1, $Double_is_checked,wxDefaultPosition,wxSIZE(80,20));
               $frame->{Frame_statictxt_Double}= Wx::StaticText->new($frame, -1,_T("Double ?"),wxDefaultPosition,wxSIZE(80,20));
               $frame->{Frame_Txt_CatalogKey} = Wx::TextCtrl->new($frame, -1, $CatalogKey,wxDefaultPosition,wxSIZE(260,20));
               $frame->{Frame_Txt_Bestand} = Wx::TextCtrl->new($frame, -1, $CatalogKey,wxDefaultPosition,wxSIZE(260,20));   
               $frame->{Frame_Button_OK}  = Wx::Button->new($frame, -1, _T("OK"),wxDefaultPosition,wxSIZE(80,20));
               $frame->{Frame_Cancel}  = Wx::Button->new($frame, -1, _T("Cancel"),wxDefaultPosition,wxSIZE(80,20));
               $frame->{Frame_statictxt_Catalog_Key}= Wx::StaticText->new($frame, -1,_T("Catalog Key"),wxDefaultPosition,wxSIZE(260,20));
               $frame->{Frame_statictxt_Bestand}= Wx::StaticText->new($frame, -1,_T("Bestand"),wxDefaultPosition,wxSIZE(260,20));
               $frame->{Frame_panel_1} = Wx::Panel->new($frame,-1,wxDefaultPosition,wxSIZE(25,5));
               $frame->{Frame_Button_Bestand}  = Wx::Button->new($frame, -1, _T("....."),wxDefaultPosition,wxSIZE(80,20));
               $frame->{Frame_chk_Enkel_eattest}  = Wx::CheckBox->new($frame, -1, $Enkel_eattest_is_checked,wxDefaultPosition,wxSIZE(80,20));
               $frame->{Frame_statictxt_Enkel_eattest}= Wx::StaticText->new($frame, -1,_T("Enkel eAtesten?"),wxDefaultPosition,wxSIZE(80,20));
               $frame->{Frame_statictxt_ZKF} = Wx::StaticText->new($frame, -1,_T("ZIEKENFONDS ?"),wxDefaultPosition,wxSIZE(80,20)); 
               $frame->{Frame_choice_ZKF}  = Wx::Choice->new($frame, 26,wxDefaultPosition,wxSIZE(80,20),\@main::zkfnr);
               $frame->{Frame_statictxt_DT} = Wx::StaticText->new($frame, -1,_T("DocType ?"),wxDefaultPosition,wxSIZE(80,20));
               $frame->{Frame_Txt_DT} = Wx::TextCtrl->new($frame, -1, $DocType,wxDefaultPosition,wxSIZE(260,20));
               $frame->{Frame_statictxt_keys} = Wx::StaticText->new($frame, -1,_T("Get Keys ?"),wxDefaultPosition,wxSIZE(80,20));
               $frame->{Frame_statictxt_BD} = Wx::StaticText->new($frame, -1,_T("Begin Date ?"),wxDefaultPosition,wxSIZE(80,20));
               $frame->{Frame_Txt_BD} = Wx::TextCtrl->new($frame, -1, $begindate,wxDefaultPosition,wxSIZE(80,20));  
               $frame->{Frame_statictxt_ED} = Wx::StaticText->new($frame, -1,_T("End Date ?"),wxDefaultPosition,wxSIZE(80,20));
               $frame->{Frame_Txt_ED} = Wx::TextCtrl->new($frame, -1, $enddate,wxDefaultPosition,wxSIZE(80,20));  
               $frame->{Frame_chk_keys}  = Wx::CheckBox->new($frame, -1, $getkeys_is_checked,wxDefaultPosition,wxSIZE(80,20));
               #rij0
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               #rij1
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_statictxt_ZKF}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_choice_ZKF}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);              
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               #rij2
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_statictxt_DT}, 0, wxALIGN_BOTTOM|wxALIGN_CENTER);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);      
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_statictxt_keys}, 0, wxALIGN_BOTTOM|wxALIGN_LEFT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_statictxt_BD}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_statictxt_ED}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               #rij3
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_Txt_DT}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_chk_keys}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_Txt_BD} , 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);                
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_Txt_ED}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               #rij4
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_statictxt_Catalog_Key}, 0, wxALIGN_BOTTOM|wxALIGN_CENTER);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_statictxt_Double}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_statictxt_Delete}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_statictxt_Enkel_eattest}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT); 
               #RIJ 5
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_Txt_CatalogKey}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_chk_Double}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_chk_Delete}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_chk_Enkel_eattest}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               #RIJ 6
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_statictxt_Bestand}, 0, wxALIGN_BOTTOM|wxALIGN_CENTER);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);     
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               #RIJ 7
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_Txt_Bestand}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_Button_Bestand}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);     
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               #rij 8
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               #RIJ 9
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);               #
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_Button_OK}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_Cancel}, 0, wxALIGN_BOTTOM|wxALIGN_LEFT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);               
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_LEFT);
               $getkeys_is_checked = $frame->{Frame_chk_keys}->SetValue(1);
               Wx::Event::EVT_BUTTON($frame,$frame->{Frame_Button_OK},\&OK);
               Wx::Event::EVT_BUTTON($frame,$frame->{Frame_Cancel},\&Cancel);
               Wx::Event::EVT_BUTTON($frame,$frame->{Frame_Button_Bestand},\&Bestand); 
               $frame->SetSizer($frame->{Frame_Sizer_1});
               $frame->SetBackgroundColour(Wx::Colour->new(239, 243, 255));
               return ($frame);
          }
      sub OK {
           my($frame)= @_;
           my $getkeys_is_checked = $frame->{Frame_chk_keys}->GetValue();
           my $Double_is_checked =  $frame->{Frame_chk_Double}->GetValue();
           my $Delete_is_checked = $frame->{Frame_chk_Delete}->GetValue();
           my $CatalogKey =  $frame->{Frame_Txt_CatalogKey}->GetValue();
           my $FileName =$frame->{Frame_Txt_Bestand}->GetValue();
           my $Enkel_eattest_is_checked =$frame->{Frame_chk_Enkel_eattest}->GetValue();
           my $Begindatum = 19750101;
           my $Einddatum =  19750101;
           my $zf = $frame->{Frame_choice_ZKF}->GetStringSelection();
           $Begindatum = $frame->{Frame_Txt_BD}->GetValue();
           $Einddatum = $frame->{Frame_Txt_ED}->GetValue();
           my $NaamBrief =  $frame->{Frame_Txt_DT}->GetValue();
           my $pagina = 1;
           if ($getkeys_is_checked == 1){
                # ,$type,$extern_nummer,$doctype,$catalogstartdate,$catalogenddate,$pageNumber,$frame,$zf,$inz_nr)
                my ($aantal1,$documenten1) =  webservice->GetCatalogKeys($zf,$NaamBrief,$Begindatum,$Einddatum,$pagina,$frame);
                Frame->maak_bestand($zf,$Begindatum,$Einddatum,$aantal1,$documenten1);
                print "";
            }else {
                if ($Double_is_checked != 1 and $Delete_is_checked != 1) {
                 Wx::MessageBox("Je moet iets aanvinken !", 
                                          _T("Vink iets aan of druk Cancel"), 
                                          wxOK|wxCENTRE, 
                                          $frame
                                         );
                }elsif ($CatalogKey eq '' and $FileName eq '') {
                 Wx::MessageBox("Je moet een Catalog key of Bestand geven  !", 
                                          _T("geef key 203-JJJJ-XXX-XXXXXXXXXX of druk Cancel"), 
                                          wxOK|wxCENTRE, 
                                          $frame
                                         );       
                }elsif ($Double_is_checked == 1 and $Delete_is_checked == 1)  {
                   Wx::MessageBox("Je mag niet alle twee aanvinken !", 
                                          _T("Vink iets af of druk Cancel"), 
                                          wxOK|wxCENTRE, 
                                          $frame
                                         );
                }else {
                  if ($Delete_is_checked == 1 ) {
                     my $response ='';
                     if ($CatalogKey ne '') {
                         $response = webservice->Cataloog_updateStatusForDelete($zf,$CatalogKey);
                          Wx::MessageBox("$response", 
                                          _T("Antwoord van de Cataloog voor Delete"), 
                                          wxOK|wxCENTRE, 
                                          $frame
                                         );
                        }elsif ($FileName ne '') {
                          Frame->verwerk_bestand($frame,$FileName,'delete',$Enkel_eattest_is_checked,$zf);
                        }
                     
                    
                    
                    }
                  if ($Double_is_checked == 1 ) {
                      my $response ='';
                     if ($CatalogKey ne '') {
                         $response = webservice->Cataloog_updateStatusForDouble($zf,$CatalogKey);
                          Wx::MessageBox("$response", 
                                          _T("Antwoord van de Cataloog voor Dubbel"), 
                                          wxOK|wxCENTRE, 
                                          $frame
                                         );
                        }elsif ($FileName ne '') {
                          Frame->verwerk_bestand($frame,$FileName,'double',$Enkel_eattest_is_checked,$zf);
                        }   
                    
                    }
                  
                }
            }
           
        }        
   
      sub Cancel {
               my($frame)= @_;
               die;
          }
      sub Bestand {
         my($frame)= @_;
         my $filedlg = Wx::FileDialog->new(  $frame,         # parent
                                          'Open File',   # Caption
                                          '',            # Default directory
                                          '',            # Default file
                                          "Text (*.txt)|*.tx*", # wildcard
                                          wxFD_OPEN);        # style
             # If the user really selected one
             if ($filedlg->ShowModal==wxID_OK)   {
                 my $filename = $filedlg->GetPath;
                 $frame->{Frame_Txt_Bestand}->SetValue($filename);
                }
        }
      sub verwerk_bestand {
         my ($class,$frame,$bestand,$soort,$Enkel_eattest_is_checked,$zf) = @_   ;
         print "";
         my  $response = "Alles gelukt behalve:\n";
         open(my $fh, '<:encoding(UTF-8)', $bestand)  or &geen_file($frame,$bestand);
         my $teller =0;
         while (my $row = <$fh>) {
              chomp $row;
              if ($teller !=0) {
                      my ($Beschrijving,$Derden,$Creatiedatum,$Gecatalogiseerd,$Afgedruk,$Outputqueue,$Status,$Afdrukwijze,$weetniet,$CatalogKey,$Staat,$Oorsprong) = split /,/,$row;
                      my $basis_stuk_nr;
                      #my ($CatalogKey,$basis_stuk_nr,$ext_nr) = split /,/,$row;
                      my $mag_verwerkt = 1;
                             if ($Enkel_eattest_is_checked == 1) {
                                my $test_nr =substr ($basis_stuk_nr,5,1);
                                #print " $test_nr\n";
                                $mag_verwerkt = 0 if ($test_nr != 6);
                             }
                      my $deel_response = '';
                      # $mag_verwerkt =0;
                      if ($mag_verwerkt == 1) {
                            if ($soort eq 'delete' ) {
                               $deel_response = webservice->Cataloog_updateStatusForDelete($zf,$CatalogKey);#code
                            }
                            if ($soort eq 'double' ) {
                               $deel_response = webservice->Cataloog_updateStatusForDouble($zf,$CatalogKey);#code
                            }
                            
                            $response = $response."$teller->$CatalogKey\n" if ($deel_response ne 'gelukt');
                            $teller +=1;
                        }
                      print "$row\n";
                      
                }
              $teller +=1;
            }
              
           Wx::MessageBox("$response", 
                                          _T("Antwoord van de Cataloog voor $soort"), 
                                          wxOK|wxCENTRE, 
                                          $frame
                                         );
        }
      sub maak_bestand {
        my ($class,$zf,$Begindatum,$Einddatum,$aantal1,$documenten1) = @_;
        my $place_outputfile = $main::instellingen->{'place_output_file'};
        my $file = "$place_outputfile\\$zf\_,$Begindatum\_$Einddatum\_docfiles.txt";
        my $naam_file ="$zf\_,$Begindatum\_$Einddatum\_docfiles.txt";
        unlink $file;
        # ($Beschrijving,$Derden,$Creatiedatum,$Gecatalogiseerd,$Afgedruk,$Outputqueue,$Status,$Afdrukwijze,$weetniet,$CatalogKey,$Staat,$Oorsprong)
        open(my $fh, '>:encoding(UTF-8)', $file) or print "Could not open file $file";
        my $sort_doc;
        eval{foreach my $dockey (keys $documenten1) {}};
        if ($@) {
           Wx::MessageBox( _T("Geen files van deze doctype gevonden tussen $Begindatum en $Einddatum"), 
                                         "Zoeken", 
                                          wxOK|wxCENTRE, 
                                          
                                         ); 
        }else{
            print $fh "achternaam,voornaam,doctype,date in catalog,docid,folder,thirdpartytype,,,dockey\n";
            foreach my $dockey (keys $documenten1) {            
                my $achternaam = $documenten1->{$dockey}->{'AchterNaam'};
                my $voornaam = $documenten1->{$dockey}->{'VoorNaam'};
                my $docid = $documenten1->{$dockey}->{'dcId'};
                my $doctype = $documenten1->{$dockey}->{'doctType'};
                my $folder = $documenten1->{$dockey}->{'folder'};
                my $thirdpartytype = $documenten1->{$dockey}->{'thirdPartyType'};
                my $catdate = substr($documenten1->{$dockey}->{'catdate'},0,10);
                my $docsort = "$achternaam$voornaam$dockey";
                $sort_doc->{$docsort}->{'AchterNaam'}= $achternaam;
                $sort_doc->{$docsort}->{'VoorNaam'} = $voornaam;
                $sort_doc->{$docsort}->{'dcId'} = $docid;
                $sort_doc->{$docsort}->{'docType'}= $doctype;
                $sort_doc->{$docsort}->{'folder'} =  $folder;
                $sort_doc->{$docsort}->{'thirdPartyType'} = $thirdpartytype;
                $sort_doc->{$docsort}->{'dockey'} = $dockey;
                $sort_doc->{$docsort}->{'catdate'} = $catdate;
            }
            foreach my $key (sort keys $sort_doc) {
                my $achternaam = $sort_doc->{$key}->{'AchterNaam'};
                my $voornaam = $sort_doc->{$key}->{'VoorNaam'};
                my $docid = $sort_doc->{$key}->{'dcId'};
                my $doctype = $sort_doc->{$key}->{'docType'};
                my $folder = $sort_doc->{$key}->{'folder'};
                my $thirdpartytype = $sort_doc->{$key}->{'thirdPartyType'};
                my $dockey = $sort_doc->{$key}->{'dockey'};
                my $catdate = $sort_doc->{$key}->{'catdate'};
                print $fh "$achternaam,$voornaam,$doctype,$catdate,$docid,$folder,$thirdpartytype,,, $dockey\n";
            }
            close $fh;
            Wx::MessageBox( _T("$aantal1 files van deze doctype gevonden tussen $Begindatum en $Einddatum. U kan deze vinden in:
                                map: $place_outputfile
                                file: $naam_file"), 
                                         "Zoeken", 
                                          wxOK|wxCENTRE, 
                                          
                                         ); 
        }
        print "";
      }
      sub geen_file {
         my ($frame,$bestand) = @_;
           Wx::MessageBox("Het bestand $bestand bestaat niet!", 
                                          _T("Geef een geldig bestand of druk Cancel"), 
                                          wxOK|wxCENTRE, 
                                          $frame
                                         );
        }