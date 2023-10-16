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
#versie 2.1  rare tekens
#versie 2.0 opdelen in stukken voor grote files
#versie variant 14 workflow interface RF <Interface>RF</Interface> VoucherType>RZ</agrlib:VoucherType>
#$FlagGPS ==1 and $LVZBaseValue > 0 20190708
use strict;
use Data::Dumper;
use XML::Compile::Schema;
use XML::Compile::Cache;
use XML::LibXML::Reader;     
use XML::Simple;
use Date::Manip::DM5 ;
use Date::Calc qw(:all);
use Scalar::Util qw(blessed dualvar isdual readonly refaddr reftype
tainted weaken isweak isvstring looks_like_number
set_prototype);
use Net::SMTP;
use File::Slurp;
use File::Copy;
use Win32::FileOp;
use File::Find;
use Win32::File;
use IO::Uncompress::Unzip qw(unzip $UnzipError) ;
use Data::Dumper;
our $ABWTransaction;
our $assurcard ;
our $agresso_instellingen;
our $vandaag = ParseDate("today");
my $vandaag_tijd = $vandaag;
$vandaag_tijd =~ s/://g;
$vandaag_tijd =~ s/\s//g;
our $tijd = substr ($vandaag_tijd,8,6);
our @Voucher= ();
our $Voucher_onderdeel;
our @Transaction;
our $transactie_onderdeel;
our $cdata;
our $mail = '';
our $factuur_teller=0;
our $HospitalisationStart ='';
our $HospitalisationEnd ='';
our $RoomTypeCode_alg =0;
our $xml_file_teller = 1;
our $laatste_xml = 1;
our @al_verwerkte_invoices ;
our $mode = 'TEST';
$mode = $ARGV[0] if (defined $ARGV[0]);
if ( $mode eq 'TEST' or $mode eq 'PROD'){}else{die}
require "agresso_leveranciers_iban_conversie.pl";
$vandaag = substr ($vandaag,0,8);  # vandaag in YYYYMMDD
my $yyyy =substr($vandaag,0,4);
my $mm =substr($vandaag,4,2);
my $dd = substr($vandaag,6,2);
our $vandaag_streepje = "$yyyy-$mm-$dd";
&load_agresso_setting_invoice('D:\OGV\ASSURCARD_2023\assurcard_settings_xml\agresso_settings.xml');
@al_verwerkte_invoices= &alverwerkte_invoices;
my ($year, $mon, $day) = Add_Delta_Days($yyyy, $mm, $dd, $agresso_instellingen->{invoice_payment_delay});
$year = sprintf ('%04s',$year);
$mon = sprintf ('%02s',$mon);
$day = sprintf ('%02s',$day);
our $Due_Date = "$year-$mon-$day";
$mail = $mail."IMPORT ASSURCARD FACTUREN NAAR AGRESSO OP $vandaag\n";
$mail = $mail."----------------------------------------------------\n\n";
print "IMPORT ASSURCARD FACTUREN NAAR AGRESSO OP $vandaag\n";
print "----------------------------------------------------\n\n";
&connect_to_assurcard_invoices;
&verwerk_xml_invoices;
#&modulo_97_invoice ('+++130/00a0/06609+++');

#&read_assurcard_invoice('D:\assurcard\invoices\017.invoice.out.20140213.120926.xml\017.invoice.out.20140213.120926.xml');
#&read_assurcard_invoice('D:\assurcard\invoices\067.invoice.out.20140213.114623.xml\067.invoice.out.20140213.114623.xml');
#&read_assurcard_invoice('D:\OGV\ASSURCARD_PROG\assurcard_invoices\714.invoice.out.20210624.003407.xml');
&mail_bericht_invoice;
sub read_assurcard_invoice {
     my $file = shift @_;
     #$assurcard = XMLin('D:\assurcard\invoices\067.invoice.out.20140213.114623.xml\067.invoice.out.20140213.114623.xml');
     #$assurcard = XMLin('D:\assurcard\invoices\110.invoice.out.20140213.114356.xml\test-inv-agr.xml');
     $file =~ m%[a-zA-Z0-9\.-]*\.xml$%;
     my $batch = $&;
     $assurcard = XMLin($file);
     my $batch_id = &maak_batch_id_invoice("$batch");
     my $batch_id_teller = $batch_id."\.$xml_file_teller";
     #my $batch_id = &maak_batch_id_invoice("067.invoice.out.20140213.114623.xml");
     &maak_header_invoice ($batch_id_teller);
     eval {foreach my $volgnr_invoice (keys @{$assurcard->{Invoice}}) { }} ;
     if ($@) {
         #is geen array reference;#code
         undef $Voucher_onderdeel;
         undef @Voucher;
         undef @Transaction;
         undef $transactie_onderdeel;
         &maak_voucher_invoice('geen');
         #$ABWTransaction->{Voucher}=$Voucher_onderdeel;
         #push (@{$ABWTransaction->{Voucher}->{Transaction}},@Transaction);
     }else {
         #is wel een array
         my $invoice_teller = 0;
         my $max_aantal_invoices_naar_webservice = $agresso_instellingen->{blok_grootte_invoices};
         foreach my $volgnr_invoice (sort keys @{$assurcard->{Invoice}}) {
             undef $Voucher_onderdeel;
             undef @Voucher;
             undef @Transaction;
             undef $transactie_onderdeel;
             &maak_voucher_invoice($volgnr_invoice);
             $invoice_teller += 1;
             if ($invoice_teller == $max_aantal_invoices_naar_webservice) {
                 $laatste_xml =0;
                 &maak_xml_invoice;
                 undef $ABWTransaction;
                 @Voucher= ();
                 undef $Voucher_onderdeel;
                 undef $transactie_onderdeel;
                 undef @Transaction;
                 &verander_xml_file_invoice;
                 &send_via_webserv_client_invoice($file);
                 $cdata='';
                 print "";
                 $laatste_xml =1;
                 $invoice_teller = 0;
                 $xml_file_teller += 1;
                 $batch_id_teller = $batch_id."\.$xml_file_teller";
                 $mail = $mail."\n We nemen de volgende batch van $max_aantal_invoices_naar_webservice om naar agresso te sturen\n ";
                 print "\n We nemen de volgende batch van $max_aantal_invoices_naar_webservice om naar agresso te sturen\n ";
                 &maak_header_invoice ($batch_id_teller);
                 
             }
             
         }
     }
     &maak_xml_invoice;
     undef $ABWTransaction;
     undef $assurcard;
     @Voucher= ();
     undef $Voucher_onderdeel;
     undef $transactie_onderdeel;
     undef @Transaction;
     &verander_xml_file_invoice;
     &send_via_webserv_client_invoice($file);
     $xml_file_teller =1;
     print ""; 
    }
sub maak_header_invoice {
     my $BatchId = shift @_;
     my $ReportClient = $agresso_instellingen->{CompanyCode};
     my $Interface = $agresso_instellingen->{assurcard_invoice_import_interface};
     $ABWTransaction = {
         Interface => "$Interface",
         BatchId => "$BatchId",
         ReportClient => "$ReportClient"};
    
}
sub maak_voucher_invoice {
     my $volgnr_invoice =shift @_;
     my $VoucherNo=1;
     my $VoucherType = $agresso_instellingen->{agresso_voucher_type};
     my $CompanyCode = $agresso_instellingen->{CompanyCode};
     my $VoucherDate= $vandaag_streepje;
     my $Period ='';
     $HospitalisationStart ='';
     $HospitalisationEnd ='';
     if ($volgnr_invoice eq 'geen'){
         #$Period= $assurcard->{Invoice}->{InvoicingPeriod};
         $Period= substr($vandaag,0,6);
         $HospitalisationStart = $assurcard->{Invoice}->{HospitalisationStart};
         $HospitalisationEnd = $assurcard->{Invoice}->{HospitalisationEnd};
         $HospitalisationStart =~ s/-//g;
         $HospitalisationEnd =~ s/-//g;
         eval {foreach my $volgnr_invoice (keys @{$assurcard->{Invoice}->{Line}}) { }} ;
         #eerste transactie maken
         if ($@) {
             #is geen array reference;#code
             my $volgnr_Line = 'geen';
             &maak_eerste_transactie_voucher_invoice($volgnr_invoice,$volgnr_Line);
            }else {
             #is wel een array
             foreach my $volgnr_Line (sort keys @{$assurcard->{Invoice}->{Line}}) {
                 print "nog niet geimplementeerd volgnr_Line:$volgnr_Line \n" ;
                 &maak_eerste_transactie_voucher_invoice($volgnr_invoice,$volgnr_Line);
                }
            }
         #volgende transacties maken
         eval {foreach my $volgnr_invoice (keys @{$assurcard->{Invoice}->{Groups}}) { }} ;
         if ($@) {
             #is geen array
             my $volgnr_Groups = 'geen';
             &maak_volgende_transactie_invoice($volgnr_invoice,$volgnr_Groups);
            }else {
             print "\n!!!!\n !!!!!!er bestaan volgnrs Groups !!!!!!\n !!!!!\n";
            }
     }else {
         $VoucherNo = $volgnr_invoice + 1; # we gaan nummering nemen van de $assurcard{Invoice}[deze nr] doen we achteraf +1
         #$Period= $assurcard->{Invoice}[$volgnr_invoice]->{InvoicingPeriod};
         $Period= substr($vandaag,0,6);
         $HospitalisationStart = $assurcard->{Invoice}[$volgnr_invoice]->{HospitalisationStart};
         $HospitalisationEnd = $assurcard->{Invoice}[$volgnr_invoice]->{HospitalisationEnd};
         $HospitalisationStart =~ s/-//g;
         $HospitalisationEnd =~ s/-//g;
         eval {foreach my $volgnr_invoice (keys @{$assurcard->{Invoice}[$volgnr_invoice]->{Line}}) { }} ;
         #eerste transactie maken
         if ($@) {
             #is geen array reference;#code
             my $volgnr_Line = 'geen';
             &maak_eerste_transactie_voucher_invoice($volgnr_invoice,$volgnr_Line);
            }else {
             #is wel een array
             foreach my $volgnr_Line (sort keys @{$assurcard->{Invoice}[$volgnr_invoice]->{Line}}) {
                 print "nog niet geimplementeerd volgnr_Line:$volgnr_Line \n" ;
                 &maak_eerste_transactie_voucher_invoice($volgnr_invoice,$volgnr_Line);
                }
            }
          #volgende transacties maken
         eval {foreach my $volgnr_invoice (keys @{$assurcard->{Invoice}[$volgnr_invoice]->{Groups}}) { }} ;
         if ($@) {
             #is geen array
             my $volgnr_Groups = 'geen';
             &maak_volgende_transactie_invoice($volgnr_invoice,$volgnr_Groups);
            }else {
             print "\n!!!!\n !!!!!!er bestaan volgnrs Groups !!!!!!\n !!!!!\n";
            }
     }
     $Voucher_onderdeel = {
         VoucherNo => $VoucherNo,
         VoucherType => "$VoucherType",
         CompanyCode => "$CompanyCode",
         Period => "$Period",
         VoucherDate => "$VoucherDate",
        };
     push (@{$Voucher_onderdeel->{Transaction}},@Transaction);
     push (@Voucher,$Voucher_onderdeel);  
     push (@{$ABWTransaction->{Voucher}},@Voucher);
}
sub maak_eerste_transactie_voucher_invoice {
     my $volgnr_invoice = shift @_;
     my $lijn_nr = shift @_;
     my $TransType = "AP";
     my $Status = "N"; #leeg voor de moment
     my $TransDate= $vandaag_streepje;  # vandaag in YYYYMMDD "$vandaag"
     my $Description = '';
     my $OAPartRekA = '';
     my $OAPartRekB = '';
     my $PatientPart = '';
     my $Overcharges = '';
     my $ApArInfoInvoiceNo = '';
     my $ApArInfoInvoiceNo_1= '';
     my $ApArInfoApArNo = '';
     my $SundryInfoBankAccount= '';
     my $SundryInfoSwift= '';
     my $BankAccount ='';
     my $Swift='';
     my $ApArInfoBacsId = '';
     if ($volgnr_invoice eq 'geen' and $lijn_nr eq 'geen') {
         $Description = $assurcard->{Invoice}->{InvoiceType}->{DisplayValue};
         $OAPartRekA = $assurcard->{Invoice}->{Line}->{Col}[1]->{content};
         $OAPartRekB = $assurcard->{Invoice}->{Line}->{Col}[2]->{content};
         $PatientPart = $assurcard->{Invoice}->{Line}->{Col}[4]->{content};
         $Overcharges = $assurcard->{Invoice}->{Line}->{Col}[3]->{content};
         $ApArInfoInvoiceNo = $assurcard->{Invoice}->{Id}; #overgang naar ivoice-id
         $ApArInfoInvoiceNo_1 = $assurcard->{Invoice}->{InvoiceNumber};
         $ApArInfoInvoiceNo = "$ApArInfoInvoiceNo/$ApArInfoInvoiceNo_1";
         $ApArInfoApArNo = $assurcard->{Invoice}->{MutualNumber};
         $SundryInfoBankAccount= $assurcard->{Invoice}->{FinancialAccount};
         $ApArInfoBacsId = $assurcard->{Invoice}->{StructuredMessage};
         $ApArInfoBacsId = &modulo_97_invoice ($ApArInfoBacsId);
     }elsif ($volgnr_invoice ne 'geen' and $lijn_nr eq 'geen') {
         $Description = $assurcard->{Invoice}[$volgnr_invoice]->{InvoiceType}->{DisplayValue};
         $OAPartRekA = $assurcard->{Invoice}[$volgnr_invoice]->{Line}->{Col}[1]->{content};
         $OAPartRekB = $assurcard->{Invoice}[$volgnr_invoice]->{Line}->{Col}[2]->{content};
         $PatientPart = $assurcard->{Invoice}[$volgnr_invoice]->{Line}->{Col}[4]->{content};
         $Overcharges = $assurcard->{Invoice}[$volgnr_invoice]->{Line}->{Col}[3]->{content};
         $ApArInfoInvoiceNo = $assurcard->{Invoice}[$volgnr_invoice]->{Id};
         $ApArInfoInvoiceNo_1 = $assurcard->{Invoice}[$volgnr_invoice]->{InvoiceNumber};
         $ApArInfoInvoiceNo = "$ApArInfoInvoiceNo/$ApArInfoInvoiceNo_1";
         $ApArInfoApArNo = $assurcard->{Invoice}[$volgnr_invoice]->{MutualNumber};
         $SundryInfoBankAccount= $assurcard->{Invoice}[$volgnr_invoice]->{FinancialAccount};
         $ApArInfoBacsId = $assurcard->{Invoice}[$volgnr_invoice]->{StructuredMessage};
         $ApArInfoBacsId = &modulo_97_invoice ($ApArInfoBacsId);
         
     }elsif ($volgnr_invoice eq 'geen' and $lijn_nr ne 'geen'){
         $Description = $assurcard->{Invoice}->{InvoiceType}->{DisplayValue};
         $OAPartRekA = $assurcard->{Invoice}->{Line}[$lijn_nr]->{Col}[1]->{content};
         $OAPartRekB = $assurcard->{Invoice}->{Line}[$lijn_nr]->{Col}[2]->{content};
         $PatientPart = $assurcard->{Invoice}->{Line}[$lijn_nr]->{Col}[4]->{content};
         $Overcharges = $assurcard->{Invoice}->{Line}[$lijn_nr]->{Col}[3]->{content};
         $ApArInfoInvoiceNo = $assurcard->{Invoice}->{Id};
         $ApArInfoInvoiceNo_1 = $assurcard->{Invoice}->{InvoiceNumber};
         $ApArInfoInvoiceNo = "$ApArInfoInvoiceNo/$ApArInfoInvoiceNo_1";
         $ApArInfoApArNo = $assurcard->{Invoice}->{MutualNumber};
         $SundryInfoBankAccount= $assurcard->{Invoice}->{FinancialAccount};
         $ApArInfoBacsId = $assurcard->{Invoice}->{StructuredMessage};
         $ApArInfoBacsId = &modulo_97_invoice ($ApArInfoBacsId);
     }elsif ($volgnr_invoice ne 'geen' and $lijn_nr ne 'geen') {
         $Description = $assurcard->{Invoice}[$volgnr_invoice]->{InvoiceType}->{DisplayValue};
         $OAPartRekA = $assurcard->{Invoice}[$volgnr_invoice]->{Line}[$lijn_nr]->{Col}[1]->{content};
         $OAPartRekB = $assurcard->{Invoice}[$volgnr_invoice]->{Line}[$lijn_nr]->{Col}[2]->{content};
         $PatientPart = $assurcard->{Invoice}[$volgnr_invoice]->{Line}[$lijn_nr]->{Col}[4]->{content};
         $Overcharges = $assurcard->{Invoice}[$volgnr_invoice]->{Line}[$lijn_nr]->{Col}[3]->{content};
         $ApArInfoInvoiceNo = $assurcard->{Invoice}[$volgnr_invoice]->{Id};
         $ApArInfoInvoiceNo_1 = $assurcard->{Invoice}[$volgnr_invoice]->{InvoiceNumber};
         $ApArInfoInvoiceNo = "$ApArInfoInvoiceNo/$ApArInfoInvoiceNo_1";
         $ApArInfoApArNo = $assurcard->{Invoice}[$volgnr_invoice]->{MutualNumber};
         $SundryInfoBankAccount= $assurcard->{Invoice}[$volgnr_invoice]->{FinancialAccount};
         $ApArInfoBacsId = $assurcard->{Invoice}[$volgnr_invoice]->{StructuredMessage};
         $ApArInfoBacsId = &modulo_97_invoice ($ApArInfoBacsId);
        }
     my $totaal = $OAPartRekA+$OAPartRekB +$PatientPart+$Overcharges;
     my $PatientPartOvercharges =$PatientPart+$Overcharges;
     my $AmountsDcFlag = -1;
     my $AmountsAmount = -$totaal;
     my $AmountsCurrAmount= -$totaal;
     my $GLAnalysisAccount = $agresso_instellingen->{AP_Account};
     my $GLAnalysisDim5 = "";
     my $GLAnalysisDim6 ="";
     my $GLAnalysisCurrency = $agresso_instellingen->{Currency};
     my $GLAnalysisTaxCode = $agresso_instellingen->{TaxCode};
     my $GLAnalysisTaxSystem ="";
     my $ApArInfoApArType =  $agresso_instellingen->{ApArType_leverancier};
     $RoomTypeCode_alg=0;
    
     my $ApArInfoDueDate = $Due_Date;
    
     $SundryInfoBankAccount =~ s/-//g;
     ($BankAccount,$Swift) =&iban__via_webserv_client($SundryInfoBankAccount);
         if ($BankAccount ne '') {
             $SundryInfoBankAccount = $BankAccount;
             $SundryInfoSwift =$Swift;
            }else {
             $SundryInfoBankAccount = ''; #we geven leeg aals het geen iban is op te zoeken
             $SundryInfoSwift = '';
            }
         
     $transactie_onderdeel = {
         TransType => $TransType,
         Description => substr($Description,-200),
         Status => $Status,
         TransDate => $TransDate,
         Amounts => {
             DcFlag => $AmountsDcFlag,
             Amount => $AmountsAmount,
             CurrAmount => $AmountsCurrAmount,
            },
         GLAnalysis => {
             Account => "$GLAnalysisAccount",
             Dim5 => "$GLAnalysisDim5",
             Dim6 => "$GLAnalysisDim6",
             Currency => "$GLAnalysisCurrency",
             TaxCode => "$GLAnalysisTaxCode",
             TaxSystem => "$GLAnalysisTaxSystem",
            },
         ApArInfo => {
             ApArType => "$ApArInfoApArType",
             ApArNo => "$ApArInfoApArNo",
             InvoiceNo => "$ApArInfoInvoiceNo",
             DueDate => "$ApArInfoDueDate",
             BacsId => "$ApArInfoBacsId",
             SundryInfo => {
                 BankAccount => "$SundryInfoBankAccount",
                 Swift => "$SundryInfoSwift",
                }
            }
        };
     my $bedrag = $AmountsDcFlag*$AmountsAmount;
     $factuur_teller +=1;
     $mail = $mail."$factuur_teller :Factuur $ApArInfoInvoiceNo voor $bedrag EURO -> geimporteerd\n";
     print "$factuur_teller :Factuur $ApArInfoInvoiceNo voor $bedrag EURO -> geimporteerd\n";
     push (@Transaction,$transactie_onderdeel);
     print "";
    }

