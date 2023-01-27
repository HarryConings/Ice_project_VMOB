#!/usr/bin/perl -w
use strict;
require 'Decryp_Encrypt.pl';
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
#gebruikt enkel PdfToAgressoScanning_settings_new.xml
#Harry Conings beheert voor I.C.E de broncode

package main;
     use strict;
     use DateTime::Format::Strptime;
     use DateTime;
     use Date::Manip::DM5 ;
     use XML::Simple;
     use Wx qw(:everything);
     use Wx::Locale gettext => '_T';
     use PDF::Extract;
     use File::Slurp;
     use File::Copy;
     use File::stat;
     use Win32;
     use Win32::FileOp;
     use File::Find;
     use Win32::File;
     our $teller_ok=0;
     our $teller_nok = 0;
     our $mail_scanning = "OVERZICHT GESCANDE DOCUMENTEN NAAR AGRESSO EN GKD PRODUCTIE\n";
     print "OVERZICHT GESCANDE DOCUMENTEN NAAR AGRESSO EN GKD PRODUCTIE\n";
     our $verwerkte_files ='';
     our $niet_verwerkte_files='';
     $mail_scanning =  $mail_scanning."----------------------------------------------------------------------\n\n";
     print "----------------------------------------------------------------------\n\n";
     our $PdfToAgressoScanning_instellingen = XMLin('P:\OGV\ASSURCARD_TEST\assurcard_settings_xml\agresso_settings_V2.xml');
     my $werkings_mode = $PdfToAgressoScanning_instellingen->{mode};
     $mail_scanning = $mail_scanning."\nMODE $werkings_mode\n";
     print "\nMODE $werkings_mode\n";
     our @bestanden;
     our @mails;
     our $klant;
     our $file;
     our $vandaag = ParseDate("today");
     our $huidig_jaar = substr ($vandaag,0,4);
     our $huidige_maand = substr ($vandaag,4,2);
     our $huidige_dag = substr ($vandaag,6,2);
     our $vandaag_dag = $huidig_jaar*10000+$huidige_maand*100+$huidige_dag;
     our @maanden = ('januari','februari','maart','april','mei','juni','juli','augustus','september','oktober','november','december') ;
     our $jaar;
     our $maandgetal;
     our $maand;
     our $dag;
     
     if ($vandaag=~ m%\d{4}%) {
         $jaar = $&;
         $_=$vandaag;
         s%\d{4}%%;
         if ($_ =~ m%\d{2}%) {
             $_=$&-1;
             $maandgetal = $_;
             $maand = $maanden[$_];
            }
         $_=$vandaag;
          s%\d{6}%%;
         if ($_ =~ m%\d{2}%) {
             $_=$&;
             s/^0//;
             $dag = $_;
             #print ":::$dag\n";
            }
        }
     our $mday=$huidige_dag;
     our $maand_naam = $maand ;
     our $jaar_getal = $huidig_jaar ;
     our $maand_getal = $huidige_maand ;
     my $gebruiker =  main->gebruikersnaam;
     $mail_scanning =  $mail_scanning."\nDit $werkings_mode programma werd gedraaid door $gebruiker\n\n";
     print "\nDit $werkings_mode programma werd gedraaid door $gebruiker\n\n";
     #webservice->agresso_get_customer_info_rr_nr;
     main->lees_dirctory("$PdfToAgressoScanning_instellingen->{Doc_Archief}->{LocatieDocumenten}");
     main->zet_mails_in;
     main->zet_pdf_in;
     
     
     sub lees_dirctory {
         my ($class,$directory) = @_;
         #my @files = <$directory\\*.odt>;
         opendir(DIR,$directory);
         my @files = grep(/\.pdf$/,readdir(DIR));
         
         for my $pdf (@files) {
             if ($pdf  =~ m/\d{11}-.*/) {
                 push (@bestanden,$pdf);
                }
            }
          @files =();
          opendir(DIR,$directory);
          @files = grep(/\.msg$/,readdir(DIR));
          for my $pdf (@files) {
             if ($pdf  =~ m/\d{11}-.*/) {
                 push (@mails,$pdf);
                }
            }
          print '';
        }
     sub zet_mails_in {
         my ($self) = @_;
         print '';         
         foreach my $mail (@mails) {
             $mail  =~ m/\d{11}-/;             
             my $rijksregnr = $&;
             $rijksregnr =~ s/-//g;
             $rijksregnr = $rijksregnr *1;
             $rijksregnr = sprintf ('%011s',$rijksregnr);
             my $antwoord = webservice->agresso_get_customer_info_rr_nr($rijksregnr,$mail);
             my $zkf_nr = $main::klant->{zkf_nr};
             my $mag_weg= 'nee';
             if ($antwoord eq 'ok' and defined $zkf_nr) {
                 $main::klant->{extern_nummer} = as400->extern_nummer($main::klant->{Rijksreg_Nr});
                 $main::file= "$PdfToAgressoScanning_instellingen->{Doc_Archief}->{LocatieDocumenten}\\$mail";
                 $main::klant->{file_encode64} = webservice->convert_base64($main::file);
                 my @gelukt = webservice->PDF_naar_Agresso('mail');
                 print "Agresso $gelukt[0]  $mail\n";
                 print '';
                 if ($gelukt[0] eq 'gelukt') {
                     copy ($main::file  => $PdfToAgressoScanning_instellingen->{Doc_Archief}->{LocatieVerwerkt}) ;
                     print "$main::file  => $PdfToAgressoScanning_instellingen->{Doc_Archief}->{LocatieVerwerkt}\n";
                     unlink $main::file;
                     $teller_ok +=1;
                     $main::verwerkte_files = $main::verwerkte_files."$mail\n";
                     print '';
                 }else {
                      $teller_nok += 1;
                      $main::niet_verwerkte_files = $main::niet_verwerkte_files."$mail\n";
                 }
                 print '';
             }
         }
     }
     sub zet_pdf_in {
          foreach my $pdf (@bestanden) {
             #my $pdf = $main::bestanden[$nr];
             $pdf  =~ m/\d{11}-/;             
             my $rijksregnr = $&;
             $rijksregnr =~ s/-//g;
             $rijksregnr = $rijksregnr *1;
             $rijksregnr = sprintf ('%011s',$rijksregnr);
             my $antwoord = webservice->agresso_get_customer_info_rr_nr($rijksregnr,$pdf);
             my $zkf_nr = $main::klant->{zkf_nr};
             my $mag_weg= 'nee';
             if ($antwoord eq 'ok' and defined $zkf_nr) {
                 $main::klant->{extern_nummer} = as400->extern_nummer($main::klant->{Rijksreg_Nr});
                 $main::file= "$PdfToAgressoScanning_instellingen->{Doc_Archief}->{LocatieDocumenten}\\$pdf";
                 $main::klant->{file_encode64} = webservice->convert_base64($main::file);
                 my @gelukt = webservice->PDF_naar_Agresso;
                 print "Agresso $gelukt[0]  $pdf\n";
                 if ($gelukt[0] eq 'gelukt') {
                    if ($PdfToAgressoScanning_instellingen->{mode} eq 'PROD') {
                         my $filesize = stat("$main::file")->size;
                         #Extract and save, in the current EXtract  all the pages in a pdf document                     
                         if ($filesize > 1000000) {
                             my $dir_extract = $PdfToAgressoScanning_instellingen->{Doc_Archief}->{LocatieExtract};
                             my $pdf_extract =new PDF::Extract( PDFDoc=>"$main::file");
                             my $cachePath = $pdf_extract->setVars( PDFCache =>"$dir_extract");
                             my $cachePath1 = $pdf_extract->getVars("PDFCache");                   
                             my $i=1;
                             $i++ while ( $pdf_extract->savePDFExtract( PDFPages=>"$i" ) );
                             copy ($main::file  => $PdfToAgressoScanning_instellingen->{Doc_Archief}->{LocatieVerwerkt}) or die;
                             $main::verwerkte_files = $main::verwerkte_files."$pdf\n";
                             $teller_ok +=1;
                             unlink $main::file;   
                             print "";
                             opendir(DIRCACHE,$dir_extract);
                             my @files_cache = grep(/\.pdf$/,readdir(DIRCACHE));
                             my @bestanden_cache =();
                             for my $pdf_cache (@files_cache) {
                                 if ($pdf_cache  =~ m/\d{11}-.*/) {
                                     push (@bestanden_cache,$pdf_cache);
                                   }
                                }
                             foreach my $pdf_cache (@bestanden_cache) {
                                  $main::klant->{file_encode64} = '';
                                  $main::file= "$PdfToAgressoScanning_instellingen->{Doc_Archief}->{LocatieExtract}\\$pdf_cache";
                                  $main::klant->{file_encode64} = webservice->convert_base64($main::file);
                                  my @gelukt = webservice->Cataloog_createEventWithWarning;
                                  if ($gelukt[0] eq 'gelukt') {
                                     $main::verwerkte_files = $main::verwerkte_files."\tGKD => $pdf_cache\n";
                                     print "\tGKD => $pdf_cache\n";
                                    }else {
                                      $mail_scanning =  $mail_scanning."\t\tGKD fout : $pdf => $gelukt[1]\n";
                                      print "\t\tGKD fout : $pdf => $gelukt[1]\n";
                                    }
                                  unlink $main::file;
                                  print "";
                                }
                            }else {
                                $main::klant->{file_encode64} = '';                         
                                $main::klant->{file_encode64} = webservice->convert_base64($main::file);
                                my @gelukt = webservice->Cataloog_createEventWithWarning;
                                $main::verwerkte_files = $main::verwerkte_files."$pdf\n";
                                copy ($main::file  => $PdfToAgressoScanning_instellingen->{Doc_Archief}->{LocatieVerwerkt}) or die;
                                $teller_ok +=1;
                                if ($gelukt[0] eq 'gelukt') {
                                   $main::verwerkte_files = $main::verwerkte_files."\tGKD => $pdf\n";
                                   print "\tGKD => $pdf\n";
                                  }else {
                                   $mail_scanning =  $mail_scanning."\t\tGKD fout : $pdf => $gelukt[1]\n";
                                   print "\t\tGKD fout : $pdf => $gelukt[1]\n";
                                  }
                                unlink $main::file;
                                print "";      
                            }                   
                        }else {
                            copy ($main::file  => $PdfToAgressoScanning_instellingen->{Doc_Archief}->{LocatieVerwerkt}) or die;
                            $main::verwerkte_files = $main::verwerkte_files."\tTest enkel agresso => $pdf\n";
                            print "\tTest enkel agresso => $pdf\n";
                            unlink $main::file;
                        }
                    }else {
                      $teller_nok +=1;
                      $mail_scanning =  $mail_scanning."$teller_nok\t: fout $pdf => $gelukt[1]\n";
                      print "$teller_nok\t: fout $pdf => $gelukt[1]\n";
                    }
                }else {
                 $main::niet_verwerkte_files = $main::niet_verwerkte_files."$rijksregnr -> zit niet in Agresso -> $pdf\n";
                }
            }
          $mail_scanning =  $mail_scanning."\nWe Hebben $teller_ok bestanden geimporteerd\n";
          print "\nWe Hebben $teller_ok bestanden geimporteerd\n";
          $mail_scanning =  $mail_scanning."\n\nVriendelijke groeten\nHarry Conings";
          $mail_scanning =  $mail_scanning."\n\nDit programma mag enkel gebruikt worden door de VMOB.\n";
          $mail_scanning =  $mail_scanning."Ben je een oneigelijke gebruiker van dit programma?\n";
          $mail_scanning =  $mail_scanning."neem dan contact op met Harry Conings 32475464289\n";
          $mail_scanning =  $mail_scanning."\n\nVolgende zijn goed gegaan:\n";
          print "Volgende zijn goed gegaan:\n";
          print "$verwerkte_files\n";
          $mail_scanning =  $mail_scanning."$main::verwerkte_files\n";
          $mail_scanning =  $mail_scanning."\n\nVolgende zijn Fout gegaan:\n";
          $mail_scanning =  $mail_scanning."$main::niet_verwerkte_files\n";
          print "\n\nVolgende zijn Fout gegaan:\n";
          print "$main::niet_verwerkte_files\n";
          mail->verslag;
          
        }
     sub gebruikersnaam {  
         my $name;
         $name = Win32::LoginName(); # or whatever function you'd like
         $name = lc($name);
         #print "gebruikersnaam = $name\n";
         return ($name) ;    
        }


