#!/usr/bin/perl -w
#OPGELET!!!!!!
#Dit programma is auteursrechtelijk beschermd.
#Deze code is voor 50% eigendom van Hospiplus en voor 50% eigendom van de Firma  I.C.E. (liebroekstraat 43 3545 Halen BE0446888007) .
#Deze code mag niet aan derden (ook niet VNZ en NZVL) getoond worden tenzij met uitdrukkelijke en schriftelijke toestemming van Hospiplus en I.C.E. bvba .
#Indien dit toch gebeurt is er een boete verschuldigd van 250.000 € exclusief btw aan de Firma  I.C.E.
#Dit geldt ook voor het kopieren van een stuk code of het repliceren van technieken gehanteerd in dit programma
#I.C.E. beheert de broncode je mag  veranderingen aanbrengen aan het programma . Deze worden samen met de documentatie overgedragen aan I.C.E. .
#I.C.E. beslist dan op deze veranderingen worden doorgevoerd.

#Door het openen van deze broncode stem je in met de voorgaande voorwaarden.

#De gerechtigden om deze broncode te bekijken zijn Christian Bruyninckx , Michel Gielens en Ben Van Massenhoven.
#Harry Conings beheert voor I.C.E de broncode
use strict;
use strict;
use Data::Dumper;
use XML::Compile::Schema;
use XML::Compile::Cache;
use XML::LibXML::Reader;     
use XML::Simple;
use Date::Manip::DM5 ;
use Date::Calc qw(:all);
use File::Copy;
use Win32::FileOp;
use Net::SMTP;
use DBI;
our $mail_feedback='';
our $assurcard_instellingen ;
our $feedback;
our $feedback1;
our $vandaag = ParseDate("today");
our $dbh_mssql;
our @invoice_processed;
my $vandaag_tijd = $vandaag;
$vandaag_tijd =~ s/://g;
$vandaag_tijd =~ s/\s//g;
our $tijd = substr ($vandaag_tijd,8,6);
$vandaag = substr ($vandaag,0,8);
our $mode = 'TEST';
$mode = $ARGV[0] if (defined $ARGV[0]);
if ( $mode eq 'TEST' or $mode eq 'PROD'){}else{die}
&load_assurcard_setting_feedback('D:\OGV\ASSURCARD_2023\assurcard_settings_xml\assurcard_card_generation_settings.xml');
#&ask_approved_via_webserv_client_feedback;
$mail_feedback = $mail_feedback."\nWE STUREN TERUG AAN ASSURCARD WELKE FACTUREN WE GOEDGKEURD HEBBEN EN GAAN BETALEN\n";
$mail_feedback = $mail_feedback."----------------------------------------------------------------------\n";
print "\nWE STUREN TERUG AAN ASSURCARD WELKE WE GOEDGKEURD HEBBEN EN GAAN BETALEN\n";
print "----------------------------------------------------------------------\n";
&ask_feedback_via_webserv_client_feedback;
&zet_approved_to_yes_agresso ;
&mail_bericht_feedback;
sub ask_feedback_via_webserv_client_feedback {
     my $directory = $assurcard_instellingen->{plaats_file};
     my $insurer_id = $assurcard_instellingen->{nr_verzekeraar};
     my $agresso_proxy = $main::assurcard_instellingen->{"Agresso_IP_$main::mode"};
     my $xml_file = "$directory\\PaymentFeedback.$insurer_id.$vandaag.$tijd.xml";
     use SOAP::Lite ;
     #'+trace => [ transport => sub { print $_[0]->as_string } ];    
     my $proxy = "http://$agresso_proxy/service.svc?QueryEngineService/QueryEngineV201101"; #productie
     my $uri   = 'http://services.agresso.com/QueryEngineService/QueryEngineV201101';
     my $soap = SOAP::Lite
        ->proxy($proxy)
        ->ns($uri,'query')
        ->on_action( sub { return 'GetTemplateResultAsDataSet' } );
     #my $template    = SOAP::Data->name('query:TemplateId' => "4250")->type('');
     my $template    = SOAP::Data->name('query:TemplateId' => "4447")->type('');
     my $pipeline    = SOAP::Data->name('query:PipelineAssociatedName' => "false")->type('');
     my $input       = SOAP::Data->name('query:input') ->value(\SOAP::Data->value($template, $pipeline));
     my $Username    = SOAP::Data->name('query:Username' => 'WEBSERV')->type('');
     my $Client      = SOAP::Data->name('query:Client'   => 'VMOB')->type('');
     my $Password    = SOAP::Data->name('query:Password' => 'WEBSERV')->type('');
     my $credentials = SOAP::Data->name('query:credentials') ->value(\SOAP::Data->value($Username, $Client, $Password));
     my $response = $soap->mySOAPFunction($input,$credentials);
     my $invoice_nr ='';
     my $teller =0;
     my $rijksreg_nr = '0';
     my $assurcard_id = '';
     my $invoicefeedbak_onderdeel;
     my @invoice_feedback =();
     my $PamentDate ='';
     my $PaymentAmount = 0;
     my $FinancialAccount ='';
     my $PaymentReference ="";
     my $kaart_nummer_prefix = $assurcard_instellingen->{kaart_nummer_prefix};
     $mail_feedback = $mail_feedback."NR\tFACTUUR\tKAART\n";
     print "NR\tFACTUUR\tKAART\n";
     @invoice_processed =();
     eval {my $test= $response->{_content}[2][0][2][0][4]->{GetTemplateResultAsDataSetResult}->{TemplateResult}->{diffgram}->{Agresso}->{AgressoQE}};
     if ($@) {
         print "geen goedgekeurde facturen\n";#code
         $mail_feedback = $mail_feedback."geen goedgekeurde facturen\n";
         &mail_bericht_feedback;
         die;
     }
     
     foreach my $invoice (keys $response->{_content}[2][0][2][0][4]->{GetTemplateResultAsDataSetResult}->{TemplateResult}->{diffgram}->{Agresso}->{AgressoQE}) {
         $invoice_nr = $response->{_content}[2][0][2][0][4]->{GetTemplateResultAsDataSetResult}->{TemplateResult}
                       ->{diffgram}->{Agresso}->{AgressoQE}[$invoice]->{ext_inv_ref};
         $invoice_nr =~ s%/.*$%%g;              
         $rijksreg_nr = $response->{_content}[2][0][2][0][4]->{GetTemplateResultAsDataSetResult}->{TemplateResult}
                       ->{diffgram}->{Agresso}->{AgressoQE}[$invoice]->{dim_3};
         $assurcard_id = "$kaart_nummer_prefix"."$rijksreg_nr";
         $assurcard_id =~ s/\s//g;
         $PamentDate = $response->{_content}[2][0][2][0][4]->{GetTemplateResultAsDataSetResult}->{TemplateResult}
                       ->{diffgram}->{Agresso}->{AgressoQE}[$invoice]->{due_date};
         $PaymentAmount = $response->{_content}[2][0][2][0][4]->{GetTemplateResultAsDataSetResult}->{TemplateResult}
                       ->{diffgram}->{Agresso}->{AgressoQE}[$invoice]->{cur_amount};
         $PaymentAmount = abs($PaymentAmount);              
         $FinancialAccount  = $response->{_content}[2][0][2][0][4]->{GetTemplateResultAsDataSetResult}->{TemplateResult}
                       ->{diffgram}->{Agresso}->{AgressoQE}[$invoice]->{iban};             
         $PaymentReference = $response->{_content}[2][0][2][0][4]->{GetTemplateResultAsDataSetResult}->{TemplateResult}
                       ->{diffgram}->{Agresso}->{AgressoQE}[$invoice]->{kid};
         $PamentDate = substr($PamentDate,0,10);            
         if ($invoice_nr ~~ @invoice_processed) {
             print "$invoice_nr bestaat al\n";#code
         }else {
             if ($assurcard_id != 8 ) {
                 push (@invoice_processed,$invoice_nr);
                 $invoicefeedbak_onderdeel = {
                     InvoiceStatus => "FULLY_ACCEPTED",
                     Justification => '',
                     InvoiceId => $invoice_nr,
                     CardId =>$assurcard_id,
                     PaymentDate => $PamentDate,
                     PaymentAmount =>$PaymentAmount,
                     FinancialAccount => $FinancialAccount,
                     PaymentReference => $PaymentReference,
                     ErrorCode => 0,
                    };
                 $teller +=1;
                 $mail_feedback = $mail_feedback."$teller\t$invoice_nr\t$assurcard_id\n";               
                 print "$teller\t$invoice_nr\t$assurcard_id\n";
                 push (@invoice_feedback,$invoicefeedbak_onderdeel);
                }else {
                 print "$teller\t->$invoice_nr ->$assurcard_id -> is acht!!!!!\n";
                }
             #last if ($teller==3);
         }
         
        
         
        
         
     }
     my $InsurerIdentifier =$assurcard_instellingen->{nr_verzekeraar};
     $feedback = {InvoiceFeedback =>[@invoice_feedback],
                           InsurerIdentifier => "$InsurerIdentifier"
                           };
    
     
     my $xsd = 'D:\OGV\ASSURCARD_2023\asurcard_xsd\invoiceFeedbacks-har.xsd';
     my $schema = XML::Compile::Schema->new($xsd);
     $schema->printIndex();
     warn $schema->template('PERL', 'InvoiceFeedbacks');
     my $doc    = XML::LibXML::Document->new('1.0', 'UTF-8');
     my $write  = $schema->compile(WRITER => 'InvoiceFeedbacks');
     my $xml    = $write->($doc, $feedback);      
     $doc->setDocumentElement($xml);
     open XMLFILE,"> $xml_file" or die &error_xml_feedback($xml_file);
     select XMLFILE;
     print $doc->toString(1); # 1 indicates "pretty print"
     close XMLFILE;
     select STDOUT;
     undef $feedback;
     $mail_feedback = $mail_feedback."\n$xml_file is aangemaakt\n";
     &copy_file_to_assurcard_upload_Paymentfeedback($xml_file);
    }