sub maak_volgende_transactie_invoice {
     my $volgnr_invoice = shift @_;
     my $volgnr_Groups = shift @_;
     my $GLAnalysisDim1 = '';
     my $GLAnalysisDim2= "";
     my $GLAnalysisDim3="";
     my $GLAnalysisDim4="";
     my $GLAnalysisDim5="";
     my $GLAnalysisDim6="";
     my $GLAnalysisDim7="";
     my $ApArInfoInvoiceNo = '';
     my $ApArInfoInvoiceNo_1 = '';
     my $ExternalRef = ''; #warnings
     my $SundryInfoBankAccount= '';
     $GLAnalysisDim4 = 0;
     my $GLAnalysisDim4_eerste = 'JA'; 
     my $GLAnalysisDim4_laagste = $GLAnalysisDim4;
     my $LineId ="";
     my $SundryInfoSwift= "";
     my $verblijf_dagen =0;
     my $TransType = "GL";
     my $ApArInfoDueDate = $Due_Date;
     my $GLAnalysisCurrency = $agresso_instellingen->{Currency};
     my $GLAnalysisTaxCode = $agresso_instellingen->{TaxCode};
     my $GLAnalysisTaxSystem ="";
     my $ApArInfoApArType =  $agresso_instellingen->{ApArType_leverancier};
     my $ApArInfoApArNo = '';
     my $AmountsAmount_OAPART =0;
     my $AmountsCurrAmount_OAPART= $AmountsAmount_OAPART;
     my $AmountsAmount_PatientPart =0;
     my $AmountsCurrAmount_PatientPart= $AmountsAmount_PatientPart;
     my $AmountsAmount_Overcharges =0;
     my $AmountsCurrAmount_Overcharges= $AmountsAmount_Overcharges;
     my $GLAnalysisDim1_OAPART=  "OAPART";
     my $AmountsValue1=0;
     my $AmountsNumber1= 0;
     my $Description='';
     my $Status ='N';
     my $TransDate=$vandaag_streepje;
     my $AmountsDcFlag = 1;
     my $GLAnalysisAccount = $agresso_instellingen->{GL_Account};
     if ($volgnr_invoice eq 'geen' and $volgnr_Groups eq 'geen') {
         $GLAnalysisDim3 = $assurcard->{Invoice}->{AssurCardIdentifier};
         $GLAnalysisDim3 = substr($GLAnalysisDim3,5,11);
         $ApArInfoInvoiceNo = $assurcard->{Invoice}->{Id};
         $ApArInfoInvoiceNo_1 = $assurcard->{Invoice}->{InvoiceNumber};
         $ApArInfoInvoiceNo = "$ApArInfoInvoiceNo/$ApArInfoInvoiceNo_1";
         $SundryInfoBankAccount= $assurcard->{Invoice}->{FinancialAccount};
         $ApArInfoApArNo = $assurcard->{Invoice}->{MutualNumber};
         eval {foreach my $volgnr_Group (keys @{$assurcard->{Invoice}->{Groups}->{Group}}) { }};
         if ($@) {
             #is geen Group array
             eval {foreach my $volgnr_Line (keys @{$assurcard->{Invoice}->{Groups}->{Group}->{Line}}) { }};
             if ($@) {
                 #geen Group array geen Line array
                 $AmountsValue1 = $assurcard->{Invoice}->{Groups}->{Group}->{Line}->{Id};
                 $GLAnalysisDim4 = 0;
                 $Description ='';
                 $AmountsAmount_OAPART =0;
                 $AmountsCurrAmount_OAPART= $AmountsAmount_OAPART; 
                 $AmountsAmount_PatientPart =0;
                 $AmountsCurrAmount_PatientPart= $AmountsAmount_PatientPart;
                 $AmountsAmount_Overcharges =0;
                 $AmountsCurrAmount_Overcharges= $AmountsAmount_Overcharges; 
                 my $FlagGPS =0;
                 my $LVZBaseValue=0;
                 foreach my $volgnr_Col (keys @{$assurcard->{Invoice}->{Groups}->{Group}->{Line}->{Col}}) {
                     if ($assurcard->{Invoice}->{Groups}->{Group}->{Line}->{Col}[$volgnr_Col]->{Type} eq "OAPart") {
                         $AmountsAmount_OAPART = $assurcard->{Invoice}->{Groups}->{Group}->{Line}->{Col}[$volgnr_Col]->{content};#code
                         $AmountsCurrAmount_OAPART= $AmountsAmount_OAPART;                                 
                      }
                     if ($assurcard->{Invoice}->{Groups}->{Group}->{Line}->{Col}[$volgnr_Col]->{Type} eq "PatientPart") {
                         $AmountsAmount_PatientPart = $assurcard->{Invoice}->{Groups}->{Group}->{Line}->{Col}[$volgnr_Col]->{content};#code
                         $AmountsCurrAmount_PatientPart= $AmountsAmount_PatientPart;        #code
                      }
                     if ($assurcard->{Invoice}->{Groups}->{Group}->{Line}->{Col}[$volgnr_Col]->{Type} eq "Overcharges") {
                         $AmountsAmount_Overcharges = $assurcard->{Invoice}->{Groups}->{Group}->{Line}->{Col}[$volgnr_Col]->{content};#code
                         $AmountsCurrAmount_Overcharges= $AmountsAmount_Overcharges;        #code
                      }
                     if ($assurcard->{Invoice}->{Groups}->{Group}->{Line}->{Col}[$volgnr_Col]->{Type} eq "INAMICode") {
                         $GLAnalysisDim2=$assurcard->{Invoice}->{Groups}->{Group}->{Line}->{Col}[$volgnr_Col]->{content};
                      }
                     if ($assurcard->{Invoice}->{Groups}->{Group}->{Line}->{Col}[$volgnr_Col]->{Type} eq "ServiceIdentifier") {
                         if ($GLAnalysisDim4_eerste eq 'JA') {
                             $GLAnalysisDim4 = $assurcard->{Invoice}->{Groups}->{Group}->{Line}->{Col}[$volgnr_Col]->{content};
                             $GLAnalysisDim4_eerste = 'NEE';
                             $GLAnalysisDim4_laagste = $GLAnalysisDim4;
                         }else {
                             my $GLAnalysisDim4_test = $assurcard->{Invoice}->{Groups}->{Group}->{Line}->{Col}[$volgnr_Col]->{content};
                             if ($GLAnalysisDim4_test < $GLAnalysisDim4_laagste) {
                                 $GLAnalysisDim4_laagste = $GLAnalysisDim4_test;#code
                                }
                            } 
                        }
                     if ($assurcard->{Invoice}->{Groups}->{Group}->{Line}->{Col}[$volgnr_Col]->{Type} eq "RoomTypeCode") {
                         $GLAnalysisDim5=$assurcard->{Invoice}->{Groups}->{Group}->{Line}->{Col}[$volgnr_Col]->{content};
                      }
                     if ($assurcard->{Invoice}->{Groups}->{Group}->{Line}->{Col}[$volgnr_Col]->{Type} eq "StartDate") {
                         $GLAnalysisDim6=$assurcard->{Invoice}->{Groups}->{Group}->{Line}->{Col}[$volgnr_Col]->{content};
                         $GLAnalysisDim6  =~ s/-//g;$GLAnalysisDim6  =~ s/\s//g;
                        }
                     if ($assurcard->{Invoice}->{Groups}->{Group}->{Line}->{Col}[$volgnr_Col]->{Type} eq "EndDate") {
                         $GLAnalysisDim7=$assurcard->{Invoice}->{Groups}->{Group}->{Line}->{Col}[$volgnr_Col]->{content};
                         $GLAnalysisDim7  =~ s/-//g;$GLAnalysisDim7  =~ s/\s//g;
                       }
                     if ($assurcard->{Invoice}->{Groups}->{Group}->{Line}->{Col}[$volgnr_Col]->{Type} eq "Quantity") {
                         $AmountsNumber1 =$assurcard->{Invoice}->{Groups}->{Group}->{Line}->{Col}[$volgnr_Col]->{content};
                       }
                     if ($assurcard->{Invoice}->{Groups}->{Group}->{Line}->{Col}[$volgnr_Col]->{Type} eq "Type") {
                         $Description =substr($assurcard->{Invoice}->{Groups}->{Group}->{Line}->{Col}[$volgnr_Col]->{content},-200);
                       }
                     if ($assurcard->{Invoice}->{Groups}->{Group}->{Line}->{Col}[$volgnr_Col]->{Type} eq "FlagGPS") {
                         $FlagGPS =$assurcard->{Invoice}->{Groups}->{Group}->{Line}->{Col}[$volgnr_Col]->{content};
                       }
                     if ($assurcard->{Invoice}->{Groups}->{Group}->{Line}->{Col}[$volgnr_Col]->{Type} eq "LVZBaseValue") {
                         $LVZBaseValue =$assurcard->{Invoice}->{Groups}->{Group}->{Line}->{Col}[$volgnr_Col]->{content};
                       }
                    
                     eval {my $bestaat = $assurcard->{Invoice}->{Groups}->{Group}->{Line}->{Warnings}};
                     if (!$@) {
                          eval {my $bestaat1 = $assurcard->{Invoice}->{Groups}->{Group}->{Line}->{Warnings}->{Warning}};
                          if (!$@) {
                               my $code_warning = $assurcard->{Invoice}->{Groups}->{Group}->{Line}->{Warnings}->{Warning}->{Code};
                               my $Description_warning= substr($assurcard->{Invoice}->{Groups}->{Group}->{Line}->{Warnings}->{Warning}->{Description},-200);
                               #$Description_warning = substr ($Description_warning,0,235);
                               $ExternalRef = "$code_warning : $Description_warning";
                               $ExternalRef = '' if ($ExternalRef eq ' : ') ;
                              }else {
                               eval {my $bestaat2 = $assurcard->{Invoice}->{Groups}->{Group}->{Line}->{Warnings}[0]->{Warning}};
                                if (!$@) {
                                    my $code_warning = $assurcard->{Invoice}->{Groups}->{Group}->{Line}->{Warnings}[0]->{Warning}->{Code};
                                    my $Description_warning= substr($assurcard->{Invoice}->{Groups}->{Group}->{Line}->{Warnings}[0]->{Warning}->{Description},-200);
                                    #$Description_warning = substr ($Description_warning,0,235);
                                    $ExternalRef = "$code_warning : $Description_warning";
                                     $ExternalRef = '' if ($ExternalRef eq ' : ') ;
                                   }
                              }
                          
                         }
                     
                    }
                 #$mail = $mail."ApArInfoInvoiceNo  $ApArInfoInvoiceNo  FlagGPS $FlagGPS LVZBaseValue $LVZBaseValue AmountsAmount_OAPART $AmountsAmount_OAPART\n";
                 if ($FlagGPS ==1 and $LVZBaseValue > 0) {                   
                    $AmountsAmount_OAPART  =$LVZBaseValue;
                    $AmountsCurrAmount_OAPART =$LVZBaseValue;
                    $mail = $mail."ApArInfoInvoiceNo  $ApArInfoInvoiceNo  FlagGPS $FlagGPS LVZBaseValue $LVZBaseValue AmountsAmount_OAPART $AmountsAmount_OAPART\n";
                 }
                 undef $transactie_onderdeel;
                 $RoomTypeCode_alg = $GLAnalysisDim5 if ($RoomTypeCode_alg < $GLAnalysisDim5);
                 $GLAnalysisDim6  =~ s/-//g;$GLAnalysisDim6  =~ s/\s//g;$GLAnalysisDim6  =~ s/\s//g;
                 $GLAnalysisDim7  =~ s/-//g;$GLAnalysisDim7  =~ s/\s//g;
                 $GLAnalysisDim6= $HospitalisationStart if ($GLAnalysisDim6 eq '' or  $GLAnalysisDim6 !~ m/\d+/);
                 $GLAnalysisDim7= $HospitalisationEnd if ($GLAnalysisDim7 eq '' or  $GLAnalysisDim7 !~ m/\d+/);
                  
                 $transactie_onderdeel = {
                         TransType => $TransType,
                         Description => substr($Description,-200),
                         Status => $Status,
                         TransDate => $TransDate,
                         ExternalRef => $ExternalRef,
                         Amounts => {
                             DcFlag => $AmountsDcFlag,
                             Amount => $AmountsAmount_OAPART,
                             CurrAmount => $AmountsCurrAmount_OAPART,
                             Value1 => $AmountsValue1,
                            },
                         GLAnalysis => {
                             Account => "$GLAnalysisAccount",
                             Dim1 => "OAPART",
                             Dim2 => $GLAnalysisDim2,
                             Dim3 => $GLAnalysisDim3,
                             Dim4 => $GLAnalysisDim4,
                             Dim5 => $RoomTypeCode_alg,
                             Dim6 => $GLAnalysisDim6,
                             Dim7 => $GLAnalysisDim7,
                             Currency => "$GLAnalysisCurrency",
                             TaxCode => "$GLAnalysisTaxCode",
                             TaxSystem => "$GLAnalysisTaxSystem",
                            },
                         ApArInfo => {
                             ApArType => "$ApArInfoApArType",
                             ApArNo => "$ApArInfoApArNo",
                             InvoiceNo => "$ApArInfoInvoiceNo",
                             DueDate => "$ApArInfoDueDate",
                            }
                        };
                 push (@Transaction,$transactie_onderdeel);
                 undef $transactie_onderdeel;
                 $transactie_onderdeel = {
                         TransType => $TransType,
                         Description => substr($Description,-200),
                         Status => $Status,
                         TransDate => $TransDate,
                         ExternalRef => $ExternalRef,
                         Amounts => {
                             DcFlag => $AmountsDcFlag,
                             Amount =>  $AmountsAmount_PatientPart,
                             CurrAmount => $AmountsCurrAmount_PatientPart,
                             Value1 => $AmountsValue1,
                            },
                         GLAnalysis => {
                             Account => "$GLAnalysisAccount",
                             Dim1 => "PatientPart",
                             Dim2 => $GLAnalysisDim2,
                             Dim3 => $GLAnalysisDim3,
                             Dim4 => $GLAnalysisDim4,
                             Dim5 => $RoomTypeCode_alg,
                             Dim6 => $GLAnalysisDim6,
                             Dim7 => $GLAnalysisDim7,
                             Currency => "$GLAnalysisCurrency",
                             TaxCode => "$GLAnalysisTaxCode",
                             TaxSystem => "$GLAnalysisTaxSystem",
                            },
                         ApArInfo => {
                             ApArType => "$ApArInfoApArType",
                             ApArNo => "$ApArInfoApArNo",
                             InvoiceNo => "$ApArInfoInvoiceNo",
                             DueDate => "$ApArInfoDueDate",
                            }
                        };
                 push (@Transaction,$transactie_onderdeel);
                 undef $transactie_onderdeel;
                 
                 $transactie_onderdeel = {
                         TransType => $TransType,
                         Description => substr($Description,-200),
                         Status => $Status,
                         TransDate => $TransDate,
                         ExternalRef => $ExternalRef,
                         Amounts => {
                             DcFlag => $AmountsDcFlag,
                             Amount =>  $AmountsAmount_Overcharges,
                             CurrAmount => $AmountsCurrAmount_Overcharges,
                             Value1 => $AmountsValue1,
                             Number1 => $AmountsNumber1,
                            },
                         GLAnalysis => {
                             Account => "$GLAnalysisAccount",
                             Dim1 => "Overcharges",
                             Dim2 => $GLAnalysisDim2,
                             Dim3 => $GLAnalysisDim3,
                             Dim4 => $GLAnalysisDim4,
                             Dim5 => $RoomTypeCode_alg,
                             Dim6 => $GLAnalysisDim6,
                             Dim7 => $GLAnalysisDim7,
                             Currency => "$GLAnalysisCurrency",
                             TaxCode => "$GLAnalysisTaxCode",
                             TaxSystem => "$GLAnalysisTaxSystem",
                            },
                         ApArInfo => {
                             ApArType => "$ApArInfoApArType",
                             ApArNo => "$ApArInfoApArNo",
                             InvoiceNo => "$ApArInfoInvoiceNo",
                             DueDate => "$ApArInfoDueDate",
                            }
                        };
                 push (@Transaction,$transactie_onderdeel);
                }else {
                     #geen Group array wel Line array
                     foreach my $volgnr_Line (keys @{$assurcard->{Invoice}->{Groups}->{Group}->{Line}}) {
                         $AmountsValue1 = $assurcard->{Invoice}->{Groups}->{Group}->{Line}[$volgnr_Line]->{Id};
                         $GLAnalysisDim4 = 0;
                         $Description ='';
                         $AmountsAmount_OAPART =0;
                         $AmountsCurrAmount_OAPART= $AmountsAmount_OAPART; 
                         $AmountsAmount_PatientPart =0;
                         $AmountsCurrAmount_PatientPart= $AmountsAmount_PatientPart;
                         $AmountsAmount_Overcharges =0;
                         $AmountsCurrAmount_Overcharges= $AmountsAmount_Overcharges;
                         my $FlagGPS =0;
                         my $LVZBaseValue=0;
                         foreach my $volgnr_Col (keys @{$assurcard->{Invoice}->{Groups}->{Group}->{Line}[$volgnr_Line]->{Col}}) {
                             if ($assurcard->{Invoice}->{Groups}->{Group}->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{Type} eq "OAPart") {
                                 $AmountsAmount_OAPART = $assurcard->{Invoice}->{Groups}->{Group}->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{content};#code
                                 $AmountsCurrAmount_OAPART= $AmountsAmount_OAPART;                                 
                                }
                             if ($assurcard->{Invoice}->{Groups}->{Group}->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{Type} eq "PatientPart") {
                                 $AmountsAmount_PatientPart = $assurcard->{Invoice}->{Groups}->{Group}->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{content};#code
                                 $AmountsCurrAmount_PatientPart= $AmountsAmount_PatientPart;        #code
                                }
                             if ($assurcard->{Invoice}->{Groups}->{Group}->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{Type} eq "Overcharges") {
                                 $AmountsAmount_Overcharges = $assurcard->{Invoice}->{Groups}->{Group}->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{content};#code
                                 $AmountsCurrAmount_Overcharges= $AmountsAmount_Overcharges;        #code
                                }
                             if ($assurcard->{Invoice}->{Groups}->{Group}->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{Type} eq "INAMICode") {
                                 $GLAnalysisDim2=$assurcard->{Invoice}->{Groups}->{Group}->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{content};
                                }
                             if ($assurcard->{Invoice}->{Groups}->{Group}->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{Type} eq "ServiceIdentifier") {
                                 if ($GLAnalysisDim4_eerste eq 'JA') {
                                     $GLAnalysisDim4 = $assurcard->{Invoice}->{Groups}->{Group}->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{content};
                                     $GLAnalysisDim4_eerste = 'NEE';
                                     $GLAnalysisDim4_laagste = $GLAnalysisDim4;
                                    }else {
                                      my $GLAnalysisDim4_test = $assurcard->{Invoice}->{Groups}->{Group}->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{content};
                                      if ($GLAnalysisDim4_test < $GLAnalysisDim4_laagste) {
                                         $GLAnalysisDim4_laagste = $GLAnalysisDim4_test;#code
                                        }
                                    } 
                                }
                             if ($assurcard->{Invoice}->{Groups}->{Group}->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{Type} eq "RoomTypeCode") {
                                 $GLAnalysisDim5=$assurcard->{Invoice}->{Groups}->{Group}->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{content};
                                }
                             if ($assurcard->{Invoice}->{Groups}->{Group}->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{Type} eq "StartDate") {
                                 $GLAnalysisDim6=$assurcard->{Invoice}->{Groups}->{Group}->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{content};
                                 $GLAnalysisDim6  =~ s/-//g;$GLAnalysisDim6  =~ s/\s//g;
                                }
                             if ($assurcard->{Invoice}->{Groups}->{Group}->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{Type} eq "EndDate") {
                                 $GLAnalysisDim7=$assurcard->{Invoice}->{Groups}->{Group}->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{content};
                                 $GLAnalysisDim7  =~ s/-//g;$GLAnalysisDim7  =~ s/\s//g;
                                }
                             if ($assurcard->{Invoice}->{Groups}->{Group}->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{Type} eq "Quantity") {
                                 $AmountsNumber1 =$assurcard->{Invoice}->{Groups}->{Group}->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{content};
                                }
                             if ($assurcard->{Invoice}->{Groups}->{Group}->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{Type} eq "Type") {
                                 $Description =$assurcard->{Invoice}->{Groups}->{Group}->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{content};
                                }
                             if ($assurcard->{Invoice}->{Groups}->{Group}->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{Type} eq "FlagGPS") {
                                        $FlagGPS =$assurcard->{Invoice}->{Groups}->{Group}->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{content};
                                   }
                              if ($assurcard->{Invoice}->{Groups}->{Group}->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{Type} eq "LVZBaseValue") {
                                        $LVZBaseValue =$assurcard->{Invoice}->{Groups}->{Group}->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{content};
                                   }
                             eval {my $bestaat = $assurcard->{Invoice}->{Groups}->{Group}->{Line}[$volgnr_Line]->{Warnings}};
                             if (!$@) {
                               eval {my $bestaat1 = $assurcard->{Invoice}->{Groups}->{Group}->{Line}[$volgnr_Line]->{Warnings}->{Warning}};
                               if (!$@) {
                                    my $code_warning = $assurcard->{Invoice}->{Groups}->{Group}->{Line}[$volgnr_Line]->{Warnings}->{Warning}->{Code};
                                    my $Description_warning= $assurcard->{Invoice}->{Groups}->{Group}->{Line}[$volgnr_Line]->{Warnings}->{Warning}->{Description};
                                    $Description_warning = substr ($Description_warning,0,235);
                                    $ExternalRef = "$code_warning : $Description_warning";
                                     $ExternalRef = '' if ($ExternalRef eq ' : ') ;
                                   }else {
                                    eval {my $bestaat2 = $assurcard->{Invoice}->{Groups}->{Group}->{Line}[$volgnr_Line]->{Warnings}[0]->{Warning}};
                                    if (!$@) {
                                         my $code_warning = $assurcard->{Invoice}->{Groups}->{Group}->{Line}[$volgnr_Line]->{Warnings}[0]->{Warning}->{Code};
                                         my $Description_warning= $assurcard->{Invoice}->{Groups}->{Group}->{Line}[$volgnr_Line]->{Warnings}[0]->{Warning}->{Description};
                                         $Description_warning = substr ($Description_warning,0,235);
                                         $ExternalRef = "$code_warning : $Description_warning";
                                          $ExternalRef = '' if ($ExternalRef eq ' : ') ;
                                        }
                                   }
                              }
                          
                         }
                         #$mail = $mail."ApArInfoInvoiceNo  $ApArInfoInvoiceNo  FlagGPS $FlagGPS LVZBaseValue $LVZBaseValue AmountsAmount_OAPART $AmountsAmount_OAPART\n";
                         if ($FlagGPS ==1 and $LVZBaseValue > 0) {
                              $AmountsAmount_OAPART  =$LVZBaseValue;
                              $AmountsCurrAmount_OAPART =$LVZBaseValue;
                              $mail = $mail."ApArInfoInvoiceNo  $ApArInfoInvoiceNo  FlagGPS $FlagGPS LVZBaseValue $LVZBaseValue AmountsAmount_OAPART $AmountsAmount_OAPART\n";
                           }
                         undef $transactie_onderdeel;
                         $RoomTypeCode_alg = $GLAnalysisDim5 if ($RoomTypeCode_alg < $GLAnalysisDim5);
                         $GLAnalysisDim6  =~ s/-//g;$GLAnalysisDim6  =~ s/\s//g;
                         $GLAnalysisDim7  =~ s/-//g;$GLAnalysisDim7  =~ s/\s//g;
                         $GLAnalysisDim6= $HospitalisationStart if ($GLAnalysisDim6 eq '' or  $GLAnalysisDim6 !~ m/\d+/);
                         $GLAnalysisDim7= $HospitalisationEnd if ($GLAnalysisDim7 eq '' or  $GLAnalysisDim7 !~ m/\d+/);
                         $transactie_onderdeel = {
                             TransType => $TransType,
                             Description => $Description,
                             Status => $Status,
                             TransDate => $TransDate,
                             ExternalRef => $ExternalRef,
                             Amounts => {
                                  DcFlag => $AmountsDcFlag,
                                 Amount => $AmountsAmount_OAPART,
                                 CurrAmount => $AmountsCurrAmount_OAPART,
                                 Value1 => $AmountsValue1,
                                },
                             GLAnalysis => {
                                 Account => "$GLAnalysisAccount",
                                 Dim1 => "OAPART",
                                 Dim2 => $GLAnalysisDim2,
                                 Dim3 => $GLAnalysisDim3,
                                 Dim4 => $GLAnalysisDim4,
                                 Dim5 => $RoomTypeCode_alg,
                                 Dim6 => $GLAnalysisDim6,
                                 Dim7 => $GLAnalysisDim7,
                                 Currency => "$GLAnalysisCurrency",
                                 TaxCode => "$GLAnalysisTaxCode",
                                 TaxSystem => "$GLAnalysisTaxSystem",
                                },
                             ApArInfo => {
                                 ApArType => "$ApArInfoApArType",
                                 ApArNo => "$ApArInfoApArNo",
                                 InvoiceNo => "$ApArInfoInvoiceNo",
                                 DueDate => "$ApArInfoDueDate",
                                }
                            };
                         push (@Transaction,$transactie_onderdeel);                         
                         undef $transactie_onderdeel;
                         $transactie_onderdeel = {
                             TransType => $TransType,
                             Description => substr($Description,-200),
                             Status => $Status,
                             TransDate => $TransDate,
                             ExternalRef => $ExternalRef,
                             Amounts => {
                                 DcFlag => $AmountsDcFlag,
                                 Amount =>  $AmountsAmount_PatientPart,
                                 CurrAmount => $AmountsCurrAmount_PatientPart,
                                 Value1 => $AmountsValue1,
                                },
                             GLAnalysis => {
                                 Account => "$GLAnalysisAccount",
                                 Dim1 => "PatientPart",
                                 Dim2 => $GLAnalysisDim2,
                                 Dim3 => $GLAnalysisDim3,
                                 Dim4 => $GLAnalysisDim4,
                                 Dim5 => $RoomTypeCode_alg,
                                 Dim6 => $GLAnalysisDim6,
                                 Dim7 => $GLAnalysisDim7,
                                 Currency => "$GLAnalysisCurrency",
                                 TaxCode => "$GLAnalysisTaxCode",
                                 TaxSystem => "$GLAnalysisTaxSystem",
                                },
                             ApArInfo => {
                                 ApArType => "$ApArInfoApArType",
                                 ApArNo => "$ApArInfoApArNo",
                                 InvoiceNo => "$ApArInfoInvoiceNo",
                                 DueDate => "$ApArInfoDueDate",
                                }
                           };
                         push (@Transaction,$transactie_onderdeel);
                         undef $transactie_onderdeel;
                         $transactie_onderdeel = {
                             TransType => $TransType,
                             Description => substr($Description,-200),
                             Status => $Status,
                             TransDate => $TransDate,
                             ExternalRef => $ExternalRef,
                             Amounts => {
                                 DcFlag => $AmountsDcFlag,
                                 Amount =>  $AmountsAmount_Overcharges,
                                 CurrAmount => $AmountsCurrAmount_Overcharges,
                                 Number1 => $AmountsNumber1,
                                 Value1 => $AmountsValue1,
                                },
                             GLAnalysis => {
                                 Account => "$GLAnalysisAccount",
                                 Dim1 => "Overcharges",
                                 Dim2 => $GLAnalysisDim2,
                                 Dim3 => $GLAnalysisDim3,
                                 Dim4 => $GLAnalysisDim4,
                                 Dim5 => $RoomTypeCode_alg,
                                 Dim6 => $GLAnalysisDim6,
                                 Dim7 => $GLAnalysisDim7,
                                 Currency => "$GLAnalysisCurrency",
                                 TaxCode => "$GLAnalysisTaxCode",
                                 TaxSystem => "$GLAnalysisTaxSystem",
                                },
                             ApArInfo => {
                                 ApArType => "$ApArInfoApArType",
                                 ApArNo => "$ApArInfoApArNo",
                                 InvoiceNo => "$ApArInfoInvoiceNo",
                                 DueDate => "$ApArInfoDueDate",
                                }
                            };
                         push (@Transaction,$transactie_onderdeel);
                        }
                    }
            }else {
             #wel Group array
             foreach my $volgnr_Group (keys @{$assurcard->{Invoice}->{Groups}->{Group}}) {
                 eval {foreach my $volgnr_Line (keys @{$assurcard->{Invoice}->{Groups}->{Group}[$volgnr_Group]->{Line}}) { }};
                 if ($@) {
                     #wel Group array geen Line array
                     $AmountsValue1 = $assurcard->{Invoice}->{Groups}->{Group}[$volgnr_Group]->{Line}->{Id};
                     $GLAnalysisDim4 = 0;
                     $AmountsAmount_OAPART =0;
                     $AmountsCurrAmount_OAPART= $AmountsAmount_OAPART; 
                     $AmountsAmount_PatientPart =0;
                     $AmountsCurrAmount_PatientPart= $AmountsAmount_PatientPart;
                     $AmountsAmount_Overcharges =0;
                     $AmountsCurrAmount_Overcharges= $AmountsAmount_Overcharges;
                     my $FlagGPS =0;
                     my $LVZBaseValue=0;
                     foreach my $volgnr_Col (keys @{$assurcard->{Invoice}->{Groups}->{Group}[$volgnr_Group]->{Line}->{Col}}) {
                         if ($assurcard->{Invoice}->{Groups}->{Group}[$volgnr_Group]->{Line}->{Col}[$volgnr_Col]->{Type} eq "OAPart") {
                             $AmountsAmount_OAPART = $assurcard->{Invoice}->{Groups}->{Group}[$volgnr_Group]->{Line}->{Col}[$volgnr_Col]->{content};#code
                             $AmountsCurrAmount_OAPART= $AmountsAmount_OAPART;                                 
                            }
                         if ($assurcard->{Invoice}->{Groups}->{Group}[$volgnr_Group]->{Line}->{Col}[$volgnr_Col]->{Type} eq "PatientPart") {
                             $AmountsAmount_PatientPart = $assurcard->{Invoice}->{Groups}->{Group}[$volgnr_Group]->{Line}->{Col}[$volgnr_Col]->{content};#code
                             $AmountsCurrAmount_PatientPart= $AmountsAmount_PatientPart;        #code
                            }
                         if ($assurcard->{Invoice}->{Groups}->{Group}[$volgnr_Group]->{Line}->{Col}[$volgnr_Col]->{Type} eq "Overcharges") {
                             $AmountsAmount_Overcharges = $assurcard->{Invoice}->{Groups}->{Group}[$volgnr_Group]->{Line}->{Col}[$volgnr_Col]->{content};#code
                             $AmountsCurrAmount_Overcharges= $AmountsAmount_Overcharges;        #code
                            }
                         if ($assurcard->{Invoice}->{Groups}->{Group}[$volgnr_Group]->{Line}->{Col}[$volgnr_Col]->{Type} eq "INAMICode") {
                             $GLAnalysisDim2=$assurcard->{Invoice}->{Groups}->{Group}[$volgnr_Group]->{Line}->{Col}[$volgnr_Col]->{content};
                            }
                         if ($assurcard->{Invoice}->{Groups}->{Group}[$volgnr_Group]->{Line}->{Col}[$volgnr_Col]->{Type} eq "ServiceIdentifier") {
                             if ($GLAnalysisDim4_eerste eq 'JA') {
                                 $GLAnalysisDim4 = $assurcard->{Invoice}->{Groups}->{Group}[$volgnr_Group]->{Line}->{Col}[$volgnr_Col]->{content};
                                 $GLAnalysisDim4_eerste = 'NEE';
                                 $GLAnalysisDim4_laagste = $GLAnalysisDim4;
                                }else {
                                 my $GLAnalysisDim4_test = $assurcard->{Invoice}->{Groups}->{Group}[$volgnr_Group]->{Line}->{Col}[$volgnr_Col]->{content};
                                 if ($GLAnalysisDim4_test < $GLAnalysisDim4_laagste) {
                                     $GLAnalysisDim4_laagste = $GLAnalysisDim4_test;#code
                                    }
                                }
                            }
                         if ($assurcard->{Invoice}->{Groups}->{Group}[$volgnr_Group]->{Line}->{Col}[$volgnr_Col]->{Type} eq "RoomTypeCode") {
                             $GLAnalysisDim5=$assurcard->{Invoice}->{Groups}->{Group}[$volgnr_Group]->{Line}->{Col}[$volgnr_Col]->{content};
                            }
                         if ($assurcard->{Invoice}->{Groups}->{Group}[$volgnr_Group]->{Line}->{Col}[$volgnr_Col]->{Type} eq "StartDate") {
                             $GLAnalysisDim6=$assurcard->{Invoice}->{Groups}->{Group}[$volgnr_Group]->{Line}->{Col}[$volgnr_Col]->{content};
                             $GLAnalysisDim6  =~ s/-//g;$GLAnalysisDim6  =~ s/\s//g;
                            }
                         if ($assurcard->{Invoice}->{Groups}->{Group}[$volgnr_Group]->{Line}->{Col}[$volgnr_Col]->{Type} eq "EndDate") {
                             $GLAnalysisDim7=$assurcard->{Invoice}->{Groups}->{Group}[$volgnr_Group]->{Line}->{Col}[$volgnr_Col]->{content};
                             $GLAnalysisDim7  =~ s/-//g;$GLAnalysisDim7  =~ s/\s//g;
                            }
                         if ($assurcard->{Invoice}->{Groups}->{Group}[$volgnr_Group]->{Line}->{Col}[$volgnr_Col]->{Type} eq "Quantity") {
                             $AmountsNumber1 =$assurcard->{Invoice}->{Groups}->{Group}[$volgnr_Group]->{Line}->{Col}[$volgnr_Col]->{content};
                            }
                         if ($assurcard->{Invoice}->{Groups}->{Group}[$volgnr_Group]->{Line}->{Col}[$volgnr_Col]->{Type} eq "Type") {
                             $Description =$assurcard->{Invoice}->{Groups}->{Group}[$volgnr_Group]->{Line}->{Col}[$volgnr_Col]->{content};
                            }
                         if ($assurcard->{Invoice}->{Groups}->{Group}[$volgnr_Group]->{Line}->{Col}[$volgnr_Col]->{Type} eq "FlagGPS") {
                                        $FlagGPS =$assurcard->{Invoice}->{Groups}->{Group}[$volgnr_Group]->{Line}->{Col}[$volgnr_Col]->{content};
                                   }
                         if ($assurcard->{Invoice}->{Groups}->{Group}[$volgnr_Group]->{Line}->{Col}[$volgnr_Col]->{Type} eq "LVZBaseValue") {
                                        $LVZBaseValue =$assurcard->{Invoice}->{Groups}->{Group}[$volgnr_Group]->{Line}->{Col}[$volgnr_Col]->{content};
                                   }
                         eval {my $bestaat = $assurcard->{Invoice}->{Groups}->{Group}[$volgnr_Group]->{Line}->{Warnings}};
                         if (!$@) {
                          eval {my $bestaat1 = $assurcard->{Invoice}->{Groups}->{Group}[$volgnr_Group]->{Line}->{Warnings}->{Warning}};
                          if (!$@) {
                               my $code_warning = $assurcard->{Invoice}->{Groups}->{Group}[$volgnr_Group]->{Line}->{Warnings}->{Warning}->{Code};
                               my $Description_warning= substr($assurcard->{Invoice}->{Groups}->{Group}[$volgnr_Group]->{Line}->{Warnings}->{Warning}->{Description},-200);
                               #$Description_warning = substr ($Description_warning,0,235);
                               $ExternalRef = "$code_warning : $Description_warning";
                                $ExternalRef = '' if ($ExternalRef eq ' : ') ;
                              }else {
                               eval {my $bestaat2 = $assurcard->{Invoice}->{Groups}->{Group}[$volgnr_Group]->{Line}->{Warnings}[0]->{Warning}};
                               if (!$@) {
                                    my $code_warning = $assurcard->{Invoice}->{Groups}->{Group}[$volgnr_Group]->{Line}->{Warnings}[0]->{Warning}->{Code};
                                    my $Description_warning= substr($assurcard->{Invoice}->{Groups}->{Group}[$volgnr_Group]->{Line}->{Warnings}[0]->{Warning}->{Description},-200);
                                    #$Description_warning = substr ($Description_warning,0,235);
                                    $ExternalRef = "$code_warning : $Description_warning";
                                    $ExternalRef = '' if ($ExternalRef eq ' : ') ;
                                   }
                              }
                         }
                        }
                     #$mail = $mail."ApArInfoInvoiceNo  $ApArInfoInvoiceNo  FlagGPS $FlagGPS LVZBaseValue $LVZBaseValue AmountsAmount_OAPART $AmountsAmount_OAPART\n";
                      if ($FlagGPS ==1 and $LVZBaseValue > 0) {
                              $AmountsAmount_OAPART  =$LVZBaseValue;
                              $AmountsCurrAmount_OAPART =$LVZBaseValue;
                              $mail = $mail."ApArInfoInvoiceNo  $ApArInfoInvoiceNo  FlagGPS $FlagGPS LVZBaseValue $LVZBaseValue AmountsAmount_OAPART $AmountsAmount_OAPART\n";
                           }
                     undef $transactie_onderdeel;
                         $RoomTypeCode_alg = $GLAnalysisDim5 if ($RoomTypeCode_alg < $GLAnalysisDim5);
                         $GLAnalysisDim6  =~ s/-//g;$GLAnalysisDim6  =~ s/\s//g;
                         $GLAnalysisDim7  =~ s/-//g;$GLAnalysisDim7  =~ s/\s//g;
                         $GLAnalysisDim6= $HospitalisationStart if ($GLAnalysisDim6 eq '' or  $GLAnalysisDim6 !~ m/\d+/);
                         $GLAnalysisDim7= $HospitalisationEnd if ($GLAnalysisDim7 eq '' or  $GLAnalysisDim7 !~ m/\d+/);
                     $transactie_onderdeel = {
                         TransType => $TransType,
                         Description => substr($Description,-200),
                         Status => $Status,
                         TransDate => $TransDate,
                         ExternalRef => $ExternalRef,
                         Amounts => {
                             DcFlag => $AmountsDcFlag,
                             Amount => $AmountsAmount_OAPART,
                             CurrAmount => $AmountsCurrAmount_OAPART,
                             Value1 => $AmountsValue1,
                            },
                         GLAnalysis => {
                             Account => "$GLAnalysisAccount",
                             Dim1 => "OAPART",
                             Dim2 => $GLAnalysisDim2,
                             Dim3 => $GLAnalysisDim3,
                             Dim4 => $GLAnalysisDim4,
                             Dim5 => $RoomTypeCode_alg,
                             Dim6 => $GLAnalysisDim6,
                             Dim7 => $GLAnalysisDim7,
                             Currency => "$GLAnalysisCurrency",
                             TaxCode => "$GLAnalysisTaxCode",
                             TaxSystem => "$GLAnalysisTaxSystem",
                            },
                         ApArInfo => {
                             ApArType => "$ApArInfoApArType",
                             ApArNo => "$ApArInfoApArNo",
                             InvoiceNo => "$ApArInfoInvoiceNo",
                             DueDate => "$ApArInfoDueDate",
                            }
                        };
                     push (@Transaction,$transactie_onderdeel);
                     undef $transactie_onderdeel;
                     $transactie_onderdeel = {
                         TransType => $TransType,
                         Description => substr($Description,-200),
                         Status => $Status,
                         TransDate => $TransDate,
                         ExternalRef => $ExternalRef,
                         Amounts => {
                             DcFlag => $AmountsDcFlag,
                             Amount =>  $AmountsAmount_PatientPart,
                             CurrAmount => $AmountsCurrAmount_PatientPart,
                             Value1 => $AmountsValue1,
                            },
                         GLAnalysis => {
                             Account => "$GLAnalysisAccount",
                             Dim1 => "PatientPart",
                             Dim2 => $GLAnalysisDim2,
                             Dim3 => $GLAnalysisDim3,
                             Dim4 => $GLAnalysisDim4,
                             Dim5 => $RoomTypeCode_alg,
                             Dim6 => $GLAnalysisDim6,
                              Dim7 => $GLAnalysisDim7,
                             Currency => "$GLAnalysisCurrency",
                             TaxCode => "$GLAnalysisTaxCode",
                             TaxSystem => "$GLAnalysisTaxSystem",
                            },
                         ApArInfo => {
                             ApArType => "$ApArInfoApArType",
                             ApArNo => "$ApArInfoApArNo",
                             InvoiceNo => "$ApArInfoInvoiceNo",
                             DueDate => "$ApArInfoDueDate",
                            }
                        };
                     push (@Transaction,$transactie_onderdeel);
                     undef $transactie_onderdeel;
                     $transactie_onderdeel = {
                         TransType => $TransType,
                         Description => substr($Description,-200),
                         Status => $Status,
                         TransDate => $TransDate,
                         ExternalRef => $ExternalRef,
                         Amounts => {
                             DcFlag => $AmountsDcFlag,
                             Amount =>  $AmountsAmount_Overcharges,
                             CurrAmount => $AmountsCurrAmount_Overcharges,
                             Number1 => $AmountsNumber1,
                             Value1 => $AmountsValue1,
                            },
                         GLAnalysis => {
                             Account => "$GLAnalysisAccount",
                             Dim1 => "Overcharges",
                             Dim2 => $GLAnalysisDim2,
                             Dim3 => $GLAnalysisDim3,
                             Dim4 => $GLAnalysisDim4,
                             Dim5 => $RoomTypeCode_alg,
                             Dim6 => $GLAnalysisDim6,
                             Dim7 => $GLAnalysisDim7,
                             Currency => "$GLAnalysisCurrency",
                             TaxCode => "$GLAnalysisTaxCode",
                             TaxSystem => "$GLAnalysisTaxSystem",
                            },
                         ApArInfo => {
                             ApArType => "$ApArInfoApArType",
                             ApArNo => "$ApArInfoApArNo",
                             InvoiceNo => "$ApArInfoInvoiceNo",
                             DueDate => "$ApArInfoDueDate",
                            }
                        };
                     push (@Transaction,$transactie_onderdeel);
                    }else {
                     #wel Group array wel Line array
                     foreach my $volgnr_Line (keys @{$assurcard->{Invoice}->{Groups}->{Group}[$volgnr_Group]->{Line}}) {
                         $AmountsValue1 = $assurcard->{Invoice}->{Groups}->{Group}[$volgnr_Group]->{Line}[$volgnr_Line]->{Id};
                         $GLAnalysisDim4 = 0;
                         $AmountsAmount_OAPART =0;
                         $AmountsCurrAmount_OAPART= $AmountsAmount_OAPART; 
                         $AmountsAmount_PatientPart =0;
                         $AmountsCurrAmount_PatientPart= $AmountsAmount_PatientPart;
                         $AmountsAmount_Overcharges =0;
                         $AmountsCurrAmount_Overcharges= $AmountsAmount_Overcharges; 
                         my $FlagGPS =0;
                         my $LVZBaseValue=0;
                         foreach my $volgnr_Col (keys @{$assurcard->{Invoice}->{Groups}->{Group}[$volgnr_Group]->{Line}[$volgnr_Line]->{Col}}) {
                             if ($assurcard->{Invoice}->{Groups}->{Group}[$volgnr_Group]->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{Type} eq "OAPart") {
                                 $AmountsAmount_OAPART = $assurcard->{Invoice}->{Groups}->{Group}[$volgnr_Group]->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{content};#code
                                 $AmountsCurrAmount_OAPART= $AmountsAmount_OAPART;                                 
                                }
                             if ($assurcard->{Invoice}->{Groups}->{Group}[$volgnr_Group]->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{Type} eq "PatientPart") {
                                 $AmountsAmount_PatientPart = $assurcard->{Invoice}->{Groups}->{Group}[$volgnr_Group]->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{content};#code
                                 $AmountsCurrAmount_PatientPart= $AmountsAmount_PatientPart;        #code
                                }
                             if ($assurcard->{Invoice}->{Groups}->{Group}[$volgnr_Group]->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{Type} eq "Overcharges") {
                                 $AmountsAmount_Overcharges = $assurcard->{Invoice}->{Groups}->{Group}[$volgnr_Group]->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{content};#code
                                 $AmountsCurrAmount_Overcharges= $AmountsAmount_Overcharges;        #code
                                }
                             if ($assurcard->{Invoice}->{Groups}->{Group}[$volgnr_Group]->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{Type} eq "INAMICode") {
                                 $GLAnalysisDim2=$assurcard->{Invoice}->{Groups}->{Group}[$volgnr_Group]->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{content};
                                }
                             if ($assurcard->{Invoice}->{Groups}->{Group}[$volgnr_Group]->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{Type} eq "ServiceIdentifier") {
                                 if ($GLAnalysisDim4_eerste eq 'JA') {
                                     $GLAnalysisDim4 = $assurcard->{Invoice}->{Groups}->{Group}[$volgnr_Group]->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{content};
                                     $GLAnalysisDim4_eerste = 'NEE';
                                     $GLAnalysisDim4_laagste = $GLAnalysisDim4;
                                    }else {
                                     my $GLAnalysisDim4_test = $assurcard->{Invoice}->{Groups}->{Group}[$volgnr_Group]->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{content};
                                     if ($GLAnalysisDim4_test < $GLAnalysisDim4_laagste) {
                                         $GLAnalysisDim4_laagste = $GLAnalysisDim4_test;#code
                                        }
                                    }
                                }
                             if ($assurcard->{Invoice}->{Groups}->{Group}[$volgnr_Group]->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{Type} eq "RoomTypeCode") {
                                 $GLAnalysisDim5=$assurcard->{Invoice}->{Groups}->{Group}[$volgnr_Group]->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{content};
                                 $GLAnalysisDim6  =~ s/-//g;$GLAnalysisDim6  =~ s/\s//g;
                                }
                             if ($assurcard->{Invoice}->{Groups}->{Group}[$volgnr_Group]->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{Type} eq "StartDate") {
                                 $GLAnalysisDim6=$assurcard->{Invoice}->{Groups}->{Group}[$volgnr_Group]->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{content};
                                }
                             if ($assurcard->{Invoice}->{Groups}->{Group}[$volgnr_Group]->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{Type} eq "EndDate") {
                                 $GLAnalysisDim7=$assurcard->{Invoice}->{Groups}->{Group}[$volgnr_Group]->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{content};
                                 $GLAnalysisDim7  =~ s/-//g;$GLAnalysisDim7  =~ s/\s//g;
                                }
                             if ($assurcard->{Invoice}->{Groups}->{Group}[$volgnr_Group]->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{Type} eq "Quantity") {
                                 $AmountsNumber1 =$assurcard->{Invoice}->{Groups}->{Group}[$volgnr_Group]->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{content};
                                }
                             if ($assurcard->{Invoice}->{Groups}->{Group}[$volgnr_Group]->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{Type} eq "Type") {
                                 $Description =$assurcard->{Invoice}->{Groups}->{Group}[$volgnr_Group]->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{content};
                                }
                              if ($assurcard->{Invoice}->{Groups}->{Group}[$volgnr_Group]->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{Type} eq "FlagGPS") {
                                        $FlagGPS =$assurcard->{Invoice}->{Groups}->{Group}[$volgnr_Group]->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{content};
                                   }
                              if ($assurcard->{Invoice}->{Groups}->{Group}[$volgnr_Group]->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{Type} eq "LVZBaseValue") {
                                        $LVZBaseValue =$assurcard->{Invoice}->{Groups}->{Group}[$volgnr_Group]->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{content};
                                   }
                             eval {my $bestaat = $assurcard->{Invoice}->{Groups}->{Group}[$volgnr_Group]->{Line}[$volgnr_Line]->{Warnings}};
                             print "volgnr_Group $volgnr_Group volgnr_Line $volgnr_Line\n";
                             if (!$@) {
                               eval {my $bestaat1 = $assurcard->{Invoice}->{Groups}->{Group}[$volgnr_Group]->{Line}[$volgnr_Line]->{Warnings}->{Warning}};
                               if (!$@) {
                                    my $code_warning = $assurcard->{Invoice}->{Groups}->{Group}[$volgnr_Group]->{Line}[$volgnr_Line]->{Warnings}->{Warning}->{Code};
                                    print "  code warning $code_warning\n";
                                    my $Description_warning= substr($assurcard->{Invoice}->{Groups}->{Group}[$volgnr_Group]->{Line}[$volgnr_Line]->{Warnings}->{Warning}->{Description},-200);
                                    #$Description_warning = substr ($Description_warning,0,235);
                                    $ExternalRef = "$code_warning : $Description_warning";
                                    $ExternalRef = '' if ($ExternalRef eq ' : ') ;
                                   }else {
                                    eval {my $bestaat2 = $assurcard->{Invoice}->{Groups}->{Group}[$volgnr_Group]->{Line}[$volgnr_Line]->{Warnings}[0]->{Warning}};
                                    if (!$@) {
                                         my $code_warning = $assurcard->{Invoice}->{Groups}->{Group}[$volgnr_Group]->{Line}[$volgnr_Line]->{Warnings}[0]->{Warning}->{Code};
                                         my $Description_warning= substr($assurcard->{Invoice}->{Groups}->{Group}[$volgnr_Group]->{Line}[$volgnr_Line]->{Warnings}[0]->{Warning}->{Description},-200);
                                         #$Description_warning = substr ($Description_warning,0,235);
                                         $ExternalRef = "$code_warning : $Description_warning";
                                         $ExternalRef = '' if ($ExternalRef eq ' : ') ;
                                        }
                                   }
                              }
                         }
                         #$mail = $mail."ApArInfoInvoiceNo  $ApArInfoInvoiceNo  FlagGPS $FlagGPS LVZBaseValue $LVZBaseValue AmountsAmount_OAPART $AmountsAmount_OAPART\n";
                          if ($FlagGPS ==1 and $LVZBaseValue > 0) {
                              $AmountsAmount_OAPART  =$LVZBaseValue;
                              $AmountsCurrAmount_OAPART =$LVZBaseValue;
                              $mail = $mail."ApArInfoInvoiceNo  $ApArInfoInvoiceNo  FlagGPS $FlagGPS LVZBaseValue $LVZBaseValue AmountsAmount_OAPART $AmountsAmount_OAPART\n";
                           }
                         undef $transactie_onderdeel;
                         $RoomTypeCode_alg = $GLAnalysisDim5 if ($RoomTypeCode_alg < $GLAnalysisDim5);
                         $GLAnalysisDim6  =~ s/-//g;$GLAnalysisDim6  =~ s/\s//g;
                         $GLAnalysisDim7  =~ s/-//g;$GLAnalysisDim7  =~ s/\s//g;
                         $GLAnalysisDim6= $HospitalisationStart if ($GLAnalysisDim6 eq '' or  $GLAnalysisDim6 !~ m/\d+/);
                         $GLAnalysisDim7= $HospitalisationEnd if ($GLAnalysisDim7 eq '' or  $GLAnalysisDim7 !~ m/\d+/);
                         $transactie_onderdeel = {
                             TransType => $TransType,
                             Description => substr($Description,-200),
                             Status => $Status,
                             TransDate => $TransDate,
                             ExternalRef => $ExternalRef,
                             Amounts => {
                                 DcFlag => $AmountsDcFlag,
                                 Amount => $AmountsAmount_OAPART,
                                 CurrAmount => $AmountsCurrAmount_OAPART,
                                 Value1 => $AmountsValue1,
                                },
                             GLAnalysis => {
                                 Account => "$GLAnalysisAccount",
                                 Dim1 => "OAPART",
                                 Dim2 => $GLAnalysisDim2,
                                 Dim3 => $GLAnalysisDim3,
                                 Dim4 => $GLAnalysisDim4,
                                 Dim5 => $RoomTypeCode_alg,
                                 Dim6 => $GLAnalysisDim6,
                                 Dim7 => $GLAnalysisDim7,
                                 Currency => "$GLAnalysisCurrency",
                                 TaxCode => "$GLAnalysisTaxCode",
                                 TaxSystem => "$GLAnalysisTaxSystem",
                                },
                             ApArInfo => {
                                 ApArType => "$ApArInfoApArType",
                                 ApArNo => "$ApArInfoApArNo",
                                 InvoiceNo => "$ApArInfoInvoiceNo",
                                 DueDate => "$ApArInfoDueDate",
                                }
                            };
                         push (@Transaction,$transactie_onderdeel);
                         undef $transactie_onderdeel;
                         $transactie_onderdeel = {
                         TransType => $TransType,
                         Description => substr($Description,-200),
                         Status => $Status,
                         TransDate => $TransDate,
                         ExternalRef => $ExternalRef,
                         Amounts => {
                             DcFlag => $AmountsDcFlag,
                             Amount =>  $AmountsAmount_PatientPart,
                             CurrAmount => $AmountsCurrAmount_PatientPart,
                             Value1 => $AmountsValue1,
                            },
                         GLAnalysis => {
                             Account => "$GLAnalysisAccount",
                             Dim1 => "PatientPart",
                             Dim2 => $GLAnalysisDim2,
                             Dim3 => $GLAnalysisDim3,
                             Dim4 => $GLAnalysisDim4,
                             Dim5 => $RoomTypeCode_alg,
                             Dim6 => $GLAnalysisDim6,
                             Dim7 => $GLAnalysisDim7,
                             Currency => "$GLAnalysisCurrency",
                             TaxCode => "$GLAnalysisTaxCode",
                             TaxSystem => "$GLAnalysisTaxSystem",
                            },
                         ApArInfo => {
                             ApArType => "$ApArInfoApArType",
                             ApArNo => "$ApArInfoApArNo",
                             InvoiceNo => "$ApArInfoInvoiceNo",
                             DueDate => "$ApArInfoDueDate",
                            }
                        };
                         push (@Transaction,$transactie_onderdeel);
                         undef $transactie_onderdeel;
                         $transactie_onderdeel = {
                         TransType => $TransType,
                         Description => substr($Description,-200),
                         Status => $Status,
                         TransDate => $TransDate,
                         ExternalRef => $ExternalRef,
                         Amounts => {
                             DcFlag => $AmountsDcFlag,
                             Amount =>  $AmountsAmount_Overcharges,
                             CurrAmount => $AmountsCurrAmount_Overcharges,
                             Number1 => $AmountsNumber1,
                             Value1 => $AmountsValue1,
                            },
                         GLAnalysis => {
                             Account => "$GLAnalysisAccount",
                             Dim1 => "Overcharges",
                             Dim2 => $GLAnalysisDim2,
                             Dim3 => $GLAnalysisDim3,
                             Dim4 => $GLAnalysisDim4,
                             Dim5 => $RoomTypeCode_alg,
                             Dim6 => $GLAnalysisDim6,
                             Dim7 => $GLAnalysisDim7,
                             Currency => "$GLAnalysisCurrency",
                             TaxCode => "$GLAnalysisTaxCode",
                             TaxSystem => "$GLAnalysisTaxSystem",
                            },
                         ApArInfo => {
                             ApArType => "$ApArInfoApArType",
                             ApArNo => "$ApArInfoApArNo",
                             InvoiceNo => "$ApArInfoInvoiceNo",
                             DueDate => "$ApArInfoDueDate",
                            }
                        };
                         push (@Transaction,$transactie_onderdeel);
                        }
                     
                    }
                }
            }
        }elsif ($volgnr_invoice ne 'geen' and $volgnr_Groups eq 'geen') {
         $GLAnalysisDim3 = $assurcard->{Invoice}[$volgnr_invoice]->{AssurCardIdentifier};
         $GLAnalysisDim3 = substr($GLAnalysisDim3,5,11);
         $ApArInfoInvoiceNo = $assurcard->{Invoice}[$volgnr_invoice]->{Id};
         $ApArInfoInvoiceNo_1 = $assurcard->{Invoice}[$volgnr_invoice]->{InvoiceNumber};
         $ApArInfoInvoiceNo = "$ApArInfoInvoiceNo/$ApArInfoInvoiceNo_1";
         $SundryInfoBankAccount= $assurcard->{Invoice}[$volgnr_invoice]->{FinancialAccount};
         $ApArInfoApArNo = $assurcard->{Invoice}[$volgnr_invoice]->{MutualNumber};
         eval {foreach my $volgnr_Group (keys @{$assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}}) { }};
         if ($@) {
             #is geen Group array
             eval {foreach my $volgnr_Line (keys @{$assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}->{Line}}) { }};
             if ($@) {
                 #geen Group array geen Line array
                 $AmountsValue1 = $assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}->{Line}->{Id};
                 $GLAnalysisDim4 = 0;
                 $Description ='';
                 $AmountsAmount_OAPART =0;
                 $AmountsCurrAmount_OAPART= $AmountsAmount_OAPART; 
                 $AmountsAmount_PatientPart =0;
                 $AmountsCurrAmount_PatientPart= $AmountsAmount_PatientPart;
                 $AmountsAmount_Overcharges =0;
                 $AmountsCurrAmount_Overcharges= $AmountsAmount_Overcharges;
                 my $FlagGPS =0;
                 my $LVZBaseValue=0;
                 foreach my $volgnr_Col (keys @{$assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}->{Line}->{Col}}) {
                     if ($assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}->{Line}->{Col}[$volgnr_Col]->{Type} eq "OAPart") {
                         $AmountsAmount_OAPART = $assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}->{Line}->{Col}[$volgnr_Col]->{content};#code
                         $AmountsCurrAmount_OAPART= $AmountsAmount_OAPART;                                 
                      }
                     if ($assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}->{Line}->{Col}[$volgnr_Col]->{Type} eq "PatientPart") {
                         $AmountsAmount_PatientPart = $assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}->{Line}->{Col}[$volgnr_Col]->{content};#code
                         $AmountsCurrAmount_PatientPart= $AmountsAmount_PatientPart;        #code
                      }
                     if ($assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}->{Line}->{Col}[$volgnr_Col]->{Type} eq "Overcharges") {
                         $AmountsAmount_Overcharges = $assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}->{Line}->{Col}[$volgnr_Col]->{content};#code
                         $AmountsCurrAmount_Overcharges= $AmountsAmount_Overcharges;        #code
                      }
                     if ($assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}->{Line}->{Col}[$volgnr_Col]->{Type} eq "INAMICode") {
                         $GLAnalysisDim2=$assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}->{Line}->{Col}[$volgnr_Col]->{content};
                      }
                     if ($assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}->{Line}->{Col}[$volgnr_Col]->{Type} eq "ServiceIdentifier") {
                         if ($GLAnalysisDim4_eerste eq 'JA') {
                             $GLAnalysisDim4 = $assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}->{Line}->{Col}[$volgnr_Col]->{content};
                             $GLAnalysisDim4_eerste = 'NEE';
                             $GLAnalysisDim4_laagste = $GLAnalysisDim4;
                         }else {
                             my $GLAnalysisDim4_test = $assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}->{Line}->{Col}[$volgnr_Col]->{content};
                             if ($GLAnalysisDim4_test < $GLAnalysisDim4_laagste) {
                                 $GLAnalysisDim4_laagste = $GLAnalysisDim4_test;#code
                                }
                            } 
                        }
                     if ($assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}->{Line}->{Col}[$volgnr_Col]->{Type} eq "RoomTypeCode") {
                         $GLAnalysisDim5=$assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}->{Line}->{Col}[$volgnr_Col]->{content};
                      }
                     if ($assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}->{Line}->{Col}[$volgnr_Col]->{Type} eq "StartDate") {
                         $GLAnalysisDim6=$assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}->{Line}->{Col}[$volgnr_Col]->{content};
                         $GLAnalysisDim6  =~ s/-//g;$GLAnalysisDim6  =~ s/\s//g;
                        }
                     if ($assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}->{Line}->{Col}[$volgnr_Col]->{Type} eq "EndDate") {
                         $GLAnalysisDim7=$assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}->{Line}->{Col}[$volgnr_Col]->{content};
                         $GLAnalysisDim7  =~ s/-//g;$GLAnalysisDim7  =~ s/\s//g;
                       }
                     if ($assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}->{Line}->{Col}[$volgnr_Col]->{Type} eq "Quantity") {
                         $AmountsNumber1 =$assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}->{Line}->{Col}[$volgnr_Col]->{content};
                       }
                     if ($assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}->{Line}->{Col}[$volgnr_Col]->{Type} eq "Type") {
                         $Description =$assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}->{Line}->{Col}[$volgnr_Col]->{content};
                       }
                      if ($assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}->{Line}->{Col}[$volgnr_Col]->{Type} eq "FlagGPS") {
                         $FlagGPS =$assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}->{Line}->{Col}[$volgnr_Col]->{content};
                       }
                     if ($assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}->{Line}->{Col}[$volgnr_Col]->{Type} eq "LVZBaseValue") {
                         $LVZBaseValue =$assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}->{Line}->{Col}[$volgnr_Col]->{content};
                        }
                     eval {my $bestaat = $assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}->{Line}->{Warnings}};
                             if (!$@) {
                               eval {my $bestaat1 = $assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}->{Line}->{Warnings}->{Warning}};
                               if (!$@) {
                                    my $code_warning = $assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}->{Line}->{Warnings}->{Warning}->{Code};
                                    my $Description_warning= substr($assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}->{Line}->{Warnings}->{Warning}->{Description},-200);
                                    #$Description_warning = substr ($Description_warning,0,235);
                                    $ExternalRef = "$code_warning : $Description_warning";
                                    $ExternalRef = '' if ($ExternalRef eq ' : ') ;
                                    
                                   }else {
                                    eval {my $bestaat2 = $assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}->{Line}->{Warnings}[0]->{Warning}};
                                    if (!$@) {
                                         my $code_warning = $assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}->{Line}->{Warnings}[0]->{Warning}->{Code};
                                         my $Description_warning= substr($assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}->{Line}->{Warnings}[0]->{Warning}->{Description},-200);
                                         #$Description_warning = substr ($Description_warning,0,235);
                                         $ExternalRef = "$code_warning : $Description_warning";
                                         $ExternalRef = '' if ($ExternalRef eq ' : ') ;
                                        }
                                   }
                              }
                    }
                #$mail = $mail."ApArInfoInvoiceNo  $ApArInfoInvoiceNo  FlagGPS $FlagGPS LVZBaseValue $LVZBaseValue AmountsAmount_OAPART $AmountsAmount_OAPART\n";
                if ($FlagGPS ==1 and $LVZBaseValue > 0) {
                              $AmountsAmount_OAPART  =$LVZBaseValue;
                              $AmountsCurrAmount_OAPART =$LVZBaseValue;
                              $mail = $mail."ApArInfoInvoiceNo  $ApArInfoInvoiceNo  FlagGPS $FlagGPS LVZBaseValue $LVZBaseValue AmountsAmount_OAPART $AmountsAmount_OAPART\n";
                    }
                 undef $transactie_onderdeel;
                 $RoomTypeCode_alg = $GLAnalysisDim5 if ($RoomTypeCode_alg < $GLAnalysisDim5);
                 $GLAnalysisDim6  =~ s/-//g;$GLAnalysisDim6  =~ s/\s//g;
                 $GLAnalysisDim7  =~ s/-//g;$GLAnalysisDim7  =~ s/\s//g;
                 $GLAnalysisDim6= $HospitalisationStart if ($GLAnalysisDim6 eq '' or  $GLAnalysisDim6 !~ m/\d+/);
                 $GLAnalysisDim7= $HospitalisationEnd if ($GLAnalysisDim7 eq '' or  $GLAnalysisDim7 !~ m/\d+/);
                 $transactie_onderdeel = {
                         TransType => $TransType,
                         Description => substr($Description,-200),
                         Status => $Status,
                         TransDate => $TransDate,
                         ExternalRef => $ExternalRef,
                         Amounts => {
                             DcFlag => $AmountsDcFlag,
                             Amount => $AmountsAmount_OAPART,
                             CurrAmount => $AmountsCurrAmount_OAPART,
                             Value1 => $AmountsValue1,
                            },
                         GLAnalysis => {
                             Account => "$GLAnalysisAccount",
                             Dim1 => "OAPART",
                             Dim2 => $GLAnalysisDim2,
                             Dim3 => $GLAnalysisDim3,
                             Dim4 => $GLAnalysisDim4,
                             Dim5 => $RoomTypeCode_alg,
                             Dim6 => $GLAnalysisDim6,
                             Dim7 => $GLAnalysisDim7,
                             Currency => "$GLAnalysisCurrency",
                             TaxCode => "$GLAnalysisTaxCode",
                             TaxSystem => "$GLAnalysisTaxSystem",
                            },
                         ApArInfo => {
                             ApArType => "$ApArInfoApArType",
                             ApArNo => "$ApArInfoApArNo",
                             InvoiceNo => "$ApArInfoInvoiceNo",
                             DueDate => "$ApArInfoDueDate",
                            }
                        };
                 push (@Transaction,$transactie_onderdeel);
                 undef $transactie_onderdeel;
                 $transactie_onderdeel = {
                         TransType => $TransType,
                         Description => substr($Description,-200),
                         Status => $Status,
                         TransDate => $TransDate,
                         ExternalRef => $ExternalRef,
                         Amounts => {
                             DcFlag => $AmountsDcFlag,
                             Amount =>  $AmountsAmount_PatientPart,
                             CurrAmount => $AmountsCurrAmount_PatientPart,
                             Value1 => $AmountsValue1,
                            },
                         GLAnalysis => {
                             Account => "$GLAnalysisAccount",
                             Dim1 => "PatientPart",
                             Dim2 => $GLAnalysisDim2,
                             Dim3 => $GLAnalysisDim3,
                             Dim4 => $GLAnalysisDim4,
                             Dim5 => $RoomTypeCode_alg,
                             Dim6 => $GLAnalysisDim6,
                             Dim7 => $GLAnalysisDim7,
                             Currency => "$GLAnalysisCurrency",
                             TaxCode => "$GLAnalysisTaxCode",
                             TaxSystem => "$GLAnalysisTaxSystem",
                            },
                         ApArInfo => {
                             ApArType => "$ApArInfoApArType",
                             ApArNo => "$ApArInfoApArNo",
                             InvoiceNo => "$ApArInfoInvoiceNo",
                             DueDate => "$ApArInfoDueDate",
                            }
                        };
                 push (@Transaction,$transactie_onderdeel);
                 undef $transactie_onderdeel;
                 $transactie_onderdeel = {
                         TransType => $TransType,
                         Description => substr($Description,-200),
                         Status => $Status,
                         TransDate => $TransDate,
                         ExternalRef => $ExternalRef,
                         Amounts => {
                             DcFlag => $AmountsDcFlag,
                             Amount =>  $AmountsAmount_Overcharges,
                             CurrAmount => $AmountsCurrAmount_Overcharges,
                             Number1 => $AmountsNumber1,
                             Value1 => $AmountsValue1,
                            },
                         GLAnalysis => {
                             Account => "$GLAnalysisAccount",
                             Dim1 => "Overcharges",
                             Dim2 => $GLAnalysisDim2,
                             Dim3 => $GLAnalysisDim3,
                             Dim4 => $GLAnalysisDim4,
                             Dim5 => $RoomTypeCode_alg,
                             Dim6 => $GLAnalysisDim6,
                             Dim7 => $GLAnalysisDim7,
                             Currency => "$GLAnalysisCurrency",
                             TaxCode => "$GLAnalysisTaxCode",
                             TaxSystem => "$GLAnalysisTaxSystem",
                            },
                         ApArInfo => {
                             ApArType => "$ApArInfoApArType",
                             ApArNo => "$ApArInfoApArNo",
                             InvoiceNo => "$ApArInfoInvoiceNo",
                             DueDate => "$ApArInfoDueDate",
                            }
                        };
                 push (@Transaction,$transactie_onderdeel);
                }else {
                     #geen Group array wel Line array
                     foreach my $volgnr_Line (keys @{$assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}->{Line}}) {
                         $AmountsValue1 = $assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}->{Line}[$volgnr_Line]->{Id};
                         $GLAnalysisDim4 = 0;
                         $Description ='';
                         $AmountsAmount_OAPART =0;
                         $AmountsCurrAmount_OAPART= $AmountsAmount_OAPART; 
                         $AmountsAmount_PatientPart =0;
                         $AmountsCurrAmount_PatientPart= $AmountsAmount_PatientPart;
                         $AmountsAmount_Overcharges =0;
                         $AmountsCurrAmount_Overcharges= $AmountsAmount_Overcharges;
                         my $LVZBaseValue =0;
                         my $FlagGPS=0;
                         foreach my $volgnr_Col (keys @{$assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}->{Line}[$volgnr_Line]->{Col}}) {
                             if ($assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{Type} eq "OAPart") {
                                 $AmountsAmount_OAPART = $assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{content};#code
                                 $AmountsCurrAmount_OAPART= $AmountsAmount_OAPART;                                 
                                }
                             if ($assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{Type} eq "PatientPart") {
                                 $AmountsAmount_PatientPart = $assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{content};#code
                                 $AmountsCurrAmount_PatientPart= $AmountsAmount_PatientPart;        #code
                                }
                             if ($assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{Type} eq "Overcharges") {
                                 $AmountsAmount_Overcharges = $assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{content};#code
                                 $AmountsCurrAmount_Overcharges= $AmountsAmount_Overcharges;        #code
                                }
                             if ($assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{Type} eq "INAMICode") {
                                 $GLAnalysisDim2=$assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{content};
                                }
                             if ($assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{Type} eq "ServiceIdentifier") {
                                 if ($GLAnalysisDim4_eerste eq 'JA') {
                                     $GLAnalysisDim4 = $assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{content};
                                     $GLAnalysisDim4_eerste = 'NEE';
                                     $GLAnalysisDim4_laagste = $GLAnalysisDim4;
                                    }else {
                                      my $GLAnalysisDim4_test = $assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{content};
                                      if ($GLAnalysisDim4_test < $GLAnalysisDim4_laagste) {
                                         $GLAnalysisDim4_laagste = $GLAnalysisDim4_test;#code
                                        }
                                    } 
                                }
                             if ($assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{Type} eq "RoomTypeCode") {
                                 $GLAnalysisDim5=$assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{content};
                                }
                             if ($assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{Type} eq "StartDate") {
                                 $GLAnalysisDim6=$assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{content};
                                 $GLAnalysisDim6  =~ s/-//g;$GLAnalysisDim6  =~ s/\s//g;
                                }
                             if ($assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{Type} eq "EndDate") {
                                 $GLAnalysisDim7=$assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{content};
                                 $GLAnalysisDim7  =~ s/-//g;$GLAnalysisDim7  =~ s/\s//g;
                                }
                             if ($assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{Type} eq "Quantity") {
                                 $AmountsNumber1 =$assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{content};
                                }
                             if ($assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{Type} eq "Type") {
                                 $Description =$assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{content};
                                }
                              if ($assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{Type} eq "FlagGPS") {
                                 $FlagGPS =$assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{content};
                                }
                             if ($assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{Type} eq "LVZBaseValue") {
                                 $LVZBaseValue =$assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{content};
                                }
                              eval {my $bestaat = $assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}->{Line}[$volgnr_Line]->{Warnings}};
                             if (!$@) {
                               eval {my $bestaat1 = $assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}->{Line}[$volgnr_Line]->{Warnings}->{Warning}};
                               if (!$@) {
                                    my $code_warning = $assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}->{Line}[$volgnr_Line]->{Warnings}->{Warning}->{Code};
                                    my $Description_warning= substr($assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}->{Line}[$volgnr_Line]->{Warnings}->{Warning}->{Description},-200);
                                    #$Description_warning = substr ($Description_warning,0,235);
                                    $ExternalRef = "$code_warning : $Description_warning";
                                     $ExternalRef = '' if ($ExternalRef eq ' : ') ;
                                   }else {
                                    eval {my $bestaat2 = $assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}->{Line}[$volgnr_Line]->{Warnings}[0]->{Warning}};
                                    if (!$@) {
                                         my $code_warning = $assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}->{Line}[$volgnr_Line]->{Warnings}[0]->{Warning}->{Code};
                                         my $Description_warning= substr($assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}->{Line}[$volgnr_Line]->{Warnings}[0]->{Warning}->{Description},-200);
                                         #$Description_warning = substr ($Description_warning,0,235);
                                         $ExternalRef = "$code_warning : $Description_warning";
                                          $ExternalRef = '' if ($ExternalRef eq ' : ') ;
                                        }
                                   }
                              }
                            }
                         #$mail = $mail."ApArInfoInvoiceNo  $ApArInfoInvoiceNo  FlagGPS $FlagGPS LVZBaseValue $LVZBaseValue AmountsAmount_OAPART $AmountsAmount_OAPART\n";
                         if ($FlagGPS ==1 and $LVZBaseValue > 0) {
                              $AmountsAmount_OAPART  =$LVZBaseValue;
                              $AmountsCurrAmount_OAPART =$LVZBaseValue;
                              $mail = $mail."ApArInfoInvoiceNo  $ApArInfoInvoiceNo  FlagGPS $FlagGPS LVZBaseValue $LVZBaseValue AmountsAmount_OAPART $AmountsAmount_OAPART\n";
                         }
                         undef $transactie_onderdeel;
                         $GLAnalysisDim6  =~ s/-//g;$GLAnalysisDim6  =~ s/\s//g;
                         $GLAnalysisDim7  =~ s/-//g;$GLAnalysisDim7  =~ s/\s//g;
                         $GLAnalysisDim6= $HospitalisationStart if ($GLAnalysisDim6 eq '' or  $GLAnalysisDim6 !~ m/\d+/);
                         $GLAnalysisDim7= $HospitalisationEnd if ($GLAnalysisDim7 eq '' or  $GLAnalysisDim7 !~ m/\d+/);
                         $transactie_onderdeel = {
                             TransType => $TransType,
                             Description => substr($Description,-200),
                             Status => $Status,
                             TransDate => $TransDate,
                             ExternalRef => $ExternalRef,
                             Amounts => {
                                 DcFlag => $AmountsDcFlag,
                                 Amount => $AmountsAmount_OAPART,
                                 CurrAmount => $AmountsCurrAmount_OAPART,
                                 Value1 => $AmountsValue1,
                                },
                         GLAnalysis => {
                             Account => "$GLAnalysisAccount",
                             Dim1 => "OAPART",
                             Dim2 => $GLAnalysisDim2,
                             Dim3 => $GLAnalysisDim3,
                             Dim4 => $GLAnalysisDim4,
                             Dim5 => $RoomTypeCode_alg,
                             Dim6 => $GLAnalysisDim6,
                             Dim7 => $GLAnalysisDim7,
                             Currency => "$GLAnalysisCurrency",
                             TaxCode => "$GLAnalysisTaxCode",
                             TaxSystem => "$GLAnalysisTaxSystem",
                            },
                         ApArInfo => {
                             ApArType => "$ApArInfoApArType",
                             ApArNo => "$ApArInfoApArNo",
                             InvoiceNo => "$ApArInfoInvoiceNo",
                             DueDate => "$ApArInfoDueDate",
                            }
                          };
                         push (@Transaction,$transactie_onderdeel);
                         undef $transactie_onderdeel;
                         $transactie_onderdeel = {
                             TransType => $TransType,
                             Description => substr($Description,-200),
                             Status => $Status,
                             TransDate => $TransDate,
                             ExternalRef => $ExternalRef,
                             Amounts => {
                                 DcFlag => $AmountsDcFlag,
                                 Amount =>  $AmountsAmount_PatientPart,
                                 CurrAmount => $AmountsCurrAmount_PatientPart,
                                 Value1 => $AmountsValue1,
                                },
                             GLAnalysis => {
                                 Account => "$GLAnalysisAccount",
                                 Dim1 => "PatientPart",
                                 Dim2 => $GLAnalysisDim2,
                                 Dim3 => $GLAnalysisDim3,
                                 Dim4 => $GLAnalysisDim4,
                                 Dim5 => $RoomTypeCode_alg,
                                 Dim6 => $GLAnalysisDim6,
                                 Dim7 => $GLAnalysisDim7,
                                 Currency => "$GLAnalysisCurrency",
                                 TaxCode => "$GLAnalysisTaxCode",
                                 TaxSystem => "$GLAnalysisTaxSystem",
                                },
                             ApArInfo => {
                                 ApArType => "$ApArInfoApArType",
                                 ApArNo => "$ApArInfoApArNo",
                                 InvoiceNo => "$ApArInfoInvoiceNo",
                                 DueDate => "$ApArInfoDueDate",
                                }
                           };
                         push (@Transaction,$transactie_onderdeel);
                         undef $transactie_onderdeel;
                         $transactie_onderdeel = {
                             TransType => $TransType,
                             Description => substr($Description,-200),
                             Status => $Status,
                             TransDate => $TransDate,
                             ExternalRef => $ExternalRef,
                             Amounts => {
                                 DcFlag => $AmountsDcFlag,
                                 Amount =>  $AmountsAmount_Overcharges,
                                 CurrAmount => $AmountsCurrAmount_Overcharges,
                                 Number1 => $AmountsNumber1,
                                 Value1 => $AmountsValue1,
                                },
                             GLAnalysis => {
                                 Account => "$GLAnalysisAccount",
                                 Dim1 => "Overcharges",
                                 Dim2 => $GLAnalysisDim2,
                                 Dim3 => $GLAnalysisDim3,
                                 Dim4 => $GLAnalysisDim4,
                                 Dim5 => $RoomTypeCode_alg,
                                 Dim6 => $GLAnalysisDim6,
                                 Dim7 => $GLAnalysisDim7,
                                 Currency => "$GLAnalysisCurrency",
                                 TaxCode => "$GLAnalysisTaxCode",
                                 TaxSystem => "$GLAnalysisTaxSystem",
                                },
                             ApArInfo => {
                                 ApArType => "$ApArInfoApArType",
                                 ApArNo => "$ApArInfoApArNo",
                                 InvoiceNo => "$ApArInfoInvoiceNo",
                                 DueDate => "$ApArInfoDueDate",
                                }
                            };
                         push (@Transaction,$transactie_onderdeel);
                        }
                    }
            }else {
             #wel Group array
             foreach my $volgnr_Group (keys @{$assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}}) {
                 eval {foreach my $volgnr_Line (keys @{$assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}[$volgnr_Group]->{Line}}) { }};
                 if ($@) {
                     #wel Group array geen Line array
                     $AmountsValue1 = $assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}[$volgnr_Group]->{Line}->{Id};
                     $GLAnalysisDim4 = 0;
                     $AmountsAmount_OAPART =0;
                     $AmountsCurrAmount_OAPART= $AmountsAmount_OAPART; 
                     $AmountsAmount_PatientPart =0;
                     $AmountsCurrAmount_PatientPart= $AmountsAmount_PatientPart;
                     $AmountsAmount_Overcharges =0;
                     $AmountsCurrAmount_Overcharges= $AmountsAmount_Overcharges;
                     my $LVZBaseValue=0;
                     my $FlagGPS=0;
                     foreach my $volgnr_Col (keys @{$assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}[$volgnr_Group]->{Line}->{Col}}) {
                         if ($assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}[$volgnr_Group]->{Line}->{Col}[$volgnr_Col]->{Type} eq "OAPart") {
                             $AmountsAmount_OAPART = $assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}[$volgnr_Group]->{Line}->{Col}[$volgnr_Col]->{content};#code
                             $AmountsCurrAmount_OAPART= $AmountsAmount_OAPART;                                 
                            }
                         if ($assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}[$volgnr_Group]->{Line}->{Col}[$volgnr_Col]->{Type} eq "PatientPart") {
                             $AmountsAmount_PatientPart = $assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}[$volgnr_Group]->{Line}->{Col}[$volgnr_Col]->{content};#code
                             $AmountsCurrAmount_PatientPart= $AmountsAmount_PatientPart;        #code
                            }
                         if ($assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}[$volgnr_Group]->{Line}->{Col}[$volgnr_Col]->{Type} eq "Overcharges") {
                             $AmountsAmount_Overcharges = $assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}[$volgnr_Group]->{Line}->{Col}[$volgnr_Col]->{content};#code
                             $AmountsCurrAmount_Overcharges= $AmountsAmount_Overcharges;        #code
                            }
                         if ($assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}[$volgnr_Group]->{Line}->{Col}[$volgnr_Col]->{Type} eq "INAMICode") {
                             $GLAnalysisDim2=$assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}[$volgnr_Group]->{Line}->{Col}[$volgnr_Col]->{content};
                            }
                         if ($assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}[$volgnr_Group]->{Line}->{Col}[$volgnr_Col]->{Type} eq "ServiceIdentifier") {
                             if ($GLAnalysisDim4_eerste eq 'JA') {
                                 $GLAnalysisDim4 = $assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}[$volgnr_Group]->{Line}->{Col}[$volgnr_Col]->{content};
                                 $GLAnalysisDim4_eerste = 'NEE';
                                 $GLAnalysisDim4_laagste = $GLAnalysisDim4;
                                }else {
                                 my $GLAnalysisDim4_test = $assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}[$volgnr_Group]->{Line}->{Col}[$volgnr_Col]->{content};
                                 if ($GLAnalysisDim4_test < $GLAnalysisDim4_laagste) {
                                     $GLAnalysisDim4_laagste = $GLAnalysisDim4_test;#code
                                    }
                                }
                            }
                         if ($assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}[$volgnr_Group]->{Line}->{Col}[$volgnr_Col]->{Type} eq "RoomTypeCode") {
                             $GLAnalysisDim5=$assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}[$volgnr_Group]->{Line}->{Col}[$volgnr_Col]->{content};
                            }
                         if ($assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}[$volgnr_Group]->{Line}->{Col}[$volgnr_Col]->{Type} eq "StartDate") {
                             $GLAnalysisDim6=$assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}[$volgnr_Group]->{Line}->{Col}[$volgnr_Col]->{content};
                            }
                         if ($assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}[$volgnr_Group]->{Line}->{Col}[$volgnr_Col]->{Type} eq "EndDate") {
                             $GLAnalysisDim7=$assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}[$volgnr_Group]->{Line}->{Col}[$volgnr_Col]->{content};
                             $GLAnalysisDim7  =~ s/-//g;$GLAnalysisDim7  =~ s/\s//g;
                            }
                         if ($assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}[$volgnr_Group]->{Line}->{Col}[$volgnr_Col]->{Type} eq "Quantity") {
                             $AmountsNumber1 =$assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}[$volgnr_Group]->{Line}->{Col}[$volgnr_Col]->{content};
                            }
                         if ($assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}[$volgnr_Group]->{Line}->{Col}[$volgnr_Col]->{Type} eq "Type") {
                             $Description =$assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}[$volgnr_Group]->{Line}->{Col}[$volgnr_Col]->{content};
                            }
                         if ($assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}[$volgnr_Group]->{Line}->{Col}[$volgnr_Col]->{Type} eq "FlagGPS") {
                             $FlagGPS =$assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}[$volgnr_Group]->{Line}->{Col}[$volgnr_Col]->{content};
                            }
                         if ($assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}[$volgnr_Group]->{Line}->{Col}[$volgnr_Col]->{Type} eq "LVZBaseValue") {
                             $LVZBaseValue=$assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}[$volgnr_Group]->{Line}->{Col}[$volgnr_Col]->{content};
                            }
                           eval {my $bestaat = $assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}[$volgnr_Group]->{Line}->{Warnings}};
                             if (!$@) {
                               eval {my $bestaat1 = $assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}[$volgnr_Group]->{Line}->{Warnings}->{Warning}->{Code}};
                               if (!$@) {
                                    my $code_warning = $assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}[$volgnr_Group]->{Line}->{Warnings}->{Warning}->{Code};
                                    my $Description_warning= $assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}[$volgnr_Group]->{Line}->{Warnings}->{Warning}->{Description};
                                    $Description_warning = substr ($Description_warning,0,235);
                                    $ExternalRef = "$code_warning : $Description_warning";
                                    $ExternalRef = '' if ($ExternalRef eq ' : ') ;
                                   }else {
                                    eval {my $bestaat2 = $assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}[$volgnr_Group]->{Line}->{Warnings}[0]->{Warning}->{Code}};
                                    if (!$@) {
                                         my $code_warning = $assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}[$volgnr_Group]->{Line}->{Warnings}[0]->{Warning}->{Code};
                                         my $Description_warning= $assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}[$volgnr_Group]->{Line}->{Warnings}[0]->{Warning}->{Description};
                                         $Description_warning = substr ($Description_warning,0,235);
                                         $ExternalRef = "$code_warning : $Description_warning";
                                         $ExternalRef = '' if ($ExternalRef eq ' : ') ;
                                        }else  {
                                         eval {my $bestaat2 = $assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}[$volgnr_Group]->{Line}->{Warnings}->{Warning}[0]->{Code}};
                                         if (!$@) {
                                              my $code_warning = $assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}[$volgnr_Group]->{Line}->{Warnings}->{Warning}[0]->{Code};
                                              my $Description_warning= $assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}[$volgnr_Group]->{Line}->{Warnings}->{Warning}[0]->{Description};
                                              $Description_warning = substr ($Description_warning,0,115);
                                              $ExternalRef = "$code_warning : $Description_warning";
                                              $ExternalRef = '' if ($ExternalRef eq ' : ') ;
                                              eval {my $bestaat2 = $assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}[$volgnr_Group]->{Line}->{Warnings}->{Warning}[1]->{Code}};
                                              if (!$@) {
                                                   $code_warning = $assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}[$volgnr_Group]->{Line}->{Warnings}->{Warning}[1]->{Code};
                                                   $Description_warning= $assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}[$volgnr_Group]->{Line}->{Warnings}->{Warning}[1]->{Description};
                                                   $Description_warning = substr ($Description_warning,0,115);
                                                   $ExternalRef = "$ExternalRef - $code_warning : $Description_warning";
                                                   $ExternalRef = '' if ($ExternalRef eq ' : ') ;
                                                  }
                                             }
                                        }
                                   }
                              }
                        }
                     #$mail = $mail."ApArInfoInvoiceNo  $ApArInfoInvoiceNo  FlagGPS $FlagGPS LVZBaseValue $LVZBaseValue AmountsAmount_OAPART $AmountsAmount_OAPART\n";
                     if ($FlagGPS ==1 and $LVZBaseValue > 0) {
                              $AmountsAmount_OAPART  =$LVZBaseValue;
                              $AmountsCurrAmount_OAPART =$LVZBaseValue;
                              $mail = $mail."ApArInfoInvoiceNo  $ApArInfoInvoiceNo  FlagGPS $FlagGPS LVZBaseValue $LVZBaseValue AmountsAmount_OAPART $AmountsAmount_OAPART\n";
                         }
                     undef $transactie_onderdeel;
                     $RoomTypeCode_alg = $GLAnalysisDim5 if ($RoomTypeCode_alg < $GLAnalysisDim5);
                     $GLAnalysisDim6  =~ s/-//g;$GLAnalysisDim6  =~ s/\s//g;
                     $GLAnalysisDim7  =~ s/-//g;$GLAnalysisDim7  =~ s/\s//g;
                     $GLAnalysisDim6= $HospitalisationStart if ($GLAnalysisDim6 eq '' or  $GLAnalysisDim6 !~ m/\d+/);
                     $GLAnalysisDim7= $HospitalisationEnd if ($GLAnalysisDim7 eq '' or  $GLAnalysisDim7 !~ m/\d+/);
                     $transactie_onderdeel = {
                         TransType => $TransType,
                         Description => substr($Description,-200),
                         Status => $Status,
                         TransDate => $TransDate,
                         ExternalRef => $ExternalRef,
                         Amounts => {
                             DcFlag => $AmountsDcFlag,
                             Amount => $AmountsAmount_OAPART,
                             CurrAmount => $AmountsCurrAmount_OAPART,
                             Value1 => $AmountsValue1,
                            },
                         GLAnalysis => {
                             Account => "$GLAnalysisAccount",
                             Dim1 => "OAPART",
                             Dim2 => $GLAnalysisDim2,
                             Dim3 => $GLAnalysisDim3,
                             Dim4 => $GLAnalysisDim4,
                             Dim5 => $RoomTypeCode_alg,
                             Dim6 => $GLAnalysisDim6,
                             Dim7 => $GLAnalysisDim7,
                             Currency => "$GLAnalysisCurrency",
                             TaxCode => "$GLAnalysisTaxCode",
                             TaxSystem => "$GLAnalysisTaxSystem",
                            },
                         ApArInfo => {
                             ApArType => "$ApArInfoApArType",
                             ApArNo => "$ApArInfoApArNo",
                             InvoiceNo => "$ApArInfoInvoiceNo",
                             DueDate => "$ApArInfoDueDate",
                            }
                        };
                     push (@Transaction,$transactie_onderdeel);
                     undef $transactie_onderdeel;
                     $transactie_onderdeel = {
                         TransType => $TransType,
                         Description => substr($Description,-200),
                         Status => $Status,
                         TransDate => $TransDate,
                         ExternalRef => $ExternalRef,
                         Amounts => {
                             DcFlag => $AmountsDcFlag,
                             Amount =>  $AmountsAmount_PatientPart,
                             CurrAmount => $AmountsCurrAmount_PatientPart,
                             Value1 => $AmountsValue1,
                            },
                         GLAnalysis => {
                             Account => "$GLAnalysisAccount",
                             Dim1 => "PatientPart",
                             Dim2 => $GLAnalysisDim2,
                             Dim3 => $GLAnalysisDim3,
                             Dim4 => $GLAnalysisDim4,
                             Dim5 => $RoomTypeCode_alg,
                             Dim6 => $GLAnalysisDim6,
                              Dim7 => $GLAnalysisDim7,
                             Currency => "$GLAnalysisCurrency",
                             TaxCode => "$GLAnalysisTaxCode",
                             TaxSystem => "$GLAnalysisTaxSystem",
                            },
                         ApArInfo => {
                             ApArType => "$ApArInfoApArType",
                             ApArNo => "$ApArInfoApArNo",
                             InvoiceNo => "$ApArInfoInvoiceNo",
                             DueDate => "$ApArInfoDueDate",
                            }
                        };
                     push (@Transaction,$transactie_onderdeel);
                     undef $transactie_onderdeel;
                     $transactie_onderdeel = {
                         TransType => $TransType,
                         Description => substr($Description,-200),
                         Status => $Status,
                         TransDate => $TransDate,
                         ExternalRef => $ExternalRef,
                         Amounts => {
                             DcFlag => $AmountsDcFlag,
                             Amount =>  $AmountsAmount_Overcharges,
                             CurrAmount => $AmountsCurrAmount_Overcharges,
                             Number1 => $AmountsNumber1,
                             Value1 => $AmountsValue1,
                            },
                         GLAnalysis => {
                             Account => "$GLAnalysisAccount",
                             Dim1 => "Overcharges",
                             Dim2 => $GLAnalysisDim2,
                             Dim3 => $GLAnalysisDim3,
                             Dim4 => $GLAnalysisDim4,
                             Dim5 => $RoomTypeCode_alg,
                             Dim6 => $GLAnalysisDim6,
                             Dim7 => $GLAnalysisDim7,
                             Currency => "$GLAnalysisCurrency",
                             TaxCode => "$GLAnalysisTaxCode",
                             TaxSystem => "$GLAnalysisTaxSystem",
                            },
                         ApArInfo => {
                             ApArType => "$ApArInfoApArType",
                             ApArNo => "$ApArInfoApArNo",
                             InvoiceNo => "$ApArInfoInvoiceNo",
                             DueDate => "$ApArInfoDueDate",
                            }
                        };
                     push (@Transaction,$transactie_onderdeel);
                    }else {
                     #wel Group array wel Line array
                     foreach my $volgnr_Line (keys @{$assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}[$volgnr_Group]->{Line}}) {
                         $AmountsValue1 = $assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}[$volgnr_Group]->{Line}[$volgnr_Line]->{Id};
                         $GLAnalysisDim4 = 0;
                         $AmountsAmount_OAPART =0;
                         $AmountsCurrAmount_OAPART= $AmountsAmount_OAPART; 
                         $AmountsAmount_PatientPart =0;
                         $AmountsCurrAmount_PatientPart= $AmountsAmount_PatientPart;
                         $AmountsAmount_Overcharges =0;
                         $AmountsCurrAmount_Overcharges= $AmountsAmount_Overcharges;
                         my $LVZBaseValue =0;
                         my $FlagGPS = 0;
                         foreach my $volgnr_Col (keys @{$assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}[$volgnr_Group]->{Line}[$volgnr_Line]->{Col}}) {
                             if ($assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}[$volgnr_Group]->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{Type} eq "OAPart") {
                                 $AmountsAmount_OAPART = $assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}[$volgnr_Group]->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{content};#code
                                 $AmountsCurrAmount_OAPART= $AmountsAmount_OAPART;                                 
                                }
                             if ($assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}[$volgnr_Group]->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{Type} eq "PatientPart") {
                                 $AmountsAmount_PatientPart = $assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}[$volgnr_Group]->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{content};#code
                                 $AmountsCurrAmount_PatientPart= $AmountsAmount_PatientPart;        #code
                                }
                             if ($assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}[$volgnr_Group]->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{Type} eq "Overcharges") {
                                 $AmountsAmount_Overcharges = $assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}[$volgnr_Group]->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{content};#code
                                 $AmountsCurrAmount_Overcharges= $AmountsAmount_Overcharges;        #code
                                }
                             if ($assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}[$volgnr_Group]->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{Type} eq "INAMICode") {
                                 $GLAnalysisDim2=$assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}[$volgnr_Group]->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{content};
                                }
                             if ($assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}[$volgnr_Group]->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{Type} eq "ServiceIdentifier") {
                                 if ($GLAnalysisDim4_eerste eq 'JA') {
                                     $GLAnalysisDim4 = $assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}[$volgnr_Group]->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{content};
                                     $GLAnalysisDim4_eerste = 'NEE';
                                     $GLAnalysisDim4_laagste = $GLAnalysisDim4;
                                    }else {
                                     my $GLAnalysisDim4_test = $assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}[$volgnr_Group]->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{content};
                                     if ($GLAnalysisDim4_test < $GLAnalysisDim4_laagste) {
                                         $GLAnalysisDim4_laagste = $GLAnalysisDim4_test;#code
                                        }
                                    }
                                }
                             if ($assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}[$volgnr_Group]->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{Type} eq "RoomTypeCode") {
                                 $GLAnalysisDim5=$assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}[$volgnr_Group]->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{content};
                                }
                             if ($assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}[$volgnr_Group]->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{Type} eq "StartDate") {
                                 $GLAnalysisDim6=$assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}[$volgnr_Group]->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{content};
                                 $GLAnalysisDim6  =~ s/-//g;$GLAnalysisDim6  =~ s/\s//g;
                                }
                             if ($assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}[$volgnr_Group]->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{Type} eq "EndDate") {
                                 $GLAnalysisDim7=$assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}[$volgnr_Group]->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{content};
                                 $GLAnalysisDim7  =~ s/-//g;$GLAnalysisDim7  =~ s/\s//g;
                                }
                             if ($assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}[$volgnr_Group]->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{Type} eq "Quantity") {
                                 $AmountsNumber1 =$assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}[$volgnr_Group]->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{content};
                                }
                             if ($assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}[$volgnr_Group]->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{Type} eq "Type") {
                                 $Description =$assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}[$volgnr_Group]->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{content};
                                }
                             if ($assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}[$volgnr_Group]->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{Type} eq "FlagGPS") {
                                 $FlagGPS =$assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}[$volgnr_Group]->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{content};
                                }
                             if ($assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}[$volgnr_Group]->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{Type} eq "LVZBaseValue") {
                                 $LVZBaseValue =$assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}[$volgnr_Group]->{Line}[$volgnr_Line]->{Col}[$volgnr_Col]->{content};
                                }
                              eval {my $bestaat = $assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}[$volgnr_Group]->{Line}[$volgnr_Line]->{Warnings}};
                             if (!$@) {
                               eval {my $bestaat1 = $assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}[$volgnr_Group]->{Line}[$volgnr_Line]->{Warnings}->{Warning}->{Code}};
                               if (!$@) {
                                    my $code_warning = $assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}[$volgnr_Group]->{Line}[$volgnr_Line]->{Warnings}->{Warning}->{Code};
                                    my $Description_warning= substr($assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}[$volgnr_Group]->{Line}[$volgnr_Line]->{Warnings}->{Warning}->{Description},-200);
                                    #$Description_warning = substr ($Description_warning,0,235);
                                    $ExternalRef = "$code_warning : $Description_warning";
                                     $ExternalRef = '' if ($ExternalRef eq ' : ') ;
                                   }else {
                                    eval {my $bestaat2 = $assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}[$volgnr_Group]->{Line}[$volgnr_Line]->{Warnings}[0]->{Warning}->{Code}};
                                    if (!$@) {
                                         my $code_warning = $assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}[$volgnr_Group]->{Line}[$volgnr_Line]->{Warnings}[0]->{Warning}->{Code};
                                         my $Description_warning= substr($assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}[$volgnr_Group]->{Line}[$volgnr_Line]->{Warnings}[0]->{Warning}->{Description},-200);
                                         #$Description_warning = substr ($Description_warning,0,235);
                                         $ExternalRef = "$code_warning : $Description_warning";
                                          $ExternalRef = '' if ($ExternalRef eq ' : ') ;
                                        }else  {
                                         eval {my $bestaat2 = $assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}[$volgnr_Group]->{Line}[$volgnr_Line]->{Warnings}->{Warning}[0]->{Code}};
                                         if (!$@) {
                                              my $code_warning = $assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}[$volgnr_Group]->{Line}[$volgnr_Line]->{Warnings}->{Warning}[0]->{Code};
                                              my $Description_warning= $assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}[$volgnr_Group]->{Line}[$volgnr_Line]->{Warnings}->{Warning}[0]->{Description};
                                              $Description_warning = substr ($Description_warning,0,115);
                                              $ExternalRef = "$code_warning : $Description_warning";
                                              $ExternalRef = '' if ($ExternalRef eq ' : ') ;
                                              eval {my $bestaat2 = $assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}[$volgnr_Group]->{Line}[$volgnr_Line]->{Warnings}->{Warning}[1]->{Code}};
                                              if (!$@) {
                                                   $code_warning = $assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}[$volgnr_Group]->{Line}[$volgnr_Line]->{Warnings}->{Warning}[1]->{Code};
                                                   $Description_warning= $assurcard->{Invoice}[$volgnr_invoice]->{Groups}->{Group}[$volgnr_Group]->{Line}[$volgnr_Line]->{Warnings}->{Warning}[1]->{Description};
                                                   $Description_warning = substr ($Description_warning,0,115);
                                                   $ExternalRef = "$ExternalRef - $code_warning : $Description_warning";
                                                   $ExternalRef = '' if ($ExternalRef eq ' : ') ;
                                                  }
                                             }
                                        }
                                   }
                              }
                            }
                         #$mail = $mail."ApArInfoInvoiceNo  $ApArInfoInvoiceNo  FlagGPS $FlagGPS LVZBaseValue $LVZBaseValue AmountsAmount_OAPART $AmountsAmount_OAPART\n";
                          if ($FlagGPS ==1 and $LVZBaseValue > 0) {
                              $AmountsAmount_OAPART  =$LVZBaseValue;
                              $AmountsCurrAmount_OAPART =$LVZBaseValue;
                              $mail = $mail."ApArInfoInvoiceNo  $ApArInfoInvoiceNo  FlagGPS $FlagGPS LVZBaseValue $LVZBaseValue AmountsAmount_OAPART $AmountsAmount_OAPART\n"; 
                         }
                         
                         undef $transactie_onderdeel;
                         $RoomTypeCode_alg = $GLAnalysisDim5 if ($RoomTypeCode_alg < $GLAnalysisDim5);
                         $GLAnalysisDim6  =~ s/-//g;$GLAnalysisDim6  =~ s/\s//g;
                         $GLAnalysisDim7  =~ s/-//g;$GLAnalysisDim7  =~ s/\s//g;
                         $GLAnalysisDim6= $HospitalisationStart if ($GLAnalysisDim6 eq '' or  $GLAnalysisDim6 !~ m/\d+/);
                         $GLAnalysisDim7= $HospitalisationEnd if ($GLAnalysisDim7 eq '' or  $GLAnalysisDim7 !~ m/\d+/);
                         $transactie_onderdeel = {
                             TransType => $TransType,
                             Description => substr($Description,-200),
                             Status => $Status,
                             TransDate => $TransDate,
                             ExternalRef => $ExternalRef,
                             Amounts => {
                                 DcFlag => $AmountsDcFlag,
                                 Amount => $AmountsAmount_OAPART,
                                 CurrAmount => $AmountsCurrAmount_OAPART,
                                 Value1 => $AmountsValue1,
                                },
                             GLAnalysis => {
                                 Account => "$GLAnalysisAccount",
                                 Dim1 => "OAPART",
                                 Dim2 => $GLAnalysisDim2,
                                 Dim3 => $GLAnalysisDim3,
                                 Dim4 => $GLAnalysisDim4,
                                 Dim5 => $RoomTypeCode_alg,
                                 Dim6 => $GLAnalysisDim6,
                                 Dim7 => $GLAnalysisDim7,
                                 Currency => "$GLAnalysisCurrency",
                                 TaxCode => "$GLAnalysisTaxCode",
                                 TaxSystem => "$GLAnalysisTaxSystem",
                                },
                             ApArInfo => {
                                 ApArType => "$ApArInfoApArType",
                                 ApArNo => "$ApArInfoApArNo",
                                 InvoiceNo => "$ApArInfoInvoiceNo",
                                 DueDate => "$ApArInfoDueDate",
                                }
                            };
                         push (@Transaction,$transactie_onderdeel);
                         undef $transactie_onderdeel;
                         $transactie_onderdeel = {
                         TransType => $TransType,
                         Description => substr($Description,-200),
                         Status => $Status,
                         TransDate => $TransDate,
                         ExternalRef => $ExternalRef,
                         Amounts => {
                             DcFlag => $AmountsDcFlag,
                             Amount =>  $AmountsAmount_PatientPart,
                             CurrAmount => $AmountsCurrAmount_PatientPart,
                             Value1 => $AmountsValue1,
                            },
                         GLAnalysis => {
                             Account => "$GLAnalysisAccount",
                             Dim1 => "PatientPart",
                             Dim2 => $GLAnalysisDim2,
                             Dim3 => $GLAnalysisDim3,
                             Dim4 => $GLAnalysisDim4,
                             Dim5 => $RoomTypeCode_alg,
                             Dim6 => $GLAnalysisDim6,
                             Dim7 => $GLAnalysisDim7,
                             Currency => "$GLAnalysisCurrency",
                             TaxCode => "$GLAnalysisTaxCode",
                             TaxSystem => "$GLAnalysisTaxSystem",
                            },
                         ApArInfo => {
                             ApArType => "$ApArInfoApArType",
                             ApArNo => "$ApArInfoApArNo",
                             InvoiceNo => "$ApArInfoInvoiceNo",
                             DueDate => "$ApArInfoDueDate",
                            }
                        };
                         push (@Transaction,$transactie_onderdeel);
                         undef $transactie_onderdeel;
                         $transactie_onderdeel = {
                         TransType => $TransType,
                         Description => substr($Description,-200),
                         Status => $Status,
                         TransDate => $TransDate,
                         ExternalRef => $ExternalRef,
                         Amounts => {
                             DcFlag => $AmountsDcFlag,
                             Amount =>  $AmountsAmount_Overcharges,
                             CurrAmount => $AmountsCurrAmount_Overcharges,
                             Number1 => $AmountsNumber1,
                             Value1 => $AmountsValue1,
                            },
                         GLAnalysis => {
                             Account => "$GLAnalysisAccount",
                             Dim1 => "Overcharges",
                             Dim2 => $GLAnalysisDim2,
                             Dim3 => $GLAnalysisDim3,
                             Dim4 => $GLAnalysisDim4,
                             Dim5 => $RoomTypeCode_alg,
                             Dim6 => $GLAnalysisDim6,
                             Dim7 => $GLAnalysisDim7,
                             Currency => "$GLAnalysisCurrency",
                             TaxCode => "$GLAnalysisTaxCode",
                             TaxSystem => "$GLAnalysisTaxSystem",
                            },
                         ApArInfo => {
                             ApArType => "$ApArInfoApArType",
                             ApArNo => "$ApArInfoApArNo",
                             InvoiceNo => "$ApArInfoInvoiceNo",
                             DueDate => "$ApArInfoDueDate",
                            }
                        };
                         push (@Transaction,$transactie_onderdeel);
                        }
                     
                    }
                }
            }
        }
}
   

