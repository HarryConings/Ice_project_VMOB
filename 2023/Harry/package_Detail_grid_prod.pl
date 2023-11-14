#!/usr/bin/perl -w
use strict;


package Detail_GridApp;

use strict;
use warnings;
use Wx qw(:everything);
use base qw(Wx::Grid);
use Data::Dumper;
use threads;
use threads::shared;
use Wx::Event qw(EVT_GRID_CELL_LEFT_CLICK EVT_GRID_CELL_RIGHT_CLICK
EVT_GRID_CELL_LEFT_DCLICK EVT_GRID_CELL_RIGHT_DCLICK
EVT_GRID_LABEL_LEFT_CLICK EVT_GRID_LABEL_RIGHT_CLICK
EVT_GRID_LABEL_LEFT_DCLICK EVT_GRID_LABEL_RIGHT_DCLICK
EVT_GRID_ROW_SIZE EVT_GRID_COL_SIZE EVT_GRID_RANGE_SELECT
EVT_GRID_SELECT_CELL);
use Wx::Locale gettext => '_T';   
# events changed names in version 2..x
our $table='';
my $events29plus = ( defined(&Wx::Event::EVT_GRID_CELL_CHANGED) );

sub new {
     my ($class, $frame,$nom_clatuur) = @_;
     my $grid = $class->SUPER::new($frame->{"MainframeNotebookOnder_pane_Detail$nom_clatuur"}, wxID_ANY, wxDefaultPosition,	# Grid object
     Wx::Size->new(1200,780));
     
     $table = Detail_Grid->new;	# Virtual Table object
     $grid->SetTable( $table );
      
     # Custom Grid Formatting Examples- text, fonts, colors, sizes, gridlines - from Grid.pl
     $grid->SetLabelBackgroundColour(wxLIGHT_GREY);
     $grid->SetLabelTextColour(Wx::Colour->new(wxBLUE));
     $grid->SetLabelFont(Wx::Font->new(10, wxFONTFAMILY_ROMAN, wxNORMAL, wxBOLD));
     $grid->SetColLabelSize(20);	# Col height
     $grid->SetRowLabelSize(100);	# Row height - 0 hides the row labels
     $grid->SetDefaultColSize(120,1);	# Default Cell width (Fit overrides)
     $grid->SetDefaultRowSize(20,1);	# Default Cell Height (Fit overrides)
     $grid->EnableGridLines(1);	# Grid lines 1-on, 0-off
     $grid->SetGridLineColour(wxBLUE);
     $grid->SetSelectionMode(wxGridSelectRows);	# Always select complete rows
     $grid->SetSelectionForeground(wxRED);
     $grid->SetSelectionBackground(wxGREEN);	# Click within grid, background goes green
     # Click on row label, background stays black
     # until clicking within grid, then green(???)
     $grid->SetColLabelValue(0, _T("Dagen"));
     $grid->SetColLabelValue(1, _T("Bdrg/dg"));
     $grid->SetColLabelValue(2, _T("P. tsk."));
     $grid->SetColLabelValue(3, _T("Sup."));
     $grid->SetColLabelValue(4, _T("Totaal"));
     $grid->SetColLabelValue(5, _T("Z. tsk"));
     $grid->SetColLabelValue(6, _T("HP+ tsk"));
     $grid->SetColLabelValue(7, _T("Verschil"));
     $grid->SetColLabelValue(8, _T("Regel Toegepast"));
     $grid->SetColLabelValue(9, _T("Aanvaard"));
     $grid->SetColLabelValue(10, _T("Geweigerd"));
     $grid->SetColLabelValue(11, _T("100%"));
     $grid->SetColLabelValue(12, _T("200%"));
     $grid->SetColLabelValue(13, _T("Dienst"));
     $grid->SetColSize( 0,60 );
     $grid->SetColSize( 1,60 );
     $grid->SetColSize( 2,60 );
     $grid->SetColSize( 3,60 );
     $grid->SetColSize( 4,60 );
     $grid->SetColSize( 5,60 );
     $grid->SetColSize( 6,60 );
     $grid->SetColSize( 7,60 );
     $grid->SetColSize( 8,190 );
     $grid->SetColSize( 9,60 );
     $grid->SetColSize( 10,60 );
     $grid->SetColSize( 11,60 );
     $grid->SetColSize( 12,60 );
     $grid->SetColSize( 13,80 );
    
     for my $r (0..$grid->GetNumberRows()-1) {	# Row Header Text
         if ($r < $grid->GetNumberRows()-1) {
             $grid->SetRowLabelValue($r,"$nom_clatuur");#  if $r % 10 != 0; #oneven
             $grid->SetRowLabelValue($r,"$main::verkorte_naam_per_nomenclatuur{$nom_clatuur}") if $r == 0 ;#even
             $grid->SetRowLabelValue($r,"$main::verkorte_naam_per_nomenclatuur{$nom_clatuur}") if $r % 10 == 0 ;
         }else{
             $grid->SetRowLabelValue($r,"Totaal");
         }
                
        
        }
    
         
# Sample Events - logs the events
  #EVT_GRID_CELL_LEFT_CLICK( $grid, c_log_skip( "Cell left click") );
  #EVT_GRID_CELL_RIGHT_CLICK( $grid, c_log_skip( "Cell right click" ) );
  #EVT_GRID_CELL_LEFT_DCLICK( $grid, c_log_skip( "Cell left double click" ) );
  #EVT_GRID_CELL_RIGHT_DCLICK( $grid, c_log_skip( "Cell right double click" ) );
  #EVT_GRID_LABEL_LEFT_CLICK( $grid, c_log_skip( "Label left click" ) );
  #EVT_GRID_LABEL_RIGHT_CLICK( $grid, c_log_skip( "Label right click" ) );
  #EVT_GRID_LABEL_RIGHT_CLICK( $grid, \&clear_row);
  #EVT_GRID_LABEL_LEFT_DCLICK( $grid, c_log_skip( "Label left double click" ) );
  #EVT_GRID_LABEL_RIGHT_DCLICK( $grid, c_log_skip( "Label right double click" ) );

  #EVT_GRID_ROW_SIZE( $grid, sub {
  #                     Wx::LogMessage( "%s %s", "Row size", GS2S( $_[1] ) );
  #                     $_[1]->Skip;
  #                   } );
  #EVT_GRID_COL_SIZE( $grid, sub {
  #                     Wx::LogMessage( "%s %s", "Col size", GS2S( $_[1] ) );
  #                     $_[1]->Skip;
  #                   } );
  #
  #EVT_GRID_RANGE_SELECT( $grid, sub {
  #                         Wx::LogMessage( "Range %sselect (%d, %d, %d, %d)",
  #                                         ( $_[1]->Selecting ? '' : 'de' ),
  #                                         $_[1]->GetLeftCol, $_[1]->GetTopRow,
  #                                         $_[1]->GetRightCol,
  #                                         $_[1]->GetBottomRow );
  #                         $_[0]->ShowSelections;
  #                         $_[1]->Skip;
  #                       } );
  
  if( $events29plus ) {
        #Wx::Event::EVT_GRID_CELL_CHANGED( $grid, c_log_skip( "Cell content changed" ) );
       
    } else {
        #Wx::Event::EVT_GRID_CELL_CHANGE( $grid, c_log_skip( "Cell content changed" ) );
        
  }
  
  #EVT_GRID_SELECT_CELL( $grid, c_log_skip( "Cell select" ) );
   
  $main::grid_Detail=$grid;
  return $grid;
}
sub refresh_grid {
          my ($class,$grid) = @_;
          $grid->ForceRefresh();
          
     }

sub ShowSelections {
    my $grid = shift;
    $grid->ForceRefresh();
    my @cells = $grid->GetSelectedCells;
    if( @cells ) {
        #Wx::LogMessage( "Cells %s selected", join ', ',
        #                                          map { "(" . $_->GetCol .
        #                                                ", " . $_->GetRow . ")"
        #                                               } @cells );
    } else {
        #Wx::LogMessage( "No cells selected" );
    }

    my @tl = $grid->GetSelectionBlockTopLeft;
    my @br = $grid->GetSelectionBlockBottomRight;
    if( @tl && @br ) {
        #Wx::LogMessage( "Blocks %s selected",
        #                join ', ',
        #                map { "(" . $tl[$_]->GetCol .
        #                      ", " . $tl[$_]->GetRow . "-" .
        #                      $br[$_]->GetCol . ", " .
        #                      $br[$_]->GetRow . ")"
        #                    } 0 .. $#tl );
    } else {
        #Wx::LogMessage( "No blocks selected" );
    }

    my @rows = $grid->GetSelectedRows;
    if( @rows ) {
        #Wx::LogMessage( "Rows %s selected", join ', ', @rows );
    } else {
        #Wx::LogMessage( "No rows selected" );
    }

    my @cols = $grid->GetSelectedCols;
    if( @cols ) {
        #Wx::LogMessage( "Columns %s selected", join ', ', @cols );
    } else {
        #Wx::LogMessage( "No columns selected" );
    }
}

# pretty printer for Wx::GridEvent
sub G2S {
  my $event = shift;
  my( $x, $y ) = ( $event->GetCol, $event->GetRow );
  return "( $x, $y )";
}

# prety printer for Wx::GridSizeEvent
sub GS2S {
  my $event = shift;
  my $roc = $event->GetRowOrCol;

  return "( $roc )";
}

# creates an anonymous sub that logs and skips any grid event
sub c_log_skip {
  my $text = shift @_;
  my $grid = shift @_;
 
  

   return sub {
    #Wx::LogMessage( "%s %s", $text, G2S( $_[1] ) );
    $_[0]->ShowSelections;
    $_[1]->Skip;
  };

}
sub clear_row {
	my ( $this, $grid_event) = @_;
	my $rij_delete = $grid_event->GetRow();
        my $kolom_label =  $grid_event->GetCol();
        my $nomenclatuur = $this->GetRowLabelValue(1);
        print"";
        foreach my $kolom  (keys $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij_delete]) {
           if ($kolom == 8 or $kolom == 13) {
                $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij_delete][$kolom]='';
           }else {
                $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij_delete][$kolom]=0;
                my $refresh = $table->Total_Col($kolom,$nomenclatuur);
           }
           
        }
        #my $test= $main::overzicht_per_nomenclatuur->{$nomenclatuur}[33][0];
        $table->Herberekenen($nomenclatuur);
        $this->ForceRefresh();
        return();
}
1;
package Detail_Grid;
     use strict;
     use warnings;
     use Wx qw(:everything);
     use Wx::Grid;
     use base qw(Wx::PlGridTable);
     use Data::Dumper;
     use Wx qw(wxRED wxGREEN wxBLUE wxALIGN_LEFT wxALIGN_CENTRE wxCYAN );
     use Wx::Locale gettext => '_T';
     use Date::Calc qw{ :all };
     our $main_frame_notebook_onder;
     #our $nomeclatuur;
     sub new {
         my( $class ) = @_;
         my $self = $class->SUPER::new;
            
         $self->{default} = Wx::GridCellAttr->new;	# Cell attributes for demo purposes
         $self->{red_bg} = Wx::GridCellAttr->new;
         $self->{cyan_bg} = Wx::GridCellAttr->new;
         $self->{green_fg} = Wx::GridCellAttr->new;
         $self->{float}=  Wx::GridCellAttr->new;
         $self->{float_precisoin}= Wx::GridCellFloatRenderer->new;
         $self->{align_left}=  Wx::GridCellAttr->new;
         
         $self->{align_left}->SetAlignment(wxALIGN_LEFT,wxALIGN_CENTRE);
         $self->{float}->SetRenderer($self->{float_precisoin});
         $self->{float_precisoin}->SetPrecision(2);
         $self->{red_bg}->SetBackgroundColour( wxRED );
         $self->{cyan_bg}->SetBackgroundColour( wxCYAN );
         $self->{green_fg}->SetTextColour( wxGREEN );
         $self->SetRowAttr($self->{float},1);
      $main::grid_Default = $self;   
  return $self;
}

# Overridden Methods from the base class - these get modified/expanded in a real app
sub GetNumberRows {# Base demo is set for 100000 x 100000
     
      if ($main::Handmatig_Inbrengen == 1) { #bij handmatig slechts 34 rijen ivm snelheid
           return (34);   
          }else {
           my $is_er_een_factuur_aangevinkt = 0;
           my $factuur_nummer = -1;
           for (my $i=0; $i < 6; $i++) {                
                 if ($main::invoices_check[$i] == 1 ) {
                     $is_er_een_factuur_aangevinkt =1;
                     $factuur_nummer =$main::invoices[$i];
                    }
               }
           if ($factuur_nummer ne '-1') {
                my $aantal_lijnen = $main::max_lijnen_invoice->{$factuur_nummer}+5;
                if ($aantal_lijnen > 5) {
                     return ($aantal_lijnen);
                }else {
                     return (65);
                }
               }else {
                 return (65); # assurcard veel lijnen 80 trager
               }
           
          
          }
     }	
sub GetNumberCols { 14 }
sub IsEmptyCell { 0 }
sub GetValue {
  my( $grid, $r, $c,$value ) = @_;
  my $nomenclatuur=$grid->GetRowLabelValue(1);
  $value = $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$r][$c];
  return "$value";
}

