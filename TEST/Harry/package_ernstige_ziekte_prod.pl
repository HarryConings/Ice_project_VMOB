#!/usr/bin/perl -w
use strict;
package ErnstigeZiekte;
     use Wx qw[:everything];
     use base qw(Wx::Frame);
     #use Data::Dumper
     use strict;
     use Wx::Locale gettext => '_T';
     sub new {
         my ($class, $frame) = @_;         
         $frame->{EZ_sizer_1} = Wx::FlexGridSizer->new(4,8, 10, 10);
         $frame->{EZ_Button_Ernstige_Ziekte}  = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_EZ}, -1, _T("Ernstige Ziekte"),wxDefaultPosition,wxSIZE(350,20));
         $frame->{EZ_Button_Verzekering}  = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_EZ}, -1, _T("Verzekering"),wxDefaultPosition,wxSIZE(200,20));
         $frame->{EZ_Button_Ernstige_Ziekte_1}  = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_EZ}, -1, _T("Ernstige Ziekte"),wxDefaultPosition,wxSIZE(350,20));
         $frame->{EZ_Button_Verzekering_1}  = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_EZ}, -1, _T("Verzekering"),wxDefaultPosition,wxSIZE(200,20));
         $frame->{EZ_Button_Ernstige_Ziekte_2}  = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_EZ}, -1, _T("Ernstige Ziekte"),wxDefaultPosition,wxSIZE(350,20));
         $frame->{EZ_Button_Verzekering_2}  = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_EZ}, -1, _T("Verzekering"),wxDefaultPosition,wxSIZE(200,20));
         $frame->{EZ_Txt_0_ziekte}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_EZ}, -1, $main::klant->{ziekten}->[0]->{ziekte},wxDefaultPosition,wxSIZE(350,20));
         $frame->{EZ_Txt_0_verzekering}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_EZ}, -1, $main::klant->{ziekten}->[0]->{verzekering},wxDefaultPosition,wxSIZE(200,20));
         $frame->{EZ_Txt_1_ziekte}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_EZ}, -1, $main::klant->{ziekten}->[1]->{ziekte},wxDefaultPosition,wxSIZE(350,20));
         $frame->{EZ_Txt_1_verzekering}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_EZ}, -1, $main::klant->{ziekten}->[1]->{verzekering},wxDefaultPosition,wxSIZE(200,20));
         $frame->{EZ_Txt_2_ziekte}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_EZ}, -1, $main::klant->{ziekten}->[2]->{ziekte},wxDefaultPosition,wxSIZE(350,20));
         $frame->{EZ_Txt_2_verzekering}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_EZ}, -1, $main::klant->{ziekten}->[2]->{verzekering},wxDefaultPosition,wxSIZE(200,20));
         $frame->{EZ_Txt_3_ziekte}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_EZ}, -1, $main::klant->{ziekten}->[3]->{ziekte},wxDefaultPosition,wxSIZE(350,20));
         $frame->{EZ_Txt_3_verzekering}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_EZ}, -1, $main::klant->{ziekten}->[3]->{verzekering},wxDefaultPosition,wxSIZE(200,20));
         $frame->{EZ_Txt_4_ziekte}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_EZ}, -1, $main::klant->{ziekten}->[4]->{ziekte},wxDefaultPosition,wxSIZE(350,20));
         $frame->{EZ_Txt_4_verzekering}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_EZ}, -1, $main::klant->{ziekten}->[4]->{verzekering},wxDefaultPosition,wxSIZE(200,20));
         $frame->{EZ_Txt_5_ziekte}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_EZ}, -1, $main::klant->{ziekten}->[5]->{ziekte},wxDefaultPosition,wxSIZE(350,20));
         $frame->{EZ_Txt_5_verzekering}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_EZ}, -1, $main::klant->{ziekten}->[5]->{verzekering},wxDefaultPosition,wxSIZE(200,20));
         $frame->{EZ_Txt_6_ziekte}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_EZ}, -1, $main::klant->{ziekten}->[6]->{ziekte},wxDefaultPosition,wxSIZE(350,20));
         $frame->{EZ_Txt_6_verzekering}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_EZ}, -1, $main::klant->{ziekten}->[6]->{verzekering},wxDefaultPosition,wxSIZE(200,20));
         $frame->{EZ_Txt_7_ziekte}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_EZ}, -1, $main::klant->{ziekten}->[7]->{ziekte},wxDefaultPosition,wxSIZE(350,20));
         $frame->{EZ_Txt_7_verzekering}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_EZ}, -1, $main::klant->{ziekten}->[7]->{verzekering},wxDefaultPosition,wxSIZE(200,20));
         $frame->{EZ_Txt_8_ziekte}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_EZ}, -1, $main::klant->{ziekten}->[8]->{ziekte},wxDefaultPosition,wxSIZE(350,20));
         $frame->{EZ_Txt_8_verzekering}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_EZ}, -1, $main::klant->{ziekten}->[8]->{verzekering},wxDefaultPosition,wxSIZE(200,20));
         #
         
         $frame->{EZ_panel_1} = Wx::Panel->new($frame->{MainFrameNotebookBoven_pane_EZ},-1,wxDefaultPosition,wxSIZE(20,20));
         #$frame->{BA_EZ_sizer_1}->Add($frame->{BA_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         #Rij1
         $frame->{EZ_sizer_1}->Add( $frame->{EZ_Button_Ernstige_Ziekte} , 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{EZ_sizer_1}->Add($frame->{EZ_Button_Verzekering}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{EZ_sizer_1}->Add($frame->{EZ_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{EZ_sizer_1}->Add($frame->{EZ_Button_Ernstige_Ziekte_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{EZ_sizer_1}->Add($frame->{EZ_Button_Verzekering_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{EZ_sizer_1}->Add($frame->{EZ_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{EZ_sizer_1}->Add($frame->{EZ_Button_Ernstige_Ziekte_2}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{EZ_sizer_1}->Add($frame->{EZ_Button_Verzekering_2}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         #rij2
         $frame->{EZ_sizer_1}->Add($frame->{EZ_Txt_0_ziekte}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{EZ_sizer_1}->Add($frame->{EZ_Txt_0_verzekering}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{EZ_sizer_1}->Add($frame->{EZ_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{EZ_sizer_1}->Add($frame->{EZ_Txt_3_ziekte}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{EZ_sizer_1}->Add($frame->{EZ_Txt_3_verzekering}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{EZ_sizer_1}->Add($frame->{EZ_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{EZ_sizer_1}->Add($frame->{EZ_Txt_6_ziekte}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{EZ_sizer_1}->Add($frame->{EZ_Txt_6_verzekering}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         #rij3
         $frame->{EZ_sizer_1}->Add($frame->{EZ_Txt_1_ziekte}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{EZ_sizer_1}->Add($frame->{EZ_Txt_1_verzekering}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{EZ_sizer_1}->Add($frame->{EZ_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{EZ_sizer_1}->Add($frame->{EZ_Txt_4_ziekte}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{EZ_sizer_1}->Add($frame->{EZ_Txt_4_verzekering}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{EZ_sizer_1}->Add($frame->{EZ_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{EZ_sizer_1}->Add($frame->{EZ_Txt_7_ziekte}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{EZ_sizer_1}->Add($frame->{EZ_Txt_7_verzekering}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         #rij4
         $frame->{EZ_sizer_1}->Add($frame->{EZ_Txt_2_ziekte}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{EZ_sizer_1}->Add($frame->{EZ_Txt_2_verzekering}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{EZ_sizer_1}->Add($frame->{EZ_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{EZ_sizer_1}->Add($frame->{EZ_Txt_5_ziekte}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{EZ_sizer_1}->Add($frame->{EZ_Txt_5_verzekering}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{EZ_sizer_1}->Add($frame->{EZ_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{EZ_sizer_1}->Add($frame->{EZ_Txt_8_ziekte}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{EZ_sizer_1}->Add($frame->{EZ_Txt_8_verzekering}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         
     }
         
1;