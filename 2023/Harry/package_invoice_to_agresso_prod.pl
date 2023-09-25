#!/usr/bin/perl -w
use strict;
package package_invoice_to_agresso;
use Date::Manip::DM5 ;
use Date::Calc qw(:all);
use Win32;
use File::Slurp;
use utf8;
use Text::Unidecode;
use XML::Simple;
use Wx::Locale gettext => '_T';
use Net::SMTP;
sub maak_agresso_factuur_aan_klant {
     my ($class,$frame) = @_;
          #my $invoice =$main::invoice;
          #my @invoices = @main::invoices;
          #my @invoices_check = @main::invoices_check;
          #my @overzicht_matrix = @main::overzicht_matrix;
          #my $instelingen = $main::instelingen;
          #my @klanten_met_assurcard_facturen = @main::klanten_met_assurcard_facturen;
          #my $klanten_met_assurcard_facturen_teller = $main::klanten_met_assurcard_facturen_teller;
     my @contracts_check = @main::contracts_check;     
     my $naam_verzekering  = '';   
     for (my $i=0; $i < 4; $i++) {
         if ($main::contracts_check[$i] == 1) {
             $naam_verzekering = uc ($main::klant->{contracten}->[$i]->{naam});
            }
        }
          #my @contracts_check = @main::contracts_check;
     my $invoice_zoeknr;
     #my $klant = $main::klanten_met_assurcard_facturen[$main::klanten_met_assurcard_facturen_teller];
     my $klant = $main::klanten_met_assurcard_facturen_niet_gesorteerd[$main::klanten_met_assurcard_facturen_teller];
     my $vandaag = ParseDate("today");
     $vandaag  =~ s/://g;
     my $plaats_file =  $main::agresso_instellingen->{plaats_file};
     my $output_file = "$plaats_file\\Assurcard\.$klant\.AgressoOrder\.$vandaag\.xml";
     print "maak_agresso_factuur_aan_klant $output_file\n";
     #my $output_file ="P:\\OGV\\ASSURCARD_PROG\\asurcard_xml\\Assurcard\.$klant\.AgressoOrder\.$vandaag\.xml";
    
     for (my $nr = 0 ; $nr < 6 ; $nr++) {
         $invoice_zoeknr = $nr if ($main::invoices_check[$nr] == 1) ;
     }
     if (defined $invoice_zoeknr) {
         my $assurcard_invoice_nr = $main::invoices[$invoice_zoeknr];
         
         
         eval {my $test = $main::invoice->{$assurcard_invoice_nr}};
         if (!$@) {
             my $generate_order =0;
             my $LineNo1 =0;
             #my $test = $main::invoice->{$assurcard_invoice_nr};
             my $Period = substr($vandaag,0,6);
             my $begindatum = $main::begindatum_opname;
             my $einddatum  =  $main::einddatum_opname;
             foreach my $LineNo (keys $main::invoice->{$assurcard_invoice_nr}) {
                  if (defined $main::invoice->{$assurcard_invoice_nr}->{$LineNo}->{begindatum} and $main::invoice->{$assurcard_invoice_nr}->{$LineNo}->{begindatum} >0) {
                     $Period = $main::invoice->{$assurcard_invoice_nr}->{$LineNo}->{begindatum};
                     $Period = substr ($Period,0,6);
                    }
                }
             foreach my $LineNo (keys $main::invoice->{$assurcard_invoice_nr}) {
                 if ($generate_order == 0) {
                    
                     #my $test =  $main::invoice->{$assurcard_invoice_nr};
                    
                     my $vandaag = ParseDate("today");
                     $vandaag = substr ($vandaag,0,8);
                     my $jaar = substr ($vandaag,0,4);
                     my $maand =  substr ($vandaag,4,2);
                     my $dag =  substr ($vandaag,6,2);
                     my $OrderDate ="$jaar\-$maand\-$dag";
                     &generate_Order($output_file,$assurcard_invoice_nr,'AF',$Period,$OrderDate,$klant);
                     $generate_order =1;
                    }
                 
                 $LineNo1 = $LineNo1 +1;
                 my $Persoonlijk =  $main::invoice->{$assurcard_invoice_nr}->{$LineNo}->{persoonlijke_tussenkomst};
                 my $Supplement =  $main::invoice->{$assurcard_invoice_nr}->{$LineNo}->{supplement};
                 my $Price =  $Persoonlijk + $Supplement;
                 my $nomenclatuur = $main::invoice->{$assurcard_invoice_nr}->{$LineNo}->{interne_nomenclatuur};
                 my $dagen = $main::invoice->{$assurcard_invoice_nr}->{$LineNo}->{aantal_dagen};
                 #my $begindatum =$main::invoice->{$assurcard_invoice_nr}->{$LineNo}->{begindatum};
                 #my $einddatum = $main::invoice->{$assurcard_invoice_nr}->{$LineNo}->{einddatum};
                 my $dienst = $main::invoice->{$assurcard_invoice_nr}->{$LineNo}->{dienst};
                
                 push (my @tekst ,"Assurcard $assurcard_invoice_nr");
                 &generate_Detail($output_file,$LineNo1,'ASSURCARD',$Price,$nomenclatuur,$dagen,$begindatum,$einddatum,$dienst,$naam_verzekering,@tekst);
                 
                }
             &close_Order ($output_file);
             my $antwoord = &send_order_via_webserv_client($output_file);
             return ($antwoord);
            }else {
             return (_T("Er zijn geen lijnen in de factuur"));
            }
         
         
         
     }else {
         return (_T("Gelieve een factuur te verwerken"));
     }
     
     
}
sub maak_hospi_plus_tussenkomst {
      my ($class,$frame) = @_;
      my $naam_verzekering  = '';   
      for (my $i=0; $i < 4; $i++) {
         if ($main::contracts_check[$i] == 1) {
             $naam_verzekering = uc ($main::klant->{contracten}->[$i]->{naam});
            }
        }
      my $invoice_zoeknr;
      #my $klant = $main::klanten_met_assurcard_facturen[$main::klanten_met_assurcard_facturen_teller];
      my $klant = $main::klanten_met_assurcard_facturen_niet_gesorteerd[$main::klanten_met_assurcard_facturen_teller];
      my $verkoopsdagboek = $main::verkoopsdagboek; #AF voor hospiplus plan FF voor forfait 
      my $vandaag = ParseDate("today");
      $vandaag  =~ s/://g;
      my $plaats_file =  $main::agresso_instellingen->{plaats_file};
      my $output_file = "$plaats_file\\HOSPI\.$klant\.AgressoOrder\.$vandaag\.xml";
       print "maak_hospi_plus_tussenkomst  $output_file\n";
      #my $output_file ="P:\\OGV\\ASSURCARD_PROG\\asurcard_xml\\HOSPI\.$klant\.AgressoOrder\.$vandaag\.xml";
      #my $test= $main::teksten_gebruikte_rekenregels_per_nomenclatuur;
          #my $invoice =$main::invoice;
          #my @invoices = @main::invoices;
          #my @invoices_check = @main::invoices_check;
          my @overzicht_matrix = @main::overzicht_matrix;
          my $aantal_rij_overzicht_matrix = $main::aantal_rij_overzicht_matrix; ;
          #my $instelingen = $main::instelingen;
          #my @klanten_met_assurcard_facturen = @main::klanten_met_assurcard_facturen;
          #my $klanten_met_assurcard_facturen_teller = $main::klanten_met_assurcard_facturen_teller;
          my $begindatum_opname = $main::begindatum_opname;
          my $einddatum_opname =  $main::einddatum_opname;
          my $hospi_tussenkomst = $main::hospi_tussenkomst ;
          my $verschil= $main::verschil ;
      for (my $nr = 0 ; $nr < 6 ; $nr++) {
         $invoice_zoeknr = $nr if ($main::invoices_check[$nr] == 1) ;
        }
      if (defined $invoice_zoeknr) {
         my $assurcard_invoice_nr = $main::invoices[$invoice_zoeknr];
         my $Period = substr($main::begindatum_opname,0,6);
         my $tst = $main::begindatum_opname;
         my $vandaag = ParseDate("today");
             $vandaag = substr ($vandaag,0,8);
             my $jaar = substr ($vandaag,0,4);
             my $maand =  substr ($vandaag,4,2);
             my $dag =  substr ($vandaag,6,2);
             my $OrderDate ="$jaar\-$maand\-$dag";
             &generate_Order($output_file,$assurcard_invoice_nr,$verkoopsdagboek,$Period,$OrderDate,$klant);
             my $LineNo1 = 0;
             my $hospi_totaal =0;
         for (my $i =0; $i <= $aantal_rij_overzicht_matrix; $i++){
             if (defined $main::overzicht_matrix[$i][1] and  $main::overzicht_matrix[$i][1] > 0  ) {
                 if  ((defined $main::overzicht_matrix[$i][8]) and defined $main::overzicht_matrix[$i][8] > 0) {
                     $LineNo1 +=1;
                     my $Price= -$main::overzicht_matrix[$i][8];
                     $hospi_totaal -= $Price;
                     my $nomenclatuur =$main::overzicht_matrix[$i][1];
                     my $dagen =$main::overzicht_matrix[$i][2];
                     my $begindatum =$main::begindatum_opname;
                     my $einddatum =$main::einddatum_opname ;
                     my $dienst =$main::dienst;
                     my @tekst = ();
                     #my $test= $main::teksten_gebruikte_rekenregels_per_nomenclatuur;
                     eval {my $bestaat = @{$main::teksten_gebruikte_rekenregels_per_nomenclatuur->{$nomenclatuur}}};
                     if ($nomenclatuur == 882174) {
                         print "";
                     }
                     #my $test =$main::teksten_gebruikte_rekenregels_per_nomenclatuur;
                     if (!$@)  {
                         foreach my $nr (keys $main::teksten_gebruikte_rekenregels_per_nomenclatuur->{$nomenclatuur}) {
                             push (@tekst,$main::teksten_gebruikte_rekenregels_per_nomenclatuur->{$nomenclatuur}->[$nr]);
                            }
                        }
                     
                     
                    
                     &generate_Detail($output_file,$LineNo1,'HOSPI',$Price,$nomenclatuur,$dagen,$begindatum,$einddatum,$dienst,$naam_verzekering,@tekst);
                    }
                }             
             
            }
         $LineNo1 +=1;
         my @tekst1 = ();
         &generate_Detail($output_file,$LineNo1,'HOSPI',0,1,$main::aantal_dagen_betaald,$main::begindatum_opname,$main::einddatum_opname,'',$naam_verzekering,@tekst1);
         &close_Order ($output_file);
         #my $test = $main::hospi_tussenkomst;
         my $rounded_hospi_tussenkomst = sprintf("%.2f", $main::hospi_tussenkomst);
         my $rounded_hospi_totaal = sprintf("%.2f", $hospi_totaal);
         #if ($main::hospi_tussenkomst == $hospi_totaal) {
         if ($rounded_hospi_tussenkomst == $rounded_hospi_totaal) {
             my $antwoord = &send_order_via_webserv_client($output_file);
              return ($antwoord);
            }else {
             return ("Totalen zijn verschillend lijn 181 : $main::hospi_tussenkomst $hospi_totaal");
            }
        }else {
         return (_T("Geen Assurcard factuur geselecteerd"));
        }
    }