sub SetValue {
  my( $grid, $x, $y, $value ) = @_;
  if ($main::contract_gekozen==0) {
             Wx::MessageBox( _T("Gelieve een verzekering te kiezen"), 
                     _T("Invoeren:"), 
                     wxOK|wxCENTRE, 
                     $main::frame
                    );
     }
  Frame->check_input_ok;
  my $nomenclatuur=$grid->GetRowLabelValue(1);
  my $soort_werkblad = $main::rekenregels_per_nomenclatuur->{$nomenclatuur}->{soort_werkblad};
  if (lc ($soort_werkblad) eq 'standaard') {
      $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$x][$y] = $value;#code
  }elsif (lc ($soort_werkblad) eq 'dienst') {
      $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$x][$y] = $value if ($y == 9 or $y ==10) ;
  }elsif (lc ($soort_werkblad) eq 'groepsregel') {
  }elsif (lc ($soort_werkblad) eq 'totaal') {
  }
  
  $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$x][$y] = $value;
  $grid->Herberekenen;
  #die "Read-Only table";
}
sub SetValueAsDouble {
     my( $grid, $x, $y, $value ) = @_;
     if ($main::contract_gekozen==0) {
             Wx::MessageBox( _T("Gelieve een verzekering te kiezen"), 
                     _T("Invoeren:"), 
                     wxOK|wxCENTRE, 
                     $main::frame
                    );
     }
     Frame->check_input_ok;
     my $nomenclatuur=$grid->GetRowLabelValue(1);
     my $soort_werkblad = $main::rekenregels_per_nomenclatuur->{$nomenclatuur}->{soort_werkblad};
     if (lc ($soort_werkblad) eq 'standaard') {
      $value = Detail_Grid->wachttijd_per_nomenclatuur($nomenclatuur,$value)  if ($nomenclatuur ~~ @main::nomenclaturen_met_wachttijd);   
      $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$x][$y] = $value;#code
      
     }elsif (lc ($soort_werkblad) eq 'dienst') {
      $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$x][$y] = $value if ($y == 9 or $y ==10) ;
     }elsif (lc ($soort_werkblad) eq 'groepstotaal') {
     }elsif (lc ($soort_werkblad) eq 'totaal') {
     }    
     $grid->Herberekenen;
    }

sub GetTypeName {	# Verified that swapping bool and double
  my( $grid, $r, $c ) = @_;	# Swap the columns
  return $c == 8 ? 'string' :
         $c == 13 ? 'string' :
                   'double' ;	# Col 0 Boolean
      
}

sub CanGetValueAs {
  my( $grid, $r, $c, $type ) = @_;
  return $c == 8 ? $type eq 'string':
  return $c == 13 ? $type eq 'string':
         $type eq 'double' ;
}

sub GetValueAsBool {	# Even rows false
  my( $grid, $r, $c ) = @_;	# Odd rows true
  my $nomenclatuur=$grid->GetRowLabelValue(1);
  my $value = $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$r][$c];
  return "$value";
  #return $r % 2;
}

sub GetValueAsDouble {	# Row # plus (Col #/1000)
  my( $grid, $r, $c ) = @_;
  my $nomenclatuur=$grid->GetRowLabelValue(1);
  my $value = $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$r][$c];
  return "$value";
 
}
sub GetValueAsString {	# Even rows false
      my( $grid, $r, $c ) = @_;	# Odd rows true
      my $nomenclatuur=$grid->GetRowLabelValue(1);
      my $value = $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$r][$c];
      return "$value";
     }

sub GetAttr {	# Cell attributes
  my( $grid, $row, $col, $kind ) = @_;
 
  #return $grid->{default} if $row % 2 && $col % 2;	# Odd rows and odd cols default format
  #return ($grid->{cyan_bg},$grid->{float}) if $row % 2;	# Odd rows only - red background
  #return $grid->{float} if $row % 2;
  #return $grid->{green_fg} if $row == 25;	# Odd cols only - green foreground text
  return Wx::GridCellAttr->new if $col == 8; # Even rows and even cols - default format
  return ($grid->{float} );#	# Even rows and even cols - default format
}
#sub SetColAttr {
#   my ($grid, $attr, $col) = @_;
#   $attr=$grid->{float}; 
#   $$grid{coldata}->[$col]->{attr} = $attr;
#   return;
#} 

sub SetColLabelValue {	# Copied from the wiki for custom labels
   my ($grid, $col, $value) = @_;
   $col = $grid->_checkCol($col);
   return unless defined $col;
   $$grid{coldata}->[$col]->{label} = $value;
}

sub GetColLabelValue {	# Copied from the wiki for custom labels
   my ($grid, $col) = @_;
   $col = $grid->_checkCol($col);
   return undef unless defined $col;
   return $$grid{coldata}->[$col]->{label};
}

sub _checkCol {	# Copied from the wiki for custom labels
   my ($grid, $col) = @_;
   my $cols = $grid->GetNumberCols;
   return undef unless defined $col && abs($col) < $cols;
   return $cols + $col if $col < 0;
   return $col;
}
sub SetRowLabelValue {	# Modeled after the wiki for custom labels
   my ($grid, $row, $value) = @_;
   $row = $grid->_checkRow($row);
   return unless defined $row;
   $$grid{rowdata}->[$row]->{label} = $value;
}
sub SetRowAttr {	# Modeled after the wiki for custom labels
   my ($grid, $attr, $row) = @_;
   $row = $grid->_checkRow($row);
   return unless defined $row;
   $$grid{rowdata}->[$row]->{attr} = $attr;
  
}

sub GetRowLabelValue {	# Modeled after the wiki for custom labels
   my ($grid, $row) = @_;
   $row = $grid->_checkRow($row);
   return undef unless defined $row;
   return $$grid{rowdata}->[$row]->{label};
}

sub _checkRow {	# Modeled after the wiki for custom labels
   my ($grid, $row) = @_;
   my $rows = $grid->GetNumberRows;
   return undef unless defined $row && abs($row) < $rows;
   return $rows + $row if $row < 0;
   return $row;
}
sub Total_Col {
     my ($grid, $col,$nomenclatuur) = @_;
     my $onderste_rij= $grid->GetNumberRows;
     $nomenclatuur=$grid->GetRowLabelValue(1) if (!defined $nomenclatuur) ;
     my $tot_nomen=$grid->GetRowLabelValue($onderste_rij-1);
     my $totaal = 0;
     my $deler =0;
     for (my $tel_rij=0; $tel_rij<$onderste_rij-1;$tel_rij += 1) {
         if ($col==1 and $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$tel_rij][1] > 0 ) {
           $deler +=1;
           $totaal +=$main::overzicht_per_nomenclatuur->{$nomenclatuur}[$tel_rij][$col];
         }else {
           $totaal +=$main::overzicht_per_nomenclatuur->{$nomenclatuur}[$tel_rij][$col];
         }
     }
     $deler = 1 if ($deler == 0);
     $totaal = $totaal /$deler if ($col==1);
     $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$onderste_rij-1][$col]=$totaal;
     #bepaal nomenclatuur rij
     for (my $row =0; $row < $main::aantal_rij_overzicht_matrix; $row+=1) {
         if ($nomenclatuur eq $main::overzicht_matrix[$row][1] and $nomenclatuur >= 1) {
            my $col1=0;
            if ($col <8) {
               $col1 = $col + 2;#code
            }else {
                $col1 =$col+2+5;
            }
            
             
             #my $tegoed = beslissing_formule->new ($nomenclatuur,$totaal,$col1,$row);
             $main::overzicht_matrix[$row][$col1] = $totaal if ($nomenclatuur >= 1);
             #hier moet de calculator komen niet de goede plaats gaat per kolom
           
             #print "";
         }
         
     }
    
     #my $test = $main::overzicht_per_nomenclatuur;
     #print"";
}
sub Toolbar_Herbereken {
        my ($class,$grid, $nomenclatuur,$force_pas_totaalwerkblad_aan) = @_;
        $grid->Herberekenen($nomenclatuur,'',$force_pas_totaalwerkblad_aan);
}

sub Herberekenen {
       my ($grid, $nomenclatuur,$soort_werkblad,$force_pas_totaalwerkblad_aan) = @_;
       #if ($nomenclatuur == 882001) {
       #             print '';
       #          }
       if ($main::type_grid{$nomenclatuur} eq 'VnZ') {
               
          }else {
       $nomenclatuur=$grid->GetRowLabelValue(1) if (!defined $nomenclatuur) ;
       my $onderste_rij= $grid->GetNumberRows;
       my $dienst=$main::dienst;
       my $har1 =  $main::overzicht_per_nomenclatuur;
       $soort_werkblad = $main::rekenregels_per_nomenclatuur->{$nomenclatuur}->{soort_werkblad};
       #my $har1 =  $main::overzicht_per_nomenclatuur->{$nomenclatuur};
      
       ##weghalen vink op overzicht
       for  (my $overzicht_rij =0 ; $overzicht_rij < $main::aantal_rij_overzicht_matrix; $overzicht_rij++) {
           if ($main::overzicht_matrix[$overzicht_rij][1] == $nomenclatuur and $nomenclatuur > 1 ) {
                $main::overzicht_matrix[$overzicht_rij][13] = 0;#code            
               }
          }
       for (my $rij =0; $rij < $onderste_rij-1 ; $rij++){
           $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][8]='';
           $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][6]=0;
           $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][7]=0;
           #$main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][9]=0;           
           $grid->Kolom_twee_plus_drie_is_vier($rij,$nomenclatuur) if (lc $soort_werkblad ne 'groepsregel');
           $grid->vul_kolomen_in_een_twee_honderd_percent($rij,$nomenclatuur) if (lc $soort_werkblad ne 'groepsregel');
          }
       #my $har =  $main::overzicht_per_nomenclatuur->{$nomenclatuur}[33][4];
       #$har1 =  $main::overzicht_per_nomenclatuur->{$nomenclatuur}[0][4];
       $grid->Total_Col(0,$nomenclatuur);
       $grid->Total_Col(2,$nomenclatuur);
       $grid->Total_Col(3,$nomenclatuur);
       $grid->Total_Col(4,$nomenclatuur);
       $grid->Total_Col(5,$nomenclatuur);
       $grid->Total_Col(6,$nomenclatuur);
       $grid->Total_Col(7,$nomenclatuur);
       $grid->Total_Col(9,$nomenclatuur);
       $grid->Total_Col(10,$nomenclatuur);
       #$har =  $main::overzicht_per_nomenclatuur->{$nomenclatuur}[33][4];
       #$har1 =  $main::overzicht_per_nomenclatuur->{$nomenclatuur}[0][4];
       eval {my $bestaat = $main::teksten_gebruikte_rekenregels_per_nomenclatuur->{$nomenclatuur}[0]};
       if (!$@) {
           foreach my $nr (keys $main::teksten_gebruikte_rekenregels_per_nomenclatuur->{$nomenclatuur}) {
                delete $main::teksten_gebruikte_rekenregels_per_nomenclatuur->{$nomenclatuur}[$nr];
               }
          }
       
     
       for (my $rij =0; $rij < $onderste_rij-1 ; $rij++){
           $grid->toegelaten_toeslagen($rij,$nomenclatuur);
           $grid->maximum_bedrag_per_dag($rij,$nomenclatuur);
           $grid->maximum_bedrag_per_dag_totaal($rij,$nomenclatuur);
           $grid->eenmalig_bedrag_jaar($rij,$nomenclatuur);
           $grid->maximum_bedrag_per_jaar($rij,$nomenclatuur);
           $grid->maximum_leeftijd ($rij,$nomenclatuur);
           $grid->eenmalig_bedrag($rij,$nomenclatuur);
           $grid->vast_bedrag_per_dag($rij,$nomenclatuur);
           $grid->maximum_aantal_dagen_per_jaar($rij,$nomenclatuur);
           $grid->hospi_tsk($rij,$nomenclatuur);
           $grid->voeg_dienst_toe ($rij,$nomenclatuur);
          }
     
      #$har =  $main::overzicht_per_nomenclatuur->{$nomenclatuur}[33][4];
      #$har1 =  $main::overzicht_per_nomenclatuur->{$nomenclatuur}[0][4];
       for (my $rij =0; $rij < $onderste_rij-1 ; $rij++){
            if ($main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][9] >0 and $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][8] eq '') {
                $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][9] = 0;
                $grid->Total_Col(9,$nomenclatuur);
                $grid->hospi_tsk($rij,$nomenclatuur);
               }
          }
      #my $test = $main::overzicht_per_nomenclatuur;
     
      $grid->pas_dienst_werkbladen_aan if (lc ($soort_werkblad) ne 'dienst' and lc ($soort_werkblad) ne 'groepsregel');
      $grid->pas_totaal_werkblad_aan if (lc ($soort_werkblad) ne 'dienst' and lc ($soort_werkblad) ne 'groepsregel');
      $grid->pas_totaal_werkblad_aan if ($force_pas_totaalwerkblad_aan ==1);
      $main::hospi_tussenkomst = $main::overzicht_per_nomenclatuur->{999999}[($onderste_rij-1)][4]+$main::overzicht_per_nomenclatuur->{999999}[($onderste_rij-1)][6] ; #rechtzetting onderste lijn
      print "\n________________\nmain::hospi_tussenkomst $main::hospi_tussenkomst\n_______________________\n";
      my $rounded_hospi_tussenkomst = sprintf("%.3f", $main::hospi_tussenkomst);
      $main::hospi_tussenkomsttxtctrl->SetValue("$rounded_hospi_tussenkomst");
      $main::verschil=0;
      
      foreach my $verschil_nom (keys $main::rekenregels_per_nomenclatuur) {
           $main::verschil +=$main::overzicht_per_nomenclatuur->{$verschil_nom}[($onderste_rij-1)][7];
      }
      $main::verschil_txtctrl->SetValue("$main::verschil" );
      Overzicht_GridApp->refresh_grid($main::grid_Overzicht);
      my @naarwaar = $grid->overname_aantal_dagen($onderste_rij-1,$nomenclatuur);
     if ($naarwaar[0] != 0) {
           foreach my $nom (@naarwaar) {
                $grid->Herberekenen($nom) if ($nom != 1) ;
          }
      }else {
          my $test = $main::rekenregels_per_nomenclatuur;
          foreach my $nom_test (keys $main::rekenregels_per_nomenclatuur) {
               if ($nomenclatuur == $main::rekenregels_per_nomenclatuur->{$nom_test}->{ja_nee_nom} and $nom_test > 0 ) {
                     @naarwaar = $grid->overname_aantal_dagen($onderste_rij-1,$nom_test);
                     if ($naarwaar[0] != 0) {
                              foreach my $nom (@naarwaar) {
                                   $grid->Herberekenen($nom) if ($nom != 1) ;
                              }
                         }
               }
          }           
      }
      my $naam_verzekering ='';
         for (my $i=0; $i < 4; $i++) {
             if ($main::contracts_check[$i] == 1) {
                 $naam_verzekering = uc ($main::klant->{contracten}->[$i]->{naam});
                }
            }
         if ($naam_verzekering =~ m/forfait/i or $naam_verzekering =~ m/continue/i) {
              $main::aantal_dagen_betaald = $main::hospi_tussenkomst /$main::prijs_per_dag_forfait if ($main::prijs_per_dag_forfait > 0) ;
            }else {
             $main::aantal_dagen_betaald = '';
            }  
      
      $main::verschil_dagen_betaald_txtctrl->SetValue("$main::aantal_dagen_betaald");
      return ($nomenclatuur);
       }
     }