sub error_xml_feedback {
     my $xml_file = shift @_;
     $mail_feedback = $mail_feedback."\nERROR !! $xml_file kan niet geopend worden\n ";
     print "\nERROR !! $xml_file kan niet geopend worden\n ";
     &mail_bericht_feedback;
     die;
}
sub mail_bericht_feedback {
     print "mail-start\n";
     my $aan = $assurcard_instellingen->{mail_verslag_naar};
     my @aan_lijst = split (/\,/,$aan);
     my $van = 'harry.conings@vnz.be';
     my $vandaag = ParseDate("today");
     $vandaag = substr ($vandaag,0,8);  # vandaag in YYYYMMDD
     $vandaag = sprintf "%04d-%02d-%02d",substr ($vandaag,0,4),substr ($vandaag,4,2),substr ($vandaag,6,2);
     foreach my $geadresseerde (@aan_lijst) {
         my $smtp = Net::SMTP->new('mailservices.m-team.be',
                    Hello => 'mail.vnz.be',
                    Timeout => 60);
         #$smtp->auth('mailprogrammas','pleintje203');
         $smtp->mail($van);
         $smtp->to($geadresseerde);
         #$smtp->cc('informatica.mail@vnz.be');
         #$smtp->bcc("bar@blah.net");
         $smtp->data;
         $smtp->datasend("From: harry.conings");
         $smtp->datasend("\n");
         $smtp->datasend("To: Kaartbeheerders");
         $smtp->datasend("\n");
         $smtp->datasend("Subject: Invoice Payment Feedback xml generatie verslag $vandaag");
         $smtp->datasend("\n");
         $smtp->datasend("$mail_feedback\nvriendelijke groeten\nHarry Conings");
         $smtp->dataend;
         $smtp->quit;
         print "mail aan $geadresseerde  gezonden\n";
        }
    }
