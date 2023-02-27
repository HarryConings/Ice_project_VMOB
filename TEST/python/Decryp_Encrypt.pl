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
package encrypt;
     use MIME::Base64;
     sub new {
         my ($self,$password) = @_;
         chomp $password;
         $password=~ s/\n//g;
         my $first = substr ($password,0,3);
         my $last = $password;
         $last =~ s/^$first//;
         my $random =int(rand(10));
         my $long_password = '';
         my $ecrypted_password = '';
         if ($random == 0) {
             $long_password = "$last"."HedendaagseKunst$first"."LagerfeldZone3816"."$first"."a365$random";
             $ecrypted_password = encode_base64($long_password);
             $ecrypted_password=~ s/\n//g;
            }elsif ($random == 1) {
             $long_password = "$last"."nombrefils5$first"."Louise1512"."$first"."kind23$random";
             $ecrypted_password = encode_base64($long_password);
             $ecrypted_password=~ s/\n//g;
            }elsif ($random == 2) {
             $long_password = "$last"."LiebeMarco1562$first"."JeanPaul1789"."$first"."256fG$random";
             $ecrypted_password = encode_base64($long_password);
             $ecrypted_password=~ s/\n//g;
            }elsif ($random == 3) {
             $long_password = "$last"."PaternosterEerst1203$first"."Janzingt598"."$first"."Gjoel523697$random";
             $ecrypted_password = encode_base64($long_password);
             $ecrypted_password=~ s/\n//g;
            }elsif ($random == 4) {
             $long_password = "$last"."Elio1et8978Joelle$first"."Jan897541las"."$first"."fietsmaart$random";
             $ecrypted_password = encode_base64($long_password);
             $ecrypted_password=~ s/\n//g;
            }elsif ($random == 5) {
             $long_password = "$last"."4578Fortissimo$first"."MusicandLife"."$first"."hiRondelle$random";
             $ecrypted_password = encode_base64($long_password);
             $ecrypted_password=~ s/\n//g;
            }elsif ($random == 6) {
             $long_password = "$last"."3245Fortissimo$first"."MusicandLife5841"."$first"."Paris214$random";
             $ecrypted_password = encode_base64($long_password);
             $ecrypted_password=~ s/\n//g;
            }elsif ($random == 7) {
             $long_password = "$last"."Pater4787nosterEerst18457$first"."Janzingt"."$first"."47Londoncalling$random";
             $ecrypted_password = encode_base64($long_password);
             $ecrypted_password=~ s/\n//g;
            }elsif ($random == 8) {
             $long_password = "$last"."Elio1et1448Joelle$first"."Janlas12478"."$first"."wAndelaar$random";
             $ecrypted_password = encode_base64($long_password);
             $ecrypted_password=~ s/\n//g;
            }elsif ($random == 9) {
             $long_password = "$last"."1234978Fortissimo$first"."Music159878andLife"."$first"."WiezoektDie$random";
             $ecrypted_password = encode_base64($long_password);
             $ecrypted_password=~ s/\n//g;
            }
         return($ecrypted_password);
           
     }

