#!/usr/bin/perl -w

use strict;

package package_agresso_get_calculater_info;
use strict;
use Wx qw[:everything];
use base qw(Wx::Frame);
use Wx qw(wxEVT_SCROLL_TOP wxEVT_SCROLL_BOTTOM wxEVT_SCROLL_LINEUP
               wxEVT_SCROLL_LINEDOWN wxEVT_SCROLL_PAGEUP wxEVT_SCROLL_PAGEDOWN
               wxEVT_SCROLL_THUMBTRACK wxEVT_SCROLL_THUMBRELEASE );
use Wx::Event qw( EVT_BUTTON EVT_TEXT_ENTER EVT_UPDATE_UI );
use Wx::Locale gettext => '_T';
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
use DateTime::Format::Strptime;
use DateTime;
#use DateTime::Span;
our $vandaag = ParseDate("today");
our $dbh_mssql;
our @invoice_processed;
my $vandaag_tijd = $vandaag;
$vandaag_tijd =~ s/://g;
$vandaag_tijd =~ s/\s//g;
our $tijd = substr ($vandaag_tijd,8,6);
$vandaag = substr ($vandaag,0,8);
#&agresso_get_clients_with_assurcard_invoices;
#&agresso_get_info;
#&agresso_get_customer_info;
#&agresso_get_customer_info_rr_nr;
#&agresso_get_invoice_info;
sub variant_LG04 {
           my ($self,$user) = @_;
           use SOAP::Lite ;
            #+trace => [ transport => sub { print $_[0]->as_string } ];
           #+trace => [ transport => sub { print $_[0]->as_string } ];
            #my $Default_Variant = $main::agresso_instellingen->{Default_variant_LG04};
            my $ip = $main::agresso_instellingen->{"Agresso_IP_$main::mode"}; 
            my $proxy = "http://$ip/service.svc?QueryEngineService/QueryEngineV201101";  
            my $uri   = 'http://services.agresso.com/QueryEngineService/QueryEngineV201101';
            my $soap = SOAP::Lite
             ->proxy($proxy)
             ->ns($uri,'query')
             ->on_action( sub { return 'GetTemplateResultAsDataSet' } );    
            my $template    = SOAP::Data->name('query:TemplateId' => "4658")->type(''); #prod
            my $pipeline    = SOAP::Data->name('query:PipelineAssociatedName' => "false")->type('');
            my $ColumnName  = SOAP::Data->name('query:ColumnName'=> "att_value")->type('');
            my $RestrictionType= SOAP::Data->name('query:RestrictionType' => "=")->type('');
            my $FromValue = SOAP::Data->name('query:FromValue' => "$user")->type('');
            my $ToValue = SOAP::Data->name('query:ToValue' => "$user")->type('');
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
                 ->value(\SOAP::Data->value($ColumnName, $RestrictionType,$FromValue,$ToValue,$DataType,$DataLength
                                     ,$DataCase,$IsParameter,$IsVisible,$IsPrompt,$IsMandatory,$CanBeOverridden));
            my $SearchCriteriaPropertiesList=  SOAP::Data->name('query:SearchCriteriaPropertiesList')
                    ->value(\SOAP::Data->value($SearchCriteriaProperties));     
            my $input       = SOAP::Data->name('query:input') ->value(\SOAP::Data->value($template, $pipeline,$SearchCriteriaPropertiesList));
            my $Username    = SOAP::Data->name('query:Username' => 'WEBSERV')->type('');
            my $Client      = SOAP::Data->name('query:Client'   => 'VMOB')->type('');
            my $Password    = SOAP::Data->name('query:Password' => 'WEBSERV')->type('');
            my $credentials = SOAP::Data->name('query:credentials') ->value(\SOAP::Data->value($Username, $Client, $Password));
            my $response = $soap->mySOAPFunction($input,$credentials);
            my $resultaten = $main::agresso_instellingen->{Default_variant_LG04};
            eval {my $returncode =$response->{_content}[2][0][2][0][4]->{GetTemplateResultAsDataSetResult}->{ReturnCode}};
            if ($response->{_content}[2][0][2][0][4]->{GetTemplateResultAsDataSetResult}->{ReturnCode}==0 and !$@) {
                 eval {my $antwoord_niet_leeg = $response->{_content}[2][0][2][0][4]->{GetTemplateResultAsDataSetResult}->{TemplateResult}->{diffgram}->{Agresso}->{AgressoQE}};
                 if ($@) {
                     #leeg antwoord
                    }else {
                     my $link = $response->{_content}[2][0][2][0][4]->{GetTemplateResultAsDataSetResult}->{TemplateResult}->{diffgram}->{Agresso}->{AgressoQE};
                     eval {$resultaten = $link->{rel_value}};
                     if ($@) {
                          #geen nomenclaturen
                         }else {
                           $resultaten = $link->{rel_value}
                         }
                    }
         
               }
            return($resultaten);
         
          }