sub load_assurcard_setting_feedback  {
     my $file_name = shift @_;
     $assurcard_instellingen = XMLin("$file_name");
     print "ingelezen\n";
     #maak verzekeringen
    
    }
sub zet_approved_to_yes_agresso {
     $dbh_mssql = &setup_mssql_connectie;
     my $teller = 0;
     foreach my $invoice_nr (@invoice_processed) {
         print "->$invoice_nr<-\n";
         print "voor update\n";
         print "select ext_inv_ref,voucher_no,feedback,approved FROM zgt_log_assurcard WHERE ext_inv_ref like \'$invoice_nr%\'\n";
         my $sqlms = ("select ext_inv_ref,voucher_no,feedback,approved FROM zgt_log_assurcard WHERE ext_inv_ref like '$invoice_nr%'");
         my $sthms = $dbh_mssql->prepare( $sqlms );
         $sthms->execute();
         my $teller1 = 0;
         while(my @test =$sthms->fetchrow_array) {
             print "$teller1 ->$test[0]->$test[1]->$test[2]\n";
              $teller1 +=1;
            }
         print "UPDATE zgt_log_assurcard set approved = 'YES' WHERE ext_inv_ref like \'$invoice_nr%\'\n";
         my $updatethis = $dbh_mssql ->do("UPDATE zgt_log_assurcard set approved = 'YES' WHERE ext_inv_ref like '$invoice_nr%'");
         $teller += 1;
         print "na update\n";
         print "select ext_inv_ref,voucher_no,feedback,approved FROM zgt_log_assurcard WHERE ext_inv_ref like \'$invoice_nr%\'\n";
         $sqlms = ("select ext_inv_ref,voucher_no,feedback,approved FROM zgt_log_assurcard WHERE ext_inv_ref like '$invoice_nr%'");
         $sthms = $dbh_mssql->prepare( $sqlms );
         $sthms->execute();
         $teller1 = 0;
        
         while(my @test =$sthms->fetchrow_array) {
             print "$teller1 ->$test[0]->$test[1]->$test[2]->$test[3]\n";
              $teller1 +=1;
            }
         #$teller += 1;
         print "";
        }
     $mail_feedback = $mail_feedback."$teller facturen op feedwack yes in Agresso gezet\n";
    }
