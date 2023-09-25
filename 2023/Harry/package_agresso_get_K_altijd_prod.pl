#!/usr/bin/perl -w
use strict;

package package_get_K_altijd;
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
#&agresso_get_K_altijd ('bla',100044);#100044
sub agresso_get_K_altijd {
      my ($class,$clientnummer,$verzekering) = @_;
      $verzekering = lc $verzekering;
      use SOAP::Lite ;
      #+trace => [ transport => sub { print $_[0]->as_string } ];
     my $ip = $main::agresso_instellingen->{"Agresso_IP_$main::mode"}; 
     my $proxy = "http://$ip/service.svc?QueryEngineService/QueryEngineV201101"; # productie /test   
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
       my $FromValue_1 = SOAP::Data->name('query:FromValue' => "")->type('');
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
                         my $test = $main::rekenregels_per_nomenclatuur;
                         foreach my $nom_rekenregels (keys $main::rekenregels_per_nomenclatuur) {
                               foreach my $rekenregel (keys $main::rekenregels_per_nomenclatuur->{$nom_rekenregels}) {
                               if ($rekenregel eq 'eenmalig_bedrag') {
                               foreach my $nr (sort keys $link) {
                                 my $nom = $link->[$nr]->{dim_2};
                                 my $verzekering_check = lc $link->[$nr]->{dim_5};
                                 if ($nom == $nom_rekenregels and $verzekering_check eq $verzekering) {
                                     my $k_altijd =  $link->[$nr]->{amount};
                                     my $d_altijd =  $link->[$nr]->{f0_aantal};
                                     for  (my $overzicht_rij =0 ; $overzicht_rij < $main::aantal_rij_overzicht_matrix; $overzicht_rij++) {
                                         if ($main::overzicht_matrix[$overzicht_rij][1] == $nom ) {
                                             $main::overzicht_matrix[$overzicht_rij][10]=-$k_altijd;#code
                                             #$main::overzicht_matrix[$overzicht_rij][11]=$d_altijd;
                                            }
                                        }         
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
1;