sub generate_Order {
     my ($output_file,$OrderNo,$VoucherType,$Period,$OrderDate,$BuyerNo) = @_;
     $OrderNo =~ s%/.*$%%g;
     
     
     open OUTPUTFILE,">$output_file" or &open_failed($output_file);
     select OUTPUTFILE;
     print '<imp:Xml><![CDATA[<agr:ABWOrder xsi:schemaLocation="http://services.agresso.com/schema/ABWOrder/2007/12/24 http://services.agresso.com/schema/ABWOrder/2007/12/24/ABWOrder.xsd" xmlns:agr="http://services.agresso.com/schema/ABWOrder/2007/12/24" xmlns:agrlib="http://services.agresso.com/schema/ABWSchemaLib/2007/12/24" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">';
     print "\n<agr:Order>\n";
     print "\t<agrlib:OrderNo>$OrderNo</agrlib:OrderNo>\n";
     print "\t<agrlib:VoucherType>$VoucherType</agrlib:VoucherType>\n";
     print "\t<agr:TransType>42</agr:TransType>\n";
     print "<agrlib:Period>$Period</agrlib:Period>\n";
     close OUTPUTFILE;
     &generate_Header ($output_file,$OrderDate,$BuyerNo);
     open OUTPUTFILE,">>$output_file" or &open_failed($output_file);
     select OUTPUTFILE;
     print "\t<agr:Details>\n";
     close OUTPUTFILE;
    }