sub  voeg_dienst_toe {
      my ($grid,$rij,$nomenclatuur) = @_;
      $nomenclatuur=$grid->GetRowLabelValue(1) if (!defined $nomenclatuur) ;
      my $onderste_rij= $grid->GetNumberRows;
      my $dienst=$main::dienst;
      my $test =$main::overzicht_per_nomenclatuur;
      if (defined $dienst) {
           if (defined $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][6] and $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][6] != 0) {
                $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][13]=$dienst if (!defined $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][13]) ;#code#code
               }
          }
      print '';
     }
sub pas_dienst_werkbladen_aan {
      my ($grid) = @_;
      my $rijenteller;
      my $onderste_rij= $grid->GetNumberRows;
      my $cols =$grid->GetNumberCols;
      my @veranderde_diensten;
      foreach my $nomenclatuur (keys $main::rekenregels_per_nomenclatuur) {
           if (lc ($main::rekenregels_per_nomenclatuur->{$nomenclatuur}->{soort_werkblad}) eq  'dienst') {
                for (my $clear_rij = 0;$clear_rij< $onderste_rij ; $clear_rij++) {
                                    $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$clear_rij][4]=0;
                                    $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$clear_rij][0]=0;
                                   }
                $grid->Total_Col(4,$nomenclatuur);
               }
          }
      foreach my $nomenclatuur (keys $main::rekenregels_per_nomenclatuur) {
           if (lc ($main::rekenregels_per_nomenclatuur->{$nomenclatuur}->{soort_werkblad}) eq  'standaard' or lc ($main::rekenregels_per_nomenclatuur->{$nomenclatuur}->{soort_werkblad}) eq  'vnz') {
                my $verkorte_naam_dienst='';                
                for (my $rij =0; $rij < $onderste_rij-1 ; $rij++){
                     $verkorte_naam_dienst = $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][13];
                     if (defined $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][6] and $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][6] != 0
                          and $verkorte_naam_dienst  ~~ @main::diensten ) {
                          my $nomenclatuur_dienst = $main::nomenclatuur_per_verkorte_naam{$verkorte_naam_dienst};
                          if (defined ($rijenteller->{$nomenclatuur_dienst})) {
                               $rijenteller->{$nomenclatuur_dienst} +=1;
                              }else {
                               $rijenteller->{$nomenclatuur_dienst} =0;
                               
                              }
                          #for (my $kolom = 2 ; $kolom < 8; $kolom++) {
                               $main::overzicht_per_nomenclatuur->{$nomenclatuur_dienst}[$rijenteller->{$nomenclatuur_dienst}][4]=$main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][6];
                               $main::overzicht_per_nomenclatuur->{$nomenclatuur_dienst}[$rijenteller->{$nomenclatuur_dienst}][0]=$main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][0]; #dagen hospiforfait
                               if ($nomenclatuur_dienst ~~ @veranderde_diensten) {
                                    #doe niets
                                   }else {
                                    push (@veranderde_diensten,$nomenclatuur_dienst) ;
                                   }
                             
                             # }
                         }
                     
                    }
               }
           
          }
      my @threads;
      foreach my $nomencla (@veranderde_diensten) {
           if (lc ($main::rekenregels_per_nomenclatuur->{$nomencla}->{soort_werkblad}) eq  'dienst') {
                $grid->Herberekenen($nomencla,'dienst');
                
               }
          }
      #$main::grid_Detail->ForceRefresh();
      print "";
     }
sub pas_totaal_werkblad_aan {
      my ($grid,$nomenclatuur) = @_;
      my $rijenteller;
      my $onderste_rij= $grid->GetNumberRows;
      my $cols =$grid->GetNumberCols;
      #my @nomenclaturen_te_tellen;
      #my $groeps_nomeclatuur = 999999;
      #if ($nomenclatuur ~~ @main::recuperatie_van_ziekenfonds and  $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$onderste_rij-1][6] != 0 ) {
      #    print ''; 
      #}
      my $rijteller =0;
      #my $test = $main::nomenclaturen_per_groepsregel;
      foreach my $groeps_nomeclatuur (sort keys  $main::nomenclaturen_per_groepsregel) {
           if ($groeps_nomeclatuur == 999999) {
                #my $test2 =  $main::overzicht_per_nomenclatuur;
                foreach my $te_tellen_nom (@{$main::nomenclaturen_per_groepsregel->{$groeps_nomeclatuur}}) {           
                     if ($main::rekenregels_per_nomenclatuur->{$te_tellen_nom}->{soort_werkblad} =~  m/dienst/i or
                          $main::rekenregels_per_nomenclatuur->{$te_tellen_nom}->{soort_werkblad} =~  m/groepsregel/i ) {
                          $main::overzicht_per_nomenclatuur->{$groeps_nomeclatuur}[$rijteller][0]= 0;
                          #print "$groeps_nomeclatuur >$test4< niet genomen $te_tellen_nom $rijteller dagen $main::overzicht_per_nomenclatuur->{$te_tellen_nom}[$onderste_rij-1][0]\n";#niets doen
                         }else {
                           $main::overzicht_per_nomenclatuur->{$groeps_nomeclatuur}[$rijteller][0]= $main::overzicht_per_nomenclatuur->{$te_tellen_nom}[$onderste_rij-1][0];
                          #print "$groeps_nomeclatuur >$test4< genomen $te_tellen_nom  $rijteller dagen $main::overzicht_per_nomenclatuur->{$te_tellen_nom}[$onderste_rij-1][0]\n";
                         }           
                     $main::overzicht_per_nomenclatuur->{$groeps_nomeclatuur}[$rijteller][4]= $main::overzicht_per_nomenclatuur->{$te_tellen_nom}[$onderste_rij-1][6];
                     #my $har =  $main::overzicht_per_nomenclatuur->{$groeps_nomeclatuur}[$rijteller][4];
                     $rijteller +=1 if ((defined $main::overzicht_per_nomenclatuur->{$te_tellen_nom}[$onderste_rij-1][0] and $main::overzicht_per_nomenclatuur->{$te_tellen_nom}[$onderste_rij-1][0] != 0)
                              or (defined $main::overzicht_per_nomenclatuur->{$te_tellen_nom}[$onderste_rij-1][6] and $main::overzicht_per_nomenclatuur->{$te_tellen_nom}[$onderste_rij-1][6] != 0 ));
                    }      
                $main::psk_plus_suppl = 0;
                foreach my $te_tellen_nom (@{$main::nomenclaturen_per_groepsregel->{$groeps_nomeclatuur}}) {           
                     if ($main::rekenregels_per_nomenclatuur->{$te_tellen_nom}->{soort_werkblad} =~  m/dienst/i or
                          $main::rekenregels_per_nomenclatuur->{$te_tellen_nom}->{soort_werkblad} =~  m/groepsregel/i ) {
                          # tellen niet mee
                         }else {
                          $main::psk_plus_suppl += $main::overzicht_per_nomenclatuur->{$te_tellen_nom}[$onderste_rij-1][4];
                         }
                    }      
                $main::frame->{lov_Txt_Ptsk_suppl}->SetValue($main::psk_plus_suppl);
                $grid->Herberekenen($groeps_nomeclatuur,'dienst');
                #$test2 =  $main::overzicht_per_nomenclatuur;
                #print "test2->{999999}->[0]-[4]  $test2->{'999999'}->[0]->[4]\n";
                # print "test2->{999999}->[1]-[4]  $test2->{'999999'}->[1]->[4]\n";
                # print "test2->{999999}->[2]-[4]  $test2->{'999999'}->[2]->[4]\n";
                # print "test2->{999999}->[3]-[4]  $test2->{'999999'}->[3]->[4]\n";
                #  print "test2->{999999}->[4]-[4]  $test2->{'999999'}->[4]->[4]\n";
                #   print "test2->{999999}->[5]-[4]  $test2->{'999999'}->[5]->[4]\n";
                #   print "test2->{999999}->[6]-[4]  $test2->{'999999'}->[6]->[4]\n";
                #   print "__________________________________________________________\n\n";
                #   if ($test2->{999999}->[3]-[4] > 19) {
                #         print "";
                #   }
                #
               }elsif ($groeps_nomeclatuur != 999999 and defined $groeps_nomeclatuur and $groeps_nomeclatuur > 1 and $main::type_grid{$nomenclatuur} ne 'VnZ' ) {
                my $rijteller1 = 0;                
                foreach my $te_tellen_nom (@{$main::nomenclaturen_per_groepsregel->{$groeps_nomeclatuur}}) {
                      if ($main::rekenregels_per_nomenclatuur->{$te_tellen_nom}->{soort_werkblad} =~  m/dienst/i or
                          $main::rekenregels_per_nomenclatuur->{$te_tellen_nom}->{soort_werkblad} =~  m/groepsregel/i ) {
                           $main::overzicht_per_nomenclatuur->{$groeps_nomeclatuur}[$rijteller1][0]= 0;
                         }else {
                          $main::overzicht_per_nomenclatuur->{$groeps_nomeclatuur}[$rijteller1][0] =0;
                          $main::overzicht_per_nomenclatuur->{$groeps_nomeclatuur}[$rijteller1][2] =0;
                          $main::overzicht_per_nomenclatuur->{$groeps_nomeclatuur}[$rijteller1][0] += $main::overzicht_per_nomenclatuur->{$te_tellen_nom}[$onderste_rij-1][0];
                          $main::overzicht_per_nomenclatuur->{$groeps_nomeclatuur}[$rijteller1][2] += $main::overzicht_per_nomenclatuur->{$te_tellen_nom}[$onderste_rij-1][6];
                          $grid->Kolom_twee_plus_drie_is_vier($rijteller1,$groeps_nomeclatuur);
                          $rijteller1 += 1;
                         }
                    }
                if (defined $groeps_nomeclatuur and $groeps_nomeclatuur > 1 and $main::type_grid{$nomenclatuur} ne 'VnZ') {
                     $main::frame->{lov_Txt_Ptsk_suppl}->SetValue($main::psk_plus_suppl);               
                     $grid->Total_Col(0,$groeps_nomeclatuur);
                     $grid->Total_Col(2,$groeps_nomeclatuur);
                     $grid->Total_Col(4,$groeps_nomeclatuur);
                     $grid->Herberekenen($groeps_nomeclatuur,'');
                     print 
                    }
               }
          }
     }
