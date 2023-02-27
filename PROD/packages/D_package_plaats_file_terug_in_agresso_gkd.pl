#!/usr/bin/perl -w
use strict;
package main;
     require "package_cnnectdb_prod.pl";
     require "package_settings_prod.pl";
     our $klant;
     verwerk_files->new;
package verwerk_files;
     use Cwd;
     use File::Copy;
     use File::Basename;
     use Win32::FileOp;
     use File::Find;
     use Win32::File;
     use Net::SMTP;
     use Date::Calc qw(Delta_Days);
     use XML::Simple;
     our $agresso_instellingen;
     our $brieven_instellingen;
     our $PdfToAgresso_instellingen;
     our @lock_files;
     our $gkd_soorten_brieven; #welke brieven gaan naar welke directory 
     my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);
     my $today_year = $year+1900;
     my $today_month = $mon+1;
     my $today_day=$mday;
     sub new {
         verwerk_files->load_agresso_setting('P:\OGV\ASSURCARD_PROG\assurcard_settings_xml\zet_klant_in_agresso_settings.xml');
         verwerk_files->load_brieven_setting('P:\OGV\ASSURCARD_PROG\assurcard_settings_xml\zet_klant_in_brieven_settings.xml');
         verwerk_files->load_PdfToAgresso_instellingen('P:\OGV\ASSURCARD_PROG\assurcard_settings_xml\zet_klant_in_PdfToAgresso_settings.xml');
         verwerk_files->load_PdfToAgressoScanning_settings('P:\OGV\ASSURCARD_PROG\assurcard_settings_xml\zet_klant_in_PdfToAgressoScanning_settings.xml');
         &search_Map;
         print "";
         
     }
     
     sub load_agresso_setting  {
         my ($class,$file_name) =  @_;
          print "$file_name";
         $agresso_instellingen = XMLin("$file_name");
          print "->ingelezen\n";
          #foreach my $zkf_inst (keys $agresso_instellingen->{verzekeringen}) {
          #   #my $verz_inst =$agresso_instellingen->{verzekeringen}->{$zkf_inst};
          #   foreach my $verz_inst  (sort keys $agresso_instellingen->{verzekeringen}->{$zkf_inst}) {
          #       if (uc $verz_inst ~~ @main::verzekeringen_in_xml) {
          #           #doe niets#code
          #          }else {
          #           push (@verzekeringen_in_xml_org,uc $verz_inst);
          #          }
          #      }
          #  }
        }
     sub load_brieven_setting  {
         my ($class,$file_name) =  @_;
          print "$file_name";
         $brieven_instellingen = XMLin("$file_name");
          print "->ingelezen\n";
          #foreach my $zkf_inst (keys $agresso_instellingen->{verzekeringen}) {
          #   #my $verz_inst =$agresso_instellingen->{verzekeringen}->{$zkf_inst};
          #   foreach my $verz_inst  (sort keys $agresso_instellingen->{verzekeringen}->{$zkf_inst}) {
          #       if (uc $verz_inst ~~ @main::verzekeringen_in_xml) {
          #           #doe niets#code
          #          }else {
          #           push (@verzekeringen_in_xml_org,uc $verz_inst);
          #          }
          #      }
          #  }
        }
     sub load_PdfToAgresso_instellingen  {
         my ($class,$file_name) =  @_;
         print "$file_name";
         $PdfToAgresso_instellingen = XMLin("$file_name");
          print "->ingelezen\n";
          #foreach my $zkf_inst (keys $agresso_instellingen->{verzekeringen}) {
          #   #my $verz_inst =$agresso_instellingen->{verzekeringen}->{$zkf_inst};
          #   foreach my $verz_inst  (sort keys $agresso_instellingen->{verzekeringen}->{$zkf_inst}) {
          #       if (uc $verz_inst ~~ @main::verzekeringen_in_xml) {
          #           #doe niets#code
          #          }else {
          #           push (@verzekeringen_in_xml_org,uc $verz_inst);
          #          }
          #      }
          #  }
        }
     sub load_PdfToAgressoScanning_settings {
         my ($class,$file_name) =  @_;
         print "$file_name";
         $gkd_soorten_brieven = XMLin("$file_name");
         print "->ingelezen\n";;
     }
     sub search_Map {
         my $directory = $agresso_instellingen->{plaats_files_gkd_agresso};
         #my @files = <$directory\\*.odt>;
         opendir(DIR,$directory);
         my @files = grep(/\.odt$/,readdir(DIR));
         opendir(DIR,$directory);
         my @files1 = grep(/\.pdf$/,readdir(DIR));
         for my $pdf (@files1) {
             push (@files,$pdf);
            }
         #hidden files       
         &find(\&wanted,$agresso_instellingen->{plaats_files_gkd_agresso});
         #alle hiddeen files zitten in lock_files
         my $days =0;
         my $lock_files;
         foreach my $loc (@verwerk_files::lock_files) {
             $days =0;
             $loc =~ s/#//;
             if ($loc =~ m/\.odt$/) {
                    $loc =~ m/\.\d{1,2}-\d{1,2}-\d{4}/;
                    my $lockdate = $&;
                    $lockdate  =~ m/\d{4}/;
                    my $lockyear = $&;
                    $lockdate  =~ m/\.\d{1,2}/;
                    my $lockday  = $&;
                    $lockday  =~ s/\.//g;
                    $lockdate  =~ m/-\d{1,2}-/;
                    my $lockmonth = $&;
                    $lockmonth  =~ s/-//g;
                    my($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);
                    my $today_year = $year+1900;
                    my $today_month = $mon+1;
                    my $today_day=$mday;
                    #print "Delta_Days($lockyear,$lockmonth,$lockday,$today_year,$today_month,$today_day)\n";
                    my $days = Delta_Days($lockyear,$lockmonth,$lockday,$today_year,$today_month,$today_day);
                    if ($days > 2 ){
                           print "unlink $directory\\$_";
                           unlink "$directory\\$_";
                       }else {
                           $lock_files = $loc;
                       } 
                   }
                }
             my @files_sorted = sort { lc($b) cmp lc($a) } @files;
             my $teller_files = 0;
             foreach my $files_cache (@files_sorted) {
                 print "nr: $teller_files -- $files_cache\n ";
                 #als er een lock is niets doen
                 my $file_naam = basename($files_cache);
                 my $er_is_een_lock = 0;
                 foreach my $lock_file_name (@verwerk_files::lock_files) {
                     $er_is_een_lock = 1 if ($lock_file_name =~ m/$file_naam/ );
                    }
                 my $error_copy_file = 0;
                 if ($er_is_een_lock == 0) {  # geen lock
                     if ($files_cache =~ m/_nops./){
                         #deletene niet opslaan
                         Delete "$agresso_instellingen->{plaats_files_gkd_agresso}\\$files_cache";
                         print "weggeveegd $files_cache\n"; 
                        }elsif ($files_cache =~ m/.HOSP_|.HOSP-|.HOSPI-|.HOSPI_/) {
                         #&copyfiles ("$agresso_instellingen->{plaats_files_gkd_agresso}\\$files_cache",$agresso_instellingen->{plaats_brieven});
                         $files_cache =~ m/\d{6}-\d{3}-\d{2}/;
                         my $inz_nr_spatie =$&;
                         zoek_agresso_nr->new($inz_nr_spatie);
                         maak_pdf->new($files_cache);                     
                         if ($files_cache =~ m/_her\d\./) {
                             $files_cache =~ m/_her\d\./;
                             my $weken = $&;
                             $weken =~ s/_her//g;
                             my $dagen_eerste_herinnering = $weken*7;
                             my $dagen_tweede_herinnering = $agresso_instellingen->{dagen_tweede_herinnering};
                             my $dagen_nagging = $agresso_instellingen->{dagen_nagging_herrinering};
                             my $dbh = sql_toegang_agresso->setup_mssql_connectie();
                             my $sjabloon= "$agresso_instellingen->{plaats_brieven}\\$files_cache";
                             #sql_toegang_agresso->afxvmobtoremind_insert_row($dbh,$main::klant->{Agresso_nummer},$sjabloon,''
                             #                                             ,$dagen_eerste_herinnering,$dagen_tweede_herinnering,
                             #                                                                   $dagen_nagging);
                            }
                         Delete "$agresso_instellingen->{plaats_files_gkd_agresso}\\$files_cache" ;#if ($error_copy_file == 0);
                        } 
                    }else {
                     print "hier zit een lock op $file_naam\n";
                    }
                 $teller_files +=1;
                }
            }
     sub copyfiles {
         my $lijstfile = shift @_;
         my $copy_plaats = shift @_;
         print "copy $lijstfile -> $copy_plaats \n";
         copy ($lijstfile  => $copy_plaats) or &error_mail_copy ($lijstfile); 
        }
     sub wanted{
         my $attr;        
         -f $_ && 
          # attr will be populated by Win32::File::GetAttributes function
          (Win32::File::GetAttributes($_,$attr)) &&      
          ($attr & HIDDEN) &&
          push (@verwerk_files::lock_files,$_);
          # push (@test,"$File::Find::name"); #volledige filename
       
        }
     sub error_mail {
        my $file_error = shift @_;
        my $aan = $agresso_instellingen->{mail_verslag_naar};
        my @aan_lijst = split (/\,/,$aan);
        my $van = 'harry.conings@vnz.be';
        my $vandaag = ParseDate("today");
        $vandaag = substr ($vandaag,0,8);  # vandaag in YYYYMMDD
        $vandaag = sprintf "%04d-%02d-%02d",substr ($vandaag,0,4),substr ($vandaag,4,2),substr ($vandaag,6,2);
        my $lokale_plaats = $agresso_instellingen->{plaats_brieven_cache};
        my $mail_error="ik kan volgende file\n$file_error \nuit $lokale_plaats\nniet rangeren  \nwaarschijnlijk een foute benaming van het sjabloon\n";
        foreach my $geadresseerde (@aan_lijst) {
            my $smtp = Net::SMTP->new('mailservices.m-team.be',
                       Hello => 'mail.vnz.be',
                       Timeout => 60);
            #$smtp->auth('mailprogrammas','pleintje203');
            $smtp->mail($van);
            $smtp->to($geadresseerde);
            $smtp->cc('informatica.mail@vnz.be');
            #$smtp->bcc("bar@blah.net");
            $smtp->data;
            $smtp->datasend("From: harry.conings");
            $smtp->datasend("\n");
            $smtp->datasend("To: Kaartbeheerders");
            $smtp->datasend("\n");
            $smtp->datasend("Subject: plaats files terug in gkd $vandaag");
            $smtp->datasend("\n");
            $smtp->datasend("$mail_error\nvriendelijke groeten\nHarry Conings");
            $smtp->dataend;
            $smtp->quit;
            print "mail aan $geadresseerde  gezonden\n";
           }
       }
     sub error_mail_copy {
        my $file_error = shift @_;
        my $aan = $agresso_instellingen->{mail_verslag_naar};
        my @aan_lijst = split (/\,/,$aan);
        my $van = 'harry.conings@vnz.be';
        my $vandaag = ParseDate("today");
        $vandaag = substr ($vandaag,0,8);  # vandaag in YYYYMMDD
        $vandaag = sprintf "%04d-%02d-%02d",substr ($vandaag,0,4),substr ($vandaag,4,2),substr ($vandaag,6,2);
        my $lokale_plaats = $agresso_instellingen->{plaats_brieven_cache};
        my $mail_error="ik kan volgende file\n$file_error \nuit $lokale_plaats\nniet copieren \nwaarschijnlijk bestaat die file al\nof is de connectie uitgevallen\n";
        foreach my $geadresseerde (@aan_lijst) {
            my $smtp = Net::SMTP->new('mailservices.m-team.be',
                       Hello => 'mail.vnz.be',
                       Timeout => 60);
            #$smtp->auth('mailprogrammas','pleintje203');
            $smtp->mail($van);
            $smtp->to($geadresseerde);
            $smtp->cc('informatica.mail@vnz.be');
            #$smtp->bcc("bar@blah.net");
            $smtp->data;
            $smtp->datasend("From: harry.conings");
            $smtp->datasend("\n");
            $smtp->datasend("To: Kaartbeheerders");
            $smtp->datasend("\n");
            $smtp->datasend("Subject: Agresso bestaande aandoeningen inzetten $vandaag");
            $smtp->datasend("\n");
            $smtp->datasend("$mail_error\nvriendelijke groeten\nHarry Conings");
            $smtp->dataend;
            $smtp->quit;
            print "mail aan $geadresseerde  gezonden\n";
           }
       }
     sub mail_verwerkt {
        my $file_s = shift @_;
        my $aan = $agresso_instellingen->{mail_verslag_naar};
        my @aan_lijst = split (/\,/,$aan);
        my $van = 'harry.conings@vnz.be';
        my $vandaag = ParseDate("today");
        $vandaag = substr ($vandaag,0,8);  # vandaag in YYYYMMDD
        $vandaag = sprintf "%04d-%02d-%02d",substr ($vandaag,0,4),substr ($vandaag,4,2),substr ($vandaag,6,2);
        my $lokale_plaats = $agresso_instellingen->{plaats_brieven_cache};
        my $mail_error="volgende files werden verwerkt:\n$file_s \n";
        foreach my $geadresseerde (@aan_lijst) {
            my $smtp = Net::SMTP->new('mailservices.m-team.be',
                       Hello => 'mail.vnz.be',
                       Timeout => 60);
            #$smtp->auth('mailprogrammas','pleintje203');
            $smtp->mail($van);
            $smtp->to($geadresseerde);
            $smtp->cc('informatica.mail@vnz.be');
            #$smtp->bcc("bar@blah.net");
            $smtp->data;
            $smtp->datasend("From: harry.conings");
            $smtp->datasend("\n");
            $smtp->datasend("To: Kaartbeheerders");
            $smtp->datasend("\n");
            $smtp->datasend("Subject: Plaats files terug in gkd $vandaag");
            $smtp->datasend("\n");
            $smtp->datasend("$mail_error\nvriendelijke groeten\nHarry Conings");
            $smtp->dataend;
            $smtp->quit;
            print "mail aan $geadresseerde  gezonden\n";
           }
       }
 package sql_toegang_agresso;
     use DBI::DBD;
     sub setup_mssql_connectie {
        my $dbh_mssql;
        my $dsn_mssql = join "", (
            "dbi:ODBC:",
            "Driver={SQL Server};",
            "Server=S000WP1XXLSQL01.mutworld.be\\i200;", # nieuwe database server 2016 05 S000WP1XXLSQL01.mutworld.be\i200
            "UID=HOSPIPLUS;",
            "PWD=ihuho4sdxn;",           
            "Database=agrprod",
           );
         my $user = 'HOSPIPLUS';
         my $passwd = 'ihuho4sdxn';
        
         my $db_options = {
            PrintError => 1,
            RaiseError => 1,
            AutoCommit => 1, #0 werkt niet in
            LongReadLen =>2000,
   
           };
        #
        # connect to database
        #
        $dbh_mssql = DBI->connect($dsn_mssql, $user, $passwd, $db_options) or exit_msg("Can't connect: $DBI::errstr");
        return ($dbh_mssql)
       }
        
     sub afxvmobtoprint_insert_row {
           my ($class,$dbh,$dim_value,$naam_sjabloon,$moet_geprint) = @_; #$dim_value is agresso nr
           my $client ='VMOB';
           my $attribute_id = 'A4';
           my $user_id = 'WEBSERV';
           my $teller = $dbh->selectrow_array("SELECT MAX(line_no) FROM afxvmobtoprint WHERE client = '$client' and dim_value = '$dim_value'");
           $teller +=1;
           my $zetin = '';
           if (uc $moet_geprint eq 'JA' or uc $moet_geprint eq 'YES'){
                $zetin = "insert into afxvmobtoprint (attribute_id,dim_value,line_no,client,date_from,date_to,naam_sjabloon,datum_ingezet,datum_geprint,last_update,user_id)
                values ('$attribute_id','$dim_value',$teller,'$client',getdate(),getdate(),'$naam_sjabloon',getdate(),getdate(),getdate(),'$user_id')";
           }else {
                $zetin = "insert into afxvmobtoprint (attribute_id,dim_value,line_no,client,date_from,date_to,naam_sjabloon,datum_ingezet,datum_geprint,last_update,user_id)
                values ('$attribute_id','$dim_value',$teller,'$client',getdate(),getdate(),'$naam_sjabloon',getdate(),'',getdate(),'$user_id')";
           }
           my $sth= $dbh ->prepare($zetin);
           $sth -> execute();
           $sth -> finish();
           print "";
        }
     sub afxvmobtoremind_insert_row {
         my ($class,$dbh,$dim_value,$naam_sjabloon,$wat_moet_binnen_gebracht,$dagen_eerste_her,$dagen_tweede_her,$dagen_nag) = @_; #$dim_value is agresso nr
         my $client ='VMOB';
         my $attribute_id = 'A4';
         my $user_id = 'WEBSERV';
         my $totaaldagen = $dagen_eerste_her+$dagen_tweede_her;
         my $nag = $totaaldagen+$dagen_nag;
         my $teller = $dbh->selectrow_array("SELECT MAX(line_no) FROM afxvmobtoremind WHERE client = '$client' and dim_value = '$dim_value'");
         $teller +=1;
         my $zetin = "insert into afxvmobtoremind (attribute_id,dim_value,line_no,client,date_from,date_to,naam_sjabloon,wat_moet_binnen_gebracht,datum_ingezet,
                 datum_eerste_her,datum_eerste_her_geprint,datum_tweede_her,datum_tweede_her_geprint,start_nagging_datum,last_update,user_id)
                 values ('$attribute_id','$dim_value',$teller,'$client',getdate(),getdate(),'$naam_sjabloon','$wat_moet_binnen_gebracht', getdate(),
                 getdate() +$dagen_eerste_her,'',getdate() +$totaaldagen,'',getdate() +$nag,getdate(),'$user_id')";
         my $sth= $dbh ->prepare($zetin);
         $sth -> execute();
         $sth -> finish();
         print "";
        }