package decrypt;
     use MIME::Base64;
     sub new {
         my ($self,$ecrypted_password) = @_;
         $ecrypted_password =~ s/\n//g;
         my $decode = decode_base64($ecrypted_password);
         $decode =~ m/\d$/;
         my $random = $&;
         $decode =~ s/$random$//;
         #print "random = $random";
         if ($random == 0) {
             $decode =~ m/HedendaagseKunst.*LagerfeldZone3816/;
             my $decode_first = $&;
             $decode_first =~ s/HedendaagseKunst//;
             $decode_first =~ s/LagerfeldZone3816//;
             $decode =~ s/HedendaagseKunst//;
             $decode =~ s/LagerfeldZone3816.*$//;
             $decode =~ s/$decode_first$//;
             $decode = "$decode_first$decode";             
            }elsif ($random == 1) {
             #$long_password = "$last"."nombrefils5$first"."Louise1512"."$first$random";
             $decode =~ m/nombrefils5.*Louise1512/;
             my $decode_first = $&;
             $decode_first =~ s/nombrefils5//;
             $decode_first =~ s/Louise1512//;
             $decode =~ s/nombrefils5//;
             $decode =~ s/Louise1512.*$//;
             $decode =~ s/$decode_first$//;
             $decode = "$decode_first$decode";     
            }elsif ($random == 2) {
             #$long_password = "$last"."LiebeMarco1562$first"."JeanPaul1789"."$first$random";
             $decode =~ m/LiebeMarco1562.*JeanPaul1789/;
             my $decode_first = $&;
             $decode_first =~ s/LiebeMarco1562//;
             $decode_first =~ s/JeanPaul1789//;
             $decode =~ s/LiebeMarco1562//;
             $decode =~ s/JeanPaul1789.*$//;
             $decode =~ s/$decode_first$//;
             $decode = "$decode_first$decode";  
            }elsif ($random == 3) {
             #$long_password = "$last"."PaternosterEerst1203$first"."Janzingt598"."$first$random";
             $decode =~ m/PaternosterEerst1203.*Janzingt598/;
             my $decode_first = $&;
             $decode_first =~ s/PaternosterEerst1203//;
             $decode_first =~ s/Janzingt598//;
             $decode =~ s/PaternosterEerst1203//;
             $decode =~ s/Janzingt598.*$//;
             $decode =~ s/$decode_first$//;
             $decode = "$decode_first$decode";  
            }elsif ($random == 4) {
             #$long_password = "$last"."Elio1et8978Joelle$first"."Jan897541las"."$first$random";
             $decode =~ m/Elio1et8978Joelle.*Jan897541las/;
             my $decode_first = $&;
             $decode_first =~ s/Elio1et8978Joelle//;
             $decode_first =~ s/Jan897541las//;
             $decode =~ s/Elio1et8978Joelle//;
             $decode =~ s/Jan897541las.*$//;
             $decode =~ s/$decode_first$//;
             $decode = "$decode_first$decode";  
            }elsif ($random == 5) {
             #$long_password = "$last"."4578Fortissimo$first"."MusicandLife"."$first$random";
             $decode =~ m/4578Fortissimo.*MusicandLife/;
             my $decode_first = $&;
             $decode_first =~ s/4578Fortissimo//;
             $decode_first =~ s/MusicandLife//;
             $decode =~ s/4578Fortissimo//;
             $decode =~ s/MusicandLife.*$//;
             $decode =~ s/$decode_first$//;
             $decode = "$decode_first$decode";  
            }elsif ($random == 6) {
             #$long_password = "$last"."3245Fortissimo$first"."MusicandLife5841"."$first$random";
             $decode =~ m/3245Fortissimo.*MusicandLife5841/;
             my $decode_first = $&;
             $decode_first =~ s/3245Fortissimo//;
             $decode_first =~ s/MusicandLife5841//;
             $decode =~ s/3245Fortissimo//;
             $decode =~ s/MusicandLife5841.*$//;
             $decode =~ s/$decode_first$//;
             $decode = "$decode_first$decode";  
            }elsif ($random == 7) {
             #$long_password = "$last"."Pater4787nosterEerst18457$first"."Janzingt"."$first$random";
             $decode =~ m/Pater4787nosterEerst18457.*Janzingt/;
             my $decode_first = $&;
             $decode_first =~ s/Pater4787nosterEerst18457//;
             $decode_first =~ s/Janzingt//;
             $decode =~ s/Pater4787nosterEerst18457//;
             $decode =~ s/Janzingt.*$//;
             $decode =~ s/$decode_first$//;
             $decode = "$decode_first$decode";  
            }elsif ($random == 8) {
             #$long_password = "$last"."Elio1et1448Joelle$first"."Janlas12478"."$first$random";
             $decode =~ m/Elio1et1448Joelle.*Janlas12478/;
             my $decode_first = $&;
             $decode_first =~ s/Elio1et1448Joelle//;
             $decode_first =~ s/Janlas12478//;
             $decode =~ s/Elio1et1448Joelle//;
             $decode =~ s/Janlas12478.*$//;
             $decode =~ s/$decode_first$//;
             $decode = "$decode_first$decode";  
            }elsif ($random == 9) {
             #$long_password = "$last"."1234978Fortissimo$first"."Music159878andLife"."$first$random";
              $decode =~ m/1234978Fortissimo.*Music159878andLife/;
             my $decode_first = $&;
             $decode_first =~ s/1234978Fortissimo//;
             $decode_first =~ s/Music159878andLife//;
             $decode =~ s/1234978Fortissimo//;
             $decode =~ s/Music159878andLife.*$//;
             $decode =~ s/$decode_first$//;
             $decode = "$decode_first$decode";  
            }
           return ($decode);
          
     }

1;