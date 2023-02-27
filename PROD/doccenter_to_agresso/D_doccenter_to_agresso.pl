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
#OPGELET!!!!!!

require 'Decryp_Encrypt.pl';
use strict;
use Cwd;
use Date::Manip::DM5;
use File::Slurp;
use MIME::Lite; 
use Net::SMTP;
use MIME::Types;
use XML::Simple;
use MIME::Base64;

package main;
     our @Doctype_Agresso = ();
     our $instellingen = main->load_settings('D:\OGV\ASSURCARD_PROG\assurcard_settings_xml\doccenter_to_agresso.xml'); #C:\macros\doccentermail
     our $vandaag = ParseDate("today");
     our $huidig_jaar = substr ($vandaag,0,4);
     our $huidige_maand = substr ($vandaag,4,2);
     our $huidige_dag = substr ($vandaag,6,2);
     our $vandaag_dag = $huidig_jaar*10000+$huidige_maand*100+$huidige_dag;
     our $klant;
     our @te_verwerken_extnr;
     our $file;
     our @IM_Doccenter = ('','IM','Doccenter');
     our $usr_prof = $ENV{'USERPROFILE'};     
     BEGIN {
        return unless defined &PerlApp::extract_bound_file;
        my $db_file = PerlApp::extract_bound_file("types.db");
        MIME::Types->new(db_file => $db_file);
      }
     my $app = App->new();          
     $app->MainLoop;
     print "";
     sub load_settings  {
         my ($class,$file_name)= @_;
         print "$file_name";
         my $instellingen = XMLin("$file_name");
         print "->ingelezen\n";
         foreach my $zf (sort keys $instellingen->{ziekenfondsen}) {
            $instellingen->{ziekenfondsen}->{$zf}->{as400_paswoord} = decrypt->new($instellingen->{ziekenfondsen}->{$zf}->{as400_paswoord});
         }
         foreach my $type (@{$instellingen->{Agresso_Doctype}->{DocType}}) {
              push (@Doctype_Agresso,$type);
              #print "$type ->$instellingen->{Agresso_Doctype}->{DocType}->[$type] \n";
         }
         #maak verzekeringen         
         return ($instellingen);
        }
package mail;
     use File::Slurp;
     use MIME::Lite; 
     use Net::SMTP;
     use MIME::Types;
     use MIME::Base64;
     use Encode qw/encode decode/;
     use Encode::MIME::Header;
     use MIME::Words qw(encode_mimewords);
     sub mail_bericht {
         my ($class,$pdf_in_mail,$file1,$file2,$file3) =  @_;
         my $LocatieMailSjabloon = $main::instellingen->{Location_mail_Template};
         #my $test = $main::klant;
         if (uc ($main::instellingen->{Customer}->{mail}->{send_mail}) eq 'YES') {
             #my $rekeningnummer_kwijting = $file;
             #$rekeningnummer_kwijting =~ m/srek_.*-kwijting.pdf/;
             #$rekeningnummer_kwijting = $&;
             #$rekeningnummer_kwijting =~ s/-kwijting.pdf//g;
             #$rekeningnummer_kwijting =~ s/rek_//g;
             my $params; 
                 $params->{voor_naam} = $main::klant->{voor_naam};
                 $params->{achter_naam}  = $main::klant->{achter_naam};
                 $params->{inz_nr_spatie}    = $main::klant->{inz_nr_spatie};
                 $params->{aan_spreek}    = $main::klant->{aan_spreek};
                 $params->{datum_geschreven} = "$main::huidige_dag $main::maand_naam $main::huidig_jaar";
                 $params->{datum_slashes} = "$main::huidige_dag/$main::huidige_maand/$main::huidig_jaar";                
                 $params->{brief_adres_lijn1}= $main::klant->{brief_adres_lijn1};
                 $params->{brief_adres_lijn2}= $main::klant->{brief_adres_lijn2};
                 $params->{brief_adres_lijn3}= $main::klant->{brief_adres_lijn3};
                 $params->{brief_adres_lijn4}= $main::klant->{brief_adres_lijn4};
                 my $mail = read_file("$LocatieMailSjabloon/mail.html");
                 $mail =~ s/aan_spreek/$params->{aan_spreek}/g;
                 $mail =~ s/voor_naam/$params->{voor_naam}/g;
                 $mail =~ s/achter_naam/$params->{achter_naam}/g;
                 $mail =~ s/inz_nr_spatie/$params->{inz_nr_spatie}/g;
                 $mail =~ s/be_drag/$params->{be_drag}/;
                 $mail =~ s/brief_adres_lijn1/$params->{brief_adres_lijn1}/g;
                 $mail =~ s/brief_adres_lijn2/$params->{brief_adres_lijn2}/g;
                 $mail =~ s/brief_adres_lijn3/$params->{brief_adres_lijn3}/g;
                 $mail =~ s/brief_adres_lijn4/$params->{brief_adres_lijn4}/g;
                 $mail =~ s%datum_slashes%$main::huidige_dag/$main::huidige_maand/$main::huidig_jaar%g;
                 $mail =~ s%datum_geschreven%$main::huidige_dag $main::huidige_maand $main::huidig_jaar%g;
                 my $test = $main::klant;                               
                 my $van = $main::instellingen->{From_Mail};
                 my $onderwerp = $main::instellingen->{Subject_Mail};
                 my $From = $main::instellingen->{From};
                 my $msg = MIME::Lite -> new( 
                     From        =>  "\"$From\" <$van>",
                     To          =>    "$main::klant->{mail_adres}", #'harry.conings@vnz.be',
                     #CC          =>  'harry@ice.be',#steven.van.dessel@vnz.be,lut.cools@vnz.be,liesbeth.rossie@vnz.be',
                     Subject     =>   encode_mimewords ("$onderwerp $main::klant->{voor_naam} $main::klant->{achter_naam} "), 
                     Type        =>  "multipart/related"
                    );
                                    
                 $msg->attach(
                     Type => 'text/html',
                     Encoding => 'quoted-printable',
                     Data => qq{
                      $mail;
                         },
                    );
                 # Attach a PDF to the message + logo        
                 $msg->attach(  Type        =>  'image/jpeg',
                     Path        =>  "$LocatieMailSjabloon\\logo.jpg",
                     Filename    =>  'logo.jpg',
                     Id => 'logo.jpg',
                     #      Disposition =>  'inline'   
                    );
                 if ($pdf_in_mail == 1) {
                     if ($file1 ne '') {
                          $msg->attach(  Type        =>  'application/pdf',
                            Path        =>  "$file1",
                            Filename    =>  'brief1.pdf',
                            Disposition =>  'attachment'
                           );
                        }
                      if ($file2 ne '') {
                          $msg->attach(  Type        =>  'application/pdf',
                            Path        =>  "$file2",
                            Filename    =>  'brief2.pdf',
                            Disposition =>  'attachment'
                           );
                        }
                       if ($file3 ne '') {
                          $msg->attach(  Type        =>  'application/pdf',
                            Path        =>  "$file3",
                            Filename    =>  'brief.pdf',
                            Disposition =>  'attachment'
                           );
                        }
                        #print "$msg";
                    }
                 #$msg->send('smtp', '10.63.120.3', AuthUser => 'mailprogrammas',AuthPass => 'pleintje203',Timeout => 60 );
                 $msg->send('smtp', 'mailservices.m-team.be',Timeout => 60 ); 
                 print "mail gezonden\n";
                 return (1);
                }
        }