sub agresso_get_clients_with_assurcard_invoices {
      use SOAP::Lite ;
      #+trace => [ transport => sub { print $_[0]->as_string } ];
      my $ip = $main::agresso_instellingen->{"Agresso_IP_$main::mode"}; 
      my $proxy = "http://$ip/service.svc?QueryEngineService/QueryEngineV201101"; # productie/test    
      my $uri   = 'http://services.agresso.com/QueryEngineService/QueryEngineV201101';
      my $soap = SOAP::Lite
        ->proxy($proxy)
        ->ns($uri,'query')
        ->on_action( sub { return 'GetTemplateResultAsDataSet' } );
      #my $template    = SOAP::Data->name('query:TemplateId' => "4266")->type('');
      #my $template    = SOAP::Data->name('query:TemplateId' => "4276")->type('');#vesir 2 test
      my $template    = SOAP::Data->name('query:TemplateId' => "4421")->type(''); #prod
      my $pipeline    = SOAP::Data->name('query:PipelineAssociatedName' => "false")->type('');
      my $input       = SOAP::Data->name('query:input') ->value(\SOAP::Data->value($template, $pipeline));
      my $Username    = SOAP::Data->name('query:Username' => 'WEBSERV')->type('');
      my $Client      = SOAP::Data->name('query:Client'   => 'VMOB')->type('');
      my $Password    = SOAP::Data->name('query:Password' => 'WEBSERV')->type('');
      my $credentials = SOAP::Data->name('query:credentials') ->value(\SOAP::Data->value($Username, $Client, $Password));
      $main::progess_dialog->Update(2,'Agresso Soap');
      my $response = $soap->mySOAPFunction($input,$credentials);
      $main::progess_dialog->Update(5,'Agresso Response');
      #my @klanten;
      my @klantnaam;
      my $aantal_klanten = 0;
      eval {my $faultcodecode =$response->{_content}[2][0][2][0][4]->{faultcode}};
      if (!$@) {
           if (defined $response->{_content}[2][0][2][0][4]->{faultcode}) {
                my $faultcodecode =$response->{_content}[2][0][2][0][4]->{faultcode};#code
                my $faultstring = $response->{_content}[2][0][2][0][4]->{faultstring};
                my $tekst = "AGRESSO NOK $faultstring";
                return ($tekst);  #code
               }
          }
      
      eval {my $returncode =$response->{_content}[2][0][2][0][4]->{GetTemplateResultAsDataSetResult}->{ReturnCode}};
      if ($@) {
           #code
          }else {
           if ($response->{_content}[2][0][2][0][4]->{GetTemplateResultAsDataSetResult}->{ReturnCode} == 0) {
                eval {my $bestaat = $response->{_content}[2][0][2][0][4]->{GetTemplateResultAsDataSetResult}->{TemplateResult}->{diffgram}->{Agresso}->{AgressoQE}};
                if ($@) {
                     return ('geen_facturen'); #code
                }else {
                     foreach my $volgnr (keys  $response->{_content}[2][0][2][0][4]->{GetTemplateResultAsDataSetResult}->{TemplateResult}->{diffgram}->{Agresso}->{AgressoQE}) {
                          eval {my $klant_id = $response->{_content}[2][0][2][0][4]->{GetTemplateResultAsDataSetResult}->{TemplateResult}->{diffgram}->{Agresso}->{AgressoQE}[$volgnr]->{f0_klantid}};
                          if ($@) {
                                my $klant_id = $response->{_content}[2][0][2][0][4]->{GetTemplateResultAsDataSetResult}->{TemplateResult}->{diffgram}->{Agresso}->{AgressoQE}->{f0_klantid};
                                my $klant_naam = $response->{_content}[2][0][2][0][4]->{GetTemplateResultAsDataSetResult}->{TemplateResult}->{diffgram}->{Agresso}->{AgressoQE}->{description__2};
                                my $klant_rijksreg = $response->{_content}[2][0][2][0][4]->{GetTemplateResultAsDataSetResult}->{TemplateResult}->{diffgram}->{Agresso}->{AgressoQE}->{dim_3};
                                push (@main::klanten_met_assurcard_facturen,$klant_id);
                                $main::klanten_met_assurcard_facturen_rijksregnr->{$klant_id} =$klant_rijksreg;
                                push (@klantnaam,$klant_naam);
                                $aantal_klanten +=1;
                          }else {
                                my $klant_id = $response->{_content}[2][0][2][0][4]->{GetTemplateResultAsDataSetResult}->{TemplateResult}->{diffgram}->{Agresso}->{AgressoQE}[$volgnr]->{f0_klantid};
                                my $klant_naam = $response->{_content}[2][0][2][0][4]->{GetTemplateResultAsDataSetResult}->{TemplateResult}->{diffgram}->{Agresso}->{AgressoQE}[$volgnr]->{description__2};
                                my $klant_rijksreg = $response->{_content}[2][0][2][0][4]->{GetTemplateResultAsDataSetResult}->{TemplateResult}->{diffgram}->{Agresso}->{AgressoQE}[$volgnr]->{dim_3};
                                push (@main::klanten_met_assurcard_facturen,$klant_id);
                                $main::klanten_met_assurcard_facturen_rijksregnr->{$klant_id} =$klant_rijksreg;
                                push (@klantnaam,$klant_naam);
                                $aantal_klanten +=1;
                          }
                          
                         
                         }
                     $main::aantal_klanten_met_facturen = $aantal_klanten ;
                    }
               }
          }
      #my @test1 = @main::klanten_met_assurcard_facturen ;
       @main::klanten_met_assurcard_facturen_niet_gesorteerd = @main::klanten_met_assurcard_facturen ;
       @main::klanten_met_assurcard_facturen = sort ( @main::klanten_met_assurcard_facturen);
       $main::progess_dialog->Update(6,'Response Analyzed');
      return ('ok');
    }
