#!/usr/bin/perl -w
use strict;

package Voor_na_zorg_GridApp;
use strict;
use warnings;
use Wx qw(:everything);
use base qw(Wx::Grid);
use Data::Dumper;
our $table1;
use Wx::Event qw(EVT_GRID_CELL_LEFT_CLICK EVT_GRID_CELL_RIGHT_CLICK
EVT_GRID_CELL_LEFT_DCLICK EVT_GRID_CELL_RIGHT_DCLICK
EVT_GRID_LABEL_LEFT_CLICK EVT_GRID_LABEL_RIGHT_CLICK
EVT_GRID_LABEL_LEFT_DCLICK EVT_GRID_LABEL_RIGHT_DCLICK
EVT_GRID_ROW_SIZE EVT_GRID_COL_SIZE EVT_GRID_RANGE_SELECT
EVT_GRID_SELECT_CELL);
use Wx::Locale gettext => '_T';   
# events changed names in version 2.9.x

my $events29plus = ( defined(&Wx::Event::EVT_GRID_CELL_CHANGED) );

sub new {
     my ($class, $frame,$nom_clatuur) = @_;
     my $grid = $class->SUPER::new($frame->{"MainframeNotebookOnder_pane_Detail$nom_clatuur"}, wxID_ANY, wxDefaultPosition,	# Grid object
     Wx::Size->new(1470,780));
     
     $table1 = Voor_na_zorg_Grid->new;	# Virtual Table object
     $grid->SetTable( $table1 );
      
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
      my $aantal_dagen_voor_begindatum = $main::begin_eind_dat_verschil_nomenclatuur->{$nom_clatuur}->{aantal_dagen_voor_begindatum};
      my $aantal_dagen_na_einddatum = $main::begin_eind_dat_verschil_nomenclatuur->{$nom_clatuur}->{aantal_dagen_na_einddatum};
      if (!defined $aantal_dagen_voor_begindatum > 0) {
           $aantal_dagen_voor_begindatum = 730;
          } 
      if (!defined $aantal_dagen_na_einddatum) {
           $aantal_dagen_na_einddatum =730;
          }
     $grid->SetColLabelValue(0, _T("Voor- en Nazorg/Ambulante zorgen"));
     $grid->SetColLabelValue(1, _T("M-D-A"));
     $grid->SetColLabelValue(2, _T("Datum"));
     $grid->SetColLabelValue(3, _T("Code"));
     $grid->SetColLabelValue(4, _T("P. tsk."));
     $grid->SetColLabelValue(5, _T("Z. tsk"));
     $grid->SetColLabelValue(6, _T("HP+ tsk"));
     $grid->SetColLabelValue(7, _T("Verschil"));
     $grid->SetColLabelValue(8, _T("Datum -$aantal_dagen_voor_begindatum"));
     $grid->SetColLabelValue(9, _T("Datum +$aantal_dagen_na_einddatum"));
     $grid->SetColLabelValue(10, _T("Regel Toegepast"));
     $grid->SetColLabelValue(11, _T("NG"));
     $grid->SetColLabelValue(12, _T("NG"));
     $grid->SetColLabelValue(13, _T("Dienst"));
     $grid->SetColSize( 0,200 );
     $grid->SetColSize( 1,60 );
     $grid->SetColSize( 2,80 );
     $grid->SetColSize( 3,60 );
     $grid->SetColSize( 4,60 );
     $grid->SetColSize( 5,60 );
     $grid->SetColSize( 6,60 );
     $grid->SetColSize( 7,60 );
     $grid->SetColSize( 8,80 );
     $grid->SetColSize( 9,80 );
     $grid->SetColSize( 10,270 );
     $grid->SetColSize( 11,50);
     $grid->SetColSize( 12,50);
     $grid->SetColSize( 13,80);
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
  ##EVT_GRID_LABEL_RIGHT_CLICK( $grid, c_log_skip( "Label right click" ) );
  EVT_GRID_LABEL_RIGHT_CLICK( $grid, \&clear_row);
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
       # Wx::Event::EVT_GRID_CELL_CHANGE( $grid, c_log_skip( "Cell content changed" ) );
        
  }
  
  #EVT_GRID_SELECT_CELL( $grid, c_log_skip( "Cell select" ) );
  $main::grid_VnZ_refresh = $grid;
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
  #  Wx::LogMessage( "%s %s", $text, G2S( $_[1] ) );
  #  $_[0]->ShowSelections;
  #  $_[1]->Skip;
  };
}
sub clear_row {
	my ( $this, $grid_event) = @_;
	my $rij_delete = $grid_event->GetRow();
        my $kolom_label =  $grid_event->GetCol();
        my $nomenclatuur = $this->GetRowLabelValue(1);
        print"";
        foreach my $kolom  (keys $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij_delete]) {
           if ($kolom == 0 or $kolom == 1 or $kolom == 2 or $kolom == 3 or $kolom == 8 or $kolom == 9 or $kolom == 10 ) {
                $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij_delete][$kolom]='';
           }else {
                $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij_delete][$kolom]=0;
                my $refresh = $table1->Total_Col($kolom,$nomenclatuur);
           }
           
        }
        #my $test= $main::overzicht_per_nomenclatuur->{$nomenclatuur}[33][0];
        $table1->Herberekenen($nomenclatuur);
        $this->ForceRefresh();
        return();
}
1;
package Voor_na_zorg_Grid;
     use strict;
     use warnings;
     use Wx qw(:everything);
     use Wx::Grid;
     use base qw(Wx::PlGridTable);
     use Data::Dumper;
     use Wx qw(wxRED wxGREEN wxBLUE wxALIGN_LEFT wxALIGN_CENTRE wxCYAN );
     use Date::Manip::DM5 ;
     use DateTime::Format::Strptime;
     use DateTime;
    
     our $main_frame_notebook_onder;
     our $nomeclatuur;
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
         $self->{bool}= Wx::GridCellAttr->new;
         $self->{date}= Wx::GridCellAttr->new;
         $self->{bool_render}= Wx::GridCellBoolRenderer->new;
         $self->{date_render}= Wx::GridCellDateTimeRenderer->new;

         $self->{align_left}->SetAlignment(wxALIGN_LEFT,wxALIGN_CENTRE);
         $self->{float}->SetRenderer($self->{float_precisoin});
         $self->{float_precisoin}->SetPrecision(2);
         $self->{bool}->SetRenderer($self->{bool_render});
         $self->{date}->SetRenderer($self->{date_render});
         $self->{red_bg}->SetBackgroundColour( wxRED );
         $self->{cyan_bg}->SetBackgroundColour( wxCYAN );
         $self->{green_fg}->SetTextColour( wxGREEN );
         $self->SetRowAttr($self->{float},1);
         $main::grid_VnZ = $self;
  return $self;
}

