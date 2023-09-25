#!/usr/bin/perl -w
use strict;

#this->parentFrame->dataGrid->ForceRefresh();
package Overzicht_GridApp;
     use strict;
     use warnings;
     use Wx qw(:everything);
     use base qw(Wx::Grid);
     use Data::Dumper;
     use Wx::Locale gettext => '_T'; 
     use Wx::Event qw(EVT_GRID_CELL_LEFT_CLICK EVT_GRID_CELL_RIGHT_CLICK
     EVT_GRID_CELL_LEFT_DCLICK EVT_GRID_CELL_RIGHT_DCLICK
     EVT_GRID_LABEL_LEFT_CLICK EVT_GRID_LABEL_RIGHT_CLICK
     EVT_GRID_LABEL_LEFT_DCLICK EVT_GRID_LABEL_RIGHT_DCLICK
     EVT_GRID_ROW_SIZE EVT_GRID_COL_SIZE EVT_GRID_RANGE_SELECT
     EVT_GRID_SELECT_CELL);
     # events changed names in version 2.9.x
     my $events29plus = ( defined(&Wx::Event::EVT_GRID_CELL_CHANGED) );
      
     sub new {
         my ($class, $frame) = @_;
         my $grid = $class->SUPER::new($frame->{MainframeNotebookOnder_pane_Overzicht}, wxID_ANY, wxDefaultPosition,	# Grid object
         #Wx::Size->new(1450,900));
         Wx::Size->new(1450,780));
         my $table = Overzicht_Grid->new($frame); # Virtual Table object
         
         $grid->SetTable($table,$frame);
         #$sizer->Add($table, 1, wxEXPAND, 0);
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
  
         $grid->SetColLabelValue(0, _T("Beschrijving"));
         $grid->SetColLabelValue(1, _T("Code"));
         $grid->SetColLabelValue(2, _T("Dagen"));
         $grid->SetColLabelValue(3, _T("Bdrg/dg"));
         $grid->SetColLabelValue(4, _T("P. tsk."));
         $grid->SetColLabelValue(5, _T("Sup."));
         $grid->SetColLabelValue(6, _T("Totaal"));
         #$grid->SetColFormatFloat(5, 6, 2);
         $grid->SetColLabelValue(7, _T("Z. tsk"));
         $grid->SetColLabelValue(8, _T("HP+ tsk"));
         $grid->SetColLabelValue(9, _T("Verschil"));
         $grid->SetColLabelValue(10, _T("K-jaar"));
         $grid->SetColLabelValue(11, _T("D-jaar"));
         $grid->SetColLabelValue(12, _T("Max. Bedr."));
         $grid->SetColLabelValue(13, _T("B.O."));
         $grid->SetColLabelValue(14, _T("Max. Dagen"));
         $grid->SetColLabelValue(15, _T("D.O"));
         $grid->SetColLabelValue(16, _T("Aanvaard"));
         $grid->SetColLabelValue(17, _T("Geweigerd"));
         $grid->SetColSize( 0,280 );
         $grid->SetColSize( 1,55 );
         $grid->SetColSize( 2,65 );
         $grid->SetColSize( 3,60 );
         $grid->SetColSize( 4,65 );
         $grid->SetColSize( 5,60 );
         $grid->SetColSize( 6,60 );
         $grid->SetColSize( 7,60 );
         $grid->SetColSize( 8,60 );
         $grid->SetColSize( 9,60 );
         $grid->SetColSize( 10,60 );
         $grid->SetColSize( 11,65 );
         $grid->SetColSize( 12,90 );
         $grid->SetColSize( 13,30 );
         $grid->SetColSize( 14,90 );
         $grid->SetColSize( 15,30 );
         $grid->SetColSize( 16,60 );
         $grid->SetColSize( 17,60 );
         my $rij=0;
         #my @test = @main::overzicht_matrix;
         my $rij_aantal =$main::aantal_rij_overzicht_matrix;
         while  ($rij < $rij_aantal) {
             my $groep =$main::overzicht_matrix_groeprijen[$rij];
             if ($groep==1) {
                 $grid->SetRowLabelValue($rij, _T(" "));#code
             }else {
                  $grid->SetRowLabelValue($rij, _T("\<$main::overzicht_matrix[$rij][1]\>"));#code               
                  
             }
             $rij +=1;
            }
           
     
         
     
    
         # Sample Events - logs the events
         #EVT_GRID_CELL_LEFT_CLICK( $grid, c_log_skip( "Cell left click" ) );
         # EVT_GRID_CELL_RIGHT_CLICK( $grid, c_log_skip( "Cell right click" ) );
         #EVT_GRID_CELL_LEFT_DCLICK( $grid, c_log_skip( "Cell left double click" ) );
         #EVT_GRID_CELL_RIGHT_DCLICK( $grid, c_log_skip( "Cell right double click" ) );
         #EVT_GRID_LABEL_LEFT_CLICK( $grid, c_log_skip( "Label left click" ) );
         #EVT_GRID_LABEL_RIGHT_CLICK( $grid, c_log_skip( "Label right click" ) );
         EVT_GRID_LABEL_LEFT_DCLICK( $grid, c_log_skip( "Label left double click" ) );
         #EVT_GRID_LABEL_RIGHT_DCLICK( $grid, c_log_skip( "Label right double click" ) );
         #EVT_GRID_ROW_SIZE( $grid, sub {
         #              Wx::LogMessage( "%s %s", "Row size", GS2S( $_[1] ) );
         #              $_[1]->Skip;
         #            } );
         #EVT_GRID_COL_SIZE( $grid, sub {
         #              Wx::LogMessage( "%s %s", "Col size", GS2S( $_[1] ) );
         #              $_[1]->Skip;
         #            } );
         #EVT_GRID_RANGE_SELECT( $grid, sub {
         #                  Wx::LogMessage( "Range %sselect (%d, %d, %d, %d)",
         #                                  ( $_[1]->Selecting ? '' : 'de' ),
         #                                  $_[1]->GetLeftCol, $_[1]->GetTopRow,
         #                                  $_[1]->GetRightCol,
         #                                  $_[1]->GetBottomRow );
         #                  $_[0]->ShowSelections;
         #                  $_[1]->Skip;
         #                } );
         if( $events29plus ) {
             #Wx::Event::EVT_GRID_CELL_CHANGED( $grid, c_log_skip( "Cell content changed" ) );
            } else {
             #Wx::Event::EVT_GRID_CELL_CHANGE( $grid, c_log_skip( "Cell content changed" ) );
            }
         #EVT_GRID_SELECT_CELL( $grid, c_log_skip( "Cell select" ) );
         $main::grid_Overzicht = $grid;
         return $grid;
        }
     sub refresh_grid {
         my ($class,$grid) = @_;
         #my $rij=0;
         #my @test = @main::overzicht_matrix;
         #my $rij_aantal =$main::aantal_rij_overzicht_matrix;
         #while  ($rij < $rij_aantal) {
         #     if ($main::overzicht_matrix[$rij][1] == 882011 and $main::overzicht_matrix[$rij][8] > 0) {
         #        #$grid->{cyan_bg}
         #        #$grid->SetCellBackgroundColour ($rij,8,wxGREEN);#code
         #        #$grid->SetCellTextColour($rij,8,wxRED);                     
         #        print "";
         #       }else {
         #        #$grid->SetCellBackgroundColour ($rij,8,wxWHITE);#code
         #        #$grid->SetCellTextColour($rij,8,wxBLACK);
         #       }
         #     $rij +=1;
         #   }
         #print "";
         $grid->ForceRefresh();
          
     }
    
     sub ShowSelections {
         my $grid = shift;
         my @cells = $grid->GetSelectedCells;
         #if( @cells ) {
         #    Wx::LogMessage( "Cells %s selected", join ', ',
         #                                         map { "(" . $_->GetCol .
         #                                               ", " . $_->GetRow . ")"
         #                                              } @cells );
         #   } else {
         #    Wx::LogMessage( "No cells selected" );
         #   }
         #my @tl = $grid->GetSelectionBlockTopLeft;
         #my @br = $grid->GetSelectionBlockBottomRight;
         #if( @tl && @br ) {
         #    Wx::LogMessage( "Blocks %s selected",
         #               join ', ',
         #               map { "(" . $tl[$_]->GetCol .
         #                     ", " . $tl[$_]->GetRow . "-" .
         #                     $br[$_]->GetCol . ", " .
         #                     $br[$_]->GetRow . ")"
         #                   } 0 .. $#tl );
         #   } else {
         #     Wx::LogMessage( "No blocks selected" );
         #   }
         my @rows = $grid->GetSelectedRows;
         #
         if( @rows ) {
         #    Wx::LogMessage( "Rows %s selected", join ', ', @rows );
             #my @test= @main::overzicht_matrix;
             my $nomenclatuur = $main::overzicht_matrix[$rows[0]][1];
         #    print "";
             my $main_frame_notebook_onder = MainFrameNotebookOnder->change_tab($nomenclatuur);
         #    print "";
         #    #&Make_Detail($rows[0]);
         #   
            } else {
         #    Wx::LogMessage( "No rows selected" );
            }
         #my @cols = $grid->GetSelectedCols;
         #if( @cols ) {
         #    Wx::LogMessage( "Columns %s selected", join ', ', @cols );
         #} else {
         #    Wx::LogMessage( "No columns selected" );
         #}
        }
     
     # pretty printer for Wx::GridEvent
     sub Make_Detail {
         my $row =shift @_;
         my $nomenclatuur = Overzicht_Grid->GetValue($row,1);
         print "rij $row -> $nomenclatuur\n";
     }
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
         my $text = shift;
         return sub {
         #    Wx::LogMessage( "%s %s", $text, G2S( $_[1] ) );
             $_[0]->ShowSelections;
             $_[1]->Skip;
            };
        }
   
    1;
