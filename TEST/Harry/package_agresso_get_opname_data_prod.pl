#!/usr/bin/perl -w
use strict;

package package_agresso_get_opname_data;
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
#&package_agresso_get_opname_data;
sub agresso_get_opname_data {
     my ($class,$clientnummer ) = @_;
     #$clientnummer =120971;
     use SOAP::Lite ;
     # +trace => [ transport => sub { print $_[0]->as_string } ];
     my $ip = $main::agresso_instellingen->{"Agresso_IP_$main::mode"}; 
     my $proxy = "http://$ip/BusinessWorld-webservices/service.svc?QueryEngineService/QueryEngineV201101"; # productie/test    
     my $uri   = 'http://services.agresso.com/QueryEngineService/QueryEngineV201101';
     my $soap = SOAP::Lite
        ->proxy($proxy, timeout => 1000)
        ->ns($uri,'query')
        ->on_action( sub { return 'GetTemplateResultAsDataSet' } );
     #my $template    = SOAP::Data->name('query:TemplateId' => "4268")->type(''); #4260 assurkarc 4268 nieuw verkoopsorders
     my $template    = SOAP::Data->name('query:TemplateId' => "4433")->type(''); #productie
     my $pipeline    = SOAP::Data->name('query:PipelineAssociatedName' => "false")->type('');
      #query:SearchCriteriaProperties>
      my $ColumnName  = SOAP::Data->name('query:ColumnName'=> "apar_id")->type('');
      my $RestrictionType= SOAP::Data->name('query:RestrictionType' => "=")->type('');
      my $FromValue = SOAP::Data->name('query:FromValue' => "$clientnummer")->type('');
      my $DataType = SOAP::Data->name('query:DataType' => "3")->type('');
      my $DataLength = SOAP::Data->name('query:DataLength' => "25")->type('');
      my $DataCase = SOAP::Data->name('query:DataCase' => "0")->type('');
      my $IsParameter = SOAP::Data->name('query:IsParameter' => "true")->type('');
      my $IsVisible =SOAP::Data->name('query:IsVisible' => "true")->type('');
      my $IsPrompt =SOAP::Data->name('query:IsPrompt' => "false")->type('');
      my $IsMandatory =SOAP::Data->name('query:IsMandatory' => "false")->type('');
      my $CanBeOverridden =SOAP::Data->name('query:CanBeOverridden' => "false")->type('');
      #/query:SearchCriteriaProperties>
      my $SearchCriteriaProperties = SOAP::Data->name('query:SearchCriteriaProperties')
          ->value(\SOAP::Data->value($ColumnName, $RestrictionType,$FromValue,$DataType,$DataLength
                                     ,$DataCase,$IsParameter,$IsVisible,$IsPrompt,$IsMandatory,$CanBeOverridden));
      my $ColumnName_1  = SOAP::Data->name('query:ColumnName'=> "fiscal_year")->type('');
      my $RestrictionType_1= SOAP::Data->name('query:RestrictionType' => ">=")->type('');
      my $FromValue_1 = SOAP::Data->name('query:FromValue' => '$YEAR(-1)')->type('');
      my $DataType_1 = SOAP::Data->name('query:DataType' => "3")->type('');
      my $DataLength_1 = SOAP::Data->name('query:DataLength' => "4")->type('');
      my $DataCase_1 = SOAP::Data->name('query:DataCase' => "0")->type('');
      my $IsParameter_1 = SOAP::Data->name('query:IsParameter' => "true")->type('');
      my $IsVisible_1 =SOAP::Data->name('query:IsVisible' => "false")->type('');
      my $IsPrompt_1 =SOAP::Data->name('query:IsPrompt' => "false")->type('');
      my $IsMandatory_1 =SOAP::Data->name('query:IsMandatory' => "false")->type('');
      my $CanBeOverridden_1 =SOAP::Data->name('query:CanBeOverridden' => "false")->type('');
      #/query:SearchCriteriaProperties>
      my $SearchCriteriaProperties_1 = SOAP::Data->name('query:SearchCriteriaProperties')
          ->value(\SOAP::Data->value($ColumnName_1, $RestrictionType_1,$FromValue_1,$DataType_1,$DataLength_1
                                     ,$DataCase_1,$IsParameter_1,$IsVisible_1,$IsPrompt_1,$IsMandatory_1,$CanBeOverridden_1));    
       my $SearchCriteriaPropertiesList=  SOAP::Data->name('query:SearchCriteriaPropertiesList')
          ->value(\SOAP::Data->value($SearchCriteriaProperties,$SearchCriteriaProperties_1));
      my $input       = SOAP::Data->name('query:input') ->value(\SOAP::Data->value($template, $pipeline,$SearchCriteriaPropertiesList));
      my $Username    = SOAP::Data->name('query:Username' => 'WEBSERV')->type('');
      my $Client      = SOAP::Data->name('query:Client'   => 'VMOB')->type('');
      my $Password    = SOAP::Data->name('query:Password' => 'WEBSERV')->type('');
      my $credentials = SOAP::Data->name('query:credentials') ->value(\SOAP::Data->value($Username, $Client, $Password));
      my $response = $soap->mySOAPFunction($input,$credentials);
      #print "\nopname data response\n_________________________________________\n";
      #print Dumper(\$response);
      #sleep 10;
      #print "\n____________\neinde dumper\n____________\n";
      
      eval {my $returncode =$response->{_content}[2][0][2][0][4]->{GetTemplateResultAsDataSetResult}->{ReturnCode}};
      if ($response->{_content}[2][0][2][0][4]->{GetTemplateResultAsDataSetResult}->{ReturnCode}==0 and !$@) {
         eval {my $antwoord_niet_leeg = $response->{_content}[2][0][2][0][4]->{GetTemplateResultAsDataSetResult}->{TemplateResult}->{diffgram}->{Agresso}->{AgressoQE}};
         if ($@) {
             #leeg antwoord
         }else {
             my $link = $response->{_content}[2][0][2][0][4]->{GetTemplateResultAsDataSetResult}->{TemplateResult}->{diffgram}->{Agresso}->{AgressoQE};
             eval {my $resultaten = $link->[0]->{apar_id}};
             if ($@) {
                eval {my $resultaten = $link->{apar_id}};
                if (!$@) {
                      my $opname_teller =0;
                      $main::klant->{opnames}->[$opname_teller]->{begindatum}=$link->{dim_6};
                      $main::klant->{opnames}->[$opname_teller]->{einddatum}=$link->{dim_7};
                    }    
               }else {
                 my $opname_teller =0;
                 #sorteren 
                 my $sorteertstap;
                 foreach my $nr (sort keys $link) {
                      my $rang = "$link->[$nr]->{dim_6}$link->[$nr]->{dim_7}";
                      $sorteertstap->{$rang}->{begindatum}=$link->[$nr]->{dim_6};
                      $sorteertstap->{$rang}->{einddatum}=$link->[$nr]->{dim_7};
                    }
                 foreach my $rang  (reverse sort keys $sorteertstap) {
                      $main::klant->{opnames}->[$opname_teller]->{begindatum} =  $sorteertstap->{$rang}->{begindatum};
                      $main::klant->{opnames}->[$opname_teller]->{einddatum}= $sorteertstap->{$rang}->{einddatum};
                      $opname_teller +=1;
                    }
                 #foreach my $nr (sort keys $link) {
                 #    $main::klant->{opnames}->[$opname_teller]->{begindatum}=$link->[$nr]->{dim_6};
                 #    $main::klant->{opnames}->[$opname_teller]->{einddatum}=$link->[$nr]->{dim_7};
                 #    $opname_teller +=1;
                 #   }
                }
            }
        }
      #my $test = $main::klant->{opnames};
      
      #print "";
    }
1;