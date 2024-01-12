#!/usr/bin/perl -w
use strict;
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
use XML::Simple;
use File::Copy;
use File::Find;
use File::Path qw(make_path remove_tree); ;
use Win32::File;
use IO::Uncompress::Unzip qw(unzip $UnzipError) ;
use Net::SMTP;
use Date::Manip::DM5 ;
use Time::Piece;
use Time::Seconds;
our $vandaag = ParseDate("today");
our $time = time();
my $AGE = 60*60*24*14;  # convert 14 days into seconds
my $vandaag_tijd = $vandaag;
$vandaag_tijd =~ s/://g;
$vandaag_tijd =~ s/\s//g;
$vandaag = substr($vandaag,0,8);
my $jaar = substr($vandaag,0,4);
#our $agresso_instellingen;
my ($locatie,$locatie_verwerkte_invoices) = &load_agresso_setting_invoice('D:\OGV\ASSURCARD_2023\assurcard_settings_xml\agresso_settings.xml');
&make_subdirectories ($locatie,$locatie_verwerkte_invoices,$jaar);
&move_files($locatie,$locatie_verwerkte_invoices,$jaar);
sub load_agresso_setting_invoice  {
     my $file_name = shift @_;
     my $agresso_instellingen = XMLin("$file_name");
     print "ingelezen plaats_file plaats $agresso_instellingen->{plaats_file} plaats_invoices_verwerkt $agresso_instellingen->{plaats_invoices_verwerkt}\n";
     #maak verzekeringen
     return ($agresso_instellingen->{plaats_file},$agresso_instellingen->{plaats_invoices_verwerkt});
    }