sub agresso_get_invoice_info {
      my ($class,$clientnummer,$rijksregnr) = @_;
      #47063035268 133480
      undef $main::invoice ;
      undef @main::invoices;
      undef @main::invoices_check;
      #use SOAP::Lite 'trace', 'debug' ;
      use SOAP::Lite ;
      #+trace => [ transport => sub { print $_[0]->as_string } ];
      use Data::Dumper;
      use warnings;
      $ENV{HTTPS_DEBUG} = 1;
      $ENV{HTTP_DEBUG} = 1;
      #$clientnummer = 102301;
       my $ip = $main::agresso_instellingen->{"Agresso_IP_$main::mode"}; 
       my $proxy = "http://$ip/service.svc?QueryEngineService/QueryEngineV201101"; # productie/test      
       my $uri   = 'http://services.agresso.com/QueryEngineService/QueryEngineV201101';
       my $soap = SOAP::Lite
            ->proxy($proxy)
            ->ns($uri,'query')
            ->on_action( sub { return 'GetTemplateResultAsDataSet' } );
      #my $template    = SOAP::Data->name('query:TemplateId' => "4267")->type('');
      my $template    = SOAP::Data->name('query:TemplateId' => "4422")->type('');#prod
      my $pipeline    = SOAP::Data->name('query:PipelineAssociatedName' => "false")->type('');
      #query:SearchCriteriaProperties>
      #my $ColumnName  = SOAP::Data->name('query:ColumnName'=> "f0_klantid")->type('');
      my $ColumnName  = SOAP::Data->name('query:ColumnName'=> "dim_3")->type('');
      my $RestrictionType= SOAP::Data->name('query:RestrictionType' => "=")->type('');
      #my $FromValue = SOAP::Data->name('query:FromValue' => "$clientnummer")->type('');
      my $FromValue = SOAP::Data->name('query:FromValue' => "$rijksregnr")->type('');
      #my $DataType = SOAP::Data->name('query:DataType' => "3")->type('');
       my $DataType = SOAP::Data->name('query:DataType' => "10")->type('');
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
      my $SearchCriteriaPropertiesList=  SOAP::Data->name('query:SearchCriteriaPropertiesList')
          ->value(\SOAP::Data->value($SearchCriteriaProperties));   
      my $input       = SOAP::Data->name('query:input') ->value(\SOAP::Data->value($template, $pipeline,$SearchCriteriaPropertiesList));
      my $Username    = SOAP::Data->name('query:Username' => 'WEBSERV')->type('');
      my $Client      = SOAP::Data->name('query:Client'   => 'VMOB')->type('');
      my $Password    = SOAP::Data->name('query:Password' => 'WEBSERV')->type('');
      my $credentials = SOAP::Data->name('query:credentials') ->value(\SOAP::Data->value($Username, $Client, $Password));
      my $response = $soap->mySOAPFunction($input,$credentials);
      eval {my $faultstring = $response->{_content}[2][0][2][0][4]->{faultstring}};
      if (!$@) {
           if (defined $response->{_content}[2][0][2][0][4]->{faultstring}) {
                my $faultstring = $response->{_content}[2][0][2][0][4]->{faultstring};
                my $tekst = "AGRESSO NOK $faultstring";
                return ($tekst);  #code
               }
      }
      
      eval {my $returncode =$response->{_content}[2][0][2][0][4]->{GetTemplateResultAsDataSetResult}->{ReturnCode}};
      
      if ($@) {
           #geen factuur
      }else {
           #kolom layout gewoon
           #$grid->SetColLabelValue(0, _T("Dagen"));                            $grid->SetColLabelValue(0, _T("Voor- en Nazorg/Ambulante zorgen"));
           #$grid->SetColLabelValue(1, _T("Bdrg/dg"));                          $grid->SetColLabelValue(1, _T("M-D-A"));   
           #$grid->SetColLabelValue(2, _T("P. tsk."));                          $grid->SetColLabelValue(2, _T("Datum"));
           #$grid->SetColLabelValue(3, _T("Sup."));                             $grid->SetColLabelValue(3, _T("Code"));
           #$grid->SetColLabelValue(4, _T("Totaal"));                           $grid->SetColLabelValue(4, _T("P. tsk."));
           #$grid->SetColLabelValue(5, _T("Z. tsk"));                           $grid->SetColLabelValue(5, _T("Z. tsk"));
           #$grid->SetColLabelValue(6, _T("HP+ tsk"));                          $grid->SetColLabelValue(6, _T("HP+ tsk"));
           #$grid->SetColLabelValue(7, _T("Verschil"));                         $grid->SetColLabelValue(7, _T("Verschil"));
           #$grid->SetColLabelValue(8, _T("Regel Toegepast"));                  $grid->SetColLabelValue(8, _T("Datum -$aantal_dagen_voor_begindatum"));
           #$grid->SetColLabelValue(9, _T("Aanvaard"));                         $grid->SetColLabelValue(9, _T("Datum +$aantal_dagen_na_einddatum"));
           #$grid->SetColLabelValue(10, _T("Geweigerd"));                       $grid->SetColLabelValue(10, _T("Regel Toegepast"));
           #$grid->SetColLabelValue(11, _T("100%"));
           #$grid->SetColLabelValue(12, _T("200%"));
           #$grid->SetColLabelValue(13, _T("Dienst"));
           my $facturen_die_niet_mogen_voorkomen;
           if ($response->{_content}[2][0][2][0][4]->{GetTemplateResultAsDataSetResult}->{ReturnCode} == 0 ) {
                eval {my $records = $response->{_content}[2][0][2][0][4]->{GetTemplateResultAsDataSetResult}->{TemplateResult}->{diffgram}->{Agresso}->{AgressoQE}[0]->{_recno} };
                if (!$@) {
                     my $link = $response->{_content}[2][0][2][0][4]->{GetTemplateResultAsDataSetResult}->{TemplateResult}->{diffgram}->{Agresso}->{AgressoQE};
                     my $invoice_nr = 0;
                     my $invoice_nr_oud =0;
                     my $teller = 0;
                     my $invoice;
                     my $honderd = 0;
                     my $tweehonderd = 0;
                     my @oapartnom= ();
                     my @groen =();
                     my $dienst ;
                     my $franchise_patient_part ;
                     my $franchise_overcharges ;
                     foreach my $nr (sort keys $link) {
                          $invoice_nr = $link->[$nr]->{ext_inv_ref};
                          
                          if (!defined $invoice_nr ) {
                               print "";
                              }else {
                          $dienst->{$invoice_nr} = 0 if (!defined $dienst->{$invoice_nr});    
                          my $rij_nr = $link->[$nr]->{value_1};                          
                          if ($rij_nr == 0) {
                               $facturen_die_niet_mogen_voorkomen->{$invoice_nr}='mag niet voorkomen';#niet normaal #code
                          }else {
                               $main::invoice->{$invoice_nr}->{$rij_nr}->{interne_nomenclatuur} = $link->[$nr]->{dim_2};
                               if ( $link->[$nr]->{dim_2}== 882077) {
                                    push (@groen,$nr);#code
                                   }
                               #franchise
                               my $franchise =0;
                               if ( $link->[$nr]->{dim_2}== 882206) {
                                    #maak franchise regel en verander dim in 882000
                                    $main::invoice->{$invoice_nr}->{99999991}->{interne_nomenclatuur} = 882206;
                                    $main::invoice->{$invoice_nr}->{99999991}->{aantal_dagen} =1;
                                    $main::invoice->{$invoice_nr}->{99999991}->{begindatum} = 0;
                                    $main::invoice->{$invoice_nr}->{99999991}->{dienst} =0;
                                    $main::invoice->{$invoice_nr}->{99999991}->{einddatum} = 0;
                                    $main::invoice->{$invoice_nr}->{99999991}->{honderd} =0;
                                    $main::invoice->{$invoice_nr}->{99999991}->{supplement} =0;
                                    $main::invoice->{$invoice_nr}->{99999991}->{tweehonderd} =0;
                                    $main::invoice->{$invoice_nr}->{99999991}->{voucher_type} = 'BZ';
                                    #$main::invoice->{$invoice_nr}->{$rij_nr}->{interne_nomenclatuur} = 882000;
                                    $franchise_overcharges->{$invoice_nr} += $link->[$nr]->{amount}  if ($link->[$nr]->{dim_1} eq 'OVERCHARGES') ;
                                    $franchise_patient_part->{$invoice_nr} += $link->[$nr]->{amount}  if ($link->[$nr]->{dim_1} eq 'PATIENTPART') ;
                                    $link->[$nr]->{dim_1} = 'FRANCHISE';
                                    $franchise =1;
                                   }
                               #einde franchise
                               $main::invoices_zgt_mark_invoices->{$invoice_nr}->{apar_id}=$link->[$nr]->{f0_klantid};
                               $main::invoices_zgt_mark_invoices->{$invoice_nr}->{voucher_no} =$link->[$nr]->{voucher_no};                               
                               my $sequence_no = $link->[$nr]->{sequence_no};
                               $main::invoices_zgt_mark_invoices->{$invoice_nr}->{sequence_no}->{$sequence_no}= $rij_nr;
                               $main::invoices_zgt_mark_invoices->{$invoice_nr}->{ext_inv_ref} = $link->[$nr]->{ext_inv_ref};
                               $main::invoice->{$invoice_nr}->{$rij_nr}->{voucher_type}= $link->[$nr]->{voucher_type};
                              
                               my $suplement =0;
                               my $persoonlijke_tussenkomst = 0;
                               if ($link->[$nr]->{dim_1} eq 'OVERCHARGES') {
                                    $main::invoice->{$invoice_nr}->{$rij_nr}->{supplement} = $link->[$nr]->{amount};
                                    $main::invoice->{$invoice_nr}->{$rij_nr}->{honderd} = abs($link->[$nr]->{value_2});
                                    $main::invoice->{$invoice_nr}->{$rij_nr}->{tweehonderd} = abs($link->[$nr]->{value_3});
                                    $main::invoice->{$invoice_nr}->{$rij_nr}->{begindatum} = $link->[$nr]->{dim_6};
                                    $main::invoice->{$invoice_nr}->{$rij_nr}->{einddatum} = $link->[$nr]->{dim_7};
                                    $main::invoice->{$invoice_nr}->{$rij_nr}->{aantal_dagen}= $link->[$nr]->{number_1};
                                    $main::invoice->{$invoice_nr}->{$rij_nr}->{aantal_dagen}= 0 if ($franchise ==1);
                                    if ($link->[$nr]->{dim_4} > 0) {
                                         if ($dienst->{$invoice_nr} != $link->[$nr]->{dim_4}) {
                                              $dienst->{$invoice_nr}=$link->[$nr]->{dim_4}; #code
                                              $main::invoice->{$invoice_nr}->{$rij_nr}->{dienst}= $dienst->{$invoice_nr};
                                              #foreach my $nr_nr  (sort keys $main::invoice->{$invoice_nr}) {
                                              #     if ($main::invoice->{$invoice_nr}->{$nr_nr}->{dienst} != $dienst->{$invoice_nr}) {
                                              #          $main::invoice->{$invoice_nr}->{$nr_nr}->{dienst} =  $dienst->{$invoice_nr};
                                              #         }
                                              #    }
                                             }
                                        }else {
                                         $main::invoice->{$invoice_nr}->{$rij_nr}->{dienst}= $dienst->{$invoice_nr};
                                        }
                                   }elsif ($link->[$nr]->{dim_1} eq 'PATIENTPART') {
                                    $main::invoice->{$invoice_nr}->{$rij_nr}->{persoonlijke_tussenkomst} = $link->[$nr]->{amount};
                                    $main::invoice->{$invoice_nr}->{$rij_nr}->{begindatum} = $link->[$nr]->{dim_6};
                                    $main::invoice->{$invoice_nr}->{$rij_nr}->{einddatum} = $link->[$nr]->{dim_7}; 
                                    if ($link->[$nr]->{dim_4} > 0) {
                                         if ($dienst->{$invoice_nr} != $link->[$nr]->{dim_4}) {
                                              $dienst->{$invoice_nr}=$link->[$nr]->{dim_4}; #code
                                              $main::invoice->{$invoice_nr}->{$rij_nr}->{dienst}= $dienst->{$invoice_nr};
                                              #foreach my $nr_nr  (sort keys $main::invoice->{$invoice_nr}) {
                                              #     if ($main::invoice->{$invoice_nr}->{$nr_nr}->{dienst} != $dienst->{$invoice_nr}) {
                                              #          $main::invoice->{$invoice_nr}->{$nr_nr}->{dienst} =  $dienst->{$invoice_nr};
                                              #         }
                                              #    }
                                             }
                                        }else {
                                         $main::invoice->{$invoice_nr}->{$rij_nr}->{dienst}= $dienst->{$invoice_nr};
                                        }
                                   }else {
                                    push (@oapartnom,$link->[$nr]->{dim_2});
                                   }
                              }
                          } # invoice not definded
                         }
                     #my $test = $main::invoice;
                     #my $test_zgt = $main::invoices_zgt_mark_invoices;
                     #dienst nr
                     foreach my $inv_nr (keys $dienst) {
                          my $dienstnr = $dienst->{$inv_nr};
                          eval {my $bestaat = $main::invoice->{$inv_nr}};
                          if (!$@ and defined $main::invoice->{$inv_nr} ) {
                               foreach my $rij_nr (keys $main::invoice->{$inv_nr}) {
                                    if (!defined $main::invoice->{$inv_nr}->{$rij_nr}->{dienst}) {
                                         $main::invoice->{$inv_nr}->{$rij_nr}->{dienst}=$dienstnr;
                                        }
                                   }
                              }
                         }
                     undef  $main::lijnen_per_invoice_per_nom;
                     foreach my $inv_nr (keys $main::invoice){
                          if ($inv_nr ne '' or defined $inv_nr) {
                               push (@main::invoices,$inv_nr);#code
                               #francise terugzetten
                               foreach my $rijnr (keys $main::invoice->{$inv_nr}) {
                                     my $nom = $main::invoice->{$inv_nr}->{$rijnr}->{interne_nomenclatuur};
                                     if ($main::invoice->{$inv_nr}->{$rijnr}->{interne_nomenclatuur} == 882000 and $main::invoice->{$inv_nr}->{$rijnr}->{aantal_dagen} > 0 ) {
                                         $main::invoice->{$inv_nr}->{$rijnr}->{persoonlijke_tussenkomst} += $franchise_patient_part->{$inv_nr};
                                         $main::invoice->{$inv_nr}->{$rijnr}->{supplement} += $franchise_overcharges->{$inv_nr};
                                        }
                                     $main::lijnen_per_invoice_per_nom->{$inv_nr}->{$nom} +=1;
                                     
                                     if ($main::invoice->{$inv_nr}->{$rijnr}->{interne_nomenclatuur} == 882000 and $main::invoice->{$inv_nr}->{$rijnr}->{aantal_dagen} == 0 ) {
                                         delete $main::invoice->{$inv_nr}->{$rijnr};
                                         #print "test\n";
                                        }
                                   }
                              }
                          
                         }
                    
                     print "";
                     #my $testa1 =$main::lijnen_per_invoice_per_nom;
                     foreach my $inv (keys $main::lijnen_per_invoice_per_nom) {
                         my $maxlijnen = 0;
                         foreach my $nom (keys $main::lijnen_per_invoice_per_nom->{$inv }){
                               $maxlijnen = $main::lijnen_per_invoice_per_nom->{$inv}->{$nom} if ($main::lijnen_per_invoice_per_nom->{$inv}->{$nom} > $maxlijnen);
                              }
                          $main::max_lijnen_invoice->{$inv} = $maxlijnen;
                        }
                      #my $testa =$main::max_lijnen_invoice;
                      print "";
                    }
                
               }
           
      }
      
      # print Dumper(\$response);
     
      print "";
      
    }
