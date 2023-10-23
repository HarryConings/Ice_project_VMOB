#!/usr/bin/perl -w
use strict;
#OPGELET!!!!!!
#Dit programma is auteursrechtelijk beschermd.
#Deze code is volledig eigendom van de Firma  I.C.E. (liebroekstraat 43 3545 Halen BE0446888007) .
#Deze code mag enkel gebruikt worden met jaarlijkse toestemming van Harry Conings 0475464286 harry@ice.be harry@icebutler.com
#Indien dit toch gebeurt is er een boete verschuldigd van 250.000 EUR exclusief btw aan de Firma  I.C.E.
#Deze code mag niet aan derden (ook niet VNZ en NZVL) getoond worden tenzij met uitdrukkelijke en schriftelijke toestemming van I.C.E. bvba .
#Indien dit toch gebeurt is er een boete verschuldigd van 250.000 EUR exclusief btw aan de Firma  I.C.E.
#Dit geldt ook voor het kopieren van een stuk code of het repliceren van technieken gehanteerd in dit programma
#I.C.E. beheert de broncode je mag  veranderingen aanbrengen aan het programma . Deze worden samen met de documentatie overgedragen aan I.C.E. .
#I.C.E. beslist dan op deze veranderingen worden doorgevoerd.
#OPGELET!!!!!!
#require 'Decryp_Encrypt.pl';
use Date::Manip::DM5;
use XML::Simple;
package main;
     our $mode = 'TEST';
     $mode = $ARGV[0] if (defined $ARGV[0]);
     if ( $mode eq 'TEST' or $mode eq 'PROD'){}else{die}
     our $version = 'v20231020';
     our $vandaag = ParseDate("today");
     our $huidig_jaar = substr ($vandaag,0,4);
     our $huidige_maand = substr ($vandaag,4,2);
     our $huidige_dag = substr ($vandaag,6,2);
     our $UBW_vandaag = "$huidig_jaar\-$huidige_maand\-$huidige_dag";
     our $agresso_instellingen = XMLin('D:\OGV\ASSURCARD_2023\assurcard_settings_xml\agresso_settings.xml');
     our $grid_her1;
     our @her1_matrix;     
     our $grid_her2;
     our @her2_matrix;
     our $aantal_lijnen_eersteher = 200;
     our $tabel_eersteher;
     our $aantal_lijnen_tweedeher = 200;
     our $tabel_tweedeher;
     our $frame;
     our $dbh_main;
     my $app = App->new();          
     $app->MainLoop;
package App;
     use strict;
     use warnings;
     use base 'Wx::App';
     sub OnInit {
         $main::dialog = Frame->new();
         #$main::frame->Maximize( 1 );
         $main::dialog->SetSize(1, 1, 730, 300);
         $main::dialog->Centre();
         
         $main::dialog->Show(1);
        }
     sub OnExit {
            my $self = @_;
            #print "on exit \n";
            $main::dialog->Destroy;
       }
     

