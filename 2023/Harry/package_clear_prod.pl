#!/usr/bin/perl -w
use strict;

package package_clear ;


sub clear_overzichts_matrix {
     my ($class,$frame) = @_;
     for my $rij (keys @main::overzicht_matrix) {
         if (defined $main::overzicht_matrix[$rij][1] and $main::overzicht_matrix[$rij][1] > 1) { # nomenclatuur
             for (my $kolom =2; $kolom < 12 ; $kolom++ ){
                 if (defined $main::overzicht_matrix[$rij][$kolom] ) {
                     $main::overzicht_matrix[$rij][$kolom] =0;
                    }
                }
             if (defined $main::overzicht_matrix[$rij][13] ) {
                 $main::overzicht_matrix[$rij][13] =0;
                }
             if (defined $main::overzicht_matrix[$rij][15] ) {
                 $main::overzicht_matrix[$rij][15] =0;
                }
             if (defined $main::overzicht_matrix[$rij][16] ) {
                 $main::overzicht_matrix[$rij][15] =0;
                }
             if (defined $main::overzicht_matrix[$rij][17] ) {
                 $main::overzicht_matrix[$rij][15] =0;
                }
            }
        }
    }
sub clear_overzicht_per_nomenclatuur {
     my ($class,$frame) = @_;
     #undef %main::overzicht_per_nomenclatuur;
     foreach my $nomenclatuur (@main::nomenclaturen)          {
         if ($main::type_grid{$nomenclatuur} eq 'Default') {
             my $aantal_rijen = $main::grid_Default->GetNumberRows ;
             my $aantal_kolommen  = $main::grid_Default->GetNumberCols;
             for (my $i=0;$i < $aantal_rijen ; $i++ ) {
                 for (my $k = 0;$k <= $aantal_kolommen;$k++){
                      if ($k ==8) {
                          $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$i][$k] = "";
                        }else {
                         $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$i][$k] = 0;
                        }
                    }
                }
             Detail_Grid->Toolbar_Herbereken($main::grid_Default,$nomenclatuur);
             Detail_GridApp->refresh_grid($main::grid_Detail,$nomenclatuur);
            }
         if ($main::type_grid{$nomenclatuur} eq 'VnZ') {
             my $aantal_rijen =$main::grid_VnZ->GetNumberRows ;
             my $aantal_kolommen  = $main::grid_VnZ->GetNumberCols;
             for (my $i=0;$i < $aantal_rijen ; $i++ ) {
                 for (my $k = 0;$k <= $aantal_kolommen;$k++){
                      if ($k ==0 or $k==1 or $k==2 or $k==3 or $k==8 or $k==9 or $k==10) {
                          $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$i][$k] = "";
                        }else {
                         $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$i][$k] = 0;
                        }
                    }
                }
             Voor_na_zorg_Grid->Toolbar_Herbereken($main::grid_VnZ,$nomenclatuur);
             Voor_na_zorg_GridApp->refresh_grid($main::grid_VnZ_refresh,$nomenclatuur);
            }
        }
     return ('ok');
    }
sub clear_overzicht_per_nomenclatuur_without_calc {
      my ($class,$frame) = @_;
     #undef %main::overzicht_per_nomenclatuur;
     foreach my $nomenclatuur (@main::nomenclaturen)          {
         if ($main::type_grid{$nomenclatuur} eq 'Default') {
             my $aantal_rijen = $main::grid_Default->GetNumberRows ;
             my $aantal_kolommen  = $main::grid_Default->GetNumberCols;
             for (my $i=0;$i < $aantal_rijen ; $i++ ) {
                 for (my $k = 0;$k <= $aantal_kolommen;$k++){
                      if ($k ==8) {
                          $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$i][$k] = "";
                        }else {
                         $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$i][$k] = 0;
                        }
                    }
                }
             #Detail_Grid->Toolbar_Herbereken($main::grid_Default,$nomenclatuur);
             #Detail_GridApp->refresh_grid($main::grid_Detail,$nomenclatuur);
            }
         if ($main::type_grid{$nomenclatuur} eq 'VnZ') {
             my $aantal_rijen =$main::grid_VnZ->GetNumberRows ;
             my $aantal_kolommen  = $main::grid_VnZ->GetNumberCols;
             for (my $i=0;$i < $aantal_rijen ; $i++ ) {
                 for (my $k = 0;$k <= $aantal_kolommen;$k++){
                      if ($k ==0 or $k==1 or $k==2 or $k==3 or $k==8 or $k==9 or $k==10) {
                          $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$i][$k] = "";
                        }else {
                         $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$i][$k] = 0;
                        }
                    }
                }
             #Voor_na_zorg_Grid->Toolbar_Herbereken($main::grid_VnZ,$nomenclatuur);
             #Voor_na_zorg_GridApp->refresh_grid($main::grid_VnZ_refresh,$nomenclatuur);
            }
        }
     return ('ok');
    }

sub clear_invoices {
     my ($class,$frame) = @_;
     foreach my $nr (@main::invoices) {
         $main::invoices[$nr]=0;
     }
}
1;