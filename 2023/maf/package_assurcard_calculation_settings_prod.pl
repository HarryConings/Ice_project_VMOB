#!/usr/bin/perl -w
use strict;


package assurcard_calculation_settings;
     use strict;
     use XML::Simple;
     sub new {
         my $settings;
         #settings $settings->{periode} en $settings->{verzekering} komen me van boven bepalen de periode en de verzekering voor de lay out
         $settings = XMLin("D:\\OGV\\ASSURCARD_2023\\assurcard_settings_xml\\harry_calculation_settings.xml");
        
         return ($settings);
        }
     sub teksten_gkd {
          my $teksten;
         #settings $teksten->{periode} en $teksten->{verzekering} komen me van boven bepalen de periode en de verzekering voor de lay out
         $teksten = XMLin("D:\\OGV\\ASSURCARD_2023\\assurcard_settings_xml\\harry_calculation_settings_teksten.xml");
         return ($teksten);
        }
    
1;