# Overridden Methods from the base class - these get modified/expanded in a real app
sub GetNumberRows { 34 }	# Base demo is set for 100000 x 100000
sub GetNumberCols { 14}
sub IsEmptyCell { 0 }

sub GetValue {
  my( $grid, $x, $y,$value ) = @_;
  my $nomenclatuur=$grid->GetRowLabelValue(1);
  $value = $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$x][$y];
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
  my $nomenclatuur=$grid->GetRowLabelValue(1);
  if ($y == 1 and lc $value eq 'h') {
      $value ='H';
  }elsif ($y == 1 and lc $value eq 'm') {
      $value = 'M';
  }elsif ($y == 1 and lc $value eq 'd') {
      $value = 'D';
  }elsif ($y == 1 and lc $value eq 'b') {
      $value = 'B';
  }elsif ($y == 1 and lc $value eq 'a') {
      $value = 'A';
  }elsif ($y == 1){
      $value = '';
  }
  if ($y == 2 or  $y == 8 or $y == 9) {
      if ($value =~ m%^\d{2}-\d{2}-\d{4}$%) {
           $value= $&;
           $value =~ s%-%/%g;
          }elsif  ($value =~ m%^\d{2}-\d{2}-\d{2}$%) {
           $value= $&;
           $value =~ s/-/\//g;
           my $deel1 = substr ($value,0,6);
           my $deel2 = substr ($value,6,2);
           $value ="$deel1"."20"."$deel2";
          }elsif  ($value =~ m%^\d{1}-\d{1}-\d{2}$%) {
           $value= $&;
           $value =~ s/-/\//g;
           my $deel1 = substr ($value,0,2);
           my $deel2 = substr ($value,2,2);
           my $deel3 = substr ($value,4,2);
           $value ="0"."$deel1"."0"."$deel2"."20"."$deel3";
          }elsif  ($value =~ m%^\d{2}-\d{1}-\d{2}$%) {
           $value= $&;
           $value =~ s/-/\//g;
           my $deel1 = substr ($value,0,3);
           my $deel2 = substr ($value,3,2);
           my $deel3 = substr ($value,5,2);
           $value ="$deel1"."0"."$deel2"."20"."$deel3";
          }elsif  ($value =~ m%^\d{1}-\d{2}-\d{2}$%) {
           $value= $&;
           $value =~ s/-/\//g;
           my $deel1 = substr ($value,0,2);
           my $deel2 = substr ($value,2,3);
           my $deel3 = substr ($value,5,2);
           $value ="0"."$deel1"."$deel2"."20"."$deel3";
          }elsif  ($value =~ m%^\d{1}-\d{1}-\d{4}$%) {
           $value= $&;
           $value =~ s/-/\//g;
           my $deel1 = substr ($value,0,2);
           my $deel2 = substr ($value,2,2);
           my $deel3 = substr ($value,4,4);
           $value ="0"."$deel1"."0"."$deel2"."$deel3";
          }elsif  ($value =~ m%^\d{2}-\d{1}-\d{4}$%) {
           $value= $&;
           $value =~ s/-/\//g;
           my $deel1 = substr ($value,0,3);
           my $deel2 = substr ($value,3,2);
           my $deel3 = substr ($value,5,4);
           $value ="$deel1"."0"."$deel2"."$deel3";
          }elsif  ($value =~ m%^\d{1}-\d{2}-\d{4}$%) {
           $value= $&;
           $value =~ s/-/\//g;
           my $deel1 = substr ($value,0,2);
           my $deel2 = substr ($value,2,3);
           my $deel3 = substr ($value,5,4);
           $value ="0"."$deel1"."$deel2"."$deel3"; #einde -
          }elsif  ($value =~ m%^\d{1}/\d{1}/\d{2}$%) {
           $value= $&;
          
           my $deel1 = substr ($value,0,2);
           my $deel2 = substr ($value,2,2);
           my $deel3 = substr ($value,4,2);
           $value ="0"."$deel1"."0"."$deel2"."20"."$deel3";
          }elsif  ($value =~ m%^\d{2}/\d{1}/\d{2}$%) {
           $value= $&;
         
           my $deel1 = substr ($value,0,3);
           my $deel2 = substr ($value,3,2);
           my $deel3 = substr ($value,5,2);
           $value ="$deel1"."0"."$deel2"."20"."$deel3";
          }elsif  ($value =~ m%^\d{1}/\d{2}/\d{2}$%) {
           $value= $&;
         
           my $deel1 = substr ($value,0,2);
           my $deel2 = substr ($value,2,3);
           my $deel3 = substr ($value,5,2);
           $value ="0"."$deel1"."$deel2"."20"."$deel3";
          }elsif  ($value =~ m%\d{1}/\d{1}/\d{4}$%) {
           $value= $&;
        
           my $deel1 = substr ($value,0,2);
           my $deel2 = substr ($value,2,2);
           my $deel3 = substr ($value,4,4);
           $value ="0"."$deel1"."0"."$deel2"."$deel3";
          }elsif  ($value =~ m%^\d{2}/\d{1}/\d{4}$%) {
           $value= $&;
         
           my $deel1 = substr ($value,0,3);
           my $deel2 = substr ($value,3,2);
           my $deel3 = substr ($value,5,4);
           $value ="$deel1"."0"."$deel2"."$deel3";
          }elsif  ($value =~ m%^\d{1}/\d{2}/\d{4}$%) {
           $value= $&;
          
           my $deel1 = substr ($value,0,2);
           my $deel2 = substr ($value,2,3);
           my $deel3 = substr ($value,5,4);
           $value ="0"."$deel1"."$deel2"."$deel3";
          }elsif ($value =~ m%^\d{2}/\d{2}/\d{4}$%){ #goed
           $value= $&;
          }elsif  ($value =~ m%^\d{2}/\d{2}/\d{2}$%) {
           $value= $&;
           my $deel1 = substr ($value,0,6);
           my $deel2 = substr ($value,6,2);
           $value ="$deel1"."20"."$deel2";
          }elsif ($value =~ m%^\d{8}$% ) {
           $value= $&;
           my $test = substr ($value,0,2);
           my $test1 = substr ($value,2,2);
           my $test3 = substr ($value,4,2);
           if ($test > 20 or $test < 20) {
                my $deel1 = substr ($value,0,2);
                my $deel2 = substr ($value,2,2);
                my $deel3 = substr ($value,4,4);#code
                $value = "$deel1"."/"."$deel2"."/"."$deel3";
               }elsif ($test == 20 and $test1 > 12) {
                my $deel1 = substr ($value,0,4);
                my $deel2 = substr ($value,4,2);
                my $deel3 = substr ($value,6,2);
                $value = "$deel3"."/"."$deel2"."/"."$deel1";
               }elsif ($test == 20 and $test1 <= 12 and $test3 == 20) {
                my $deel1 = substr ($value,0,2);
                my $deel2 = substr ($value,2,2);
                my $deel3 = substr ($value,4,4);#code
                $value = "$deel3"."/"."$deel2"."/"."$deel1";
               }else {
                $value ='';
               }
          }else {
           $value ='';
          }
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
     my $nomenclatuur=$grid->GetRowLabelValue(1);
     $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$x][$y] = $value;
     $grid->Herberekenen;
    }
