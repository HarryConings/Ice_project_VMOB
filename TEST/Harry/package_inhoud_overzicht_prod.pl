#!/usr/bin/perl -w
use strict;

package Inhoud_Overzicht_grid ;
use Date::Manip::DM5 ;

sub make_overzicht_matrix {
         my ($class,$periode,$verzekering) = @_;
         @main::recuperatie_van_ziekenfonds = ();         
         my $groepsnaam= '';
         my $aantal_kolommen= 15;
         my $aantal_rijen= 0;
         #bijgezet
         undef @main::overzicht_matrix;
         undef @main::overzicht_matrix_groeprijen;
         undef $main::aantal_rij_overzicht_matrix ;
         undef @main::nomenclaturen;
         undef @main::diensten;
         undef $main::dienst;
         undef %main::overzicht_per_nomenclatuur; #$overzicht_per_nomenclatuur->{nomeclatuur}[rij][kolom]
         undef $main::rekenregels_per_nomenclatuur;
         undef $main::tekst_rekenregels_per_nomenclatuur;
         undef $main::teksten_gebruikte_rekenregels_per_nomenclatuur;
         undef %main::verkorte_naam_per_nomenclatuur;
         undef %main::nomenclatuur_per_verkorte_naam;
         undef %main::nomenclatuurnummers_per_groep;
         undef $main::nomenclaturen_per_groepsregel;
         undef $main::geweigerde_types_pernomenclatuur;
         undef $main::geweigerde_types_pernomenclatuur_fr;
         undef $main::begin_eind_dat_verschil_nomenclatuur;
         undef %main::type_grid; #type van beeld       
         undef %main::page_nr;
         
         #$main::begindatum_opname = '';
         #$main::einddatum_opname =  '';
         #$main::leeftijd = 10;
         $main::hospi_tussenkomst =0 ;    
         $main::verschil=0;
         #undef $main::verschil_txtctrl;
         #$main::datum_laaste_aanvraag_kaart = '';
         #undef $main::klant;
         #undef $main::opnamedata;
         #@main::klanten_met_assurcard_facturen;
         #$main::klanten_met_assurcard_facturen_teller =0;
         #$main::aantal_klanten_met_facturen =0;
         #$main::Handmatig_Inbrengen =1;
         #$main::Verwerk_Assurcard_Facturen=0;
         undef $main::Normal_Item;
         undef $main::invoice if ($main::Verwerk_Assurcard_Facturen == 0);
         undef @main::invoices if ($main::Verwerk_Assurcard_Facturen == 0);
         undef @main::invoices_check if ($main::Verwerk_Assurcard_Facturen == 0);
         undef $main::grid_Default; #voor herbereken
         undef $main::grid_Detail; #voor refresh
         undef $main::grid_VnZ; #voor herbereken
         undef $main::grid_VnZ_refresh; #voor refresh
         undef $main::grid_Overzicht; #voor refresh
         undef @main::nomenclaturen_met_wachttijd;
         undef $main::wachttijden_per_nomenclatuur;
         $main::carensdagen = 0;
         my $vandaag = ParseDate("today");
         my $td_1=substr($vandaag,0,4);
         my $td_2=substr($vandaag,4,2);
         my $td_3=substr($vandaag,6,2);
         my $td_4 = substr($vandaag,8,2);
         my $td_5 = substr($vandaag,11,2);
         my $td_6 = substr($vandaag,14,2);
         $main::tech_creation_date = "$td_1-$td_2-$td_3-$td_4.$td_5.$td_6.000000";
         $vandaag = substr($vandaag,0,8);
         $main::vandaag = $vandaag;
         #my $test= $main::instelingen;
         $main::verkoopsdagboek = $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{verkoopsdagboek};
         my @geboorte_datum = split(/\//,$main::klant->{geboortedatum});
         my $geboortejaar = $geboorte_datum[2];
         my $jaar = substr($main::vandaag,0,4);
         $main::leeftijd=$jaar-$geboortejaar;
         #undef $main::agresso_instellingen;
         #my $test = $main::instelingen->{$periode}->{verzekeringen};
         #bepalen aantal rijen
        # my @test1a = @main::nomenclaturen_met_wachttijd;
        # my $test = $main::instelingen;
         foreach my $nr (keys $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}){
                   eval {my $wachttijd = $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}->{wachttijd}};
                   if (!$@) {
                            my $wachttijd = $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}->{wachttijd};                                                  
                            if ($wachttijd > 0) {
                                     my $nom_nummer =  $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}->{nummer} ;
                                     push (@main::nomenclaturen_met_wachttijd,$nom_nummer);
                                     $main::wachttijden_per_nomenclatuur->{$nom_nummer} =$wachttijd;
                                     
                                    }                                     
                           }
                   eval {foreach my $n_nr (keys $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}){}};
                   if (!$@) {
                            foreach my $n_nr (keys $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}){
                                      eval {my $wachttijd = $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}[$n_nr]->{wachttijd}};
                                      if (!$@) {
                                              my $wachttijd = $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}[$n_nr]->{wachttijd};
                                              if ($wachttijd > 0) {
                                                       my $nom_nummer =  $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}[$n_nr]->{nummer};
                                                       push (@main::nomenclaturen_met_wachttijd,$nom_nummer);#....
                                                       $main::wachttijden_per_nomenclatuur->{$nom_nummer} =$wachttijd;
                                                      }
                                             }
                                      eval {my $recup = $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}[$n_nr]->{recuperatie_van_ziekenfonds}};
                                      if (!$@) {
                                              my $recup = $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}[$n_nr]->{recuperatie_van_ziekenfonds};
                                              my $nom_recup = $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}[$n_nr]->{nummer};
                                              push (@main::recuperatie_van_ziekenfonds,$nom_recup) if (uc $recup eq 'JA');
                                              #my @test1= @main::recuperatie_van_ziekenfonds;
                                              #print '';
                                             }
                                    }
                           }
                  }
         #my @test1 = @main::nomenclaturen_met_wachttijd;
         foreach my $nr (keys $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}){
             $aantal_rijen +=1;
             my $een_nomenclatuur_in_groep=0;
             foreach my $n_nr (keys $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}){
                 if ( $n_nr =~ /^\d+/ and $een_nomenclatuur_in_groep==0) {
                     $aantal_rijen +=1;
                    }elsif ($een_nomenclatuur_in_groep==0)  {
                     $een_nomenclatuur_in_groep =1;
                      $aantal_rijen +=1;
                    }
                }
            }
         $main::aantal_rij_overzicht_matrix= $aantal_rijen;
         my $rijs = 0;
         my $cols=0;
         while ($rijs<=50) { # we nemen maximaal 50 rijen
             $cols=0;
             while ($cols <= $aantal_kolommen) {
                 $main::overzicht_matrix[$rijs][$cols]='';
                 $cols +=1;
                }
             $rijs +=1;
            }
     
         my $rij = 0;
         my $rijgroep=0;
         #my $test = $main::instelingen->{$periode}->{verzekeringen};
         foreach my $nr (keys $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}){
              $groepsnaam= $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{groepsnaam};
              print "$groepsnaam\n";
              $main::overzicht_matrix[$rij][0]="$groepsnaam";
              $main::overzicht_matrix_groeprijen[$rij]=1;
              #$grid->SetRowLabelValue($rij, _T(""));  
              my $kolom=0;
              $rij +=1;
              $main::overzicht_matrix_groeprijen[$rij]=0;
              my $nomenclatuur_naam= '';
              my $korte_naam ='';
              my $soort_werkblad='';
              my $nomencltuur_nr ='';
              my $max_bedrag ='';
              my $max_dagen ='';
              my $getal =0;
              my $een_nomenclatuur_in_groep=0;
             foreach my $n_nr (keys $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}){
                 if ( $n_nr =~ /^\d+/ and $een_nomenclatuur_in_groep==0) {
                     $nomenclatuur_naam=$main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}[$n_nr]->{naam};#code
                     $nomencltuur_nr=$main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}[$n_nr]->{nummer};#code
                     print "\t$nomencltuur_nr $nomenclatuur_naam\n";
                     $korte_naam = $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}[$n_nr]->{korte_naam};
                     $main::verkorte_naam_per_nomenclatuur{$nomencltuur_nr}=$korte_naam;
                     $main::nomenclatuur_per_verkorte_naam{$korte_naam}=$nomencltuur_nr;
                     $soort_werkblad=$main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}[$n_nr]->{soort_werkblad};
                     $main::rekenregels_per_nomenclatuur->{$nomencltuur_nr}->{soort_werkblad} =$soort_werkblad;
                     push (@{$main::nomenclatuurnummers_per_groep{$groepsnaam}},$nomencltuur_nr);
                     if (lc ($groepsnaam) eq 'dienst') {
                            push (@main::diensten,$korte_naam);
                           }
                     
                     if (defined $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}[$n_nr]->{eenmalig_bedrag_jaar}->{bedrag}) {
                            $max_bedrag = $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}[$n_nr]->{eenmalig_bedrag_jaar}->{bedrag};
                            my $tekst = $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}[$n_nr]->{eenmalig_bedrag_jaar}->{tekst};
                            my $tekst_fr  = $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}[$n_nr]->{eenmalig_bedrag_jaar}->{tekst_fr};
                            $getal = $max_bedrag;
                            $max_bedrag = "$max_bedrag /één";
                            $main::rekenregels_per_nomenclatuur->{$nomencltuur_nr}->{eenmalig_bedrag_jaar} = $getal if ($nomencltuur_nr > 0);
                            $main::tekst_rekenregels_per_nomenclatuur->{$nomencltuur_nr}->{eenmalig_bedrag_jaar}->{tekst} = $tekst if ($nomencltuur_nr > 0);
                            $main::tekst_rekenregels_per_nomenclatuur->{$nomencltuur_nr}->{eenmalig_bedrag_jaar}->{tekst_fr} = $tekst_fr if ($nomencltuur_nr > 0);
                            #print "$main::rekenregels_per_nomenclatuur->{$n_nr}->{eenmalig_bedrag_jaar}\n";
                           }
                     if (defined $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}[$n_nr]->{maximum_bedrag_per_jaar}->{bedrag}) {
                            $max_bedrag =$main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}[$n_nr]->{maximum_bedrag_per_jaar}->{bedrag};
                            my $tekst = $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}[$n_nr]->{maximum_bedrag_per_jaar}->{tekst};
                            my $tekst_fr  = $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}[$n_nr]->{maximum_bedrag_per_jaar}->{tekst_fr};
                            $getal = $max_bedrag;
                            $max_bedrag = "$max_bedrag /jaar";
                            $main::rekenregels_per_nomenclatuur->{$nomencltuur_nr}->{maximum_bedrag_per_jaar} = $getal if ($nomencltuur_nr > 0);
                            $main::tekst_rekenregels_per_nomenclatuur->{$nomencltuur_nr}->{maximum_bedrag_per_jaar}->{tekst} = $tekst if ($nomencltuur_nr > 0);
                            $main::tekst_rekenregels_per_nomenclatuur->{$nomencltuur_nr}->{maximum_bedrag_per_jaar}->{tekst_fr} = $tekst_fr if ($nomencltuur_nr > 0);
                           }
                     if (defined $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}[$n_nr]->{maximum_bedrag_per_dag}->{bedrag}){
                            $max_bedrag =$main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}[$n_nr]->{maximum_bedrag_per_dag}->{bedrag};
                            my $tekst = $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}[$n_nr]->{maximum_bedrag_per_dag}->{tekst};
                            my $tekst_fr  = $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}[$n_nr]->{maximum_bedrag_per_dag}->{tekst_fr};
                            $getal = $max_bedrag;
                            $max_bedrag = "$max_bedrag /dag";
                            $main::rekenregels_per_nomenclatuur->{$nomencltuur_nr}->{maximum_bedrag_per_dag} = $getal if ($nomencltuur_nr > 0);
                            
                            $main::tekst_rekenregels_per_nomenclatuur->{$nomencltuur_nr}->{maximum_bedrag_per_dag}->{tekst} = $tekst if ($nomencltuur_nr > 0);
                            $main::tekst_rekenregels_per_nomenclatuur->{$nomencltuur_nr}->{maximum_bedrag_per_dag}->{tekst_fr} = $tekst_fr if ($nomencltuur_nr > 0);
                           }
                     if (defined $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}[$n_nr]->{eenmalig_bedrag}->{bedrag}){
                            $max_bedrag =$main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}[$n_nr]->{eenmalig_bedrag}->{bedrag};
                            my $tekst = $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}[$n_nr]->{eenmalig_bedrag}->{tekst};
                            my $tekst_fr  = $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}[$n_nr]->{eenmalig_bedrag}->{tekst_fr};
                            $getal = $max_bedrag;
                            $max_bedrag = "$max_bedrag /één";
                            $main::rekenregels_per_nomenclatuur->{$nomencltuur_nr}->{eenmalig_bedrag} = $getal if ($nomencltuur_nr > 0);
                            $main::tekst_rekenregels_per_nomenclatuur->{$nomencltuur_nr}->{eenmalig_bedrag}->{tekst} = $tekst if ($nomencltuur_nr > 0);
                            $main::tekst_rekenregels_per_nomenclatuur->{$nomencltuur_nr}->{eenmalig_bedrag}->{tekst_fr} = $tekst_fr if ($nomencltuur_nr > 0);
                           }
                     if (defined $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}[$n_nr]->{toegelaten_toeslagen}->{percent}){
                            $max_bedrag =$main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}[$n_nr]->{toegelaten_toeslagen}->{percent};
                            my $tekst = $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}[$n_nr]->{toegelaten_toeslagen}->{tekst};
                            my $tekst_fr  = $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}[$n_nr]->{toegelaten_toeslagen}->{tekst_fr};
                            $getal = $max_bedrag;
                            $max_bedrag = "$max_bedrag /één";
                            $main::rekenregels_per_nomenclatuur->{$nomencltuur_nr}->{toegelaten_toeslagen} = $getal if ($nomencltuur_nr > 0);
                            $main::tekst_rekenregels_per_nomenclatuur->{$nomencltuur_nr}->{toegelaten_toeslagen}->{tekst} = $tekst if ($nomencltuur_nr > 0);
                            $main::tekst_rekenregels_per_nomenclatuur->{$nomencltuur_nr}->{toegelaten_toeslagen}->{tekst_fr} = $tekst_fr if ($nomencltuur_nr > 0);
                           }
                     if (defined $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}[$n_nr]->{vast_bedrag_per_dag}->{bedrag}){
                            $max_bedrag =$main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}[$n_nr]->{vast_bedrag_per_dag}->{bedrag};
                            my $tekst = $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}[$n_nr]->{vast_bedrag_per_dag}->{tekst};
                            my $tekst_fr  = $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}[$n_nr]->{vast_bedrag_per_dag}->{tekst_fr};
                            $getal = $max_bedrag;
                            $max_bedrag = "$max_bedrag /dag";
                            $main::rekenregels_per_nomenclatuur->{$nomencltuur_nr}->{vast_bedrag_per_dag} = $getal if ($nomencltuur_nr > 0);
                            $main::tekst_rekenregels_per_nomenclatuur->{$nomencltuur_nr}->{vast_bedrag_per_dag}->{tekst} = $tekst if ($nomencltuur_nr > 0);
                            $main::tekst_rekenregels_per_nomenclatuur->{$nomencltuur_nr}->{vast_bedrag_per_dag}->{tekst_fr} = $tekst_fr if ($nomencltuur_nr > 0);
                           }
                      if (defined $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}[$n_nr]->{carensdagen}->{aantal}){
                            my $aantal =$main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}[$n_nr]->{carensdagen}->{aantal};
                            my $ouder_dan = $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}[$n_nr]->{carensdagen}->{leeftijd_hoger_dan};
                            my $tekst = $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}[$n_nr]->{carensdagen}->{tekst};
                            my $tekst_fr  = $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}[$n_nr]->{carensdagen}->{tekst_fr};
                            $getal =  $aantal ;
                            $max_dagen = "$aantal Carensdag +$ouder_dan";
                            #my $test =$main::leeftijd;
                            $main::carensdagen =$aantal if ($main::leeftijd > $ouder_dan);
                            $main::rekenregels_per_nomenclatuur->{$nomencltuur_nr}->{carensdagen} = $getal if ($nomencltuur_nr > 0);
                            $main::tekst_rekenregels_per_nomenclatuur->{$nomencltuur_nr}->{carensdagen}->{ouder_dan} = $ouder_dan if ($nomencltuur_nr > 0);
                            $main::tekst_rekenregels_per_nomenclatuur->{$nomencltuur_nr}->{carensdagen}->{tekst} = $tekst if ($nomencltuur_nr > 0);
                            $main::tekst_rekenregels_per_nomenclatuur->{$nomencltuur_nr}->{carensdagen}->{tekst_fr} = $tekst_fr if ($nomencltuur_nr > 0);
                           }
                     if (defined $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}[$n_nr]->{geweigerde_type_nomenclaturen}){
                            foreach my $n_n_nr (keys $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}[$n_nr]->{geweigerde_type_nomenclaturen}){
                                     my $korte_naam =$main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}[$n_nr]->{geweigerde_type_nomenclaturen}[$n_n_nr]->{korte_naam};
                                     my $weigertext = $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}[$n_nr]->{geweigerde_type_nomenclaturen}[$n_n_nr]->{tekst};
                                     my $weigertext_fr = $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}[$n_nr]->{geweigerde_type_nomenclaturen}[$n_n_nr]->{tekst_fr};
                                     $main::geweigerde_types_pernomenclatuur->{$nomencltuur_nr}->{$korte_naam} = $weigertext if ($nomencltuur_nr > 0);
                                     $main::geweigerde_types_pernomenclatuur_fr->{$nomencltuur_nr}->{$korte_naam} = $weigertext_fr if ($nomencltuur_nr > 0);
                                    }
                           }
                      if (defined $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}[$n_nr]->{aantal_dagen_voor_begindatum}){
                            my $aantal_dagen_voor_begin =$main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}[$n_nr]->{aantal_dagen_voor_begindatum};
                            $main::begin_eind_dat_verschil_nomenclatuur->{$nomencltuur_nr}->{aantal_dagen_voor_begindatum} =$aantal_dagen_voor_begin;
                           }
                      if (defined $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}[$n_nr]->{aantal_dagen_na_einddatum}){
                            my $aantal_dagen_na_eind =$main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}[$n_nr]->{aantal_dagen_na_einddatum};
                            $main::begin_eind_dat_verschil_nomenclatuur->{$nomencltuur_nr}->{aantal_dagen_na_einddatum} =$aantal_dagen_na_eind;
                           }
                     if (defined $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}[$n_nr]->{maximum_aantal_dagen_per_jaar}->{dagen}) {
                            $max_dagen = $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}[$n_nr]->{maximum_aantal_dagen_per_jaar}->{dagen};
                            my $tekst = $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}[$n_nr]->{maximum_aantal_dagen_per_jaar}->{tekst};
                            my $tekst_fr  = $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}[$n_nr]->{maximum_aantal_dagen_per_jaar}->{tekst_fr};
                            my $bijtelling_carens  = $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}[$n_nr]->{maximum_aantal_dagen_per_jaar}->{bijtelling_carensdagen};
                            $getal = $max_dagen;
                            $getal += $main::carensdagen if (uc $bijtelling_carens eq 'JA' or uc $bijtelling_carens eq 'YES' or uc $bijtelling_carens eq 'OUI'  );
                            $max_dagen = "$max_dagen d/jaar";
                            $main::rekenregels_per_nomenclatuur->{$nomencltuur_nr}->{maximum_aantal_dagen_per_jaar} = $getal  if ($nomencltuur_nr > 0);
                           # $main::rekenregels_per_nomenclatuur->{$nomencltuur_nr}->{maximum_aantal_dagen_per_jaar}->{bijtelling_carensdagen} = $bijtelling_carens if ($nomencltuur_nr > 0);
                            $main::tekst_rekenregels_per_nomenclatuur->{$nomencltuur_nr}->{maximum_aantal_dagen_per_jaar}->{tekst} = $tekst if ($nomencltuur_nr > 0);
                            $main::tekst_rekenregels_per_nomenclatuur->{$nomencltuur_nr}->{maximum_aantal_dagen_per_jaar}->{tekst_fr} = $tekst_fr if ($nomencltuur_nr > 0);
                           }
                     if (defined $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}[$n_nr]->{maximum_leeftijd}->{leeftijd}) {
                            my $max_leeftijd= $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}[$n_nr]->{maximum_leeftijd}->{leeftijd};
                            my $tekst = $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}[$n_nr]->{maximum_leeftijd}->{tekst};
                            my $tekst_fr  = $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}[$n_nr]->{maximum_leeftijd}->{tekst_fr};
                            $max_dagen = "$max_dagen =<$max_leeftijd jr";#code
                            $main::rekenregels_per_nomenclatuur->{$nomencltuur_nr}->{maximum_leeftijd} = $max_leeftijd;
                            $main::tekst_rekenregels_per_nomenclatuur->{$nomencltuur_nr}->{maximum_leeftijd}->{tekst} = $tekst if ($nomencltuur_nr > 0);
                            $main::tekst_rekenregels_per_nomenclatuur->{$nomencltuur_nr}->{maximum_leeftijd}->{tekst_fr} = $tekst_fr if ($nomencltuur_nr > 0);
                           }
                     if (defined $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}[$n_nr]->{overname_aantal_dagen}) {
                            my $overname_dagen =$main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}[$n_nr]->{overname_aantal_dagen};
                            $main::rekenregels_per_nomenclatuur->{$nomencltuur_nr}->{overname_aantal_dagen} = $overname_dagen ;
                           }
                      if (defined $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}[$n_nr]->{ja_overname_aantal_dagen}) {
                            my $ja_overname_dagen =$main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}[$n_nr]->{ja_overname_aantal_dagen};
                            $main::rekenregels_per_nomenclatuur->{$nomencltuur_nr}->{ja_overname_aantal_dagen} = $ja_overname_dagen ;
                           }
                       if (defined $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}[$n_nr]->{nee_overname_aantal_dagen}) {
                            my $nee_overname_dagen =$main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}[$n_nr]->{nee_overname_aantal_dagen};
                            $main::rekenregels_per_nomenclatuur->{$nomencltuur_nr}->{nee_overname_aantal_dagen} = $nee_overname_dagen ;
                           }
                         if (defined $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}[$n_nr]->{ja_nee_nom}) {
                            my $ja_nee_nom =$main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}[$n_nr]->{ja_nee_nom};
                            $main::ja_nee_nomenclaturen->{$nomencltuur_nr}->{ja_nee}=$ja_nee_nom;
                            $main::rekenregels_per_nomenclatuur->{$nomencltuur_nr}->{ja_nee_nom} = $ja_nee_nom ;
                           }
                     # $grid->SetRowLabelValue($rij, _T("<->")); 
                     $main::overzicht_matrix[$rij][0]="$nomenclatuur_naam";
                     $main::overzicht_matrix[$rij][1]="$nomencltuur_nr";
                     if ($nomencltuur_nr =~ m/\d+/ or (defined $nomencltuur_nr) ) {
                            push (@main::nomenclaturen,$nomencltuur_nr);
                             my $t_grid=$main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}[$n_nr]->{type_grid};
                            if (!defined $t_grid) {
                                     $t_grid ='Default';#code
                                    }
                            $main::type_grid{"$nomencltuur_nr"}= $t_grid;
                           }
                    
                     $main::overzicht_matrix[$rij][12]="$max_bedrag";
                     $main::overzicht_matrix[$rij][14]="$max_dagen"; 
                     $rij +=1;
                     $main::overzicht_matrix_groeprijen[$rij]=0;
                  }elsif ($een_nomenclatuur_in_groep==0)  {
                     $een_nomenclatuur_in_groep =1;
                     $nomenclatuur_naam=$main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}->{naam};#code
                     $nomencltuur_nr=$main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}->{nummer};#code
                     $korte_naam = $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}->{korte_naam};
                     $main::verkorte_naam_per_nomenclatuur{$nomencltuur_nr}=$korte_naam;
                     $main::nomenclatuur_per_verkorte_naam{$korte_naam}=$nomencltuur_nr;
                     $soort_werkblad=$main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}->{soort_werkblad};
                     $main::rekenregels_per_nomenclatuur->{$nomencltuur_nr}->{soort_werkblad} =$soort_werkblad;
                     push (@{$main::nomenclatuurnummers_per_groep{$groepsnaam}},$nomencltuur_nr);
                     if (lc ($groepsnaam) eq 'dienst') {
                            push (@main::diensten,$korte_naam);
                           }
                     if (defined $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}->{'eenmalig_bedrag_jaar'}->{bedrag} ) {
                            $max_bedrag = $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}->{'eenmalig_bedrag_jaar'}->{bedrag};
                            my $tekst = $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}->{'eenmalig_bedrag_jaar'}->{tekst};
                            my $tekst_fr = $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}->{'eenmalig_bedrag_jaar'}->{tekst_fr};
                            $getal = $max_bedrag;
                            $max_bedrag = "$max_bedrag /één";
                            $main::rekenregels_per_nomenclatuur->{$nomencltuur_nr}->{eenmalig_bedrag_jaar} =  $getal if ($nomencltuur_nr > 0);
                            $main::tekst_rekenregels_per_nomenclatuur->{$nomencltuur_nr}->{eenmalig_bedrag_jaar}->{tekst}  =  $tekst if ($nomencltuur_nr > 0);
                            $main::tekst_rekenregels_per_nomenclatuur->{$nomencltuur_nr}->{eenmalig_bedrag_jaar}->{tekst_fr}  =  $tekst if ($nomencltuur_nr > 0);
                           }
                     if (defined $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}->{'maximum_bedrag_per_jaar'}->{bedrag} ) {
                            $max_bedrag =$main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}->{'maximum_bedrag_per_jaar'}->{bedrag};
                            my $tekst = $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}->{'maximum_bedrag_per_jaar'}->{tekst};
                            my $tekst_fr = $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}->{'maximum_bedrag_per_jaar'}->{tekst_fr};
                            $getal = $max_bedrag;
                            $max_bedrag = "$max_bedrag /jaar";
                            $main::rekenregels_per_nomenclatuur->{$nomencltuur_nr}->{maximum_bedrag_per_jaar} = $getal if ($nomencltuur_nr > 0);
                            $main::tekst_rekenregels_per_nomenclatuur->{$nomencltuur_nr}->{maximum_bedrag_per_jaar}->{tekst}  =  $tekst if ($nomencltuur_nr > 0);
                            $main::tekst_rekenregels_per_nomenclatuur->{$nomencltuur_nr}->{maximum_bedrag_per_jaar}->{tekst_fr}  =  $tekst if ($nomencltuur_nr > 0);
                           }
                     if (defined $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}->{'maximum_bedrag_per_dag'}->{bedrag} ){
                            $max_bedrag =$main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}->{'maximum_bedrag_per_dag'}->{bedrag};
                            my $tekst = $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}->{'maximum_bedrag_per_dag'}->{tekst};
                            my $tekst_fr = $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}->{'maximum_bedrag_per_dag'}->{tekst_fr};
                            $getal = $max_bedrag;
                            $max_bedrag = "$max_bedrag /dag";
                            $main::rekenregels_per_nomenclatuur->{$nomencltuur_nr}->{maximum_bedrag_per_dag} = $getal if ($nomencltuur_nr > 0);
                            $main::tekst_rekenregels_per_nomenclatuur->{$nomencltuur_nr}->{maximum_bedrag_per_dag}->{tekst}  =  $tekst if ($nomencltuur_nr > 0);
                            $main::tekst_rekenregels_per_nomenclatuur->{$nomencltuur_nr}->{maximum_bedrag_per_dag}->{tekst_fr}  =  $tekst if ($nomencltuur_nr > 0);
                           }
                     if (defined $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}->{'eenmalig_bedrag'}->{bedrag} ){
                            $max_bedrag =$main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}->{'eenmalig_bedrag'}->{bedrag};
                            my $tekst = $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}->{'eenmalig_bedrag'}->{tekst};
                            my $tekst_fr = $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}->{'eenmalig_bedrag'}->{tekst_fr};
                            $getal = $max_bedrag;
                            $max_bedrag = "$max_bedrag /één";
                            $main::rekenregels_per_nomenclatuur->{$nomencltuur_nr}->{eenmalig_bedrag} = $getal if ($nomencltuur_nr > 0);
                            $main::tekst_rekenregels_per_nomenclatuur->{$nomencltuur_nr}->{eenmalig_bedrag}->{tekst}  =  $tekst if ($nomencltuur_nr > 0);
                            $main::tekst_rekenregels_per_nomenclatuur->{$nomencltuur_nr}->{eenmalig_bedrag}->{tekst_fr}  =  $tekst if ($nomencltuur_nr > 0);
                        }
                     if (defined $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}->{'toegelaten_toeslagen'}->{percent} ){
                            $max_bedrag =$main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}->{'toegelaten_toeslagen'}->{percent};
                            my $tekst = $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}->{'toegelaten_toeslagen'}->{tekst};
                            my $tekst_fr = $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}->{'toegelaten_toeslagen'}->{tekst_fr};
                            $getal = $max_bedrag;
                            $max_bedrag = "$max_bedrag /één";
                            $main::rekenregels_per_nomenclatuur->{$nomencltuur_nr}->{toegelaten_toeslagen} = $getal if ($nomencltuur_nr > 0);
                            $main::tekst_rekenregels_per_nomenclatuur->{$nomencltuur_nr}->{toegelaten_toeslagen}->{tekst}  =  $tekst if ($nomencltuur_nr > 0);
                            $main::tekst_rekenregels_per_nomenclatuur->{$nomencltuur_nr}->{toegelaten_toeslagen}->{tekst_fr}  =  $tekst if ($nomencltuur_nr > 0);
                        }
                     if (defined $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}->{'vast_bedrag_per_dag'}->{bedrag} ){
                            $max_bedrag =$main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}->{'vast_bedrag_per_dag'}->{bedrag};
                            my $tekst = $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}->{'vast_bedrag_per_dag'}->{tekst};
                            my $tekst_fr = $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}->{'vast_bedrag_per_dag'}->{tekst_fr};
                            $getal = $max_bedrag;
                            $max_bedrag = "$max_bedrag /dag";
                            $main::rekenregels_per_nomenclatuur->{$nomencltuur_nr}->{'vast_bedrag_per_dag'} = $getal if ($nomencltuur_nr > 0);
                            $main::tekst_rekenregels_per_nomenclatuur->{$nomencltuur_nr}->{'vast_bedrag_per_dag'}->{tekst}  =  $tekst if ($nomencltuur_nr > 0);
                            $main::tekst_rekenregels_per_nomenclatuur->{$nomencltuur_nr}->{'vast_bedrag_per_dag'}->{tekst_fr}  =  $tekst if ($nomencltuur_nr > 0);
                           }
                      if (defined $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}->{carensdagen}->{aantal}){
                            my $aantal =$main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}->{carensdagen}->{aantal};
                            my $ouder_dan = $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}->{carensdagen}->{leeftijd_hoger_dan};
                            my $tekst = $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}->{carensdagen}->{tekst};
                            my $tekst_fr  = $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}->{carensdagen}->{tekst_fr};
                            $getal =  $aantal ;
                            $max_dagen = "$aantal Carensdag +$ouder_dan";
                            $main::carensdagen =$aantal if ($main::leeftijd > $ouder_dan);
                            $main::rekenregels_per_nomenclatuur->{$nomencltuur_nr}->{carensdagen} = $getal if ($nomencltuur_nr > 0);
                            $main::tekst_rekenregels_per_nomenclatuur->{$nomencltuur_nr}->{carensdagen}->{ouder_dan} = $ouder_dan if ($nomencltuur_nr > 0);
                            $main::tekst_rekenregels_per_nomenclatuur->{$nomencltuur_nr}->{carensdagen}->{tekst} = $tekst if ($nomencltuur_nr > 0);
                            $main::tekst_rekenregels_per_nomenclatuur->{$nomencltuur_nr}->{carensdagen}->{tekst_fr} = $tekst_fr if ($nomencltuur_nr > 0);
                           }
                      if (defined $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}->{geweigerde_type_nomenclaturen}){
                            foreach my $n_n_nr (keys $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}->{geweigerde_type_nomenclaturen}){
                                     my $korte_naam =$main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}->{geweigerde_type_nomenclaturen}[$n_n_nr]->{korte_naam};
                                     my $weigertext = $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}->{geweigerde_type_nomenclaturen}[$n_n_nr]->{tekst};
                                     my $weigertext_fr = $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}->{geweigerde_type_nomenclaturen}[$n_n_nr]->{tekst_fr};
                                     $main::geweigerde_types_pernomenclatuur->{$nomencltuur_nr}->{$korte_naam} = $weigertext if ($nomencltuur_nr > 0);
                                     $main::geweigerde_types_pernomenclatuur_fr->{$nomencltuur_nr}->{$korte_naam} = $weigertext_fr if ($nomencltuur_nr > 0);
                                    }
                           }
                     if (defined $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}->{aantal_dagen_voor_begindatum}){
                            my $aantal_dagen_voor_begin =$main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}->{aantal_dagen_voor_begindatum};
                            $main::begin_eind_dat_verschil_nomenclatuur->{$nomencltuur_nr}->{aantal_dagen_voor_begindatum} =$aantal_dagen_voor_begin;
                           }
                      if (defined $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}->{aantal_dagen_na_einddatum}){
                            my $aantal_dagen_na_eind =$main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}->{aantal_dagen_na_einddatum};
                            $main::begin_eind_dat_verschil_nomenclatuur->{$nomencltuur_nr}->{aantal_dagen_na_einddatum} =$aantal_dagen_na_eind;
                           } 
                     if (defined $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}->{maximum_aantal_dagen_per_jaar}->{dagen}) {
                            $max_dagen = $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}->{maximum_aantal_dagen_per_jaar}->{dagen};
                            my $tekst = $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}->{maximum_aantal_dagen_per_jaar}->{tekst};
                            my $tekst_fr = $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}->{maximum_aantal_dagen_per_jaar}->{tekst_fr};
                            my $bijtelling_carens  = $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}->{maximum_aantal_dagen_per_jaar}->{bijtelling_carensdagen};
                            $getal = $max_dagen;
                            $getal += $main::carensdagen if (uc $bijtelling_carens eq 'JA' or uc $bijtelling_carens eq 'YES' or uc $bijtelling_carens eq 'OUI'  );
                            $max_dagen = "$max_dagen d/jaar";
                            $main::rekenregels_per_nomenclatuur->{$nomencltuur_nr}->{maximum_aantal_dagen_per_jaar} = $getal if ($nomencltuur_nr > 0);
                           # $main::rekenregels_per_nomenclatuur->{$nomencltuur_nr}->{maximum_aantal_dagen_per_jaar}->{bijtelling_carensdagen} = $bijtelling_carens if ($nomencltuur_nr > 0);
                            $main::tekst_rekenregels_per_nomenclatuur->{$nomencltuur_nr}->{maximum_aantal_dagen_per_jaar}->{tekst}  =  $tekst if ($nomencltuur_nr > 0);
                            $main::tekst_rekenregels_per_nomenclatuur->{$nomencltuur_nr}->{maximum_aantal_dagen_per_jaar}->{tekst_fr}  =  $tekst if ($nomencltuur_nr > 0);
                           }
                     if (defined $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}->{maximum_leeftijd}->{leeftijd}) {
                            my $max_leeftijd= $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}->{maximum_leeftijd}->{leeftijd};
                            my $tekst = $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}->{maximum_leeftijd}->{tekst};
                            my $tekst_fr = $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}->{maximum_leeftijd}->{tekst_fr};
                            $max_dagen = "$max_dagen =<$max_leeftijd jr";#code
                            $main::rekenregels_per_nomenclatuur->{$nomencltuur_nr}->{maximum_leeftijd} = $max_leeftijd if ($nomencltuur_nr > 0);
                            $main::tekst_rekenregels_per_nomenclatuur->{$nomencltuur_nr}->{maximum_leeftijd}->{tekst}  =  $tekst if ($nomencltuur_nr > 0);
                            $main::tekst_rekenregels_per_nomenclatuur->{$nomencltuur_nr}->{maximum_leeftijd}->{tekst_fr}  =  $tekst if ($nomencltuur_nr > 0);
                           }
                     if (defined $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}->{overname_aantal_dagen}) {
                            my $overname_dagen =$main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}->{overname_aantal_dagen};
                            $main::rekenregels_per_nomenclatuur->{$nomencltuur_nr}->{overname_aantal_dagen} = $overname_dagen ;
                           }     
                     if (defined $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}->{ja_overname_aantal_dagen}) {
                            my $ja_overname_dagen =$main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}->{ja_overname_aantal_dagen};
                            $main::rekenregels_per_nomenclatuur->{$nomencltuur_nr}->{ja_overname_aantal_dagen} = $ja_overname_dagen ;
                           }
                       if (defined $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}->{nee_overname_aantal_dagen}) {
                            my $nee_overname_dagen =$main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}->{nee_overname_aantal_dagen};
                            $main::rekenregels_per_nomenclatuur->{$nomencltuur_nr}->{nee_overname_aantal_dagen} = $nee_overname_dagen ;
                           }
                         if (defined $main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}->{ja_nee_nom}) {
                            my $ja_nee_nom =$main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}->{ja_nee_nom};
                            $main::rekenregels_per_nomenclatuur->{$nomencltuur_nr}->{ja_nee_nom} = $ja_nee_nom ;
                           }
                     $main::overzicht_matrix[$rij][0]="$nomenclatuur_naam";
                     #push (@main::nomenclaturen,$nomencltuur_nr) if ($nomencltuur_nr =~ m/\d+/ or (defined $nomencltuur_nr) );
                     if ($nomencltuur_nr =~ m/\d+/ or (defined $nomencltuur_nr) ) {
                          push (@main::nomenclaturen,$nomencltuur_nr);
                          my $t_grid=$main::instelingen->{$periode}->{verzekeringen}->{$verzekering}->{groep}[$nr]->{nomenclatuur}->{type_grid};
                          if (!defined $t_grid) {
                             $t_grid ='Default';#code
                          }
                          $main::type_grid{"$nomencltuur_nr"}=$t_grid;
                     }
                     $main::overzicht_matrix[$rij][1]="$nomencltuur_nr";
                     $main::overzicht_matrix[$rij][12]="$max_bedrag";
                     $main::overzicht_matrix[$rij][14]="$max_dagen";
                     $rij +=1;
                     $main::overzicht_matrix_groeprijen[$rij]=0;
                    
                    }else {
                     print "$n_nr fout xml $een_nomenclatuur_in_groep\n";
                      
                    }
             
                }
            }
          #verwerken groepsregels
          my @voorlopig_array_totaal=();
          foreach my $groep (keys %main::nomenclatuurnummers_per_groep) {
                   my @voorlopig_array_groep=();
                   my $groepsregel_nomenclatuur = '';
                   foreach my $nomenclatuur (@{$main::nomenclatuurnummers_per_groep{$groep}}){
                            if ($nomenclatuur < 999990) {
                                     push (@voorlopig_array_groep,$nomenclatuur);
                                     push (@voorlopig_array_totaal,$nomenclatuur);
                                    }elsif ($nomenclatuur < 999999) {
                                     $groepsregel_nomenclatuur = $nomenclatuur ;
                                     push (@voorlopig_array_totaal,$nomenclatuur);
                                    }
                           }
                   $main::nomenclaturen_per_groepsregel->{$groepsregel_nomenclatuur} =\@voorlopig_array_groep;
                  }
          $main::nomenclaturen_per_groepsregel->{999999}= \@voorlopig_array_totaal;
           $main::aantal_rij_overzicht_matrix = $rij;
          push (@main::diensten,0);
          #my %test = %main::geweigerde_types_pernomenclatuur;
          return (1);
         }
1;
