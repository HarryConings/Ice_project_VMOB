#!/usr/bin/perl -w
require 'Decryp_Encrypt_MI.pl';
use strict;

package maak_brief;

use DBD::ODBC;
use DBI;
use Win32;
use Date::Manip::DM5;
use Date::Calc qw(:all);
use DateTime::Format::Strptime;
use DateTime;
use OpenOffice::OODoc;
use OpenOffice::OODoc::Document;
use OpenOffice::OODoc::File;
use OpenOffice::OODoc::Image;
use OpenOffice::OODoc::Manifest;
use OpenOffice::OODoc::Text;
use OpenOffice::OODoc::XPath;
use OpenOffice::OODoc::Meta ;
use Barcode::Code128;
use File::Copy;
use Wx qw[:everything];
use base qw(Wx::Frame);
use Wx::Locale gettext => '_T';
my $old_charset = odfLocalEncoding(); #versie 5.2 charset utf8 
odfLocalEncoding('iso-8859-15');  #versie 5.2

use vars qw(%oodoc_variabelen);
use vars qw(%settings);
our $personen_zelfdedoss;
our $personen_zelfdeadres;
our $persoon_bestaande;
#sub dir__OO {
#    my $dir = "c:\\Program Files";
#    my $OO_dir ="";
#    opendir(DIR, $dir);
#    my @files = readdir(DIR);
#    for my $file (@files) {
#       if ($file =~ m/Openoffice.org/i) {
#	  print "$file \n";
#	  $OO_dir ="$dir\\$file";
#         }
#      }
#    if ($OO_dir eq '') {
#       $dir = "c:\\program files (x86)";
#       opendir(DIR, $dir);
#       my @files = readdir(DIR);
#       for my $file (@files) {
#          if ($file =~ m/Openoffice.org/i) {
#             print "$file \n";
#             $OO_dir ="$dir\\$file";
#            }
#         }
#      }
#    print "______________________________\n\n$OO_dir\n\n_______________________________\n";
#    return ($OO_dir);
#   }
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
sub maak_oodoc_variabelen{
     my ($class,$ext_nr,$rijksregisternummer,$zkf,$verz_doorgeef,$contract_nr,$sjabloon,$moet_geprint,$printer,$pdf_naar_agresso,$bestaat_in_xml,$popup,@wat_binnenbrengen) = @_;
     $persoon_bestaande = ();
     my @naam = ();
     my @adres = ();
     my @postadres = ();
     my @cg1cg2 = ();       
     #&lees_uit_mob_gegevens($rijksregisternummer);    
     #my $onstlagcode =shift @_;
     #my $detail_ontslagcode =shift @_;
     #my $ontslag_datum = shift @_;
     #my $aansluitingscode = shift @_;
     #my $detail_aansluitingscode =shift @_;
     #my $aansluiting_datum = shift @_;
     #my $nummer_dossier = shift @_;
     my $gebruikersnaam = &get_windows_user;;
     my $geen_path = 1; #voor onslag en aansluitingsbrieven
     #my $briefverz =shift @_;
     #my $verzekering ='';
     (my $alle_verzekeringen, my $aantal_verzekeringen )=&alle_verzekeringen;    
     #my $bolean_wachttijd  ='';
     my  @hospiplan_051_ambuplan_rek_nr=();
     my  @hospiplan_061_rek_nr =();
     my  @ambuplan_063_rek_nr =();
     my  @hospiplus_052_ambuplus_rek_nr=();
     my  @hospiplus_062_rek_nr=();
     my  @ambuplus_064_rek_nr=();
     my  @hospiforfait_rek_nr=();
     my  @hospicontinue_rek_nr=();
     my $bestaandaandoening1 = "";
     my $bestaandaandoening2 = "";
     my $bestaandaandoening3 = "";
     my $bestaandaandoening4 = "";
     my $bestaandaandoening5 = "";
     my $bestaandaandoening1_duur = "";
     my $bestaandaandoening2_duur = "";
     my $bestaandaandoening3_duur = "";
     my $bestaandaandoening4_duur = "";
     my $bestaandaandoening5_duur = "";
     my $ernstigeziekte1 = "";
     my $ernstigeziekte2 = "";
     my $ernstigeziekte3 = "";
     my $ernstigeziekte4 = "";
     my $ernstigeziekte5 = "";
     my $info_text = '';
     my $verzekering = '';
     my $naamgeslacht ='';
     
     my $vandaag = ParseDate("today");
     $vandaag = substr ($vandaag,0,8);  # vandaag in YYYYMMDD
     my $vandaag_slashes = substr($vandaag,6,2)."/".substr($vandaag,4,2)."/".substr($vandaag,0,4);
     my $parser1 = DateTime::Format::Strptime->new(pattern => '%d/%m/%Y');
     my $parser = DateTime::Format::Strptime->new(pattern => '%d-%m-%Y');
     (my $sec,my $min,my $hour,my $mday,my $mon,my $year,my $wday,my $yday,my $isdst)=localtime(time);
      my $filedat = sprintf "%4d-%02d-%02d-%02du%02d",$year+1900,$mon+1,$mday,$hour,$min,$sec;
      my @maanden = ('januari','februari','maart','april','mei','juni','juli','augustus','september','oktober','november','december') ;
      my $maand_naam = $maanden[$mon];
      my $jaar_getal = $year+1900;
      my $maand_getal = $mon+1;
     my $uurfile ="$hour"."u"."$min"; 
     my $man_vrouw  = substr ($main::klant->{Rijksreg_Nr},8,1) % 2; #man is 1 vrouw = 0
     $naamgeslacht = "man" if $man_vrouw == 1;
     $naamgeslacht = "vrouw" if $man_vrouw == 0;
     my $H_aan_spreek= '';
     my $aan_spreek= '';
     $H_aan_spreek = "Heer" if $man_vrouw == 1;
     $H_aan_spreek = "Mevrouw" if $man_vrouw == 0;
     $aan_spreek = "heer" if $man_vrouw == 1;
     $aan_spreek = "mevrouw" if $man_vrouw == 0;
     my $h_h = '';
     my $h_ar = '';
     $h_h = "haar" if $man_vrouw == 0;
     $h_h = "hem" if $man_vrouw == 1;
     $h_ar = "haar" if $man_vrouw == 0;
     $h_ar = "zijn" if $man_vrouw == 1;
     my $naam_uc = uc $main::klant->{naam};
     my $lijn_v = '';
     my $domi_adres_lijn1 ='';
     my $domi_adres_lijn2 = '';
     my $domi_adres_lijn3 = '';
     my $post_adres_lijn1 ='';
     my $post_adres_lijn2 = '';
     my $post_adres_lijn3 = '';
     my $landecode_v = '';
     my $brief_adres_lijn1 ='';
     my $brief_adres_lijn2 = '';
     my $brief_adres_lijn3 = '';
     my $brief_adres_lijn4 = '';
     my $woonplaats = '';
     my $aansluitings_datum = '';
     my $eind_datum = '';
     my $wacht_datum ='';
     my $aanvangsdatum ='';
     my $aanvangs_datum ='';
     $verzekering ='HospiPlus & AmbuPlus' if  (uc $verz_doorgeef eq 'HOSPIPLUS_AMBUPLUS');
     $verzekering ='HospiPlus'  if (uc $verz_doorgeef eq 'HOSPIPLUS') ;
     $verzekering ='AmbuPlus' if ($verz_doorgeef eq 'AMBUPLUS') ;
     $verzekering ='HospiPlan & AmbuPlan'  if ($verz_doorgeef eq 'HOSPIPLAN_AMBUPLAN');
     $verzekering ='HospiPlan'  if ($verz_doorgeef eq 'HOSPIPLAN') ;
     $verzekering ='AmbuPlan' if ($verz_doorgeef eq 'AMBUPLAN') ;                 
     $verzekering ='HospiForfait' if ($verz_doorgeef =~ m/HOSPIFORFAIT/) ;
     $verzekering ='HospiContinu' if ($verz_doorgeef eq 'HOSPICONTINU') ;
     $verzekering ='MaxiPlan' if (uc $verz_doorgeef eq 'MAXIPLAN') ;
     $verzekering ='TandPlus' if (uc $verz_doorgeef eq 'TANDPLUS') ;
     $lijn_v = "DE HEER $naam_uc" if $man_vrouw == 1;
     $lijn_v = "MEVROUW $naam_uc" if $man_vrouw == 0;
     #my $test = $main::klant;
     eval {my $bestaat = $main::klant->{contracten}->[0]->{contract_nr}};
     if (!$@) {
       if ($contract_nr) {
             foreach my $nr (sort keys $main::klant->{contracten}) {
                 if ($main::klant->{contracten}->[$nr]->{contract_nr} == $contract_nr and uc $main::klant->{contracten}->[$nr]->{naam} eq uc $verz_doorgeef) {
                     if ($aansluitings_datum ne '') {
                         my ($ddn,$mmn,$yyyyn) = split /-/,$main::klant->{contracten}->[$nr]->{startdatum};
                         my ($ddo,$mmo,$yyyyo) = split /-/,$aansluitings_datum;
                         my $new= $yyyyn*10000+$mmn*100+$ddn;
                         my $old = $yyyyo*10000+$mmo*100+$ddo;
                         if ($new > $old) {
                             $aansluitings_datum = $main::klant->{contracten}->[$nr]->{startdatum};
                             $eind_datum =  $main::klant->{contracten}->[$nr]->{einddatum};
                             $wacht_datum = $main::klant->{contracten}->[$nr]->{wachtdatum};
                             $aanvangsdatum = $parser->parse_datetime($wacht_datum);
                             $aanvangsdatum = $aanvangsdatum->add(days => 1);
                             $aanvangs_datum = $aanvangsdatum->strftime('%d/%m/%Y');
                            }
                        }else {
                         $aansluitings_datum = $main::klant->{contracten}->[$nr]->{startdatum};
                         $eind_datum =  $main::klant->{contracten}->[$nr]->{einddatum};
                         $wacht_datum = $main::klant->{contracten}->[$nr]->{wachtdatum};
                         $aanvangsdatum = $parser->parse_datetime($wacht_datum);
                         $aanvangsdatum = $aanvangsdatum->add(days => 1);
                         $aanvangs_datum = $aanvangsdatum->strftime('%d/%m/%Y'); 
                        }
                    }
                }
            }else {
                 foreach my $nr (sort keys $main::klant->{contracten}) {
                     if ($main::klant->{contracten}->[$nr]->{contract_nr}) {
                         $aansluitings_datum = $main::klant->{contracten}->[$nr]->{startdatum};
                         $eind_datum =  $main::klant->{contracten}->[$nr]->{einddatum};
                         $wacht_datum = $main::klant->{contracten}->[$nr]->{wachtdatum};
                         $aanvangsdatum = $parser->parse_datetime($wacht_datum);
                         $aanvangsdatum = $aanvangsdatum->add(days => 1);
                         $aanvangs_datum = $aanvangsdatum->strftime('%d/%m/%Y');
                         last;
                        }
                    }
            }
        }
     eval {my $bestaat = $main::klant->{aandoeningen}->[0]->{verzekering}};
     #my $test =$main::klant;
     if (!$@) {
         my $aan_teller =1;
         #my $test = $main::klant;
         foreach my $nr (sort keys $main::klant->{aandoeningen}) {
	     my $huidig_jaar = substr ($vandaag,0,4);
	     my @a_begin_jaar = split(/-/,$main::klant->{aandoeningen}->[$nr]->{begindatum});
             my @a_eind_jaar = split(/-/,$main::klant->{aandoeningen}->[$nr]->{einddatum});
             if ($verz_doorgeef eq '' or !defined $verz_doorgeef and $huidig_jaar <= $a_eind_jaar[2]) {
                if (uc $main::klant->{aandoeningen}->[$nr]->{verzekering} ne '' or defined $main::klant->{aandoeningen}->[$nr]->{verzekering}) {  
                   $bestaandaandoening1 =$main::klant->{aandoeningen}->[$nr]->{aandoening};                         
                   $bestaandaandoening1_duur = "gedurende 3 jaar" if ($a_begin_jaar[2]+4 >= $a_eind_jaar[2]);
                   $bestaandaandoening1_duur = "definitief" if ($a_begin_jaar[2]+4 <= $a_eind_jaar[2]);
                   $persoon_bestaande->[$nr]->{naam} = $main::klant->{naam};
                   $persoon_bestaande->[$nr]->{'rijksregisternummmer'} = $main::klant->{Rijksreg_Nr};
                   $persoon_bestaande->[$nr]->{'bestaande_aandoening'} =  $bestaandaandoening1;
                   $persoon_bestaande->[$nr]->{'bestaande_aandoening_duur'} =  $bestaandaandoening1_duur;
                            
                  }  
               }else {
                if (uc $main::klant->{aandoeningen}->[$nr]->{verzekering} eq uc $verz_doorgeef and $huidig_jaar <= $a_eind_jaar[2]) {
                   #my @a_begin_jaar = split(/-/,$main::klant->{aandoeningen}->[$nr]->{begindatum});
                   #my @a_eind_jaar = split(/-/,$main::klant->{aandoeningen}->[$nr]->{einddatum});
		   
                   $bestaandaandoening1 =$main::klant->{aandoeningen}->[$nr]->{aandoening};                         
                   $bestaandaandoening1_duur = "gedurende 3 jaar" if ($a_begin_jaar[2]+4 >= $a_eind_jaar[2]);
                   $bestaandaandoening1_duur = "definitief" if ($a_begin_jaar[2]+4 <= $a_eind_jaar[2]);
                   $persoon_bestaande->[$nr]->{naam} = $main::klant->{naam};
                   $persoon_bestaande->[$nr]->{'rijksregisternummmer'} = $main::klant->{Rijksreg_Nr};
                   $persoon_bestaande->[$nr]->{'bestaande_aandoening'} =  $bestaandaandoening1;
                   $persoon_bestaande->[$nr]->{'bestaande_aandoening_duur'} =  $bestaandaandoening1_duur;
                  }               
                
               }  
            }
         }
     eval {my $bestaat = $main::klant->{ziekten}->[0]->{ziekten}};
     if (!$@) {        #
         my $aan_teller =1;
         foreach my $nr (sort keys $main::klant->{ziekten}) {
             if (uc $main::klant->{ziekten}->[$nr]->{verzekering} eq uc $verz_doorgeef) {
                 $verzekering ='HospiPlus & AmbuPlus' if  (uc $verz_doorgeef eq 'HOSPIPLUS_AMBUPLUS');
                 $verzekering ='HospiPlus'  if (uc $verz_doorgeef eq 'HOSPIPLUS') ;
                 $verzekering ='AmbuPlus' if ($verz_doorgeef eq 'AMBUPLUS') ;
                 $verzekering ='HospiPlan & AmbuPlan'  if ($verz_doorgeef eq 'HOSPIPLAN_AMBUPLAN');
                 $verzekering ='HospiPlan'  if ($verz_doorgeef eq 'HOSPIPLAN') ;
                 $verzekering ='AmbuPlan' if ($verz_doorgeef eq 'AMBUPLAN') ;                 
                 $verzekering ='HospiForfait' if ($verz_doorgeef =~ m/HOSPIFORFAIT/) ;
                 $verzekering ='HospiContinu' if ($verz_doorgeef eq 'HOSPICONTINUE') ;
                 $verzekering ='MaxiPlan' if (uc $verz_doorgeef eq 'MAXIPLAN') ;
                 $verzekering ='TandPlus' if (uc $verz_doorgeef eq 'TANDPLUS') ;
                 $ernstigeziekte1 = $main::klant->{ziekten}->[$nr]->{ziekte} if ($aan_teller == 1);
                 $ernstigeziekte2 = $main::klant->{ziekten}->[$nr]->{ziekte} if ($aan_teller == 2);
                 $ernstigeziekte3 = $main::klant->{ziekten}->[$nr]->{ziekte} if ($aan_teller == 3);
                 $ernstigeziekte4 = $main::klant->{ziekten}->[$nr]->{ziekte} if ($aan_teller == 4);
                 $ernstigeziekte5 = $main::klant->{ziekten}->[$nr]->{ziekte} if ($aan_teller == 5);
                 $aan_teller +=1;
                }
            }
        }
     eval {my $bestaat =$main::klant->{adres}->[0]->{Stad}};
    
     if (!$@) {
         my $postadres_bestaat = 'nee';
         foreach my $nr (sort keys $main::klant->{adres}) {
             if ($main::klant->{adres}->[$nr]->{type} eq 'Domi') {
                  $domi_adres_lijn1 = uc "$lijn_v";
                  $domi_adres_lijn2 = uc $main::klant->{adres}->[$nr]->{Straat};
                  $domi_adres_lijn3 = uc "$main::klant->{adres}->[$nr]->{Postcode} $main::klant->{adres}->[$nr]->{Stad}";
                  $woonplaats = "$main::klant->{adres}->[$nr]->{Postcode} $main::klant->{adres}->[$nr]->{Stad}";
                   &checkwonendopzelfdeadres ('',$main::klant->{adres}->[$nr]->{Straat},
                        $main::klant->{adres}->[$nr]->{Postcode},
                        $main::klant->{adres}->[$nr]->{Stad});
                }elsif ($main::klant->{adres}->[$nr]->{type} eq 'Post') {
                  $post_adres_lijn1 = uc "$lijn_v";
                  $post_adres_lijn2 = uc $main::klant->{adres}->[$nr]->{Straat};
                  $post_adres_lijn3 = uc "$main::klant->{adres}->[$nr]->{Postcode} $main::klant->{adres}->[$nr]->{Stad}";
                  $postadres_bestaat = 'ja';
                  $brief_adres_lijn1 = $post_adres_lijn1;
                  $brief_adres_lijn2 = $post_adres_lijn2;
                  $brief_adres_lijn3 = $post_adres_lijn3;   
                }
             if ($postadres_bestaat eq 'nee') {
                 $brief_adres_lijn1 = $domi_adres_lijn1;
                 $brief_adres_lijn2 = $domi_adres_lijn2;
                 $brief_adres_lijn3 = $domi_adres_lijn3;
                }             
            }
        }
     #my $wachtdatum = '';
     #if ($wacht_datum) {
     #  $wachtdatum = $parser->parse_datetime($wacht_datum);
     #  $wachtdatum = $wachtdatum->strftime('%Y%m%d');
     #  $wachtdatum = substr ($wachtdatum,0,8);
     #  my $aansluitingsdatum = $parser->parse_datetime($aansluitings_datum);
     #  $aansluitingsdatum = $aansluitingsdatum->strftime('%Y%m%d');
     #  $aansluitingsdatum = substr ($aansluitingsdatum,0,8);
     #  $vandaag = substr ($vandaag,0,8);
     #  if ( $aansluitingsdatum  < $wachtdatum) {
     #      $bolean_wachttijd = 'met';
     #    }else {
     #      $bolean_wachttijd = 'zonder';
     #    } 
     # }
      #rijksregisternummer_spatie
      my $splitinz= $main::klant->{Rijksreg_Nr};
      $splitinz=~ s%\d{2}$% $&%;
      #print "$splitinz\n";
      $splitinz=~ s%\d{3}\s\d{2}$% $&%;
      $splitinz = sprintf ('%013s',$splitinz);  #voorafgaande nullen terug zetten
     
      #datum
       
      $eind_datum =~ s/31-12-2099/99-99-9999/;
      
     
      %oodoc_variabelen = (
	 'agr_nr' => $main::klant->{Agresso_nummer},
         'uur' => $uurfile,
         'brief_adres_lijn1' => $brief_adres_lijn1,
         'brief_adres_lijn2' => $brief_adres_lijn2,
         'brief_adres_lijn3' => $brief_adres_lijn3,
         'brief_adres_lijn4' => $brief_adres_lijn4,
         'domi_adres_lijn1' => $domi_adres_lijn1,
         'domi_adres_lijn2' => $domi_adres_lijn2,
         'domi_adres_lijn3' => $domi_adres_lijn3,
         'ziekenfonds' => $zkf ,
         'externnummer' =>  $main::klant->{ExternNummer},
         'rijksregisternummer' => $main::klant->{Rijksreg_Nr},
         'rijksregisternummer_spatie' =>  $splitinz,
         'naam' => $main::klant->{naam},
         'voornaam' => "",
         'geboortedatum' => $main::klant->{geboortedatum},
         'geslacht' => $naamgeslacht,
         'naamgeslacht' => $naamgeslacht,
         'cg1cg2' => "",
         'H_aan_spreek' => $H_aan_spreek,
         'aan_spreek' => $aan_spreek,
         'datum_geschreven' => "$mday $maand_naam $jaar_getal",
         'datum_slashes' => "$mday/$maand_getal/$jaar_getal",
         'datum_min' => "$mday-$maand_getal-$jaar_getal",
         'h_h' => $h_h,
         'h_ar' => $h_ar,
         'bic_nummer' =>  $main::klant->{BIC},
         'eu_rek_nummer' =>$main::klant->{IBAN},
         'bb_rek_nummer' =>$main::klant->{Bankrekening},
         'ontslag_code' =>  "",
         'detail_ontslag_code' => "",
         'ontslag_datum' => "$eind_datum",
         'aansluitings_code' => "",
         'detail_aansluitings_code' =>"",
         'aansluitings_datum' =>  "$aansluitings_datum",
         'nummer_dossier' => $contract_nr,
         'sjabloon' => $sjabloon,
         'verzekering' =>$verzekering,
         'gebruikersnaam' => $gebruikersnaam,
         'geenpath' => $geen_path,
         'documentplaatst_brieven' => $main::agresso_instellingen->{plaats_brieven},
         'bestaande_aandoening1' => $bestaandaandoening1,
         'bestaandaandoening1_duur' => $bestaandaandoening1_duur,
         'bestaande_aandoening2' => $bestaandaandoening2,
         'bestaandaandoening2_duur' => $bestaandaandoening2_duur,
         'bestaande_aandoening3' => $bestaandaandoening3,
         'bestaandaandoening3_duur' => $bestaandaandoening3_duur,
         'bestaande_aandoening4' => $bestaandaandoening4,
         'bestaandaandoening4_duur' => $bestaandaandoening4_duur,
         'bestaande_aandoening5' => $bestaandaandoening5,
         'bestaandaandoening5_duur' => $bestaandaandoening5_duur,
         'ernstigeziekte1' => $ernstigeziekte1,
         'ernstigeziekte2' => $ernstigeziekte2,
         'ernstigeziekte3' => $ernstigeziekte3,
         'ernstigeziekte4' => $ernstigeziekte4,
         'ernstigeziekte5' => $ernstigeziekte5,
         'car_v_j' =>'',
         'car_h_j' => '',
         'm_w' => $main::bolean_wachttijd,
         'eind_wacht' =>"$wacht_datum",
         'aanvangs_datum' => $aanvangs_datum,
         'datum_laatste_betaling' => "" ,
         'alle_verzekeringen' => $alle_verzekeringen,
         'aantal_verzekeringen' => $aantal_verzekeringen,
         'forfait_formule' =>"",
         'info_text' =>  $info_text ,
         'lcode' =>"",
         'bus' => "",
         'huisnr' => "",
         'straatnr' => "",
         'postnr' => "",
         'wat_binnen_brengen1' => $wat_binnenbrengen[0],
         'wat_binnen_brengen2' => $wat_binnenbrengen[1],
         'wat_binnen_brengen3' => $wat_binnenbrengen[2],
         'wat_binnen_brengen4' => $wat_binnenbrengen[3],
         'wat_binnen_brengen5' => $wat_binnenbrengen[4],
         'wat_binnen_brengen6' => $wat_binnenbrengen[5],
         'wat_binnen_brengen7' => $wat_binnenbrengen[6],
         'wat_binnen_brengen8' => $wat_binnenbrengen[7],
         'wat_binnen_brengen9' => $wat_binnenbrengen[8],
         'wat_binnen_brengen010' => $wat_binnenbrengen[9],
         'wat_binnen_brengen011' => $wat_binnenbrengen[10],
         'wat_binnen_brengen012' => $wat_binnenbrengen[11],
         'wat_binnen_brengen013' => $wat_binnenbrengen[12],
         'wat_binnen_brengen014' => $wat_binnenbrengen[13],
         'wat_binnen_brengen015' => $wat_binnenbrengen[14],
         'wat_binnen_brengen016' => $wat_binnenbrengen[15],
         'wat_binnen_brengen017' => $wat_binnenbrengen[16],
         'wat_binnen_brengen018' => $wat_binnenbrengen[17],
         'wat_binnen_brengen019' => $wat_binnenbrengen[18],
         'wat_binnen_brengen020' => $wat_binnenbrengen[19],
         'moet_geprint' =>$moet_geprint,
         'printer' => $printer,
         'pdf_naar_agresso' => $pdf_naar_agresso,
         'bestaat_in_xml' => $bestaat_in_xml,
	 'popup' => $popup
        );
     #zoek alle verzekeringen
     
     &zoek_zelfde_dossier($contract_nr,$verz_doorgeef) if ($contract_nr);
    
     my $printfilename =&vervang_parameters_in_oodoc ($verz_doorgeef,@wat_binnenbrengen);
}