sub SetValueAsDate {
     my( $grid, $x, $y, $value ) = @_;
     my $nomenclatuur=$grid->GetRowLabelValue(1);
     $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$x][$y] = $value;
    
    }
sub GetTypeName {	# Verified that swapping bool and double
  my( $grid, $r, $c ) = @_;	# Swap the columns
  return $c == 0 ? 'string' :
         $c == 1 ? 'string' :
         $c == 2 ? 'string' :
         $c == 3 ? 'string' :
         $c == 8 ? 'string' :
         $c == 9 ? 'string' :
         $c == 10 ? 'string' :
         $c == 11 ? 'string':
                   'double' ;	# Col 0 Boolean

  
      
}

sub CanGetValueAs {
  my( $grid, $r, $c, $type ) = @_;
  return        $c == 0 ? $type eq 'string' :
                $c == 1 ? $type eq 'string' :  #bool is ook een mogelijkheid geeft een vink
                $c == 2 ? $type eq 'date':
                $c == 3 ? $type eq 'string':
                $c == 8 ? $type eq 'date':
                $c == 9 ? $type eq 'date':
                $c == 10 ? $type eq 'string':
                $c == 11 ? $type eq 'string':
               # $c == 11 ? $type eq 'bool':
                $type eq 'double';
  
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

sub GetAttr {	# Cell attributes
  my( $grid, $row, $col, $kind ) = @_;

  #return $grid->{default} if $row % 2 && $col % 2;	# Odd rows and odd cols default format
  #return ($grid->{cyan_bg},$grid->{float}) if $row % 2;	# Odd rows only - red background
  #return $grid->{float} if $row % 2;
  #return $grid->{green_fg} if $row == 25;	# Odd cols only - green foreground text
  return Wx::GridCellAttr->new if ($col == 0 or $col == 1 or $col == 3 or $col == 10 or $col == 11);
  #return ($grid->{bool}) if $col ==11 ; #vink vn boolean rij 14 en 12 behalve waar groep begint
  return ($grid->{date}) if $col ==8 or $col ==9 or $col == 2; #vink vn boolean rij 14 en 12 behalve waar groep begint
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
sub Toolbar_Herbereken {
        my ($class,$grid, $nomenclatuur) = @_;
        $grid->Herberekenen($nomenclatuur);
}
sub Herberekenen {
       my ($grid, $nomenclatuur,$soort_werkblad) = @_;
       $nomenclatuur=$grid->GetRowLabelValue(1) if (!defined $nomenclatuur) ;
       my $onderste_rij= $grid->GetNumberRows;
       my $vandaag = ParseDate("today");
       $vandaag = substr ($vandaag,0,8);
      #geweigerde_type_nomenclaturen
       my @geweigerde_types = ();
       my $parser = DateTime::Format::Strptime->new(pattern => '%d/%m/%Y');
       my $parser1 = DateTime::Format::Strptime->new(pattern => '%Y%m%d');
       my $datum_nummer =0;
       my $begindatum_min_30;
       my $einddatum_plus_90;
       my $einddatum_plus_90_nummer;
       my $begindatum_min_30_nummer;
       if (lc ($soort_werkblad) ne  'groepsregel' and lc ($soort_werkblad) ne 'dienst') {
           #my $test_begin = $main::begindatum_opname;
           #my $test_einde = $main::einddatum_opname;
           #if ($main::begindatum_opname < 19000000 or $main::einddatum_opname < 19000000) {
           #     $main::frame->Wx::MessageBox( _T("Gelieve Begin- en Einddatum opname in te voeren"), 
           #           _T("Berekenen"), 
           #           wxOK|wxCENTRE, 
           #           $main::frame
           #         );
           #    }else {
           #     
           #    }
           my $begindatum =$parser1->parse_datetime($vandaag);
           my $einddatum = $parser1->parse_datetime($vandaag);
           $begindatum =$parser1->parse_datetime($main::begindatum_opname) if ($main::begindatum_opname > 0);
           $einddatum = $parser1->parse_datetime($main::einddatum_opname) if($main::einddatum_opname > 0) ;
           my $begindatum_min_30_reken = $begindatum->clone;
           my $aantal_dagen_voor_begindatum = $main::begin_eind_dat_verschil_nomenclatuur->{$nomenclatuur}->{aantal_dagen_voor_begindatum};
           my $aantal_dagen_na_einddatum = $main::begin_eind_dat_verschil_nomenclatuur->{$nomenclatuur}->{aantal_dagen_na_einddatum};
           
           if ($aantal_dagen_voor_begindatum > 0) {
                $begindatum_min_30_reken->subtract(days => $aantal_dagen_voor_begindatum);#code
               }else {
                $begindatum_min_30_reken->subtract(days => 730); #730 is twee jaar
               } 
           $begindatum_min_30 = $begindatum_min_30_reken->strftime('%d/%m/%Y');
           my $einddatum_plus_90_reken = $einddatum->clone;
           if ($aantal_dagen_na_einddatum > 0) {
                $einddatum_plus_90_reken->add(days =>$aantal_dagen_na_einddatum);
               }else {
                $einddatum_plus_90_reken->add(days =>730);#730 is twee jaar
               }
           $einddatum_plus_90 = $einddatum_plus_90_reken->strftime('%d/%m/%Y');
           $einddatum_plus_90_nummer = $einddatum_plus_90_reken->strftime('%Y%m%d');
           $begindatum_min_30_nummer = $begindatum_min_30_reken->strftime('%Y%m%d');
           print "\n$nomenclatuur\n$nomenclatuur\n$nomenclatuur\n";
           eval {foreach my $type (keys $main::geweigerde_types_pernomenclatuur->{$nomenclatuur}) {}};
           if (!$@) {
                foreach my $type (keys $main::geweigerde_types_pernomenclatuur->{$nomenclatuur}) {
                     push (@geweigerde_types,$type);
                    }
               }
           
           
          }
       
      
       print "";
      
       ##weghalen vink op overzicht
       for  (my $overzicht_rij =0 ; $overzicht_rij < $main::aantal_rij_overzicht_matrix; $overzicht_rij++) {
           if ($main::overzicht_matrix[$overzicht_rij][1] == $nomenclatuur and $nomenclatuur > 1) {
                $main::overzicht_matrix[$overzicht_rij][13] = 0;#code
               }
          }
       for (my $rij =0; $rij < $onderste_rij-1 ; $rij++){
           $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][10]='';
           $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][6]=0;
           $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][7]=0;
          }
       $grid->Total_Col(4,$nomenclatuur);
       $grid->Total_Col(5,$nomenclatuur);
       $grid->Total_Col(6,$nomenclatuur);
       $grid->Total_Col(7,$nomenclatuur);
       for (my $rij =0; $rij < $onderste_rij-1 ; $rij++){
           if (lc ($soort_werkblad) ne  'groepsregel' and lc ($soort_werkblad) ne 'dienst') {
                INVALID_DATE:
                my $hh = $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][2];
                if (defined $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][2] and $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][2] ne '') {
                     my $datum = $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][2];
                     my $datum_reken =$parser->parse_datetime($datum);
                     eval {$datum_nummer = $datum_reken->strftime('%Y%m%d')} ;
                     if ($@) {
                          $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][2] = ''; #code
                          goto INVALID_DATE;
                         }
                     $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][8] =$begindatum_min_30;
                     $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][9] =$einddatum_plus_90 ;
                     if ( !($datum_nummer >= $begindatum_min_30_nummer and $datum_nummer <= $einddatum_plus_90_nummer)) {
                          $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][7]=$main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][4]-$main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][5];
                          $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][10]= "$datum valt niet tussen $begindatum_min_30 en $einddatum_plus_90";
                          my $tekst =  "900";
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
                if ($main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][4] > 0  or $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][5] > 0 ) {
                     $grid->hospi_tsk($rij,$nomenclatuur);
                     my $geweigerd_type =uc ($main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][1]);
                     if ($geweigerd_type ~~ @geweigerde_types) {
                          $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][7]=$main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][4]-$main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][5];
                          $grid->hospi_tsk($rij,$nomenclatuur);
                          my $tes = $main::geweigerde_types_pernomenclatuur->{$nomenclatuur}->{$geweigerd_type};
                          $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][10]=$main::geweigerde_types_pernomenclatuur->{$nomenclatuur}->{$geweigerd_type};
                         }
                     $grid->maximum_bedrag_per_jaar($rij,$nomenclatuur);
                     $grid->voeg_dienst_toe ($rij,$nomenclatuur);
                    }
               }else {
                $grid->Total_Col(4,$nomenclatuur);
                $grid->maximum_bedrag_per_jaar($rij,$nomenclatuur,'GroepsRegel');
                $grid->hospi_tsk($rij,$nomenclatuur,'GroepsRegel');
                $grid->voeg_dienst_toe ($rij,$nomenclatuur);
               }
          
          }
       $grid->Total_Col(4,$nomenclatuur);
       $grid->Total_Col(5,$nomenclatuur);
       $grid->Total_Col(6,$nomenclatuur);
       $grid->Total_Col(7,$nomenclatuur);
       $grid->pas_groeptotaal_werkbladen_aan($nomenclatuur) if (lc ($soort_werkblad) ne 'groepsregel' and lc ($soort_werkblad) ne 'dienst');
       $grid->pas_totaal_werkblad_aan($nomenclatuur) if (lc ($soort_werkblad) ne 'groepsregel' and lc ($soort_werkblad) ne 'dienst' );
       $main::hospi_tussenkomst = $main::overzicht_per_nomenclatuur->{999999}[($onderste_rij-1)][4]+$main::overzicht_per_nomenclatuur->{999999}[($onderste_rij-1)][6] ; #rechtzetting onderste lijn
       $main::hospi_tussenkomsttxtctrl->SetValue("$main::hospi_tussenkomst");
       #my $test = $main::hospi_tussenkomst;
       $main::verschil=0;
       foreach my $verschil_nom (keys $main::rekenregels_per_nomenclatuur) {
           $main::verschil +=$main::overzicht_per_nomenclatuur->{$verschil_nom}[($onderste_rij-1)][7];
          }
        $main::verschil_txtctrl->SetValue("$main::verschil" );
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
        Overzicht_GridApp->refresh_grid($main::grid_Overzicht);
     }