sub close_Order {
     my ($output_file) = @_;
     open OUTPUTFILE,">>$output_file" or &open_failed($output_file);
     select OUTPUTFILE;
     print "\t</agr:Details>\n";
     print "</agr:Order>\n";
     print "</agr:ABWOrder>\n";
     print "]]></imp:Xml>\n";
     close OUTPUTFILE;
     select STDOUT;
}

sub generate_Header {
     my ($output_file,$OrderDate,$BuyerNo) = @_;
     open OUTPUTFILE,">>$output_file" or &open_failed($output_file);
     select OUTPUTFILE;
     print "\t<agr:Header>\n";
     print "\t\t<agr:OrderType>SO</agr:OrderType>\n";
     print "\t\t<agr:OrderDate>$OrderDate</agr:OrderDate>\n";
     print "\t\t<agr:ObsDate>$OrderDate</agr:ObsDate>\n";
     print "\t\t<agrlib:Currency>EUR</agrlib:Currency>\n";
     print "\t\t<agr:Seller>\n";
     print "\t\t\t<agr:SellerReferences>\n";
     print "\t\t\t\t<agr:Responsible>AGRESS</agr:Responsible>\n";
     my $windows_user = &get_windows_user;
     print "\t\t\t\t<agr:SalesMan>$windows_user</agr:SalesMan>\n";
     print "\t\t\t</agr:SellerReferences>\n";
     print "\t\t</agr:Seller>\n";
     print "\t\t<agr:Buyer>\n";
     print "\t\t\t<agrlib:BuyerNo>$BuyerNo</agrlib:BuyerNo>\n";
     print "\t\t\t<agr:BuyerReferences>\n";
     print "\t\t\t\t<agr:Responsible>AGRESS</agr:Responsible>\n";
     print "\t\t\t\t<agr:RequestedBy>AGRESS</agr:RequestedBy>\n";
     print "\t\t\t\t<agr:Accountable/>\n";
     print "\t\t\t</agr:BuyerReferences>\n";
     print "\t\t</agr:Buyer>\n";
     print "\t</agr:Header>\n";
     close OUTPUTFILE;
    }