package maak_pdf ;
     use File::Copy;
     use Win32::FileOp;
     use File::Find;
     use Win32::File;
     use PDF::API2;
     sub new {
         my ($self,$file)=  @_;
         $file  =~ m/\d{6}-\d{3}-\d{2}/;
         my $inz_nr_spatie =$&;
         my $filename = "$agresso_instellingen->{plaats_files_gkd_agresso}\\$file";
         my $openoffice_dir = &dir__OO;
         my $home_dir = "$ENV{USERPROFILE}"  ;
         $inz_nr_spatie =~ s/-//g;
         my $home_file = "$home_dir\\$file";
         my $file_pdf  = $file;
         $file_pdf =~ s/\.od\w$/\.pdf/;
         my $pdfname = "$home_dir\\$file_pdf";
         unlink $home_file;
         copy ($filename  => $home_file);    
         unlink "$pdfname" ; #or &sluit_kwijting if (-e "$home_dir\\$externnummer-kwijting.pdf");
         my $macro= "macro:///ConversionLibrary.PDFConversion.ConvertWordToPdf($home_file,$pdfname)";
         my $gedaan= system(1,"$openoffice_dir\\program\\soffice.exe", '-invisible','-norestore',+ $macro);
         waitpid($gedaan, 0);
         my $emergency = 0;
         my $no_pdf = 0;
         until (-e $pdfname) {
           sleep 1;
           $emergency +=1;
           print "$emergency \n";
           if ($emergency == 80) {
              my $macro= "macro:///ConversionLibrary.PDFConversion.ConvertWordToPdf($home_file,$pdfname)";
              $emergency = 0;
              until (-e $pdfname) {
                 sleep 1;
                 $emergency +=1;
                 print "retry ->$emergency \n";
                  if ($emergency == 60) {
                    $no_pdf = 1;
                    last;
                   }
                }
              last;
             }  
          }
         print "pdf_gedaan $gedaan\n";
         unlink $home_file;
         &zet_logo ($pdfname);
         $main::klant->{file_encode64} =webservice_pdf_to_Agresso->convert_base64("$pdfname");
         my ($gelukt,$mydocid) = webservice_pdf_to_Agresso->PDF_naar_Agresso($pdfname);
         Webservice_pdf_to_Cataloog->Cataloog_createEventWithWarning($pdfname);
         if ($gelukt eq 'gelukt') {
             unlink ("$pdfname");
           }else {
             ($gelukt,$mydocid) = webservice_pdf_to_Agresso->PDF_naar_Agresso($pdfname);
             unlink ("$pdfname");           
            }
         return ($gelukt);
        }
     sub zet_logo {
         my $pdfname = shift @_;
         my $openoffice_dir = &dir__OO;
         my $home_dir = "$ENV{USERPROFILE}"  ;
         my $dienst_achtergrond = "$agresso_instellingen->{plaats_background_pdf}";
         #unlink "$home_dir\\mail_ad_brief.pdf";
         #unlink "$pdfname";
         my $achter_grond = '';
         if (-e $dienst_achtergrond) {
             $achter_grond = PDF::API2->open("$dienst_achtergrond");       # template file
            }else {
             $achter_grond = PDF::API2->open("c:\\macros\\adres\\mailsjabloon\\Logo_achtergrond.pdf");       # template file
            }
         my $brief = PDF::API2->open("$pdfname");
         my $outputpdf = PDF::API2->new;
         my $count =  $brief->pages();
         my $count_pages =1;
         my $page;
         while ($count_pages <= $count) {
             $page = $outputpdf->importpage($achter_grond,1);
             $page = $outputpdf->importpage($brief,$count_pages,$outputpdf->openpage($count_pages));
             $count_pages +=1;
            }
         $outputpdf->saveas("$pdfname");
        }

     sub dir__OO {
         my $dir = "c:\\Program Files";
         my $OO_dir ="";
         opendir(DIR, $dir);
         my @files = readdir(DIR);
         for my $file (@files) {
             if ($file =~ m/Openoffice.org/i) {
                 print "$file \n";
                 $OO_dir ="$dir\\$file";
                }
            }
         if ($OO_dir eq '') {
             $dir = "c:\\program files (x86)";
             opendir(DIR, $dir);
             my @files = readdir(DIR);
             for my $file (@files) {
                 if ($file =~ m/Openoffice.org/i) {
                     print "$file \n";
                     $OO_dir ="$dir\\$file";
                    }
                }
            }
         return ($OO_dir);
        }