sub Kolom_twee_plus_drie_is_vier {
     my ($grid, $rij,$nomenclatuur)  = @_;
     $nomenclatuur=$grid->GetRowLabelValue(1) if (!defined $nomenclatuur) ;
     my $soort_werkblad = $main::rekenregels_per_nomenclatuur->{$nomenclatuur}->{soort_werkblad};
     if (lc ($soort_werkblad) eq 'dienst') {
          #code
     }else {
      $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][4]=$main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][2]+$main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][3];
      
     }
     
    
}
sub vul_kolomen_in_een_twee_honderd_percent {
      my ($grid, $rij,$nomenclatuur)  = @_;
      $nomenclatuur=$grid->GetRowLabelValue(1) if (!defined $nomenclatuur) ;
      if ($main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][11] > 0) {
           #doe niets#code
      }elsif ($main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][5] > 0) {
           $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][11] = $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][5];
           $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][12] = $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][5]*2;
      }
      
}
sub hospi_tsk {
      my ($grid, $rij,$nomenclatuur) = @_;
      $nomenclatuur=$grid->GetRowLabelValue(1) if (!defined $nomenclatuur) ;
      my $aanvaard  = $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][9];
      
      my $geweigerd = $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][10];
      my $verschil = $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][7];
      my $soort_werkblad = $main::rekenregels_per_nomenclatuur->{$nomenclatuur}->{soort_werkblad};
      $grid->Total_Col(9,$nomenclatuur);
      $grid->Total_Col(10,$nomenclatuur);
      my $onderste_rij= $grid->GetNumberRows;
      my $laatste = 0;
      $aanvaard  =  $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$onderste_rij-1][9];
      #test aanvaard
      if ($main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][9] >0) {
           print "";
      }
      
      if (lc ($soort_werkblad) eq 'dienst' ) {
           $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][6]=-$main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][7]
           +$main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][9]-$main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][10];
          }elsif (lc $soort_werkblad eq 'groepsregel') {
           $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][6] =  -$main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][7];  #code
          }else {          
           $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][6]=$main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][4]-$main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][5]
           -$main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][7]+$main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][9]-$main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][10];        
                  
          }
      $grid->Kolom_twee_plus_drie_is_vier($rij) if (lc $soort_werkblad ne 'groepsregel');   
     }
sub hospi_tsk_zonder_verschil {
      my ($grid, $rij, $nomenclatuur) = @_;
      $nomenclatuur=$grid->GetRowLabelValue(1) if (!defined $nomenclatuur) ;
      my $soort_werkblad = $main::rekenregels_per_nomenclatuur->{$nomenclatuur}->{soort_werkblad};
      if (lc ($soort_werkblad) eq 'dienst') {
           $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][6]=$main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][6];
          }else {
            $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][6]=$main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][4]-$main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][5];
          }
     }
sub maximum_bedrag_per_dag{
     my ($grid, $rij,$nomenclatuur) = @_;
     $nomenclatuur=$grid->GetRowLabelValue(1) if (!defined $nomenclatuur)  ;
     #$grid->Kolom_twee_plus_drie_is_vier($rij);
     #$grid->hospi_tsk_zonder_verschil($rij);
     #my $test=$main::overzicht_per_nomenclatuur;
     my $totaal_rij= $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][3]  ; #maximum bedrag per dag gaat over supplement was ervoor [$rij][4] 
     my $aantal_dagen = $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][0];
     my $betrag_per_dag= $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][1];
     if ($aantal_dagen > 0 and $totaal_rij == 0 and $betrag_per_dag > 0 ) {
           #maximum per dag gaat over supplementen dus we mogen de personlijke tyssenkomst niet overzetten en geld de regel niet (dubbel met kamers en dienst)
           $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][3] = $aantal_dagen*$betrag_per_dag if ($main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][2] ==0) ;
     }elsif ($aantal_dagen > 0 and $totaal_rij > 0  ) { #and $betrag_per_dag == 0
           $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][1] = $totaal_rij/$aantal_dagen;
           $betrag_per_dag= $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][1];
     }
     foreach my $regel (keys $main::rekenregels_per_nomenclatuur->{$nomenclatuur}) {
      if ($regel eq 'maximum_bedrag_per_dag') {
           my $maximum_bedrag_per_dag = $main::rekenregels_per_nomenclatuur->{$nomenclatuur}->{$regel};#code
           if ($main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][1] > $maximum_bedrag_per_dag ) {
                my $verschil = $aantal_dagen*$betrag_per_dag - $maximum_bedrag_per_dag*$aantal_dagen;
                $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][7] =$verschil;
                $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][8] ="$regel :$maximum_bedrag_per_dag";
                #foreach my $tekst (keys $main::teksten_gebruikte_rekenregels_per_nomenclatuur->{$nomenclatuur}) {
                #      delete $main::teksten_gebruikte_rekenregels_per_nomenclatuur->{$nomenclatuur}->{$tekst};
                #}
                foreach my $regel1 (keys $main::tekst_rekenregels_per_nomenclatuur->{$nomenclatuur}) {
                     if ($regel1 eq 'maximum_bedrag_per_dag') {
                           if (lc ($main::klant->{Taal}) eq 'nl') {
                               my $tekst =  $main::tekst_rekenregels_per_nomenclatuur->{$nomenclatuur}->{$regel1}->{tekst};
                               my $tekst_bestaat_al = 0;
                               foreach my $nr (keys $main::teksten_gebruikte_rekenregels_per_nomenclatuur->{$nomenclatuur}) {
                                    $tekst_bestaat_al =  1 if ($main::teksten_gebruikte_rekenregels_per_nomenclatuur->{$nomenclatuur}[$nr]  == $tekst );
                                   }
                               push (@{$main::teksten_gebruikte_rekenregels_per_nomenclatuur->{$nomenclatuur}},$tekst) if ($tekst_bestaat_al ==0) ;
                              }elsif (lc ($main::klant->{Taal}) eq 'fr') {                               
                               my $tekst =  $main::tekst_rekenregels_per_nomenclatuur->{$nomenclatuur}->{$regel1}->{tekst_fr};
                               my $tekst_bestaat_al = 0;
                               foreach my $nr (keys $main::teksten_gebruikte_rekenregels_per_nomenclatuur->{$nomenclatuur}) {
                                    $tekst_bestaat_al =  1 if ($main::teksten_gebruikte_rekenregels_per_nomenclatuur->{$nomenclatuur}[$nr]  == $tekst );
                                   }
                               push (@{$main::teksten_gebruikte_rekenregels_per_nomenclatuur->{$nomenclatuur}},$tekst) if ($tekst_bestaat_al ==0)  ;
                              } 
                         }
                    }
                   
                for  (my $overzicht_rij =0 ; $overzicht_rij < $main::aantal_rij_overzicht_matrix; $overzicht_rij++) {
                     if ($main::overzicht_matrix[$overzicht_rij][1] == $nomenclatuur and $nomenclatuur > 1) {
                          $main::overzicht_matrix[$overzicht_rij][13] = 1;#code
                         }
                    }
                $grid->hospi_tsk($rij);
               }
          }
     }
      $grid->Total_Col(7,$nomenclatuur);
      $grid->Total_Col(6,$nomenclatuur);
}
sub maximum_bedrag_per_dag_totaal{
     my ($grid, $rij,$nomenclatuur) = @_;
     $nomenclatuur=$grid->GetRowLabelValue(1) if (!defined $nomenclatuur)  ;
     #$grid->Kolom_twee_plus_drie_is_vier($rij);
     #$grid->hospi_tsk_zonder_verschil($rij);
     
     my $totaal_rij= $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][4]  ; #maximum bedrag per dag gaat over supplement was ervoor [$rij][4] 
     my $aantal_dagen = $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][0];
     my $betrag_per_dag= $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][1];
     if ($aantal_dagen > 0 and $totaal_rij == 0 and $betrag_per_dag > 0 ) {
           $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][3] = $aantal_dagen*$betrag_per_dag;
     }elsif ($aantal_dagen > 0 and $totaal_rij > 0  ) { #and $betrag_per_dag == 0
           $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][1] = $totaal_rij/$aantal_dagen;
           $betrag_per_dag= $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][1];
     }
     my $test=$main::rekenregels_per_nomenclatuur;
     if  ($nomenclatuur == 882055) {
           my $test=$main::rekenregels_per_nomenclatuur;
           print '';
     }
     foreach my $regel (keys $main::rekenregels_per_nomenclatuur->{$nomenclatuur}) {          
      if ($regel eq 'maximum_totaal_bedrag_per_dag') {
           my $maximum_bedrag_per_dag = $main::rekenregels_per_nomenclatuur->{$nomenclatuur}->{$regel};#code
           if ($main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][1] > $maximum_bedrag_per_dag ) {
                my $verschil = $aantal_dagen*$betrag_per_dag - $maximum_bedrag_per_dag*$aantal_dagen;
                $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][7] =$verschil;
                $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][8] ="$regel :$maximum_bedrag_per_dag";
                #foreach my $tekst (keys $main::teksten_gebruikte_rekenregels_per_nomenclatuur->{$nomenclatuur}) {
                #      delete $main::teksten_gebruikte_rekenregels_per_nomenclatuur->{$nomenclatuur}->{$tekst};
                #}
                foreach my $regel1 (keys $main::tekst_rekenregels_per_nomenclatuur->{$nomenclatuur}) {
                     if ($regel1 eq 'maximum_bedrag_per_dag') {
                           if (lc ($main::klant->{Taal}) eq 'nl') {
                               my $tekst =  $main::tekst_rekenregels_per_nomenclatuur->{$nomenclatuur}->{$regel1}->{tekst};
                               my $tekst_bestaat_al = 0;
                               foreach my $nr (keys $main::teksten_gebruikte_rekenregels_per_nomenclatuur->{$nomenclatuur}) {
                                    $tekst_bestaat_al =  1 if ($main::teksten_gebruikte_rekenregels_per_nomenclatuur->{$nomenclatuur}[$nr]  == $tekst );
                                   }
                               push (@{$main::teksten_gebruikte_rekenregels_per_nomenclatuur->{$nomenclatuur}},$tekst) if ($tekst_bestaat_al ==0) ;
                              }elsif (lc ($main::klant->{Taal}) eq 'fr') {                               
                               my $tekst =  $main::tekst_rekenregels_per_nomenclatuur->{$nomenclatuur}->{$regel1}->{tekst_fr};
                               my $tekst_bestaat_al = 0;
                               foreach my $nr (keys $main::teksten_gebruikte_rekenregels_per_nomenclatuur->{$nomenclatuur}) {
                                    $tekst_bestaat_al =  1 if ($main::teksten_gebruikte_rekenregels_per_nomenclatuur->{$nomenclatuur}[$nr]  == $tekst );
                                   }
                               push (@{$main::teksten_gebruikte_rekenregels_per_nomenclatuur->{$nomenclatuur}},$tekst) if ($tekst_bestaat_al ==0)  ;
                              } 
                         }
                    }
                   
                for  (my $overzicht_rij =0 ; $overzicht_rij < $main::aantal_rij_overzicht_matrix; $overzicht_rij++) {
                     if ($main::overzicht_matrix[$overzicht_rij][1] == $nomenclatuur and $nomenclatuur > 1) {
                          $main::overzicht_matrix[$overzicht_rij][13] = 1;#code
                         }
                    }
                $grid->hospi_tsk($rij);
               }
          }
     }
      $grid->Total_Col(7,$nomenclatuur);
      $grid->Total_Col(6,$nomenclatuur);
}
sub eenmalig_bedrag_jaar {
      my ($grid, $rij,$nomenclatuur) = @_;
      $nomenclatuur=$grid->GetRowLabelValue(1) if (!defined $nomenclatuur) ;
      my $k_jaar = 0;
      my $rows = $grid->GetNumberRows;
      my $verschil =0;
      my $eenmalig_bedrag_jaar=0;
      my $is_bevalling = $main::is_bevalling;
      foreach my $regel (keys $main::rekenregels_per_nomenclatuur->{$nomenclatuur}) {
           if ($regel eq 'eenmalig_bedrag_jaar') {
                #if ($nomenclatuur==882206 or $nomenclatuur==882000 ){                   
                #    my $test =  $main::overzicht_per_nomenclatuur->{$nomenclatuur};
                #    my $testbegind = $main::begindatum_opname;
                #    print '';
                #}
                $eenmalig_bedrag_jaar = $main::rekenregels_per_nomenclatuur->{$nomenclatuur}->{$regel};#code
                if ($is_bevalling > 0 and $nomenclatuur==882206 and $main::begindatum_opname > 20240000) { # geen franchise bij bevalling na 2024
                     $eenmalig_bedrag_jaar = 0;
                    
                }
                for  (my $overzicht_rij =0 ; $overzicht_rij < $main::aantal_rij_overzicht_matrix; $overzicht_rij++) {
                     if ($main::overzicht_matrix[$overzicht_rij][1] == $nomenclatuur and $nomenclatuur > 1) {
                          $k_jaar = $main::overzicht_matrix[$overzicht_rij][10];#code
                         }
                    }
                $verschil= $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rows-1][7];
                if ((abs($verschil) + abs($k_jaar)) > $eenmalig_bedrag_jaar-1) {
                     $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][2] =0;#code
                     $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][3] =0;
                     $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][7]=0;
                     $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][6]=0;
                     if ($nomenclatuur==882206 and $is_bevalling == 260 and $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][0] > 0
                         and $main::begindatum_opname > 20240000) {                        
                          #bevalling vanaf 2024 geen franchise
                          $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][8] ="Geen franchische Bevalling na 2024";
                          $main::is_bevalling = 0;
                     }
                }elsif ($main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][0] > 0) {
                     $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][2] =0;#code
                     $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][3] =0;
                     $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][7]=$eenmalig_bedrag_jaar;
                     $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][6]=-$eenmalig_bedrag_jaar;
                     $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][8] ="$regel :$eenmalig_bedrag_jaar";                     
                     foreach my $regel1 (keys $main::tekst_rekenregels_per_nomenclatuur->{$nomenclatuur}) {
                          if ($regel1 eq 'eenmalig_bedrag_jaar') {
                               if (lc ($main::klant->{Taal}) eq 'nl') {
                                    my $tekst =  $main::tekst_rekenregels_per_nomenclatuur->{$nomenclatuur}->{$regel1}->{tekst};
                                    my $tekst_bestaat_al = 0;
                                    foreach my $nr (keys $main::teksten_gebruikte_rekenregels_per_nomenclatuur->{$nomenclatuur}) {
                                          $tekst_bestaat_al =  1 if ($main::teksten_gebruikte_rekenregels_per_nomenclatuur->{$nomenclatuur}[$nr]  == $tekst );
                                        }
                                     push (@{$main::teksten_gebruikte_rekenregels_per_nomenclatuur->{$nomenclatuur}},$tekst) if ($tekst_bestaat_al == 0);
                                   }elsif (lc ($main::klant->{Taal}) eq 'fr') { 
                                     my $tekst =  $main::tekst_rekenregels_per_nomenclatuur->{$nomenclatuur}->{$regel1}->{tekst_fr};
                                     my $tekst_bestaat_al = 0;
                                     foreach my $nr (keys $main::teksten_gebruikte_rekenregels_per_nomenclatuur->{$nomenclatuur}) {
                                         $tekst_bestaat_al =  1 if ($main::teksten_gebruikte_rekenregels_per_nomenclatuur->{$nomenclatuur}[$nr]  == $tekst );
                                        }
                                    push (@{$main::teksten_gebruikte_rekenregels_per_nomenclatuur->{$nomenclatuur}},$tekst) if ($tekst_bestaat_al == 0);
                                   } 
                              }
                         }
                     for  (my $overzicht_rij =0 ; $overzicht_rij < $main::aantal_rij_overzicht_matrix; $overzicht_rij++) {
                          if ($main::overzicht_matrix[$overzicht_rij][1] == $nomenclatuur and $nomenclatuur > 1) {
                               $main::overzicht_matrix[$overzicht_rij][13] = 1;#code
                              }
                         }
                }else {
                    $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][2] =0;#code
                    $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][3] =0;
                    $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][7]=0;
                    $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][6]=0;
                    
                }
               
                $grid->Kolom_twee_plus_drie_is_vier($rij);
               }
          }
      
      
     }