package App;     
     use strict;
     use warnings;
     use base 'Wx::App';
     sub OnInit {
         my $frame = Frame->new();
         $frame->Centre();
         #$frame->Maximize( 1 );
         #$frame->SendSizeEvent();
         $frame->Show(1);
        }
     
package Frame;
     use strict;
     use warnings;
     use Wx qw(:everything);
     use base qw(Wx::Frame);
     use Wx::Locale gettext => '_T';
     sub new {
         my($frame) = @_;
         my $y = 90;
         $frame = $frame->SUPER::new(undef, -1,_T("Print of Mail"),
                              [-1,-1],[450,300],wxDEFAULT_FRAME_STYLE );
         return ($frame);
        }
     sub fout_agresso {
          my($frame) = @_;
          Wx::MessageBox(_T("PDF in Agresso zetten is niet gelukt"), 
                                     "Fout", 
                                     wxOK|wxCENTRE, 
                                     $frame
                                    );
          return ($frame);
        }
      
     
package webservice;  
     use SOAP::Lite #;
     +trace => [ transport => sub { print $_[0]->as_string } ];
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
         
         my ($class) = @_;
         my $zkf = $main::klant->{zkf_nr};
         my $file_name = $main::file;
         my $catalog_Key ="";
         my $folderRef_text = $main::file;           
         $folderRef_text =~ m/-\w+\.pdf/i;     
         $folderRef_text = $&;
         $folderRef_text =~ s/-//g;
         $folderRef_text =~ m/\d+\.pdf/;
         my $pagina = $&;
         $pagina =~ s/\.pdf//;
         $folderRef_text =~ s/\d+\.pdf//i;
         $folderRef_text =~ s/\.pdf//i;
         $folderRef_text = uc $folderRef_text;
         my $omschrij = $folderRef_text;
         eval {$omschrij  = $main::PdfToAgressoScanning_instellingen->{Doc_Archief}->{ziekenfondsen}->{"ZKF$zkf"}
               ->{doc_in_naam_mapping}->{$folderRef_text}->{omschrijving}};
         if (!$@) {
             $omschrij = $main::PdfToAgressoScanning_instellingen->{Doc_Archief}->{ziekenfondsen}->{"ZKF$zkf"}
             ->{doc_in_naam_mapping}->{$folderRef_text}->{omschrijving};
             $catalog_Key = $main::PdfToAgressoScanning_instellingen->{Doc_Archief}->{ziekenfondsen}->{"ZKF$zkf"}
             ->{doc_in_naam_mapping}->{$folderRef_text}->{CAT};
             $omschrij = '';
         } 
         if ($catalog_Key eq "") {
             $catalog_Key =$main::PdfToAgressoScanning_instellingen->{Doc_Archief}->{ziekenfondsen}->{"ZKF$zkf"}->{doc_in};
            }elsif ($file_name =~ m/_M_/ and  $catalog_Key eq "") {
             $catalog_Key =$main::PdfToAgressoScanning_instellingen->{Doc_Archief}->{ziekenfondsen}->{"ZKF$zkf"}->{doc_conf_in};
            }     
         my $extern_nummer = $main::klant->{extern_nummer} ;
         $extern_nummer = sprintf("%013s", $extern_nummer );
         my $request = 'createEventWithWarning';
         my $user = $main::PdfToAgressoScanning_instellingen->{Doc_Archief}->{ziekenfondsen}->{"ZKF$zkf"}->{as400_user}; 
         my $domain = "$zkf";
         my $pass = decrypt->new($main::PdfToAgressoScanning_instellingen->{Doc_Archief}->{ziekenfondsen}->{"ZKF$zkf"}->{as400_paswoord});
         #print "\nuser $user $pass \n";
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
         $omschrij =~ s/\_M_//;
         $omschrij = substr($omschrij,0,17);        
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
          my $folderRef  = SOAP::Data->name('folderRef'=> " $omschrij p$pagina")->type('');
          my $thirdCodeType = SOAP::Data->name('thirdCodeType' => "EXID")->type('');
          my $thirdCodeValue = SOAP::Data->name('thirdCodeValue' => "$extern_nummer")->type('');
          my $thirdOrg = SOAP::Data->name('thirdOrg' => "$zkf")->type('');
          my $thirdParType = SOAP::Data->name('ThirdParType' =>"MUTUALITYPERSON")->type('');
          my $imageMimeType = SOAP::Data->name('imageMimeType' => "application/pdf")->type('');
          my $imageName  = SOAP::Data->name('imageName' => "$file_name")->type('');
          my $imageBytes = SOAP::Data->name('imageBytes' => "$main::klant->{file_encode64}")->type('');
          #my $folderType = SOAP::Data->name('folderType' => "Zorgverzekering")->type('');
          #my $folderRef  = SOAP::Data->name('folderRef' => "00NoRefDossier")->type('');
          my $createEventWithWarning = SOAP::Data->name('createEventWithWarning') ->attr({xmlns => "$uri"});
          my $in0 = SOAP::Data->name('in0')
          ->value(\SOAP::Data->value($docType,$folderRef,$thirdCodeType,$thirdCodeValue,
                                     $thirdOrg,$thirdParType,$imageMimeType,$imageName,$imageBytes));
          my $response = $soap->call($createEventWithWarning,$in0);
          print "";
          eval {my $key = $response->{_content}->[2]->[0]->[2]->[0]->[4]->{out}->{key}};
         
          if (!$@) {
             my $key = $response->{_content}->[2]->[0]->[2]->[0]->[4]->{out}->{key};
             return ('gelukt',$key);
          }else {
             return ('mislukt');
          }
          
          
        }    
     sub PDF_naar_Agresso {
         my ($class,$is_mail ) = @_;
         my $clientnummer = $main::klant->{Agresso_nummer};
         my $zkf = $main::klant->{zkf_nr};
         my $file_name = $main::file;
         ##$clientnummer = 67122533419;#;100048 100248 166516
         use SOAP::Lite ;
         my $catalog_Key ="";
         my $folderRef_text = $main::file;           
         $folderRef_text =~ m/-\w+\.pdf/i;     
         $folderRef_text = $&;
         $folderRef_text =~ s/-//g;
         $folderRef_text =~ m/\d+\.pdf/;
         my $pagina = $&;
         $pagina =~ s/\.pdf//;
         $folderRef_text =~ s/\d+\.pdf//i;
         $folderRef_text =~ s/\.pdf//i;
         $folderRef_text = uc $folderRef_text;
         my $omschrij = $folderRef_text;
         eval {$omschrij  = $main::PdfToAgressoScanning_instellingen->{Doc_Archief}->{ziekenfondsen}->{"ZKF$zkf"}
               ->{doc_in_naam_mapping}->{$folderRef_text}->{omschrijving}};
         if (!$@) {
             $omschrij = $main::PdfToAgressoScanning_instellingen->{Doc_Archief}->{ziekenfondsen}->{"ZKF$zkf"}
             ->{doc_in_naam_mapping}->{$folderRef_text}->{omschrijving};
             $catalog_Key = $main::PdfToAgressoScanning_instellingen->{Doc_Archief}->{ziekenfondsen}->{"ZKF$zkf"}
             ->{doc_in_naam_mapping}->{$folderRef_text}->{doc_agresso};
             $omschrij = '';
         } 
         if ($catalog_Key eq "" or !$catalog_Key) {
             $catalog_Key =$main::PdfToAgressoScanning_instellingen->{Doc_Archief}->{DocType};  
            }
         $folderRef_text = $main::file;
         if  ($is_mail eq 'mail') {
             $catalog_Key =$PdfToAgressoScanning_instellingen->{Doc_Archief}->{DocType_MSG};
             $folderRef_text =~ s/-\w+\.msg/\.msg/i if ($folderRef_text =~ m/-\w+\-\w+\.msg/i);
             $folderRef_text =~ m/-\w+\.msg/i;     
             $folderRef_text = $&;
             $folderRef_text =~ s/-//g;
         }else {               
             $folderRef_text =~ s/-\w+\.pdf/\.pdf/i if ($folderRef_text =~ m/-\w+\-\w+\.pdf/i);
             $folderRef_text =~ m/-\w+\.pdf/i;     
             $folderRef_text = $&;
             $folderRef_text =~ s/-//g;
         }         
         my $proxy = "http://$PdfToAgressoScanning_instellingen->{Agresso_IP}/BusinessWorld-webservices/service.svc?CustomerService/Customer";# test
         my $uri   = 'http://services.agresso.com/DocArchiveService/DocArchiveV201101';
         my $soap = SOAP::Lite
             ->proxy($proxy)
             ->ns($uri,'doc')
             ->on_action( sub { return 'AddDocument' } );
         my $DocId  = SOAP::Data->name('doc:DocId'=> 0)->type('');
         my $type = $main::PdfToAgressoScanning_instellingen->{Doc_Archief}->{DocType};
         my $DocType  = SOAP::Data->name('doc:DocType'=> $catalog_Key )->type('');
         my $RevisionNo = SOAP::Data->name('doc:RevisionNo'=> 1)->type('');        
         my $FileName = SOAP::Data->name('doc:FileName'=> "$folderRef_text")->type('');
         $folderRef_text =~ s/\.pdf//i;
         $folderRef_text =~ s/\.msg//i;
         $folderRef_text = uc $folderRef_text;
         my $user = 'SCANNER';       
         my $Comments_data  = $folderRef_text;
         eval {$Comments_data  = $main::PdfToAgressoScanning_instellingen->{Doc_Archief}->{ziekenfondsen}->{"ZKF$zkf"}
               ->{doc_in_naam_mapping}->{$folderRef_text}->{omschrijving}};
         if (!$@) {
             $Comments_data  = $main::PdfToAgressoScanning_instellingen->{Doc_Archief}->{ziekenfondsen}->{"ZKF$zkf"}
             ->{doc_in_naam_mapping}->{$folderRef_text}->{omschrijving};
         } 
         $Comments_data = substr($Comments_data,0,40);
         my $Comments = SOAP::Data->name('doc:Comments'=> "$Comments_data")->type('');
         my $Description = SOAP::Data->name('doc:Description'=> "$user $Comments_data")->type('');
         my $RevisionDate = SOAP::Data->name('doc:RevisionDate'=> "$main::huidig_jaar-$main::huidige_maand-$main::huidige_dag")->type('');
         my $FileContent = SOAP::Data->name('doc:FileContent'=> $main::klant->{file_encode64})->type('');
         my $string1 = SOAP::Data->name('doc:string'=> 'VMOB')->type('');
         my $string2 = SOAP::Data->name('doc:string'=> $main::klant->{Agresso_nummer})->type('');
         my $IndexValues = SOAP::Data->name('doc:IndexValues')->value(\SOAP::Data->value($string1,$string2));
         my $newDocument =  SOAP::Data->name('doc:newDocument')->value(\SOAP::Data->value($DocId,$DocType,$IndexValues,
                        $RevisionNo,$Comments,$RevisionDate,$FileName,$Description,$FileContent));
         my $Username    = SOAP::Data->name('doc:Username' => 'WEBSERV')->type('');
         my $Client      = SOAP::Data->name('doc:Client'   => 'VMOB')->type('');
         my $Password    = SOAP::Data->name('doc:Password' => 'WEBSERV')->type('');
         my $credentials = SOAP::Data->name('doc:credentials') ->value(\SOAP::Data->value($Username, $Client, $Password));
         #my $AddDocument = SOAP::Data->name('doc:AddDocument')->value(\SOAP::Data->value($newDocument,$credentials));
         my $response = $soap->AddDocument($newDocument,$credentials);
         print "";
         my $text = '';
         my $status ='';
         my $link ='';
         eval {$status = $response->{_content}->[2]->[0]->[2]->[0]->[4]->{AddDocumentResult}->{Response}->{Status}};
         if (!$@) {
             $status = $response->{_content}->[2]->[0]->[2]->[0]->[4]->{AddDocumentResult}->{Response}->{Status};
             $text = $response->{_content}->[2]->[0]->[2]->[0]->[4]->{AddDocumentResult}->{Response}->{Text};
             if ($status == 0) {
                 $link = $response->{_content}->[2]->[0]->[2]->[0]->[4]->{AddDocumentResult}->{Properties}->{DocumentProperties} ;
                 eval {my $gelukt = $link->{DocId}};
                 if (!$@) {
                     my $gelukt = $link->{DocId};
                     return ('gelukt',$gelukt);
                    }else {
                     return ('mislukt',$text);
                    }   
             }else {
                 return ('mislukt',$text);
             }
             
            }
         
        
         
           
        }
     sub agresso_get_customer_info_rr_nr {
      use SOAP::Lite ;
      #+trace => [ transport => sub { print $_[0]->as_string } ];
      my ($class,$clientnummer,$pdf) = @_;
      $clientnummer = sprintf("%011s", $clientnummer );
      print "we zoeken $clientnummer voor pdf $pdf in agresso\n";
      #$clientnummer = 67122533419;#;100048 100248 166516
      #use SOAP::Lite ;
      #my $proxy = 'http://10.198.205.8/AgressoWSHost/service.svc';
      #my $uri   = 'http://services.agresso.com/CustomerService/Customer';
      #my $soap = SOAP::Lite
      #      ->proxy($proxy)
      #      ->ns($uri,'cus')
      #      ->on_action( sub { return 'GetCustomers' } );
      #my $company   = SOAP::Data->name('cus:Company'=> 'VMOB')->type('');
      #my $customerId =  SOAP::Data->name('cus:ExternalReference'=> "$clientnummer")->type('');
      #my $customerObject = SOAP::Data->name('cus:customerObject')->value(\SOAP::Data->value($company,$customerId));
      #my $customerDetailsOnly =  SOAP::Data->name('cus:customerDetailsOnly'=> "0")->type('');
      #my $Username    = SOAP::Data->name('cus:Username' => 'WEBSERV')->type('');
      #my $Client      = SOAP::Data->name('cus:Client'   => 'VMOB')->type('');
      #my $Password    = SOAP::Data->name('cus:Password' => 'WEBSERV')->type('');
      #my $credentials = SOAP::Data->name('cus:credentials') ->value(\SOAP::Data->value($Username, $Client, $Password));
      #my $GetCustomer       = SOAP::Data->name('cus:GetCustomer')
      #->value(\SOAP::Data->value($company , $customerId, $customerDetailsOnly ,$credentials ));
      my $proxy = "http://$PdfToAgressoScanning_instellingen->{Agresso_IP}/BusinessWorld-webservices/service.svc"; #productie    
      #my $proxy = 'http://10.198.206.217/AgressoWSHost/service.svc';
      my $uri   = 'http://services.agresso.com/CustomerService/Customer';
      my $soap = SOAP::Lite
            ->proxy($proxy)
            ->ns($uri,'cus')
            ->on_action( sub { return 'GetCustomers' } );
      my $company   = SOAP::Data->name('cus:Company'=> 'VMOB')->type('');
      my $customerId =  SOAP::Data->name('cus:ExternalReference'=> "$clientnummer")->type('');
      my $customerObject = SOAP::Data->name('cus:customerObject')->value(\SOAP::Data->value($company,$customerId));
      my $customerDetailsOnly =  SOAP::Data->name('cus:customerDetailsOnly'=> "0")->type('');
      my $Username    = SOAP::Data->name('cus:Username' => 'WEBSERV')->type('');
      my $Client      = SOAP::Data->name('cus:Client'   => 'VMOB')->type('');
      my $Password    = SOAP::Data->name('cus:Password' => 'WEBSERV')->type('');
      my $credentials = SOAP::Data->name('cus:credentials') ->value(\SOAP::Data->value($Username, $Client, $Password));
      my $response = $soap->GetCustomers($customerObject, $customerDetailsOnly ,$credentials );
      eval {my $returncode =$response->{_content}[2][0][2][0][4]->{GetCustomersResult}->{ReturnCode}};
      print "-> fout $@\n" if($@); 
      if ( $response->{_content}[2][0][2][0][4]->{GetCustomersResult}->{ReturnCode} == 40 and !$@) {         #code  
      
      $main::klant->{Agresso_nummer} = $response->{_content}[2][0][2][0][4]->{GetCustomersResult}->{CustomerTypeList}->{CustomerObject}->{CustomerID};
      #my $test = $response->{_content}[2][0][2][0][4]->{GetCustomersResult}->{CustomerTypeList}->{CustomerObject}->{CustomerName};
      $main::klant->{naam} =$response->{_content}[2][0][2][0][4]->{GetCustomersResult}->{CustomerTypeList}->{CustomerObject}->{CustomerName};
      $main::klant->{Rijksreg_Nr} =$response->{_content}[2][0][2][0][4]->{GetCustomersResult}->{CustomerTypeList}->{CustomerObject}->{ExternalReference};
      $main::klant->{Bankrekening}=$response->{_content}[2][0][2][0][4]->{GetCustomersResult}->{CustomerTypeList}->{CustomerObject}->{BankAccount};
      $main::klant->{IBAN}=$response->{_content}[2][0][2][0][4]->{GetCustomerResult}->{CustomerType}->{IBAN};
      $main::klant->{BIC}=$response->{_content}[2][0][2][0][4]->{GetCustomerResult}->{CustomerType}->{SWIFT};
      $main::klant->{Taal}=$response->{_content}[2][0][2][0][4]->{GetCustomerResult}->{CustomerTypeList}->{CustomerObject}->{Language};
      eval {my $meerdere_adressen = $response->{_content}[2][0][2][0][4]->{GetCustomersResult}->{CustomerTypeList}->{CustomerObject}->{AddressList}->{AddressUnitType}->[0]->{Address}};
      if ($@) {
           $main::klant->{adres}->[0]->{Straat}=$response->{_content}[2][0][2][0][4]->{GetCustomersResult}->{CustomerTypeList}->{CustomerObject}->{AddressList}->{AddressUnitType}->{Address};
           $main::klant->{adres}->[0]->{Stad}=$response->{_content}[2][0][2][0][4]->{GetCustomersResult}->{CustomerTypeList}->{CustomerObject}->{AddressList}->{AddressUnitType}->{Place};
           $main::klant->{adres}->[0]->{Postcode}=$response->{_content}[2][0][2][0][4]->{GetCustomersResult}->{CustomerTypeList}->{CustomerObject}->{AddressList}->{AddressUnitType}->{ZipCode};
           $main::klant->{adres}->[0]->{Telefoon_nr}=$response->{_content}[2][0][2][0][4]->{GetCustomersResult}->{CustomerTypeList}->{CustomerObject}->{AddressList}->{AddressUnitType}->{Telephone1};
           $main::klant->{adres}->[0]->{e_mail}=$response->{_content}[2][0][2][0][4]->{GetCustomersResult}->{CustomerTypeList}->{CustomerObject}->{AddressList}->{AddressUnitType}->{eMail};
           $main::klant->{adres}->[0]->{type}='Domi';
          }else {
           my $adres_teller = 0;
           foreach my $nr (keys $response->{_content}[2][0][2][0][4]->{GetCustomersResult}->{CustomerTypeList}->{CustomerObject}->{AddressList}->{AddressUnitType}) {
                $main::klant->{adres}->[$adres_teller]->{Straat}=$response->{_content}[2][0][2][0][4]->{GetCustomersResult}->{CustomerTypeList}->{CustomerObject}->{AddressList}->{AddressUnitType}->[$nr]->{Address};
                $main::klant->{adres}->[$adres_teller]->{Stad}=$response->{_content}[2][0][2][0][4]->{GetCustomersResult}->{CustomerTypeList}->{CustomerObject}->{AddressList}->{AddressUnitType}->[$nr]->{Place};
                $main::klant->{adres}->[$adres_teller]->{Postcode}=$response->{_content}[2][0][2][0][4]->{GetCustomersResult}->{CustomerTypeList}->{CustomerObject}->{AddressList}->{AddressUnitType}->[$nr]->{ZipCode};
                $main::klant->{adres}->[$adres_teller]->{Telefoon_nr}=$response->{_content}[2][0][2][0][4]->{GetCustomersResult}->{CustomerTypeList}->{CustomerObject}->{AddressList}->{AddressUnitType}->[$nr]->{Telephone1};
                $main::klant->{adres}->[$adres_teller]->{e_mail}=$response->{_content}[2][0][2][0][4]->{GetCustomersResult}->{CustomerTypeList}->{CustomerObject}->{AddressList}->{AddressUnitType}->[$nr]->{eMail};
                my $adres_type =$response->{_content}[2][0][2][0][4]->{GetCustomersResult}->{CustomerTypeList}->{CustomerObject}->{AddressList}->{AddressUnitType}->[$nr]->{AddressType};
                if ($adres_type == 1) {
                     $main::klant->{adres}->[$adres_teller]->{type}='Domi';
                    }else {
                     $main::klant->{adres}->[$adres_teller]->{type}='Post';
                    }
                
                $adres_teller += 1;
               }
          }
      
      
      #we gaan de verzekeringen opzoeken
      my $link =$response->{_content}[2][0][2][0][4]->{GetCustomersResult}->{CustomerTypeList}->{CustomerObject}->{FlexiGroupList}->{FlexiGroupUnitType};
      my  $cop= $main::klant;
      foreach my $nr     (keys $link){
           if ($link->[$nr]->{FlexiGroup} eq 'VMOBCONTRACT') { # dit zijn de contracten
                my $contract_teller=0;
                eval {my $testeval = $link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->[0]->{FlexiFieldList} };
                if ($@) {
                     foreach my $nr_nr_nr (keys $link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->{FlexiFieldList}->{FlexiFieldUnitType}) {
                          if ($link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{ColumnName} eq 'product') {
                               $main::klant->{contracten}->[$contract_teller]->{naam}=$link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{Value};                              
                              }
                          if ($link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{ColumnName} eq 'startdatum') {                              
                               $link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{Value} =~ m%\d+/\d+/\d{4}% ;
                               $main::klant->{contracten}->[$contract_teller]->{startdatum} = $&;
                              }
                          if ($link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{ColumnName} eq 'wachtdatum') {                              
                               $link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{Value} =~ m%\d+/\d+/\d{4}%;
                               $main::klant->{contracten}->[$contract_teller]->{wachtdatum} = $&;
                              }
                          if ($link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{ColumnName} eq 'einddatum') {                              
                               $link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{Value} =~ m%\d+/\d+/\d{4}%;
                               $main::klant->{contracten}->[$contract_teller]->{einddatum} = $&;
                              }
                          if ($link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{ColumnName} eq 'contract_nr') {                              
                               $link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{Value} =~ m%\d+%;
                               $main::klant->{contracten}->[$contract_teller]->{contract_nr} = $&;
                              }
                          if ($link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{ColumnName} eq 'zkf_nr') {                              
                               $link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{Value} =~ m%\d+%;
                               $main::klant->{contracten}->[$contract_teller]->{zkf_nr} = $&;
                              }
                         }
                         
                }else {
                     foreach my $nr_nr (keys $link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}) {
                          #undef $contract;
                          foreach my $nr_nr_nr (keys $link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->[$nr_nr]->{FlexiFieldList}->{FlexiFieldUnitType}) {
                                if ($link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->[$nr_nr]->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{ColumnName} eq 'product') {
                                     $main::klant->{contracten}->[$contract_teller]->{naam}=$link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->[$nr_nr]->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{Value};                              
                                   }
                                if ($link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->[$nr_nr]->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{ColumnName} eq 'startdatum') {                              
                                    $link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->[$nr_nr]->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{Value} =~ m%\d+/\d+/\d{4}% ;
                                    $main::klant->{contracten}->[$contract_teller]->{startdatum} = $&;
                                   }
                                if ($link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->[$nr_nr]->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{ColumnName} eq 'wachtdatum') {                              
                                    $link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->[$nr_nr]->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{Value} =~ m%\d+/\d+/\d{4}%;
                                    $main::klant->{contracten}->[$contract_teller]->{wachtdatum} = $&;
                                   }
                                if ($link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->[$nr_nr]->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{ColumnName} eq 'einddatum') {                              
                                    $link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->[$nr_nr]->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{Value} =~ m%\d+/\d+/\d{4}%;
                                    $main::klant->{contracten}->[$contract_teller]->{einddatum} = $&;
                                   }
                               if ($link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->[$nr_nr]->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{ColumnName} eq 'contract_nr') {                              
                                    $link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->[$nr_nr]->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{Value} =~ m%\d+%;
                                    $main::klant->{contracten}->[$contract_teller]->{contract_nr} = $&;
                                   }
                               if ($link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->[$nr_nr]->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{ColumnName} eq 'zkf_nr') {                              
                                    $link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->[$nr_nr]->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{Value} =~ m%\d+%;
                                    $main::klant->{contracten}->[$contract_teller]->{zkf_nr} = $&;
                                   }
                              }
                          $contract_teller +=1;        
                          print;
                         }
                    }
               }
           if ($link->[$nr]->{FlexiGroup} eq 'VMOBZIEKTEN') { #dit zijn de ziekten
                my $ziekten_teller =0; ;
                eval {my $testeval = $link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->[0]->{FlexiFieldList} };
                if ($@) {
                     foreach my $nr_nr_nr (keys $link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->{FlexiFieldList}->{FlexiFieldUnitType}) {
                          if ($link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{ColumnName} eq 'product') {
                               $main::klant->{ziekten}->[$ziekten_teller]->{verzekering}=$link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{Value};                              
                              }
                          if ($link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{ColumnName} eq 'ziekte') {
                               $main::klant->{ziekten}->[$ziekten_teller]->{ziekte}=$link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{Value};                              
                              }
                         }
                    }else {
                     foreach my $nr_nr (keys $link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}) {
                          foreach my $nr_nr_nr (keys $link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->[$nr_nr]->{FlexiFieldList}->{FlexiFieldUnitType}) {
                               if ($link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->[$nr_nr]->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{ColumnName} eq 'product') {
                                    $main::klant->{ziekten}->[$ziekten_teller]->{verzekering}=$link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->[$nr_nr]->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{Value};                              
                                   }
                               if ($link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->[$nr_nr]->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{ColumnName} eq 'ziekte') {
                                    $main::klant->{ziekten}->[$ziekten_teller]->{ziekte}=$link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->[$nr_nr]->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{Value};                              
                                   }
                              }
                          $ziekten_teller +=1;       
                         }
                    }
                
               }
           if ($link->[$nr]->{FlexiGroup} eq 'VMOBAANDOEN') { #dit zijn de ziekten
                my $aandoeningen_teller = 0 ;
                eval {my $testeval = $link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->[0]->{FlexiFieldList} };
                if ($@) {
                     foreach my $nr_nr_nr (keys $link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->{FlexiFieldList}->{FlexiFieldUnitType}) {
                          if ($link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{ColumnName} eq 'aandoening') {
                               $main::klant->{aandoeningen}->[$aandoeningen_teller]->{aandoening}=$link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{Value};                              
                              }
                          if ($link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{ColumnName} eq 'begindatum') {
                               $link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{Value}=~ m%\d+/\d+/\d{4}%;
                               $main::klant->{aandoeningen}->[$aandoeningen_teller]->{begindatum}=$&;
                              }
                          if ($link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{ColumnName} eq 'einddatum') {
                               $link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{Value}=~ m%\d+/\d+/\d{4}%;
                               $main::klant->{aandoeningen}->[$aandoeningen_teller]->{einddatum}=$&;
                              }
                          if ($link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{ColumnName} eq 'product') {
                               $main::klant->{aandoeningen}->[$aandoeningen_teller]->{verzekering}=$link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{Value};                              
                              }
                         }
                    }else{
                     foreach my $nr_nr (keys $link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}) {
                          foreach my $nr_nr_nr (keys $link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->[$nr_nr]->{FlexiFieldList}->{FlexiFieldUnitType}) {
                               if ($link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->[$nr_nr]->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{ColumnName} eq 'aandoening') {
                                    $main::klant->{aandoeningen}->[$aandoeningen_teller]->{aandoening}=$link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->[$nr_nr]->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{Value};                              
                                   }
                               if ($link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->[$nr_nr]->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{ColumnName} eq 'begindatum') {
                                    $link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->[$nr_nr]->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{Value}=~ m%\d+/\d+/\d{4}%;
                                    $main::klant->{aandoeningen}->[$aandoeningen_teller]->{begindatum}=$&;
                                   }
                               if ($link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->[$nr_nr]->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{ColumnName} eq 'einddatum') {
                                    $link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->[$nr_nr]->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{Value}=~ m%\d+/\d+/\d{4}%;
                                    $main::klant->{aandoeningen}->[$aandoeningen_teller]->{einddatum}=$&;
                                    }
                               if ($link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->[$nr_nr]->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{ColumnName} eq 'product') {
                                    $main::klant->{aandoeningen}->[$aandoeningen_teller]->{verzekering}=$link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->[$nr_nr]->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{Value};                              
                                    }
                              }
                          $aandoeningen_teller += 1 ;
                         }
                    }
                
               }
           if ($link->[$nr]->{FlexiGroup} eq 'VMOBALG1') { #geboortedatum
                  eval {if ($link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->{FlexiFieldList}->{FlexiFieldUnitType}->{ColumnName} eq 'geboortedatum') {}};
                   if (!$@) {
                      if ($link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->{FlexiFieldList}->{FlexiFieldUnitType}->{ColumnName} eq 'geboortedatum') {
                          $link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->{FlexiFieldList}->{FlexiFieldUnitType}->{Value} =~ m%\d+/\d+/\d{4}%;
                          $main::klant->{geboortedatum} = $&;
                          my $test = $&;
                        }
                   }else {
                      foreach my $key (sort keys $link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->{FlexiFieldList}->{FlexiFieldUnitType}) {
                          if ($link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->{FlexiFieldList}->{FlexiFieldUnitType}->[$key]->{ColumnName} eq 'geboortedatum') {
                              $link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->{FlexiFieldList}->{FlexiFieldUnitType}->[$key]->{Value} =~ m%\d+/\d+/\d{4}%;
                              $main::klant->{geboortedatum} = $&;
                              my $test = $&;
                              print ""; 
                             }
                          if ($link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->{FlexiFieldList}->{FlexiFieldUnitType}->[$key]->{ColumnName} eq 'aantal_kaarten_fx') {
                               $main::klant->{aantal_kaarten} =$link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->{FlexiFieldList}->{FlexiFieldUnitType}->[$key]->{Value};
                               
                              }
                        }
                   }                  
            }
           if ($link->[$nr]->{FlexiGroup} eq 'VMOBTLN') { #ten laste name en commentaar
                eval {my $testeval = $link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->[0]->{FlexiFieldList} };
                if ($@) {
                     foreach my $nr_nr_nr (keys $link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->{FlexiFieldList}->{FlexiFieldUnitType}) {
                          if ($link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{ColumnName} eq 'ten_laste_name') {
                               $main::klant->{ten_laste_name}->{ja_nee}=$link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{Value};                              
                              }
                          if ($link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{ColumnName} eq 'commentaar') {
                               $main::klant->{ten_laste_name}->{commentaar}=$link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{Value};                              
                              }
                         }
                    }else {
                     
                    }
               }
          }
      my $aantal_lijnen = &sorteer_contracten;
      for (my $i = 0; $i < $aantal_lijnen; $i++) {
           &sorteer_contracten;
          }
      return ("ok");
      }else {
           return ("nok");
      }
      print"";
      #$main::klant->{Agresso_nummer}
      #$main::klant->{Bankrekening}
      #$main::klant->{naam}
      #$main::klant->{Rijksreg_Nr}
      #$main::klant->{geboortedatum}
      #$main::klant->{adres}->[0..]->{e_mail}
      #$main::klant->{adres}->[0..]->{Postcode}
      #$main::klant->{adres}->[0..]->{Stad}
      #$main::klant->{adres}->[0..]->{Straat}
      #$main::klant->{adres}->[0..]->{Telefoon_nr}
      #$main::klant->{adres}->[0..]->{Type}
      #$main::klant->{contracten}->[0]->{contract_nr}
      #$main::klant->{contracten}->[0]->{einddatum}
      #$main::klant->{contracten}->[0]->{naam}
      #$main::klant->{contracten}->[0]->{startdatum}
      #$main::klant->{contracten}->[0]->{wachtdatum}
      #$main::klant->{contracten}->[0]->{zkf_nr}
      #$main::klant->{ten_laste_name}->{commentaar}
      #$main::klant->{ten_laste_name}->{ja_nee}
      #$main::klant->{ziekten}->[0..]->{verzekering}
      #$main::klant->{ziekten}->[0..]->{ziekte}
      #$main::klant->{aandoeningen}->[0..]->{aandoening}
      #$main::klant->{aandoeningen}->[0..]->{begindatum}
      #$main::klant->{aandoeningen}->[0..]->{einddatum}
      #$main::klant->{aandoeningen}->[0..]->{verzekering}
      
     }
     
     sub sorteer_contracten {
      my $startdatum_oud;
      my $einddatum_oud;
      my $teller = 0;
      #my $test = $main::klant->{contracten};
      eval { foreach my $nr (sort keys $main::klant->{contracten}) {}};
      if (!$@) { 
      foreach my $nr (sort keys $main::klant->{contracten}) {
           if ($teller == 0) {
                my $startdatum = $main::klant->{contracten}->[$nr]->{startdatum};
                my ($startdag,$startmaand,$startjaar) = split (/\//,$startdatum);
                my $einddatum = $main::klant->{contracten}->[$nr]->{einddatum};
                my ($einddag,$eindmaand,$eindjaar) = split (/\//,$einddatum);
                $startdatum = $startjaar*10000+$startmaand*100+$startdag;
                $einddatum = $eindjaar*10000+$eindmaand*100+$einddag;
                $startdatum_oud = $startdatum;
                $einddatum_oud = $einddatum ;
                $teller +=1;
               }else {
                my $startdatum = $main::klant->{contracten}->[$nr]->{startdatum};
                my ($startdag,$startmaand,$startjaar) = split (/\//,$startdatum);
                my $einddatum = $main::klant->{contracten}->[$nr]->{einddatum};
                my ($einddag,$eindmaand,$eindjaar) = split (/\//,$einddatum);
                $startdatum = $startjaar*10000+$startmaand*100+$startdag;
                $einddatum = $eindjaar*10000+$eindmaand*100+$einddag;
                if ($einddatum > $einddatum_oud) {
                     my $cache = $main::klant->{contracten}->[$nr-1];
                     $main::klant->{contracten}->[$nr-1] = $main::klant->{contracten}->[$nr];
                     $main::klant->{contracten}->[$nr] = $cache;
                    }else {
                     $startdatum_oud = $startdatum;
                     $einddatum_oud = $einddatum ;  
                    }
                $teller +=1;
                
               }
          }
      
      $main::klant->{zkf_nr}= $main::klant->{contracten}->[0]->{zkf_nr};
      }
      return ($teller);
    }




package as400;
     
     use DBD::ODBC;
     use DBI;
     use MIME::Base64;
     sub extern_nummer {
         my ($class,$natnummer) = @_; # tzst
         my $zkf_nr = $main::klant->{zkf_nr};
         $natnummer = $main::klant->{Rijksreg_Nr};
         my $lib= $main::PdfToAgressoScanning_instellingen->{Doc_Archief}->{ziekenfondsen}->{"ZKF$zkf_nr"}->{as400_library};
         my $pers_fil = "$lib\.PFYSL8";
         my $dbh = as400->cnnectdb;
         ##openen van PFYSL8
         ## EXIDL8 = extern nummer
         ## KNRNL8 = nationaalt register nummer
         ## NAMBL8 = naam van de gerechtigde
         ## PRNBL8 = voornaam van de gerechtigde
         ## SEXEL8 = code van het geslacht $naamrij[4]
         ## NAIYL8 = geboortejaat
         ## NAIML8 = geboortemaand
         ## NAIJL8 = geboortedag
         ## LANGL8 = taal code $naamrij[9]
         #print "SELECT EXIDL8,KNRNL8,NAMBL8,PRNBL8,SEXEL8,NAIYL8,NAIML8,NAIJL8,KVPSL8,LANGL8 FROM $pers_fil WHERE KNRNL8=$natnummer\n";
         my @naamrij = $dbh->selectrow_array("SELECT EXIDL8,KNRNL8,NAMBL8,PRNBL8,SEXEL8,NAIYL8,NAIML8,NAIJL8,KVPSL8,LANGL8 FROM $pers_fil WHERE KNRNL8=$natnummer");
         &dscnnectdb ($dbh);
         return ($naamrij[0]);
        }
     sub cnnectdb {
         use strict;
         use DBD::ODBC;
         use DBI;
         my $zkf_nr = $main::klant->{zkf_nr};
         my $user_name= $main::PdfToAgressoScanning_instellingen->{Doc_Archief}->{ziekenfondsen}->{"ZKF$zkf_nr"}->{as400_user};     	     #username as400
         my $password=decrypt->new($main::PdfToAgressoScanning_instellingen->{Doc_Archief}->{ziekenfondsen}->{"ZKF$zkf_nr"}->{as400_paswoord});              #paswoord
         my $as400= $main::PdfToAgressoScanning_instellingen->{Doc_Archief}->{ziekenfondsen}->{"ZKF$zkf_nr"}->{name_as400};                 #naam as400
         my $DSN="driver={iSeries Access ODBC Driver};System=$as400";
         # connect to database
         #
         my $dbh = DBI->connect("dbi:ODBC:$DSN",$user_name,$password) or &wrong_password($user_name);
         #
         #  dbh->disconnect;
         return ($dbh)
        }
     sub dscnnectdb {
         my $dbh = shift @_;
         $dbh->disconnect;
        } 
     sub wrong_password {
         my $user_name = @_;
         $mail_scanning =  $mail_scanning."FOUT PASSWOORD VOOR $user_name PAS PASWOORD FILE AAN IN SETTINGS\n";
         $mail_scanning =  $mail_scanning."------------------------------------------------------------------\n\n";
         print "FOUT PASSWOORD VOOR $user_name PAS PASWOORD FILE AAN IN SETTINGS\n";
         print "------------------------------------------------------------------\n\n";
         mail->verslag;
         die;
        }


package mail;
    
     use Date::Manip::DM5 ;
     use Net::SMTP;
     use Date::Calc qw(:all);
     sub verslag {
         #print "mail-start\n";
         my $aan = $main::PdfToAgressoScanning_instellingen->{mail_verslag_naar};
         my @aan_lijst = split (/\,/,$aan);
         my $van = 'harry.conings@vnz.be';
         my $vandaag = ParseDate("today");
         $vandaag = substr ($vandaag,0,8);  # vandaag in YYYYMMDD
         $vandaag = sprintf "%04d-%02d-%02d",substr ($vandaag,0,4),substr ($vandaag,4,2),substr ($vandaag,6,2);
         foreach my $geadresseerde (@aan_lijst) {
             my $smtp = Net::SMTP->new('10.63.120.3',
                     Hello => 'mail.vnz.be',
                     Timeout => 60);
                     $smtp->auth('mailprogrammas','pleintje203');
                     $smtp->mail($van);
                     $smtp->to($geadresseerde);
                     $smtp->cc('informatica.mail@vnz.be');
                     #$smtp->bcc("bar@blah.net");
                     $smtp->data;
                     $smtp->datasend("From: harry.conings");
                     $smtp->datasend("\n");
                     $smtp->datasend("To: Kaartbeheerders");
                     $smtp->datasend("\n");
                     $smtp->datasend("Subject: importeren van gescande documenten $vandaag");
                     $smtp->datasend("\n");
                     $smtp->datasend("$main::mail_scanning\nvriendelijke groeten\nHarry Conings");
                     $smtp->dataend;
                     $smtp->quit;
                     print "mail aan $geadresseerde  gezonden\n";
            }
        }

1;