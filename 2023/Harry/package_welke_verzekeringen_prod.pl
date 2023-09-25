#!/usr/bin/perl -w
use strict;

package welke_verzekeringen {
     my ($class,$periode) = @_;
     undef @main::verzekeringen_in_xml;
     foreach my $verzekering (keys $main::instelingen->{$periode}->{verzekeringen}) {
         push (@main::verzekeringen_in_xml,$verzekering); 
     }
}

