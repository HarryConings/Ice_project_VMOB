#!/usr/bin/perl -w
#in GIT gezet
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
use strict;
require 'Decryp_Encrypt.pl';
use XML::Simple;
use Date::Manip::DM5;
use Time::Piece;
package main;
        our $instellingen = XMLin('P:\GIT\VNZ\gok_blII\settings\Gok_export_settings.xml'); #C:\macros\doccentermail
        our $vandaag = ParseDate("today");      
        my $home_dir = "$ENV{USERPROFILE}";
        #my $delta = new Date::Manip::Delta;
        my $delta =ParseDateDelta("4 business days ago");
        my $date = DateCalc($vandaag,$delta);
        if ($ARGV[0] =~ m/\d{8}/ and  $ARGV[0] > 20160101 ) {
               my $dat = substr($ARGV[0],0,8);
               $vandaag = "$dat".'18:50:50';
              }
        #$vandaag =20180112;
        our $huidig_jaar = substr ($vandaag,0,4);
        our $huidige_maand = substr ($vandaag,4,2);
        our $huidige_dag = substr ($vandaag,6,2);
        our $vandaag_dag = $huidig_jaar*10000+$huidige_maand*100+$huidige_dag;
        foreach my $MUT (sort keys $instellingen->{MUT}) {
                my $zkf = $instellingen->{MUT}->{$MUT}->{zkf};
                my $input_dir =  $instellingen->{MUT}->{$MUT}->{input_directory};
                my $mutnaam = $instellingen->{MUT}->{$MUT}->{naam};
                my $libcxfil =  $instellingen->{AS400}->{$MUT}->{libcxfil};
                my $libcxcom =  $instellingen->{AS400}->{$MUT}->{libcxcom};
                my $libcxref =  $instellingen->{AS400}->{$MUT}->{libcxref};
                my $username =  $instellingen->{AS400}->{$MUT}->{username};
                my $password = decrypt->new($instellingen->{AS400}->{$MUT}->{password});
                my $dbh = AS400->connect_db($username,$password);
               my $active;
               # verwerken active              
               $active = "$input_dir\\active.csv";
               my $possible =  "$input_dir\\active_possible.csv";
               my $impliciet_to_expleciet = "$input_dir\\impliciet_to_expleciet.csv";
               my $impossible =  "$input_dir\\active_impossible.csv";
               my $to_be_clarified  =  "$input_dir\\active_to_be_clarified.csv";
               main->verwerk_file($dbh,$MUT,$zkf,$active,$possible,$impossible,$to_be_clarified,$impliciet_to_expleciet);
               
               AS400->disconnect_db($dbh);
               
        }
        
        
        sub verwerk_file {
             my ($self,$dbh,$MUT,$zkf,$file,$possible,$impossible,$to_be_clarified,$impliciet_to_expleciet) = @_;
             my $libcxfil =  $instellingen->{AS400}->{$MUT}->{libcxfil};
             my $libcxcom =  $instellingen->{AS400}->{$MUT}->{libcxcom};
             my $libcxref =  $instellingen->{AS400}->{$MUT}->{libcxref};
             my $inlezenteller =0;
             my $ext_nr;
             open(my $pos, '>', $possible) or die "Could not open file $possible $!";
             print $pos "Holder,Subject,Donor,Completed,Startdate,INZ_holder,INZ_Subject,INZ_Donor,Type,Age_Subject,Info -> gives procuration\n";
             close $pos;
             open(my $impos, '>',$impossible) or die "Could not open file $impossible $!";
             print $impos "Holder,Subject,Donor,Completed,Startdate,INZ_holder,INZ_Subject,INZ_Donor,Type,Age_Subject,Info -> gives procuration\n";
             close $impos;
             open(my $clarified, '>',$to_be_clarified) or die "Could not open file $to_be_clarified $!";
             print $clarified "Holder,Subject,Donor,Completed,Startdate,INZ_holder,INZ_Subject,INZ_Donor,Type,Age_Subject,Info -> gives procuration\n";
             close $clarified;
             open(my $pos_ex, '>', $impliciet_to_expleciet) or die "Could not open file $impliciet_to_expleciet $!";
             print $pos_ex "Holder,Subject,Donor,Completed,Startdate,INZ_holder,INZ_Subject,INZ_Donor,Type,Age_Subject,explicit naar impliciet\n";
             close $pos_ex;
             #print "$path_to_files\\$spoollfile\n";
             open (LEDENFILE,"$file") or die "SPOOLFILE is er niet" ;
             my $lijnenteller = 0;
             my $lijnpos=0;
             my $lijnimpl=0;
             my $lijnimpos = 0;
             my $lijnclar =0;
             while (my $record = <LEDENFILE>) {
                    if ($lijnenteller ==0) {
                        
                    }else{
                        chomp $record;
                        my ($holder,$subject,$completed,$datestart) = split "," , $record;
                        my $holder_info = AS400->klantinfo($dbh,$libcxfil,$MUT,$zkf,$holder);
                        my $subject_info = AS400->klantinfo($dbh,$libcxfil,$MUT,$zkf,$subject);
                           my $vandaag_YYMMDD = substr($main::vandaag,0,8);
                           my $datvandaag =Time::Piece->strptime($vandaag_YYMMDD,"%Y%m%d");
                           my $datb = Time::Piece->strptime($subject_info->{geboortedatum}, "%Y%m%d");
                           my $diff = $datvandaag - $datb;
                           my $ouderdom = $diff->years;
                        print "";
                        my $age_subject = int($ouderdom);
                        if ($holder_info->{is_titularis} eq 'ja' and $subject_info->{is_titularis} eq 'ja'){
                             open(my $fh, '>>', $possible) or die "Could not open file '$possible' $!";
                             print  $fh "$holder_info->{inz_nr},$subject_info->{inz_nr},$subject_info->{inz_nr},$completed,$datestart,$holder_info->{inz_nr},$subject_info->{inz_nr},$subject_info->{inz_nr},Explecit,$age_subject,Tit -> Tit\n";
                             close $fh;
                             $lijnpos +=1;
                            }elsif ($holder_info->{is_titularis} eq 'ja' and $subject_info->{is_titularis} eq 'nee') {
                              if ($subject_info->{inz_Nr_tit} ==  $holder_info->{inz_nr}) {
                                   if ($ouderdom > 18) {
                                        open(my $fh, '>>', $possible) or die "Could not open file $possible $!";
                                        print  $fh "$holder_info->{inz_nr},$subject_info->{inz_nr},$subject_info->{inz_nr},$completed,$datestart,$holder_info->{inz_nr},$subject_info->{inz_nr},$subject_info->{inz_nr},Explecit,$age_subject,PAC -> Own TIT\n";
                                        close $fh;
                                        open($fh, '>>',$impliciet_to_expleciet) or die "Could not open file $impliciet_to_expleciet $!";
                                        print  $fh "$holder_info->{inz_nr},$subject_info->{inz_nr},$subject_info->{inz_nr},$completed,$datestart,$holder_info->{inz_nr},$subject_info->{inz_nr},$subject_info->{inz_nr},Explecit,$age_subject,PAC -> impliciet->expleciet\n";
                                        close $fh;
                                        $lijnpos +=1;
                                        $lijnimpl +=1;
                                    }else {
                                        open(my $fh, '>>', $possible) or die "Could not open file $possible $!";
                                        print  $fh "$holder_info->{inz_nr},$subject_info->{inz_nr},$subject_info->{inz_nr},$completed,$datestart,$holder_info->{inz_nr},$subject_info->{inz_nr},$subject_info->{inz_Nr_tit},Implecit,$age_subject,PAC <18 -> own TIT\n";
                                        close $fh;
                                        $lijnpos +=1;
                                    }
                                }else {                                  
                                     if ($ouderdom > 18) {
                                        open(my $fh, '>>', $impossible) or die "Could not open file $impossible $!";
                                        print  $fh "$holder_info->{inz_nr},$subject_info->{inz_nr},$subject_info->{inz_nr},$completed,$datestart,$holder_info->{inz_nr},$subject_info->{inz_nr},$subject_info->{inz_nr},Explecit,$age_subject,PAC > 18 -> other than own TIT\n";
                                        close $fh;
                                        $lijnimpos +=1;
                                        #print "";
                                     }else {
                                        open(my $fh, '>>', $to_be_clarified) or die "Could not open file $to_be_clarified $!";
                                        print  $fh "$holder_info->{inz_nr},$subject_info->{inz_nr},$subject_info->{inz_nr},$completed,$datestart,$holder_info->{inz_nr},$subject_info->{inz_nr},$subject_info->{inz_Nr_tit},Explecit,$age_subject, heeft $subject_info->{inz_Nr_tit} de volmacht gegeven?\n";
                                        close $fh;
                                        $lijnclar +=1;
                                        #print "";
                                     }
                                }
                            
                            }elsif ($holder_info->{is_titularis} eq 'nee' and $subject_info->{is_titularis} eq 'ja') {
                                        open(my $fh, '>>', $impossible) or die "Could not open file $impossible $!";
                                        print  $fh "$holder_info->{inz_nr},$subject_info->{inz_nr},$subject_info->{inz_nr},$completed,$datestart,$holder_info->{inz_nr},$subject_info->{inz_nr},$subject_info->{inz_nr},Explecit,$age_subject,TIT -> PAC\n";
                                        close $fh;
                                        $lijnimpos +=1;
                                        #print "";
                            }elsif ($holder_info->{is_titularis} eq 'nee' and $subject_info->{is_titularis} eq 'nee') {
                                       if ($ouderdom > 18) {
                                            open(my $fh, '>>', $impossible) or die "Could not open file $impossible $!";
                                            print  $fh "$holder_info->{inz_nr},$subject_info->{inz_nr},$subject_info->{inz_nr},$completed,$datestart,$holder_info->{inz_nr},$subject_info->{inz_nr},$subject_info->{inz_nr},Explecit,$age_subject,PAC > 18 -> PAC\n";
                                            close $fh;
                                            $lijnimpos +=1;
                                            #print "";
                                        }else {
                                              open(my $fh, '>>',  $impossible) or die "Could not open file  $impossible $!";
                                              print  $fh "$holder_info->{inz_nr},$subject_info->{inz_nr},$subject_info->{inz_nr},$completed,$datestart,$holder_info->{inz_nr},$subject_info->{inz_nr},$subject_info->{inz_Nr_tit},Explecit,$age_subject, PAC < 18 -> PAC\n";
                                              close $fh;
                                              $lijnimpos +=1;
                                              #print "";
                                        }
                                        
                            }                      
                    }
                 $lijnenteller +=1;   
                }
             close(LEDENFILE);
             select STDOUT;
             print "$MUT gedaan $lijnenteller = $lijnpos + $lijnimpos + $lijnclar +1 -> lijn implicit  $lijnimpl\n";
            }