sub generate_Detail {
     my ($output_file,$LineNo,$BuyerProductCode,$Price,$nomenclatuur,$dagen,$begindatum,$einddatum,$dienst,$verzekering,@tekst) = @_;
     $dienst =0 if (!defined $dienst);
     $dienst =0 if ($dienst eq '');
     open OUTPUTFILE,">>$output_file" or &open_failed($output_file);
     select OUTPUTFILE;
     print "\t\t<agr:Detail>\n";
     print "\t\t\t<agr:LineNo>$LineNo</agr:LineNo>\n";
     print "\t\t\t<agr:BuyerProductCode>$BuyerProductCode</agr:BuyerProductCode>\n";
     print "\t\t\t<agr:UnitCode>NVT</agr:UnitCode>\n";
     print "\t\t\t<agr:Quantity>1</agr:Quantity>\n";
     print "\t\t\t<agr:Price>$Price</agr:Price>\n";
     print "\t\t\t<agr:LineTotal>$Price</agr:LineTotal>\n";
     print "\t\t\t<agr:DetailInfo>\n";
     print "\t\t\t\t<agrlib:UseLineTotal>1</agrlib:UseLineTotal>\n";
     
     print "\t\t\t\t<agrlib:ReferenceCode>\n";
     print "\t\t\t\t\t<agrlib:Code>O118</agrlib:Code>\n";
     print "\t\t\t\t\t<agrlib:Value>A</agrlib:Value>\n";
     print "\t\t\t\t</agrlib:ReferenceCode>\n";
     
     print "\t\t\t\t<agrlib:ReferenceCode>\n";
     print "\t\t\t\t\t<agrlib:Code>O112</agrlib:Code>\n";
     print "\t\t\t\t\t<agrlib:Value>$nomenclatuur</agrlib:Value>\n";
     print "\t\t\t\t</agrlib:ReferenceCode>\n";
     
     if ($dagen <= 0 or !defined $dagen) { #negatieve dagen zijn 0 carensdagen
         print "\t\t\t\t<agrlib:ReferenceCode>\n";
         print "\t\t\t\t\t<agrlib:Code></agrlib:Code>\n";
         print "\t\t\t\t\t<agrlib:Value></agrlib:Value>\n";
         print "\t\t\t\t</agrlib:ReferenceCode>\n";
     }else {
         print "\t\t\t\t<agrlib:ReferenceCode>\n";
         print "\t\t\t\t\t<agrlib:Code>O119</agrlib:Code>\n";
         print "\t\t\t\t\t<agrlib:Value>$dagen</agrlib:Value>\n";
         print "\t\t\t\t</agrlib:ReferenceCode>\n";
        }
     
     print "\t\t\t\t<agrlib:ReferenceCode>\n";
     print "\t\t\t\t\t<agrlib:Code>O104</agrlib:Code>\n";
     print "\t\t\t\t\t<agrlib:Value>$dienst</agrlib:Value>\n";
     print "\t\t\t\t</agrlib:ReferenceCode>\n";
     
     print "\t\t\t\t<agrlib:ReferenceCode>\n";
     print "\t\t\t\t\t<agrlib:Code>O111</agrlib:Code>\n";
     print "\t\t\t\t\t<agrlib:Value>$verzekering</agrlib:Value>\n";
     print "\t\t\t\t</agrlib:ReferenceCode>\n";
     
     print "\t\t\t\t<agrlib:ReferenceCode>\n";
     print "\t\t\t\t\t<agrlib:Code>O102</agrlib:Code>\n";
     print "\t\t\t\t\t<agrlib:Value>$begindatum</agrlib:Value>\n";
     print "\t\t\t\t</agrlib:ReferenceCode>\n";
     
     print "\t\t\t\t<agrlib:ReferenceCode>\n";
     print "\t\t\t\t\t<agrlib:Code>O103</agrlib:Code>\n";
     print "\t\t\t\t\t<agrlib:Value>$einddatum</agrlib:Value>\n";
     print "\t\t\t\t</agrlib:ReferenceCode>\n";
     
     print "\t\t\t</agr:DetailInfo>\n";
     
     my $tl  =0;
     my $nr1 = 0;
     if ($nomenclatuur == 882174) {
         print "";#code
     }
     eval  {my $bestaat = $tekst[0]};
     if (defined $tekst[0]) {
        
         foreach my $nr (keys @tekst){
             if ($tekst[$nr] =~ m/\d+/ and defined $tekst[$nr]) {
                 $nr1 =$nr+1;
                 print "\t\t\t<agrlib:ProductSpecification>\n";
                 print "\t\t\t\t<agrlib:SeqNo>$nr1</agrlib:SeqNo>\n";
                 print "\t\t\t\t<agrlib:Info>$tekst[$nr]</agrlib:Info>\n";#code
                 print "\t\t\t</agrlib:ProductSpecification>\n";
                }
             $tl +=1;
            }
        
        }
     
     
     #print "\t\t\t<agrlib:ProductSpecification>\n";
     #print "\t\t\t\t<agrlib:SeqNo>1</agrlib:SeqNo>\n";
     #print "\t\t\t\t<agrlib:Info>een</agrlib:Info>\n";
     #print "\t\t\t</agrlib:ProductSpecification>\n";
     print "\t\t</agr:Detail>\n";
     close OUTPUTFILE;
}
sub get_windows_user {
     my $name;
     $name = Win32::LoginName(); # or whatever function you'd like
     $name = uc($name);
     #print "gebruikersnaam = $name\n";
     return ($name) ;    
}
sub open_failed {
     my $file = @_;
     print "kan file $file niet openen\n";
}
sub send_order_via_webserv_client {
     my ($output_file) = @_;
     print "send_order_via_webserv_client $output_file\n";
     my $cdata= read_file($output_file);
     print "";
     use SOAP::Lite ;
     #+trace => [ transport => sub { print $_[0]->as_string } ];
     use XML::Compile::SOAP12::Client;
     use XML::Writer;
     use XML::Writer::String;
     $ENV{HTTPS_DEBUG} = 1;
     $ENV{HTTP_DEBUG} = 1;
     my $serverProcessId = 'LG04';
     my $menuId = 'SO103';
     my $variant = $main::variant_LG04;
     #$variant = 2 if ($main::verkoopsdagboek eq 'FF'); # dit werkt niet ?
     my $username = 'WEBSERV';
     my $client = 'VMOB';
     my $password = 'WEBSERV';
     my $Username = SOAP::Data->name('imp:Username' => $username)->type('');
     my $Password = SOAP::Data->name('imp:Password' => $password)->type('');
     my $Client  = SOAP::Data->name('imp:Client' => $client)->type('');
     my $ServerProcessId = SOAP::Data->name('imp:ServerProcessId' => $serverProcessId)->type('');
     my $MenuId = SOAP::Data->name('imp:MenuId' => $menuId)->type('');
     my $Variant = SOAP::Data->name('imp:Variant' => $variant)->type('');
     my $Xml = SOAP::Data->name('imp:Xml' =>$cdata)->type('xml');
     my $Input = SOAP::Data->name('imp:input')
            ->value(\SOAP::Data->value($ServerProcessId,$MenuId,$Variant,$Xml));
     my $Credentials = SOAP::Data->name('imp:credentials')
            ->value(\SOAP::Data->value($Username, $Client,$Password));
     my $ip = $main::agresso_instellingen->{"Agresso_IP_$main::mode"};
     my $antwoord ='';
     my $ordernr='fault';
     my $fault ='';
     my $soap = SOAP::Lite
      -> proxy("http://$ip/service.svc?ImportService/ImportV200606")    
      ->ns('http://services.agresso.com/ImportService/ImportV200606','imp')
      ->on_action( sub { return 'ExecuteServerProcessAsynchronously' } );
      #->on_fault( $antwoord = &mail_bericht_fout($output_file) );  # timout versie 20201126 ;
     $soap->transport->timeout(120) ;
     my $response;
     eval {$response = $soap->ExecuteServerProcessAsynchronously($Input,$Credentials); #timout ondevangen 20201126
     $ordernr = $response->{_content}[4]->{Body}->{ExecuteServerProcessAsynchronouslyResponse}
     ->{ExecuteServerProcessAsynchronouslyResult}->{OrderNumber};
     $fault = $response->{_content}[4]->{Body}->{Fault}->{faultstring};} or $fault = &mail_bericht_fout($output_file);
     if ($ordernr =~ m/\d+/) {
         $antwoord ="OK ordernr = $ordernr";#code
     }else {
         $antwoord ="ERROR !! -> $fault";
     }
     
     return ($antwoord);
     
     #print "$response\n";
}
sub timout_send_order_via_webserv_client { 
     my ($output_file) = @_;
     print "send_order_via_webserv_client $output_file\n";
     my $datestring = localtime();
     print "Local date and time $datestring\n";
     #my $cdata= read_file($output_file);
     print "";
}
sub maak_hospi_plus_Handmatige_tussenkomst {
      my ($class,$frame) = @_;
      my $naam_verzekering  = '';   
      for (my $i=0; $i < 4; $i++) {
         if ($main::contracts_check[$i] == 1) {
             $naam_verzekering = uc ($main::klant->{contracten}->[$i]->{naam});
            }
        }
      my $invoice_zoeknr;
      my $klant =$main::klant->{Agresso_nummer};
      my $vandaag = ParseDate("today");
      my $verkoopsdagboek = $main::verkoopsdagboek; #AF voor hospiplus plan FF voor forfait  MF voor maxiplan
      $vandaag  =~ s/://g;
      my $order_no = substr($vandaag,4,10);
      my $plaats_file =  $main::agresso_instellingen->{plaats_file};
      my $output_file = "$plaats_file\\HOSPI\.$klant\.AgressoOrder\.$vandaag\.xml";
      #my $output_file ="P:\\OGV\\ASSURCARD_PROG\\asurcard_xml\\HOSPI\.$klant\.AgressoOrder\.$vandaag\.xml";
      my $test= $main::teksten_gebruikte_rekenregels_per_nomenclatuur;
      #my $invoice =$main::invoice;
      #my @invoices = @main::invoices;
      #my @invoices_check = @main::invoices_check;
      my @overzicht_matrix = @main::overzicht_matrix;
      my $aantal_rij_overzicht_matrix = $main::aantal_rij_overzicht_matrix; ;
      #my $instelingen = $main::instelingen;
      #my @klanten_met_assurcard_facturen = @main::klanten_met_assurcard_facturen;
      #my $klanten_met_assurcard_facturen_teller = $main::klanten_met_assurcard_facturen_teller;
      my $begindatum_opname = $main::begindatum_opname;
      my $einddatum_opname =  $main::einddatum_opname;
      my $hospi_tussenkomst = $main::hospi_tussenkomst ;
      my $verschil= $main::verschil ; 
      $vandaag = substr ($vandaag,0,8);
      my $jaar = substr ($vandaag,0,4);
      my $maand =  substr ($vandaag,4,2);
      my $dag =  substr ($vandaag,6,2);
      my $OrderDate ="$jaar\-$maand\-$dag";
      my $Period = $jaar*100+$maand;
      &generate_Order($output_file,$order_no,$verkoopsdagboek,$Period,$OrderDate,$klant);
      my $LineNo1 = 0;
      my $hospi_totaal =0;
      for (my $i =0; $i <= $aantal_rij_overzicht_matrix; $i++){
         if (defined $main::overzicht_matrix[$i][1] and  $main::overzicht_matrix[$i][1] > 0  ) {
             if  ((defined $main::overzicht_matrix[$i][8]) and defined $main::overzicht_matrix[$i][8] > 0) {
                 $LineNo1 +=1;
                 my $Price= -$main::overzicht_matrix[$i][8];
                 $hospi_totaal -= $Price;
                 my $nomenclatuur =$main::overzicht_matrix[$i][1];
                 my $dagen =$main::overzicht_matrix[$i][2];
                 my $begindatum =$main::begindatum_opname;
                 my $einddatum =$main::einddatum_opname ;
                 my $dienst =$main::dienst;
                 my @tekst = ();
                 #my $test= $main::teksten_gebruikte_rekenregels_per_nomenclatuur;
                 eval {my $bestaat = @{$main::teksten_gebruikte_rekenregels_per_nomenclatuur->{$nomenclatuur}}};
                 if (!$@)  {
                     foreach my $nr (keys $main::teksten_gebruikte_rekenregels_per_nomenclatuur->{$nomenclatuur}) {
                         push (@tekst,$main::teksten_gebruikte_rekenregels_per_nomenclatuur->{$nomenclatuur}->[$nr]);
                        }
                    }
                 &generate_Detail($output_file,$LineNo1,'HOSPI',$Price,$nomenclatuur,$dagen,$begindatum,$einddatum,$dienst,$naam_verzekering,@tekst);
                }
            }             
             
        }
      
     $LineNo1 +=1;
     my @tekst1 = ();
     &generate_Detail($output_file,$LineNo1,'HOSPI',0,1,$main::aantal_dagen_betaald,$main::begindatum_opname,$main::einddatum_opname,'',$naam_verzekering,@tekst1);
     &close_Order ($output_file);
     my $rounded_hospi_tussenkomst = sprintf("%.2f", $main::hospi_tussenkomst);
     my $rounded_hospi_totaal = sprintf("%.2f", $hospi_totaal);
     if ($rounded_hospi_tussenkomst == $rounded_hospi_totaal) {
         my $antwoord = &send_order_via_webserv_client($output_file);
         return ($antwoord);
        }else {
         return ("Totalen zijn verschillend lijn 461 : $main::hospi_tussenkomst $hospi_totaal");
        }
       
    }