sub make_subdirectories {
     my $location = shift @_;
     my $locatie_verwerkte_invoices = shift @_;
     my $jaar= shift @_;
     my $vorig_jaar = $jaar-1;
     my $twee_jaar_geleden = $jaar-2;
     if (-d "$locatie_verwerkte_invoices\\$twee_jaar_geleden") {
          }elsif (-e "$locatie_verwerkte_invoices\\$twee_jaar_geleden") {
           unlink "$locatie_verwerkte_invoices\\$twee_jaar_geleden";
           make_path("$locatie_verwerkte_invoices\\$twee_jaar_geleden");
          }else {
           make_path("$locatie_verwerkte_invoices\\$twee_jaar_geleden");
          }
      if (-d "$locatie_verwerkte_invoices\\$vorig_jaar") {
          }elsif (-e "$locatie_verwerkte_invoices\\$vorig_jaar") {
           unlink "$locatie_verwerkte_invoices\\$vorig_jaar";
           make_path("$locatie_verwerkte_invoices\\$vorig_jaar");
          }else {
           make_path("$locatie_verwerkte_invoices\\$vorig_jaar");
          }
       if (-d "$locatie_verwerkte_invoices\\$jaar") {
          }elsif (-e "$locatie_verwerkte_invoices\\$jaar") {
           unlink "$locatie_verwerkte_invoices\\$jaar";
           make_path("$locatie_verwerkte_invoices\\$jaar");
          }else {
           make_path("$locatie_verwerkte_invoices\\$jaar");
          }
     if (-d "$location\\CONTRACTXML") {
         # directory called cgi-bin exists
        }elsif (-e "$location\\CONTRACTXML") {
          unlink "$location\\CONTRACTXML";# exists but is not a directory
          make_path("$location\\CONTRACTXML");
        }else {
          make_path("$location\\CONTRACTXML");
        }
     if (-d "$location\\INVOICERECEIVED") {
         # directory called cgi-bin exists
        }elsif (-e "$location\\INVOICERECEIVED") {
          unlink "$location\\INVOICERECEIVED";# exists but is not a directory
          make_path("$location\\INVOICERECEIVED");
        }else {
          make_path("$location\\INVOICERECEIVED");
        }
     if (-d "$location\\INVOICE_TO_AGRESSO") {
         # directory called cgi-bin exists
        }elsif (-e "$location\\INVOICE_TO_AGRESSO") {
          unlink "$location\\INVOICE_TO_AGRESSO";# exists but is not a directory
          make_path("$location\\INVOICE_TO_AGRESSO");
        }else {
          make_path("$location\\INVOICE_TO_AGRESSO");
        }
     if (-d "$location\\ASSURCARD_ORDER_AGRESSO") {
         # directory called cgi-bin exists
        }elsif (-e "$location\\ASSURCARD_ORDER_AGRESSO") {
          unlink "$location\\ASSURCARD_ORDER_AGRESSO";# exists but is not a directory
          make_path("$location\\ASSURCARD_ORDER_AGRESSO");
        }else {
          make_path("$location\\ASSURCARD_ORDER_AGRESSO");
        }
     if (-d "$location\\KAARTGENERATIE") {
         # directory called cgi-bin exists
        }elsif (-e "$location\\KAARTGENERATIE") {
          unlink "$location\\KAARTGENERATIE";# exists but is not a directory
          make_path("$location\\KAARTGENERATIE");
        }else {
          make_path("$location\\KAARTGENERATIE");
        }
     if (-d "$location\\HOSPI_ORDER_AGRESSO") {
         # directory called cgi-bin exists
        }elsif (-e "$location\\HOSPI_ORDER_AGRESSO") {
          unlink "$location\\HOSPI_ORDER_AGRESSO";# exists but is not a directory
          make_path("$location\\HOSPI_ORDER_AGRESSO");
        }else {
          make_path("$location\\HOSPI_ORDER_AGRESSO");
        }
     if (-d "$location\\PAYMENTFEEDBACK") {
         # directory called cgi-bin exists
        }elsif (-e "$location\\PAYMENTFEEDBACK") {
          unlink "$location\\PAYMENTFEEDBACK";# exists but is not a directory
          make_path("$location\\PAYMENTFEEDBACK");
        }else {
          make_path("$location\\PAYMENTFEEDBACK");
        }
     if (-d "$location\\AGRESSO_CUSTOMER_GENERATION") {
         # directory called cgi-bin exists
        }elsif (-e "$location\\AGRESSO_CUSTOMER_GENERATION") {
          unlink "$location\\AGRESSO_CUSTOMER_GENERATION";# exists but is not a directory
          make_path("$location\\AGRESSO_CUSTOMER_GENERATION");
        }else {
          make_path("$location\\AGRESSO_CUSTOMER_GENERATION");
        }     
    }