package AS400;
     use DBI;
     
     sub connect_db {
         #connect to database
	      my ($self,$user_name,$password) = @_;       
         my $DSN='driver={iSeries Access ODBC Driver};System=airbus';
         #my $DSN='driver={iSeries Access ODBC Driver};System=10.198.11.111';ref
          my $dbh = DBI->connect("dbi:ODBC:$DSN",$user_name,$password) or die "Couldn't connect to database: " . BDI->errstr;
	      return ($dbh);
        }
     sub disconnect_db {
         my ($self,$dbh) = @_;
         $dbh->disconnect;
        }
     sub check_of_tit {
        
     }
     sub klantinfo  {
         my ($self,$dbh,$libcxfil,$MUT,$zkf,$inz_holder) = @_;
            #openen van PFYSL8
            # EXIDL8 = extern nummer
            # KNRNL8 = nationaalt register nummer
            # NAMBL8 = naam van de gerechtigde
            # PRNBL8 = voornaam van de gerechtigde
            # SEXEL8 = code van het geslacht
            # NAIYL8 = geboortejaat
            # NAIML8 = geboortemaand
            # NAIJL8 = geboortedag
            # LANGL8 = taal N= nederlands
            my $pers_fil = "$libcxfil.PFYSL8";
            my @naamrij = $dbh->selectrow_array("SELECT EXIDL8,KNRNL8,NAMBL8,PRNBL8,SEXEL8,NAIYL8,NAIML8,NAIJL8,LANGL8 FROM $pers_fil WHERE KNRNL8=$inz_holder");
            my $tel=0;
            foreach my $item (@naamrij) {
                         $naamrij[$tel] =~ s/^\s+//;
                         $naamrij[$tel] =~ s/\s+$//;
                         $tel +=1;
                    }
           my $geboortedatum =$naamrij[5]*10000+$naamrij[6]*100+$naamrij[7];
            my $klant =  {
                            'naam'               => "$naamrij[2]",
                            'voornaam'       => "$naamrij[3]",
                            'extern_nr'  =>  sprintf("%013s", $naamrij[0] ),
                            'inz_nr' =>  sprintf("%011s",$naamrij[1]),                        
                            'sex' => "$naamrij[4]",
                            'taal' => "$naamrij[8]",
                            'geboortedatum' => $geboortedatum,
                     
                        };
            $klant = AS400->zoektitularis($dbh,$libcxfil,$klant);
            return ($klant);
        }
     sub zoektitularis {
         my ($self,$dbh,$libcxfil,$klant) = @_;
         my $pben_fil = "$libcxfil.PBEN17";
         my $pers_fil = "$libcxfil.PFYSL8";
         my $externnrdzkf = $klant->{extern_nr};
         my @pben_uit = $dbh->selectrow_array("SELECT IDNS17,EXID17,NAMB17,PRNB17,FEDA17,AFFC17,AFFJ17,AFFM17,AFFY17,IDMT17,DAFC17,IDNS17,DAFY17,
            DAFM17,DAFJ17,FEDN17,NNDN17,NNNS17,NNCC17,SEXE17,NBUR17,SECT17,IDNO17  FROM $pben_fil WHERE DAFC17 = '' and EXID17 =  $externnrdzkf");
         my $volgnummer = $pben_uit[0];
         my $stamnummer = $pben_uit[22];
         my $eig_extern_nr = $pben_uit[1];
         if ($volgnummer == 0) {
             $klant->{is_titularis} = 'ja',
             $klant->{extern_Nr_tit} = $eig_extern_nr;
             $klant->{inz_Nr_tit} = $klant->{inz_nr};
            }else {
              $klant->{is_titularis} = 'nee',
              my @pben1_uit = $dbh->selectrow_array("SELECT IDNS17,EXID17,IDNO17  FROM $pben_fil WHERE DAFC17 = '' and IDNO17  =  $stamnummer and IDNS17 = 0");
              $klant->{extern_Nr_tit} =$pben1_uit[1];
               my $inz_Nr_tit = $dbh->selectrow_array("SELECT KNRNL8 FROM $pers_fil WHERE EXIDL8=$pben1_uit[1]");
              $klant->{inz_Nr_tit} = $inz_Nr_tit;
            }
         return($klant);
        }