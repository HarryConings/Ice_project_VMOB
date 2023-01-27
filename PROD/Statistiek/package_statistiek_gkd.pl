#!/usr/bin/perl -w
use strict;
use XML::Simple;
use Date::Manip::DM5 ;
use Date::Calc qw(:all);
use DateTime::Format::Strptime;
use DateTime;
require "package_cnnectdb_prod.pl";
require "package_settings_prod.pl";
require 'Decryp_Encrypt.pl';
our $teksten;
our $statistiek_gkd_instellingen;
our $AS400;
our @tekst_match;
package main;
    &load_statistiek_gkd_instellingen;
    #&teksten_gkd;
    main->load_as400_settings('P:\OGV\ASSURCARD_PROG\assurcard_settings_xml\zet_klant_in_AS400_settings.xml'); #nagezien
    my $Begin_datum = $ARGV[0];
    my $Eind_datum = $ARGV[1];
    #$Begin_datum= 20160101;
    #$Eind_datum  = 20160120;
    my $statistiek;
       foreach my $zkf_test (keys $main::statistiek_gkd_instellingen->{ziekenfondsen}) {
          my $zkf = $zkf_test;
          $zkf =~ s/zkf//gi;
          my $user= $main::statistiek_gkd_instellingen->{ziekenfondsen}->{"$zkf_test"}->{as400_user};     	     #username as400
          my $pass=decrypt->new($main::statistiek_gkd_instellingen->{ziekenfondsen}->{"$zkf_test"}->{as400_paswoord});
          print "\n\nuser :$user\n\npas: $pass\n\n";
          my $dbh =connectdb->connect_as400 ($user,$pass,'airbus');
          ($statistiek->{$zkf},$statistiek->{totaal})= main->lees_history_gkd($dbh,$zkf,$Begin_datum,$Eind_datum,$statistiek->{totaal});
          connectdb->disconnect($dbh) if (defined $dbh);
        }
       excel->new($statistiek);
       print "\nEinde\n__________________\n";
 
    sub load_statistiek_gkd_instellingen  {
         my ($class,$file_name) =  @_;
         print "$file_name ->";
         $statistiek_gkd_instellingen = XMLin('P:\OGV\ASSURCARD_PROG\assurcard_settings_xml\statistiek_gkd_settings.xml');
          print "ingelezen\n";
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
    sub teksten_gkd {
    
          my $teksten;
         #settings $teksten->{periode} en $teksten->{verzekering} komen me van boven bepalen de periode en de verzekering voor de lay out
         print "agresso_zet_klant_in_settings_Teksten.xml->";
         $teksten = XMLin('P:\OGV\ASSURCARD_PROG\assurcard_settings_xml\zet_klant_in_agresso_settings_Teksten.xml');
         foreach my $nr (keys $teksten->{GKD_teksten}->{TABBLAD_GKD}->{tekst}) {
             push (@tekst_match,$teksten->{GKD_teksten}->{TABBLAD_GKD}->{tekst}->[$nr]);
         }
         print "ingelezen \n";
         return ($teksten);
        }
     sub load_as400_settings {
           my ($class,$file_name) =  @_;
           print "$file_name ->";
           $main::as400 = XMLin("$file_name");
           print "ingelezen\n"; 
     }
    sub lees_history_gkd {
         my ($class,$dbh,$zkf,$Begin_datum,$Eind_datum,$stat_tot) = @_;
         my $settings=settings->new($zkf);
         my $stat_zkf;        
         #1 A.ORG                 organization                    CHARACTER         3         
         #2 A.CONTACTID           contact id                       INTEGER           9        0 
         #3 A.TYPE                contact type 1:phone,2:email     SMALLINT          4        0     
         #4 A.TARGETTYPE          0=prospect, 1=member             SMALLINT          4        0 
         #5 A.TARGETID            prospect id or member id         DECIMAL          13        0
         #6 A.OFFICE              office manager                   SMALLINT          4        0 
         #7 A.SECTION                                               SMALLINT          4        0 
         #8 A.ACTION              1=creation,2=update,3=single c   SMALLINT          4        0 
         #9 A.COMMENT             manager comments                  VARCHAR        1024  
         #10 A.TECHVERSIONNUMBER                                   INTEGER           9  
         #11 A.TECHCREATIONUSER                                    VARCHAR          10 
         #12 A.TECHCREATIONDATE                                     TIMESTAMP        26  
         #13 A.TECHLASTUPDATEUSER                                    VARCHAR          10 
         #14 A.TECHLASTUPDATEDATE                          TIMESTAMP        26 
         #15 A.TECHORGANIZATION                             CHARACTER         3 
         #16 A.COMPLAINTCOMMENT    complaints comments      VARCHAR        1024 
         #17 A.IDMT                mut for fusion concern  SMALLINT          4
         # 1            2           3       4                   5           6       7       8           9                       10              11              12                          13                  14                          15
         # ORG       CONTACTID     TYPE  TARGETTYPE            TARGETID   OFFICE  SECTION   ACTION  COMMENT                 ECHVERSIONNUMBER  TECHCREATIONUSER  TECHCREATIONDATE            TECHLASTUPDATEUSER  TECHLASTUPDATEDATE           IDMT 
         #203        739,735        7           1     810,003,677,473        0      200        3   test 21092011                          0   HC                2011-09-21-12.43.58.000000  HC                  2011-09-21-13.05.57.000000   0                 
         #                                                                                                                                                      2011-09-21-17.10.35.000000
         my $maand;
         my $parser = DateTime::Format::Strptime->new(pattern => '%Y-%m-%d');
         my $parser1 = DateTime::Format::Strptime->new(pattern => '%Y%m%d');
         my $begin =$parser1->parse_datetime($Begin_datum);
         my $eerste_maand_begin =$parser1->parse_datetime($Begin_datum);             
         my $eerste_maand_einde = $parser1->parse_datetime($Begin_datum);
         $eerste_maand_einde = $eerste_maand_einde->add(months => 1);
         $eerste_maand_einde = $eerste_maand_einde->subtract(days => 1);       
         $maand->{1}->{begin}= $eerste_maand_begin->strftime('%Y-%m-%d');
         $maand->{1}->{einde}= $eerste_maand_einde->strftime('%Y-%m-%d');
         
         my $tweede_maand_begin =$parser1->parse_datetime($Begin_datum);
         $tweede_maand_begin = $tweede_maand_begin->add(months => 1);
         my $tweede_maand_einde = $parser1->parse_datetime($Begin_datum);
         $tweede_maand_einde = $tweede_maand_einde->add(months => 2);
         $tweede_maand_einde = $tweede_maand_einde->subtract(days => 1);       
         $maand->{2}->{begin}= $tweede_maand_begin->strftime('%Y-%m-%d');
         $maand->{2}->{einde}= $tweede_maand_einde->strftime('%Y-%m-%d');
                   
         my $derde_maand_begin =$parser1->parse_datetime($Begin_datum);
         $derde_maand_begin = $derde_maand_begin->add(months => 2);
         my $derde_maand_einde = $parser1->parse_datetime($Begin_datum);
         $derde_maand_einde = $derde_maand_einde->add(months => 3);
         $derde_maand_einde = $derde_maand_einde->subtract(days => 1);       
         $maand->{3}->{begin}= $derde_maand_begin->strftime('%Y-%m-%d');
         $maand->{3}->{einde}= $derde_maand_einde->strftime('%Y-%m-%d');
         
          
         my $vierde_maand_begin =$parser1->parse_datetime($Begin_datum);
         $vierde_maand_begin = $vierde_maand_begin->add(months => 3);
         my $vierde_maand_einde = $parser1->parse_datetime($Begin_datum);
         $vierde_maand_einde = $vierde_maand_einde->add(months => 4);
         $vierde_maand_einde = $vierde_maand_einde->subtract(days => 1);       
         $maand->{4}->{begin}= $vierde_maand_begin->strftime('%Y-%m-%d');
         $maand->{4}->{einde}= $vierde_maand_einde->strftime('%Y-%m-%d');
          
         my $vijfde_maand_begin =$parser1->parse_datetime($Begin_datum);
         $vijfde_maand_begin = $vijfde_maand_begin->add(months => 4);
         my $vijfde_maand_einde = $parser1->parse_datetime($Begin_datum);
         $vijfde_maand_einde = $vijfde_maand_einde->add(months => 5);
         $vijfde_maand_einde = $vijfde_maand_einde->subtract(days => 1);       
         $maand->{5}->{begin}= $vijfde_maand_begin->strftime('%Y-%m-%d');
         $maand->{5}->{einde}= $vijfde_maand_einde->strftime('%Y-%m-%d');
         
         
         my $zesde_maand_begin =$parser1->parse_datetime($Begin_datum);
         $zesde_maand_begin = $zesde_maand_begin->add(months => 5);
         my $zesde_maand_einde = $parser1->parse_datetime($Begin_datum);
         $zesde_maand_einde = $zesde_maand_einde->add(months => 6);
         $zesde_maand_einde = $zesde_maand_einde->subtract(days => 1);       
         $maand->{6}->{begin}= $zesde_maand_begin->strftime('%Y-%m-%d');
         $maand->{6}->{einde}= $zesde_maand_einde->strftime('%Y-%m-%d');
          
         my $zevende_maand_begin =$parser1->parse_datetime($Begin_datum);
         $zevende_maand_begin = $zevende_maand_begin->add(months => 6);
         my $zevende_maand_einde = $parser1->parse_datetime($Begin_datum);
         $zevende_maand_einde = $zevende_maand_einde->add(months => 7);
         $zevende_maand_einde = $zevende_maand_einde->subtract(days => 1);       
         $maand->{7}->{begin}= $zevende_maand_begin->strftime('%Y-%m-%d');
         $maand->{7}->{einde}= $zevende_maand_einde->strftime('%Y-%m-%d');
          
         my $achtste_maand_begin =$parser1->parse_datetime($Begin_datum);
         $achtste_maand_begin = $achtste_maand_begin->add(months => 7);
         my $achtste_maand_einde = $parser1->parse_datetime($Begin_datum);
         $achtste_maand_einde = $achtste_maand_einde->add(months => 8);
         $achtste_maand_einde = $achtste_maand_einde->subtract(days => 1);       
         $maand->{8}->{begin}= $achtste_maand_begin->strftime('%Y-%m-%d');
         $maand->{8}->{einde}= $achtste_maand_einde->strftime('%Y-%m-%d');
          
         my $negende_maand_begin =$parser1->parse_datetime($Begin_datum);
         $negende_maand_begin = $negende_maand_begin->add(months => 8);
         my $negende_maand_einde = $parser1->parse_datetime($Begin_datum);
         $negende_maand_einde = $negende_maand_einde->add(months => 9);
         $negende_maand_einde = $negende_maand_einde->subtract(days => 1);       
         $maand->{9}->{begin}= $negende_maand_begin->strftime('%Y-%m-%d');
         $maand->{9}->{einde}= $negende_maand_einde->strftime('%Y-%m-%d');
          
         my $tiende_maand_begin =$parser1->parse_datetime($Begin_datum);
         $tiende_maand_begin = $tiende_maand_begin->add(months => 9);
         my $tiende_maand_einde = $parser1->parse_datetime($Begin_datum);
         $tiende_maand_einde = $tiende_maand_einde->add(months => 10);
         $tiende_maand_einde = $tiende_maand_einde->subtract(days => 1);       
         $maand->{10}->{begin}= $tiende_maand_begin->strftime('%Y-%m-%d');
         $maand->{10}->{einde}= $tiende_maand_einde->strftime('%Y-%m-%d');
          
         my $elfde_maand_begin =$parser1->parse_datetime($Begin_datum);
         $elfde_maand_begin = $elfde_maand_begin->add(months => 10);
         my $elfde_maand_einde = $parser1->parse_datetime($Begin_datum);
         $elfde_maand_einde = $elfde_maand_einde->add(months => 11);
         $elfde_maand_einde = $elfde_maand_einde->subtract(days => 1);       
         $maand->{11}->{begin}= $elfde_maand_begin->strftime('%Y-%m-%d');
         $maand->{11}->{einde}= $elfde_maand_einde->strftime('%Y-%m-%d');
         
          
         my $twaalfde_maand_begin =$parser1->parse_datetime($Begin_datum);
         $twaalfde_maand_begin = $twaalfde_maand_begin->add(months => 11);
         my $twaalfde_maand_einde = $parser1->parse_datetime($Begin_datum);
         $twaalfde_maand_einde = $twaalfde_maand_einde->add(months => 12);
         $twaalfde_maand_einde = $twaalfde_maand_einde->subtract(days => 1);       
         $maand->{12}->{begin}= $twaalfde_maand_begin->strftime('%Y-%m-%d');
         $maand->{12}->{einde}= $twaalfde_maand_einde->strftime('%Y-%m-%d');
         foreach my $nr_maand (sort keys $maand) {
              my $checkbegin =  $maand->{$nr_maand}->{begin};
              my $checkeind = $maand->{$nr_maand}->{einde};
              my $sql =("SELECT COMMENT,TARGETID,TECHCREATIONDATE,TECHCREATIONUSER FROM $settings->{'gkd_hist_fil'} WHERE TECHCREATIONUSER = 'HOSI'
                   and (TECHCREATIONDATE BETWEEN date('$checkbegin') and date('$checkeind'))
                   ");
               my $sth = $dbh->prepare( $sql );
               $sth->execute();
               my @mijncomment =();       
               #my $test = $main::gkd_commentaar;
               my $statistiek;
              while(@mijncomment =$sth->fetchrow_array)  {
                 #print "@mijncomment \n";
                 if (defined $mijncomment[0] or $mijncomment[0] ne '') {
                     $stat_zkf->{"$checkbegin\_$checkeind"}->{$mijncomment[0]} +=1;
                     $stat_zkf->{totaal}->{$mijncomment[0]} +=1;
                     $stat_tot->{totaal}->{$mijncomment[0]} +=1;
                     $stat_tot->{"$checkbegin\_$checkeind"}->{$mijncomment[0]} +=1;
                    }                
                }
              
            }
         return ($stat_zkf,$stat_tot);
        }
package excel;
     use Win32::OLE;
     use Win32::OLE::Const 'Microsoft Excel';
     use Date::Manip::DM5;
     sub new {
        my ($self,$statistiek) = @_;      
        my $Excel = Win32::OLE->GetActiveObject('Excel.Application')
        	|| Win32::OLE->new('Excel.Application', 'Quit');
         $Excel->{'Visible'} = 0;  # toon wat je doet is 1
         my $sjabloon = $main::statistiek_gkd_instellingen->{statistiek_gkd_sjabloon};
         my $Book = $Excel->Workbooks->Open($sjabloon );
         my $sheet_teller = 1;
         foreach my  $zkf (sort keys $statistiek) {
              my $Sheet = $Book->Worksheets($sheet_teller);
              $Sheet->{Name} = "GKD $zkf";
              my $kolom_teller = 2;
              foreach my $periode (sort keys $statistiek->{totaal} ) {
                   my $inhoudcel= $Sheet->Cells(3,$kolom_teller);
                   my $titel = $periode;
                   $titel  =~ s/\_/\n/g;
                   $inhoudcel->{Value} = "$titel";
                   $kolom_teller +=1;
                }
              my $rij_teller = 5;
              foreach my $tekst (sort keys $statistiek->{totaal}->{totaal}) {
                 if ($statistiek->{totaal}->{totaal}->{$tekst} > 3) {
                      my $inhoudcel= $Sheet->Cells($rij_teller,1);
                      $inhoudcel->{Value} = "$tekst";
                      $kolom_teller = 2;
                      foreach my $periode (sort keys $statistiek->{totaal} ) {
                         $inhoudcel= $Sheet->Cells($rij_teller,$kolom_teller);
                         $inhoudcel->{Value} = $statistiek->{$zkf}->{$periode}->{$tekst};
                         $kolom_teller +=1;
                        }
                      $rij_teller +=1;
                    }
                }
              $sheet_teller += 1;
            }
         my $vandaag = ParseDate("today");
         $vandaag = substr ($vandaag,0,8);  # vandaag in YYYYMMDD
         $vandaag = sprintf "%04d-%02d-%02d",substr ($vandaag,0,4),substr ($vandaag,4,2),substr ($vandaag,6,2);
         my $path_to_files =$main::statistiek_gkd_instellingen->{statistiek_gkd_verslag};
         $Excel->ActiveWorkbook->SaveAs("$path_to_files\\$vandaag-GKD-statistiek.xls");
         $Excel->ActiveWorkbook->Close(1);
         $Excel->Quit();
         
     }