sub eenmalig_bedrag {
      my ($grid, $rij,$nomenclatuur) = @_;
      $nomenclatuur=$grid->GetRowLabelValue(1) if (!defined $nomenclatuur) ;
      my $soort_werkblad = $main::rekenregels_per_nomenclatuur->{$nomenclatuur}->{soort_werkblad};      
      my $k_jaar = 0;
      my $rows = $grid->GetNumberRows;
      my $verschil =0;
      my $eenmalig_bedrag=0;
      foreach my $regel (keys $main::rekenregels_per_nomenclatuur->{$nomenclatuur}) {
           if ($regel eq 'eenmalig_bedrag') {
                 if (lc ($soort_werkblad) eq 'dienst' or lc ($soort_werkblad) eq 'groepsregel') {
                      $grid->Total_Col(4,$nomenclatuur);
                      $grid->Total_Col(6,$nomenclatuur);
                      my $eenmalig_bedrag = $main::rekenregels_per_nomenclatuur->{$nomenclatuur}->{$regel};#code
                      my $tussenkomst_hospi_totaal = $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rows-1][4]+$main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rows-1][6];
                      for (my $overzicht_rij =0 ; $overzicht_rij < $main::aantal_rij_overzicht_matrix; $overzicht_rij++) {
                          if ($main::overzicht_matrix[$overzicht_rij][1] == $nomenclatuur ) {
                               if (lc ($soort_werkblad) eq 'dienst') {
                                      $k_jaar = sprintf "%.0f", ($main::overzicht_matrix[$overzicht_rij][11]/1000);#code kjaar zit eigen lijk bij de dagen
                                      my $berek = sprintf "%.0f", ($main::overzicht_matrix[$overzicht_rij][6]-$main::overzicht_matrix[$overzicht_rij][9]);
                                      my $dagen = sprintf '%3d',  $main::overzicht_matrix[$overzicht_rij][2] % 1000;                                      
                                      $berek = $berek*1000 +$dagen ;
                                      $main::overzicht_matrix[$overzicht_rij][2] =  $berek;# getal naar dagen
                                   }else {
                                      $k_jaar = $main::overzicht_matrix[$overzicht_rij][10];#code kjaar zit eigen lijk bij de dagen
                                   }
                              }
                         }
                      my $test_totaal =$main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][4];
                      if (($tussenkomst_hospi_totaal+$k_jaar) > $eenmalig_bedrag and $test_totaal >0 ) {
                          my $verschil = $tussenkomst_hospi_totaal - $eenmalig_bedrag+$k_jaar;
                          my $bestaand_verschil =$main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][7];
                          $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][7] =$verschil;#code $bestaand_verschil+
                          $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][2] = $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][2] -$verschil*1000;
                          foreach my $regel1 (keys $main::tekst_rekenregels_per_nomenclatuur->{$nomenclatuur}) {
                               if ($regel1 eq 'eenmalig_bedrag') {
                                    if (lc ($main::klant->{Taal}) eq 'nl') {
                                         my $tekst =  $main::tekst_rekenregels_per_nomenclatuur->{$nomenclatuur}->{$regel1}->{tekst};
                                         my $tekst_bestaat_al = 0;
                                         foreach my $nr (keys $main::teksten_gebruikte_rekenregels_per_nomenclatuur->{$nomenclatuur}) {
                                              $tekst_bestaat_al =  1 if ($main::teksten_gebruikte_rekenregels_per_nomenclatuur->{$nomenclatuur}[$nr]  == $tekst );
                                             }
                                         push (@{$main::teksten_gebruikte_rekenregels_per_nomenclatuur->{$nomenclatuur}},$tekst) if ($tekst_bestaat_al == 0);
                                        }elsif (lc ($main::klant->{Taal}) eq 'fr') { 
                                         my $tekst =  $main::tekst_rekenregels_per_nomenclatuur->{$nomenclatuur}->{$regel1}->{tekst_fr};
                                         my $tekst_bestaat_al = 0;
                                         foreach my $nr (keys $main::teksten_gebruikte_rekenregels_per_nomenclatuur->{$nomenclatuur}) {
                                              $tekst_bestaat_al =  1 if ($main::teksten_gebruikte_rekenregels_per_nomenclatuur->{$nomenclatuur}[$nr]  == $tekst );
                                             }
                                         push (@{$main::teksten_gebruikte_rekenregels_per_nomenclatuur->{$nomenclatuur}},$tekst) if ($tekst_bestaat_al == 0);
                                        } 
                                   }
                              }
                         }
                    }else {
                       $grid->hospi_tsk_zonder_verschil($rij,$nomenclatuur);
                       $grid->Total_Col(6,$nomenclatuur);
                       my $eenmalig_bedrag = $main::rekenregels_per_nomenclatuur->{$nomenclatuur}->{$regel};#code
                       my $tussenkomst_hospi_totaal = $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rows-1][6];
                       for  (my $overzicht_rij =0 ; $overzicht_rij < $main::aantal_rij_overzicht_matrix; $overzicht_rij++) {
                          if ($main::overzicht_matrix[$overzicht_rij][1] == $nomenclatuur and $nomenclatuur > 1) {
                               $k_jaar = $main::overzicht_matrix[$overzicht_rij][10];#code
                              }
                         }
                       my $test_totaal =$main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][4];
                       if (($tussenkomst_hospi_totaal+$k_jaar) > $eenmalig_bedrag and $test_totaal >0 ) {
                          my $verschil = $tussenkomst_hospi_totaal - $eenmalig_bedrag+$k_jaar;
                          my $bestaand_verschil =$main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][7];
                          $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][7] =$verschil;#code $bestaand_verschil+
                          foreach my $regel1 (keys $main::tekst_rekenregels_per_nomenclatuur->{$nomenclatuur}) {
                               if ($regel1 eq 'eenmalig_bedrag') {
                                    if (lc ($main::klant->{Taal}) eq 'nl') {
                                         my $tekst =  $main::tekst_rekenregels_per_nomenclatuur->{$nomenclatuur}->{$regel1}->{tekst};
                                         my $tekst_bestaat_al = 0;
                                         foreach my $nr (keys $main::teksten_gebruikte_rekenregels_per_nomenclatuur->{$nomenclatuur}) {
                                              $tekst_bestaat_al =  1 if ($main::teksten_gebruikte_rekenregels_per_nomenclatuur->{$nomenclatuur}[$nr]  == $tekst );
                                             }
                                         push (@{$main::teksten_gebruikte_rekenregels_per_nomenclatuur->{$nomenclatuur}},$tekst) if ($tekst_bestaat_al == 0);
                                        }elsif (lc ($main::klant->{Taal}) eq 'fr') { 
                                         my $tekst =  $main::tekst_rekenregels_per_nomenclatuur->{$nomenclatuur}->{$regel1}->{tekst_fr};
                                         my $tekst_bestaat_al = 0;
                                         foreach my $nr (keys $main::teksten_gebruikte_rekenregels_per_nomenclatuur->{$nomenclatuur}) {
                                              $tekst_bestaat_al =  1 if ($main::teksten_gebruikte_rekenregels_per_nomenclatuur->{$nomenclatuur}[$nr]  == $tekst );
                                             }
                                         push (@{$main::teksten_gebruikte_rekenregels_per_nomenclatuur->{$nomenclatuur}},$tekst) if ($tekst_bestaat_al == 0);
                                        } 
                                   }
                              }
                          for  (my $overzicht_rij =0 ; $overzicht_rij < $main::aantal_rij_overzicht_matrix; $overzicht_rij++) {
                               if ($main::overzicht_matrix[$overzicht_rij][1] == $nomenclatuur and $nomenclatuur > 1) {
                                     $main::overzicht_matrix[$overzicht_rij][13] = 1;#code
                                   }                     
                              }
                          $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][8] ="$regel :$eenmalig_bedrag";
                          $grid->hospi_tsk($rij,$nomenclatuur);
                         }
                    }               
               }
           $grid->Total_Col(7,$nomenclatuur);
          }
     }
