#!/usr/bin/perl -w
#gebruikt enkel agresso_settings_V2.xml
#in GIT gezet
#OPGELET!!!!!!
#Dit programma is auteursrechtelijk beschermd.
#Deze code is voor 50% eigendom van Hospiplus en voor 50% eigendom van de Firma  I.C.E. (liebroekstraat 43 3545 Halen BE0446888007) .
#Deze code mag niet aan derden (ook niet VNZ en NZVL) getoond worden tenzij met uitdrukkelijke en schriftelijke toestemming van Hospiplus en I.C.E. bvba .
#Indien dit toch gebeurt is er een boete verschuldigd van 250.000 € exclusief btw aan de Firma  I.C.E.
#Dit geldt ook voor het kopieren van een stuk code of het repliceren van technieken gehanteerd in dit programma
#I.C.E. beheert de broncode je mag  veranderingen aanbrengen aan het programma . Deze worden samen met de documentatie overgedragen aan I.C.E. .
#I.C.E. beslist dan op deze veranderingen worden doorgevoerd.

#Door het openen van deze broncode stem je in met de voorgaande voorwaarden.

#
#gebruikt enkel PdfToAgressoScanning_settings_new.xml
#Harry Conings beheert voor I.C.E de broncode
use strict;

require 'Decryp_Encrypt_prod.pl';
require "package_cnnectdb_as400.pl";
package main;
     our $klant;
     our $as400;
     our $test_prod = 'PROG'; # test = 'TEST' productie = 'PROG'
     verwerk_files->new;
package verwerk_files;
     use Cwd;
     use File::Copy;
     use File::Basename;
     use File::stat;
     use File::Util;
     use Win32::FileOp;
     use File::Find;
     use Win32::File;
     use Net::SMTP;
     use Date::Calc qw(Delta_Days);
     use XML::Simple;
     use File::Path qw(make_path remove_tree);
     use IO::Uncompress::Unzip qw(unzip $UnzipError) ;
     use Date::Manip::DM5 ;
     use Time::Piece;
     use Time::Seconds;
     use POSIX qw( strftime );
     our $agresso_instellingen;
     our $zet_klant_instellingen;
     #our $brieven_instellingen;
     #our $PdfToAgresso_instellingen;
     our @lock_files;
     #our $gkd_soorten_brieven; #welke brieven gaan naar welke directory 
   
     sub new {
        my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);
        my $today_year = $year+1900;
        my $today_month = $mon+1;
        my $today_day=$mday;
        my $today_year_month =$today_year*100+$today_month;
        our $mail_text;
         verwerk_files->load_agresso_setting('D:\OGV\ASSURCARD_2023\assurcard_settings_xml\agresso_settings.xml');
         print '';
         $mail_text = &delete_lock_cache($mail_text);
         my $directory =  $agresso_instellingen->{plaats_file};
         $mail_text = &clean_agresso_xml($mail_text,$directory ,$today_year_month);
         $directory =  $agresso_instellingen->{plaats_file1};
         $mail_text = &clean_agresso_xml($mail_text,$directory ,$today_year_month);
         $mail_text = $mail_text."\nEINDE\n____________\n";
         &mail_verwerkt($mail_text);
         print "\nEINDE\n____________\n";
         
     }     
     sub load_agresso_setting  {
         my ($class,$file_name) =  @_;
         $agresso_instellingen = XMLin("$file_name");         
         print "ingelezen\n";          
        }
     sub delete_lock_cache {
         my $files_text = @_;
         my $directory = $agresso_instellingen->{plaats_brieven_cache};
         print "\n____________________________________________________________________________\n$directory\n_____________________________________________________________________\n";
         #hidden files
         $files_text = "$files_text\n\nVolgende lock files werden verwijderd in $directory \n_______________________________________________\n";
         &find(\&wanted,$agresso_instellingen->{plaats_brieven_cache});
         #alle hiddeen files zitten in lock_files
         my $lock_teller =1;
         foreach (@verwerk_files::lock_files) {
            $files_text = $files_text."\t$lock_teller $_\n";
            print "unlink $directory\\$_";
            unlink "$directory\\$_";
            $lock_teller +=1;
            }
         return ($files_text);
        }
     sub clean_agresso_xml {
          my ($mailtext,$directory,$dir_d) = @_;         
          opendir(DIR,$directory);
          my @files = grep(/\.xml$/,readdir(DIR));
          my $destination_dir =$agresso_instellingen->{plaats_clean_agresso_xml};
          our $vandaag = ParseDate("today");
          $vandaag= substr($vandaag,0,8);
          $mailtext =$mailtext."\nWe gaan xml's archiveren\n___________________________\n\n";
          if (-e "$destination_dir\\$dir_d") {
               
            }else{
             make_path("$destination_dir\\$dir_d");
            }
          foreach my $xl (@files) {
            my $file = "$directory\\$xl";
            my $epoch = stat($file)->mtime;
            #my $date = strftime '%Y/%m/%d %H:%M:%S', localtime $epoch;
            #my $creation =Time::Piece -> new( $epoch );
            my $clean_text_time= strftime('%Y-%m-%d %H:%M:%S', gmtime($epoch));
            my $clean_text_time_day= substr ($clean_text_time,0,10);
            $clean_text_time_day =~ s/-//g;
            my $datumfile1 = Time::Piece->strptime($clean_text_time_day, "%Y%m%d");
            my $vandaag1 = Time::Piece->strptime($vandaag, "%Y%m%d");
            my $diff = Time::Seconds->new($vandaag1 - $datumfile1);
            my $dagen_oud = $diff->days;
            print '';
            if ($dagen_oud > 10) {
                 copy ("$file"  => "$destination_dir\\$dir_d");
                 $mailtext = $mailtext."$file naar $destination_dir\\$dir_d verplaatst\n";
                 unlink $file;
                 print '';
                 
            }
          }
          return ($mailtext);
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
            #$smtp->cc('informatica.mail@vnz.be');
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
            #$smtp->cc('informatica.mail@vnz.be');
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
        my $mail_error="$file_s \n";
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
            $smtp->datasend("Subject: verwijder lock files $vandaag");
            $smtp->datasend("\n");
            $smtp->datasend("$mail_error\nvriendelijke groeten\nHarry Conings");
            $smtp->dataend;
            $smtp->quit;
            print "mail aan $geadresseerde  gezonden\n";
           }
       }
            
