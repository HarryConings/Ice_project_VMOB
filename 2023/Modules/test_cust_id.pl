#!/usr/bin/perl -w
use strict;
use SOAP::Lite ;
     #+trace => [ transport => sub { print $_[0]->as_string } ];
 use MIME::Base64;
     use LWP::Simple;
     use DateTime::Format::Strptime;
     use DateTime;
     use Date::Manip::DM5 ;

our $mail_scanning ;
&agresso_get_customer_info_rr_nr('',83051640916,'');
&agresso_get_customer_info_rr_nr('',60073024369,'');
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
      my $proxy = "http://S200WP1XXL01\.mutworld\.be/BusinessWorld-webservices/service.svc"; #productie    
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
      #print "\napestaart-$@\-\n";
      print "-> fout $@\n" if($@);
      #if (!$@) {
            if ( $response->{_content}[2][0][2][0][4]->{GetCustomersResult}->{ReturnCode} == 40 and !$@) {         #code
                eval {print "\nCustomerID $response->{_content}[2][0][2][0][4]->{GetCustomersResult}->{CustomerTypeList}->{CustomerObject}->{CustomerID}\n"};
                if (!$@) {
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
                         eval {my $geen_adres = $response->{_content}[2][0][2][0][4]->{GetCustomersResult}->{CustomerTypeList}->{CustomerObject}->{AddressList}->{AddressUnitType}->{Address}};
                         if (!$@) {                              
                            $main::klant->{adres}->[0]->{Straat}=$response->{_content}[2][0][2][0][4]->{GetCustomersResult}->{CustomerTypeList}->{CustomerObject}->{AddressList}->{AddressUnitType}->{Address};
                            $main::klant->{adres}->[0]->{Stad}=$response->{_content}[2][0][2][0][4]->{GetCustomersResult}->{CustomerTypeList}->{CustomerObject}->{AddressList}->{AddressUnitType}->{Place};
                            $main::klant->{adres}->[0]->{Postcode}=$response->{_content}[2][0][2][0][4]->{GetCustomersResult}->{CustomerTypeList}->{CustomerObject}->{AddressList}->{AddressUnitType}->{ZipCode};
                            $main::klant->{adres}->[0]->{Telefoon_nr}=$response->{_content}[2][0][2][0][4]->{GetCustomersResult}->{CustomerTypeList}->{CustomerObject}->{AddressList}->{AddressUnitType}->{Telephone1};
                            $main::klant->{adres}->[0]->{e_mail}=$response->{_content}[2][0][2][0][4]->{GetCustomersResult}->{CustomerTypeList}->{CustomerObject}->{AddressList}->{AddressUnitType}->{eMail};
                         } else {
                            $main::klant->{adres}->[0]->{Straat} = '';
                            $main::klant->{adres}->[0]->{Stad}= '';
                            $main::klant->{adres}->[0]->{Postcode}='';
                            $main::klant->{adres}->[0]->{Telefoon_nr}='';
                            $main::klant->{adres}->[0]->{e_mail}='';
                         }
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
                    print "meerdere custid voor $clientnummer !!!\n";
                    $mail_scanning =  $mail_scanning."meerdere custid voor $clientnummer !!!\n";
                    foreach my $aantal_cus (sort keys $response->{_content}[2][0][2][0][4]->{GetCustomersResult}->{CustomerTypeList}->{CustomerObject} ) {
                        print "\t$aantal_cus\t cus_id $response->{_content}[2][0][2][0][4]->{GetCustomersResult}->{CustomerTypeList}->{CustomerObject}->[$aantal_cus]->{CustomerID}\n";
                        $mail_scanning =  $mail_scanning."\t$aantal_cus \tcus_id->$response->{_content}[2][0][2][0][4]->{GetCustomersResult}->{CustomerTypeList}->{CustomerObject}->[$aantal_cus]->{CustomerID}\n";
                    }
                    return ("nok");
                }
                
            }else {
                 return ("nok");
            }
        #}else {
        #    return ("nok");
        #}
      
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
     