sub load_agresso_setting_invoice  {
     my $file_name = shift @_;
     $agresso_instellingen = XMLin("$file_name");
     print "ingelezen\n";
     #maak verzekeringen
    
    }
sub maak_batch_id_invoice {
     my $filename = shift @_;
     $filename =~ m/\d{8}\.\d{6}/;
     my $batch_id = $&;
     return ($batch_id);
}
sub maak_xml_invoice {
     my $xsd ='D:\OGV\ASSURCARD_2023\asurcard_xsd\agresso\ABWTransaction-har.xsd';
     my $schema = XML::Compile::Schema->new($xsd);                      
     $schema->importDefinitions('D:\OGV\ASSURCARD_2023\asurcard_xsd\agresso\ABWSchemaLib-har.xsd');#,
         #target_namespace     =>"http://services.agresso.com/schema/ABWSchemaLib/2011/11/14",  
         #element_form_default => 'qualified',
         #attribute_form_default => "unqualified");
        #$schema->printIndex();
         warn $schema->template('PERL','ABWTransaction');
         my $doc    = XML::LibXML::Document->new('1.0', 'UTF-8');
         my $write  = $schema->compile(WRITER => 'ABWTransaction');
         my $xml    = $write->($doc, $ABWTransaction);
         #my $xml_file = "D:\\agressosoap\\test_invoice.xml";
         my $xml_file = "$agresso_instellingen->{plaats_file}\\assurcard_agresso_invoice.$vandaag.$tijd.$xml_file_teller.xml";    
         unlink $xml_file ;
         $doc->setDocumentElement($xml);
         open XMLFILE,"> $xml_file" or die "can not open file $xml_file ";
         select XMLFILE;
         print $doc->toString(1); # 1 indicates "pretty print"
         close XMLFILE;
         select STDOUT; 
}
sub modulo_97_invoice {
     my $mededeling = shift @_;
     $mededeling =~ s/-//g;
     $mededeling =~ s/\s//g;
     $mededeling =~ s/\*//g;
     $mededeling =~ s%/%%g;
     $mededeling =~ s/\+//g;
     my $is_a_number = looks_like_number ($mededeling);
     if ($is_a_number) {
         my $lengte = length ($mededeling);
         if ($lengte == 12) {
             my $getal = substr($mededeling,0,10);#code
             my $test_getal = substr($mededeling,10,2);#code
             my $rest = $getal % 97;
             $rest= 97 if ($rest==0);
             if ($rest == $test_getal ) {
                 return ($mededeling);  
             }else {
                 #return ($mededeling); #modules 97 uitgezet
                 return ('');
                }
             
            }else {
              #return ($mededeling); #modules 97 uitgezet
             return ('');
            }
         
        }else {
          #return ($mededeling); #modules 97 uitgezet
         return ('');
     }
     
     
}
sub verander_xml_file_invoice {
     $cdata='';
     $cdata= read_file("$agresso_instellingen->{plaats_file}\\assurcard_agresso_invoice.$vandaag.$tijd.$xml_file_teller.xml");
     my $xml_intro = '<?xml version="1.0" encoding="UTF-8"?>';
     my $old_header ='<ABWTransaction xmlns:agrlib="http://services.agresso.com/schema/ABWSchemaLib/2011/11/14">';
     my $header = '<ABWTransaction xsi:schemaLocation="http://services.agresso.com/schema/ABWTransaction/2011/11/14 http://services.agresso.com/schema/ABWTransaction/2011/11/14/ABWTransaction.xsd" xmlns="http://services.agresso.com/schema/ABWTransaction/2011/11/14" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:agrlib="http://services.agresso.com/schema/ABWSchemaLib/2011/11/14">';
     $cdata=~ s/\<\?xml version=\"1\.0\" encoding=\"UTF-8\"\?>\n//;
     $cdata=~ s%$old_header%<imp:Xml><![CDATA[$header%;
     $cdata=~ s%</ABWTransaction>$%</ABWTransaction>]]></imp:Xml>%;
     #versie 2.1  rare tekens Het is inderdaad het beste dat jij deze ë vervangt door een e. Misschien ook é, è, à en ç.
     $cdata=~ s/ë/e/g;
     $cdata=~ s/é/e/g;
     $cdata=~ s/è/e/g;
     $cdata=~ s/à/a/g;
     $cdata=~ s/ç/c/g;
     #print "\n$cdata\n";
     #print "";
}
sub send_via_webserv_client_invoice {
     my $origniele_xml = shift @_;
     my $plaats_verwerkt = $agresso_instellingen->{plaats_invoices_verwerkt_P};
     use SOAP::Lite 
     +trace => [ transport => sub { print $_[0]->as_string } ];
     use XML::Compile::SOAP12::Client;
     use XML::Writer;
     use XML::Writer::String;
     $ENV{HTTPS_DEBUG} = 1;
     $ENV{HTTP_DEBUG} = 1;
     my $serverProcessId = 'GL07';
     my $menuId = 'BI88';
     my $variant = 14;
     my $username = 'WEBSERV';
     my $client = 'VMOB';
     my $password = 'WEBSERV';
     my $agresso_proxy = $main::agresso_instellingen->{"Agresso_IP_$main::mode"};
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
     my $soap = SOAP::Lite
     #-> proxy('http://10.198.205.8/AgressoWSHost/service.svc?ImportService/ImportV200606')
     -> proxy("http://$agresso_proxy/service.svc?ImportService/ImportV200606") #productie
     #-> proxy('http://10.198.206.217/AgressoWSHost/service.svc?ImportService/ImportV200606')
     ->ns('http://services.agresso.com/ImportService/ImportV200606','imp')
     ->on_action( sub { return 'ExecuteServerProcessAsynchronously' } );
     my $response = $soap->ExecuteServerProcessAsynchronously($Input,$Credentials);    
     my $antwoord ='';
     my $ordernr = $response->{_content}[4]->{Body}->{ExecuteServerProcessAsynchronouslyResponse}
     ->{ExecuteServerProcessAsynchronouslyResult}->{OrderNumber};
     my $fault = $response->{_content}[4]->{Body}->{Fault}->{faultstring};
     if ($ordernr =~ m/\d+/) {
         $antwoord ="OK -> ordernummer = $ordernr";
         $mail = $mail."\n XML verzonden naar agresso:\nAntwoord van agresso: -> $antwoord\n";
         print "\n XML verzonden naar agresso:\nAntwoord van agresso: -> $antwoord\n";
         my $test_copy = 0;
         if ($laatste_xml == 1) {
             copy ("$origniele_xml"  => $plaats_verwerkt) or $test_copy=&error_mail_copy ("$origniele_xml",$plaats_verwerkt);
             if ($test_copy == 0) {
                 unlink ($origniele_xml);
                }else {
                 $mail = $mail."verplaats met de hand $origniele_xml \nnaar $plaats_verwerkt \n";
                 print "verplaats met de hand $origniele_xml \nnaar $plaats_verwerkt \n";
                }
            }
        }else {
         $antwoord ="ERROR ->$fault";
         $mail = $mail."\n\n $origniele_xml :\nXML verzonden naar agresso:\nAntwoord van agresso: -> $antwoord\n";
         $mail = $mail."-----------------------------------------------------------------------------------------\n";
         print "\n $origniele_xml :\nXML verzonden naar agresso:\nAntwoord van agresso: -> $antwoord\n";
         print "-----------------------------------------------------------------------------------------\n";
         #print Dumper(\$response);
         #my $error =  Dumper(\$response);
         #$mail = $mail."$error";
     }
     
     
     
     
}
sub mail_bericht_invoice {
     #print "mail-start\n";
     my $aan = $agresso_instellingen->{mail_verslag_naar};
     my @aan_lijst = split (/\,/,$aan);
     my $van = 'harry.conings@vnz.be';
     my $vandaag = ParseDate("today");
     $vandaag = substr ($vandaag,0,8);  # vandaag in YYYYMMDD
     $vandaag = sprintf "%04d-%02d-%02d",substr ($vandaag,0,4),substr ($vandaag,4,2),substr ($vandaag,6,2);
     foreach my $geadresseerde (@aan_lijst) {
         my $smtp = Net::SMTP->new('mailservices.m-team.be',
                    Hello => 'mail.vnz.be',
                    Timeout => 60);
         $smtp->auth('mailprogrammas','pleintje203');
         $smtp->mail($van);
         $smtp->to($geadresseerde);
         #$smtp->cc('informatica.mail@vnz.be');
         #$smtp->bcc("bar@blah.net");
         $smtp->data;
         $smtp->datasend("From: harry.conings");
         $smtp->datasend("\n");
         $smtp->datasend("To: Kaartbeheerders");
         $smtp->datasend("\n");
         $smtp->datasend("Subject: Assurcard facturen -> Agresso $vandaag");
         $smtp->datasend("\n");
         $smtp->datasend("$mail\nvriendelijke groeten\nHarry Conings");
         $smtp->dataend;
         $smtp->quit;
         print "mail aan $geadresseerde  gezonden\n";
        }
    }
