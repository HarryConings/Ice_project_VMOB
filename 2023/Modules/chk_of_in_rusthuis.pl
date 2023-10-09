#!/usr/bin/perl -w
use strict;
use vars qw(%settings);
sub checkofinrusthuis {
        
        #PSDDS5 LIBCXCOM20 $toelating_file = "libcxcom20.PSDDS5
	#ZG53S5          DATE DEBUT ACCORD/REFUS /DATUM BEGIN OVE      8
        #ZG57S5          DATE FIN ACCORD/REFUS   /DATUM EIND OVER      8
        #ZG52S5          COD.DECISION DEM.M-C.   /KODE BESLUIT AA      6
        #ZG05S5          COD.PRESTAT.1 DE DEMANDE/KODE PREST.1.AA      7
        #ZG06S5          COD.PRESTAT.2 DE DEMANDE/KODE PREST.2 AA      7
        #ZG45S5          DATE DECISION M-C.      /DATUM BESLUIT M      8
        #IDFDS5          NUMERO MUTUELLE         /NUMMER ZIEKENFO      3
        #EXIDS5          NUMERO EXTERNE          /EXTERN NUMMER       13
	#iemand is in een rusthuis als ZG57S5 begint met 9999 als ZG52S5 niet gelijk is aan Z en
	# als ZG05S5 tussen 763195 en 763372 of 763033 en 763151 is
	my $ext_rust = shift @_;
        my $dbh = shift @_;
	my $sql =("SELECT EXIDS5,ZG53S5,ZG57S5,ZG52S5,ZG05S5,ZG06S5,ZG45S5,IDFDS5,SUBSTR(ZG57S5,0,5) FROM $settings{'toelating_fil'} WHERE EXIDS5 = $ext_rust and IDFDS5 = $settings{'zkfnummer'} and SUBSTR(ZG57S5,0,5) = '9999'
		  and ZG52S5 != 'Z' and ((ZG05S5 BETWEEN 763195 AND 763372) or (ZG05S5 BETWEEN 763033 AND 763152))");
        my $sth = $dbh->prepare( $sql );
        $sth->execute();
        my $rusthuis=0;
        my $gevonden=0;
	#print "RUSTHUIS ?\n";
        # we nemen de cg1 cg2 waarvan de datum van vandaag valt tussen begin en einfdatum
        # indien er geen zo is de meest recente
        while(my @rustrij=$sth->fetchrow_array) {
	  # print "rusthuis $rustrij[0] : @rustrij\n";
	   $rusthuis =1;
	  }
      return ($rusthuis);
     }
1;