sub maak_maf_tussenkomst {
      my ($class,$klant,$naam_verzekering,$verkoopsdagboek,$nomenclatuur,$wat_we_moeten_betalen,$eerstejaar,$tweedejaar,$derdejaar) = @_;    
      my $vandaag = ParseDate("today");
      $vandaag  =~ s/://g;      
      my $order_no = substr($vandaag,4,10);
      my $plaats_file =  $main::agresso_instellingen->{plaats_file};
      my $output_file = "$plaats_file\\HOSPI\.$klant\.AgressoOrder\.$vandaag\.xml";
     # my $output_file ="P:\\OGV\\ASSURCARD_PROG\\asurcard_xml\\HOSPI\.$klant\.AgressoOrder\.$vandaag\.xml";
      $vandaag = substr ($vandaag,0,8);
      my $jaar = substr ($vandaag,0,4);
      my $maand =  substr ($vandaag,4,2);
      my $dag =  substr ($vandaag,6,2);
      my $OrderDate ="$jaar\-$maand\-$dag";
      my $Period = $jaar*100+$maand;
      &generate_Order($output_file,$order_no,$verkoopsdagboek,$Period,$OrderDate,$klant);
      my $LineNo1 = 0;
      my $hospi_totaal =0;
      my $totaal_dagen = 0;
      my $begindatum_derde ='';
      my $einddatum_eerste ='';
      foreach my $year (sort keys $wat_we_moeten_betalen) {
             $LineNo1 +=1;
             my $Price=-($wat_we_moeten_betalen->{$year});
             my $next_year = $year+1;
             my $dagen = Delta_Days($year,01,01,$next_year,01,01);
              #$dagen = 1;
             my $begindatum ="$year"."0101";
             my $einddatum ="$year"."1231" ;
             $begindatum_derde =$begindatum if ($LineNo1 ==1);
              $einddatum_eerste = $einddatum if ($LineNo1 == 1);
             #$begindatum ="20160102";
             #$einddatum ="20160103";
             $totaal_dagen += $dagen;
             $hospi_totaal +=$Price;
             my $dienst =0;
             my @tekst = ();
             &generate_Detail($output_file,$LineNo1,'HOSPI',$Price,$nomenclatuur,$dagen,$begindatum,$einddatum,$dienst,$naam_verzekering,@tekst);  
          }
      $LineNo1 +=1;
      my @tekst1 = ();
      &generate_Detail($output_file,$LineNo1,'HOSPI',0,1,$totaal_dagen,$begindatum_derde,$einddatum_eerste,'',$naam_verzekering,@tekst1);
      &close_Order ($output_file);
      if ($hospi_totaal != 0) {
           my $antwoord = &send_order_via_webserv_client($output_file);
           return ($antwoord);
          }else {
           return ('Nul factuur');
          }
     }