sub  voeg_dienst_toe {
      my ($grid,$rij,$nomenclatuur) = @_;
      $nomenclatuur=$grid->GetRowLabelValue(1) if (!defined $nomenclatuur) ;
      my $onderste_rij= $grid->GetNumberRows;
      my $dienst=$main::dienst;
      if (defined $dienst) {
           if (defined $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][6] and $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][6] != 0) {
                $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][13]=$dienst if (!defined $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][11]) ;#code#code
               }
          }
     }
sub Total_Col {
      my ($grid, $col,$nomenclatuur) = @_;
      my $onderste_rij= $grid->GetNumberRows;
      $nomenclatuur=$grid->GetRowLabelValue(1) if (!defined $nomenclatuur) ;
      my $tot_nomen=$grid->GetRowLabelValue($onderste_rij-1);
      my $totaal = 0;
      for (my $tel_rij=0; $tel_rij<$onderste_rij-1;$tel_rij += 1) {
           $totaal +=$main::overzicht_per_nomenclatuur->{$nomenclatuur}[$tel_rij][$col];          
          }
     
      $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$onderste_rij-1][$col]=$totaal;
      #bepaal nomenclatuur rij
      for (my $row =0; $row < $main::aantal_rij_overzicht_matrix; $row+=1) {
         if ($nomenclatuur eq $main::overzicht_matrix[$row][1] and $nomenclatuur > 1) {
            my $col1=0;
            if ($col <8) {
               $col1 = $col + 2;#code
            }else {
                $col1 =$col+2+5;
            }
            
             
             #my $tegoed = beslissing_formule->new ($nomenclatuur,$totaal,$col1,$row);
             $main::overzicht_matrix[$row][$col1] = $totaal;
             #hier moet de calculator komen niet de goede plaats gaat per kolom
           
             #print "";
         }
         
     }
    
     #my $test = $main::overzicht_per_nomenclatuur;
     #print"";
}
sub pas_groeptotaal_werkbladen_aan {
      my ($grid,$nomenclatuur) = @_;
      my $rijenteller;
      my $onderste_rij= $grid->GetNumberRows;
      my $cols =$grid->GetNumberCols;
      #my @nomenclaturen_te_tellen;
      my $groeps_nomeclatuur ;
      foreach my $groeps_nom    (keys $main::nomenclaturen_per_groepsregel) {
           foreach my $test_nom (@{$main::nomenclaturen_per_groepsregel->{$groeps_nom}}) {
                $groeps_nomeclatuur = $groeps_nom if ($test_nom == $nomenclatuur and $groeps_nom != 999999);
               }
          }
      my $rijteller =0;
      foreach my $te_tellen_nom (@{$main::nomenclaturen_per_groepsregel->{$groeps_nomeclatuur}}) {
           #push (@nomenclaturen_te_tellen,$te_tellen_nom);
           $main::overzicht_per_nomenclatuur->{$groeps_nomeclatuur}[$rijteller][4]= $main::overzicht_per_nomenclatuur->{$te_tellen_nom}[$onderste_rij-1][6];
           $rijteller +=1;
          }
      $grid->Herberekenen($groeps_nomeclatuur,'GroepsRegel');
      print "";
     }