package AS400;
     use DBI;
     
     sub connect_db {
         my ($self,$zf) = @_;
         #connect to database	 #
         my $user_name = $main::instellingen->{ziekenfondsen}->{$zf}->{as400_user}; 
         my $password =  $main::instellingen->{ziekenfondsen}->{$zf}->{as400_paswoord};
         my $DSN='driver={iSeries Access ODBC Driver};System=airbus';
         my $dbh = DBI->connect("dbi:ODBC:$DSN",$user_name,$password) or die "Couldn't connect to database: " . BDI->errstr;
	      return ($dbh);
        }
     sub disconnect_db {
         my ($class,$dbh) = @_;
         $dbh->disconnect;
        }
     sub geef_volle_landnaam {
          my ($class,$dbh,$afkorting )= @_;
            #IV00Q0              CODE PAYS    / KODE LAND       
            #IV04Q0              LIBELLE PAYS NEERLANDAIS /OMSC 
            #E127Q0              CODE PAYS NORME ISO     /LANDC 
            #ISO2Q0              CODE PAYS NORME ISO 2   /LANDC 
            #IV01Q0              APPARTENANCE CEE / LAND EEG    
            #IV02Q0              CODE PAYS DU SN / KODE LAND VA 
            #IV03Q0              LIBELLE PAYS FRANCAIS /OMSCHRI 
            #IV05Q0              LIBELLE PAYS ALLEMAND /OMSCHRI 
            #IV06Q0              DATE DEBUT APPARTENANCE CEE /B 
            #IV07Q0              DATE FIN APPARTENANCE CEE /EIN 
            #IV08Q0              CODE PAYS BANQUE CARREFOUR /CO 
            #PT7PQ0              T7 CODE PAYS NUMERIQUE  /T7 NU 
            #IV81Q0              PAYS CONVENTIONNE CI /GECONVEN
            my $library = $main::instellingen->{as400_library};
            my  $landen_fil ="$library.PREFQ0";
            my $land_naam = $dbh->selectrow_array("SELECT IV04Q0 FROM $landen_fil WHERE IV00Q0= '$afkorting' ");
            $land_naam =~ s/^\s+//;
            $land_naam =~ s/\s+$//;
            return ($land_naam);
       }
     sub zoek_of_mail_wil {
         my ($class,$dbh,$externnummer,$emailadres) = @_;
         my $library = $main::instellingen->{as400_NoMAIL_library};
         my $nrzkfcheck = $main::instellingen->{zkf};
         my $nomail_fil = "$library.NOMAIL";           
         my @mailrij = $dbh->selectrow_array("SELECT ZKF,EXID52,KNRN52,NOMAIL FROM $nomail_fil WHERE EXID52=$externnummer and ZKF=$nrzkfcheck");
            if ($mailrij[3] == 1) {
               my $wil_geen_mail= "WIL GEEN MAIL $emailadres";
               return ('geen_mail');       
            }else {
               return ('ok_mail')
            }
        }

   
     sub checkadres {
         my ($class,$dbh,$externnummer) = @_;
         my $nrzkfcheck = $main::instellingen->{zkf};
         undef $main::klant;
         #openen van PADRJR op as400
         # EXIDJR = extern nummer
         # ABGIJR = soort adres post of gewoon post =02
         # ABKTJR = naam van de bewoner van het postadress
         # ABSTJR = naam van de straat
         # ABNTJR = huisnnummer
         # ABBTJR = busnummer
         # IV00JR = kode van het land
         # ABPTJR = postnummer
         # ABWTJR = woornplaats
         # IDFDJR = NUMMER ZIEKENFOND
         # ER ZIJN DUBBEL ENTRIES VOOR POSTADRES EN GEWOON ADRES WE KIJKEN OF ER EEN POSTADRES IS
         # het postadres heeft ABGIJR == 02 dit gaan we zoeken
         # KGERJR = srtaat kode
         my $library = $main::instellingen->{as400_library};
         my $adres_fil = "$library\.PADRJR";
         my $sql =("SELECT EXIDJR,ABGIJR,ABKTJR,ABSTJR,ABNTJR,ABBTJR,IV00JR,ABPTJR,ABWTJR,IDFDJR,KGERJR FROM $adres_fil WHERE EXIDJR= $externnummer and IDFDJR = $nrzkfcheck");
         my $sth = $dbh->prepare( $sql );
         $sth->execute();
         my $aantalrij=0;
         my @adresrij;
         my @adresrijdomi;
         while(my @mijnrij=$sth->fetchrow_array)  {
              #print "$aantalrij    @mijnrij\n";
              @adresrij=@mijnrij if ($aantalrij == 0 );
              @adresrijdomi=@mijnrij if ($aantalrij == 0 );
              @adresrij=@mijnrij if ($aantalrij >= 0) ; #and ($mijnrij[1] == 02);  #postadres
              @adresrijdomi=@mijnrij if ($aantalrij >= 0) and ($mijnrij[1] == 01);  #domicili adres
              $aantalrij +=1;
            }
         #print "post -- @adresrij \n";
         #print "domi -- @adresrijdomi \n";
         $sth->finish();
         # openen van PFYSL8
         # EXIDL8 = extern nummer
         # KNRNL8 = nationaalt register nummer
         # NAMBL8 = naam van de gerechtigde
         # PRNBL8 = voornaam van de gerechtigde
         # SEXEL8 = code van het geslacht
         my @naamrij;
         my $pers_fil ="$library.PFYSL8";
         @naamrij = $dbh->selectrow_array("SELECT EXIDL8,KNRNL8,NAMBL8,PRNBL8,SEXEL8 FROM $pers_fil WHERE EXIDL8=$externnummer");
         #
         # disconnect database
          #
          $dbh->disconnect;
          my $lijn_v = "";
        my $bus_v = "";
        my $landcode_v = ""; 
        $main::klant->{brief_adres_lijn1} = "";
        $main::klant->{brief_adres_lijn2} = "";
        $naamrij[1]=~ s/^\s+//;
	$naamrij[3]=~ s/^\s+//;
	$naamrij[3]=~ s/\s+$//;
	$naamrij[2]=~ s/^\s+$//;
	$naamrij[2]=~ s/\s+$//;
        $naamrij[8]=~ s/^\s+$//; #versie 3.3 neuw id
	$naamrij[8]=~ s/\s+$//;
        $naamrij[8]=~ s/^203//;
	$adresrij[3]=~ s/^\s+$//;
	$adresrij[3]=~ s/\s+$//;
	$adresrij[4]=~ s/^\s+//;
	$adresrij[4]=~ s/\s+$//;
	$adresrij[6]=~ s/^\s+$//;
	$adresrij[6]=~ s/\s+$//;
	$adresrij[7]=~ s/^\s+//;
	$adresrij[7]=~ s/\s+$//;
	$adresrij[8]=~ s/^\s+//;
	$adresrij[8]=~ s/\s+$//;
 	$adresrij[5]=~ s/^\s+//;
	$adresrij[5]=~ s/\s+$//;
        #postadres of domiadres om op te sturen
        $bus_v = "bus $adresrij[5]" if ($adresrij[5]);
	$lijn_v = "DE HEER $naamrij[3] $naamrij[2]" if $naamrij[4] == 01;
        $lijn_v= "MEVROUW $naamrij[3] $naamrij[2]" if $naamrij[4] == 02;
	$adresrij[6]=~ s/^\s+//;
        $adresrij[6]=~ s/\s+$//;
        my $land_voluit = '';
	if ($adresrij[6] ne "B") {
	  $land_voluit = AS400->geef_volle_landnaam($dbh,$adresrij[6]);             
	    if ($adresrij[1] == 02) {
	     $main::klant->{brief_adres_lijn1} = uc $adresrij[2];
	     $main::klant->{brief_adres_lijn2}= uc "TAV. $lijn_v" ;
	     $main::klant->{brief_adres_lijn3} = uc "$adresrij[3] $adresrij[4] $bus_v";
	     $main::klant->{brief_adres_lijn4} = uc "$adresrij[7] $adresrij[8] $land_voluit";
	    }else {
	     $main::klant->{brief_adres_lijn1} = uc "$lijn_v" ;
	     $main::klant->{brief_adres_lijn2} = uc "$adresrij[3] $adresrij[4] $bus_v";
	     $main::klant->{brief_adres_lijn3} = uc "$adresrij[7] $adresrij[8]";
	     $main::klant->{brief_adres_lijn4} = uc "$land_voluit";
	    }
	}else {
	     if ($adresrij[1] == 02) {
	     $main::klant->{brief_adres_lijn1} = uc $adresrij[2];
	     $main::klant->{brief_adres_lijn2} = uc "TAV. $lijn_v" ;
	     $main::klant->{brief_adres_lijn3} = uc "$adresrij[3] $adresrij[4] $bus_v";
	     $main::klant->{brief_adres_lijn4} = uc "$adresrij[7] $adresrij[8]";
	    }else {
	     $main::klant->{brief_adres_lijn1} = uc "$lijn_v";
	     $main::klant->{brief_adres_lijn2} = uc "$adresrij[3] $adresrij[4] $bus_v" ;
	     $main::klant->{brief_adres_lijn3} = uc "$adresrij[7] $adresrij[8]";
	     $main::klant->{brief_adres_lijn4} = uc "";
	    }
 	}
        #domiadres 
        $bus_v = "bus $adresrijdomi[5]" if ($adresrijdomi[5]);
        my $landecode_v = "$adresrijdomi[6] " if $adresrijdomi[6] ne "B";
        $main::klant->{domi_adres_lijn1} = uc "$lijn_v";
        $main::klant->{domi_adres_lijn2} = uc "$adresrijdomi[3] $adresrijdomi[4] $bus_v";
        $main::klant->{domi_adres_lijn3} = uc "$landecode_v$adresrijdomi[7] $adresrijdomi[8]";
	#cgi
        #$main::klant->{cg1_cg2}  = "$cgrij[3]/$cgrij[4]";
        #briefnaam
        $main::klant->{voor_naam} = $naamrij[3];
        $main::klant->{achter_naam}= $naamrij[2];
        #rijksregisternummer
          $main::klant->{inz_nr_g_sp} = $naamrij[1];
          my $splitinz=$naamrij[1];
          $splitinz=~ s%\d{2}$% $&%;
          #print "$splitinz\n";
          $splitinz=~ s%\d{3}\s\d{2}$% $&%;
          $main::klant->{inz_nr_spatie} = sprintf ('%013s',$splitinz);  #voorafgaande nullen terug zetten
        #extern nummer
          $main::klant->{extern_nummer} = sprintf ('%013s',$naamrij[0]);  #voorafgaande nullen terug zetten
        #geboortedatum
          $main::klant->{geboorte_datum} = "$naamrij[7]/$naamrij[6]/$naamrij[5]";
        #aanspreek
          $main::klant->{H_aan_spreek} = "MIJNHEER" if $naamrij[4] == 01;
          $main::klant->{H_aan_spreek} = "MEVROUW" if $naamrij[4] == 02;
          $main::klant->{aan_spreek} = "Mijnheer" if $naamrij[4] == 01;
          $main::klant->{aan_spreek} = "Mevrouw" if $naamrij[4] == 02;
	  $main::klant->{aan_spreek} = $main::klant->{brief_adres_lijn1} if ($main::klant->{brief_adres_lijn1} =~ m/\sOUDERS\s/i or $main::klant->{brief_adres_lijn1} =~ m/\sOUDER\s/i);
	  $main::klant->{aan_spreek} = $main::klant->{brief_adres_lijn1} if ($main::klant->{brief_adres_lijn1} =~ m/\sERFGENAMEN\s/i or $main::klant->{brief_adres_lijn1} =~ m/\sERFGENAAM\s/i); 
          $main::klant->{ge_slacht} = "man" if $naamrij[4] == 01;
          $main::klant->{ge_slacht} = "vrouw" if $naamrij[4] == 02;
	  $main::klant->{h_h} = "haar" if $naamrij[4] == 02;
	  $main::klant->{h_h} = "hem" if $naamrij[4] == 01;
	  $main::klant->{h_ar} = "haar" if $naamrij[4] == 02;
	  $main::klant->{h_ar} = "zijn" if $naamrij[4] == 01;
          #rekening nummers
	  #$main::klant->{rek_nummer_v01} = $rekeningnummer ;
	  print '';
          
        }
     sub Zoek_documenten_in_IM {
         my ($class,$dbh,$catalog_name,$begindatum,$einddatum,$zkfXXX,$frame) = @_;
         my $library =  $main::instellingen->{ziekenfondsen}->{$zkfXXX}->{as400_library};
         my $integmail = "$library\.pimhn2";
         my $dtmfil = "$library\.pdetm7";
         my $documenten;
         my $aantal_per_persoon;
         #print "SELECT COUNT b.EXIDM7 FROM $integmail a left join $dtmfil b on a.BU50N2=b.BU50m7 WHERE a.BU06N2 = $catalog_name 
         #           and a.ZG61N2 >= $begindatum and a.ZG61N2 <= $einddatum ORDER BY b.BUPCM7,b.BURUM7,b.BUNUM7,b.BUBTM7";
         my $aantal = $dbh->selectrow_array("SELECT COUNT (EXIDM7) FROM $integmail a left join $dtmfil b on a.BU50N2=b.BU50m7 WHERE A.BU06N2 = '$catalog_name' and A.ZG61N2 >= $begindatum
                    and A.ZG61N2 <= $einddatum");
         my $sql = ("SELECT EXIDM7 FROM $integmail a left join $dtmfil b on a.BU50N2=b.BU50m7 WHERE A.BU06N2 = '$catalog_name' and A.ZG61N2 >= $begindatum
                    and A.ZG61N2 <= $einddatum ORDER BY B.BUPCM7,B.BURUM7,B.BUNUM7,B.BUBTM7");
         
         my $sth = $dbh->prepare( $sql );
         $sth->execute();
         my $testteller=0;
         #open(my $fh, ">", "C:\\macros\\doccentermail\\externummer.txt") ;
         my $ext_oud='';
         while(my @mijnrij=$sth->fetchrow_array)  {            
             if ($mijnrij[0] != $ext_oud) {
                  $ext_oud=$mijnrij[0];
                  my $inz_nr =   AS400->checknaamnextern($mijnrij[0],$zkfXXX,$dbh); 
                  push (@main::te_verwerken_extnr, $mijnrij[0]);
                 #print $fh "$mijnrij[0]\n";
                 ($aantal_per_persoon->{$mijnrij[0]},$documenten->{$mijnrij[0]}) =  webservice->GetCatalogKeys('EXID',$mijnrij[0],$catalog_name,$begindatum,$einddatum,1,$frame,$zkfXXX,$inz_nr);
                 $testteller+=1;
                 #last if ($testteller==10);
                 print '';
             }
             
            }
         #close ($fh);
         return ($aantal,$documenten);
        }
     sub checknaamnextern {
                  my ($class,$ext_nr,$zkfXXX,$dbh) = @_;
                  my $library =  $main::instellingen->{ziekenfondsen}->{$zkfXXX}->{as400_library};
                  #openen van PFYSL8
                  # EXIDL8 = extern nummer
                  # KNRNL8 = nationaalt register nummer
                  # NAMBL8 = naam van de gerechtigde
                  # PRNBL8 = voornaam van de gerechtigde
                  # SEXEL8 = code van het geslacht
                  # NAIYL8 = geboortejaat
                  # NAIML8 = geboortemaand
                  # NAIJL8 = geboortedag
                  my $pers_fil =  "$library\.PFYSL8";
                  my @naamrij = $dbh->selectrow_array("SELECT KNRNL8 FROM $pers_fil WHERE EXIDL8=$ext_nr");
                  return ($naamrij[0]);
     }
package App;
     use strict;
     use warnings;
     use base 'Wx::App';
     sub OnInit {
         $main::dialog = Frame->new();
         #$main::frame->Maximize( 1 );
         $main::dialog->SetSize(1, 1, 770, 160);
         $main::dialog->Centre();
         
         $main::dialog->Show(1);
        }
package Frame;
     use Wx qw[:everything];
     use base qw(Wx::Frame);
     use Wx::Locale gettext => '_T';
     use LWP::Simple;
     use Win32::API;
     use Hash::Merge;
     #my $old_charset = odfLocalEncoding(); #versie 5.2 charset utf8 
     #odfLocalEncoding('iso-8859-15');  #versie 5.2
     sub new {
               use warnings;
               use Wx qw(:everything);
               use base qw(Wx::Frame);
               use Data::Dumper;
               use Wx::Locale gettext => '_T';
               my($frame) = @_;
               my $mail_is_checked;
               my $PDF_is_checked;
               my $PRINT_is_checked;
               my $begindatum;
               my $einddatum;
               my $NaamBrief;
               my $aantal = '?';
               my $exid_inz='';
               my $mode = $instellingen->{mode};
               $frame = $frame->SUPER::new(undef, -1,_T("Welke Doccenter brief wil je in agresso $mode zetten"),
                                        [-1,-1],[770,160], wxDEFAULT_FRAME_STYLE | wxTAB_TRAVERSAL  );
               #$frame->Wx::Size->new(800,600) ;
               $frame->{Frame_Sizer_1} = Wx::FlexGridSizer->new(5,7, 10, 10);
               $frame->{Frame_statictxt_NaamBrief}= Wx::StaticText->new($frame, -1,_T("Naam v/d brief in Doccenter?"),wxDefaultPosition,wxSIZE(140,20));
               $frame->{Frame_Txt_NaamBrief} = Wx::TextCtrl->new($frame, -1, $NaamBrief,wxDefaultPosition,wxSIZE(140,20));
               $frame->{Frame_statictxt_Begindatum}= Wx::StaticText->new($frame, -1,_T("Begindatum YYYYMMDD"),wxDefaultPosition,wxSIZE(140,20));
               $frame->{Frame_Txt_Begindatum} = Wx::TextCtrl->new($frame, -1, $begindatum,wxDefaultPosition,wxSIZE(140,20));
               $frame->{Frame_statictxt_Einddatum}= Wx::StaticText->new($frame, -1,_T("Einddatum YYYYMMDD"),wxDefaultPosition,wxSIZE(140,20));
               $frame->{Frame_Txt_Einddatum} = Wx::TextCtrl->new($frame, -1, $einddatum,wxDefaultPosition,wxSIZE(140,20));
               $frame->{Frame_statictxt_Aantal}= Wx::StaticText->new($frame, -1,_T("Aantal gevonden:"),wxDefaultPosition,wxSIZE(140,20));
               $frame->{Frame_Txt_Aantal} = Wx::TextCtrl->new($frame, -1, $aantal,wxDefaultPosition,wxSIZE(140,20));   
               $frame->{Frame_Button_OK}  = Wx::Button->new($frame, -1, _T("OK"),wxDefaultPosition,wxSIZE(140,20));
               $frame->{Frame_Cancel}  = Wx::Button->new($frame, -1, _T("Cancel"),wxDefaultPosition,wxSIZE(140,20));               
               $frame->{Frame_statictxt_choice_DocT_Ag}  = Wx::StaticText->new($frame, -1,_T("Kies:"),wxDefaultPosition,wxSIZE(20,20));
               $frame->{Frame_statictxt_DocT_Ag} = Wx::StaticText->new($frame, -1,_T("Waar plaatsen we ze in Agresso ?"),wxDefaultPosition,wxSIZE(200,20)); 
               $frame->{Frame_choice_DocT_Ag}  = Wx::Choice->new($frame, 26,wxDefaultPosition,wxSIZE(200,20),\@main::Doctype_Agresso);
               $frame->{Frame_panel_1} = Wx::Panel->new($frame,-1,wxDefaultPosition,wxSIZE(20,5));
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
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_statictxt_NaamBrief}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);               
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_statictxt_Begindatum}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);               
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_statictxt_Einddatum}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_statictxt_DocT_Ag}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);            
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               #RIJ 2 
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_Txt_NaamBrief}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_Txt_Begindatum}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_Txt_Einddatum}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_statictxt_choice_DocT_Ag}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_choice_DocT_Ag}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               #RIJ3
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_statictxt_Aantal}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_Txt_Aantal}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);               
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);              
               #RIJ4 
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);               #
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_Button_OK}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_LEFT);
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_Cancel}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);               
               $frame->{Frame_Sizer_1}->Add($frame->{Frame_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_LEFT);              
               
               
               Wx::Event::EVT_BUTTON($frame,$frame->{Frame_Button_OK},\&OK);
               Wx::Event::EVT_BUTTON($frame,$frame->{Frame_Cancel},\&Cancel);
               Wx::Event::EVT_BUTTON($frame,$frame->{Frame_Button_Bestand},\&Bestand); 
               $frame->SetSizer($frame->{Frame_Sizer_1});
               $frame->SetBackgroundColour(Wx::Colour->new(239, 243, 255));
               return ($frame);
          }
     sub OK {
           my($frame)= @_;           
           my $aantal =  $frame->{Frame_Txt_Aantal}->GetValue();          
           my $NaamBrief ='';
           $NaamBrief =  $frame->{Frame_Txt_NaamBrief}->GetValue();           
           my $Begindatum = 19750101;
           my $Einddatum =  19750101;
           $Begindatum = $frame->{Frame_Txt_Begindatum}->GetValue();
           $Einddatum = $frame->{Frame_Txt_Einddatum}->GetValue();
           my $agresso_doctype = $frame->{Frame_choice_DocT_Ag}->GetStringSelection();
           my $totaal_aantal=0; 
           if ( ($aantal eq '?' or  $aantal == 0) ) {
             Wx::MessageBox("We gaan het aantal opzoeken", 
                                     _T("Kijk naar het aantal"), 
                                     wxOK|wxCENTRE, 
                                     $frame
                                    );
             @main::te_verwerken_extnr = ();
             my $locatie_log = $instellingen->{locatie_log};
             foreach my $zf (sort keys $instellingen->{ziekenfondsen}) {
                unlink "$locatie_log\\externummer$zf.txt";
               } 
             my $documenten;
             my $pageNumber = 1;
             #my ($class,$type,$inz_extern_nummer,$doctype,$catalogstartdate,$catalogenddate) = @_;
             #my $zkf ="zkf203";
                      
             if ($Begindatum > 19750101 and $Einddatum >= $Begindatum and $Begindatum =~ m/\d{8}/ and $Einddatum =~ m/\d{8}/ and $NaamBrief ne '') {                       
                  foreach my $zf (sort keys $instellingen->{ziekenfondsen}) {
                    #($aantal,$documenten->{$zf}) =  webservice->GetCatalogKeys($zf,$NaamBrief,$Begindatum,$Einddatum,$pageNumber,$frame);
                     my $dbh = AS400->connect_db($zf);
                    ($aantal,$documenten->{$zf})  = AS400->Zoek_documenten_in_IM($dbh,$NaamBrief,$Begindatum,$Einddatum,$zf);
                    $totaal_aantal += $aantal;
                  }
                  $frame->{Frame_Txt_Aantal}->SetValue($totaal_aantal);
                  return ();
                  print '';
               }else {                                                      
                  Wx::MessageBox("Opgelet je moet alles invullen", 
                                  _T("Vul IN"), 
                                  wxOK|wxCENTRE, 
                                  $frame
                                );
                  return ();
                  print '';
               }                      
            
             
            }else{
                 #$IM_of_Doccenter = $frame->{Frame_choice_IM}->GetStringSelection;
                 #$pdf_in_mail =  $frame->{Frame_chk_pdf}->GetValue();                   
                 print "ja\n";#code
                 my $teller_agresso=0;
                 my $locatie_log = $instellingen->{locatie_log};
                 unlink "$locatie_log\\overview.csv";
                 open(my $fh_overview, ">", "$locatie_log\\overview.csv") ;
                 foreach my $zf (sort keys $instellingen->{ziekenfondsen}) {
                   my $cUrl = webservice->make_commen_download_url($zf);
                   
                   my $teller = 0;                   
                   my $agresso_ok = '';             
                   $teller = 0;
                   if ($aantal >= $main::instellingen->{page_size_doccenter}) {                                                      
                         my $veel_mails = Wx::MessageBox("Opgelet aantal documenten is groter dan $main::instellingen->{page_size_doccenter}\n We gaan in blokken van $main::instellingen->{page_size_doccenter} versturen", 
                            _T("Aantal documenten"), 
                            wxCENTRE|wxYES_NO,  
                            $frame
                          );
                         if ($veel_mails == wxYES) {
                             #we gaan de eerste pagina vewerken
                             open(FILE, "$locatie_log\\externummer$zf.txt") ;
                             my $count = 0;
                             $teller = 0;
                             #my $dbh = AS400->connect_db();                   
                             foreach my $line (<FILE>)  {   
                                 print "$count->$line\n";
                                 my ($ext,$key,$inz,$vnaam,$naam,$direction,$cat_name,$docId) = split (/,/,$line);
                                 my $download_url = webservice->download_url($cUrl,$key,$direction,$zf);
                                 $main::file = "$main::usr_prof\\$NaamBrief.pdf";
                                 unlink $main::file;
                                 getstore($download_url, $main::file) ; 
                                 undef $main::klant;
                                 $main::klant->{voor_naam} =$vnaam;
                                 $main::klant->{achter_naam} =$naam;
                                 my $inz_nr_spatie = sprintf ('%011s',$inz);#code$inz;
                                 my $inz_nr_spatie1 = substr($inz_nr_spatie,0,6);
                                 my $inz_nr_spatie2 = substr($inz_nr_spatie,6,3);
                                 my $inz_nr_spatie3 = substr($inz_nr_spatie,9,2);
                                 $inz_nr_spatie = "$inz_nr_spatie1 $inz_nr_spatie2 $inz_nr_spatie3";
                                 $main::klant->{inz_nr_spatie} =$inz_nr_spatie;
                                 my $antwoord = webservice->agresso_get_customer_info_rr_nr($inz,$file);
                                 $main::klant->{file_encode64} = webservice->convert_base64($main::file);
                                 print "$ext,$main::klant->{inz_nr_spatie},,$main::klant->{voor_naam},$main::klant->{achter_naam}\n";
                                 print $fh_overview "$ext,$main::klant->{inz_nr_spatie},$main::klant->{voor_naam},$main::klant->{achter_naam}\n";
                                 sleep 1;
                                 my @gelukt = webservice->PDF_naar_Agresso($agresso_doctype);
                                 $teller_agresso +=1 if ($gelukt[0] eq 'gelukt');
                                 $agresso_ok ='';
                                 print "";
                              }
                             print '';
                             close FILE;
                             unlink "$locatie_log\\externummer$zf.txt";
                             #volgende pagina's
                             my $pagina = 2;
                             until ($aantal < $main::instellingen->{page_size_doccenter}){
                                 my ($aantal1,$documenten1) =  webservice->GetCatalogKeys($zf,$NaamBrief,$Begindatum,$Einddatum,$pagina,$frame);
                                 $aantal = $aantal1;
                                 $frame->{Frame_Txt_Aantal}->SetValue($aantal);
                                 $pagina += 1;
                                 open(FILE, "$locatie_log\\externummer$zf.txt") ;
                                 $teller = 0;
                                 my $count = 0;                                               
                                 foreach my $line (<FILE>)  {   
                                     print "$count->$line\n";
                                     my ($ext,$key,$inz,$vnaam,$naam,$direction,$cat_name,$docId) = split (/,/,$line);
                                     my $download_url = webservice->download_url($cUrl,$key,$direction,$zf);
                                     $main::file = "$main::usr_prof\\$NaamBrief.pdf";
                                     unlink $main::file;
                                     getstore($download_url, $main::file);
                                     undef $main::klant;
                                     $main::klant->{voor_naam} =$vnaam;
                                     $main::klant->{achter_naam} =$naam;
                                     my $inz_nr_spatie = sprintf ('%011s',$inz);#code$inz;
                                     my $inz_nr_spatie1 = substr($inz_nr_spatie,0,6);
                                     my $inz_nr_spatie2 = substr($inz_nr_spatie,6,3);
                                     my $inz_nr_spatie3 = substr($inz_nr_spatie,9,2);
                                     $inz_nr_spatie = "$inz_nr_spatie1 $inz_nr_spatie2 $inz_nr_spatie3";
                                     $main::klant->{inz_nr_spatie} =$inz_nr_spatie;
                                     my $antwoord = webservice->agresso_get_customer_info_rr_nr($inz,$file);
                                     $main::klant->{file_encode64} = webservice->convert_base64($main::file);
                                     print "$ext,$main::klant->{inz_nr_spatie},,$main::klant->{voor_naam},$main::klant->{achter_naam}\n";
                                     print $fh_overview "$ext,$main::klant->{inz_nr_spatie},$main::klant->{voor_naam},$main::klant->{achter_naam}\n";
                                     my @gelukt = webservice->PDF_naar_Agresso($agresso_doctype);
                                     $teller_agresso +=1 if ($gelukt[0] eq 'gelukt');
                                     sleep 1;
                                     $agresso_ok ='';
                                     
                                    }
                                 print '';
                                 close FILE;
                                 unlink "$locatie_log\\externummer.txt";
                              }
                              
                           }
                     }else {
                       open(FILE, "$locatie_log\\externummer$zf.txt") ;
                       my $count = 0;                                     
                       foreach my $line (<FILE>)  {   
                           print "$count->$line\n";
                           my ($ext,$key,$inz,$vnaam,$naam,$direction,$cat_name,$docId) = split (/,/,$line);
                           my $download_url = webservice->download_url($cUrl,$key,$direction,$zf);
                           $main::file = "$main::usr_prof\\$NaamBrief.pdf";
                           unlink $main::file;
                           getstore($download_url, $main::file) ;                             
                           undef $main::klant;                            
                           $main::klant->{voor_naam} =$vnaam;
                           $main::klant->{achter_naam} =$naam;
                           my $inz_nr_spatie = sprintf ('%011s',$inz);#code$inz;
                           my $inz_nr_spatie1 = substr($inz_nr_spatie,0,6);
                           my $inz_nr_spatie2 = substr($inz_nr_spatie,6,3);
                           my $inz_nr_spatie3 = substr($inz_nr_spatie,9,2);
                           $inz_nr_spatie = "$inz_nr_spatie1 $inz_nr_spatie2 $inz_nr_spatie3";
                           $main::klant->{inz_nr_spatie} =$inz_nr_spatie;
                           my $antwoord = webservice->agresso_get_customer_info_rr_nr($inz,$file);
                           $main::klant->{file_encode64} = webservice->convert_base64($main::file);
                           print $fh_overview "$ext,$main::klant->{inz_nr_spatie},,$main::klant->{voor_naam},$main::klant->{achter_naam}\n";
                           my @gelukt = webservice->PDF_naar_Agresso($agresso_doctype);
                           $teller_agresso +=1 if ($gelukt[0] eq 'gelukt');
                           sleep 1;
                        }
                         print '';
                         #close $fh_overview;
                     }
                 }
                 close $fh_overview;
                 print '';
                 my $antwoord = Wx::MessageBox("We hebben $teller_agresso documenten van de $aantal in Agresso gezet", 
                                     _T("Aantal Documenten in Agresso gezet"), 
                                     wxCENTRE|wxOK, 
                                     $frame
                                    );
               
               
                 print '';
                 die;
             
            }
     }  
   sub Cancel {
          my($frame)= @_;
          die;
      }
