#!/usr/bin/perl -w
use strict;
#package main;
#package_get_K_D_jaar->agresso_get_TANDPLUS_jaar(163444,2021,'TANDPLUS','10.198.216.90');
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

sub agresso_get_TANDPLUS_jaar {
      my ($class,$clientnummer,$jaar,$verzekering,$ip,$remgeldnom) = @_;
      my $k_jaar = 0;
      my $rem_jaar = 0;
      #$verzekering = lc $verzekering;
      use SOAP::Lite ;
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
      my $ColumnName_1  = SOAP::Data->name('query:ColumnName'=> "f1_jaar")->type('');
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
      my $ColumnName_3  = SOAP::Data->name('query:ColumnName'=> "dim_5")->type('');
      my $RestrictionType_3= SOAP::Data->name('query:RestrictionType' => "=")->type('');
      my $FromValue_3 = SOAP::Data->name('query:FromValue' => "$verzekering")->type('');
      my $DataType_3 = SOAP::Data->name('query:DataType' => "10")->type('');
      my $DataLength_3 = SOAP::Data->name('query:DataLength' => "25")->type('');
      my $DataCase_3 = SOAP::Data->name('query:DataCase' => "2")->type('');
      my $IsParameter_3 = SOAP::Data->name('query:IsParameter' => "true")->type('');
      my $IsVisible_3 =SOAP::Data->name('query:IsVisible' => "true")->type('');
      my $IsPrompt_3 =SOAP::Data->name('query:IsPrompt' => "false")->type('');
      my $IsMandatory_3 =SOAP::Data->name('query:IsMandatory' => "false")->type('');
      my $CanBeOverridden_3 =SOAP::Data->name('query:CanBeOverridden' => "false")->type('');
      #/query:SearchCriteriaProperties>
      my $SearchCriteriaProperties_3 = SOAP::Data->name('query:SearchCriteriaProperties')
          ->value(\SOAP::Data->value($ColumnName_3, $RestrictionType_3,$FromValue_3,$DataType_3,$DataLength_3
                                     ,$DataCase_3,$IsParameter_3,$IsVisible_3,$IsPrompt_3,$IsMandatory_3,$CanBeOverridden_3));
      my $SearchCriteriaPropertiesList=  SOAP::Data->name('query:SearchCriteriaPropertiesList')
          ->value(\SOAP::Data->value($SearchCriteriaProperties,$SearchCriteriaProperties_1,$SearchCriteriaProperties_2,$SearchCriteriaProperties_3));
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
                           print "nom $nom testjaar $testjaar jaar $jaar\n";
                           print "$k_jaar +=  $link->[$nr]->{amount}\n";
                           print "$rem_jaar +=  $link->[$nr]->{amount}\n";
                           $k_jaar +=  $link->[$nr]->{amount} if ($testjaar == $jaar);
                           $rem_jaar +=  $link->[$nr]->{amount} if ($testjaar == $jaar and $nom == $remgeldnom );                 
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
      print "$rem_jaar   $k_jaar\n";
      return ($k_jaar,$rem_jaar);
}
1;