sub vast_bedrag_per_dag {
      my ($grid, $rij,$nomenclatuur) = @_;
      $nomenclatuur=$grid->GetRowLabelValue(1) if (!defined $nomenclatuur)  ;
      my $soort_werkblad = $main::rekenregels_per_nomenclatuur->{$nomenclatuur}->{soort_werkblad};
      my $rows = $grid->GetNumberRows;
      foreach my $regel (keys $main::rekenregels_per_nomenclatuur->{$nomenclatuur}) {
           if ($regel eq 'vast_bedrag_per_dag') {
                my $carensdagen_te_gaan = 0;
                my $vast_bedrag_per_dag = $main::rekenregels_per_nomenclatuur->{$nomenclatuur}->{$regel};#code
                my $d_jaar = 0;
                my $carensdagen1=$main::carensdagen;
                my $leeftijd = $main::leeftijd ;
                $main::prijs_per_dag_forfait = $vast_bedrag_per_dag ;
                #
                if ($main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][0] > 0 or $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][4] > 0 ) {
                     $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][1] = $vast_bedrag_per_dag;
                     $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][2] = $vast_bedrag_per_dag *  $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][0];
                     $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][3] = 0;
                     my $soort_werkblad = $main::rekenregels_per_nomenclatuur->{$nomenclatuur}->{soort_werkblad};
                     $grid->Kolom_twee_plus_drie_is_vier($rij,$nomenclatuur) if (lc $soort_werkblad ne 'groepsregel');
                     foreach my $regel1 (keys $main::tekst_rekenregels_per_nomenclatuur->{$nomenclatuur}) {
                          if ($regel1 eq 'vast_bedrag_per_dag') {
                               if (lc ($main::klant->{Taal}) eq 'nl') {
                                    my $tekst =  $main::tekst_rekenregels_per_nomenclatuur->{$nomenclatuur}->{$regel1}->{tekst};
                                    my $tekst_bestaat_al = 0;
                                    foreach my $nr (keys $main::teksten_gebruikte_rekenregels_per_nomenclatuur->{$nomenclatuur}) {
                                         $tekst_bestaat_al =  1 if ($main::teksten_gebruikte_rekenregels_per_nomenclatuur->{$nomenclatuur}[$nr]  == $tekst );
                                        }
                                     push (@{$main::teksten_gebruikte_rekenregels_per_nomenclatuur->{$nomenclatuur}},$tekst) if ($tekst_bestaat_al ==0);
                                   }elsif (lc ($main::klant->{Taal}) eq 'fr') { 
                                    my $tekst =  $main::tekst_rekenregels_per_nomenclatuur->{$nomenclatuur}->{$regel1}->{tekst_fr};
                                    my $tekst_bestaat_al = 0;
                                    foreach my $nr (keys $main::teksten_gebruikte_rekenregels_per_nomenclatuur->{$nomenclatuur}) {
                                         $tekst_bestaat_al =  1 if ($main::teksten_gebruikte_rekenregels_per_nomenclatuur->{$nomenclatuur}[$nr]  == $tekst );
                                        }
                                    push (@{$main::teksten_gebruikte_rekenregels_per_nomenclatuur->{$nomenclatuur}},$tekst) if ($tekst_bestaat_al == 0);
                                   } 
                              }
                         }
                     for  (my $overzicht_rij =0 ; $overzicht_rij < $main::aantal_rij_overzicht_matrix; $overzicht_rij++) {
                          if ($main::overzicht_matrix[$overzicht_rij][1] == $nomenclatuur and $nomenclatuur > 1) {
                               $main::overzicht_matrix[$overzicht_rij][13] = 1;#code
                              }                     
                         }
                     $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][8] ="$regel :$vast_bedrag_per_dag";
                     #
                     #
                     if (defined $main::rekenregels_per_nomenclatuur->{$nomenclatuur}->{carensdagen} and $main::carensdagen > 0){
                          for  (my $overzicht_rij =0 ; $overzicht_rij < $main::aantal_rij_overzicht_matrix; $overzicht_rij++) {
                               if ($main::overzicht_matrix[$overzicht_rij][1] == $nomenclatuur ) {
                                    $d_jaar = $main::overzicht_matrix[$overzicht_rij][11];#code
                                   }
                              }
                          $carensdagen_te_gaan = $main::carensdagen -$d_jaar;
                          $carensdagen_te_gaan = 0 if ( $carensdagen_te_gaan < 0);
                          my $te_tellen_dagen = 0;
                          my $eerste_rij_nul =0;
                          if ($carensdagen_te_gaan > 0) {
                               for (my $telrij = 0;$telrij < $rows-1;$telrij++ ) {
                                    $te_tellen_dagen += $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$telrij][0] if ($main::overzicht_per_nomenclatuur->{$nomenclatuur}[$telrij][0] > 0) ;
                                    if ($main::overzicht_per_nomenclatuur->{$nomenclatuur}[$telrij][0] <= 0) {
                                         $eerste_rij_nul = $telrij;
                                         last;
                                        }
                                   }
                               if ($te_tellen_dagen >= $carensdagen_te_gaan) {
                                     $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$eerste_rij_nul][1] = $vast_bedrag_per_dag;
                                     $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$eerste_rij_nul][0] = -$carensdagen_te_gaan;
                                     $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$eerste_rij_nul][2] = $vast_bedrag_per_dag *  $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$eerste_rij_nul][0];
                                     $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$eerste_rij_nul][4] = $vast_bedrag_per_dag *  $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$eerste_rij_nul][0];
                                   }else {
                                    $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$eerste_rij_nul][1] = $vast_bedrag_per_dag;
                                    $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$eerste_rij_nul][0] = -$te_tellen_dagen;
                                    $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$eerste_rij_nul][2] = $vast_bedrag_per_dag *  $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$eerste_rij_nul][0];
                                    $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$eerste_rij_nul][4] = $vast_bedrag_per_dag *  $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$eerste_rij_nul][0];
                                   }
                               foreach my $regel1 (keys $main::tekst_rekenregels_per_nomenclatuur->{$nomenclatuur}) {
                                    if ($regel1 eq 'carensdagen') {
                                         if (lc ($main::klant->{Taal}) eq 'nl') {
                                              my $tekst =  $main::tekst_rekenregels_per_nomenclatuur->{$nomenclatuur}->{$regel1}->{tekst};
                                              my $tekst_bestaat_al = 0;
                                              foreach my $nr (keys $main::teksten_gebruikte_rekenregels_per_nomenclatuur->{$nomenclatuur}) {
                                                   $tekst_bestaat_al =  1 if ($main::teksten_gebruikte_rekenregels_per_nomenclatuur->{$nomenclatuur}[$nr]  == $tekst );
                                                  }
                                              push (@{$main::teksten_gebruikte_rekenregels_per_nomenclatuur->{$nomenclatuur}},$tekst) if ($tekst_bestaat_al ==0);
                                             }elsif (lc ($main::klant->{Taal}) eq 'fr') { 
                                              my $tekst =  $main::tekst_rekenregels_per_nomenclatuur->{$nomenclatuur}->{$regel1}->{tekst_fr};
                                              my $tekst_bestaat_al = 0;
                                              foreach my $nr (keys $main::teksten_gebruikte_rekenregels_per_nomenclatuur->{$nomenclatuur}) {
                                                   $tekst_bestaat_al =  1 if ($main::teksten_gebruikte_rekenregels_per_nomenclatuur->{$nomenclatuur}[$nr]  == $tekst );
                                                  }
                                              push (@{$main::teksten_gebruikte_rekenregels_per_nomenclatuur->{$nomenclatuur}},$tekst) if ($tekst_bestaat_al == 0);
                                             } 
                                        }
                                   }
                               for  (my $overzicht_rij =0 ; $overzicht_rij < $main::aantal_rij_overzicht_matrix; $overzicht_rij++) {
                                    if ($main::overzicht_matrix[$overzicht_rij][1] == $nomenclatuur and $nomenclatuur > 1) {
                                         $main::overzicht_matrix[$overzicht_rij][15] = 1;#code
                                        }                     
                                   }
                               $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$eerste_rij_nul][8] ="carensdagen"; 
                              }
                         }    
                     $grid->hospi_tsk($rij,$nomenclatuur);
                    }
               }
          }
     }
sub maximum_bedrag_per_jaar {
      my ($grid, $rij,$nomenclatuur) = @_;
      #my $test = $main::type_grid{$nomenclatuur} ;
      #$nomenclaturen_per_groepsregel
      if ($main::type_grid{$nomenclatuur} eq 'VnZ') {

          }else {
           $nomenclatuur=$grid->GetRowLabelValue(1) if (!defined $nomenclatuur)  ;
           my $k_jaar = 0;
           my $rows = $grid->GetNumberRows;
           my $verschil =0;
           my $soort_werkblad = $main::rekenregels_per_nomenclatuur->{$nomenclatuur}->{soort_werkblad};      
           foreach my $regel (keys $main::rekenregels_per_nomenclatuur->{$nomenclatuur}) {
                if ($regel eq 'maximum_bedrag_per_jaar') {
                     if (lc ($soort_werkblad) eq 'dienst' or lc ($soort_werkblad) eq 'groepsregel') {
                          $grid->Total_Col(4,$nomenclatuur);
                          $grid->Total_Col(6,$nomenclatuur);
                          #$grid->Total_Col(9,$nomenclatuur);
                          #my $onderste_rij= $grid->GetNumberRows;
                          #my $aanvaard  =  $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$onderste_rij-1][9];
                          my $maximum_bedrag_per_jaar = $main::rekenregels_per_nomenclatuur->{$nomenclatuur}->{$regel};#code
                          #$maximum_bedrag_per_jaar +=$aanvaard;
                          my $tussenkomst_hospi_totaal = $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rows-1][4]+$main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rows-1][6];
                          for (my $overzicht_rij =0 ; $overzicht_rij < $main::aantal_rij_overzicht_matrix; $overzicht_rij++) {
                               if ($main::overzicht_matrix[$overzicht_rij][1] == $nomenclatuur ) {
                                    if (lc ($soort_werkblad) eq 'dienst') {
                                         $k_jaar = sprintf "%.0f", ($main::overzicht_matrix[$overzicht_rij][11]/1000);#code kjaar zit eigen lijk bij de dagen                                         
                                         #my $htest = $main::overzicht_matrix[$overzicht_rij][6]-$main::overzicht_matrix[$overzicht_rij][9];
                                         #if ($nomenclatuur == 882137 and $htest >0){
                                         #    print "";
                                         #}
                                         my $berek = sprintf "%.0f", ($main::overzicht_matrix[$overzicht_rij][6]-$main::overzicht_matrix[$overzicht_rij][9]);
                                         my $dagen = sprintf '%3d',  $main::overzicht_matrix[$overzicht_rij][2] % 1000;
                                         $berek = $berek*1000 +$dagen ;
                                         $main::overzicht_matrix[$overzicht_rij][2] =  $berek;# getal naar dagen
                                        }else {
                                         $k_jaar = $main::overzicht_matrix[$overzicht_rij][10];#code kjaar zit eigen lijk bij de dagen
                                        }
                                  
                                   }
                              }
                          my $test_totaal =$main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][4];
                          if (($tussenkomst_hospi_totaal+$k_jaar) > $maximum_bedrag_per_jaar and $test_totaal >0 ) {
                               my $verschil = $tussenkomst_hospi_totaal +$k_jaar- $maximum_bedrag_per_jaar ;  #dienst +$k_jaar
                               my $bestaand_verschil =$main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][7];
                               $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][7] =$verschil;
                                $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][2] = $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][2] -$verschil*1000;
                               foreach my $regel1 (keys $main::tekst_rekenregels_per_nomenclatuur->{$nomenclatuur}) {
                                    if ($regel1 eq 'maximum_bedrag_per_jaar') {
                                         if (lc ($main::klant->{Taal}) eq 'nl') {
                                              my $tekst =  $main::tekst_rekenregels_per_nomenclatuur->{$nomenclatuur}->{$regel1}->{tekst};
                                              my $tekst_bestaat_al = 0;
                                              eval {my $bestaat = $main::teksten_gebruikte_rekenregels_per_nomenclatuur->{$nomenclatuur}[0] };
                                              if (!$@) {
                                                   foreach my $nr (keys $main::teksten_gebruikte_rekenregels_per_nomenclatuur->{$nomenclatuur}) {
                                                        $tekst_bestaat_al =  1 if ($main::teksten_gebruikte_rekenregels_per_nomenclatuur->{$nomenclatuur}[$nr]  == $tekst );
                                                       }
                                                  }
                                              push (@{$main::teksten_gebruikte_rekenregels_per_nomenclatuur->{$nomenclatuur}},$tekst) if ($tekst_bestaat_al == 0);
                                            }elsif (lc ($main::klant->{Taal}) eq 'fr') { 
                                              my $tekst =  $main::tekst_rekenregels_per_nomenclatuur->{$nomenclatuur}->{$regel1}->{tekst_fr};
                                              my $tekst_bestaat_al = 0;
                                              eval {my $bestaat = $main::teksten_gebruikte_rekenregels_per_nomenclatuur->{$nomenclatuur}[0] };
                                              if (!$@) {
                                                   foreach my $nr (keys $main::teksten_gebruikte_rekenregels_per_nomenclatuur->{$nomenclatuur}) {
                                                        $tekst_bestaat_al =  1 if ($main::teksten_gebruikte_rekenregels_per_nomenclatuur->{$nomenclatuur}[$nr]  == $tekst );
                                                       }
                                                  }
                                              push (@{$main::teksten_gebruikte_rekenregels_per_nomenclatuur->{$nomenclatuur}},$tekst) if ($tekst_bestaat_al == 0);
                                             } 
                                        }
                                   }
                               for  (my $overzicht_rij =0 ; $overzicht_rij < $main::aantal_rij_overzicht_matrix; $overzicht_rij++) {
                                    if ($main::overzicht_matrix[$overzicht_rij][1] == $nomenclatuur and $nomenclatuur > 1) {
                                         $main::overzicht_matrix[$overzicht_rij][13] = 1;#code
                                        }                     
                                   } 
                               $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][8] ="$regel :$maximum_bedrag_per_jaar";
                               $grid->hospi_tsk($rij,$nomenclatuur);
                              }
                          $grid->Total_Col(7,$nomenclatuur);
                         }else {
                          $grid->Total_Col(9,$nomenclatuur);
                          my $onderste_rij= $grid->GetNumberRows;
                          my $aanvaard  =  $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$onderste_rij-1][9];
                          #$grid->Kolom_twee_plus_drie_is_vier($rij,$nomenclatuur);
                          $grid->hospi_tsk_zonder_verschil($rij,$nomenclatuur);
                          $grid->Total_Col(6,$nomenclatuur);
                          #$grid->Total_Col(6,$nomenclatuur);
                          my $maximum_bedrag_per_jaar = $main::rekenregels_per_nomenclatuur->{$nomenclatuur}->{$regel};#code
                          $maximum_bedrag_per_jaar +=$aanvaard;
                          my $tussenkomst_hospi_totaal = $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rows-1][6];
                          for  (my $overzicht_rij =0 ; $overzicht_rij < $main::aantal_rij_overzicht_matrix; $overzicht_rij++) {
                               if ($main::overzicht_matrix[$overzicht_rij][1] == $nomenclatuur and $nomenclatuur > 1) {
                                    $k_jaar = $main::overzicht_matrix[$overzicht_rij][10];#code
                                   }
                              }
                          my $test_totaal =$main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][4];
                          if (($tussenkomst_hospi_totaal+$k_jaar) > $maximum_bedrag_per_jaar and $test_totaal >0 ) {
                               my $verschil = $tussenkomst_hospi_totaal +$k_jaar- $maximum_bedrag_per_jaar ;  #dienst +$k_jaar
                               my $bestaand_verschil =$main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][7];
                               $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][7] =$verschil;#code $bestaand_verschil+
                               foreach my $regel1 (keys $main::tekst_rekenregels_per_nomenclatuur->{$nomenclatuur}) {
                                    if ($regel1 eq 'maximum_bedrag_per_jaar') {
                                         if (lc ($main::klant->{Taal}) eq 'nl') {
                                              my $tekst =  $main::tekst_rekenregels_per_nomenclatuur->{$nomenclatuur}->{$regel1}->{tekst};
                                              my $tekst_bestaat_al = 0;
                                              #my $test = $main::teksten_gebruikte_rekenregels_per_nomenclatuur;
                                              #my $tekst_array = $main::teksten_gebruikte_rekenregels_per_nomenclatuur->{$nomenclatuur};
                                              foreach my $nr (keys $main::teksten_gebruikte_rekenregels_per_nomenclatuur->{$nomenclatuur}) {
                                                   $tekst_bestaat_al =  1 if ($main::teksten_gebruikte_rekenregels_per_nomenclatuur->{$nomenclatuur}[$nr]  == $tekst );
                                                  }
                                              push (@{$main::teksten_gebruikte_rekenregels_per_nomenclatuur->{$nomenclatuur}},$tekst) if ($tekst_bestaat_al == 0);
                                             }elsif (lc ($main::klant->{Taal}) eq 'fr') { 
                                              my $tekst =  $main::tekst_rekenregels_per_nomenclatuur->{$nomenclatuur}->{$regel1}->{tekst_fr};
                                              my $tekst_bestaat_al = 0;
                                              foreach my $nr (keys $main::teksten_gebruikte_rekenregels_per_nomenclatuur->{$nomenclatuur}) {
                                                   $tekst_bestaat_al =  1 if ($main::teksten_gebruikte_rekenregels_per_nomenclatuur->{$nomenclatuur}[$nr]  == $tekst );
                                                  }
                                              push (@{$main::teksten_gebruikte_rekenregels_per_nomenclatuur->{$nomenclatuur}},$tekst) if ($tekst_bestaat_al == 0);
                                            } 
                                        }
                                   }
                               for  (my $overzicht_rij =0 ; $overzicht_rij < $main::aantal_rij_overzicht_matrix; $overzicht_rij++) {
                                    if ($main::overzicht_matrix[$overzicht_rij][1] == $nomenclatuur ) {
                                         $main::overzicht_matrix[$overzicht_rij][13] = 1;#code
                                        }                     
                                   }
                              $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][8] ="$regel :$maximum_bedrag_per_jaar";
                              $grid->hospi_tsk($rij,$nomenclatuur);
                             }
                          $grid->Total_Col(7,$nomenclatuur);
                         }
                    }
              } 
           #my $tekst_array = $main::teksten_gebruikte_rekenregels_per_nomenclatuur;
           print "";
          }
     }