package Webservice_pdf_to_Cataloog;  
     use SOAP::Lite #;
     +trace => [ transport => sub { print $_[0]->as_string } ];
     use MIME::Base64;
     use LWP::Simple;
     use DateTime::Format::Strptime;
     use DateTime;
     use Date::Manip::DM5 ;
     use File::Copy;
     use File::Basename;
     use File::stat;
     use Win32::FileOp;
     use File::Find;
    
     
     sub RijksRegister_Nummer {
         my ($class,$rr_nr) = @_ ;
         $rr_nr =~ s/\s//g;
         $rr_nr =~ s/-//g;
         $rr_nr = sprintf("%011s",$rr_nr);
         print "";
         #main->agresso_get_customer_info_rr_nr($rijks_register_nummer);
         my $uiteindelijk_ext_nr = '';
         my $uiteindelijk_zkf = '';
         my $uiteindelijk_ontslagen = '';
         foreach my $zf  (keys $verwerk_files::agresso_instellingen->{verzekeringen}) {
             my $zf_nr = substr($zf,3,3);
             my $settings = settings->new($zf_nr);
             my $dbconnectie = connectdb->connect_as400 ($settings->{user_name},$settings->{password},$settings->{name_as400});
             my $externnummer =as400_gegevens->natreg_to_extern($dbconnectie,$rr_nr,$settings);             
             if ($externnummer =~ m/\d+/) {
                 if  ($uiteindelijk_ext_nr eq '') {
                     $uiteindelijk_ext_nr = $externnummer;
                     $uiteindelijk_zkf = $zf;
                 }else {
                     # bestaat in 2 ziekenfondsen
                     my $is_nu_ontslagen = as400_gegevens->ontslag($dbconnectie,$externnummer,$settings);
                     if ($is_nu_ontslagen eq 'nee') {
                         $uiteindelijk_ext_nr = $externnummer;
                         $uiteindelijk_zkf = $zf;
                        }
                    }
                }
             connectdb->disconnect($dbconnectie);
            }
         return ($uiteindelijk_ext_nr,$uiteindelijk_zkf);
        }        
     sub Cataloog_createEventWithWarning {
       my ($class,$file_name) = @_;
       my $test = $verwerk_files::PdfToAgresso_instellingen;
       $file_name =~ m/HOSP_\w+_/;
       my $zoek_cat_key = '';
       $zoek_cat_key = $&;
       $zoek_cat_key =~ s/HOSP//g;
       $zoek_cat_key =~ s/_//g;
       my $pdf_naar_gkd= uc $verwerk_files::PdfToAgresso_instellingen->{pdf_naar_gkd}; 
       my $catalog_Key = $verwerk_files::PdfToAgresso_instellingen->{Catalog_key_Openoffice_brieven}; 
       my $vandaag = ParseDate("today");
       my $huidig_jaar = substr ($vandaag,0,4);
       my $huidige_maand = substr ($vandaag,4,2);
       my $huidige_dag = substr ($vandaag,6,2);
       my $vandaag_dag = $huidig_jaar*10000+$huidige_maand*100+$huidige_dag;
       my @maanden = ('januari','februari','maart','april','mei','juni','juli','augustus','september','oktober','november','december') ;
       my $rijkregnr = '';
       $file_name =~ m/\d+\-\d{3}\-\d{2}/;
       $rijkregnr = $&;
       $rijkregnr =~ s/-//g;
       $rijkregnr =~ s/\s//g;       
       my ($extern_nummer,$ziekenfonds) = Webservice_pdf_to_Cataloog->RijksRegister_Nummer($rijkregnr);      
       $ziekenfonds  =~ s/ZKF//g;
       $catalog_Key = $gkd_soorten_brieven->{ziekenfondsen}->{"zkf$ziekenfonds"}->{doc_in_naam_mapping}->{$zoek_cat_key}->{CAT} if ($zoek_cat_key ne '') ;
       $pdf_naar_gkd = uc $gkd_soorten_brieven->{ziekenfondsen}->{"zkf$ziekenfonds"}->{doc_in_naam_mapping}->{$zoek_cat_key}->{pdf_naar_gkd} if ($zoek_cat_key ne '') ; # specifieke setting per brief
       if ( $pdf_naar_gkd eq 'JA') {
            my $folderRef_text = $file_name;
            $folderRef_text =~ m/\d+\-.*/;
            $folderRef_text = $&;
            $folderRef_text =~ s/\d+-//g;
            $folderRef_text =~ s/\d+\.\d+\.\d+u\d+\.\d+\.//g;
            $folderRef_text =~ s/HOSPIPLUS//i;
            $folderRef_text =~ s/HOSPIPLAN//i;
            $folderRef_text =~ s/HOSPIFORFAIT//i;
            $folderRef_text =~ s/HOSPICONTINUE//i;
            $folderRef_text =~ s/_AMBUPLUS//i;
            $folderRef_text =~ s/_AMBUPLAN//i;
            $folderRef_text =~ s/--//g;
            $folderRef_text =~ s/\.\w{1}\d{3}\w+//;
            $folderRef_text =~ s/\.pdf$//;
            $folderRef_text =~ s/\_her\d{1}//;
            $folderRef_text =~ s/\_nops//;
            $folderRef_text =~ s/\-geenmail//;
            $folderRef_text =~ s/\.//g;
            $folderRef_text = substr($folderRef_text,0,20);
            if ($extern_nummer) {
                $extern_nummer = sprintf("%013s", $extern_nummer );             
                my $request = 'createEventWithWarning';            
                my $domain = "$ziekenfonds";
                my $zkf = "$ziekenfonds";
                my $user= $verwerk_files::PdfToAgresso_instellingen->{ziekenfondsen}->{"zkf$zkf"}->{as400_user};     	     #username as400
                my $pass=decode_base64($verwerk_files::PdfToAgresso_instellingen->{ziekenfondsen}->{"zkf$zkf"}->{as400_paswoord});              #paswoord
                my $endpoint_data = get("http://rfapps.jablux.cpc998.be/WebStartWeb/Jade2Properties/$domain/connectionspec.properties");
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
                my $file_encode64 = $main::klant->{file_encode64}; 
                my $vandaag = ParseDate("today");
                my $endpoint = "$host:$port/$contextPath/remoting/$environment_name/GEDCatalogService";
                my $uri   = 'http://ged.services.common.com.gfdi.be';
                my $soap = SOAP::Lite
                    ->proxy("http://$user:$pass\@$endpoint")
                    ->ns($uri)
                    ->on_action( sub { join '/','http://ged.services.common.com.gfdi.be',$request } )
                   ;
                my $docType    = SOAP::Data->name('docType' => "$catalog_Key")->type('');
                my $folderRef  = SOAP::Data->name('folderRef'=> "$folderRef_text")->type('');
                my $thirdCodeType = SOAP::Data->name('thirdCodeType' => "EXID")->type('');
                my $thirdCodeValue = SOAP::Data->name('thirdCodeValue' => "$extern_nummer")->type('');
                my $thirdOrg = SOAP::Data->name('thirdOrg' => "$zkf")->type('');
                my $thirdParType = SOAP::Data->name('ThirdParType' =>"MUTUALITYPERSON")->type('');
                my $imageMimeType = SOAP::Data->name('imageMimeType' => "application/pdf")->type('');
                my $imageName  = SOAP::Data->name('imageName' => "$file_name")->type('');             
                my $imageBytes = SOAP::Data->name('imageBytes' => "$file_encode64")->type('');
                #my $workflowFlg = SOAP::Data->name('workflowFlg' => 1)->type('');
                my $createEventWithWarning = SOAP::Data->name('createEventWithWarning') ->attr({xmlns => "$uri"});
                my $in0 = SOAP::Data->name('in0')
                     ->value(\SOAP::Data->value($docType,$folderRef,$thirdCodeType,$thirdCodeValue,
                       $thirdOrg,$thirdParType,$imageMimeType,$imageName,$imageBytes));#$workflowFlg,
                #my $response->{_content}->[2]->[0]->[2]->[0]->[4]->{out}->{key} = "test 203- $file_name niet ingezet";
                my $response = $soap->call($createEventWithWarning,$in0);
                my $key = '';
                eval {$key = $response->{_content}->[2]->[0]->[2]->[0]->[4]->{out}->{key}};
                if (!$@) {
                   $key = $response->{_content}->[2]->[0]->[2]->[0]->[4]->{out}->{key};
                  }
                return ($key);
                print "";
            } 
        }else {
          print "geen PDF naar -> GKD nodig -> $file_name\n";
        }
       
       
    }
      