sub pas_totaal_werkblad_aan {
      my ($grid,$nomenclatuur) = @_;
      my $rijenteller;
      my $onderste_rij= $grid->GetNumberRows;
      my $cols =$grid->GetNumberCols;
      #my @nomenclaturen_te_tellen;
      my $groeps_nomeclatuur = 999999;
      
      my $rijteller =0;
      foreach my $te_tellen_nom (@{$main::nomenclaturen_per_groepsregel->{$groeps_nomeclatuur}}) {
           #push (@nomenclaturen_te_tellen,$te_tellen_nom);
           $main::overzicht_per_nomenclatuur->{$groeps_nomeclatuur}[$rijteller][0]= $main::overzicht_per_nomenclatuur->{$te_tellen_nom}[$onderste_rij-1][0];
           $main::overzicht_per_nomenclatuur->{$groeps_nomeclatuur}[$rijteller][4]= $main::overzicht_per_nomenclatuur->{$te_tellen_nom}[$onderste_rij-1][6];
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
      $grid->Herberekenen($groeps_nomeclatuur,'GroepsRegel');
      print "";
     }
sub hospi_tsk {
      my ($grid, $rij,$nomenclatuur) = @_;
      $nomenclatuur=$grid->GetRowLabelValue(1) if (!defined $nomenclatuur) ;
      my $verschil = $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][7];
      my $soort_werkblad = $main::rekenregels_per_nomenclatuur->{$nomenclatuur}->{soort_werkblad};
      if (lc $soort_werkblad eq 'groepsregel' ) {
           $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][6] =  -$main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][7];  #code
      }elsif (lc ($soort_werkblad) eq 'dienst' ) {
           $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][6]=-$main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][7]
           +$main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][9]-$main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][10];
      }else {
           $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][6]=$main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][4]-$main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][5]
           -$main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][7];        
      }
      
      
     }