sub toegelaten_toeslagen {
      my ($grid, $rij,$nomenclatuur) = @_;
      $nomenclatuur=$grid->GetRowLabelValue(1) if (!defined $nomenclatuur)  ;
      my $k_jaar = 0;
      my $rows = $grid->GetNumberRows;
      my $verschil =0;
      
      foreach my $regel (keys $main::rekenregels_per_nomenclatuur->{$nomenclatuur}) {
           if ($regel eq 'toegelaten_toeslagen') {
                my $percentage = $main::rekenregels_per_nomenclatuur->{$nomenclatuur}->{$regel};
                if ($percentage == 100) {
                     if ( $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][3] > $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][11]) {
                          my $bestaand_verschil = $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][7];
                          my $verschil = $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][3]-$main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][11];#code
                          $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][7] = $verschil ;#+ $bestaand_verschil;
                          $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][8] ="$regel :$percentage %";
                          foreach my $regel1 (keys $main::tekst_rekenregels_per_nomenclatuur->{$nomenclatuur}) {
                               if ($regel1 eq 'toegelaten_toeslagen') {
                                    if (lc ($main::klant->{Taal}) eq 'nl') {
                                         my $tekst =  $main::tekst_rekenregels_per_nomenclatuur->{$nomenclatuur}->{$regel1}->{tekst};
                                         my $tekst_bestaat_al = 0;
                                         foreach my $nr (keys $main::teksten_gebruikte_rekenregels_per_nomenclatuur->{$nomenclatuur}) {
                                              $tekst_bestaat_al =  1 if ($main::teksten_gebruikte_rekenregels_per_nomenclatuur->{$nomenclatuur}[$nr]  == $tekst );
                                             }
                                         push (@{$main::teksten_gebruikte_rekenregels_per_nomenclatuur->{$nomenclatuur}},$tekst) if ($tekst_bestaat_al == 0);
                                        }elsif (lc ($main::klant->{Taal}) eq 'fr') { 
                                         my $tekst =  $main::tekst_rekenregels_per_nomenclatuur->{$nomenclatuur}->{$regel1}->{tekst_fr};
                                         my $tekst_bestaat_al = 0;
                                         foreach my $nr (keys $main::teksten_gebruikte_rekenregels_per_nomenclatuur->{$nomenclatuur}) {
                                              $tekst_bestaat_al =  1 if ($main::teksten_gebruikte_rekenregels_per_nomenclatuur->{$nomenclatuur}[$nr]  == $tekst );
                                             }
                                         push (@{$main::teksten_gebruikte_rekenregels_per_nomenclatuur->{$nomenclatuur}},$tekst) if ($tekst_bestaat_al == 0) ;
                                        } 
                                   }
                              }
                          for  (my $overzicht_rij =0 ; $overzicht_rij < $main::aantal_rij_overzicht_matrix; $overzicht_rij++) {
                               if ($main::overzicht_matrix[$overzicht_rij][1] == $nomenclatuur and $nomenclatuur > 1) {
                                    $main::overzicht_matrix[$overzicht_rij][13] = 1;#code
                                   }                     
                              }
                         }
                    }elsif ($percentage == 200){
                      if ( $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][3] > $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][12]) {
                          my $bestaand_verschil = $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][7];
                          my $verschil = $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][3]-$main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][12];#code
                          $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][7] = $verschil ;#+ $bestaand_verschil;
                          $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][8] ="$regel :$percentage %";
                          foreach my $regel1 (keys $main::tekst_rekenregels_per_nomenclatuur->{$nomenclatuur}) {
                               if ($regel1 eq 'toegelaten_toeslagen') {
                                    if (lc ($main::klant->{Taal}) eq 'nl') {
                                         my $tekst =  $main::tekst_rekenregels_per_nomenclatuur->{$nomenclatuur}->{$regel1}->{tekst};
                                         my $tekst_bestaat_al = 0;
                                         foreach my $nr (keys $main::teksten_gebruikte_rekenregels_per_nomenclatuur->{$nomenclatuur}) {
                                              $tekst_bestaat_al =  1 if ($main::teksten_gebruikte_rekenregels_per_nomenclatuur->{$nomenclatuur}[$nr]  == $tekst );
                                             }
                                          push (@{$main::teksten_gebruikte_rekenregels_per_nomenclatuur->{$nomenclatuur}},$tekst) if ($tekst_bestaat_al == 0);
                                        }elsif (lc ($main::klant->{Taal}) eq 'fr') { 
                                         my $tekst =  $main::tekst_rekenregels_per_nomenclatuur->{$nomenclatuur}->{$regel1}->{tekst_fr};
                                         my $tekst_bestaat_al = 0;
                                         foreach my $nr (keys $main::teksten_gebruikte_rekenregels_per_nomenclatuur->{$nomenclatuur}) {
                                              $tekst_bestaat_al =  1 if ($main::teksten_gebruikte_rekenregels_per_nomenclatuur->{$nomenclatuur}[$nr]  == $tekst );
                                             }
                                         push (@{$main::teksten_gebruikte_rekenregels_per_nomenclatuur->{$nomenclatuur}},$tekst) if ($tekst_bestaat_al == 0);
                                        } 
                                   }
                              }
                          for  (my $overzicht_rij =0 ; $overzicht_rij < $main::aantal_rij_overzicht_matrix; $overzicht_rij++) {
                               if ($main::overzicht_matrix[$overzicht_rij][1] == $nomenclatuur and $nomenclatuur > 1) {
                                    $main::overzicht_matrix[$overzicht_rij][13] = 1;#code
                                   }                     
                              }
                         } 
                    }else {
                     #doe niets
                    }
               }
          }
     }
sub maximum_aantal_dagen_per_jaar {
      my ($grid, $rij,$nomenclatuur) = @_;
      $nomenclatuur=$grid->GetRowLabelValue(1) if (!defined $nomenclatuur)  ;
      my $d_jaar = 0;
      my $rows = $grid->GetNumberRows;
      my $verschil =0;
      my $soort_werkblad = $main::rekenregels_per_nomenclatuur->{$nomenclatuur}->{soort_werkblad};
      my $al_afgehouden_dagen = 0; #afgehouden in de groep
      foreach my $regel (keys $main::rekenregels_per_nomenclatuur->{$nomenclatuur}) {
           if ($regel eq 'maximum_aantal_dagen_per_jaar') {
                my $maximum_aantal_dagen_per_jaar = $main::rekenregels_per_nomenclatuur->{$nomenclatuur}->{$regel};#code
                for  (my $overzicht_rij =0 ; $overzicht_rij < $main::aantal_rij_overzicht_matrix; $overzicht_rij++) {
                          if ($main::overzicht_matrix[$overzicht_rij][1] == $nomenclatuur and $nomenclatuur > 1) {
                               $d_jaar = $main::overzicht_matrix[$overzicht_rij][11];#code
                              }
                         }
                my $dagen = $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][0];
                 my $totaal_dagen=0;
                for (my $rijteller =0;$rijteller <= $rij;$rijteller++ ) {
                     $totaal_dagen += $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rijteller][0]
                }
                $totaal_dagen += $d_jaar;
                if ($soort_werkblad =~ m/groepsregel/i) {
                     my $overschreden = 0;
                     my $dagen_overzicht =0;
                     foreach my $rij1 (keys $main::nomenclaturen_per_groepsregel->{$nomenclatuur}) {
                          my $nomcl = $main::nomenclaturen_per_groepsregel->{$nomenclatuur}->[$rij1];
                          my $soort_werkblad1 = $main::rekenregels_per_nomenclatuur->{$nomcl}->{soort_werkblad}; 
                          if ($soort_werkblad1 =~ m/dienst/i) {
                               $dagen_overzicht =0;
                               for  (my $overzicht_rij =0 ; $overzicht_rij < $main::aantal_rij_overzicht_matrix; $overzicht_rij++) {
                                    if ($main::overzicht_matrix[$overzicht_rij][1] == $nomcl and $nomcl > 1) {
                                         my $berek = sprintf '%3d',  $main::overzicht_matrix[$overzicht_rij][2] % 1000; # drie laaste cijfers zijn de dagen in het overzicht 
                                         $dagen_overzicht  = $berek;#code
                                        }
                                   }
                               if ($dagen_overzicht > $maximum_aantal_dagen_per_jaar and $dagen !=0 ) {
                                    my $teveel = $dagen_overzicht-$maximum_aantal_dagen_per_jaar;
                                    $totaal_dagen -= $teveel;
                                    print "" ;
                                   }
                               
                              }                          
                         }
                    }
                my $prijs_per_dag = 0;
                if ($totaal_dagen > $maximum_aantal_dagen_per_jaar and $dagen !=0 ) {
                     $grid->hospi_tsk_zonder_verschil($rij,$nomenclatuur);
                     $prijs_per_dag = $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][4] /$dagen;  
                     $main::prijs_per_dag_forfait = $prijs_per_dag ;
                     my $aantal_dagen = $totaal_dagen - $maximum_aantal_dagen_per_jaar;
                     $aantal_dagen = $dagen if ($aantal_dagen > $dagen  );
                     my $verschil = $aantal_dagen*$prijs_per_dag ;
                     $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][7] = $verschil ;
                     foreach my $regel1 (keys $main::tekst_rekenregels_per_nomenclatuur->{$nomenclatuur}) {
                          if ($regel1 eq 'maximum_aantal_dagen_per_jaar') {
                                if (lc ($main::klant->{Taal}) eq 'nl') {
                                    my $tekst =  $main::tekst_rekenregels_per_nomenclatuur->{$nomenclatuur}->{$regel1}->{tekst};
                                    my $tekst_bestaat_al = 0;
                                    foreach my $nr (keys $main::teksten_gebruikte_rekenregels_per_nomenclatuur->{$nomenclatuur}) {
                                         $tekst_bestaat_al =  1 if ($main::teksten_gebruikte_rekenregels_per_nomenclatuur->{$nomenclatuur}[$nr]  == $tekst );
                                        }
                                    push (@{$main::teksten_gebruikte_rekenregels_per_nomenclatuur->{$nomenclatuur}},$tekst) if ($tekst_bestaat_al == 0);
                                   }elsif (lc ($main::klant->{Taal}) eq 'fr') { 
                                    my $tekst =  $main::tekst_rekenregels_per_nomenclatuur->{$nomenclatuur}->{$regel1}->{tekst_fr};
                                    my $tekst_bestaat_al = 0;
                                    foreach my $nr (keys $main::teksten_gebruikte_rekenregels_per_nomenclatuur->{$nomenclatuur}) {
                                         $tekst_bestaat_al =  1 if ($main::teksten_gebruikte_rekenregels_per_nomenclatuur->{$nomenclatuur}[$nr]  == $tekst );
                                        }
                                    push (@{$main::teksten_gebruikte_rekenregels_per_nomenclatuur->{$nomenclatuur}},$tekst) if ($tekst_bestaat_al == 0);
                                   } 
                              }
                         }
                     for  (my $overzicht_rij =0 ; $overzicht_rij < $main::aantal_rij_overzicht_matrix; $overzicht_rij++) {
                               if ($main::overzicht_matrix[$overzicht_rij][1] == $nomenclatuur and $nomenclatuur > 1) {
                                    $main::overzicht_matrix[$overzicht_rij][15] = 1;#code
                                   }                     
                              }
                      $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][8] ="$regel:$maximum_aantal_dagen_per_jaar";
                     $grid->hospi_tsk($rij,$nomenclatuur);
                    }
               }
          }
     }