1;
package webservice_pdf_to_Agresso;  
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
     sub PDF_naar_Agresso {
            my ($class,$file) = @_;
            my $vandaag = ParseDate("today");
            my $huidig_jaar = substr ($vandaag,0,4);
            my $huidige_maand = substr ($vandaag,4,2);
            my $huidige_dag = substr ($vandaag,6,2);
            my $vandaag_dag = $huidig_jaar*10000+$huidige_maand*100+$huidige_dag;
            my @maanden = ('januari','februari','maart','april','mei','juni','juli','augustus','september','oktober','november','december') ;
            my $clientnummer = $main::klant->{Agresso_nummer};
            my $pdf_naar_agresso= uc $verwerk_files::PdfToAgresso_instellingen->{pdf_naar_agresso};
            $file=~ m/HOSP_\w+_/;
            my $zoek_cat_key = '';
            $zoek_cat_key = $&;
            $zoek_cat_key =~ s/HOSP//g;
            $zoek_cat_key =~ s/_//g;
            #my = main::
            $pdf_naar_agresso = uc $gkd_soorten_brieven->{ziekenfondsen}->{"zkf203"}->{doc_in_naam_mapping}->{$zoek_cat_key}->{pdf_naar_agresso} if ($zoek_cat_key ne '') ; # specifieke setting per brief
            ##$clientnummer = 67122533419;#;100048 100248 166516
            use SOAP::Lite ;
            if ($pdf_naar_agresso eq 'JA') {
             my $proxy = 'http://S200WP1XXL01.mutworld.be/BusinessWorld-webservices/service.svc'; # productie           
             my $uri   = 'http://services.agresso.com/DocArchiveService/DocArchiveV201101';
             my $soap = SOAP::Lite
                 ->proxy($proxy)
                 ->ns($uri,'doc')
                 ->on_action( sub { return 'AddDocument' } );
             my $DocId  = SOAP::Data->name('doc:DocId'=> 0)->type('');
             #my $type = $main::PdfToAgresso_instellingen->{DocType};
             my $type = "KLANTBRIEF";
             my $DocType  = SOAP::Data->name('doc:DocType'=> $type )->type('');
             my $RevisionNo = SOAP::Data->name('doc:RevisionNo'=> 1)->type('');
             my $folderRef_text =$file;
             #$folderRef_text =~ s/\.--./.-ONBEKEND-./g;             
             $folderRef_text =~ m/\d{6}-\d{3}-\d{2}\.\d+-\d+-\d+\.\d+u\d+\.\d{3}.*/;
             $folderRef_text = $&;
             $folderRef_text =~ s/\d{6}-\d{3}-\d{2}\.\d+-\d+-\d+\.\d+u\d+.\d{3}\.//;  
             if ($folderRef_text eq '.odt' or $folderRef_text eq '.ods' ) {
                 $folderRef_text =$file;
                 $folderRef_text =~ m/\d{6}-\d{3}-\d{2}\.\d+-\d+-\d+\.\d{3}.*/;
                 $folderRef_text = $&;
                 $folderRef_text =~ s/\d{6}-\d{3}-\d{2}\.\d+-\d+-\d+\.\d{3}\.//;
                }
             $folderRef_text =~ m/\.\w{1}\d{3}\w+/;
             my $user = $&;
             $user  =~ s/\.//g;     
             $folderRef_text =~ s/\.\w{1}\d{3}\w+//;            
             $folderRef_text =~ m/-.*-\./;
             my $Comments_data = $&;
             $Comments_data  =~ s/\.//g;
             $Comments_data  =~ s/-//g;
             $folderRef_text =~ s/-.*-\.//;
             $folderRef_text =~ s/\.odt$/\.pdf/;
             $folderRef_text =~ s/\.ods$/\.pdf/;
             my $FileName = SOAP::Data->name('doc:FileName'=> "$folderRef_text")->type('');
             $folderRef_text =~ s/\.odt$//;
             $folderRef_text =~ s/\.pdf$//;
             $folderRef_text =~ s/\_her\d{1}//;
             $folderRef_text =~ s/\_nops//;
             $folderRef_text =~ s/\-geenmail//;
             $folderRef_text =~ s/\_M_//;
             $folderRef_text = substr($folderRef_text,0,40);
             my $Comments = SOAP::Data->name('doc:Comments'=> "$Comments_data")->type('');
             my $Description = SOAP::Data->name('doc:Description'=> "$user $Comments_data")->type('');
             my $RevisionDate = SOAP::Data->name('doc:RevisionDate'=> "$huidig_jaar-$huidige_maand-$huidige_dag")->type('');
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
             eval {my $link = $response->{_content}->[2]->[0]->[2]->[0]->[4]->{AddDocumentResult}->{Properties}->{DocumentProperties}};
             if (!$@) {
                 my $link = $response->{_content}->[2]->[0]->[2]->[0]->[4]->{AddDocumentResult}->{Properties}->{DocumentProperties};
                 eval {my $gelukt = $link->{DocId}};
                 if (!$@) {
                     my $gelukt = $link->{DocId};
                     return ('gelukt',$gelukt);
                    }else {
                     return ('mislukt');
                    }   
                }else {
                     return ('mislukt');
                }  
            }else {
                print "geen pdf -> agresso nodig -> $file\n";
                return ('gelukt',1);
            }
        }
