#!/usr/bin/perl -w
use strict;


package assurcard_calculation_settings;
     use strict;
     use XML::Simple;
     sub new {
         my $settings;
         #settings $settings->{periode} en $settings->{verzekering} komen me van boven bepalen de periode en de verzekering voor de lay out
         print "\n\\\\s298file101.zkf200mut.prd\\250-B\\Applicaties\\Assurcard\\assurcard_settings_xml_$main::mode\\harry_calculation_settings.xml\n";
         #$settings = XMLin("P:\\OGV\\ASSURCARD_TEST\\assurcard_settings_xml\\harry_calculation_settings.xml"); #test nieuwe xml
         $settings = XMLin("\\\\s298file101.zkf200mut.prd\\250-B\\Applicaties\\Assurcard\\assurcard_settings_xml_$main::mode\\harry_calculation_settings.xml");
        
         return ($settings);
        }
     sub teksten_gkd {
          my $teksten;
         #settings $teksten->{periode} en $teksten->{verzekering} komen me van boven bepalen de periode en de verzekering voor de lay out
         $teksten = XMLin("\\\\s298file101.zkf200mut.prd\\250-B\\Applicaties\\Assurcard\\assurcard_settings_xml_$main::mode\\harry_calculation_settings_teksten.xml");
         return ($teksten);
        }
    
1;