sub maximum_leeftijd {
      my ($grid, $rij,$nomenclatuur) = @_;
      $nomenclatuur=$grid->GetRowLabelValue(1) if (!defined $nomenclatuur)  ;
      foreach my $regel (keys $main::rekenregels_per_nomenclatuur->{$nomenclatuur}) {
           if ($regel eq 'maximum_leeftijd') {
                my $maximum_leeftijd =  $main::rekenregels_per_nomenclatuur->{$nomenclatuur}->{$regel};
                if ($main::leeftijd > $maximum_leeftijd  and ($main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][0] >0 or $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][4] >0 )) {
                     $grid->hospi_tsk_zonder_verschil($rij,$nomenclatuur);
                     my $verschil = $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][6];
                     $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][7] = $verschil;
                     $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][8] ="$regel :$maximum_leeftijd";
                     foreach my $regel1 (keys $main::tekst_rekenregels_per_nomenclatuur->{$nomenclatuur}) {
                          if ($regel1 eq 'maximum_leeftijd') {
                                if (lc ($main::klant->{Taal}) eq 'nl') {
                                    my $tekst =  $main::tekst_rekenregels_per_nomenclatuur->{$nomenclatuur}->{$regel1}->{tekst};
                                    my $tekst_bestaat_al = 0;
                                    foreach my $nr (keys $main::teksten_gebruikte_rekenregels_per_nomenclatuur->{$nomenclatuur}) {
                                         $tekst_bestaat_al =  1 if ($main::teksten_gebruikte_rekenregels_per_nomenclatuur->{$nomenclatuur}[$nr]  == $tekst );
                                        }
                                    push (@{$main::teksten_gebruikte_rekenregels_per_nomenclatuur->{$nomenclatuur}},$tekst) if ($tekst_bestaat_al == 0);
                                   }elsif (lc ($main::klant->{Taal}) eq 'fr') { 
                                    my $tekst =  $main::tekst_rekenregels_per_nomenclatuur->{$nomenclatuur}->{$regel1}->{tekst_fr};
                                    my $tekst_bestaat_al = 0;
                                    foreach my $nr (keys $main::teksten_gebruikte_rekenregels_per_nomenclatuur->{$nomenclatuur}) {
                                         $tekst_bestaat_al =  1 if ($main::teksten_gebruikte_rekenregels_per_nomenclatuur->{$nomenclatuur}[$nr]  == $tekst );
                                        }
                                    push (@{$main::teksten_gebruikte_rekenregels_per_nomenclatuur->{$nomenclatuur}},$tekst) if ($tekst_bestaat_al == 0);
                                   } 
                              }
                         }
                     for  (my $overzicht_rij =0 ; $overzicht_rij < $main::aantal_rij_overzicht_matrix; $overzicht_rij++) {
                          if ($main::overzicht_matrix[$overzicht_rij][1] == $nomenclatuur and $nomenclatuur > 1) {
                               $main::overzicht_matrix[$overzicht_rij][13] = 1;#code
                              }
                         }
                     $grid->hospi_tsk($rij);
                    }
               }
         }
}
sub overname_aantal_dagen {
      my ($grid, $rij,$nomenclatuur) = @_;
      $nomenclatuur=$grid->GetRowLabelValue(1) if (!defined $nomenclatuur)  ;
      my $er_is_overgedragen = 0;
      my @naarwaar = ();
      my @reset_naarwaar=();
      my $ja_nee_nom = 0;
      my $test_rekenregels = $main::rekenregels_per_nomenclatuur->{$nomenclatuur};
      #if ($nomenclatuur==882206 or $nomenclatuur==882000 ){
      #         print '';
      #    }
      #  
      foreach my $regel (keys $main::rekenregels_per_nomenclatuur->{$nomenclatuur}) {
               if ($regel eq  'ja_nee_nom'){
                    $ja_nee_nom = $main::rekenregels_per_nomenclatuur->{$nomenclatuur}->{ja_nee_nom};
               }
          } 
      foreach my $regel (keys $main::rekenregels_per_nomenclatuur->{$nomenclatuur}) {        

           if ($regel eq 'overname_aantal_dagen') {
                @naarwaar = split(/,/,$main::rekenregels_per_nomenclatuur->{$nomenclatuur}->{overname_aantal_dagen});
                my $laatste_rij = GetNumberRows;
                foreach my $naarwaar (@naarwaar) {
                      
                      my $over_te_nemen_aantal_dagen = $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$laatste_rij-1][0];
                      $main::overzicht_per_nomenclatuur->{$naarwaar}[0][0]=$over_te_nemen_aantal_dagen;
                      $er_is_overgedragen =1;
                    }
                
               }
           if ($regel eq 'ja_overname_aantal_dagen' and $ja_nee_nom > 0 and $er_is_overgedragen ==0) {
                    @naarwaar = split(/,/,$main::rekenregels_per_nomenclatuur->{$nomenclatuur}->{ja_overname_aantal_dagen});
                    @reset_naarwaar = split(/,/,$main::rekenregels_per_nomenclatuur->{$nomenclatuur}->{nee_overname_aantal_dagen});
                    my $laatste_rij = GetNumberRows;
                    my $ja = $main::overzicht_per_nomenclatuur->{$ja_nee_nom}[$laatste_rij-1][0];
                    if ($ja > 0) {
                         foreach my $reset_naarwaar (@reset_naarwaar) {
                              $main::overzicht_per_nomenclatuur->{$reset_naarwaar}[0][0]=0;
                              $grid->Herberekenen($reset_naarwaar[0]);
                              }
                         
                         foreach my $naarwaar (@naarwaar) {                      
                             my $over_te_nemen_aantal_dagen = $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$laatste_rij-1][0];
                             $main::overzicht_per_nomenclatuur->{$naarwaar}[0][0]=$over_te_nemen_aantal_dagen;
                             $er_is_overgedragen =1;
                         }
                    }else {
                          @naarwaar = () if ($er_is_overgedragen==0);
                    }
                   
                
               }
           if ($regel eq 'nee_overname_aantal_dagen' and $ja_nee_nom > 0 and  $er_is_overgedragen ==0) {
                    @naarwaar = split(/,/,$main::rekenregels_per_nomenclatuur->{$nomenclatuur}->{nee_overname_aantal_dagen});
                    @reset_naarwaar = split(/,/,$main::rekenregels_per_nomenclatuur->{$nomenclatuur}->{ja_overname_aantal_dagen});
                    my $laatste_rij = GetNumberRows;
                    my $ja = $main::overzicht_per_nomenclatuur->{$ja_nee_nom}[$laatste_rij-1][0];
                    if ($ja <= 0 or !defined $ja) {
                        foreach my $reset_naarwaar (@reset_naarwaar) {
                              $main::overzicht_per_nomenclatuur->{$reset_naarwaar}[0][0]=0;
                              $grid->Herberekenen($reset_naarwaar[0]);
                              }
                         foreach my $naarwaar (@naarwaar) {                      
                           my $over_te_nemen_aantal_dagen = $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$laatste_rij-1][0];
                           $main::overzicht_per_nomenclatuur->{$naarwaar}[0][0]=$over_te_nemen_aantal_dagen;
                           $er_is_overgedragen =1;
                         }
                    }else {
                          @naarwaar = () if ($er_is_overgedragen==0);
                    }
                
               }
          }
      return ($er_is_overgedragen,@naarwaar);
     }
sub wachttijd_per_nomenclatuur {
       my ($grid,$nomenclatuur,$value) = @_;
       $nomenclatuur=$grid->GetRowLabelValue(1) if (!defined $nomenclatuur)  ;
       my $naam_verzekering = '';
       my $startdatum_verzekering = '';
       my $wachtdatum_verzekering ='';
       my $einddatum_verzekering ='';
       my $zkf_nr_verzekering ='';
       #my @test = @main::contracts_check;
       #my $test1 = $main::klant;
       my $aantal_maanden_wachttijd =0;
          for (my $i=0; $i < 4; $i++) {
               if ($main::contracts_check[$i] == 1) {
                    $naam_verzekering = uc ($main::klant->{contracten}->[$i]->{naam});
                    $startdatum_verzekering = $main::klant->{contracten}->[$i]->{startdatum};
                    $wachtdatum_verzekering = $main::klant->{contracten}->[$i]->{wachtdatum};
                    $einddatum_verzekering = $main::klant->{contracten}->[$i]->{einddatum};
                    $zkf_nr_verzekering = $main::klant->{contracten}->[$i]->{zkf_nr};
                   }
              }
       #my $testr= $main::rekenregels_per_nomenclatuur->{$nomenclatuur};
       $aantal_maanden_wachttijd = $main::wachttijden_per_nomenclatuur->{$nomenclatuur} ;
        my $einddatum = $main::einddatum_opname;
        my $begindatum  =   $main::begindatum_opname ;
        my ($st_d,$st_m,$st_j) = split /\//,$startdatum_verzekering ;
        my ($w_year, $w_mon, $w_day) = Add_Delta_YM($st_j, $st_m, $st_d,0,$aantal_maanden_wachttijd);
        my ($w_d,$w_m,$w_j) = split /\//,$wachtdatum_verzekering ;
        $startdatum_verzekering = $st_j*10000+$st_m*100+$st_d;
        $wachtdatum_verzekering = $w_j*10000+$w_m*100+$w_d;
        my $test_wachtdatum = $w_year*10000+$w_mon*100+$w_day;
        my $einde_wacht =0;
        if  ($test_wachtdatum <  $wachtdatum_verzekering) {
           $einde_wacht= $test_wachtdatum; 
          }else {
           $einde_wacht = $wachtdatum_verzekering;
          }
        if ($begindatum < $einde_wacht) {
                Wx::MessageBox( _T("valt in wachttijd\n$begindatum < $einde_wacht"), 
                    _T("Wachttijd $nomenclatuur"), 
                      wxOK|wxCENTRE, 
                      $main::frame);
                $value=0;
          }          
        return ($value);
}
#sub PostGridMenu {
#  my ($parent, $self, $event) = @_;
#  my $row = $event->GetRow;
#  return if ($row < 0);
#  $parent->{clicked_row} = $row;
#  my $this = $self->GetCellValue($row, 1) || "current row";
#
#  my @sel = grep {$parent->{grid}->IsInSelection($_,0)} (0 .. $parent->{grid}->GetNumberRows-1);
#  my $which = ($#sel > 0) ? 'selected' : $this;
#  @sel = sort {$a <=> $b} uniq(@sel, $row);
#  $parent->{selected} = \@sel;
#
#  my $change = Wx::Menu->new(q{});
#  my $ind = 100;
#  foreach my $t (@$types) {
#    next if ($t eq 'merge');
#    $change->Append($ind++, $t);
#  };
#  my $explain = Wx::Menu->new(q{});
#  $ind = 200;
#  foreach my $t (@$types) {
#    $explain->Append($ind++, $t);
#  };
#
#  ## test for how many are selected
#  my $menu = Wx::Menu->new(q{});
#  $menu->Append	         (0,	    "Copy $which");        # or selected
#  $menu->Append	         (1,	    "Cut $which");         # or selected
#  $menu->Append	         (2,	    "Paste below $this");  # or selected
#  $menu->AppendSeparator;
#  $menu->Append	         (4,	    "Insert blank line above $this");
#  $menu->Append	         (5,	    "Insert blank line below $this");
#  $menu->AppendSeparator;
#  $menu->AppendSubMenu   ($change,  "Change $which to");         # or selected
#  $menu->Append	         (8,	    "Grab best fit for $which"); # or selected
#  $menu->Append	         (9,	    "Build restraint from $this");
#  $menu->Append	         (10,	    "Annotate $this");
#  $menu->AppendSeparator;
#  $menu->Append	         (12,	    "Find where $this is used");
#  $menu->Append	         (13,	    "Rename $this globally");
#  $menu->AppendSeparator;
#  $menu->AppendSubMenu   ($explain, "Explain");
#  $self->SelectRow($row, 1);
#
#  if (($which =~ m{\A\s*\z}) or ($which eq 'current row')) {
#    $menu->Enable($_,0) foreach (0, 8, 9, 10, 12, 13);
#  };
#  $self->PopupMenu($menu, $event->GetPosition);
#}  
  1;