sub connect_to_assurcard_invoices {
     print "maak verbinding\n";
     my $smbuser = 'assurcard';
     my $smbpasswd = 'Hospiplus';
     my $cifs= $agresso_instellingen->{plaats_assurcard_invoices};
     my $plaats_zip = $agresso_instellingen->{plaats_invoices_zip_op_P};
     my $plaats_xml = $agresso_instellingen->{plaats_invoices_xml_op_P};
     my $plaats_verwerkt = $agresso_instellingen->{plaats_invoices_verwerkt_P};
     Connect $cifs,{user=>$smbuser,passwd=>$smbpasswd} ;
     print "$cifs\\test.txt";
     if (-e "$cifs\\test.txt") {
         print"gevonden $cifs\\test.txt\n"; 
         opendir(DIR,$cifs);
         my @inhouddir = readdir(DIR);
         my @files = ();
         my @files1 = ();
         foreach my $file_dir (@inhouddir) {
             push (@files,$file_dir) if ($file_dir =~ m/\.zip$/i);
             push (@files1,$file_dir) if ($file_dir =~ m/\.xml$/i);
         }
         #my @files = grep(/zip$/,readdir(DIR));
         #my @files1 = grep(/\.xml$/,readdir(DIR));
         
         print"gevonden $cifs\$file_dir\n";
         my $file_copie_error=0;
         my $test_copy=0;
         foreach my $file (@files) {
             $test_copy=0;
             copy ("$cifs\\$file"  => $plaats_zip) or $test_copy=&error_mail_copy_invoices ("$cifs\\$file" ,$plaats_zip);
             $file_copie_error += $test_copy;
             if ($test_copy==0) {
                 $mail=$mail."file $file gekopieerd naar $plaats_zip\n" ;
                 print "file $file gekopieerd naar $plaats_zip\n" ;
                 unlink ("$cifs\\$file");
             }
            
            }
         foreach my $file (@files1) {
             $test_copy=0;
             copy ("$cifs\\$file"  => $plaats_xml) or $test_copy=&error_mail_copy_invoices ("$cifs\\$file" ,$plaats_xml);
             $file_copie_error += $test_copy;
              if ($test_copy==0) {
                 $mail=$mail."file $file gekopieerd naar $plaats_xml\n" ;
                 print "file $file gekopieerd naar $plaats_xml\n" ;
                 unlink ("$cifs\\$file");
                }
            }
         if ($file_copie_error > 0) {
             $mail = $mail."\nNIET ALLE FILES ZIJN GEKOPIEERD !! van  $cifs naar P\n----------------------------------------------------------\n";
             print "\nNIET ALLE FILES ZIJN GEKOPIEERD !! van  $cifs naar P\n----------------------------------------------------------\n";
         }else {
             $mail = $mail."\nalle files zijn gekopieerd van $cifs naar P\n";
             print "\nalle files zijn gekopieerd van $cifs naar P\n";
         }
         opendir(DIR,$plaats_zip);
         my @inhouddir1 = readdir(DIR);
         @files = ();
         #@files = grep(/\.zip$/,readdir(DIR));
         foreach my $file_dir (@inhouddir1) {
             push (@files,$file_dir) if ($file_dir =~ m/\.zip$/i);
             #push (@files1,$file_dir) if ($file_dir =~ m/\.xml$/i);
         }
         my $unzip_file='';
         my $file_unzip_error=0;
         my $test_unzip=0;
         foreach my $file (@files) {
             $unzip_file=$file;
             $unzip_file =~ s/\.zip$//;
             $test_unzip=0;
             unzip "$plaats_zip\\$file" => "$plaats_xml\\$unzip_file " or $test_unzip=&error_mail_unzip_invoices($UnzipError);
             if ($test_unzip ==0) {
                 $test_copy= 0;
                 $mail = $mail."extract $plaats_zip\\$file => $plaats_xml\\$unzip_file\n" ;
                 print "extract $plaats_zip\\$file => $plaats_xml\\$unzip_file\n" ;
                 copy ("$plaats_zip\\$file"  => $plaats_verwerkt) or $test_copy=&error_mail_copy_invoices ("$plaats_zip\\$file",$plaats_verwerkt);
                 if ($test_copy == 0) {
                     unlink ("$plaats_zip\\$file");#code
                 }
                 
             }
             
            }
         print "";

     }else {
         print "map niet gemaakt $cifs";
         my $cifs_leesbaar = $cifs;
         # $cifs_leesbaar =~ s/\\/\\\\/g;
         $mail = $mail."\nKAN NETWERK MAP NIET MAKEN $cifs_leesbaar !!!!!\n--------------------------------------------\n";
         print "\nKAN NETWERK MAP NIET MAKEN $cifs_leesbaar !!!!!\n--------------------------------------------\n";
         $mail = $mail."of bestand test.txt staat niet op $cifs_leesbaar \n maak het aan\n";
         print "of bestand test.txt staat niet op $cifs_leesbaar \n maak het aan\n";
     }
    
}

