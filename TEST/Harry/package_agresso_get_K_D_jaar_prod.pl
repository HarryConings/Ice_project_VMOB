#!/usr/bin/perl -w
use strict;


package package_get_K_D_jaar;
use strict;
use Data::Dumper;
use XML::Compile::Schema;
use XML::Compile::Cache;
use XML::LibXML::Reader;     
use XML::Simple;
use Date::Manip::DM5 ;
use Date::Calc qw(:all);
use File::Copy;
use Net::SMTP;
use DBI;
our $vandaag = ParseDate("today");
our $dbh_mssql;
our @invoice_processed;
my $vandaag_tijd = $vandaag;
$vandaag_tijd =~ s/://g;
$vandaag_tijd =~ s/\s//g;
#&agresso_get_K_D_jaar ('bla',100044,2014);#100044
sub agresso_get_K_D_jaar {
      my ($class,$clientnummer,$jaar,$verzekering ) = @_;
      $verzekering = lc $verzekering;
      use SOAP::Lite ;
      #+trace => [ transport => sub { print $_[0]->as_string } ];    
     my $ip = $main::agresso_instellingen->{"Agresso_IP_$main::mode"};      
     my $proxy = "http://$ip/BusinessWorld-webservices/service.svc?QueryEngineService/QueryEngineV201101"; # productie/test    
     my $uri   = 'http://services.agresso.com/QueryEngineService/QueryEngineV201101';
     my $soap = SOAP::Lite
        ->proxy($proxy)
        ->ns($uri,'query')
        ->on_action( sub { return 'GetTemplateResultAsDataSet' } );
     my $template    = SOAP::Data->name('query:TemplateId' => "4417")->type('');
     my $pipeline    = SOAP::Data->name('query:PipelineAssociatedName' => "false")->type('');
     #query:SearchCriteriaProperties>
      my $ColumnName  = SOAP::Data->name('query:ColumnName'=> "apar_id")->type('');
      my $RestrictionType= SOAP::Data->name('query:RestrictionType' => "=")->type('');
      my $FromValue = SOAP::Data->name('query:FromValue' => "$clientnummer")->type('');
      my $DataType = SOAP::Data->name('query:DataType' => "10")->type('');
      my $DataLength = SOAP::Data->name('query:DataLength' => "25")->type('');
      my $DataCase = SOAP::Data->name('query:DataCase' => "2")->type('');
      my $IsParameter = SOAP::Data->name('query:IsParameter' => "true")->type('');
      my $IsVisible =SOAP::Data->name('query:IsVisible' => "true")->type('');
      my $IsPrompt =SOAP::Data->name('query:IsPrompt' => "true")->type('');
      my $IsMandatory =SOAP::Data->name('query:IsMandatory' => "true")->type('');
      my $CanBeOverridden =SOAP::Data->name('query:CanBeOverridden' => "true")->type('');
      #/query:SearchCriteriaProperties>
      my $SearchCriteriaProperties = SOAP::Data->name('query:SearchCriteriaProperties')
          ->value(\SOAP::Data->value($ColumnName, $RestrictionType,$FromValue,$DataType,$DataLength
                                     ,$DataCase,$IsParameter,$IsVisible,$IsPrompt,$IsMandatory,$CanBeOverridden));
      my $ColumnName_1  = SOAP::Data->name('query:ColumnName'=> "f2_jaar")->type('');
      my $RestrictionType_1= SOAP::Data->name('query:RestrictionType' => "=")->type('');
      my $FromValue_1 = SOAP::Data->name('query:FromValue' => "$jaar")->type('');
      my $ToValue_1 = SOAP::Data->name('query:ToValue' => "")->type('');
      my $DataType_1 = SOAP::Data->name('query:DataType' => "3")->type('');
      my $DataLength_1 = SOAP::Data->name('query:DataLength' => "10")->type('');
      my $DataCase_1 = SOAP::Data->name('query:DataCase' => "0")->type('');
      my $IsParameter_1 = SOAP::Data->name('query:IsParameter' => "true")->type('');
      my $IsVisible_1 =SOAP::Data->name('query:IsVisible' => "true")->type('');
      my $IsPrompt_1 =SOAP::Data->name('query:IsPrompt' => "false")->type('');
      my $IsMandatory_1 =SOAP::Data->name('query:IsMandatory' => "false")->type('');
      my $CanBeOverridden_1 =SOAP::Data->name('query:CanBeOverridden' => "false")->type('');
      #/query:SearchCriteriaProperties>
      my $SearchCriteriaProperties_1 = SOAP::Data->name('query:SearchCriteriaProperties')
          ->value(\SOAP::Data->value($ColumnName_1, $RestrictionType_1,$FromValue_1,$ToValue_1,$DataType_1,$DataLength_1
                                     ,$DataCase_1,$IsParameter_1,$IsVisible_1,$IsPrompt_1,$IsMandatory_1,$CanBeOverridden_1));
      my $ColumnName_2  = SOAP::Data->name('query:ColumnName'=> "article")->type('');
      my $RestrictionType_2= SOAP::Data->name('query:RestrictionType' => "=")->type('');
      my $FromValue_2 = SOAP::Data->name('query:FromValue' => "HOSPI")->type('');
      my $DataType_2 = SOAP::Data->name('query:DataType' => "10")->type('');
      my $DataLength_2 = SOAP::Data->name('query:DataLength' => "25")->type('');
      my $DataCase_2 = SOAP::Data->name('query:DataCase' => "2")->type('');
      my $IsParameter_2 = SOAP::Data->name('query:IsParameter' => "true")->type('');
      my $IsVisible_2 =SOAP::Data->name('query:IsVisible' => "true")->type('');
      my $IsPrompt_2 =SOAP::Data->name('query:IsPrompt' => "false")->type('');
      my $IsMandatory_2 =SOAP::Data->name('query:IsMandatory' => "false")->type('');
      my $CanBeOverridden_2 =SOAP::Data->name('query:CanBeOverridden' => "false")->type('');
      #/query:SearchCriteriaProperties>
      my $SearchCriteriaProperties_2 = SOAP::Data->name('query:SearchCriteriaProperties')
          ->value(\SOAP::Data->value($ColumnName_2, $RestrictionType_2,$FromValue_2,$DataType_2,$DataLength_2
                                     ,$DataCase_2,$IsParameter_2,$IsVisible_2,$IsPrompt_2,$IsMandatory_2,$CanBeOverridden_2));
      my $SearchCriteriaPropertiesList=  SOAP::Data->name('query:SearchCriteriaPropertiesList')
          ->value(\SOAP::Data->value($SearchCriteriaProperties,$SearchCriteriaProperties_1,$SearchCriteriaProperties_2));
      my $input       = SOAP::Data->name('query:input') ->value(\SOAP::Data->value($template, $pipeline,$SearchCriteriaPropertiesList));
      my $Username    = SOAP::Data->name('query:Username' => 'WEBSERV')->type('');
      my $Client      = SOAP::Data->name('query:Client'   => 'VMOB')->type('');
      my $Password    = SOAP::Data->name('query:Password' => 'WEBSERV')->type('');
      my $credentials = SOAP::Data->name('query:credentials') ->value(\SOAP::Data->value($Username, $Client, $Password));
      my $response = $soap->mySOAPFunction($input,$credentials);
      #my $test =  $main::overzicht_matrix;
      eval {my $returncode =$response->{_content}[2][0][2][0][4]->{GetTemplateResultAsDataSetResult}->{ReturnCode}};
      if ($response->{_content}[2][0][2][0][4]->{GetTemplateResultAsDataSetResult}->{ReturnCode}==0 and !$@) {
         eval {my $antwoord_niet_leeg = $response->{_content}[2][0][2][0][4]->{GetTemplateResultAsDataSetResult}->{TemplateResult}->{diffgram}->{Agresso}->{AgressoQE}};
         if ($@) {
             #leeg antwoord
            }else {
             my $link = $response->{_content}[2][0][2][0][4]->{GetTemplateResultAsDataSetResult}->{TemplateResult}->{diffgram}->{Agresso}->{AgressoQE};
             eval {my $resultaten = $link->[0]->{dim_2}};
              if ($@) {
                 #geen nomenclaturen
                }else {
                  foreach my $nr (sort keys $link) {
                     my $nom = $link->[$nr]->{dim_2};
                     my $testjaar = $link->[$nr]->{f1_jaar};
                     my $k_jaar = 0;
                     my $d_jaar = 0;
                     $k_jaar =  $link->[$nr]->{amount} if ($testjaar == $jaar);
                     $d_jaar =  $link->[$nr]->{f0_aantal} if ($testjaar == $jaar);
                     my $verzekering_check = lc $link->[$nr]->{dim_5};
                     my @zit_in_groepsregels =();
                     foreach my $groeps_nom    (keys $main::nomenclaturen_per_groepsregel) {
                         if ($nom ~~ @{$main::nomenclaturen_per_groepsregel->{$groeps_nom}}) {
                               push (@zit_in_groepsregels,$groeps_nom) if ($nom ne '');                               
                              }
                        }
                     #my @test = @main::overzicht_matrix;
                     for  (my $overzicht_rij =0 ; $overzicht_rij < $main::aantal_rij_overzicht_matrix; $overzicht_rij++) {
                         my $notest =$main::overzicht_matrix[$overzicht_rij][1];
                         if ($main::overzicht_matrix[$overzicht_rij][1] == $nom and (defined $nom) and ($main::overzicht_matrix[$overzicht_rij][1] >1) and $verzekering_check eq $verzekering) {
                             $main::overzicht_matrix[$overzicht_rij][10]= $main::overzicht_matrix[$overzicht_rij][10]-$k_jaar if ($nom < 999990);#code
                             $main::overzicht_matrix[$overzicht_rij][11]=$main::overzicht_matrix[$overzicht_rij][11]+$d_jaar if ($nom < 999990); # groepsregels niet tweemaal samantellen
                            }
                         
                         if ($main::overzicht_matrix[$overzicht_rij][1] ~~ @zit_in_groepsregels and ($main::overzicht_matrix[$overzicht_rij][1] > 1) and (defined $nom) and $verzekering_check eq $verzekering and ($k_jaar !=0 or $d_jaar != 0) ) {
                               my $soort_werkblad = $main::rekenregels_per_nomenclatuur->{$nom}->{soort_werkblad};                            
                               $main::overzicht_matrix[$overzicht_rij][10]=$main::overzicht_matrix[$overzicht_rij][10]-$k_jaar if (lc ($soort_werkblad) ne 'dienst' and lc ($soort_werkblad) ne 'groepsregel');#code
                               $main::overzicht_matrix[$overzicht_rij][11]=$main::overzicht_matrix[$overzicht_rij][11]+$d_jaar if (lc ($soort_werkblad) ne 'dienst' and lc ($soort_werkblad) ne 'groepsregel'); 
                               
                                                             }
                         # print "nom $nom nomtest $notest 999997k $main::overzicht_matrix[22][10] $k_jaar \n";
                         # print "nom $nom nomtest $notest 999997d $main::overzicht_matrix[22][11] $d_jaar \n";
                         # print "nom $nom nomtest $notest 999999 $main::overzicht_matrix[51][10] $k_jaar \n";
                         # print "nom $nom nomtest $notest 999999d $main::overzicht_matrix[51][11] $d_jaar \n";
                         #print "";
                        }
                      
                       print;
                    }
                }
                
            }
        }
      # my @test = @main::overzicht_matrix;
      #my %test = %main::nomenclaturen_per_groepsregel;
      #my %test1 = %main::nomenclatuurnummers_per_groep;
       #foreach my $groeps_nom    (keys %main::nomenclaturen_per_groepsregel) {
       #      foreach my $test_nom (@{%main::nomenclaturen_per_groepsregel->{$groeps_nom}}) {
       #            $groeps_nomeclatuur = $groeps_nom if ($test_nom == $nomenclatuur and $groeps_nom != 999999);
       #        }
       #   }
      print "";
      
}
1;