package Frame;
     use Wx qw[:everything];
     use Wx::Grid;
     use base qw(Wx::Frame);
     use Wx::Locale gettext => '_T';
     use LWP::Simple;
     use Win32::API;
     use Hash::Merge;
     #my $old_charset = odfLocalEncoding(); #versie 5.2 charset utf8 
     #odfLocalEncoding('iso-8859-15');  #versie 5.2
     our $frame_her1;
     sub new {
          my($self) = @_;         
          $self = $self->SUPER::new(undef, -1, "Vanaf welke datum wil je alle herinneringen terug aanmaken? prog versie: $main::version MODE: $main::mode !!!",
                              wxDefaultPosition,[1800,950],wxDEFAULT_FRAME_STYLE | wxMAXIMIZE);
         #my $menu_main_frame = MenuMainFrame->new($self);
         #my $toolbar_main_frame = ToolBarMainFrame->new($self);
         my $main_frame_notebook_boven = MainFrameNotebookBoven->new($self);
         my $main_frame_notebook_onder = MainFrameNotebookOnder->new($self);
         my $main_frame_notebook_onder_EersteHer =  Overzicht_GridApp->new($self,"EersteHer");
         my $main_frame_notebook_onder_TweedeHer =  Overzicht_GridApp->new($self,"TweedeHer");
         $self->__do_layout();
         #$self->{Maximize}(1);
         return $self;
        }
       
     sub __do_layout {
        my $self =shift;
        #$self->SetMenuBar($self->{main_frame_menubar});
        #$self->SetToolBar($self->{frame_toolbar});
        $self->{mainframe}->{sizer_1} = Wx::BoxSizer->new(wxVERTICAL);
        $self->SetSizerAndFit( $self->{mainframe}->{sizer_1});            
        $self->{mainframe}->{sizer_1}->Add($self->{MainFrameNotebookBoven}, 3,wxEXPAND, 0);
        $self->{mainframe}->{sizer_1}->Add($self->{MainframeNotebookOnder}, 13, wxEXPAND | wxALIGN_TOP, 0);
        $self->{pane_Ask_boven}->SetSizer($self->{ASK_Sizer_1});
        $self->Maximize("True");
        $self->Layout()
    }
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
         my ($class, $frame,$her) = @_;
         my $fff ="MainframeNotebookOnder_pane_$her";
         my $grid = $class->SUPER::new($frame->{"MainframeNotebookOnder_pane_$her"}, wxID_ANY, wxDefaultPosition,	# Grid object
         Wx::Size->new(1750,750));
         my $table = Overzicht_Grid->new($frame,$her); # Virtual Table object
         $grid->SetTable($table,$frame);
         $grid->SetLabelBackgroundColour(wxLIGHT_GREY);
         $grid->SetLabelTextColour(Wx::Colour->new(wxBLUE));
         $grid->SetLabelFont(Wx::Font->new(10, wxFONTFAMILY_ROMAN, wxNORMAL, wxBOLD));
         $grid->SetColLabelSize(20);	# Col height
         $grid->SetRowLabelSize(250);	# Row height - 0 hides the row labels
         $grid->SetDefaultColSize(120,1);	# Default Cell width (Fit overrides)
         $grid->SetDefaultRowSize(20,1);	# Default Cell Height (Fit overrides)
         $grid->EnableGridLines(1);	# Grid lines 1-on, 0-off
         $grid->SetGridLineColour(wxBLUE);
         $grid->SetSelectionMode(wxGridSelectRows);	# Always select complete rows
         $grid->SetSelectionForeground(wxRED);
         $grid->SetSelectionBackground(wxGREEN);	# Click within grid, background goes green
         # Click on row label, background stays black
         # until clicking within grid, then green(???)         
                  
         $grid->SetColLabelValue(1,"Sjabloon");
         $grid->SetColLabelValue(2,"Datum ingezet");
         $grid->SetColLabelValue(3,"Datum eerste Herinnering");
         $grid->SetColLabelValue(4,"Datum Geprint");
         $grid->SetColSize( 0,75 );
         $grid->SetColSize( 1,930 );
         $grid->SetColSize( 2,165 );
         $grid->SetColSize( 3,165 );
         $grid->SetColSize( 4,165 );         
         for my $r (0..$grid->GetNumberRows()) {	# Row Header Text
             $grid->SetRowLabelValue($r, "No_$r");
             print '';
         }
            if ($her eq "EersteHer") {
                $grid->SetColLabelValue(0,"EersteHer");  
                #$main::aantal_lijnen_eersteher = 20 if (!$main::aantal_lijnen_eersteher);
                $grid->{rows} = $main::aantal_lijnen_eersteher;
                $frame->{MainframeNotebookOnder_pane_EersteHer}->{grid_her1} = $grid;
                for my $r (0..$main::aantal_lijnen_eersteher) {
                    for my $c (0..4) {
                        my $test = $grid_her1;
                        $her1_matrix[$r][$c]="";
                        
                    }
                }
                $main::grid_her1 = $grid;   
                print '';
            }elsif  ($her eq "TweedeHer") {
                $grid->SetColLabelValue(0,"TweedeHer");  
                #$main::aantal_lijnen_tweedeher = 20 if (!$main::aantal_lijnen_tweedeher);
                $grid->{rows} = $main::aantal_lijnen_tweedeher;
                $frame->{MainframeNotebookOnder_pane_TweedeHer}->{grid_her2} = $grid;
                for my $r (0..$main::aantal_lijnen_tweedeher) {
                    for my $c (0..4) {
                        $main::her2_matrix[$r][$c]="";
                        
                    }
                }
                $main::grid_her2 = $grid;   
            }        
         return $grid;    
        }
    sub refresh_grid {
          my ($class,$grid) = @_;
          $grid->ForceRefresh();
          
     }
   
    
