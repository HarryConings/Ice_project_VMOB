#!/usr/bin/perl -w
use strict;
use File::Slurp;
my $text = read_file('P:\OGV\ASSURCARD_PROG\asurcard_xml\klanten_naar_agresso_235-20230307-B1.xml');
$text =~ m%<ABWSupplierCustomer xmlns:agrlib=\"http://services\.agresso\.com/schema/ABWSchemaLib/2007/12/24\">\s+?\n?<MasterFile>%;
my $match = $&;
$match =~ s/^\s+\n//;
$match =~ s%<ABWSupplierCustomer xmlns:agrlib=\"http://services\.agresso\.com/schema/ABWSchemaLib/2007/12/24\">\s+?\n?<MasterFile>%
                            <ABWSupplierCustomer xsi:schemaLocation=\"http://services\.agresso\.com/schema/ABWSupplierCustomer/2007/12/24 
                          http://services\.agresso\.com/schema/ABWSupplierCustomer/2007/12/24/ABWSupplierCustomer.xsd" 
						  xmlns="http://services\.agresso\.com/schema/ABWSupplierCustomer/2007/12/24" 
						  xmlns:agrlib="http://services\.agresso\.com/schema/ABWSchemaLib/2007/12/24" 
						  xmlns:xsi=\"http://www\.w3\.org/2001/XMLSchema-instance" xmlns:ns0=\"http://www\.openapplications\.org/oagis\">\n<MasterFile>%;
$match =~ s/^\n\s+//;                          
  
print '';