sub agresso_get_customer_info {
      use SOAP::Lite ;#'trace', 'debug' ;
      my ($class,$clientnummer ) = @_;
      #$clientnummer = 100048 ;#;100048 100248 166516
      #use SOAP::Lite ;
      my $ip = $main::agresso_instellingen->{"Agresso_IP_$main::mode"}; 
      my $proxy = "http://$ip/service.svc"; # productie /test
      my $uri   = 'http://services.agresso.com/CustomerService/Customer';
      my $soap = SOAP::Lite
            ->proxy($proxy)
            ->ns($uri,'cus')
            ->on_action( sub { return 'GetCustomer' } );
      my $company   = SOAP::Data->name('cus:company'=> 'VMOB')->type('');
      my $customerId =  SOAP::Data->name('cus:customerId'=> "$clientnummer")->type('');
      my $customerDetailsOnly =  SOAP::Data->name('cus:customerDetailsOnly'=> "0")->type('');
      my $Username    = SOAP::Data->name('cus:Username' => 'WEBSERV')->type('');
      my $Client      = SOAP::Data->name('cus:Client'   => 'VMOB')->type('');
      my $Password    = SOAP::Data->name('cus:Password' => 'WEBSERV')->type('');
      my $credentials = SOAP::Data->name('cus:credentials') ->value(\SOAP::Data->value($Username, $Client, $Password));
      #my $GetCustomer       = SOAP::Data->name('cus:GetCustomer')
      #->value(\SOAP::Data->value($company , $customerId, $customerDetailsOnly ,$credentials ));
      my $response = $soap->GetCustomer($company , $customerId, $customerDetailsOnly ,$credentials );
      eval {my $returncode =$response->{_content}[2][0][2][0][4]->{GetCustomerResult}->{ReturnCode}};
      if ( $response->{_content}[2][0][2][0][4]->{GetCustomerResult}->{ReturnCode} == 40 and !$@) {
          #code
      
      
      print "";
      $main::klant->{Agresso_nummer} = $clientnummer;
      $main::klant->{naam} =$response->{_content}[2][0][2][0][4]->{GetCustomerResult}->{CustomerType}->{CustomerName};
      $main::klant->{Rijksreg_Nr} =$response->{_content}[2][0][2][0][4]->{GetCustomerResult}->{CustomerType}->{ExternalReference};
      $main::klant->{Bankrekening}=$response->{_content}[2][0][2][0][4]->{GetCustomerResult}->{CustomerType}->{BankAccount};
      $main::klant->{Taal}=$response->{_content}[2][0][2][0][4]->{GetCustomerResult}->{CustomerType}->{Language};
      eval {my $meerdere_adressen = $response->{_content}[2][0][2][0][4]->{GetCustomerResult}->{CustomerType}->{AddressList}->{AddressUnitType}->[0]->{Address}};
      if ($@) {
           $main::klant->{adres}->[0]->{Straat}=$response->{_content}[2][0][2][0][4]->{GetCustomerResult}->{CustomerType}->{AddressList}->{AddressUnitType}->{Address};
           $main::klant->{adres}->[0]->{Stad}=$response->{_content}[2][0][2][0][4]->{GetCustomerResult}->{CustomerType}->{AddressList}->{AddressUnitType}->{Place};
           $main::klant->{adres}->[0]->{Postcode}=$response->{_content}[2][0][2][0][4]->{GetCustomerResult}->{CustomerType}->{AddressList}->{AddressUnitType}->{ZipCode};
           $main::klant->{adres}->[0]->{Telefoon_nr}=$response->{_content}[2][0][2][0][4]->{GetCustomerResult}->{CustomerType}->{AddressList}->{AddressUnitType}->{Telephone1};
           $main::klant->{adres}->[0]->{e_mail}=$response->{_content}[2][0][2][0][4]->{GetCustomerResult}->{CustomerType}->{AddressList}->{AddressUnitType}->{eMail};
           $main::klant->{adres}->[0]->{type}='Domi';
          }else {
           my $adres_teller = 0;
           foreach my $nr (keys $response->{_content}[2][0][2][0][4]->{GetCustomerResult}->{CustomerType}->{AddressList}->{AddressUnitType}) {
                $main::klant->{adres}->[$adres_teller]->{Straat}=$response->{_content}[2][0][2][0][4]->{GetCustomerResult}->{CustomerType}->{AddressList}->{AddressUnitType}->[$nr]->{Address};
                $main::klant->{adres}->[$adres_teller]->{Stad}=$response->{_content}[2][0][2][0][4]->{GetCustomerResult}->{CustomerType}->{AddressList}->{AddressUnitType}->[$nr]->{Place};
                $main::klant->{adres}->[$adres_teller]->{Postcode}=$response->{_content}[2][0][2][0][4]->{GetCustomerResult}->{CustomerType}->{AddressList}->{AddressUnitType}->[$nr]->{ZipCode};
                $main::klant->{adres}->[$adres_teller]->{Telefoon_nr}=$response->{_content}[2][0][2][0][4]->{GetCustomerResult}->{CustomerType}->{AddressList}->{AddressUnitType}->[$nr]->{Telephone1};
                $main::klant->{adres}->[$adres_teller]->{e_mail}=$response->{_content}[2][0][2][0][4]->{GetCustomerResult}->{CustomerType}->{AddressList}->{AddressUnitType}->[$nr]->{eMail};
                my $adres_type =$response->{_content}[2][0][2][0][4]->{GetCustomerResult}->{CustomerType}->{AddressList}->{AddressUnitType}->[$nr]->{AddressType};
                if ($adres_type == 1) {
                     $main::klant->{adres}->[$adres_teller]->{type}='Domi';
                    }else {
                     $main::klant->{adres}->[$adres_teller]->{type}='Post';
                    }
                
                $adres_teller += 1;
               }
          }
      
      
      #we gaan de verzekeringen opzoeken
      my $link =$response->{_content}[2][0][2][0][4]->{GetCustomerResult}->{CustomerType}->{FlexiGroupList}->{FlexiGroupUnitType};
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
       #sorteer op actieve contracten
       
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
      eval {foreach my $nr (sort keys $main::klant->{contracten}) {}};
      if ($@) {
         Wx::MessageBox( _T("Opgelet dit lid heeft geen contract"), 
                   _T("CONTRACTEN"), 
                   wxOK|wxCENTRE, 
                   $main::frame
                );    #code
      }else {
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
      }
      
      
      return ($teller);
    }

sub agresso_get_customer_info_rr_nr {
      use SOAP::Lite;# 'trace', 'debug' ;
      my ($class,$clientnummer ) = @_;
      #$clientnummer = 67122533419;#;100048 100248 166516
      #use SOAP::Lite ;
      my $ip = $main::agresso_instellingen->{"Agresso_IP_$main::mode"}; 
      my $proxy = "http://$ip/service.svc?QueryEngineService/QueryEngineV201101"; # productie/test
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
      #my $GetCustomer       = SOAP::Data->name('cus:GetCustomer')
      #->value(\SOAP::Data->value($company , $customerId, $customerDetailsOnly ,$credentials ));
      my $response = $soap->GetCustomers($customerObject, $customerDetailsOnly ,$credentials );
      eval {my $returncode =$response->{_content}[2][0][2][0][4]->{GetCustomersResult}->{ReturnCode}};
      if ( $response->{_content}[2][0][2][0][4]->{GetCustomersResult}->{ReturnCode} == 40 and !$@) {
          #code
      
      
      print "";
      $main::klant->{Agresso_nummer} = $response->{_content}[2][0][2][0][4]->{GetCustomersResult}->{CustomerTypeList}->{CustomerObject}->{CustomerID};
      #my $test = $response->{_content}[2][0][2][0][4]->{GetCustomersResult}->{CustomerTypeList}->{CustomerObject}->{CustomerName};
      $main::klant->{naam} =$response->{_content}[2][0][2][0][4]->{GetCustomersResult}->{CustomerTypeList}->{CustomerObject}->{CustomerName};
      $main::klant->{Rijksreg_Nr} =$response->{_content}[2][0][2][0][4]->{GetCustomersResult}->{CustomerTypeList}->{CustomerObject}->{ExternalReference};
      $main::klant->{Bankrekening}=$response->{_content}[2][0][2][0][4]->{GetCustomersResult}->{CustomerTypeList}->{CustomerObject}->{BankAccount};
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
                        } 
                  }else {
                   foreach my $number (sort keys $link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->{FlexiFieldList}->{FlexiFieldUnitType}) {
                         if ($link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->{FlexiFieldList}->{FlexiFieldUnitType}->[$number]->{ColumnName} eq 'geboortedatum') {
                               $link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->{FlexiFieldList}->{FlexiFieldUnitType}->[$number]->{Value} =~ m%\d+/\d+/\d{4}%;
                               $main::klant->{geboortedatum} = $&;
                              }
                         if ($link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->{FlexiFieldList}->{FlexiFieldUnitType}->[$number]->{ColumnName} eq 'aantal_kaarten_fx') {
                               $link->[$nr]->{FlexiFieldRowList}->{FlexiRowUnitType}->{FlexiFieldList}->{FlexiFieldUnitType}->[$number]->{Value} =~ m%\d+%;
                               $main::klant->{aantal_kaarten} = $&;
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
1;
#OK