package zoek_agresso_nr;
     sub new {
            use SOAP::Lite ;#'trace', 'debug' ;
            my ($class,$clientnummer ) = @_;
            $clientnummer =~ s/\s//g;
            $clientnummer =~ s/\-//g;
            #$clientnummer = 67122533419;#;100048 100248 166516
            #use SOAP::Lite ;
            my $proxy = 'http://S200WP1XXL01.mutworld.be/BusinessWorld-webservices/service.svc'; # productie          
           # my $proxy = 'http://10.198.205.8/AgressoWSHost/service.svc';
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
            #my $GetCustomer       = SOAP::Data->name('cus:GetCustomer')
            #->value(\SOAP::Data->value($company , $customerId, $customerDetailsOnly ,$credentials ));
            my $response = $soap->GetCustomers($customerObject, $customerDetailsOnly ,$credentials );
            eval {my $returncode =$response->{_content}[2][0][2][0][4]->{GetCustomersResult}->{ReturnCode}};
            if ( $response->{_content}[2][0][2][0][4]->{GetCustomersResult}->{ReturnCode} == 40 and !$@) {
                #code
            print "";
            $main::klant->{Agresso_nummer} = $response->{_content}[2][0][2][0][4]->{GetCustomersResult}->{CustomerTypeList}->{CustomerObject}->{CustomerID};
            $main::klant->{CustomerGroupID} = $response->{_content}[2][0][2][0][4]->{GetCustomersResult}->{CustomerTypeList}->{CustomerObject}->{CustomerGroupID};
            #my $test = $response->{_content}[2][0][2][0][4]->{GetCustomersResult}->{CustomerTypeList}->{CustomerObject}->{CustomerName};
            $main::klant->{naam} =$response->{_content}[2][0][2][0][4]->{GetCustomersResult}->{CustomerTypeList}->{CustomerObject}->{CustomerName};
            $main::klant->{Rijksreg_Nr} =$response->{_content}[2][0][2][0][4]->{GetCustomersResult}->{CustomerTypeList}->{CustomerObject}->{ExternalReference};
            $main::klant->{Bankrekening}=$response->{_content}[2][0][2][0][4]->{GetCustomersResult}->{CustomerTypeList}->{CustomerObject}->{BankAccount};
            $main::klant->{IBAN}=$response->{_content}[2][0][2][0][4]->{GetCustomerResult}->{CustomerType}->{IBAN};
            $main::klant->{BIC}=$response->{_content}[2][0][2][0][4]->{GetCustomerResult}->{CustomerType}->{Swift};
            $main::klant->{Taal}=$response->{_content}[2][0][2][0][4]->{GetCustomerResult}->{CustomerTypeList}->{CustomerObject}->{Language};
            $main::klant->{PTL_TIT}=$response->{_content}[2][0][2][0][4]->{GetCustomerResult}->{CustomerType}->{Text};
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
                 if ($link->[$nr]->{FlexiGroup} eq 'VMOBCONTR2') { # dit zijn de contracten
                      my $contract_teller=0;
                      eval {my $testeval = $link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->[0]->{FlexiFieldList} };
                      if ($@) {
                           foreach my $nr_nr_nr (keys $link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->{FlexiFieldList}->{FlexiFieldUnitType}) {
                                if ($link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{ColumnName} eq 'product') {
                                     $main::klant->{contracten}->[$contract_teller]->{naam}=$link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->{FlexiFieldList}->{FlexiFieldUnitType}->[$nr_nr_nr]->{Value};
                                     my $NAAM = uc $main::klant->{contracten}->[$contract_teller]->{naam};
                                     push (@main::verzekeringen_in_xml,$NAAM) if !($NAAM ~~ @main::verzekeringen_in_xml);
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
                                            my $NAAM = uc $main::klant->{contracten}->[$contract_teller]->{naam};
                                            push (@main::verzekeringen_in_xml,$NAAM) if !($NAAM ~~ @main::verzekeringen_in_xml);
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
                 if ($link->[$nr]->{FlexiGroup} eq 'VMOBZIEKTEN2') { #dit zijn de ziekten
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
                 if ($link->[$nr]->{FlexiGroup} eq 'VMOBAANDOEN2') { #dit zijn de ziekten
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
            #my $aantal_lijnen = &sorteer_contracten;
            #for (my $i = 0; $i < $aantal_lijnen; $i++) {
            #     &sorteer_contracten;
            #    }
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
package as400_gegevens;
      sub natreg_to_extern {
         my ($self,$dbh,$natnummer,$settings) = @_;
         #openen van PFYSL8
         # EXIDL8 = extern nummer
         # KNRNL8 = nationaalt register nummer
         # NAMBL8 = naam van de gerechtigde
         # PRNBL8 = voornaam van de gerechtigde
         # SEXEL8 = code van het geslacht
         # NAIYL8 = geboortejaat
         # NAIML8 = geboortemaand
         # NAIJL8 = geboortedag
           
         my $ex = $dbh->selectrow_array("SELECT EXIDL8 FROM $settings->{'pers_fil'} WHERE KNRNL8=$natnummer");
         return ($ex);
        }
      sub ontslag {
            my ($self,$dbh,$ext_nr,$settings) = @_;
            #we openen PHOEKK
            #IDFDKK              NUMERO MUTUELLE         /NUMME
            #A.EXIDKK              NUMERO EXTERNE          /EXTER
            #A.ABADKK              DATE DEBUT DOSSIER      /AANVA
            #A.ABEDKK              DATE FIN DOSSIER        /EINDD    
            #A.ABNOKK              NUMERO DOSSIER          /DOSSI    
            #A.ABPRKK              NO PRODUIT              /NUMME    
            #A.ABCTKK              CODE TITULAIRE          /CODET
            #A.ABTVKK              CODE VERZEKERING         /CODET
            #ABACKK              CODE AFFILIATION / AANSLUITING 
            #AB2AKK              CODE DETAIL AFFILIATION /DETAI
            #ABOCKK              CODE DESAFFILIATION     /ONTSL    
            #AB2OKK              CODE DETAIL DESAFFILIATION / D
            #ABPEKK              DATE PRISE D'EFFET     /AANVANGDATUM
            my $onslagen = 'ja';
            my $sql =("SELECT EXIDKK FROM $settings->{'phoekk_fil'} WHERE ABOCKK = '' and EXIDKK =$ext_nr and ABTVKK = 11");
            my $sth = $dbh->prepare( $sql );
            $sth ->execute();
            while(my $return_ext = $sth->fetchrow_array)  {
                 $onslagen = 'nee';
                }
            return ($onslagen);
        }