package Overzicht_Grid;
     use strict;
     use warnings;
     use Wx qw(:everything);
     use Wx::Grid;
     use base qw(Wx::PlGridTable);
     use Data::Dumper;
     use Wx qw(wxRED wxGREEN wxBLUE wxALIGN_LEFT wxALIGN_CENTRE wxCYAN );
    
     sub new {
         my( $class, $frame) = @_;
         my $self = $class->SUPER::new;
         #my $test = maketable_matrix ($frame); 
         #$self->{float} = Wx::GridCellFloatRenderer->new(8,2) ;
         $self->{rows} = $main::aantal_rij_overzicht_matrix;
         $self->{matrix} = @main::overzicht_matrix;
         $self->{rijgroep}=@main::overzicht_matrix_groeprijen;
         $self->{default} = Wx::GridCellAttr->new;	# Cell attributes for demo purposes
         $self->{red_bg} = Wx::GridCellAttr->new;
         $self->{cyan_bg} = Wx::GridCellAttr->new;
         $self->{green_fg} = Wx::GridCellAttr->new;
         $self->{float}=  Wx::GridCellAttr->new;
         $self->{float_precisoin}= Wx::GridCellFloatRenderer->new;
         $self->{bool}= Wx::GridCellAttr->new;
         $self->{bool_render}= Wx::GridCellBoolRenderer->new;
         $self->{align_left}=  Wx::GridCellAttr->new;
         $self->{red_twodigits}=Wx::GridCellAttr->new;
         
         $self->{align_left}->SetAlignment(wxALIGN_LEFT,wxALIGN_CENTRE);
         $self->{float}->SetRenderer($self->{float_precisoin});
         $self->{float_precisoin}->SetPrecision(2);
         $self->{bool}->SetRenderer($self->{bool_render});
         #$self->{bool_render}->GridCellBoolRenderer();
         $self->{red_bg}->SetBackgroundColour( wxRED );
         $self->{cyan_bg}->SetBackgroundColour( wxCYAN );
         $self->{green_fg}->SetTextColour( wxGREEN );
         $self->{red_twodigits}->SetBackgroundColour(Wx::Colour->new(255,255,0));
         $self->{red_twodigits}->SetRenderer($self->{float_precisoin});
         print "";                   
         return $self;
        }
     # Overridden Methods from the base class - these get modified/expanded in a real app
     sub GetNumberRows {
          my ($self) = @_;
          return ($self->{rows});
        
        }	 # Base demo is set for 100000 x 100000
     sub GetNumberCols {18}
     sub IsEmptyCell {
          my( $grid, $row, $col) = @_;
          #my $test = $grid->GetValue($row, $col);
          
          return defined $grid->GetValue($row, $col) ? 1 : 0;
        }
     sub GetValue {
         my( $grid, $y, $x ) = @_;
         #$main::overzicht_matrix["$y"][9]= $main::overzicht_matrix["$y"][6]- $main::overzicht_matrix["$y"][7]-$main::overzicht_matrix["$y"][8];
         return $main::overzicht_matrix["$y"]["$x"];
        }
     sub SetValue {
         my( $grid, $x, $y, $value ) = @_;
         $main::overzicht_matrix["$y"]["$x"] = $value;
     #    die "Read-Only table";
      }
     sub SetValueAsDouble {
          my( $grid, $x, $y, $value ) = @_;
         $main::overzicht_matrix["$y"]["$x"] = $value;
     #    die "Read-Only table";
      }
     
     sub GetTypeName {	# Verified that swapping bool and double
         my( $grid, $r, $c ) = @_;	# Swap the columns
         return $c == 0 ? 'string' :
                $c == 1 ? 'string' : # Col 0 Boolean
                $c == 12 ? 'string' :	# Col 1 Double
                #$c == 12 ? 'bool' : # gezet in celattr
                $c == 14 ? 'string' :
               # $c == 14 ? 'bool' :
                         'double';	# All others String
        }
     sub CanGetValueAs {
         my( $grid, $r, $c, $type ) = @_;
         my $leeg =$main::overzicht_matrix_groeprijen[$r];
         return $c == 0 ? $type eq 'string' :
                $c == 1 ? $type eq 'string' :  #bool is ook een mogelijkheid geeft een vink
                $c == 12 ? $type eq 'string':
                $c == 13 ? $type eq 'bool':
                $c == 14 ? $type eq 'string':
                $c == 15 ? $type eq 'bool':
                $leeg == 1 ? $type eq 'string':
                          $type eq 'double';
        }
     sub GetValueAsBool {	# Even rows false
         my( $grid, $r, $c ) = @_;	# Odd rows true
         return ($main::overzicht_matrix["$r"]["$c"]);
       }
     sub GetValueAsString {	# Even rows false
          my( $grid, $r, $c ) = @_;	# Odd rows true
          return ($main::overzicht_matrix[$r][$c]);
        }
     sub GetValueAsDouble {	# Row # plus (Col #/1000)
         my( $grid, $r, $c ) = @_;
         #return (0);
         return ($main::overzicht_matrix[$r][$c]);
       }
     sub GetAttr {	# Cell attributes
         my( $grid, $row, $col, $kind ) = @_;
         #return $grid->{default} if $row % 2 && $col % 2;	# Odd rows and odd cols default format
         #return $grid->{red_bg} if $row % 2;	# Odd rows only - red background
         #return $grid->{green_fg} if $col % 2;	# Odd cols only - green foreground text
         my $groep =$main::overzicht_matrix_groeprijen[$row];
          if ($main::overzicht_matrix[$row][1] ~~ @main::recuperatie_van_ziekenfonds and $main::overzicht_matrix[$row][8] > 0 and $col == 6) {
            #$main::grid_Overzicht->SetColFormatFloat($row, 6, 2);
            return ($grid->{red_twodigits});
         }
         return ($grid->{align_left},$grid->{cyan_bg}) if $groep ==1;
         return ($grid->{align_left},Wx::GridCellAttr->new) if $col == 0; # Even rows and even cols - default format
         return ($grid->{align_left},Wx::GridCellAttr->new) if $col == 1; # Even rows and even cols - default format
         return Wx::GridCellAttr->new if $col == 12; # Even rows and even cols - default format
         return Wx::GridCellAttr->new if $col == 14; # Even rows and even cols - default format
         return Wx::GridCellAttr->new if $groep ==1; #groep title volledige lijn string
         return ($grid->{bool}) if $col ==15 or $col == 13; #vink vn boolean rij 14 en 12 behalve waar groep begint
         return ($grid->{float});
        
     }
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
         #my $label ='';
         #my $groep =$grid->{rijgroep}[$row];
         #$label = "----" if($groep == 0);
         #return $label;
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
    
     #sub maketable_matrix {
     #    my $frame = shift @_;
     #    $frame->{matrix}=@main::overzicht_matrix;
     #    return ($frame);
     #   }
1;