#!/usr/bin/perl -w
use strict;


package main;
     require "package_settings_prod.pl";
     require "package_cnnectdb_prod.pl";
     require 'package_maak_brief_prod.pl';
     use Date::Calc qw(Delta_Days);
     my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);
     our @maanden = ('januari','februari','maart','april','mei','juni','juli','augustus','september','oktober','november','december') ;
     our $maand_naam = $maanden[$mon];
     our $today_year = $year+1900;
     our $today_month = $mon+1;
     our $today_day=$mday;
     use XML::Simple;
     our $agresso_instellingen;
     our $brieven_instellingen;
     our $overzichts_mail = "Herinnerings brieven die moeten worden afgedrukt\n___________________________________________________________________________\n\n";
     my $dbh= sql_toegang_agresso->setup_mssql_connectie;
     sql_toegang_agresso->afxvmobreminded_replace_to_P($dbh);
     sql_toegang_agresso->afxvmobtoprint_replace_to_P($dbh);
     main->delfiles("D:\\OGV\\ASSURCARD_PROG\\programmas\\Brieven\\te_herpinten");
     main->load_agresso_setting('D:\OGV\ASSURCARD_PROG\assurcard_settings_xml\zet_klant_in_agresso_settings.xml');
     main->load_brieven_setting('D:\OGV\ASSURCARD_PROG\assurcard_settings_xml\\zet_klant_in_brieven_settings.xml');
     my $alternatieve_drive = $agresso_instellingen->{plaats_brieven_print_herinneringen};
     our $te_herinneren = sql_toegang_agresso->afxvmobtoremind_first_time($dbh,$alternatieve_drive);
    
     my $nr_old = "";
     our $brieven_aan_te_maken;
     our @mogelijke_ziekenfondsen;
     our $klant;
     foreach my $zkfnr (keys $agresso_instellingen->{verzekeringen}){
         $zkfnr =~ s/ZKF//i;
         push (@mogelijke_ziekenfondsen,$zkfnr);
     }
     eval {foreach my $nr (sort keys $te_herinneren) {}};
     if (!$@) {
          
          foreach my $nr (sort keys $te_herinneren) {
                my $agresso_nr= $te_herinneren->{$nr}->{'agresso_nr'};
                my $sjabloon= $te_herinneren->{$nr}->{'sjabloon'};
                my $wat_moet_binnen_gebracht = $te_herinneren->{$nr}->{'wat_moet_binnen_gebracht'};       #'wat_moet_binnen_gebracht' => $to_remind[2],
                my $datum_ingezet = $te_herinneren->{$nr}->{'datum_ingezet'};        #'datum_ingezet' => $to_remind[3],
                my $datum_eerste_her = $te_herinneren->{$nr}->{'datum_eerste_her'};       #'datum_eerste_her' => $to_remind[4],
                my $datum_eerste_her_geprint = $te_herinneren->{$nr}->{'datum_eerste_her_geprint'};       #'datum_eerste_her_geprint' => $to_remind[5],
                my $nrtest = $nr;
                $nrtest =~ s/-\d+$//;
                #$a_ref = \@a; 
                if ($nrtest eq $nr_old) {
                    if ($wat_moet_binnen_gebracht ne '') {
                        push (@{$brieven_aan_te_maken->{$nrtest}->{'wat_moet_binnen_gebracht'}},$wat_moet_binnen_gebracht);
                       }
                   }else {
                    $brieven_aan_te_maken->{$nrtest} = {
                        'agresso_nr' =>$agresso_nr,
                        'sjabloon' => $sjabloon,
                        'datum_ingezet' => $datum_ingezet,
                        'datum_eerste_her' => $datum_eerste_her,
                        'datum_eerste_her_geprint' => $datum_eerste_her_geprint,
                       };
                    if ($wat_moet_binnen_gebracht ne '') {
                        push (@{$brieven_aan_te_maken->{$nrtest}->{'wat_moet_binnen_gebracht'}},$wat_moet_binnen_gebracht);
                       }
                   }
                $nr_old =$nrtest;
                
               }
            foreach my $nr(sort keys $brieven_aan_te_maken) {
                my $agresso_nr= $brieven_aan_te_maken->{$nr}->{'agresso_nr'};
                my $sjabloon= $brieven_aan_te_maken->{$nr}->{'sjabloon'};
                my $datum_ingezet = $brieven_aan_te_maken->{$nr}->{'datum_ingezet'};         #'datum_ingezet' => $to_remind[3],
                my $jaar_ingezet = substr ($datum_ingezet,0,4);
                my $maand_ingezet = substr ($datum_ingezet,5,2);
                my $dag_ingezet = substr ($datum_ingezet,8,2);
                my $maand_ingezet_text  = $main::maanden[$maand_ingezet-1];
                my $datum_ingezet_text = "$dag_ingezet $maand_ingezet_text $jaar_ingezet";
                my $datum_eerste_her = $brieven_aan_te_maken->{$nr}->{'datum_eerste_her'};       #'datum_eerste_her' => $to_remind[4],
                my $datum_eerste_her_geprint = $brieven_aan_te_maken->{$nr}->{'datum_eerste_her_geprint'};       #'datum_eerste_her_geprint' => $to_remind[5],
                eval {foreach my $tekst (@{$brieven_aan_te_maken->{$nr}->{'wat_moet_binnen_gebracht'}}) {}};
                if (!$@){
                    my @wat_binnenbrengen;           
                    foreach my $tekst (@{$brieven_aan_te_maken->{$nr}->{'wat_moet_binnen_gebracht'}}) {
                        push (@wat_binnenbrengen,$tekst);
                        print "";
                       }
                     insert_eerste_herinnering_in_frame->new($sjabloon,$datum_ingezet,$datum_ingezet_text,@wat_binnenbrengen);
                   
                   }else {
                    #brief van vorige brief
                     insert_eerste_herinnering_in_frame->new($sjabloon,$datum_ingezet,$datum_ingezet_text);
                    print "";
                   }
                my $ok =  sql_toegang_agresso->afxvmobreminded_first_time($dbh,$agresso_nr,$sjabloon);
                print "$ok ->sql_toegang_agresso->afxvmobreminded_first_time($agresso_nr,$sjabloon)\n";
               }
     }
     
    
     print "";
     undef $te_herinneren;
     undef $brieven_aan_te_maken;
     $nr_old = "";
     $te_herinneren = sql_toegang_agresso->afxvmobtoremind_second_time($dbh,$alternatieve_drive);
     eval {foreach my $nr (sort keys $te_herinneren) {}};
     if (!$@) {
         foreach my $nr (sort keys $te_herinneren) {
                my $agresso_nr= $te_herinneren->{$nr}->{'agresso_nr'};
                my $sjabloon= $te_herinneren->{$nr}->{'sjabloon'};
                my $wat_moet_binnen_gebracht = $te_herinneren->{$nr}->{'wat_moet_binnen_gebracht'};       #'wat_moet_binnen_gebracht' => $to_remind[2],
                my $datum_ingezet = $te_herinneren->{$nr}->{'datum_ingezet'};        #'datum_ingezet' => $to_remind[3],
                my $datum_eerste_her = $te_herinneren->{$nr}->{'datum_tweede_her'};       #'datum_eerste_her' => $to_remind[4],
                my $datum_eerste_her_geprint = $te_herinneren->{$nr}->{'datum_tweede_her_geprint'};       #'datum_eerste_her_geprint' => $to_remind[5],
                my $nrtest = $nr;
                $nrtest =~ s/-\d+$//;
                 #$a_ref = \@a; 
                if ($nrtest eq $nr_old) {
                    if ($wat_moet_binnen_gebracht ne '') {
                        push (@{$brieven_aan_te_maken->{$nrtest}->{'wat_moet_binnen_gebracht'}},$wat_moet_binnen_gebracht);
                       }
                   }else {
                    $brieven_aan_te_maken->{$nrtest} = {
                        'agresso_nr' =>$agresso_nr,
                        'sjabloon' => $sjabloon,
                        'datum_ingezet' => $datum_ingezet,
                        'datum_tweede_her' => $datum_eerste_her,
                        'datum_tweede_her_geprint' => $datum_eerste_her_geprint,
                       };
                    if ($wat_moet_binnen_gebracht ne '') {
                        push (@{$brieven_aan_te_maken->{$nrtest}->{'wat_moet_binnen_gebracht'}},$wat_moet_binnen_gebracht);
                       }
                   }
                $nr_old =$nrtest;
                
               }
         foreach my $nr(sort keys $brieven_aan_te_maken) {
                my $agresso_nr= $brieven_aan_te_maken->{$nr}->{'agresso_nr'};
                my $sjabloon= $brieven_aan_te_maken->{$nr}->{'sjabloon'};
                my $datum_ingezet = $brieven_aan_te_maken->{$nr}->{'datum_ingezet'};         #'datum_ingezet' => $to_remind[3],
                my $jaar_ingezet = substr ($datum_ingezet,0,4);
                my $maand_ingezet = substr ($datum_ingezet,5,2);
                my $dag_ingezet = substr ($datum_ingezet,8,2);
                my $maand_ingezet_text  = $main::maanden[$maand_ingezet-1];
                my $datum_ingezet_text = "$dag_ingezet $maand_ingezet_text $jaar_ingezet";
                my $datum_eerste_her = $brieven_aan_te_maken->{$nr}->{'datum_tweede_her'};       #'datum_eerste_her' => $to_remind[4],
                my $datum_eerste_her_geprint = $brieven_aan_te_maken->{$nr}->{'datum_tweede_her_geprint'};       #'datum_eerste_her_geprint' => $to_remind[5],
                eval {foreach my $tekst (@{$brieven_aan_te_maken->{$nr}->{'wat_moet_binnen_gebracht'}}) {}};
                if (!$@){
                    my @wat_binnenbrengen;           
                    foreach my $tekst (@{$brieven_aan_te_maken->{$nr}->{'wat_moet_binnen_gebracht'}}) {
                        push (@wat_binnenbrengen,$tekst);
                        print "";
                       }
                    insert_tweede_herinnering_in_frame->new($sjabloon,$datum_ingezet,$datum_ingezet_text,@wat_binnenbrengen);
                   
                   }else {
                    #brief van vorige brief
                    insert_tweede_herinnering_in_frame->new($sjabloon,$datum_ingezet,$datum_ingezet_text);
                    print "";
                   }
                my $ok =  sql_toegang_agresso->afxvmobreminded_second_time($dbh,$agresso_nr,$sjabloon);
                print "";
            }
        }
     $te_herinneren = sql_toegang_agresso->afxvmobtonag($dbh);
    
     my $nag_mail = "\nMensen die niet reageren op hun brieven:\n";
     $nag_mail = $nag_mail."-------------------------------------------\n\n";
     $nag_mail = $nag_mail."agresso_nr -> sjabloon\n";
     eval {foreach my $nr (sort keys $te_herinneren) {}};
     if (!$@) {
         foreach my $nr (sort keys $te_herinneren) {
                my $agresso_nr= $te_herinneren->{$nr}->{'agresso_nr'};
                my $sjabloon= $te_herinneren->{$nr}->{'sjabloon'};
                $nag_mail = $nag_mail."$agresso_nr     -> $sjabloon\n";
            }
        }
     $nag_mail = $nag_mail."\n\n"."$main::overzichts_mail";
     nag_mail->new($nag_mail);
     sub load_agresso_setting  {
         my ($class,$file_name) =  @_;
         $agresso_instellingen = XMLin("$file_name");
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
     sub load_brieven_setting  {
         my ($class,$file_name) =  @_;
         $brieven_instellingen = XMLin("$file_name");
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
    sub delfiles {
        #haal de directorY
        my ($self,$dirtoempty)= @_;
        #print "\n dir delete $dirtoempty\n";
        my $extension_to_delete = ".*";
        opendir (DIR,"$dirtoempty");
        my @files = grep(/.*$extension_to_delete$/, readdir (DIR));
        #print "file @files\n";
        closedir (DIR);
        foreach my $file (@files){
          #print "@file\n";
          unlink "$dirtoempty\\$file";
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
     sub  afxvmobtoremind_first_time {
         my ($class,$dbh,$alternatieve_drive) = @_;
         my $client ='VMOB';
         my $attribute_id = 'A4';
         my $user_id = 'WEBSERV';
         my $To_Remind;
         $main::overzichts_mail = $main::overzichts_mail."\n\nBrieven die de eerste maal worden herinnerd\n___________________________________________________________\n";    
         my $sql =("SELECT dim_value,naam_sjabloon,wat_moet_binnen_gebracht,datum_ingezet,datum_eerste_her,datum_eerste_her_geprint FROM afxvmobtoremind
                   WHERE client = '$client' and datum_eerste_her_geprint = '' and datum_eerste_her <= getdate() order by dim_value");#and datum_eerste_her = $datum_vandaag 
         my $sth = $dbh->prepare($sql);
         $sth->execute();
             my $nr=0;
         while (my @to_remind = $sth->fetchrow_array) {
             my $datingezet = substr($to_remind[3],0,10);
             $datingezet =~ s/-//g;
             my $nr1="$to_remind[0]-$datingezet-$to_remind[1]-$nr";
             $to_remind[1] =~ s/^\w:/$alternatieve_drive/;
             $To_Remind->{$nr1} = {
                 'agresso_nr' => $to_remind[0],
                 'sjabloon' => $to_remind[1],
                 'wat_moet_binnen_gebracht' => $to_remind[2],
                 'datum_ingezet' => $to_remind[3],
                 'datum_eerste_her' => $to_remind[4],
                 'datum_eerste_her_geprint' => $to_remind[5],
                 };
             $nr += 1;
             $main::overzichts_mail = $main::overzichts_mail."$nr -> @to_remind\n";
             print "$nr -> @to_remind\n";
            }
         return ($To_Remind);
     }
     sub  afxvmobreminded_first_time {
         my ($class,$dbh,$agresso_nr,$sjabloon) = @_;
         my $client ='VMOB';
         my $attribute_id = 'A4';
         my $user_id = 'WEBSERV';
         $sjabloon =~ s/^\w://;
         my $updatethis = $dbh ->do("UPDATE afxvmobtoremind set datum_eerste_her_geprint = getdate() WHERE client = '$client' and dim_value=$agresso_nr
                                  and naam_sjabloon like '%$sjabloon'");
         return ($updatethis);
        }
     sub  afxvmobtoremind_second_time {
         my ($class,$dbh,$alternatieve_drive) = @_;
         my $client ='VMOB';
         my $attribute_id = 'A4';
         my $user_id = 'WEBSERV';
         my $To_Remind;
         my $sql =("SELECT dim_value,naam_sjabloon,wat_moet_binnen_gebracht,datum_ingezet,datum_tweede_her,datum_tweede_her_geprint FROM afxvmobtoremind
                   WHERE client = '$client' and datum_eerste_her_geprint != '' and datum_tweede_her_geprint = '' and datum_tweede_her<= getdate() order by dim_value");#and datum_eerste_her = $datum_vandaag 
         my $sth = $dbh->prepare($sql);
         $sth->execute();
             my $nr=0;
         $main::overzichts_mail = $main::overzichts_mail."\n\nBrieven die de tweede maal worden herinnerd\n___________________________________________________________\n";    
         while (my @to_remind = $sth->fetchrow_array) {
             my $datingezet = substr($to_remind[3],0,10);
             $datingezet =~ s/-//g;
             my $nr1="$to_remind[0]-$datingezet-$to_remind[1]-$nr";
             $to_remind[1] =~ s/^\w:/$alternatieve_drive/;
             $To_Remind->{$nr1} = {
                 'agresso_nr' => $to_remind[0],
                 'sjabloon' => $to_remind[1],
                 'wat_moet_binnen_gebracht' => $to_remind[2],
                 'datum_ingezet' => $to_remind[3],
                 'datum_tweede_her' => $to_remind[4],
                 'datum_tweede_her_geprint' => $to_remind[5],
                 };
             $nr += 1;
             $main::overzichts_mail = $main::overzichts_mail."$nr -> @to_remind\n";
             print "$nr1 -> @to_remind\n";
            }
         return ($To_Remind);
     }
     sub  afxvmobreminded_second_time {
         my ($class,$dbh,$agresso_nr,$sjabloon) = @_;
         my $client ='VMOB';
         my $attribute_id = 'A4';
         my $user_id = 'WEBSERV';
         $sjabloon =~ s/^\w://;
         my $updatethis = $dbh ->do("UPDATE afxvmobtoremind set datum_tweede_her_geprint = getdate() WHERE client = '$client' and dim_value=$agresso_nr
                                  and naam_sjabloon like '%$sjabloon'");
         return ($updatethis);
        }
     sub afxvmobtonag {
         my ($class,$dbh,) = @_;
         my $client ='VMOB';
         my $attribute_id = 'A4';
         my $user_id = 'WEBSERV';
         my $To_Remind;
         my $sql =("SELECT dim_value,naam_sjabloon,wat_moet_binnen_gebracht,datum_ingezet,start_nagging_datum FROM afxvmobtoremind
                   WHERE client = '$client' and datum_eerste_her_geprint != '' and datum_tweede_her_geprint != '' and start_nagging_datum <= getdate() order by dim_value");#and datum_eerste_her = $datum_vandaag 
         my $sth = $dbh->prepare($sql);
         $sth->execute();
             my $nr=0;
         while (my @to_remind = $sth->fetchrow_array) {
             my $datingezet = substr($to_remind[3],0,10);
             $datingezet =~ s/-//g;
             my $nr1="$to_remind[0]-$datingezet-$to_remind[1]-$nr";
             $To_Remind->{$nr1} = {
                 'agresso_nr' => $to_remind[0],
                 'sjabloon' => $to_remind[1],
                 'wat_moet_binnen_gebracht' => $to_remind[2],
                 'datum_ingezet' => $to_remind[3],
                 'start_nagging_datum' => $to_remind[4],
                 
                 };
             $nr += 1;
             print "$nr -> @to_remind\n";
            }
         return ($To_Remind);
        }
     sub afxvmobreminded_replace_to_P {
        my ($class,$dbh) = @_;
        my $updatethis = $dbh ->do("UPDATE afxvmobtoremind set naam_sjabloon = replace( naam_sjabloon,'W:','P:') where naam_sjabloon like 'W:%' ");
        return ($updatethis);
     }
     sub afxvmobtoprint_replace_to_P {
           my ($class,$dbh) = @_;
           my $updatethis = $dbh ->do("UPDATE afxvmobtoprint set naam_sjabloon = replace( naam_sjabloon,'W:','P:') where naam_sjabloon like 'W:%' ");
           return ($updatethis);
     }
package insert_eerste_herinnering_in_frame ;
     use OpenOffice::OODoc;
     use OpenOffice::OODoc::Meta;
     use OpenOffice::OODoc::Styles;
     use File::Copy;
     sub new {
         my ($self,$brief,$dat_oorspronk_brief,$dat_oorspronk_brief_tekst,@wat_binnenbrengen) = @_;
         my $printer = $main::agresso_instellingen->{printer_herineringen};
         my $home_dir = "$ENV{USERPROFILE}"  ;
         unlink "$home_dir\\herinner-brief.odt";       
         my $home_file = "$home_dir\\herinner-brief.odt";
         my $home_file1 = "$home_dir\\herinner-brief1.odt";
         workingDirectory($home_dir) ;
         #my $test = workingDirectory;
         my $brief1=$brief;
         $brief1 =~ s%\\%/%g;
         if (-e $brief) {
              print "bestaat->$brief\n";
              copy ($brief  => $home_file);
              print "home-file->$home_file\n";
              if (-e $home_file) {                
              }else {
                sleep (5)
              }
              if (-e $home_file) {     
                my $doc = ooDocument(file =>  "$home_file");     
                my $element =  $doc->getFrameElement('Plaats_datum');
                my $text_plaats_datum =  $doc->getFlatText($element);
                my $filter = "$text_plaats_datum";
                my $result = $doc->selectTextContent($filter, "Aalst, $main::today_day $main::maand_naam $main::today_year");
                $element =  $doc->getFrameElement('Herinnering');     
                #create the style
                #$doc->importFontDeclaration( '<style:font-face ' . 'style:name="Comic Sans MS" ' . 'svg:font-family="Comic Sans MS"/>' );
                #$doc->updateStyle( 'Frame-inhoud', properties => {-area => 'Speciale opmaakprofielen','style:font-name' => 'Comic Sans MS','fo:font-size' => '12pt'} ) or print "kan stijl niet aanpassen\n";
                
                # declare the font used by the style
                # create the needed style
                $doc->importFontDeclaration( '<style:font-face ' . 'style:name="Comic Sans MS" ' . 'svg:font-family="Comic Sans MS"/>' );
               
                $doc -> getStyleElement("Standard");
                #we nemen een style die bestaat veranderen het font want een nieuw font creeren werkt niet versie 1.3
                #$doc->createStyle( "ComicMS11", family => 'frame', parent => "Standard", properties => {'style:font-name' => 'Comic Sans MS', 'fo:font-size' => '12pt' } );
                $doc-> updateStyle ("P1",properties => {-area => 'text', 'style:font-name' => 'Comic Sans MS', 'fo:font-size' => '10pt', 'fo:font-weight' => 'bold' } );
                # my @styles = $doc->getAutoStyleList();
                my $paragraph = $doc->createParagraph( "$main::agresso_instellingen->{herinneringen_tekst} $dat_oorspronk_brief_tekst","P1");
                #$doc-> updateStyle ("Standard",properties => { -area => 'text', 'style:font-name' => 'Comic Sans MS', 'fo:font-size' => '10pt' } );
                $doc->setTextBoxContent($element, $paragraph);
                my @styles = $doc->getAutoStyleList();
                $filter = "dat_oorspronk_brief";
                $result = $doc->selectTextContent($filter, "$dat_oorspronk_brief");
                #print "stop\n";
                #vervang rijen       
                
                my ($rows, $columns) = $doc->getTableSize("wat_binnenbrengen");
                for (my $rijenteller =0;$rijenteller < $rows;$rijenteller +=1) {
                    $doc->deleteRow("wat_binnenbrengen",1);                 
                   }
                eval {foreach my $item (@wat_binnenbrengen) {}};
                if (!$@) {            
                    my $rijenteller =1;
                    my $cell;
                    foreach my $wat (@wat_binnenbrengen) {
                        $doc->appendRow("wat_binnenbrengen");
                        $cell = $doc->getCell("wat_binnenbrengen",$rijenteller, 0);
                        $doc->cellValue("wat_binnenbrengen",$rijenteller,0,$wat);
                        $rijenteller +=1;
                       }
                   }
                
               
                my $brief_nieuw_file_naam = $brief ;
                my $filedat = "$main::today_day\-$main::today_month\-$main::today_year";
                $brief_nieuw_file_naam =~ s/\d{1,2}-\d{1,2}-\d{4}\.\d{1,2}u\d{1,2}/$filedat\.07u30/;
                $brief_nieuw_file_naam =~  s/_her\d+/_h1/;
                my $brief_te_herprinten =$brief_nieuw_file_naam;        
                my $oude_locatie = $main::agresso_instellingen->{plaats_brieven};
                $oude_locatie =~  s/\\/\\\\/g;
                my $nieuwe_locatie = $main::agresso_instellingen->{plaats_brieven_cache};
                $nieuwe_locatie =~  s/\\/\\\\/g;
                $brief_nieuw_file_naam =~  s%$oude_locatie%$nieuwe_locatie%;
                $brief_te_herprinten =~  s%$oude_locatie%%;
                $doc-> save;
                #$doc-> save("$brief_nieuw_file_naam");
                $doc-> dispose;
                copy ($home_file  => $brief_nieuw_file_naam);
                copy ($home_file  => "D:\\OGV\\ASSURCARD_PROG\\programmas\\Brieven\\te_herpinten\\$brief_te_herprinten");      
                my $OO_instpath = &dir__OO;
                $OO_instpath =~  s/\\/\\\\/g;
                print "$OO_instpath\\program\\swriter.exe, -norestore,-headless,-pt,+ $printer,+ $home_file\n";
                $main::overzichts_mail = $main::overzichts_mail."$OO_instpath\\program\\swriter.exe, -norestore,-headless,-pt,+ $printer,+ $brief_nieuw_file_naam\n";
                #traagheid netwerk system(1,"$OO_instpath\\program\\swriter.exe", '-norestore','-headless','-pt',+ $printer,+ $brief_nieuw_file_naam);#, '-norestore','-headless','-pt',+ $printer,+ "$brief_nieuw_file_naam"); #,'-pt',+ $printer,+ "$brief_nieuw_file_naam"
                system(1,"$OO_instpath\\program\\swriter.exe", '-norestore','-headless','-pt',+ $printer,+ $home_file);
                $brief_nieuw_file_naam  =~ s/cache\\/cache\\\\/;
                #my $home_dir = "$ENV{USERPROFILE}"  ;
                #unlink "$home_dir\\herinner-brief.odt";       
                #my $home_file = "$home_dir\\herinner-brief.odt";
                #copy ($brief_nieuw_file_naam  => $home_file);
                #print "$OO_instpath\\program\\swriter.exe, -norestore,-headless,-pt,+ $printer,+ $home_file\n";
                #system(1,"$OO_instpath\\program\\swriter.exe", '-norestore','-headless','-pt',+ $printer,+ $home_file);#, '-norestore','-headless','-pt',+ $printer,+ "$brief_nieuw_file_naam"); #,'-pt',+ $printer,+ "$brief_nieuw_file_naam"
                sleep (5);
              }else {
                 print " home file $home_file -> bestaat niet !!!!!! -> NIETS GEDAAN !!!-> $brief\n";
                 $main::overzichts_mail = $main::overzichts_mail."home file $home_file -> bestaat niet !!!!!! -> NIETS GEDAAN !!!-> brief\n"
              }
                print "";
         }else {
             print "\nbestaat niet ->$brief\--\n";
             print "testen op->$brief1\--\n";
             print "--$brief1\--bestaat\n" if (-e $brief1);
             copy ($brief  => $home_file);
             copy ($brief1  => $home_file1);
             $main::overzichts_mail = $main::overzichts_mail."\ndocument bestaat niet -> $brief\n";
             
             #die;
         }
         
        
        }
     
   sub dir__OO {
         my $dir = "c:\\program files (x86)";
         my $OO_dir ="";
         if (-d $dir) {
                opendir(DIR, $dir);
                my @files = readdir(DIR);
                for my $file (@files) {
                       if ($file =~ m/Openoffice.org/i) {
                          print "$file \n";
                          $OO_dir ="$dir\\$file" if (-e "$dir\\$file\\program\\soffice.exe");
                        
                         }
                       if ($file =~ m/Openoffice/i) {
                           print "$file \n";
                           $OO_dir ="$dir\\$file" if (-e "$dir\\$file\\program\\soffice.exe");
                       } 
                    }
            }    
         if ($OO_dir eq '') {
                $dir = "c:\\Program Files";                
                opendir(DIR, $dir);               
                my @files = readdir(DIR);
                for my $file (@files) {
                     if ($file =~ m/Openoffice.org/i) {
                         print "$file \n";
                         $OO_dir ="$dir\\$file" if (-e "$dir\\$file\\program\\soffice.exe");
                        }
                     if ($file =~ m/Openoffice/i) {
                                print "$file \n";
                                $OO_dir ="$dir\\$file" if (-e "$dir\\$file\\program\\soffice.exe");
                        } 
                    }
            }    
        print "\n________________\n$OO_dir\n___________\n";
        #$OO_dir =~ s/ /\\ /g;
        return ($OO_dir);
       }  

package insert_tweede_herinnering_in_frame ;
     use OpenOffice::OODoc;
     use OpenOffice::OODoc::Meta;
     use OpenOffice::OODoc::Styles;
     use File::Copy;
     sub new {
         my ($self,$brief,$dat_oorspronk_brief,$dat_oorspronk_brief_tekst,@wat_binnenbrengen) = @_;
         my $home_dir = "$ENV{USERPROFILE}"  ;
         unlink "$home_dir\\herinner-brief.odt";       
         my $home_file = "$home_dir\\herinner-brief.odt";
         my $home_file1 = "$home_dir\\herinner-brief1.odt";
         workingDirectory($home_dir) ;
         my $brief1=$brief;
         $brief1 =~ s%\\%/%g;
         if (-e $brief) {
                print "bestaat->$brief\n";
                copy ($brief  => $home_file);
                #die;
                if (-e $home_file) {
                    
                }else {
                   sleep(5);
                }
                if (-e $home_file) {
                    my $printer = $main::agresso_instellingen->{printer_herineringen};
                    my $doc = ooDocument(file =>  "$home_file");     
                    my $element =  $doc->getFrameElement('Plaats_datum');
                    my $text_plaats_datum =  $doc->getFlatText($element);
                    my $filter = "$text_plaats_datum";
                    my $result = $doc->selectTextContent($filter, "Aalst, $main::today_day $main::maand_naam $main::today_year");
                    $element =  $doc->getFrameElement('Herinnering');     
                    #create the style
                    #$doc->importFontDeclaration( '<style:font-face ' . 'style:name="Comic Sans MS" ' . 'svg:font-family="Comic Sans MS"/>' );
                    #$doc->updateStyle( 'Frame-inhoud', properties => {-area => 'Speciale opmaakprofielen','style:font-name' => 'Comic Sans MS','fo:font-size' => '12pt'} ) or print "kan stijl niet aanpassen\n";
                    
                    # declare the font used by the style
                    # create the needed style
                    $doc->importFontDeclaration( '<style:font-face ' . 'style:name="Comic Sans MS" ' . 'svg:font-family="Comic Sans MS"/>' );
                   
                    $doc -> getStyleElement("Standard");
                    #we nemen een style die bestaat veranderen het font want een nieuw font creeren werkt niet versie 1.3
                    #$doc->createStyle( "ComicMS11", family => 'frame', parent => "Standard", properties => {'style:font-name' => 'Comic Sans MS', 'fo:font-size' => '12pt' } );
                    $doc-> updateStyle ("P1",properties => {-area => 'text', 'style:font-name' => 'Comic Sans MS', 'fo:font-size' => '10pt', 'fo:font-weight' => 'bold' } );
                    # my @styles = $doc->getAutoStyleList();
                    my $paragraph = $doc->createParagraph( "$main::agresso_instellingen->{tweede_herinneringen_tekst} $dat_oorspronk_brief_tekst","P1");
                    #$doc-> updateStyle ("Standard",properties => { -area => 'text', 'style:font-name' => 'Comic Sans MS', 'fo:font-size' => '10pt' } );
                    $doc->setTextBoxContent($element, $paragraph);
                    my @styles = $doc->getAutoStyleList();
                    $filter = "dat_oorspronk_brief";
                    $result = $doc->selectTextContent($filter, "$dat_oorspronk_brief");
                    #print "stop\n";
                    #vervang rijen
                    my ($rows, $columns) = $doc->getTableSize("wat_binnenbrengen");
                    for (my $rijenteller =0;$rijenteller < $rows;$rijenteller +=1) {
                        $doc->deleteRow("wat_binnenbrengen",1);                 
                       }
                    eval {foreach my $item (@wat_binnenbrengen) {}};
                    if (!$@) {            
                        my $rijenteller =1;
                        my $cell;
                        foreach my $wat (@wat_binnenbrengen) {
                            $doc->appendRow("wat_binnenbrengen");
                            $cell = $doc->getCell("wat_binnenbrengen",$rijenteller, 0);
                            $doc->cellValue("wat_binnenbrengen",$rijenteller,0,$wat);
                            $rijenteller +=1;
                           }
                       }
                        
                    my $brief_nieuw_file_naam = $brief ;
                    my $filedat = "$main::today_day\-$main::today_month\-$main::today_year";
                    #$brief_nieuw_file_naam =~ s/\d{1,2}-\d{1,2}-\d{4}\.\d{1,2}u\d{1,2}/$filedat/;
                    $brief_nieuw_file_naam =~ s/\d{1,2}-\d{1,2}-\d{4}\.\d{1,2}u\d{1,2}/$filedat\.07u30/;
                    $brief_nieuw_file_naam =~  s/_her\d+/_h2/;
                    my $brief_te_herprinten =$brief_nieuw_file_naam;                
                    my $oude_locatie = $main::agresso_instellingen->{plaats_brieven};
                    $oude_locatie =~  s/\\/\\\\/g;
                    my $nieuwe_locatie = $main::agresso_instellingen->{plaats_brieven_cache};
                    $nieuwe_locatie =~  s/\\/\\\\/g;
                    $brief_nieuw_file_naam =~  s%$oude_locatie%$nieuwe_locatie%;
                    $brief_te_herprinten =~  s%$oude_locatie%%;
                    $doc-> save;
                    #$doc-> save("$brief_nieuw_file_naam");
                    $doc-> dispose;
                    copy ($home_file  => $brief_nieuw_file_naam);
                    copy ($home_file  => "D:\\OGV\\ASSURCARD_PROG\\programmas\\Brieven\\te_herpinten\\$brief_te_herprinten");
                    my $OO_instpath = &dir__OO;
                    $OO_instpath =~  s/\\/\\\\/g;
                    print "$OO_instpath\\program\\swriter.exe, -norestore,-headless,-pt,+ $printer,+ $home_file\n";
                    $main::overzichts_mail = $main::overzichts_mail."$OO_instpath\\program\\swriter.exe, -norestore,-headless,-pt,+ $printer,+ $brief_nieuw_file_naam\n";
                    system(1,"$OO_instpath\\program\\swriter.exe", '-norestore','-headless','-pt',+ $printer,+ $home_file);             #, '-norestore','-headless','-pt',+ $printer,+ "$brief_nieuw_file_naam"); #,'-pt',+ $printer,+ "$brief_nieuw_file_naam"
                    
                    $brief_nieuw_file_naam  =~ s/cache\\/cache\\\\/;
                    #my $home_dir = "$ENV{USERPROFILE}"  ;
                    #unlink "$home_dir\\herinner-brief.odt";       
                    #my $home_file = "$home_dir\\herinner-brief.odt";
                    #copy ($brief_nieuw_file_naam  => $home_file);
                    #print "$OO_instpath\\program\\swriter.exe, -norestore,-headless,-pt,+ $printer,+ $home_file\n";
                    #system(1,"$OO_instpath\\program\\swriter.exe", '-norestore','-headless','-pt',+ $printer,+ $home_file);#, '-norestore','-headless','-pt',+ $printer,+ "$brief_nieuw_file_naam"); #,'-pt',+ $printer,+ "$brief_nieuw_file_naam"
                    #system(1,"$OO_instpath\\program\\swriter.exe", '-norestore','-headless','-pt',+ $printer,+ $home_file);
                    sleep (5);
                    print "";
                    #system(1,"$instpath\\program\\swriter.exe", '-norestore','-headless','-pt',+ $printer,
                    #   + $printfilename);
                }else {
                 print " home file $home_file -> bestaat niet !!!!!! -> NIETS GEDAAN !!!-> $brief\n";
                 $main::overzichts_mail = $main::overzichts_mail."home file $home_file -> bestaat niet !!!!!! -> NIETS GEDAAN !!!-> brief\n"
                }
            }else {
             print "\nbestaat niet ->$brief\--\n";
             print "testen op->$brief1\--\n";
             print "--$brief1\--bestaat\n" if (-e $brief1);
             $main::overzichts_mail = $main::overzichts_mail."\ndocument bestaat niet -> $brief\n";
              print "\nbestaat niet ->$brief\ngetest op->$brief1\n";
             copy ($brief  => $home_file);
             copy ($brief1  => $home_file1);
             $main::overzichts_mail = $main::overzichts_mail."\ndocument bestaat niet -> $brief\n";
             #die;
            }
        }
     sub dir__OO {
         my $dir = "c:\\program files (x86)";
         my $OO_dir ="";
         if (-d $dir) {
                opendir(DIR, $dir);
                my @files = readdir(DIR);
                for my $file (@files) {
                       if ($file =~ m/Openoffice.org/i) {
                          print "$file \n";
                          $OO_dir ="$dir\\$file" if (-e "$dir\\$file\\program\\soffice.exe");
                        
                         }
                       if ($file =~ m/Openoffice/i) {
                           print "$file \n";
                           $OO_dir ="$dir\\$file" if (-e "$dir\\$file\\program\\soffice.exe");
                       } 
                    }
            }    
         if ($OO_dir eq '') {
                $dir = "c:\\Program Files";                
                opendir(DIR, $dir);               
                my @files = readdir(DIR);
                for my $file (@files) {
                     if ($file =~ m/Openoffice.org/i) {
                         print "$file \n";
                         $OO_dir ="$dir\\$file" if (-e "$dir\\$file\\program\\soffice.exe");
                        }
                     if ($file =~ m/Openoffice/i) {
                                print "$file \n";
                                $OO_dir ="$dir\\$file" if (-e "$dir\\$file\\program\\soffice.exe");
                        } 
                    }
            }    
        print "\n________________\n$OO_dir\n___________\n";
        #$OO_dir =~ s/ /\\ /g;
        return ($OO_dir);
       }  
    
package nag_mail;
     use Net::SMTP;
     use Date::Manip::DM5 ;
     sub new {
         my ($self,$nag_mail) = @_;
         #print "mail-start\n";
         my $aan = $agresso_instellingen->{mail_verslag_naar};
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
             $smtp->datasend("Subject: Mensen die niet reageren op hun herinneringen $vandaag");
             $smtp->datasend("\n");
             $smtp->datasend("$nag_mail\nvriendelijke groeten\nHarry Conings");
             $smtp->dataend;
             $smtp->quit;
             print "mail aan $geadresseerde  gezonden\n";
            }
        }