sub mail_bericht_fout {
     my @output_file = @_;
     #print "mail-start\n";
     #my $aan = $agresso_instellingen->{mail_verslag_naar};
     #my @aan_lijst = split (/\,/,$aan);
     my @aan_lijst= ('harry.conings@vnz.be','JeroenCoenaerts@hospiplus.be');
     my $van = 'harry.conings@vnz.be';
     my $vandaag = ParseDate("today");
     #$vandaag = substr ($vandaag,0,8);  # vandaag in YYYYMMDD
     #$vandaag = sprintf "%04d-%02d-%02d",substr ($vandaag,0,4),substr ($vandaag,4,2),substr ($vandaag,6,2);
     #foreach my $geadresseerde (@aan_lijst) {
     #    my $smtp = Net::SMTP->new('10.63.120.3',
     #               Hello => 'mail.vnz.be',
     #               Timeout => 60);
     #    $smtp->auth('mailprogrammas','pleintje203');
     #    $smtp->mail($van);
     #    $smtp->to($geadresseerde);
     #    $smtp->cc('informatica.mail@vnz.be');
     #    #$smtp->bcc("bar@blah.net");
     #    $smtp->data;
     #    $smtp->datasend("From: harry.conings");
     #    $smtp->datasend("\n");
     #    $smtp->datasend("To: Kaartbeheerders");
     #    $smtp->datasend("\n");
     #    $smtp->datasend("Subject: Agresso timout $vandaag");
     #    $smtp->datasend("\n");
     #    $smtp->datasend("Een fout kwam voor op @output_file\ntijd $vandaag\nvriendelijke groeten\nHarry Conings");
     #    $smtp->dataend;
     #    $smtp->quit;
     #    print "mail aan $geadresseerde  gezonden\n";
     #    return ('Timeout fout mail_bericht_fout');
     #   }
     print "mail uitgeschakeld";
    }
1;