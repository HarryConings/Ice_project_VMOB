#!/usr/bin/perl -w
use strict;
use File::Copy;
my $brief='W:\OGV\BRIEFWISSELING_NIEUW\Documenten\531207-298-10.7-11-2019.13u32.235.-HOSPIPLAN_AMBUPLAN-.HOSP_SABI_ZHFACT-SAFORM-opvragen-manueel-geenmail_her3.M235VAUW.odt';
my $brief1=$brief;
$brief1 =~ s%\\%/%g;
print "brief bestaat->$brief\n"if (-e $brief);
print "brief1 bestaat->$brief\n"if (-e $brief1);
print " gedaan \n"