sub move_files {
     my $location = shift @_;
     my $locatie_verwerkte_invoices =shift @_;
     my $jaar= shift @_;
     my $vorig_jaar = $jaar-1;
     my $twee_jaar_geleden = $jaar-2;
     print "locatie verwerkt $locatie_verwerkte_invoices\n";
     opendir(DIR,$locatie_verwerkte_invoices);
     my @inhouddir_inv = readdir(DIR);
     my @files = ();
     foreach my $file_dir (@inhouddir_inv) {
            my $datumfile = $file_dir;
            $datumfile =~ s/^\d+\.invoice.out\.//;
            $datumfile =~ s/\.\d+\..*$//;
            if ($datumfile > 20130000) {
                my $datumfile1 = Time::Piece->strptime($datumfile, "%Y%m%d");
                my $vandaag1 = Time::Piece->strptime($vandaag, "%Y%m%d");
                my $diff = Time::Seconds->new($vandaag1 - $datumfile1);
                my $dagen_oud = $diff->days;
                print $diff->days, "\n";
                my $jaarfile = substr ($datumfile,0,4);
                if ($jaarfile == $twee_jaar_geleden ){
                    my $test_copy=0;
                    print "copy $locatie_verwerkte_invoices\\$file_dir  => $locatie_verwerkte_invoices\\$twee_jaar_geleden\n";
                    copy ("$locatie_verwerkte_invoices\\$file_dir"  => "$locatie_verwerkte_invoices\\$twee_jaar_geleden") or
                    $test_copy= &error_mail_copy_invoices ("$locatie_verwerkte_invoices\\$file_dir" ,"locatie_verwerkte_invoices\\$twee_jaar_geleden");
                    unlink ("$locatie_verwerkte_invoices\\$file_dir"  => "ocatie_verwerkte_invoices\\$twee_jaar_geleden") if ($test_copy==0); 
                   }
                if ($jaarfile == $vorig_jaar and $dagen_oud > 30 ){
                    my $test_copy=0;
                    print "copy $locatie_verwerkte_invoices\\$file_dir  => $locatie_verwerkte_invoices\\$vorig_jaar\n";
                    copy ("$locatie_verwerkte_invoices\\$file_dir"  => "$locatie_verwerkte_invoices\\$vorig_jaar") or
                    $test_copy= &error_mail_copy_invoices ("$locatie_verwerkte_invoices\\$file_dir" ,"locatie_verwerkte_invoices\\$vorig_jaar");
                    unlink ("$locatie_verwerkte_invoices\\$file_dir"  => "ocatie_verwerkte_invoices\\$vorig_jaar") if ($test_copy==0); 
                   }
                if ($jaarfile == $jaar and $dagen_oud > 30 ){
                    my $test_copy=0;
                    print "copy $locatie_verwerkte_invoices\\$file_dir  => $locatie_verwerkte_invoices\\$jaar\n";
                    copy ("$locatie_verwerkte_invoices\\$file_dir"  => "$locatie_verwerkte_invoices\\$jaar") or
                    $test_copy= &error_mail_copy_invoices ("$locatie_verwerkte_invoices\\$file_dir" ,"locatie_verwerkte_invoices\\$jaar");
                    unlink ("$locatie_verwerkte_invoices\\$file_dir"  => "ocatie_verwerkte_invoices\\$jaar") if ($test_copy==0); 
                   }
               }
           print '';
          }
     opendir(DIR,$location);
     my @inhouddir = readdir(DIR);
     my @files0 = ();
     my @files1 = ();
     my @files2 = ();
     my @files3 = ();
     my @files4 = ();
     my @files5 = ();
     my @files6 = ();
     my @files7 = ();
     my @files8 = ();
     foreach my $file_dir (@inhouddir) {
         push (@files0,$file_dir) if ($file_dir =~ m/laser\.\d+\.\d+\.bak$/i);
         push (@files1,$file_dir) if ($file_dir =~ m/laser\.\d+\.\d+\.xml$/i);
         push (@files2,$file_dir) if ($file_dir =~ m/Contracts\.\d+\.\d+\.\d+\.xml$/i);
         push (@files3,$file_dir) if ($file_dir =~ m/HOSPI\.\d+\.AgressoOrder\.\d+\.xml$/i);
         push (@files4,$file_dir) if ($file_dir =~ m/InvoiceReceived\.\d+\.\d+\.\d+\.xml$/i);
         push (@files5,$file_dir) if ($file_dir =~ m/PaymentFeedback\.\d+\.\d+\.\d+\.xml$/i);
         push (@files6,$file_dir) if ($file_dir =~ m/assurcard_agresso_invoice\.\d+\.\d+\.\d+\.xml$/i);
         push (@files7,$file_dir) if ($file_dir =~ m/Assurcard\.\d+\.AgressoOrder\.\d+\.xml$/i);                                                  #Assurcard.130522.AgressoOrder.20141222140323.xml
         push (@files8,$file_dir) if ($file_dir =~ m/klanten_naar_agresso/i);    
        }
     print "";
     my $test_copy=0;
     foreach my $file (@files0) {
         $test_copy=0;
         print "copy $location\\$file  => $location\\KAARTGENERATIE\n";
         copy ("$location\\$file"  => "$location\\KAARTGENERATIE") or $test_copy= &error_mail_copy_invoices ("$location\\$file" ,"$location\\KAARTGENERATIE");
         unlink ("$location\\$file"  => "$location\\KAARTGENERATIE") if ($test_copy==0);
        }
     foreach my $file (@files1) {
         $test_copy=0;
         print "copy $location\\$file  => $location\\KAARTGENERATIE\n";
         copy ("$location\\$file"  => "$location\\KAARTGENERATIE") or $test_copy= &error_mail_copy_invoices ("$location\\$file" ,"$location\\KAARTGENERATIE");
         unlink ("$location\\$file"  => "$location\\KAARTGENERATIE") if ($test_copy==0);
        }
     foreach my $file (@files2) {
         $test_copy=0;
         print "copy $location\\$file  => $location\\CONTRACTXML\n";
         copy ("$location\\$file"  => "$location\\CONTRACTXML") or $test_copy= &error_mail_copy_invoices ("$location\\$file" ,"$location\\CONTRACTXML");
         unlink ("$location\\$file"  => "$location\\CONTRACTXML") if ($test_copy==0);
        }
     foreach my $file (@files3) {
         $test_copy=0;
         print "copy $location\\$file  => $location\\HOSPI_ORDER_AGRESSO\n";
         copy ("$location\\$file"  => "$location\\HOSPI_ORDER_AGRESSO") or $test_copy= &error_mail_copy_invoices ("$location\\$file" ,"$location\\HOSPI_ORDER_AGRESSO");
         unlink ("$location\\$file"  => "$location\\HOSPI_ORDER_AGRESSO") if ($test_copy==0);
        }     
     foreach my $file (@files4) {
         $test_copy=0;
         print "copy $location\\$file  => $location\\INVOICERECEIVED\n";
         copy ("$location\\$file"  => "$location\\INVOICERECEIVED") or $test_copy= &error_mail_copy_invoices ("$location\\$file" ,"$location\\INVOICERECEIVED");
         unlink ("$location\\$file"  => "$location\\INVOICERECEIVED") if ($test_copy==0);
        }
     foreach my $file (@files5) {
         $test_copy=0;
         print "copy $location\\$file  => $location\\PAYMENTFEEDBACK\n";
         copy ("$location\\$file"  => "$location\\PAYMENTFEEDBACK") or $test_copy= &error_mail_copy_invoices ("$location\\$file" ,"$location\\PAYMENTFEEDBACK");
         unlink ("$location\\$file"  => "$location\\PAYMENTFEEDBACK") if ($test_copy==0);
        }
     foreach my $file (@files6) {
         $test_copy=0;
         print "copy $location\\$file  => $location\\INVOICE_TO_AGRESSO\n";
         copy ("$location\\$file"  => "$location\\INVOICE_TO_AGRESSO") or $test_copy= &error_mail_copy_invoices ("$location\\$file" ,"$location\\ASSURCARD_ORDER_AGRESSO");
         unlink ("$location\\$file"  => "$location\\INVOICE_TO_AGRESSO") if ($test_copy==0);
        }
      foreach my $file (@files7) {
         $test_copy=0;
         print "copy $location\\$file  => $location\\ASSURCARD_ORDER_AGRESSO\n";
         copy ("$location\\$file"  => "$location\\ASSURCARD_ORDER_AGRESSO") or $test_copy= &error_mail_copy_invoices ("$location\\$file" ,"$location\\ASSURCARD_ORDER_AGRESSO");
         unlink ("$location\\$file"  => "$location\\ASSURCARD_ORDER_AGRESSO") if ($test_copy==0);
        }
     foreach my $file (@files8) {
         $test_copy=0;
         print "copy $location\\$file  => $location\\AGRESSO_CUSTOMER_GENERATION\n";
         copy ("$location\\$file"  => "$location\\AGRESSO_CUSTOMER_GENERATION") or $test_copy= &error_mail_copy_invoices ("$location\\$file" ,"$location\\ASSURCARD_ORDER_AGRESSO");
         unlink ("$location\\$file"  => "$location\\ASSURCARD_ORDER_AGRESSO") if ($test_copy==0);
        } 
}
sub error_mail_copy_invoices {
     return (1);
}