package Overzicht_Grid;
     use strict;
     use warnings;
     use Wx qw(:everything);
     use Wx::Grid;
     use base qw(Wx::PlGridTable);
     use Data::Dumper;
     use Wx qw(wxRED wxGREEN wxBLUE wxALIGN_LEFT wxALIGN_CENTRE wxCYAN );
    
     sub new {
         my( $class, $frame, $her) = @_;
         my $self = $class->SUPER::new;
         #my $test = maketable_matrix ($frame); 
         #$self->{float} = Wx::GridCellFloatRenderer->new(8,2) ;
         if ($her eq "EersteHer") {
             $self->{rows} = $main::aantal_lijnen_eersteher;
             $self->{matrix} = @her1_matrix;
         }elsif  ($her eq "TweedeHer") {
             $self->{rows} = $main::aantal_lijnen_tweedeher;
             $self->{matrix} = @her2_matrix;
         }      
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
    sub SetColLabelValue {	# Copied from the wiki for custom labels
        my ($grid, $col, $value) = @_;
        $col = $grid->_checkCol($col);
        return unless defined $col;
        $$grid{coldata}->[$col]->{label} = $value;
        print "";
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
        print '';
        
    }
    sub _checkRow {	# Modeled after the wiki for custom labels
        my ($grid, $row) = @_;
        my $rows = $grid->GetNumberRows;
        return undef unless defined $row && abs($row) < $rows;
        return $rows + $row if $row < 0;
        return $row;
    }
    sub SetRowAttr {	# Modeled after the wiki for custom labels
        my ($grid, $attr, $row) = @_;
        $row = $grid->_checkRow($row);
        return unless defined $row;
        $$grid{rowdata}->[$row]->{attr} = $attr;
       
     }
    sub GetNumberRows {# Base demo is set for 100000 x 100000
        my ($self) = @_;          
        return($self->{rows});
    }
    sub GetNumberCols { 5 }
    sub GetValue {
         my( $grid, $y, $x ) = @_;
         my $her = $grid->GetColLabelValue(0);
         my $val;
         if ($her eq "EersteHer") {
             $val = $main::her1_matrix[$y][$x];
         }elsif  ($her eq "TweedeHer") {
             $val = $main::her2_matrix[$y][$x];
         }
         return ($val);
        }
    sub SetValue {
         my ($grid, $row , $col, $value) = @_;
         #$grid->SetCellValue($row,$col,$value);
         print "";
    }
package MainFrameNotebookBoven;
     use Wx qw[:everything];
     use base qw(Wx::Frame);
     #use Data::Dumper
     use strict;
     use Wx::Locale gettext => '_T';
     sub new {
         (my $class, $frame) = @_;
         $frame->{MainFrameNotebookBoven} = Wx::Notebook->new($frame, wxID_ANY, wxDefaultPosition, wxDefaultSize, 0);
         $frame->{pane_Ask_boven} = Wx::Panel->new($frame->{MainFrameNotebookBoven}, wxID_ANY, wxDefaultPosition, wxDefaultSize, ); 
         $frame->{MainFrameNotebookBoven}->AddPage($frame->{pane_Ask_boven}, _T("Zoek"));
         my $frame1 = Ask->new($frame);
         $frame->{MainFrameNotebookBoven}->SetBackgroundColour(Wx::Colour->new(204, 204, 255));
         return ($frame);
        }
package MainFrameNotebookOnder;
     use Wx qw[:everything];
     use base qw(Wx::Frame);
     #use Data::Dumper
     use strict;
     use Wx::Locale gettext => '_T';
    
     sub new {
         (my $class, $frame) = @_;
         $frame->{MainframeNotebookOnder} = Wx::Notebook->new($frame, wxID_ANY, wxDefaultPosition, wxDefaultSize, 0);
         $frame->{MainframeNotebookOnder_pane_EersteHer} = Wx::Panel->new($frame->{MainframeNotebookOnder}, wxID_ANY, wxDefaultPosition, wxDefaultSize, );
         $frame->{MainframeNotebookOnder_pane_TweedeHer} = Wx::Panel->new($frame->{MainframeNotebookOnder}, wxID_ANY, wxDefaultPosition, wxDefaultSize, );
         $frame->{MainframeNotebookOnder}->AddPage($frame->{MainframeNotebookOnder_pane_EersteHer}, _T("Eerste Herinnering"));
         #$grid_her1= Overzicht_Grid->new($frame,"EersteHer");
         $frame->{MainframeNotebookOnder}->AddPage($frame->{MainframeNotebookOnder_pane_TweedeHer}, _T("Tweede Herinnering"));
         $grid_her2 = Overzicht_Grid->new($frame,"TweedeHer");
         $frame->{MainframeNotebookOnder}->SetBackgroundColour(Wx::Colour->new(239, 243, 255));
         
         
         my $test = $frame->{MainframeNotebookOnder}->GetSelection();
         #my $test1 = $frame->{MainframeNotebookOnder}->ChangeSelection(2);
         #$test = $frame->{MainframeNotebookOnder}->GetSelection();
         return ($class, $frame);
        }
package Ask;
     use Time::Piece (); 
     use Wx qw[:everything];
     use base qw(Wx::Frame);
     use Wx qw(wxEVT_SCROLL_TOP wxEVT_SCROLL_BOTTOM wxEVT_SCROLL_LINEUP
               wxEVT_SCROLL_LINEDOWN wxEVT_SCROLL_PAGEUP wxEVT_SCROLL_PAGEDOWN
               wxEVT_SCROLL_THUMBTRACK wxEVT_SCROLL_THUMBRELEASE );
     use Wx::Event qw( EVT_BUTTON EVT_TEXT_ENTER EVT_UPDATE_UI );
     
     use Wx::Perl::ListCtrl;
     #use Data::Dumper
     use strict;
     use Wx::Locale gettext => '_T';
     sub new {
               my $uitvoeren_check = 'niet uitvoeren enkel overzicht';
               (my $class,$frame) = @_;
               #$frame->{pane_Ask_boven} = $frame->{pane_Ask_boven}->SUPER::new(undef, -1,_T("Vanaf welke datum wil je alle herinneringen terug aanmaken"),
               #                         [-1,-1],[730,300], wxDEFAULT_FRAME_STYLE | wxTAB_TRAVERSAL  );
               $frame->{ASK_Sizer_1} = Wx::FlexGridSizer->new(4,12, 10, 10);
               $frame->{ASK_statictxt_Eerste}= Wx::StaticText->new($frame->{pane_Ask_boven}, -1,_T("Zet eerste herinnering tussen begin en einddatum op niet afgedrukt in UBW"),wxDefaultPosition,wxSIZE(140,40));
               $frame->{ASK_statictxt_Tweede}= Wx::StaticText->new($frame->{pane_Ask_boven}, -1,_T("Zet tweede herinnering tussen begin en einddatum op niet afgedrukt in UBW"),wxDefaultPosition,wxSIZE(140,40));
               $frame->{ASK_statictxt_Begindatum}= Wx::StaticText->new($frame->{pane_Ask_boven}, -1,_T("Begindatum YYYY-MM-DD"),wxDefaultPosition,wxSIZE(140,20));
               $frame->{ASK_statictxt_Einddatum}= Wx::StaticText->new($frame->{pane_Ask_boven}, -1,_T("Einddatum YYYY-MM-DD"),wxDefaultPosition,wxSIZE(140,20));
               $frame->{ASK_Txt_Begindatum_Eerste} = Wx::TextCtrl->new($frame->{pane_Ask_boven}, -1, $UBW_vandaag,wxDefaultPosition,wxSIZE(140,40));
               $frame->{ASK_Txt_Begindatum_Tweede} = Wx::TextCtrl->new($frame->{pane_Ask_boven}, -1, $UBW_vandaag,wxDefaultPosition,wxSIZE(140,40));
               $frame->{ASK_Txt_Einddatum_Eerste} = Wx::TextCtrl->new($frame->{pane_Ask_boven}, -1, $UBW_vandaag,wxDefaultPosition,wxSIZE(140,40));
               $frame->{ASK_Txt_Einddatum_Tweede} = Wx::TextCtrl->new($frame->{pane_Ask_boven}, -1, $UBW_vandaag,wxDefaultPosition,wxSIZE(140,40));
               $frame->{ASK_Button_Reprint_her1}  = Wx::Button->new($frame->{pane_Ask_boven}, -1, _T("Herprint Eerste Her"),wxDefaultPosition,wxSIZE(140,40));
               $frame->{ASK_Button_Reprint_her2}  = Wx::Button->new($frame->{pane_Ask_boven}, -1, _T("Herprint Tweede Her"),wxDefaultPosition,wxSIZE(140,40));
               $frame->{ASK_Button_OK}  = Wx::Button->new($frame->{pane_Ask_boven}, -1, _T("Zoek Files"),wxDefaultPosition,wxSIZE(140,40));
               $frame->{ASK_Cancel}  = Wx::Button->new($frame->{pane_Ask_boven}, -1, _T("Cancel"),wxDefaultPosition,wxSIZE(140,40));
               #$frame->{ASK_statictxt_uitvoeren}= Wx::StaticText->new($frame->{pane_Ask_boven}, -1,_T("Enkel opvragen niet Uitvoeren"),wxDefaultPosition,wxSIZE(140,40));
               #$frame->{ASK_chk_uitvoeren}  = Wx::CheckBox->new($frame->{pane_Ask_boven}, 104, $uitvoeren_check,wxDefaultPosition,wxSIZE(170,40));
               $frame->{ASK_panel_1} = Wx::Panel->new($frame->{pane_Ask_boven},-1,wxDefaultPosition,wxSIZE(20,5));
               
               #$frame->{ASK_chk_uitvoeren}->SetValue('True');
               $frame->{ASK_Sizer_1}->Add($frame->{ASK_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{ASK_Sizer_1}->Add($frame->{ASK_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{ASK_Sizer_1}->Add($frame->{ASK_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{ASK_Sizer_1}->Add($frame->{ASK_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{ASK_Sizer_1}->Add($frame->{ASK_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{ASK_Sizer_1}->Add($frame->{ASK_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{ASK_Sizer_1}->Add($frame->{ASK_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{ASK_Sizer_1}->Add($frame->{ASK_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{ASK_Sizer_1}->Add($frame->{ASK_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{ASK_Sizer_1}->Add($frame->{ASK_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{ASK_Sizer_1}->Add($frame->{ASK_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{ASK_Sizer_1}->Add($frame->{ASK_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               #rij1
               $frame->{ASK_Sizer_1}->Add($frame->{ASK_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{ASK_Sizer_1}->Add($frame->{ASK_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{ASK_Sizer_1}->Add($frame->{ASK_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{ASK_Sizer_1}->Add($frame->{ASK_statictxt_Begindatum}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{ASK_Sizer_1}->Add($frame->{ASK_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{ASK_Sizer_1}->Add($frame->{ASK_statictxt_Einddatum}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{ASK_Sizer_1}->Add($frame->{ASK_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{ASK_Sizer_1}->Add($frame->{ASK_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{ASK_Sizer_1}->Add($frame->{ASK_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{ASK_Sizer_1}->Add($frame->{ASK_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{ASK_Sizer_1}->Add($frame->{ASK_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{ASK_Sizer_1}->Add($frame->{ASK_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               #rij2
               $frame->{ASK_Sizer_1}->Add($frame->{ASK_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{ASK_Sizer_1}->Add($frame->{ASK_statictxt_Eerste}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{ASK_Sizer_1}->Add($frame->{ASK_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{ASK_Sizer_1}->Add($frame->{ASK_Txt_Begindatum_Eerste}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{ASK_Sizer_1}->Add($frame->{ASK_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{ASK_Sizer_1}->Add($frame->{ASK_Txt_Einddatum_Eerste}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{ASK_Sizer_1}->Add($frame->{ASK_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{ASK_Sizer_1}->Add($frame->{ASK_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{ASK_Sizer_1}->Add($frame->{ASK_Button_OK}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{ASK_Sizer_1}->Add($frame->{ASK_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{ASK_Sizer_1}->Add($frame->{ASK_Button_Reprint_her1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{ASK_Sizer_1}->Add($frame->{ASK_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               #rij3
               $frame->{ASK_Sizer_1}->Add($frame->{ASK_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{ASK_Sizer_1}->Add($frame->{ASK_statictxt_Tweede}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{ASK_Sizer_1}->Add($frame->{ASK_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{ASK_Sizer_1}->Add($frame->{ASK_Txt_Begindatum_Tweede}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{ASK_Sizer_1}->Add($frame->{ASK_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{ASK_Sizer_1}->Add($frame->{ASK_Txt_Einddatum_Tweede}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{ASK_Sizer_1}->Add($frame->{ASK_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{ASK_Sizer_1}->Add($frame->{ASK_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{ASK_Sizer_1}->Add($frame->{ASK_Cancel}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{ASK_Sizer_1}->Add($frame->{ASK_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
               $frame->{ASK_Sizer_1}->Add($frame->{ASK_Button_Reprint_her2}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);               
               $frame->{ASK_Sizer_1}->Add($frame->{ASK_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
              
               Wx::Event::EVT_BUTTON($frame,$frame->{ASK_Button_OK},\&OK);
               Wx::Event::EVT_BUTTON($frame,$frame->{ASK_Cancel},\&Cancel);
               Wx::Event::EVT_BUTTON($frame,$frame->{ASK_Button_Reprint_her1},\&HerPrint1);
               Wx::Event::EVT_BUTTON($frame,$frame->{ASK_Button_Reprint_her2},\&HerPrint2);
               $frame->{pane_Ask_boven}->SetSizer($frame->{ASK_Sizer_1});
               #$frame->SetSizer($frame->{ASK_Sizer_1});               
               #$frame->SetBackgroundColour(Wx::Colour->new(239, 243, 255));
               return ($frame);
        }
     sub Cancel {
        die;
     }
     sub OK {
        my $dbh = sql_toegang_agresso->setup_mssql_connectie;
        $main::dbh_main = $dbh;
        my $begindatum_eerste = $frame->{ASK_Txt_Begindatum_Eerste}->GetValue();
        my $einddatum_eerste = $frame->{ASK_Txt_Einddatum_Eerste}->GetValue();
        my $begindatum_tweede = $frame->{ASK_Txt_Begindatum_Tweede}->GetValue();
        my $einddatum_tweede = $frame->{ASK_Txt_Einddatum_Tweede}->GetValue();
        print '';
        ($main::aantal_lijnen_eersteher,$main::tabel_eersteher)= sql_toegang_agresso->get_eerste_her($dbh,$begindatum_eerste,$einddatum_eerste, $frame);
        ($main::aantal_lijnen_tweedeher,$main::tabel_tweedeher)= sql_toegang_agresso->get_tweede_her($dbh,$begindatum_tweede,$einddatum_tweede, $frame);
        print '';
        undef $main::her1_matrix;
         for my $r (0..200) {
                    for my $c (0..4) {                       
                        $her1_matrix[$r][$c]="";
                        
                    }
                }
        undef $main::her2_matrix;
        for my $r (0..200) {
                    for my $c (0..4) {                        
                        $her2_matrix[$r][$c]="";
                        
                    }
                }
        Overzicht_GridApp->refresh_grid($main::grid_her1);
        Overzicht_GridApp->refresh_grid($main::grid_her2);
        for my $r (0..$main::aantal_lijnen_eersteher) {
            $main::her1_matrix[$r][0]=$main::tabel_eersteher->{$r}->[0];
            $main::her1_matrix[$r][1]=$main::tabel_eersteher->{$r}->[1];
            $main::her1_matrix[$r][2]=$main::tabel_eersteher->{$r}->[2];
            $main::her1_matrix[$r][3]=$main::tabel_eersteher->{$r}->[3];
            $main::her1_matrix[$r][4]=$main::tabel_eersteher->{$r}->[4]; 
         }
        for my $r (0..$main::aantal_lijnen_tweedeher) {
            $main::her2_matrix[$r][0]=$main::tabel_tweedeher->{$r}->[0];
            $main::her2_matrix[$r][1]=$main::tabel_tweedeher->{$r}->[1];
            $main::her2_matrix[$r][2]=$main::tabel_tweedeher->{$r}->[2];
            $main::her2_matrix[$r][3]=$main::tabel_tweedeher->{$r}->[3];
            $main::her2_matrix[$r][4]=$main::tabel_tweedeher->{$r}->[4]; 
         }
        Overzicht_GridApp->refresh_grid($main::grid_her1);
        Overzicht_GridApp->refresh_grid($main::grid_her2);
        return($frame);
     }
     sub HerPrint1 {
        my $dbh = $main::dbh_main;
        my $begindatum_eerste = $frame->{ASK_Txt_Begindatum_Eerste}->GetValue();
        my $einddatum_eerste = $frame->{ASK_Txt_Einddatum_Eerste}->GetValue();
        my $begindatum_tweede = $frame->{ASK_Txt_Begindatum_Tweede}->GetValue();
        my $einddatum_tweede = $frame->{ASK_Txt_Einddatum_Tweede}->GetValue();     
        sql_toegang_agresso->reprint_eerste_her($dbh,$begindatum_eerste,$einddatum_eerste, $frame);
        ($main::aantal_lijnen_eersteher,$main::tabel_eersteher)= sql_toegang_agresso->get_eerste_her($dbh,$begindatum_eerste,$einddatum_eerste, $frame);
        ($main::aantal_lijnen_tweedeher,$main::tabel_tweedeher)= sql_toegang_agresso->get_tweede_her($dbh,$begindatum_tweede,$einddatum_tweede, $frame);
        print '';
        undef $main::her1_matrix;
         for my $r (0..200) {
                    for my $c (0..4) {                       
                        $her1_matrix[$r][$c]="";
                        
                    }
                }
        undef $main::her2_matrix;
        for my $r (0..200) {
                    for my $c (0..4) {                        
                        $her2_matrix[$r][$c]="";
                        
                    }
                }
        Overzicht_GridApp->refresh_grid($main::grid_her1);
        Overzicht_GridApp->refresh_grid($main::grid_her2);
        for my $r (0..$main::aantal_lijnen_eersteher) {
            $main::her1_matrix[$r][0]=$main::tabel_eersteher->{$r}->[0];
            $main::her1_matrix[$r][1]=$main::tabel_eersteher->{$r}->[1];
            $main::her1_matrix[$r][2]=$main::tabel_eersteher->{$r}->[2];
            $main::her1_matrix[$r][3]=$main::tabel_eersteher->{$r}->[3];
            $main::her1_matrix[$r][4]=$main::tabel_eersteher->{$r}->[4]; 
         }
        for my $r (0..$main::aantal_lijnen_tweedeher) {
            $main::her2_matrix[$r][0]=$main::tabel_tweedeher->{$r}->[0];
            $main::her2_matrix[$r][1]=$main::tabel_tweedeher->{$r}->[1];
            $main::her2_matrix[$r][2]=$main::tabel_tweedeher->{$r}->[2];
            $main::her2_matrix[$r][3]=$main::tabel_tweedeher->{$r}->[3];
            $main::her2_matrix[$r][4]=$main::tabel_tweedeher->{$r}->[4]; 
         }
        Overzicht_GridApp->refresh_grid($main::grid_her1);
        Overzicht_GridApp->refresh_grid($main::grid_her2);
        return($frame);
     }
     sub HerPrint2 {
        my $dbh = $main::dbh_main;
        my $begindatum_eerste = $frame->{ASK_Txt_Begindatum_Eerste}->GetValue();
        my $einddatum_eerste = $frame->{ASK_Txt_Einddatum_Eerste}->GetValue();
        my $begindatum_tweede = $frame->{ASK_Txt_Begindatum_Tweede}->GetValue();
        my $einddatum_tweede = $frame->{ASK_Txt_Einddatum_Tweede}->GetValue();     
        sql_toegang_agresso->reprint_tweede_her($dbh,$begindatum_eerste,$einddatum_eerste, $frame);
        ($main::aantal_lijnen_eersteher,$main::tabel_eersteher)= sql_toegang_agresso->get_eerste_her($dbh,$begindatum_eerste,$einddatum_eerste, $frame);
        ($main::aantal_lijnen_tweedeher,$main::tabel_tweedeher)= sql_toegang_agresso->get_tweede_her($dbh,$begindatum_tweede,$einddatum_tweede, $frame);
        print '';
        undef $main::her1_matrix;
         for my $r (0..200) {
                    for my $c (0..4) {                       
                        $her1_matrix[$r][$c]="";
                        
                    }
                }
        undef $main::her2_matrix;
        for my $r (0..200) {
                    for my $c (0..4) {                        
                        $her2_matrix[$r][$c]="";
                        
                    }
                }
        Overzicht_GridApp->refresh_grid($main::grid_her1);
        Overzicht_GridApp->refresh_grid($main::grid_her2);
        for my $r (0..$main::aantal_lijnen_eersteher) {
            $main::her1_matrix[$r][0]=$main::tabel_eersteher->{$r}->[0];
            $main::her1_matrix[$r][1]=$main::tabel_eersteher->{$r}->[1];
            $main::her1_matrix[$r][2]=$main::tabel_eersteher->{$r}->[2];
            $main::her1_matrix[$r][3]=$main::tabel_eersteher->{$r}->[3];
            $main::her1_matrix[$r][4]=$main::tabel_eersteher->{$r}->[4]; 
         }
        for my $r (0..$main::aantal_lijnen_tweedeher) {
            $main::her2_matrix[$r][0]=$main::tabel_tweedeher->{$r}->[0];
            $main::her2_matrix[$r][1]=$main::tabel_tweedeher->{$r}->[1];
            $main::her2_matrix[$r][2]=$main::tabel_tweedeher->{$r}->[2];
            $main::her2_matrix[$r][3]=$main::tabel_tweedeher->{$r}->[3];
            $main::her2_matrix[$r][4]=$main::tabel_tweedeher->{$r}->[4]; 
         }
        Overzicht_GridApp->refresh_grid($main::grid_her1);
        Overzicht_GridApp->refresh_grid($main::grid_her2);
        return($frame);
     }  
package sql_toegang_agresso;
    use DBI::DBD;
    sub setup_mssql_connectie {
        my $ip = $agresso_instellingen->{"Agresso_SQL_$main::mode"};
        my $database=$agresso_instellingen->{"Agresso_Database_$main::mode"};
        my $dbh_mssql;
        my $dsn_mssql = join "", (
            "dbi:ODBC:",
            "Driver={SQL Server};",
            "Server=$ip;", # nieuwe database server 2016 05 S000WP1XXLSQL01.mutworld.be\i200
            "UID=HOSPIPLUS;",
            "PWD=ihuho4sdxn;",
            "Database=$database",
           );
         my $user = 'HOSPIPLUS';
         my $passwd = 'ihuho4sdxn';
        
         my $db_options = {
            PrintError => 1,
            RaiseError => 1,
            AutoCommit => 1, #0 werkt niet in
            LongReadLen =>2000,
   
           };
        #
        # connect to database
        #
        $dbh_mssql = DBI->connect($dsn_mssql, $user, $passwd, $db_options) or exit_msg("Can't connect: $DBI::errstr");
        return ($dbh_mssql)
       }
    sub get_eerste_her {
         my ($self, $dbh ,$begindatum, $einddatum) = @_;
         my $client ='VMOB';
         my $attribute_id = 'A4';
         my $user_id = 'WEBSERV';
         my $To_Remind;
         my $sql =("SELECT dim_value,naam_sjabloon,datum_ingezet,datum_eerste_her,datum_eerste_her_geprint FROM afxvmobtoremind
                   WHERE client = '$client' and datum_eerste_her_geprint >= '$begindatum' and datum_eerste_her_geprint <= '$einddatum' order by dim_value");#and datum_eerste_her = $datum_vandaag 
         my $sth = $dbh->prepare($sql);
         $sth->execute();
         my $lijn = 0;
         my $tabel;
         while (my @to_remind = $sth->fetchrow_array) {
              print "@to_remind \n";
              $tabel->{$lijn} =[@to_remind];
              $lijn +=1;
              
            }         
         return($lijn,$tabel)
        }
     sub get_tweede_her {
         my ($self, $dbh ,$begindatum, $einddatum) = @_;
         my $client ='VMOB';
         my $attribute_id = 'A4';
         my $user_id = 'WEBSERV';
         my $To_Remind;
         my $sql =("SELECT dim_value,naam_sjabloon,datum_ingezet,datum_tweede_her,datum_tweede_her_geprint FROM afxvmobtoremind
                   WHERE client = '$client' and datum_tweede_her_geprint >= '$begindatum' and datum_tweede_her_geprint <= '$einddatum' order by dim_value");#and datum_eerste_her = $datum_vandaag 
         my $sth = $dbh->prepare($sql);
         $sth->execute();
         my $lijn = 0;
         my $tabel;
         while (my @to_remind = $sth->fetchrow_array) {
              print "@to_remind \n";
              $tabel->{$lijn} =[@to_remind];
              $lijn +=1;
              
            }
         return($lijn,$tabel);
        }
     sub reprint_eerste_her {
         my ($self, $dbh ,$begindatum, $einddatum) = @_;
         my $client ='VMOB';
         my $attribute_id = 'A4';
         my $user_id = 'WEBSERV';
         my $To_Remind;
         my $sql =("update afxvmobtoremind set datum_eerste_her_geprint = '' where datum_eerste_her_geprint >= '$begindatum' and datum_eerste_her_geprint <= '$einddatum';");#and datum_eerste_her = $datum_vandaag 
         my $sth = $dbh->prepare($sql);
         $sth->execute();
        }
      sub reprint_tweede_her {
         my ($self, $dbh ,$begindatum, $einddatum) = @_;
         my $client ='VMOB';
         my $attribute_id = 'A4';
         my $user_id = 'WEBSERV';
         my $To_Remind;
         my $sql =("update afxvmobtoremind set datum_tweede_her_geprint = '' where datum_tweede_her_geprint >= '$begindatum' and datum_tweede_her_geprint <= '$einddatum';");#and datum_eerste_her = $datum_vandaag 
         my $sth = $dbh->prepare($sql);
         $sth->execute();
        }