sub setup_mssql_connectie {         
          my $database;
          $database = $assurcard_instellingen->{"Agresso_Database_$mode"};          
          my $ip = $assurcard_instellingen->{"Agresso_SQL_$mode"};
          my $dbh_mssql;
          my $dsn_mssql = join "", (
              "dbi:ODBC:",
              "Driver={SQL Server};",
              #"Server=S998XXLSQL01.CPC998.BE\\i200;",
              "Server=$ip;", # nieuwe database server 2016 05 S000WP1XXLSQL01.mutworld.be\i200
              "UID=HOSPIPLUS;",
              "PWD=ihuho4sdxn;",
              "Database=$database",
              #"Database=agraccept",
             );
      my $user = 'HOSPIPLUS';
      my $passwd = 'ihuho4sdxn';
     
      my $db_options = {
         PrintError => 1,
         RaiseError => 1,
         AutoCommit => 1, #0=Use transactions werkt niet
         LongReadLen =>2000,

        };
     #
     # connect to database
     #
     $dbh_mssql = DBI->connect($dsn_mssql, $user, $passwd, $db_options) or exit_msg("Can't connect: $DBI::errstr");
     print "";
     return($dbh_mssql)
    }

sub disconnect_mssql {
     my $dbh_mssql = shift @_;
     $dbh_mssql->disconnect;
}
sub copy_file_to_assurcard_upload_Paymentfeedback  {
     my $file = shift @_;
     my $smbuser = 'assurcard';
     my $smbpasswd = 'Hospiplus';
     my $cifs= $assurcard_instellingen->{plaats_assurcard_upload};
     my $cifs_readable =$cifs;
     $cifs_readable =~ s/\\/\\\\/g;
     Connect $cifs,{user=>$smbuser,passwd=>$smbpasswd} ;
     if (-e "$cifs\\test.txt") {
         my $test_copy=0;
         copy ("$file"  => $cifs) or $test_copy=&error_mail_copy ("$file" ,$cifs);
         if ($test_copy==0) {
             $mail_feedback=$mail_feedback."file $file gekopieerd naar $cifs_readable\n" ;
             print "file $file gekopieerd naar $cifs_readable\n" ;
            }else {
             $mail_feedback=$mail_feedback."ERROR !! =>file $file kon niet gekopieerd worden naar $cifs_readable\n" ;
             print "ERROR !! =>file $file kon niet gekopieerd worden naar $cifs_readable\n" ;
            }
        }else {
         print "map niet gemaakt";
         my $cifs_leesbaar = $cifs;
         $cifs_leesbaar =~ s/\\/\\\\/g;
         $mail_feedback = $mail_feedback."\nKAN NETWERK MAP NIET MAKEN $cifs_leesbaar !!!!!\n--------------------------------------------\n";
         print "\nKAN NETWERK MAP NIET MAKEN $cifs_leesbaar !!!!!\n--------------------------------------------\n";
         $mail_feedback = $mail_feedback."of bestand test.txt staat niet op $cifs_leesbaar \n maak het aan\n";
         print "of bestand test.txt staat niet op $cifs_leesbaar \n maak het aan\n";
        }
    }
sub error_mail_copy_invoices {
     my $lijstfile = shift @_;
     my $copy_plaats = shift @_;
     #$mail_contract = $mail_contract."kon file $lijstfile niet kopieren naar $copy_plaats\n";
     return (1);
    }