sub vervang_parameters_in_oodoc {
        #print "\nok\n";
	my $vandaag = ParseDate("today");
        $vandaag = substr ($vandaag,0,8);
	my ($verz_doorgeef,@wat_binnenbrengen) = @_;
        my $home_dir = "$ENV{USERPROFILE}"  ;
	my $parser2 = DateTime::Format::Strptime->new(pattern => '%Y%m%d');
        my $parser1 = DateTime::Format::Strptime->new(pattern => '%d/%m/%Y');
        my $parser = DateTime::Format::Strptime->new(pattern => '%d-%m-%Y');
        my $path_to_files = $main::agresso_instellingen->{'plaats_sjablonen_brieven'};
        my $documentplaats = $main::agresso_instellingen->{'plaats_brieven'};#$locatie_documenten;
        my $sjabloon = $oodoc_variabelen{'sjabloon'};
        print "wordt gemaakt $sjabloon $oodoc_variabelen{'verzekering'} $oodoc_variabelen{'ziekenfonds'} $oodoc_variabelen{'rijksregisternummer'}\n";
        my $doc ;
	my $file_bestaat =1;
        if ($oodoc_variabelen{'geenpath'} == 1) {
          eval {$doc = ooDocument(file => "$sjabloon")};
	  if (!$!) {
	     $doc = ooDocument(file => "$sjabloon");
	  }else {
	    print "";
	     Wx::MessageBox( _T("$sjabloon\nBESTAAT NIET!"), 
                 _T("Brieven Maken"), 
                 wxOK|wxCENTRE, 
                $main::frame
               );
	     $file_bestaat =0;
	  }
	  
          $documentplaats = $oodoc_variabelen{'documentplaatst_brieven'};
        }else {
	  eval {$doc = ooDocument(file => "$path_to_files\\$sjabloon")};
	  if (!$!) {
	     $doc = ooDocument(file => "$path_to_files\\$sjabloon");  #onslag aansluiting brieven
	     #&delfiles  ($documentplaats);  #maak de printdirectory leeg     
	    }else {
	     Wx::MessageBox( _T("$sjabloon\nBESTAAT NIET!"), 
                 _T("Brieven Maken"), 
                 wxOK|wxCENTRE, 
                $main::frame
               );
	     $file_bestaat =0;
	  }
        }
	if ($file_bestaat ==1) {
	    my $object = Barcode::Code128->new();
	    $object->code('A');     # Enforce 128A?
	    $object->option("border", 0);
	    $object->option("font","tiny");
	    my $BarName = "$home_dir\\inzbar.png";
	    unlink $BarName ;
	    my $meta = odfMeta(file => $sjabloon);
	    my $catlogkey ='';
	    my $title = '';
	    eval {my @userdef = $meta->user_defined()};
	    if (!$@) {
	      $title = $meta->title();
	      my @userdef = $meta->user_defined();
	      my $tel_def = 0;
	      foreach my $ufield (@userdef) {
		  $tel_def +=1;
		  if ($ufield =~ m/cataloog/i) {
		     $catlogkey= $userdef[$tel_def];
		     last;
		    }
		 }
	    }
	    
		
	   
	    my $filter = "brief_adres_lijn1";
	    my $result = $doc->selectTextContent($filter,$oodoc_variabelen{'brief_adres_lijn1'});
	    my $uc_verz_doorgeef = $verz_doorgeef;
	    #my $test= $main::brieven_vervang_teksten;
	    eval {foreach my $xml_vervangtekst  (keys $main::brieven_vervang_teksten->{verzekeringen}->{$uc_verz_doorgeef}) {}};
	    if (!$@) {
		my $tekst_vervang =''; 
	       foreach my $xml_vervangtekst  (keys $main::brieven_vervang_teksten->{verzekeringen}->{$uc_verz_doorgeef}) {
		 $filter ="$xml_vervangtekst";
		 $tekst_vervang =''; 
		 $tekst_vervang = $main::brieven_vervang_teksten->{verzekeringen}->{$uc_verz_doorgeef}->{$xml_vervangtekst};
		 
		 $tekst_vervang = '' if (ref($tekst_vervang) eq 'HASH' );
		 $result = $doc->selectTextContent($filter,"$tekst_vervang"); 
	       }
	    }
	    my $uc_ziekenfonds = "ZKF$oodoc_variabelen{'ziekenfonds'}";
	    #my $test = $main::brieven_vervang_teksten;
	    eval {foreach my $xml_vervangtekst (keys $main::brieven_vervang_teksten->{ziekenfondsen}->{$uc_ziekenfonds} ){}};
	    if (!$@) {
	       my $tekst_vervang =''; 
	      foreach my $xml_vervangtekst (keys $main::brieven_vervang_teksten->{ziekenfondsen}->{$uc_ziekenfonds}) {
		  $filter ="$xml_vervangtekst";
		  $tekst_vervang =''; 
		  $tekst_vervang = $main::brieven_vervang_teksten->{ziekenfondsen}->{$uc_ziekenfonds}->{$xml_vervangtekst};
		  $tekst_vervang = '' if (ref($tekst_vervang) eq 'HASH' );
		  $result = $doc->selectTextContent($filter,"$tekst_vervang"); 
		}
	     }
	    $filter ="test_characters";
	    $result = $doc->selectTextContent($filter,"üéèçô%£à");
	    $filter = "agr_nr";
	    $result = $doc->selectTextContent($filter,$oodoc_variabelen{'agr_nr'});
	    $filter = "brief_adres_lijn2";
	    $result = $doc->selectTextContent($filter,$oodoc_variabelen{'brief_adres_lijn2'});
	    $filter = "brief_adres_lijn3";
	    $result = $doc->selectTextContent($filter,$oodoc_variabelen{'brief_adres_lijn3'});
	    $filter = "brief_adres_lijn4";
	    $result = $doc->selectTextContent($filter,$oodoc_variabelen{'brief_adres_lijn4'});
	    $filter = "domi_adres_lijn1";
	    $result = $doc->selectTextContent($filter,$oodoc_variabelen{'domi_adres_lijn1'});
	    $filter = "domi_adres_lijn2";
	    $result = $doc->selectTextContent($filter,$oodoc_variabelen{'domi_adres_lijn2'});
	    $filter = "domi_adres_lijn3";
	    $result = $doc->selectTextContent($filter,$oodoc_variabelen{'domi_adres_lijn3'});
	    $filter = "cg1_cg2";
	    $result = $doc->selectTextContent($filter,$oodoc_variabelen{'cg1cg2'});
	    $filter = "voor_naam";
	    $result = $doc->selectTextContent($filter,$oodoc_variabelen{'voornaam'});
	    $filter = "achter_naam";
	    $result = $doc->selectTextContent($filter,$oodoc_variabelen{'naam'});
	    $filter = "inz_nr_g_sp";
	    $result = $doc->selectTextContent($filter,$oodoc_variabelen{'rijksregisternummer'});
	    $filter = "inz_nr_spatie";
	    $result = $doc->selectTextContent($filter,$oodoc_variabelen{'rijksregisternummer_spatie'});
	    $filter = "extern_nummer";
	    $result = $doc->selectTextContent($filter,$oodoc_variabelen{'externnummer'});
	    $filter = "geb_datum";
	    $result = $doc->selectTextContent($filter,$oodoc_variabelen{'geboortedatum'});
	    $filter = "H_aan_spreek";
	    $result = $doc->selectTextContent($filter,$oodoc_variabelen{'H_aan_spreek'});
	    $filter = "aan_spreek";
	    $result = $doc->selectTextContent($filter,$oodoc_variabelen{'aan_spreek'});
	    $filter = "ge_slacht";
	    $result = $doc->selectTextContent($filter,$oodoc_variabelen{'geslacht'});
	    $filter = "datum_geschreven";
	    $result = $doc->selectTextContent($filter,$oodoc_variabelen{'datum_geschreven'});
	    $filter = "datum_slashes";
	    $result = $doc->selectTextContent($filter,$oodoc_variabelen{'datum_slashes'});
	    $filter = "datum_min";
	    $result = $doc->selectTextContent($filter,$oodoc_variabelen{'datum_min'});
	    $filter = "h_h";
	    $result = $doc->selectTextContent($filter,$oodoc_variabelen{'h_h'});
	    $filter = "h_ar";
	    $result = $doc->selectTextContent($filter,$oodoc_variabelen{'h_ar'});
	    $filter = "bic_nummer";
	    $result = $doc->selectTextContent($filter,$oodoc_variabelen{'bic_nummer'});
	    $filter = "eu_rek_nummer";
	    $result = $doc->selectTextContent($filter,$oodoc_variabelen{'eu_rek_nummer'});
	    $filter = "bb_rek_nummer";
	    $result = $doc->selectTextContent($filter,$oodoc_variabelen{'bb_rek_nummer'});
	    $filter = "ontslag_code";
	    $result = $doc->selectTextContent($filter,$oodoc_variabelen{'ontslag_code'});
	    $filter = "ontslagd_code";
	    $result = $doc->selectTextContent($filter,$oodoc_variabelen{'detail_ontslag_code'});
	    $filter = "ontslag_datum";
	    $result = $doc->selectTextContent($filter,$oodoc_variabelen{'ontslag_datum'});
	    $filter = "aansluitings_code";
	    $result = $doc->selectTextContent($filter,$oodoc_variabelen{'aansluitings_code'});
	    $filter = "aansluitingsd_code";
	    $result = $doc->selectTextContent($filter,$oodoc_variabelen{'detail_aansluitings_code'});
	    $filter = "aansluitings_datum";#aansluitings_datum
	    $result = $doc->selectTextContent($filter,$oodoc_variabelen{'aansluitings_datum'});
	    $filter = "nummer_dossier";
	    $result = $doc->selectTextContent($filter,$oodoc_variabelen{'nummer_dossier'});
	    $filter = "ver_zekering";
	    $result = $doc->selectTextContent($filter,$oodoc_variabelen{'verzekering'});
	    $filter = "zkf_nr";
	    $result = $doc->selectTextContent($filter,$oodoc_variabelen{'ziekenfonds'});
	    $filter = "gebruikers_naam";
	    $result = $doc->selectTextContent($filter,$oodoc_variabelen{'gebruikersnaam'});
	    $filter = "bestaande_aandoening1";
	    $result = $doc->selectTextContent($filter,$oodoc_variabelen{'bestaande_aandoening1'});
	    $filter = "bestaandaandoening1_duur";
	    $result = $doc->selectTextContent($filter,$oodoc_variabelen{'bestaandaandoening1_duur'});
	    $filter = "bestaande_aandoening2";
	    $result = $doc->selectTextContent($filter,$oodoc_variabelen{'bestaande_aandoening2'});
	    $filter = "bestaandaandoening2_duur";
	    $result = $doc->selectTextContent($filter,$oodoc_variabelen{'bestaandaandoening2_duur'});
	    $filter = "bestaande_aandoening3";
	    $result = $doc->selectTextContent($filter,$oodoc_variabelen{'bestaande_aandoening3'});
	    $filter = "bestaandaandoening3_duur";
	    $result = $doc->selectTextContent($filter,$oodoc_variabelen{'bestaandaandoening3_duur'});
	    $filter = "bestaande_aandoening4";
	    $result = $doc->selectTextContent($filter,$oodoc_variabelen{'bestaande_aandoening4'});
	    $filter = "bestaandaandoening4_duur";
	    $result = $doc->selectTextContent($filter,$oodoc_variabelen{'bestaandaandoening4_duur'});
	    $filter = "bestaande_aandoening5";
	    $result = $doc->selectTextContent($filter,$oodoc_variabelen{'bestaande_aandoening5'});
	    $filter = "bestaandaandoening5_duur";
	    $result = $doc->selectTextContent($filter,$oodoc_variabelen{'bestaandaandoening5_duur'});
	    $filter = "ernstige_ziekte1";
	    $result = $doc->selectTextContent($filter,$oodoc_variabelen{'ernstigeziekte1'});
	    $filter = "ernstige_ziekte2";
	    $result = $doc->selectTextContent($filter,$oodoc_variabelen{'ernstigeziekte2'});
	    $filter = "ernstige_ziekte3";
	    $result = $doc->selectTextContent($filter,$oodoc_variabelen{'ernstigeziekte3'});
	    $filter = "ernstige_ziekte4";
	    $result = $doc->selectTextContent($filter,$oodoc_variabelen{'ernstigeziekte4'});
	    $filter = "ernstige_ziekte5";
	    $result = $doc->selectTextContent($filter,$oodoc_variabelen{'ernstigeziekte5'});
	    $filter = "car_v_j";
	    $result = $doc->selectTextContent($filter,$oodoc_variabelen{'car_v_j'});
	    $filter = "car_h_j";
	    $result = $doc->selectTextContent($filter,$oodoc_variabelen{'car_h_j'});
	    $filter = "eind_wacht";
	    $result = $doc->selectTextContent($filter,$oodoc_variabelen{'eind_wacht'});
	    $filter = "aanvangs_datum";
	    $result = $doc->selectTextContent($filter,$oodoc_variabelen{'aanvangs_datum'});
	    $filter = "d_l_betaal";
	    $result = $doc->selectTextContent($filter,$oodoc_variabelen{'datum_laatste_betaling'});
	    $filter = "alle_verzekeringen";
	    $result = $doc->selectTextContent($filter,$oodoc_variabelen{'alle_verzekeringen'});
	    $filter = "for_mule";
	    $result = $doc->selectTextContent($filter,$oodoc_variabelen{'forfait_formule'});
	    $filter = "m_w";
	    $result = $doc->selectTextContent($filter,$oodoc_variabelen{'m_w'});
	    $filter = "info_text";
	    $result = $doc->selectTextContent($filter,$oodoc_variabelen{'info_text'});
	    $filter = "wat_binnen_brengen1";
	    $result = $doc->selectTextContent($filter,$oodoc_variabelen{'wat_binnen_brengen1'});
	    $filter = "wat_binnen_brengen2";
	    $result = $doc->selectTextContent($filter,$oodoc_variabelen{'wat_binnen_brengen2'});
	    $filter = "wat_binnen_brengen3";
	    $result = $doc->selectTextContent($filter,$oodoc_variabelen{'wat_binnen_brengen3'});
	    $filter = "wat_binnen_brengen4";
	    $result = $doc->selectTextContent($filter,$oodoc_variabelen{'wat_binnen_brengen4'});
	    $filter = "wat_binnen_brengen5";
	    $result = $doc->selectTextContent($filter,$oodoc_variabelen{'wat_binnen_brengen5'});
	    $filter = "wat_binnen_brengen6";
	    $result = $doc->selectTextContent($filter,$oodoc_variabelen{'wat_binnen_brengen6'});
	    $filter = "wat_binnen_brengen7";
	    $result = $doc->selectTextContent($filter,$oodoc_variabelen{'wat_binnen_brengen7'});
	    $filter = "wat_binnen_brengen8";
	    $result = $doc->selectTextContent($filter,$oodoc_variabelen{'wat_binnen_brengen8'});
	    $filter = "wat_binnen_brengen9";
	    $result = $doc->selectTextContent($filter,$oodoc_variabelen{'wat_binnen_brengen9'});
	    $filter = "wat_binnen_brengen010";
	    $result = $doc->selectTextContent($filter,$oodoc_variabelen{'wat_binnen_brengen010'});
	    $filter = "wat_binnen_brengen011";
	    $result = $doc->selectTextContent($filter,$oodoc_variabelen{'wat_binnen_brengen011'});
	    $filter = "wat_binnen_brengen012";
	    $result = $doc->selectTextContent($filter,$oodoc_variabelen{'wat_binnen_brengen012'});
	    $filter = "wat_binnen_brengen013";
	    $result = $doc->selectTextContent($filter,$oodoc_variabelen{'wat_binnen_brengen013'});
	    $filter = "wat_binnen_brengen014";
	    $result = $doc->selectTextContent($filter,$oodoc_variabelen{'wat_binnen_brengen014'});
	    $filter = "wat_binnen_brengen015";
	    $result = $doc->selectTextContent($filter,$oodoc_variabelen{'wat_binnen_brengen015'});
	    $filter = "wat_binnen_brengen016";
	    $result = $doc->selectTextContent($filter,$oodoc_variabelen{'wat_binnen_brengen016'});
	    $filter = "wat_binnen_brengen017";
	    $result = $doc->selectTextContent($filter,$oodoc_variabelen{'wat_binnen_brengen017'});
	    $filter = "wat_binnen_brengen018";
	    $result = $doc->selectTextContent($filter,$oodoc_variabelen{'wat_binnen_brengen018'});
	    $filter = "wat_binnen_brengen019";
	    $result = $doc->selectTextContent($filter,$oodoc_variabelen{'wat_binnen_brengen019'});
	    $filter = "wat_binnen_brengen020";
	    $result = $doc->selectTextContent($filter,$oodoc_variabelen{'wat_binnen_brengen020'});
	    $filter = "pre_mie";
	    my $komma_premie = $main::premie;
	    $komma_premie =~ s/\./,/;
	    $result = $doc->selectTextContent($filter,$komma_premie);
	    for (my $i = 10; $i < 20; $i++) {
	      $filter = "wat_binnen_brengen0$i";
	      $result = $doc->selectTextContent($filter,'')          
	     }
	     for (my $i = 1; $i < 10; $i++) {
	      $filter = "wat_binnen_brengen$i";
	      $result = $doc->selectTextContent($filter,'');         
	     }
	    my $rijenteller =1;
	    my $cell;
	    foreach my $wat (@wat_binnenbrengen) {
	      $doc->appendRow("wat_binnenbrengen");
	      $cell = $doc->getCell("wat_binnenbrengen",$rijenteller, 0);
	      $doc->cellValue("wat_binnenbrengen",$rijenteller,0,$wat);
	      $rijenteller +=1;
	    }
	    #veven weg
	    #tabel met naam overzicht_dossier
	    $rijenteller =1;
	    eval {foreach my $rrnr (sort keys $personen_zelfdedoss) {}};
	    if (!$@) {
	      foreach my $rrnr (sort keys $personen_zelfdedoss) {
		 if ($rijenteller !=1){
		    $doc->appendRow("overzicht_dossier");
		    $cell = $doc->getCell("overzicht_dossier",$rijenteller, 0);
		    $doc->cellValue("overzicht_dossier",$rijenteller,0,'');
		    $cell = $doc->getCell("overzicht_dossier",$rijenteller, 1);
		    $doc->cellValue("overzicht_dossier",$rijenteller,1,'');
		    $cell = $doc->getCell("overzicht_dossier",$rijenteller, 2);
		    $doc->cellValue("overzicht_dossier",$rijenteller,2,'');
		    $cell = $doc->getCell("overzicht_dossier",$rijenteller, 3);
		    $doc->cellValue("overzicht_dossier",$rijenteller,3,'');
		    $cell = $doc->getCell("overzicht_dossier",$rijenteller, 4);
		    $doc->cellValue("overzicht_dossier",$rijenteller,4,'');
		   }
		   #my $test2 = $personen_zelfdedoss;
		       
		   $cell = $doc->getCell("overzicht_dossier",$rijenteller, 0);
		   $doc->cellValue("overzicht_dossier",$rijenteller,0,$personen_zelfdedoss->{$rrnr}->{'naam'});
		   $cell = $doc->getCell("overzicht_dossier",$rijenteller,1);
		   $doc->cellValue("overzicht_dossier",$rijenteller,1,$personen_zelfdedoss->{$rrnr}->{'rijksregisternummer'});
		   $cell = $doc->getCell("overzicht_dossier",$rijenteller,2);
		   $doc->cellValue("overzicht_dossier",$rijenteller,2,$personen_zelfdedoss->{$rrnr}->{'geboortedatum'});
		   $cell = $doc->getCell("overzicht_dossier",$rijenteller,3);
		   $doc->cellValue("overzicht_dossier",$rijenteller,3,$personen_zelfdedoss->{$rrnr}->{'tit_ptl'});
		   $cell = $doc->getCell("overzicht_dossier",$rijenteller,4);
		   $doc->cellValue("overzicht_dossier",$rijenteller,4,$personen_zelfdedoss->{$rrnr}->{'bijdrage'});
		   $rijenteller +=1;
		}
	      $rijenteller =1;
	      #tabel met naam overzicht_dossier1
	      foreach my $rrnr (sort keys $personen_zelfdedoss) {
		 if ($rijenteller !=1){
		    $doc->appendRow("overzicht_dossier1");           
		    $cell = $doc->getCell("overzicht_dossier1",$rijenteller,0 );
		    $doc->cellValue("overzicht_dossier1",$rijenteller,0,'');
		    $cell = $doc->getCell("overzicht_dossier1",$rijenteller, 1);
		    $doc->cellValue("overzicht_dossier1",$rijenteller,1,'');
		    $cell = $doc->getCell("overzicht_dossier1",$rijenteller, 2);
		    $doc->cellValue("overzicht_dossier1",$rijenteller,2,'');
		    $cell = $doc->getCell("overzicht_dossier1",$rijenteller, 3);
		    $doc->cellValue("overzicht_dossier1",$rijenteller,3,'');          
		   }                 
		 $cell = $doc->getCell("overzicht_dossier1",$rijenteller, 0);
		 $doc->cellValue("overzicht_dossier1",$rijenteller,0,$personen_zelfdedoss->{$rrnr}->{'naam'});
		 $cell = $doc->getCell("overzicht_dossier1",$rijenteller,1);
		 $doc->cellValue("overzicht_dossier1",$rijenteller,1,$personen_zelfdedoss->{$rrnr}->{'rijksregisternummer'});
		 $cell = $doc->getCell("overzicht_dossier1",$rijenteller,2);
		 $doc->cellValue("overzicht_dossier1",$rijenteller,2,$personen_zelfdedoss->{$rrnr}->{'aansluitingsdatum'});
		 $cell = $doc->getCell("overzicht_dossier1",$rijenteller,3);
		 my $eind_datum = $personen_zelfdedoss->{$rrnr}->{'afsluitingsdatum'};
		 $eind_datum = '99/99/9999' if ($personen_zelfdedoss->{$rrnr}->{'afsluitingsdatum'} eq '31/12/2099');
		 $doc->cellValue("overzicht_dossier1",$rijenteller,3,$eind_datum);
		 $rijenteller +=1;
		}
	     }
	    
	    
	     #tabel verzekeringen
	      $rijenteller =0;
	     #tabel met naam overzicht_verzekeringen
	    # my $test = $main::klant;
	     if (defined $main::klant->{contracten}->[0]->{naam}) {
		 foreach my $nr (sort keys $main::klant->{contracten}) {
		     if (defined $main::klant->{contracten}->[$nr]->{naam}) {
			 my $test = $main::klant;
			 my $verzek_naam ='';
			 $verzek_naam = 'HospiPlus & AmbuPlus ' if ($main::klant->{contracten}->[$nr]->{naam} eq uc ('hospiplus_ambuplus'));
			 $verzek_naam = 'HospiPlus ' if ($main::klant->{contracten}->[$nr]->{naam} eq uc ('hospiplus'));
			 $verzek_naam = 'AmbuPlus ' if ($main::klant->{contracten}->[$nr]->{naam} eq uc ('ambuplus'));
			 $verzek_naam = 'HospiPlan & AmbuPlan ' if ($main::klant->{contracten}->[$nr]->{naam} eq uc ('hospiplan_ambuplan'));
			 $verzek_naam = 'HospiPlan ' if ($main::klant->{contracten}->[$nr]->{naam} eq uc ('hospiplan'));
			 $verzek_naam = 'AmbuPlan '  if ($main::klant->{contracten}->[$nr]->{naam} eq uc ('ambuplan'));
			 $verzek_naam = 'HospiForfait ' if ($main::klant->{contracten}->[$nr]->{naam} =~ m/HOSPIFORFAIT/) ;
			 $verzek_naam = 'HospiContinu ' if ($main::klant->{contracten}->[$nr]->{naam} eq uc 'hospicontinu');
			 $verzek_naam = 'MaxiPlan ' if ($main::klant->{contracten}->[$nr]->{naam} eq uc 'MaxiPlan');
			 my $test_eind_datum = $main::klant->{contracten}->[$nr]->{einddatum};
			 $test_eind_datum = $parser->parse_datetime($test_eind_datum);
			 $test_eind_datum = $test_eind_datum->strftime('%Y%m%d');
			 $test_eind_datum = $test_eind_datum +30000;
			 if ($rijenteller !=0 and $vandaag < $test_eind_datum ){
			     $doc->appendRow("overzicht_verzekeringen");
			     $cell = $doc->getCell("overzicht_verzekeringen",$rijenteller, 0);
			     $doc->cellValue("overzicht_verzekeringen",$rijenteller,0,'');
			     $cell = $doc->getCell("overzicht_verzekeringen",$rijenteller, 1);
			     $doc->cellValue("overzicht_verzekeringen",$rijenteller,1,'');
			     $cell = $doc->getCell("overzicht_verzekeringen",$rijenteller, 2);
			     $doc->cellValue("overzicht_verzekeringen",$rijenteller,2,'');
			     $cell = $doc->getCell("overzicht_verzekeringen",$rijenteller, 3);
			     $doc->cellValue("overzicht_verzekeringen",$rijenteller,3,'');
			    }
			 my $eind_datum = $main::klant->{contracten}->[$nr]->{einddatum};
			 
			 $eind_datum = $parser->parse_datetime($eind_datum);
			 $eind_datum = $eind_datum->strftime('%d/%m/%Y');
		         $eind_datum = '99/99/9999' if ($eind_datum eq '31/12/2099');
			 my $begin_datum = $main::klant->{contracten}->[$nr]->{startdatum};
			 $begin_datum = $parser->parse_datetime($begin_datum);
			 $begin_datum = $begin_datum->strftime('%d/%m/%Y');
			 if ($vandaag < $test_eind_datum ) {
			     $cell = $doc->getCell("overzicht_verzekeringen",$rijenteller, 0);
			     $doc->cellValue("overzicht_verzekeringen",$rijenteller,0,$verzek_naam);
			     $cell = $doc->getCell("overzicht_verzekeringen",$rijenteller, 1);		
			     $doc->cellValue("overzicht_verzekeringen",$rijenteller,1,$begin_datum);
			     $cell = $doc->getCell("overzicht_verzekeringen",$rijenteller, 2);		 
			     $doc->cellValue("overzicht_verzekeringen",$rijenteller,2,$eind_datum);
			     $cell = $doc->getCell("overzicht_verzekeringen",$rijenteller, 3);
			     my $verz_contract = $main::brieven_vervang_teksten->{verzekeringen}->{$uc_verz_doorgeef}->{verz_tekst7};
			     $doc->cellValue("overzicht_verzekeringen",$rijenteller,3,"$verz_contract-$main::klant->{contracten}->[$nr]->{contract_nr}");
			     $rijenteller +=1;
			     }
			 
			 
			}
		    }
		}else {
		 my $verzek_naam ='';
		 #my $test = $main::klant ;
		 eval {my $bestaat = $main::klant->{contracten}->{naam}};
		 if (!$@) {
		    $verzek_naam = 'HospiPlus & AmbuPlus ' if ($main::klant->{contracten}->{naam} eq uc ('hospiplus_ambuplus'));
		    $verzek_naam = 'HospiPlus ' if ($main::klant->{contracten}->{naam} eq uc ('hospiplus'));
		    $verzek_naam = 'AmbuPlus ' if ($main::klant->{contracten}->{naam} eq uc ('ambuplus'));
		    $verzek_naam = 'HospiPlan & AmbuPlan ' if ($main::klant->{contracten}->{naam} eq uc ('hospiplan_ambuplan'));
		    $verzek_naam = 'HospiPlan ' if ($main::klant->{contracten}->{naam} eq uc ('hospiplan'));
		    $verzek_naam = 'AmbuPlan '  if ($main::klant->{contracten}->{naam} eq uc ('ambuplan'));
		    $verzek_naam = 'HospiForfait ' if ($main::klant->{contracten}->{naam} =~ m/HOSPIFORFAIT/) ;
		    $verzek_naam = 'HospiContinu ' if ($main::klant->{contracten}->{naam} eq 'hospicontinue');
		    $verzek_naam = 'MaxiPlan ' if ($main::klant->{contracten}->{naam} eq uc 'MaxiPlan');
		     my $test_eind_datum = $main::klant->{contracten}->{einddatum};
		     $test_eind_datum = $parser->parse_datetime($test_eind_datum);
		     $test_eind_datum = $test_eind_datum->strftime('%Y%m%d');
		     $test_eind_datum = $test_eind_datum +30000;
		    if ($rijenteller !=0 and $vandaag < $test_eind_datum ){
		       $doc->appendRow("overzicht_verzekeringen");
		       $cell = $doc->getCell("overzicht_verzekeringen",$rijenteller, 0);
		       $doc->cellValue("overzicht_verzekeringen",$rijenteller,0,'');
		       $cell = $doc->getCell("overzicht_verzekeringen",$rijenteller, 1);
		       $doc->cellValue("overzicht_verzekeringen",$rijenteller,1,'');
		       $cell = $doc->getCell("overzicht_verzekeringen",$rijenteller, 2);
		       $doc->cellValue("overzicht_verzekeringen",$rijenteller,2,'');
		       $cell = $doc->getCell("overzicht_verzekeringen",$rijenteller, 3);
		       $doc->cellValue("overzicht_verzekeringen",$rijenteller,3,'');
		      }
		     my $eind_datum = $main::klant->{contracten}->{einddatum};
		    
		     $eind_datum = $parser->parse_datetime($eind_datum);
		     $eind_datum = $eind_datum->strftime('%m/%d/%Y');
		     my $begin_datum = $main::klant->{contracten}->{startdatum};
		     $begin_datum = $parser->parse_datetime($begin_datum);
		     $begin_datum = $begin_datum->strftime('%m/%d/%Y');
		     if ($vandaag < $test_eind_datum ) {
			    $cell = $doc->getCell("overzicht_verzekeringen",$rijenteller, 0);
			    $doc->cellValue("overzicht_verzekeringen",$rijenteller,0,$verzek_naam);
			    $cell = $doc->getCell("overzicht_verzekeringen",$rijenteller, 1);		
			    $doc->cellValue("overzicht_verzekeringen",$rijenteller,1,$begin_datum);
			    $cell = $doc->getCell("overzicht_verzekeringen",$rijenteller, 2);		 
			    $doc->cellValue("overzicht_verzekeringen",$rijenteller,2,$eind_datum);
			    $cell = $doc->getCell("overzicht_verzekeringen",$rijenteller, 3);
			    $doc->cellValue("overzicht_verzekeringen",$rijenteller,3,$main::klant->{contracten}->{contract_nr});
			    $rijenteller +=1;
		        }
		   }#code
		}
		 
		 
	    $rijenteller =1;
	    #tabel met bestaande aandoeningen
	    #my $test3 =$persoon_bestaande;
	    eval {foreach my $rrnr (sort keys $persoon_bestaande) {}};
	    if (!$@) {  
	      foreach my $rrnr (sort keys $persoon_bestaande) {
		 if ($rijenteller !=1 and $persoon_bestaande->[$rrnr]->{'bestaande_aandoening'} ne ''){
		      $doc->appendRow("bestaande_aandoening");
		      $cell = $doc->getCell("bestaande_aandoening",$rijenteller, 0);
		      $doc->cellValue("bestaande_aandoening",$rijenteller,0,'');
		      $cell = $doc->getCell("bestaande_aandoening",$rijenteller, 1);
		      $doc->cellValue("bestaande_aandoening",$rijenteller,1,'');
		      $cell = $doc->getCell("bestaande_aandoening",$rijenteller, 2);
		      $doc->cellValue("bestaande_aandoening",$rijenteller,2,'');
		      $cell = $doc->getCell("bestaande_aandoening",$rijenteller, 3);
		      $doc->cellValue("bestaande_aandoening",$rijenteller,3,'');
		      
		      
		   }
		 if ($persoon_bestaande->[$rrnr]->{'bestaande_aandoening'} ne '') {
		    $cell = $doc->getCell("bestaande_aandoening",$rijenteller, 0);
		    $doc->cellValue("bestaande_aandoening",$rijenteller,0,$persoon_bestaande->[$rrnr]->{'naam'});
		    $cell = $doc->getCell("bestaande_aandoening",$rijenteller,1);
		    $doc->cellValue("bestaande_aandoening",$rijenteller,1,$persoon_bestaande->[$rrnr]->{'rijksregisternummmer'});
		    $cell = $doc->getCell("bestaande_aandoening",$rijenteller,2);
		    $doc->cellValue("bestaande_aandoening",$rijenteller,2,$persoon_bestaande->[$rrnr]->{'bestaande_aandoening'});
		     
		   }
		 if ($rijenteller !=1 and $persoon_bestaande->[$rrnr]->{'bestaande_aandoening'} ne ''){
		    $doc->appendRow("een_kolom_bestaande");
		    $cell = $doc->getCell("een_kolom_bestaande",$rijenteller, 0);
		    $doc->cellValue("een_kolom_bestaande",$rijenteller,0,'');
		   }
		 if ($persoon_bestaande->[$rrnr]->{'bestaande_aandoening'} ne '') {
		    $cell = $doc->getCell("een_kolom_bestaande",$rijenteller,0);
		    $doc->cellValue("een_kolom_bestaande",$rijenteller,0,$persoon_bestaande->[$rrnr]->{'bestaande_aandoening'});
		    $rijenteller +=1;
		   }
		}
	     }else {
	      $doc->deleteRow("een_kolom_bestaande",1);
	      $doc->deleteRow("een_kolom_bestaande",0);
	       $doc->deleteRow("bestaande_aandoening",1);
	      $doc->deleteRow("bestaande_aandoening",0);
	     }
	    #tabel aansluiting
	    $rijenteller =1;
	    eval {foreach my $rrnr (sort keys $personen_zelfdeadres) {}};
	    if (!$@) {
	     foreach my $rrnr (sort keys $personen_zelfdeadres) {
		 if ($rijenteller !=1){
		      $doc->appendRow("Aansluitings_overzicht");
		      $cell = $doc->getCell("Aansluitings_overzicht",$rijenteller, 0);
		      $doc->cellValue("Aansluitings_overzicht",$rijenteller,0,'');
		      $cell = $doc->getCell("Aansluitings_overzicht",$rijenteller, 1);
		      $doc->cellValue("Aansluitings_overzicht",$rijenteller,1,'');
		      $cell = $doc->getCell("Aansluitings_overzicht",$rijenteller, 2);
		      $doc->cellValue("Aansluitings_overzicht",$rijenteller,2,'');
		    }
		  $cell = $doc->getCell("Aansluitings_overzicht",$rijenteller, 0);
		  $doc->cellValue("Aansluitings_overzicht",$rijenteller,0,$personen_zelfdeadres->{$rrnr}->{'naam'});
		  $cell = $doc->getCell("Aansluitings_overzicht",$rijenteller,1);
		  $doc->cellValue("Aansluitings_overzicht",$rijenteller,1,$personen_zelfdeadres->{$rrnr}->{'rijksregisternummer'});
		  $cell = $doc->getCell("Aansluitings_overzicht",$rijenteller,2);
		  $doc->cellValue("Aansluitings_overzicht",$rijenteller,2,$personen_zelfdeadres->{$rrnr}->{'aansluitingsdatum'});
		  $rijenteller +=1;
		}
	    }
	    
	   
	    #tabel onslag aansluiting
	    $rijenteller =1;
	    #my $test = $personen_zelfdedoss ;
	    eval {foreach my $rrnr (sort keys $personen_zelfdedoss) {}};
	    if (!$@) {
	      foreach my $rrnr (sort keys $personen_zelfdedoss) {
		 if ($rijenteller !=1){
		      $doc->appendRow("Ontslag_Aansluiting");
		      $cell = $doc->getCell("Ontslag_Aansluiting",$rijenteller, 0);
		      $doc->cellValue("Ontslag_Aansluiting",$rijenteller,0,'');
		      $cell = $doc->getCell("Ontslag_Aansluiting",$rijenteller, 1);
		      $doc->cellValue("Ontslag_Aansluiting",$rijenteller,1,'');
		      $cell = $doc->getCell("Ontslag_Aansluiting",$rijenteller, 2);
		      $doc->cellValue("Ontslag_Aansluiting",$rijenteller,2,'');
		      $cell = $doc->getCell("Ontslag_Aansluiting",$rijenteller, 3);
		      $doc->cellValue("Ontslag_Aansluiting",$rijenteller,3,'');
		   }   
		  $cell = $doc->getCell("Ontslag_Aansluiting",$rijenteller, 0);
		  $doc->cellValue("Ontslag_Aansluiting",$rijenteller,0,$personen_zelfdedoss->{$rrnr}->{'naam'});
		  $cell = $doc->getCell("Ontslag_Aansluiting",$rijenteller,1);
		  my $rr_nrr =sprintf("%011s",$personen_zelfdedoss->{$rrnr}->{'rijksregisternummer'});
		  $doc->cellValue("Ontslag_Aansluiting",$rijenteller,1,"$rr_nrr");
		  $cell = $doc->getCell("Ontslag_Aansluiting",$rijenteller,2);
		  $doc->cellValue("Ontslag_Aansluiting",$rijenteller,2,$personen_zelfdedoss->{$rrnr}->{'aansluitingsdatum'});
		  $cell = $doc->getCell("Ontslag_Aansluiting",$rijenteller,3);
		  my $eind_datum = $personen_zelfdedoss->{$rrnr}->{'afsluitingsdatum'};
		  $eind_datum = '99/99/9999' if ($personen_zelfdedoss->{$rrnr}->{'afsluitingsdatum'} eq '31/12/2099');
		  $doc->cellValue("Ontslag_Aansluiting",$rijenteller,3,$eind_datum);
		  $rijenteller +=1;
		}
	     }
	    
	     
	    
	    #opslagnaam bepalen
	    # we nemen de naam van het sjabloon en plaatsen er het inz nr voor
	    #evenweg
	    my $inz_nr_spatie = $oodoc_variabelen{'rijksregisternummer_spatie'};
	    $inz_nr_spatie =~ s/\s/-/g; #spaties van inz worden -
	    my $inz_nr_g_sp =$inz_nr_spatie;
	    $inz_nr_g_sp =~ s/-//g;
	    my $stukfile = $sjabloon;
	    #print "voor match: $stukfile\n";
	    $stukfile =~ s%/%:%g;
	    my @filename = split(/:/,$stukfile);
	    my $file1 = pop (@filename);
	    my $file = '';
	    my @filename1 = split(/\\/,$file1);
	    foreach my $entry (@filename1) {
	     if ($entry =~ m%\.odt$% ) {
		 $file = $entry;
		}
	     if ($entry =~ m%\.ods$% ) {
		 $file = $entry;
		}     
	    }
	     $file =~ s%.\w{3}$%%;
	     
	    my $naam_verzekering = $oodoc_variabelen{'verzekering'};
	    $naam_verzekering =~ s/\s//g;
	    $naam_verzekering =~ s/\&/_/g;
	    my $barcode_nr=$inz_nr_g_sp;
	    eval {my $element =  $doc->getImageElement('BarCode');}; #7.7 versi 7.7 barcode
	    if (!$@) {
	      my $element =  $doc->getImageElement('BarCode');
	      $doc->importImage('BarCode', $BarName) ;
	      open(my $png, ">", $BarName ) || die("Cannnot open $BarName: $!");
	      binmode($png);
	      if ($catlogkey ne '') {
		 $barcode_nr = $barcode_nr."$catlogkey";
		}
	      print $png $object->png($barcode_nr);
	      close($png);
	     }
	    if ($oodoc_variabelen{'bestaat_in_xml'} != 1) {
	      $documentplaats =$main::agresso_instellingen->{'plaats_brieven_cache'};
	    }
	    my $printfilename = "$documentplaats\\$inz_nr_spatie.$oodoc_variabelen{'datum_min'}.$oodoc_variabelen{uur}.$oodoc_variabelen{'ziekenfonds'}.-$verz_doorgeef\-.$file.$oodoc_variabelen{'gebruikersnaam'}.odt";
	    unlink "$documentplaats\\$inz_nr_spatie.$oodoc_variabelen{'datum_min'}.$oodoc_variabelen{uur}.$oodoc_variabelen{'ziekenfonds'}.-$verz_doorgeef\-.$file.$oodoc_variabelen{'gebruikersnaam'}.odt";
	    $doc->save("$documentplaats\\$inz_nr_spatie.$oodoc_variabelen{'datum_min'}.$oodoc_variabelen{uur}.$oodoc_variabelen{'ziekenfonds'}.-$verz_doorgeef\-.$file.$oodoc_variabelen{'gebruikersnaam'}.odt");
	    
	    $doc->dispose;
	   # soffice --headless --convert-to <TargetFileExtension>:<NameOfFilter> file_to_convert.xxx
	    my $OO_instpath = &dir__OO;
	    my $gelukt_pdf = '';
	   
	    if (uc $oodoc_variabelen{'moet_geprint'} eq 'JA' or uc $oodoc_variabelen{'moet_geprint'} eq 'YES') {
	      if (uc $oodoc_variabelen{'pdf_naar_agresso'} eq 'JA' or uc $oodoc_variabelen{'pdf_naar_agresso'} eq 'YES') {
		 $gelukt_pdf = &maak_pdf ($printfilename,$OO_instpath,$file,$inz_nr_spatie);
	       }
	      my $printer = $oodoc_variabelen{'printer'};
	      if ($printer ne '') {
		  print "\nprinter is $printer\n";
		  print "\nsoffice.exe, '-norestore','-headless','-pt',+ $printer,+ $printfilename\n";		  
		  system(1,"$OO_instpath\\program\\soffice.exe", '-norestore','-headless','-pt',+ $printer,+ $printfilename);
		}else {
		  print "\ngeen printer\n";
		  system(1,"$OO_instpath\\program\\soffice.exe", '-norestore','-headless','-p',+ $printfilename);              
		}
	       
	      
	    }elsif ($oodoc_variabelen{'geenpath'} == 1) {
		if (!defined $oodoc_variabelen{'popup'}  ) {
		     $oodoc_variabelen{'popup'} = 'JA';
		}
		
	      if (uc $oodoc_variabelen{'popup'} eq 'JA')  {
              print "\"$OO_instpath\\program\\soffice.exe\" $documentplaats\\$inz_nr_spatie.$oodoc_variabelen{'datum_min'}.$oodoc_variabelen{uur}.$oodoc_variabelen{'ziekenfonds'}.-$verz_doorgeef\-.$file.$oodoc_variabelen{'gebruikersnaam'}.odt\n";
		  system(1, "\"$OO_instpath\\program\\soffice.exe\"",'-norestore','-headless',
	         "$documentplaats\\$inz_nr_spatie.$oodoc_variabelen{'datum_min'}.$oodoc_variabelen{uur}.$oodoc_variabelen{'ziekenfonds'}.-$verz_doorgeef\-.$file.$oodoc_variabelen{'gebruikersnaam'}.odt");
              #die;
	      }
	     
	     }
	    
	    for (keys %oodoc_variabelen) {
	      delete $oodoc_variabelen{$_};
	    }
	   return ($printfilename);  
	}else {
	   return ('error file bestaat niet');
	}
	
       
}
sub maak_pdf {
    my ($filename,$openoffice_dir,$file,$inz_nr_spatie)=  @_;
    my $home_dir = "$ENV{USERPROFILE}"  ;
    $inz_nr_spatie =~ s/-//g;
    my $home_file = "$home_dir\\$inz_nr_spatie-brief.odt";
    my $pdfname = "$home_dir\\$inz_nr_spatie-$file.pdf";
    unlink $home_file;
    copy ($filename  => $home_file);    
    unlink "$pdfname" ; #or &sluit_kwijting if (-e "$home_dir\\$externnummer-kwijting.pdf");
    unlink "$home_dir\\$inz_nr_spatie\-$file.pdf";
    my $macro= "macro:///ConversionLibrary.PDFConversion.ConvertWordToPdf($home_dir\\$inz_nr_spatie-brief.odt,$home_dir\\$inz_nr_spatie\-$file.pdf)";
    my $gedaan= system(1,"$openoffice_dir\\program\\soffice.exe", '-invisible','-norestore',+ $macro);
    waitpid($gedaan, 0);
    my $emergency = 0;
    my $no_pdf = 0;
    until (-e "$home_dir\\$inz_nr_spatie\-$file.pdf") {
       sleep 1;
       $emergency +=1;
       print "$emergency \n";
       if ($emergency == 80) {
          my $macro= "macro:///ConversionLibrary.PDFConversion.ConvertWordToPdf($home_dir\\$inz_nr_spatie-brief.odt,$home_dir\\$inz_nr_spatie\-$file.pdf)";
          $emergency = 0;
          until (-e "$home_dir\\$inz_nr_spatie\-$file.pdf") {
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
    
    &zet_logo("$home_dir\\$inz_nr_spatie\-$file.pdf");
    print "pdf_gedaan $gedaan\n";
    unlink $home_file;
    $main::klant->{file_encode64} =webservice_pdf_to_Agresso->convert_base64("$home_dir\\$inz_nr_spatie\-$file\.pdf") if ($no_pdf == 0);
    my ($gelukt,$mydocid) = webservice_pdf_to_Agresso->PDF_naar_Agresso($filename) if ($no_pdf == 0);
    if ($gelukt eq 'gelukt') {
       ($gelukt,$mydocid) = Webservice_pdf_to_Cataloog->Cataloog_createEventWithWarning("$home_dir\\$inz_nr_spatie\-$file\.pdf") if ($no_pdf == 0);
       unlink ("$home_dir\\$inz_nr_spatie\-$file\.pdf");
    }elsif ($no_pdf == 0) {
       ($gelukt,$mydocid) = webservice_pdf_to_Agresso->PDF_naar_Agresso($filename);
       unlink ("$home_dir\\$inz_nr_spatie\-$file\.pdf");
       
    }
    return ($gelukt);
  
}
sub zet_logo {
         use PDF::API2;
         my $pdfname = shift @_;
         my $openoffice_dir = &dir__OO;
         my $home_dir = "$ENV{USERPROFILE}"  ;
         my $dienst_achtergrond = "$main::agresso_instellingen->{plaats_background_pdf}";
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
sub delfiles {
         #haal de directorY
         my $dirtoempty= shift @_;
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
sub get_windows_user {
     my $name;
     $name = Win32::LoginName(); # or whatever function you'd like
     $name = uc($name);
     #print "gebruikersnaam = $name\n";
     return ($name) ;    
} 
sub alle_verzekeringen { #is naar Agresso
     my $alle_verzekeringen = '';
     my $eerste =0;
     my $parser1 = DateTime::Format::Strptime->new(pattern => '%d/%m/%Y');
     my $parser = DateTime::Format::Strptime->new(pattern => '%d-%m-%Y');
     my $vandaag = ParseDate("today");
     $vandaag = substr ($vandaag,0,8);  # vandaag in YYYYMMDD
     #my $test = $main::klant;
     if (defined $main::klant->{contracten}->[0]->{naam}) {
         foreach my $nr (sort keys $main::klant->{contracten}) {
             if (defined $main::klant->{contracten}->[$nr]->{naam}) {
                 my $eind_datum = $main::klant->{contracten}->[$nr]->{einddatum};
                 $eind_datum = $parser->parse_datetime($eind_datum);
                 $eind_datum = $eind_datum->strftime('%Y%m%d');
                 my $begin_datum = $main::klant->{contracten}->[$nr]->{startdatum};
                 $begin_datum = $parser->parse_datetime($begin_datum);
                 $begin_datum = $begin_datum->strftime('%Y%m%d');
                 if ($vandaag >= $begin_datum and $vandaag <= $eind_datum) {
                     my $verzekering =$main::klant->{contracten}->[$nr]->{naam};
                     $verzekering =~ s%\_% \& %;
                     $alle_verzekeringen = "$verzekering" if ($eerste == 0);
                     $alle_verzekeringen = "$alle_verzekeringen"." en $verzekering" if ($eerste != 0);
                     $eerste +=1;
                    }
                }
            }
        }
     return ($alle_verzekeringen,$eerste)
    }

sub zoek_zelfde_dossier {
     my $contract_nr = shift @_;
     my $vandaag = ParseDate("today");
     $vandaag = substr ($vandaag,0,8);  # vandaag in YYYYMMDD
     $personen_zelfdedoss= ();
     my $rijksregnr;
     my $link="";
     $ENV{HTTPS_DEBUG} = 1;
     $ENV{HTTP_DEBUG} = 1;
     #$clientnummer = 102301;
     my $ip = $main::agresso_instellingen->{"Agresso_IP_$main::test_prod"};;      
     my $proxy = 'http://$ip/service.svc?QueryEngineService/QueryEngineV201101'; # productie    
     my $uri   = 'http://services.agresso.com/QueryEngineService/QueryEngineV201101';
     my $soap = SOAP::Lite
            ->proxy($proxy)
            ->ns($uri,'query')
            ->on_action( sub { return 'GetTemplateResultAsDataSet' } );
     my $template    = SOAP::Data->name('query:TemplateId' => "4559")->type('');
     my $pipeline    = SOAP::Data->name('query:PipelineAssociatedName' => "false")->type('');
     #my $ColumnName  = SOAP::Data->name('query:ColumnName'=> 'r0#contract_nr#44')->type('');
     my $ColumnName  = SOAP::Data->name('query:ColumnName'=> 'r0#contract_nr#37')->type('');
     my $RestrictionType= SOAP::Data->name('query:RestrictionType' => "=")->type('');
     my $FromValue = SOAP::Data->name('query:FromValue' => "$contract_nr")->type('');
     my $DataType = SOAP::Data->name('query:DataType' => "10")->type('');
     my $DataLength = SOAP::Data->name('query:DataLength' => "20")->type('');
     my $DataCase = SOAP::Data->name('query:DataCase' => "0")->type('');
     my $IsParameter = SOAP::Data->name('query:IsParameter' => "true")->type('');
     my $IsVisible =SOAP::Data->name('query:IsVisible' => "true")->type('');
     my $IsPrompt =SOAP::Data->name('query:IsPrompt' => "false")->type('');
     my $IsMandatory =SOAP::Data->name('query:IsMandatory' => "false")->type('');
     my $CanBeOverridden =SOAP::Data->name('query:CanBeOverridden' => "false")->type('');
     my $SearchCriteriaProperties = SOAP::Data->name('query:SearchCriteriaProperties')
          ->value(\SOAP::Data->value($ColumnName, $RestrictionType,$FromValue,$DataType,$DataLength
                                     ,$DataCase,$IsParameter,$IsVisible,$IsPrompt,$IsMandatory,$CanBeOverridden));
     my $SearchCriteriaPropertiesList=  SOAP::Data->name('query:SearchCriteriaPropertiesList')
          ->value(\SOAP::Data->value($SearchCriteriaProperties));   
     my $input       = SOAP::Data->name('query:input') ->value(\SOAP::Data->value($template, $pipeline,$SearchCriteriaPropertiesList));
     my $Username    = SOAP::Data->name('query:Username' => 'WEBSERV')->type('');
     my $Client      = SOAP::Data->name('query:Client'   => 'VMOB')->type('');
     my $Password    = SOAP::Data->name('query:Password' => 'WEBSERV')->type('');
     my $credentials = SOAP::Data->name('query:credentials') ->value(\SOAP::Data->value($Username, $Client, $Password));
     my $response = $soap->mySOAPFunction($input,$credentials);  
     eval {my $faultstring = $response->{_content}[2][0][2][0][4]->{faultstring}};
     if ($@) {
         if (defined $response->{_content}[2][0][2][0][4]->{faultstring}) {
             my $faultstring = $response->{_content}[2][0][2][0][4]->{faultstring};
             my $tekst = "AGRESSO NOK $faultstring";
             return ($tekst);  #code
            }
      }
     eval {my $returncode =$response->{_content}[2][0][2][0][4]->{GetTemplateResultAsDataSetResult}->{ReturnCode}};        
     if ( $response->{_content}[2][0][2][0][4]->{GetTemplateResultAsDataSetResult}->{ReturnCode} == 0 and !$@) {
         eval {my $er_is_een_antwoord = $response->{_content}[2][0][2][0][4]->{GetTemplateResultAsDataSetResult}->{TemplateResult}->{diffgram}->{Agresso}->{AgressoQE}};
         if (!$@) {
             $link= $response->{_content}[2][0][2][0][4]->{GetTemplateResultAsDataSetResult}->{TemplateResult}->{diffgram}->{Agresso}->{AgressoQE};
             eval {my $bestaat = $link->[0]->{apar_id}};
             if ($@) {
                 eval {my $bestaat1 = $link->{apar_id}};
                 if (!$@) {
                     $rijksregnr =  $link->{ext_apar_ref};
                     my $test_geslacht = substr($rijksregnr,8,1);
                     $test_geslacht = $test_geslacht % 2;
                     my $geslacht = '';
                     if ($test_geslacht == 0) {
                         $geslacht = 'vrouw';
                        }else {
                         $geslacht = 'man';
                        }
                     my $parser1 = DateTime::Format::Strptime->new(pattern => '%Y-%m-%d');
                    
                     my $einddatum =  $link->{r2_x0023_einddatum_x0023_36};
                     $einddatum = $parser1->parse_datetime($einddatum) if ($einddatum);                    
                     my $eind_datum = $einddatum->strftime('%d/%m/%Y') if ($einddatum);
                     $einddatum = $einddatum->strftime('%Y%m%d');
                     
                     my $begindatum = $link->{r2_x0023_startdatum_x0023_34};
                     $begindatum = $parser1->parse_datetime($begindatum) if ($begindatum);       
                     my $begin_datum = $begindatum->strftime('%d/%m/%Y') if ($begindatum);
                     $begindatum = $begindatum->strftime('%Y%m%d') if ($begindatum);
                     my $geboortedatum = $link->{r1_x0023_geboortedatum_x0023_20};
                     $geboortedatum = $parser1->parse_datetime($geboortedatum) if ($geboortedatum);      
                     my $geboorte_datum = $geboortedatum->strftime('%d/%m/%Y') if ($geboortedatum);
                     if ($vandaag <= $einddatum +10000 and $vandaag >= $begindatum -10000) {
			  my $bestaat_ja = $personen_zelfdedoss->{$rijksregnr};
			     #eval {my $bestaat_ja = $personen_zelfdedoss->{$rijksregnr}};
			     if ($bestaat_ja eq '') {
				  $personen_zelfdedoss->{$rijksregnr} = {
				    'ziekenfonds' =>$link->{r3_x0023_zkf_nr_x0023_45},
				    'externnummer' => '',
				    'rijksregisternummer' => "$rijksregnr",
				    'naam' => $link->{apar_name},
				    'voornaam' => "",
				    'geboortedatum' => $geboorte_datum,
				    'geslacht' => $geslacht,
				    'tit_ptl' =>  $link->{description},
				    'bijdrage' => 0,
				    'aansluitingsdatum' => "$begin_datum",
				    'afsluitingsdatum' => "$eind_datum",
				    'aansluitingscode' => "",
				    'ontslagcode' => "",
				    'product' =>"$link->{r2_x0023_product_x0023_40_x0023_O111}"
				   };
			     }else {
				    my $parser2 = DateTime::Format::Strptime->new(pattern => '%d/%m/%Y');
				    my $einddatum_test =  $personen_zelfdedoss->{$rijksregnr}->{afsluitingsdatum};
				    $einddatum_test = $parser2->parse_datetime($einddatum_test);
				    my $einddatum_testYYYYMMDD = $einddatum_test->strftime('%Y%m%d');
				    if ($einddatum_testYYYYMMDD < $einddatum) {
					 $personen_zelfdedoss->{$rijksregnr} = {
					    'ziekenfonds' =>$link->{r3_x0023_zkf_nr_x0023_45},
					    'externnummer' => '',
					    'rijksregisternummer' => "$rijksregnr",
					    'naam' => $link->{apar_name},
					    'voornaam' => "",
					    'geboortedatum' => $geboorte_datum,
					    'geslacht' => $geslacht,
					    'tit_ptl' =>  $link->{description},
					    'bijdrage' => 0,
					    'aansluitingsdatum' => "$begin_datum",
					    'afsluitingsdatum' => "$eind_datum",
					    'aansluitingscode' => "",
					    'ontslagcode' => "",
					    'product' =>"$link->{r2_x0023_product_x0023_40_x0023_O111}"
					   };
				    }
				    
				  
				}
                         #$personen_zelfdedoss->{$rijksregnr} = {
                         #    'ziekenfonds' =>$link->{r3_x0023_zkf_nr_x0023_45},
                         #    'externnummer' => '',
                         #    'rijksregisternummer' => "$rijksregnr",
                         #    'naam' => $link->{apar_name},
                         #    'voornaam' => "",
                         #    'geboortedatum' => $geboorte_datum,
                         #    'geslacht' => $geslacht,
                         #    'tit_ptl' =>  $link->{description},
                         #    'bijdrage' => 0,
                         #    'aansluitingsdatum' => "$begin_datum",
                         #    'afsluitingsdatum' => "$eind_datum",
                         #    'aansluitingscode' => "",
                         #    'ontslagcode' => "",
                         #    'product' =>"$link->{r2_x0023_product_x0023_40_x0023_O111}"
                         #   };
                        }                         
                    }
                }else {
                 foreach my $nr (sort keys $link) {
                     eval {my $bestaat1 = $link->[$nr]->{apar_id}};
                     if (!$@) {
                         $rijksregnr =  $link->[$nr]->{ext_apar_ref};
                         my $test_geslacht = substr($rijksregnr,8,1);
                         $test_geslacht = $test_geslacht % 2;
                         my $geslacht = '';
                         if ($test_geslacht == 0) {
                              $geslacht = 'vrouw';
                            }else {
                             $geslacht = 'man';
                            }
                         my $parser1 = DateTime::Format::Strptime->new(pattern => '%Y-%m-%d');
                         my $einddatum =  $link->[$nr]->{r2_x0023_einddatum_x0023_36};
                         $einddatum = $parser1->parse_datetime($einddatum);                    
                         my $eind_datum = $einddatum->strftime('%d/%m/%Y');
                         $einddatum = $einddatum->strftime('%Y%m%d');
                         my $begindatum = $link->[$nr]->{r2_x0023_startdatum_x0023_34};
                         $begindatum = $parser1->parse_datetime($begindatum);       
                         my $begin_datum = $begindatum->strftime('%d/%m/%Y');
                         $begindatum = $begindatum->strftime('%Y%m%d');
                         my $geboortedatum = $link->[$nr]->{r1_x0023_geboortedatum_x0023_20};
                         $geboortedatum = $parser1->parse_datetime($geboortedatum);      
                         my $geboorte_datum = $geboortedatum->strftime('%d/%m/%Y') if ($geboortedatum);
                         if ($vandaag <= $einddatum + 10000 and $vandaag >= $begindatum -10000) {
			     my $bestaat_ja = $personen_zelfdedoss->{$rijksregnr};
			     #eval {my $bestaat_ja = $personen_zelfdedoss->{$rijksregnr}};
			     if ($bestaat_ja eq '') {
				  $personen_zelfdedoss->{$rijksregnr} = {
				    'ziekenfonds' =>$link->[$nr]->{r3_x0023_zkf_nr_x0023_45},
				    'externnummer' => '',
				    'rijksregisternummer' => "$rijksregnr",
				    'naam' => $link->[$nr]->{apar_name},
				    'voornaam' => "",
				    'geboortedatum' => $geboorte_datum,
				    'geslacht' => $geslacht,
				    'tit_ptl' =>  $link->[$nr]->{description},
				    'bijdrage' => 0,
				    'aansluitingsdatum' => "$begin_datum",
				    'afsluitingsdatum' => "$eind_datum",
				    'aansluitingscode' => "",
				    'ontslagcode' => "",
				    'product' =>"$link->[$nr]->{r2_x0023_product_x0023_40_x0023_O111}"
				   };
			     }else {
				    my $parser2 = DateTime::Format::Strptime->new(pattern => '%d/%m/%Y');
				    my $einddatum_test =  $personen_zelfdedoss->{$rijksregnr}->{afsluitingsdatum};
				    $einddatum_test = $parser2->parse_datetime($einddatum_test);
				    my $einddatum_testYYYYMMDD = $einddatum_test->strftime('%Y%m%d');
				    if ($einddatum_testYYYYMMDD < $einddatum) {
					 $personen_zelfdedoss->{$rijksregnr} = {
					    'ziekenfonds' =>$link->[$nr]->{r3_x0023_zkf_nr_x0023_45},
					    'externnummer' => '',
					    'rijksregisternummer' => "$rijksregnr",
					    'naam' => $link->[$nr]->{apar_name},
					    'voornaam' => "",
					    'geboortedatum' => $geboorte_datum,
					    'geslacht' => $geslacht,
					    'tit_ptl' =>  $link->[$nr]->{description},
					    'bijdrage' => 0,
					    'aansluitingsdatum' => "$begin_datum",
					    'afsluitingsdatum' => "$eind_datum",
					    'aansluitingscode' => "",
					    'ontslagcode' => "",
					    'product' =>"$link->[$nr]->{r2_x0023_product_x0023_40_x0023_O111}"
					   };
				    }
				    
				  
				}
			     
                            
                            }                 
                        }
                    }
                }  
            }
        }
     print "";   
    }

sub checkwonendopzelfdeadres {
     my $address_type = shift @_;
     my $address = shift @_;
     my $zip_code = shift @_;
     my $place = shift @_;
     my $link = '';
     $personen_zelfdeadres = ();
     $ENV{HTTPS_DEBUG} = 1;
     $ENV{HTTP_DEBUG} = 1;
     #$clientnummer = 102301;10.198.206.217
     my $ip = $main::agresso_instellingen->{"Agresso_IP_$main::test_prod"};;      
     my $proxy = 'http://$ip/service.svc?QueryEngineService/QueryEngineV201101';    
     my $uri   = 'http://services.agresso.com/QueryEngineService/QueryEngineV201101';
     my $soap = SOAP::Lite
            ->proxy($proxy)
            ->ns($uri,'query')
            ->on_action( sub { return 'GetTemplateResultAsDataSet' } );
     my $template    = SOAP::Data->name('query:TemplateId' => "4558")->type('');
     my $pipeline    = SOAP::Data->name('query:PipelineAssociatedName' => "false")->type('');
     my $ColumnName  = SOAP::Data->name('query:ColumnName'=> 'address_type')->type('');
     my $RestrictionType= SOAP::Data->name('query:RestrictionType' => "=")->type('');
     my $FromValue = SOAP::Data->name('query:FromValue' => "$address_type")->type('');
     my $DataType = SOAP::Data->name('query:DataType' => "10")->type('');
     my $DataLength = SOAP::Data->name('query:DataLength' => "25")->type('');
     my $DataCase = SOAP::Data->name('query:DataCase' => "2")->type('');
     my $IsParameter = SOAP::Data->name('query:IsParameter' => "true")->type('');
     my $IsVisible =SOAP::Data->name('query:IsVisible' => "true")->type('');
     my $IsPrompt =SOAP::Data->name('query:IsPrompt' => "false")->type('');
     my $IsMandatory =SOAP::Data->name('query:IsMandatory' => "false")->type('');
     my $CanBeOverridden =SOAP::Data->name('query:CanBeOverridden' => "false")->type('');
     my $SearchCriteriaProperties_address_type = SOAP::Data->name('query:SearchCriteriaProperties')
          ->value(\SOAP::Data->value($ColumnName, $RestrictionType,$FromValue,$DataType,$DataLength
                                     ,$DataCase,$IsParameter,$IsVisible,$IsPrompt,$IsMandatory,$CanBeOverridden));
     $ColumnName  = SOAP::Data->name('query:ColumnName'=> 'address')->type('');
     $RestrictionType= SOAP::Data->name('query:RestrictionType' => "=")->type('');
     $FromValue = SOAP::Data->name('query:FromValue' => "$address")->type('');
     $DataType = SOAP::Data->name('query:DataType' => "10")->type('');
     $DataLength = SOAP::Data->name('query:DataLength' => "160")->type('');
     $DataCase = SOAP::Data->name('query:DataCase' => "0")->type('');
     $IsParameter = SOAP::Data->name('query:IsParameter' => "true")->type('');
     $IsVisible =SOAP::Data->name('query:IsVisible' => "true")->type('');
     $IsPrompt =SOAP::Data->name('query:IsPrompt' => "false")->type('');
     $IsMandatory =SOAP::Data->name('query:IsMandatory' => "false")->type('');
     $CanBeOverridden =SOAP::Data->name('query:CanBeOverridden' => "false")->type('');
     my $SearchCriteriaProperties_address = SOAP::Data->name('query:SearchCriteriaProperties')
          ->value(\SOAP::Data->value($ColumnName, $RestrictionType,$FromValue,$DataType,$DataLength
                                     ,$DataCase,$IsParameter,$IsVisible,$IsPrompt,$IsMandatory,$CanBeOverridden));
     $ColumnName  = SOAP::Data->name('query:ColumnName'=> 'zip_code')->type('');
     $RestrictionType= SOAP::Data->name('query:RestrictionType' => "=")->type('');
     $FromValue = SOAP::Data->name('query:FromValue' => "$zip_code")->type('');
     $DataType = SOAP::Data->name('query:DataType' => "10")->type('');
     $DataLength = SOAP::Data->name('query:DataLength' => "15")->type('');
     $DataCase = SOAP::Data->name('query:DataCase' => "0")->type('');
     $IsParameter = SOAP::Data->name('query:IsParameter' => "true")->type('');
     $IsVisible =SOAP::Data->name('query:IsVisible' => "true")->type('');
     $IsPrompt =SOAP::Data->name('query:IsPrompt' => "false")->type('');
     $IsMandatory =SOAP::Data->name('query:IsMandatory' => "false")->type('');
     $CanBeOverridden =SOAP::Data->name('query:CanBeOverridden' => "false")->type('');
     my $SearchCriteriaProperties_zip_code = SOAP::Data->name('query:SearchCriteriaProperties')
          ->value(\SOAP::Data->value($ColumnName, $RestrictionType,$FromValue,$DataType,$DataLength
                                     ,$DataCase,$IsParameter,$IsVisible,$IsPrompt,$IsMandatory,$CanBeOverridden));
     $ColumnName  = SOAP::Data->name('query:ColumnName'=> 'place')->type('');
     $RestrictionType= SOAP::Data->name('query:RestrictionType' => "=")->type('');
     $FromValue = SOAP::Data->name('query:FromValue' => "$place")->type('');
     $DataType = SOAP::Data->name('query:DataType' => "10")->type('');
     $DataLength = SOAP::Data->name('query:DataLength' => "25")->type('');
     $DataCase = SOAP::Data->name('query:DataCase' => "2")->type('');
     $IsParameter = SOAP::Data->name('query:IsParameter' => "true")->type('');
     $IsVisible =SOAP::Data->name('query:IsVisible' => "true")->type('');
     $IsPrompt =SOAP::Data->name('query:IsPrompt' => "false")->type('');
     $IsMandatory =SOAP::Data->name('query:IsMandatory' => "false")->type('');
     $CanBeOverridden =SOAP::Data->name('query:CanBeOverridden' => "false")->type('');
     my $SearchCriteriaProperties_place = SOAP::Data->name('query:SearchCriteriaProperties')
          ->value(\SOAP::Data->value($ColumnName, $RestrictionType,$FromValue,$DataType,$DataLength
                                     ,$DataCase,$IsParameter,$IsVisible,$IsPrompt,$IsMandatory,$CanBeOverridden));
     my $SearchCriteriaPropertiesList= '';
     if ($address_type eq '') {
           $SearchCriteriaPropertiesList=  SOAP::Data->name('query:SearchCriteriaPropertiesList')
          ->value(\SOAP::Data->value($SearchCriteriaProperties_address,$SearchCriteriaProperties_zip_code,
                                     $SearchCriteriaProperties_place));  
     }else {
          $SearchCriteriaPropertiesList=  SOAP::Data->name('query:SearchCriteriaPropertiesList')
          ->value(\SOAP::Data->value($SearchCriteriaProperties_address,$SearchCriteriaProperties_zip_code,
                                     $SearchCriteriaProperties_place,$SearchCriteriaProperties_address_type));  
     }
     
     
     my $input       = SOAP::Data->name('query:input') ->value(\SOAP::Data->value($template, $pipeline,$SearchCriteriaPropertiesList));
     my $Username    = SOAP::Data->name('query:Username' => 'WEBSERV')->type('');
     my $Client      = SOAP::Data->name('query:Client'   => 'VMOB')->type('');
     my $Password    = SOAP::Data->name('query:Password' => 'WEBSERV')->type('');
     my $credentials = SOAP::Data->name('query:credentials') ->value(\SOAP::Data->value($Username, $Client, $Password));
     my $response = $soap->mySOAPFunction($input,$credentials);  
     eval {my $faultstring = $response->{_content}[2][0][2][0][4]->{faultstring}};
     if ($@) {
         if (defined $response->{_content}[2][0][2][0][4]->{faultstring}) {
             my $faultstring = $response->{_content}[2][0][2][0][4]->{faultstring};
             my $tekst = "AGRESSO NOK $faultstring";
             return ($tekst);  #code
            }
        }
     eval {my $returncode =$response->{_content}[2][0][2][0][4]->{GetTemplateResultAsDataSetResult}->{ReturnCode}};        
     if ( $response->{_content}[2][0][2][0][4]->{GetTemplateResultAsDataSetResult}->{ReturnCode} == 0 and !$@) {
         eval {my $er_is_een_antwoord = $response->{_content}[2][0][2][0][4]->{GetTemplateResultAsDataSetResult}->{TemplateResult}->{diffgram}->{Agresso}->{AgressoQE}};
         if (!$@) {
             $link= $response->{_content}[2][0][2][0][4]->{GetTemplateResultAsDataSetResult}->{TemplateResult}->{diffgram}->{Agresso}->{AgressoQE};
             eval {my $bestaat = $link->[0]->{apar_id}};
             if ($@) {
                  my $rijksregnr =  $link->{ext_apar_ref};
                  #my $begin_zkf_dos ='';
                   my $begin_zkf_dos = $main::klant->{aansluit_datum_zkf}; 
                  $personen_zelfdeadres->{$rijksregnr} ={
                     'naam' =>  $link->{apar_name},
                     'rijksregisternummer' => "$rijksregnr",
                     'agresso_nr' =>  $link->{apar_id},
                     'straat' => $link->{address},
                     'postcode' => $link->{zip_code},
                     'stad' => $link->{place},
                     'country_code'=> $link->{country_code},
                     'address_type' => $link->{address_type},
                     'aansluitingsdatum' => $begin_zkf_dos ,
                    };
                }else {
                  foreach my $nr (sort keys $link) {
                     my $rijksregnr =  $link->[$nr]->{ext_apar_ref};
                     #my $begin_zkf_dos ='';
                     my $begin_zkf_dos = $main::klant->{aansluit_datum_zkf}; 
                     $personen_zelfdeadres->{$rijksregnr} ={
                         'naam' =>  $link->[$nr]->{apar_name},
                         'rijksregisternummer' => "$rijksregnr",
                         'agresso_nr' =>  $link->[$nr]->{apar_id},
                         'straat' => $link->[$nr]->{address},
                         'postcode' => $link->[$nr]->{zip_code},
                         'stad' => $link->[$nr]->{place},
                         'country_code'=> $link->[$nr]->{country_code},
                         'address_type' => $link->[$nr]->{address_type},
                         'aansluitingsdatum' => $begin_zkf_dos ,
                        };
                    }
                }
            }
        }
     print "";
     
    }

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
	 my $in_cataloog = 'ja';
	 my $test = $main::brieven_instellingen;
	 my $zoekbrief_in_instellingen = '';
	 $file =~ m/HOSP_.*/;	
	 $zoekbrief_in_instellingen = $&;
	 $zoekbrief_in_instellingen=~ s/\.pdf//;
	 $zoekbrief_in_instellingen=~ s/\.odt//;
	 $zoekbrief_in_instellingen=~ s/\.M\d{3}\w{4}//;
	 foreach my $key (sort keys $main::brieven_instellingen) {
	     if ($main::brieven_instellingen->{$key}->{sjabloon} =~ m/$zoekbrief_in_instellingen/ ) {
	         $in_cataloog = $main::brieven_instellingen->{$key}->{pdf_naar_agresso};
	         last;
	        }
	    }
	 if (uc $in_cataloog eq 'JA' or uc $in_cataloog eq 'YES') {
	     my $vandaag = ParseDate("today");
	     my $huidig_jaar = substr ($vandaag,0,4);
	     my $huidige_maand = substr ($vandaag,4,2);
	     my $huidige_dag = substr ($vandaag,6,2);
	     my $vandaag_dag = $huidig_jaar*10000+$huidige_maand*100+$huidige_dag;
	     my @maanden = ('januari','februari','maart','april','mei','juni','juli','augustus','september','oktober','november','december') ;
	     my $clientnummer = $main::klant->{Agresso_nummer};
	     ##$clientnummer = 67122533419;#;100048 100248 166516
	     use SOAP::Lite ;
           my $ip = $main::agresso_instellingen->{"Agresso_IP_$main::test_prod"};;      
	     my $proxy = 'http://$ip/service.svc?';	    
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
	     $folderRef_text =~ m/\d{6}-\d{3}-\d{2}\.\d+-\d+-\d+\.\d+u\d+\.\d{3}.*/;
	     $folderRef_text = $&;    
	     $folderRef_text =~ s/\d{6}-\d{3}-\d{2}\.\d+-\d+-\d+\.\d+u\d+.\d{3}\.//;     
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
	     my $link = $response->{_content}->[2]->[0]->[2]->[0]->[4]->{AddDocumentResult}->{Properties}->{DocumentProperties};
	     eval {my $gelukt = $link->{DocId}};
	     if (!$@) {
		 my $gelukt = $link->{DocId};
		 return ('gelukt',$gelukt);
		}else {
		 return ('mislukt');
		}
	    }else {
	     return ('niet nodig');
	    }
     
}



package Webservice_pdf_to_Cataloog;
     
     use SOAP::Lite ;
     #+trace => [ transport => sub { print $_[0]->as_string } ];
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
             
     sub Cataloog_createEventWithWarning {
	 my ($class,$file_name) = @_;
	 my $test = $main::brieven_instellingen;
	 $file_name =~ m/HOSP_\w+_/;
	 my $zoek_cat_key = '';
	 my $zoekbrief_in_instellingen = '';
	 $zoek_cat_key = $&;
	 #$file_name =~ m/HOSP_.*/;
	 $zoekbrief_in_instellingen = $&;
	 $zoekbrief_in_instellingen=~ s/\.pdf//;
	 $zoek_cat_key =~ s/HOSP//g;
	 $zoek_cat_key =~ s/_//g;
	 my $catalog_Key = '';
	 my $in_cataloog = 'ja';
	 # $zoekbrief_in_instellingen=~ s/\.odt//;
	 #$zoekbrief_in_instellingen=~ s/\.M\d{3}\w{4}//;
	 foreach my $key (sort keys $main::brieven_instellingen) {
	     if ($main::brieven_instellingen->{$key}->{sjabloon} =~ m/$zoekbrief_in_instellingen/ ) {
	         $in_cataloog = $main::brieven_instellingen->{$key}->{pdf_naar_gkd};
	         last;
	        }
	    }
	 if (uc $in_cataloog eq 'JA' or uc $in_cataloog eq 'YES') {
	     my $vandaag = ParseDate("today");
	     my $huidig_jaar = substr ($vandaag,0,4);
	     my $huidige_maand = substr ($vandaag,4,2);
	     my $huidige_dag = substr ($vandaag,6,2);
	     my $vandaag_dag = $huidig_jaar*10000+$huidige_maand*100+$huidige_dag;
	     my @maanden = ('januari','februari','maart','april','mei','juni','juli','augustus','september','oktober','november','december') ;
	     my $extern_nummer = $main::klant->{ExternNummer};
	     my $folderRef_text = $file_name;
	     $folderRef_text =~ m/\d+\-.*/;
	     $folderRef_text = $&;
	     $folderRef_text =~ s/\d+-//;
	     $folderRef_text =~ s/\.\w{1}\d{3}\w+//;
	     $folderRef_text =~ s/\.pdf$//;
	     $folderRef_text =~ s/\_her\d{1}//;
	     $folderRef_text =~ s/\_nops//;
	     $folderRef_text =~ s/\-geenmail//;
	     $folderRef_text = substr($folderRef_text,0,20);
	     if ($extern_nummer) {
	         $extern_nummer = sprintf("%013s", $extern_nummer );             
	         my $request = 'createEventWithWarning';            
		 my $domain = "$main::ziekenfonds_nummer";
		 my $zkf = "$main::ziekenfonds_nummer";
		 $catalog_Key =  $main::agresso_instellingen->{Doc_Archief}->{ziekenfondsen}->{"ZKF$zkf"}->{doc_in_naam_mapping}->{$zoek_cat_key}->{CAT} if ($zoek_cat_key ne '') ;
		 $catalog_Key =  $main::agresso_instellingen->{Doc_Archief}->{Catalog_key_Openoffice_brieven} if (!defined $catalog_Key or $catalog_Key eq '' );
		 my $user= $main::agresso_instellingen->{Doc_Archief}->{ziekenfondsen}->{"ZKF$zkf"}->{username};     	     #username as400
		 my $pass=decrypt->new( $main::agresso_instellingen->{Doc_Archief}->{ziekenfondsen}->{"ZKF$zkf"}->{password});              #paswoord
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
	  return ();
	}
       
      
    }
      
1;