sub maximum_bedrag_per_jaar {
      my ($grid, $rij,$nomenclatuur) = @_;
      $nomenclatuur=$grid->GetRowLabelValue(1) if (!defined $nomenclatuur)  ;
      my $k_jaar = 0;
      my $rows = $grid->GetNumberRows;
      my $verschil =0;
      my $soort_werkblad = $main::rekenregels_per_nomenclatuur->{$nomenclatuur}->{soort_werkblad};
      my @test1 =$main::teksten_gebruikte_rekenregels_per_nomenclatuur;
      foreach my $regel (keys $main::rekenregels_per_nomenclatuur->{$nomenclatuur}) {
           if ($regel eq 'maximum_bedrag_per_jaar') {
                if (lc ($soort_werkblad) eq 'groepsregel') {
                     $grid->Total_Col(4,$nomenclatuur);
                     $grid->Total_Col(6,$nomenclatuur);
                     my $maximum_bedrag_per_jaar = $main::rekenregels_per_nomenclatuur->{$nomenclatuur}->{$regel};#code
                     my $tussenkomst_hospi_totaal = $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rows-1][4]+$main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rows-1][6];
                     for (my $overzicht_rij =0 ; $overzicht_rij < $main::aantal_rij_overzicht_matrix; $overzicht_rij++) {
                          if ($main::overzicht_matrix[$overzicht_rij][1] == $nomenclatuur and $nomenclatuur > 1) {
                               $k_jaar = $main::overzicht_matrix[$overzicht_rij][10];#code
                              }
                         }
                     my $test_totaal =$main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][4];
                     if (($tussenkomst_hospi_totaal+$k_jaar) > $maximum_bedrag_per_jaar and $test_totaal >0 ) {
                          my $verschil = $tussenkomst_hospi_totaal+$k_jaar - $maximum_bedrag_per_jaar ;
                          my $bestaand_verschil =$main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][7];
                          $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][7] =$verschil;
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
                               if ($main::overzicht_matrix[$overzicht_rij][1] == $nomenclatuur and $nomenclatuur > 1 ) {
                                    $main::overzicht_matrix[$overzicht_rij][13] = 1;#code
                                   }                     
                              }
                          $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][10] ="$regel :$maximum_bedrag_per_jaar";
                          $grid->hospi_tsk($rij,$nomenclatuur);
                          $grid->voeg_dienst_toe ($rij,$nomenclatuur);
                         }
                      $grid->Total_Col(7,$nomenclatuur);
                }else {
                     #$grid->Kolom_twee_plus_drie_is_vier($rij,$nomenclatuur);
                     #$grid->hospi_tsk_zonder_verschil($rij,$nomenclatuur);
                     $grid->Total_Col(6,$nomenclatuur);
                     #$grid->Total_Col(6,$nomenclatuur);
                     my $maximum_bedrag_per_jaar = $main::rekenregels_per_nomenclatuur->{$nomenclatuur}->{$regel};#code
                     my $tussenkomst_hospi_totaal = $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rows-1][6];
                     for  (my $overzicht_rij =0 ; $overzicht_rij < $main::aantal_rij_overzicht_matrix; $overzicht_rij++) {
                          if ($main::overzicht_matrix[$overzicht_rij][1] == $nomenclatuur and $nomenclatuur > 1) {
                               $k_jaar = $main::overzicht_matrix[$overzicht_rij][10];#code
                              }
                         }
                     my $test_totaal =$main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][4];
                  
                     if (($tussenkomst_hospi_totaal+$k_jaar) > $maximum_bedrag_per_jaar and $test_totaal >0 ) {
                          my $verschil = $tussenkomst_hospi_totaal+$k_jaar - $maximum_bedrag_per_jaar ;
                          my $bestaand_verschil =$main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][7];
                          $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][7] =$verschil;#code $bestaand_verschil+
                          
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
                          $main::overzicht_per_nomenclatuur->{$nomenclatuur}[$rij][10] ="$regel :$maximum_bedrag_per_jaar";
                          $grid->hospi_tsk($rij,$nomenclatuur);
                          $grid->voeg_dienst_toe ($rij,$nomenclatuur);
                         }
                     $grid->Total_Col(7,$nomenclatuur);
                    }
               }
          }    
}
    1;