sub error_mail_copy_invoices {
     my $lijstfile = shift @_;
     my $copy_plaats = shift @_;
     $mail = $mail."kon file $lijstfile niet kopieren naar $copy_plaats\n";
     return (1);
}
sub error_mail_unzip_invoices {
     my $UnzipError = shift @_;
     $mail = $mail."unzip niet gelukt $UnzipError\n";
     return (1);
}
sub verwerk_xml_invoices{
     my $plaats_xml = $agresso_instellingen->{plaats_invoices_xml_op_P};
     opendir(DIR,$plaats_xml);
     my @files = ();
     my @inhouddir = readdir(DIR);
     #my @files = grep(/\.xml$/,readdir(DIR));
     foreach my $file_dir (@inhouddir) {
             if ($file_dir ~~ @al_verwerkte_invoices) {
                  $mail = $mail."\n_____________________________________________\n";
                  print "\n_____________________________________________\n";
                  $mail = $mail."OPGELET DUBBELE FACTUUR $file_dir";
                  print "OPGELET DUBBELE FACTUUR $file_dir";
                  $mail = $mail."\n_____________________________________________\n";
                  print "\n_____________________________________________\n";
             }else {
                 #push (@files,$file_dir) if ($file_dir =~ m/\.zip$/i);
                 push (@files,$file_dir) if ($file_dir =~ m/\.xml$/i);
             }
            
         }
     my $invoice_teller=0;
     foreach my $file (@files) {
         undef $ABWTransaction;
         undef $assurcard;
         @Voucher= ();
         undef $Voucher_onderdeel;
         undef $transactie_onderdeel;
         undef @Transaction;
         undef $cdata;
         $invoice_teller +=1;
         $mail = $mail."\n$invoice_teller\. We gaan factuur $file verwerken.\n-----------------------------------------------\n";
         print "\n$invoice_teller\. We gaan factuur $file verwerken.\n-------------------------------------------------------\n";
         &read_assurcard_invoice("$plaats_xml\\$file");
         #&read_assurcard_invoice("$plaats_xml\\017.invoice.out.20140213.120927.xml");
         #last;
     }
     $mail = $mail."Geen facturen te verwerken $vandaag\n" if ($invoice_teller == 0);
     print "Geen facturen te verwerken $vandaag\n" if ($invoice_teller == 0);
}
sub alverwerkte_invoices {
      my $locatie_verwerkte_invoices = $agresso_instellingen->{plaats_invoices_verwerkt_P};
      opendir(DIR,$locatie_verwerkte_invoices);
      my @inhouddir_inv = readdir(DIR);
      my @files = ();
      foreach my $file_dir (@inhouddir_inv) {
            my $datumfile = $file_dir;
            $datumfile =~ s/^\d+\.invoice.out\.//;
            $datumfile =~ s/\.\d+\..*$//;
            if ($datumfile > 20130000) {
               push (@files,$file_dir);
               }
          }
      return(@files);
     }
1;