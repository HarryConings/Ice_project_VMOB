#!/usr/bin/perl -w
use strict;


package Commentaar_tab ;
use Wx qw[:everything];
     use base qw(Wx::Frame);
     #use Data::Dumper
     use strict;
     use Wx::Locale gettext => '_T';
sub new {
     my ($class, $frame) = @_;
     $frame->{CT_sizer_1} = Wx::FlexGridSizer->new(1,3, 10, 10);
     $frame->{CT_Button_Opslaan}  = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_CT}, -1, _T("Commentaar\nOplsaan"),wxDefaultPosition,wxSIZE(80,80));
     $frame->{CT_Txt_Commentaar}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_CT}, -1, $main::commentaar,wxDefaultPosition,wxSIZE(800,80));
     #CT MainFrameNotebookBoven_pane_CT
     #Rij1
     #kolom 1 +2+3
         $frame->{CT_panel_1} = Wx::Panel->new($frame->{MainFrameNotebookBoven_pane_CT},-1,wxDefaultPosition,wxSIZE(15,80));
         #$frame->{BA_EZ_sizer_1}->Add($frame->{BA_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{CT_sizer_1}->Add($frame->{CT_Button_Opslaan}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{CT_sizer_1}->Add($frame->{CT_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);  
         $frame->{CT_sizer_1}->Add($frame->{CT_Txt_Commentaar}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         
     Wx::Event::EVT_BUTTON( $frame,$frame->{CT_Button_Opslaan},\&Oplsaan_commentaar);    
    }
sub Oplsaan_commentaar {
     my ($frame, $evt) = @_;
}

1;