package webservice;
     use Wx qw[:everything];
     use base qw(Wx::Frame);
     use Wx::Locale gettext => '_T';
     use SOAP::Lite 
     +trace => [ transport => sub { print $_[0]->as_string } ];
     use MIME::Base64;
     use LWP::Simple;
     use DateTime::Format::Strptime;
     use DateTime;
     use Date::Manip::DM5 ;
     our $documenten;
     sub Cataloog_updateStatusForDelete {      
         my ($class,$catalog_key,$zf) = @_;
         #my $test = uc $main::instellingen->{Customer};
         #<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ged="http://ged.services.common.com.gfdi.be">
         #<soapenv:Header/>
         #   <soapenv:Body>
         #      <ged:updateStatusForDelete>
         #         <ged:in0>203-2015-203-0000000000</ged:in0>
         #      </ged:updateStatusForDelete>
         #   </soapenv:Body>
         #</soapenv:Envelope>
         my $request = 'ged:updateStatusForDelete';
         my $user = $main::instellingen->{ziekenfondsen}->{$zf}->{as400_user}; 
         my $domain = $main::instellingen->{ziekenfondsen}->{$zf}->{nr};
         my $zkf = $main::instellingen->{ziekenfondsen}->{$zf}->{nr};
         my $pass = $main::instellingen->{ziekenfondsen}->{$zf}->{as400_paswoord}; 
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
          my $uri   = 'http://ged.services.common.com.gfdi.be';
          my $soap = SOAP::Lite
             ->proxy("http://$user:$pass\@$endpoint")
             ->ns($uri,'ged')
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
         my ($class,$catalog_key,$zf) = @_;
         #my $test = uc $main::instellingen->{Customer};
         #<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ged="http://ged.services.common.com.gfdi.be">
         #<soapenv:Header/>
         #   <soapenv:Body>
         #      <ged:updateStatusForDelete>
         #         <ged:in0>203-2015-203-0000000000</ged:in0>
         #      </ged:updateStatusForDelete>
         #   </soapenv:Body>
         #</soapenv:Envelope>
         my $request = 'updateStatusForDouble';
         my $user = $main::instellingen->{ziekenfondsen}->{$zf}->{as400_user}; 
         my $domain = $main::instellingen->{ziekenfondsen}->{$zf}->{nr};
         my $zkf = $main::instellingen->{ziekenfondsen}->{$zf}->{nr};
         my $pass = $main::instellingen->{ziekenfondsen}->{$zf}->{as400_paswoord}; 
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
          my $uri   = 'http://ged.services.common.com.gfdi.be';
          my $soap = SOAP::Lite
             ->proxy("http://$user:$pass\@$endpoint")
             ->ns($uri,'ged')
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
      my ($class,$type,$extern_nummer,$doctype,$catalogstartdate,$catalogenddate,$pageNumber,$frame,$zf,$inz_nr) = @_;
      if ($type eq 'EXID') {
           $extern_nummer = sprintf ('%013s',$extern_nummer);#code
          }elsif ($type eq 'NISS') {
           $extern_nummer = sprintf ('%011s',$extern_nummer);#code
          }
         
         undef $documenten;      
         
         my $jaarstart = substr($catalogstartdate,0,4);
         my $maandstart = substr($catalogstartdate,4,2);
         my $dagstart = substr($catalogstartdate,6,2);
         $catalogstartdate ="$jaarstart-$maandstart-$dagstart"."T00:00:01";
         my $jaarend = substr($catalogenddate,0,4);
         my $maandend = substr($catalogenddate,4,2);
         my $dagend = substr($catalogenddate,6,2);
         $catalogenddate ="$jaarend-$maandend-$dagend"."T23:59:59";
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
         my $user = $main::instellingen->{ziekenfondsen}->{$zf}->{as400_user}; 
         my $domain = $main::instellingen->{ziekenfondsen}->{$zf}->{nr};        
         my $pass = $main::instellingen->{ziekenfondsen}->{$zf}->{as400_paswoord}; 
         #my $host = 'rfapps.jablux.cpc998.be/RFND_GRP200b_1407.02_20150118_03:80';  # always include the port
         #my $wsdlfn='C:\macros\ClientTool\GEDCatalogService.xml';
         my $zkf = $main::instellingen->{ziekenfondsen}->{$zf}->{nr};          
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
          my $thirdCodeType = SOAP::Data->name('thirdCodeType' => "$type")->type('');
          my $thirdCodeValue = SOAP::Data->name('thirdCodeValue' => "$extern_nummer")->type('');
          my $thirdOrg = SOAP::Data->name('thirdOrg' => $zkf)->type('');
          my $pageSize  = SOAP::Data->name('pageSize' => $main::instellingen->{page_size_doccenter})->type('');
          my $setPageNumber  = SOAP::Data->name('pageNumber' => $pageNumber)->type('');
          #my $in0 = SOAP::Data->name('ged:in0')->value(\SOAP::Data->value($catalog_key));
          my $in0 = '';
         if ($extern_nummer > 0 and $type ne '') {
              $in0 = SOAP::Data->name('ged:in0')
                 ->value(\SOAP::Data->value($catalogEndDate,$catalogStartDate,$docType,$thirdCodeType,$thirdCodeValue,$thirdOrg)); #$thirdCodeType,$thirdCodeValue,
          }elsif ($doctype ne '') {
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
                     my $externnr = $extern_nummer;
                     my $rijksregnr =  $inz_nr; 
                     my $voornaam = $link->[$doc_teller]->{thirdFName};
                     my $achternaam = $link->[$doc_teller]->{thirdName};
                     my $thirdtype = $link->[$doc_teller]->{thirdPartyType};
                     my $folder = $link->[$doc_teller]->{folderType};
                     my $docType = $link->[$doc_teller]->{docType};
                     my $dcId = $link->[$doc_teller]->{dcId};
                     my $direction = $link->[$doc_teller]->{direction};
                     print $fh "$externnr,$key,$rijksregnr,$voornaam,$achternaam,$direction,$doctype,$dcId\n";
                     push (@main::te_verwerken_extnr,$externnr);
                     $documenten->{$key}->{ExternNummer} =$externnr;
                     $documenten->{$key}->{RijksRegisterNummer}=$rijksregnr;
                     $documenten->{$key}->{VoorNaam}=$voornaam;
                     $documenten->{$key}->{AchterNaam} = $achternaam;
                     $documenten->{$key}->{thirdPartyType} = $thirdtype;
                     $documenten->{$key}->{folder} = $folder;
                     $documenten->{$key}->{doctType} =$docType;
                     $documenten->{$key}->{dcId} = $dcId;
                     $documenten->{$key}->{direction}= $direction;
                     $docteller += 1;
                    }
                 print '';
                }else {
                 my $key = $link->{key};
                 my $externnr = $extern_nummer;
                 my $rijksregnr = $inz_nr; 
                 my $voornaam = $link->{thirdFName};
                 my $achternaam = $link->{thirdName};
                 my $thirdtype = $link->{thirdPartyType};
                 my $folder = $link->{folderType};
                 my $docType = $link->{docType};
                 my $dcId = $link->{dcId};
                 my $direction = $link->{direction};
                 push (@main::te_verwerken_extnr,$externnr);
                 print $fh "$externnr,$key,$rijksregnr,$voornaam,$achternaam,$direction,$doctype,$dcId\n";
                 $documenten->{$key}->{ExternNummer} =$externnr;
                 $documenten->{$key}->{RijksRegisterNummer}=$rijksregnr;
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
         my ($self,$zf) = @_;
          my $zkf = $main::instellingen->{ziekenfondsen}->{$zf}->{nr};
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
         my ($class,$url,$dcId,$direction,$zf) = @_;
         my $generate = "false";
         if ($direction eq 'OUT') {
             $generate = 'true';
         }
         my $user= $main::instellingen->{ziekenfondsen}->{$zf}->{as400_user};
         my $passwd = $main::instellingen->{ziekenfondsen}->{$zf}->{as400_paswoord};
         my $basicauth = encode_base64("$user:$passwd");
          my $test = decode_base64($basicauth);
         my $download_url = $url."$dcId&format=pdf&generate=$generate&vl=false&basicauth=$basicauth&c_tb_img=false&c_tb_view=false&c_tb_ann=false&h_tb_ann=false&zoom=1.0&notes_enabled=false&ann_enabled=false&Scale=best";
         print "\n$download_url\n";
         return ($download_url);
      }
     sub PDF_naar_Agresso {
         my ($class,$agresso_doctype) = @_;
         my $clientnummer = $main::klant->{Agresso_nummer};
         my $test = $clientnummer+1;
         return ('mislukt','geen agresso klant') if (!$clientnummer or $test < 100000); 
         my $zkf = $main::klant->{zkf_nr};
         my $file_name = $main::file;
         $file_name =~ m/\\[a-zA-Z\d]+\.pdf$/i;
         $file_name = $&;
         $file_name =~ s/\\//;
         ##$clientnummer = 67122533419;#;100048 100248 166516
         use SOAP::Lite ;
         my $catalog_Key =$agresso_doctype;
         my $folderRef_text = $file_name;           
         my $omschrij = $folderRef_text;    
        
         my $proxy = "http://$instellingen->{Agresso_IP}/BusinessWorld-webservices/service.svc?CustomerService/Customer";# test
         my $uri   = 'http://services.agresso.com/DocArchiveService/DocArchiveV201101';
         my $soap = SOAP::Lite
             ->proxy($proxy)
             ->ns($uri,'doc')
             ->on_action( sub { return 'AddDocument' } );
         my $DocId  = SOAP::Data->name('doc:DocId'=> 0)->type('');         
         my $DocType  = SOAP::Data->name('doc:DocType'=> $catalog_Key )->type('');
         my $RevisionNo = SOAP::Data->name('doc:RevisionNo'=> 1)->type('');        
         my $FileName = SOAP::Data->name('doc:FileName'=> "$folderRef_text")->type('');
         $folderRef_text =~ s/\.pdf//i;
         $folderRef_text =~ s/\.msg//i;
         $folderRef_text = uc $folderRef_text;
         my $user = 'DOCCENTER';       
         my $Comments_data  = $folderRef_text;
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
      use SOAP::Lite ;#'trace', 'debug' ;
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
      my $proxy = "http://$instellingen->{Agresso_IP}/BusinessWorld-webservices/service.svc"; #productie    
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