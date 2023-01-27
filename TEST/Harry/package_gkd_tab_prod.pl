#!/usr/bin/perl -w
use strict;


package gkd_tab;

use Wx qw[:everything];
use base qw(Wx::Frame);
#use Data::Dumper
use strict;
use Wx::Locale gettext => '_T';
use Wx::Event qw(EVT_CHECKBOX);
use Wx::Event qw(EVT_MENU EVT_CLOSE);
use DateTime::Format::Strptime;
use DateTime;
sub new {
      my ($class, $frame) = @_;
      $frame->{GKD_sizer_1} = Wx::FlexGridSizer->new(4,19, 10, 10);
      #$frame->{GKD_static_SCHADE}  = Wx::txtText->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,_T("TEKST"),wxDefaultPosition,wxSIZE(70,20));
      my $test11 = $main::teksten_GKD->{GKD_teksten}->{TABBLAD_GKD}->{tekst}->[11];
      my $test1 = $main::teksten_GKD;
      $frame->{GKD_chk_0}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,$main::gkd_commentaar->{0},wxDefaultPosition,wxSIZE(15,20));
      $frame->{GKD_txt_0}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,$main::teksten_GKD->{GKD_teksten}->{TABBLAD_GKD}->{tekst}->[0],wxDefaultPosition,wxSIZE(250,20));
      $frame->{GKD_chk_1}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,$main::gkd_commentaar->{1},wxDefaultPosition,wxSIZE(15,20));
      $frame->{GKD_txt_1}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,$main::teksten_GKD->{GKD_teksten}->{TABBLAD_GKD}->{tekst}->[1],wxDefaultPosition,wxSIZE(250,20));
      $frame->{GKD_chk_2}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,$main::gkd_commentaar->{2},wxDefaultPosition,wxSIZE(15,20));
      $frame->{GKD_txt_2}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,$main::teksten_GKD->{GKD_teksten}->{TABBLAD_GKD}->{tekst}->[2],wxDefaultPosition,wxSIZE(250,20));
      $frame->{GKD_chk_3}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,$main::gkd_commentaar->{3},wxDefaultPosition,wxSIZE(15,20));
      $frame->{GKD_txt_3}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,$main::teksten_GKD->{GKD_teksten}->{TABBLAD_GKD}->{tekst}->[3],wxDefaultPosition,wxSIZE(250,20));
      $frame->{GKD_chk_4}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,$main::gkd_commentaar->{4},wxDefaultPosition,wxSIZE(15,20));      
      $frame->{GKD_txt_4}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,$main::teksten_GKD->{GKD_teksten}->{TABBLAD_GKD}->{tekst}->[4],wxDefaultPosition,wxSIZE(250,20));
      $frame->{GKD_chk_5}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,$main::gkd_commentaar->{5},wxDefaultPosition,wxSIZE(15,20));          
      $frame->{GKD_txt_5}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,$main::teksten_GKD->{GKD_teksten}->{TABBLAD_GKD}->{tekst}->[5],wxDefaultPosition,wxSIZE(250,20));
      
      #$frame->{GKD_static_AANSLUITING}  = Wx::txtText->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,_T("TEKST"),wxDefaultPosition,wxSIZE(70,20));
      $frame->{GKD_chk_6}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,$main::gkd_commentaar->{6},wxDefaultPosition,wxSIZE(15,20)); 
      $frame->{GKD_txt_6}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,$main::teksten_GKD->{GKD_teksten}->{TABBLAD_GKD}->{tekst}->[6],wxDefaultPosition,wxSIZE(250,20));
      $frame->{GKD_chk_7}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,$main::gkd_commentaar->{7},wxDefaultPosition,wxSIZE(15,20));  
      $frame->{GKD_txt_7}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,$main::teksten_GKD->{GKD_teksten}->{TABBLAD_GKD}->{tekst}->[7],wxDefaultPosition,wxSIZE(250,20));
      $frame->{GKD_chk_8}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,$main::gkd_commentaar->{8},wxDefaultPosition,wxSIZE(15,20));
      $frame->{GKD_txt_8}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,$main::teksten_GKD->{GKD_teksten}->{TABBLAD_GKD}->{tekst}->[8],wxDefaultPosition,wxSIZE(250,20));
      $frame->{GKD_chk_9}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,$main::gkd_commentaar->{9},wxDefaultPosition,wxSIZE(15,20));
      $frame->{GKD_txt_9}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,$main::teksten_GKD->{GKD_teksten}->{TABBLAD_GKD}->{tekst}->[9],wxDefaultPosition,wxSIZE(250,20));
      $frame->{GKD_chk_10}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,$main::gkd_commentaar->{10},wxDefaultPosition,wxSIZE(15,20));  
      $frame->{GKD_txt_10}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,$main::teksten_GKD->{GKD_teksten}->{TABBLAD_GKD}->{tekst}->[10],wxDefaultPosition,wxSIZE(250,20));
      
      #$frame->{GKD_static_DIVERSE}  = Wx::txtText->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,_T("DIVERSE"),wxDefaultPosition,wxSIZE(70,20));  
      $frame->{GKD_chk_11}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,$main::gkd_commentaar->{11},wxDefaultPosition,wxSIZE(15,20));  
      $frame->{GKD_txt_11}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,$main::teksten_GKD->{GKD_teksten}->{TABBLAD_GKD}->{tekst}->[11],wxDefaultPosition,wxSIZE(250,20));
      $frame->{GKD_chk_12}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,$main::gkd_commentaar->{12},wxDefaultPosition,wxSIZE(15,20)); 
      $frame->{GKD_txt_12}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,$main::teksten_GKD->{GKD_teksten}->{TABBLAD_GKD}->{tekst}->[12],wxDefaultPosition,wxSIZE(250,20));
      $frame->{GKD_chk_13}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,$main::gkd_commentaar->{13},wxDefaultPosition,wxSIZE(15,20));    
      $frame->{GKD_txt_13}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,$main::teksten_GKD->{GKD_teksten}->{TABBLAD_GKD}->{tekst}->[13],wxDefaultPosition,wxSIZE(250,20));
      $frame->{GKD_chk_14}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,$main::gkd_commentaar->{14},wxDefaultPosition,wxSIZE(15,20));    
      $frame->{GKD_txt_14}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,$main::teksten_GKD->{GKD_teksten}->{TABBLAD_GKD}->{tekst}->[14],wxDefaultPosition,wxSIZE(250,20));
      $frame->{GKD_chk_15}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,$main::gkd_commentaar->{15},wxDefaultPosition,wxSIZE(15,20));    
      $frame->{GKD_txt_15}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,$main::teksten_GKD->{GKD_teksten}->{TABBLAD_GKD}->{tekst}->[15],wxDefaultPosition,wxSIZE(250,20));
      $frame->{GKD_chk_16}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,$main::gkd_commentaar->{16},wxDefaultPosition,wxSIZE(15,20));    
      $frame->{GKD_txt_16}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,$main::teksten_GKD->{GKD_teksten}->{TABBLAD_GKD}->{tekst}->[16],wxDefaultPosition,wxSIZE(250,20));
      $frame->{GKD_chk_17}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,$main::gkd_commentaar->{17},wxDefaultPosition,wxSIZE(15,20));    
      $frame->{GKD_txt_17}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,$main::teksten_GKD->{GKD_teksten}->{TABBLAD_GKD}->{tekst}->[17],wxDefaultPosition,wxSIZE(250,20));
     
      $frame->{GKD_chk_18}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,$main::gkd_commentaar->{18},wxDefaultPosition,wxSIZE(15,20)); 
      $frame->{GKD_txt_18}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,$main::teksten_GKD->{GKD_teksten}->{TABBLAD_GKD}->{tekst}->[18],wxDefaultPosition,wxSIZE(250,20));
      $frame->{GKD_chk_19}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,$main::gkd_commentaar->{19},wxDefaultPosition,wxSIZE(15,20));    
      $frame->{GKD_txt_19}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,$main::teksten_GKD->{GKD_teksten}->{TABBLAD_GKD}->{tekst}->[19],wxDefaultPosition,wxSIZE(250,20));
      $frame->{GKD_chk_20}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,$main::gkd_commentaar->{20},wxDefaultPosition,wxSIZE(15,20));    
      $frame->{GKD_txt_20}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,$main::teksten_GKD->{GKD_teksten}->{TABBLAD_GKD}->{tekst}->[20],wxDefaultPosition,wxSIZE(250,20));
      $frame->{GKD_chk_21}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,$main::gkd_commentaar->{21},wxDefaultPosition,wxSIZE(15,20));    
      $frame->{GKD_txt_21}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,$main::teksten_GKD->{GKD_teksten}->{TABBLAD_GKD}->{tekst}->[21],wxDefaultPosition,wxSIZE(250,20));
      $frame->{GKD_chk_22}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,$main::gkd_commentaar->{22},wxDefaultPosition,wxSIZE(15,20));    
      $frame->{GKD_txt_22}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,$main::teksten_GKD->{GKD_teksten}->{TABBLAD_GKD}->{tekst}->[22],wxDefaultPosition,wxSIZE(250,20));
      $frame->{GKD_chk_23}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,$main::gkd_commentaar->{23},wxDefaultPosition,wxSIZE(15,20));    
      $frame->{GKD_txt_23}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_GKD}, -1,$main::teksten_GKD->{GKD_teksten}->{TABBLAD_GKD}->{tekst}->[23],wxDefaultPosition,wxSIZE(250,20));
     
     
     $frame->{GKD_panel_1} = Wx::Panel->new($frame->{MainFrameNotebookBoven_pane_GKD},-1,wxDefaultPosition,wxSIZE(15,20));
     #RIJ1
     #kolom   1+2+3+4
     $frame->{GKD_sizer_1}->Add($frame->{GKD_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{GKD_sizer_1}->Add($frame->{GKD_chk_0}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{GKD_sizer_1}->Add($frame->{GKD_txt_0}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{GKD_sizer_1}->Add($frame->{GKD_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     #kolom 5+6+7
     $frame->{GKD_sizer_1}->Add($frame->{GKD_chk_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{GKD_sizer_1}->Add($frame->{GKD_txt_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{GKD_sizer_1}->Add($frame->{GKD_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     #kolom 8+9+10
     $frame->{GKD_sizer_1}->Add($frame->{GKD_chk_2}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{GKD_sizer_1}->Add($frame->{GKD_txt_2}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{GKD_sizer_1}->Add($frame->{GKD_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     #kolom11+12+13
     $frame->{GKD_sizer_1}->Add($frame->{GKD_chk_3}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{GKD_sizer_1}->Add($frame->{GKD_txt_3}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{GKD_sizer_1}->Add($frame->{GKD_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     #kolom 14+15+16
     $frame->{GKD_sizer_1}->Add($frame->{GKD_chk_4}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{GKD_sizer_1}->Add($frame->{GKD_txt_4}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{GKD_sizer_1}->Add($frame->{GKD_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
      #kolom 17+18+19
     $frame->{GKD_sizer_1}->Add($frame->{GKD_chk_5}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{GKD_sizer_1}->Add($frame->{GKD_txt_5}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{GKD_sizer_1}->Add($frame->{GKD_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         
     
     #RIJ2
     #kolom 1 +2 +3
     #kolom   1+2+3+4
     $frame->{GKD_sizer_1}->Add($frame->{GKD_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{GKD_sizer_1}->Add($frame->{GKD_chk_6}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{GKD_sizer_1}->Add($frame->{GKD_txt_6}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{GKD_sizer_1}->Add($frame->{GKD_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     #kolom 5+6+7
     $frame->{GKD_sizer_1}->Add($frame->{GKD_chk_7}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{GKD_sizer_1}->Add($frame->{GKD_txt_7}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{GKD_sizer_1}->Add($frame->{GKD_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     #kolom 8+9+10
     $frame->{GKD_sizer_1}->Add($frame->{GKD_chk_8}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{GKD_sizer_1}->Add($frame->{GKD_txt_8}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{GKD_sizer_1}->Add($frame->{GKD_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     #kolom 11+12+13
     $frame->{GKD_sizer_1}->Add($frame->{GKD_chk_9}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{GKD_sizer_1}->Add($frame->{GKD_txt_9}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{GKD_sizer_1}->Add($frame->{GKD_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     #kolom 14+15+16
     $frame->{GKD_sizer_1}->Add($frame->{GKD_chk_10}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{GKD_sizer_1}->Add($frame->{GKD_txt_10}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{GKD_sizer_1}->Add($frame->{GKD_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     #kolom 17+18+19
     $frame->{GKD_sizer_1}->Add($frame->{GKD_chk_11}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{GKD_sizer_1}->Add($frame->{GKD_txt_11}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{GKD_sizer_1}->Add($frame->{GKD_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     
     #RIJ 3
     #kolom   1+2+3+4
     $frame->{GKD_sizer_1}->Add($frame->{GKD_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{GKD_sizer_1}->Add($frame->{GKD_chk_12}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{GKD_sizer_1}->Add($frame->{GKD_txt_12}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{GKD_sizer_1}->Add($frame->{GKD_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     #kolom 5+6+7
     $frame->{GKD_sizer_1}->Add($frame->{GKD_chk_13}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{GKD_sizer_1}->Add($frame->{GKD_txt_13}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{GKD_sizer_1}->Add($frame->{GKD_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     #kolom 8+9+10
     $frame->{GKD_sizer_1}->Add($frame->{GKD_chk_14}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{GKD_sizer_1}->Add($frame->{GKD_txt_14}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{GKD_sizer_1}->Add($frame->{GKD_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     #kolom 11+12+13
     $frame->{GKD_sizer_1}->Add($frame->{GKD_chk_15}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{GKD_sizer_1}->Add($frame->{GKD_txt_15}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{GKD_sizer_1}->Add($frame->{GKD_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
      #kolom 14+15+16
     $frame->{GKD_sizer_1}->Add($frame->{GKD_chk_16}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{GKD_sizer_1}->Add($frame->{GKD_txt_16}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{GKD_sizer_1}->Add($frame->{GKD_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
      #kolom 17+1+18+19
     $frame->{GKD_sizer_1}->Add($frame->{GKD_chk_17}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{GKD_sizer_1}->Add($frame->{GKD_txt_17}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{GKD_sizer_1}->Add($frame->{GKD_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     #RIJ4
     #schade
     $frame->{GKD_sizer_1}->Add($frame->{GKD_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{GKD_sizer_1}->Add($frame->{GKD_chk_18}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{GKD_sizer_1}->Add($frame->{GKD_txt_18}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{GKD_sizer_1}->Add($frame->{GKD_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     #kolom 5+6+7
     $frame->{GKD_sizer_1}->Add($frame->{GKD_chk_19}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{GKD_sizer_1}->Add($frame->{GKD_txt_19}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{GKD_sizer_1}->Add($frame->{GKD_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     #kolom 8+9+10
     $frame->{GKD_sizer_1}->Add($frame->{GKD_chk_20}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{GKD_sizer_1}->Add($frame->{GKD_txt_20}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{GKD_sizer_1}->Add($frame->{GKD_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     #kolom 11+12+13
     $frame->{GKD_sizer_1}->Add($frame->{GKD_chk_21}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{GKD_sizer_1}->Add($frame->{GKD_txt_21}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{GKD_sizer_1}->Add($frame->{GKD_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
      #kolom 14+15+16
     $frame->{GKD_sizer_1}->Add($frame->{GKD_chk_22}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{GKD_sizer_1}->Add($frame->{GKD_txt_22}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{GKD_sizer_1}->Add($frame->{GKD_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
      #kolom 17+1+18+19
     $frame->{GKD_sizer_1}->Add($frame->{GKD_chk_23}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{GKD_sizer_1}->Add($frame->{GKD_txt_23}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{GKD_sizer_1}->Add($frame->{GKD_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     
     
     
     
     Wx::Event::EVT_CHECKBOX($frame,$frame->{GKD_chk_0}, \&GKD_chk_0_clicked);
     Wx::Event::EVT_CHECKBOX($frame,$frame->{GKD_chk_1}, \&GKD_chk_1_clicked);
     Wx::Event::EVT_CHECKBOX($frame,$frame->{GKD_chk_2}, \&GKD_chk_2_clicked);
     Wx::Event::EVT_CHECKBOX($frame,$frame->{GKD_chk_3}, \&GKD_chk_3_clicked);
     Wx::Event::EVT_CHECKBOX($frame,$frame->{GKD_chk_4}, \&GKD_chk_4_clicked);
     Wx::Event::EVT_CHECKBOX($frame,$frame->{GKD_chk_5}, \&GKD_chk_5_clicked);
     #aansluiting
     Wx::Event::EVT_CHECKBOX($frame,$frame->{GKD_chk_6}, \&GKD_chk_6_clicked);
     Wx::Event::EVT_CHECKBOX($frame,$frame->{GKD_chk_7}, \&GKD_chk_7_clicked);
     Wx::Event::EVT_CHECKBOX($frame,$frame->{GKD_chk_8}, \&GKD_chk_8_clicked);
     Wx::Event::EVT_CHECKBOX($frame,$frame->{GKD_chk_9}, \&GKD_chk_9_clicked);
     Wx::Event::EVT_CHECKBOX($frame,$frame->{GKD_chk_10}, \&GKD_chk_10_clicked);
     #diverse
     Wx::Event::EVT_CHECKBOX($frame,$frame->{GKD_chk_11}, \&GKD_chk_11_clicked);
     Wx::Event::EVT_CHECKBOX($frame,$frame->{GKD_chk_12}, \&GKD_chk_12_clicked);
     Wx::Event::EVT_CHECKBOX($frame,$frame->{GKD_chk_13}, \&GKD_chk_13_clicked);
     
     Wx::Event::EVT_CHECKBOX($frame,$frame->{GKD_chk_14}, \&GKD_chk_14_clicked);
     Wx::Event::EVT_CHECKBOX($frame,$frame->{GKD_chk_15}, \&GKD_chk_15_clicked);
     Wx::Event::EVT_CHECKBOX($frame,$frame->{GKD_chk_16}, \&GKD_chk_16_clicked);
     
     Wx::Event::EVT_CHECKBOX($frame,$frame->{GKD_chk_17}, \&GKD_chk_17_clicked);
     Wx::Event::EVT_CHECKBOX($frame,$frame->{GKD_chk_18}, \&GKD_chk_18_clicked);
     Wx::Event::EVT_CHECKBOX($frame,$frame->{GKD_chk_19}, \&GKD_chk_19_clicked);
     
     Wx::Event::EVT_CHECKBOX($frame,$frame->{GKD_chk_20}, \&GKD_chk_20_clicked);
     Wx::Event::EVT_CHECKBOX($frame,$frame->{GKD_chk_21}, \&GKD_chk_21_clicked);
     Wx::Event::EVT_CHECKBOX($frame,$frame->{GKD_chk_22}, \&GKD_chk_22_clicked);
     Wx::Event::EVT_CHECKBOX($frame,$frame->{GKD_chk_23}, \&GKD_chk_23_clicked);
    }
sub GKD_chk_0_clicked {
     my ($frame, $evt) = @_;
     if ($evt->IsChecked()) {
         if ($main::gkd_commentaar->{0} != 1) {
             my $historiek_gkd = $frame->{GKD_txt_0}->GetValue();            
             as400_gegevens->zet_history_gkd_in ($historiek_gkd);
             my $resultaat  = as400_gegevens->lees_history_gkd($frame);
             my $dbh = sql_toegang_agresso->setup_mssql_connectie;
             sql_toegang_agresso->ubtstatistics_insert_row($dbh,$main::klant->{Agresso_nummer},$main::klant->{Ziekenfonds},$historiek_gkd);
             sql_toegang_agresso->disconnect_mssql($dbh);
             print "";
            }
        }else {
         #niets doen
        }     
    }
sub GKD_chk_1_clicked {
     my ($frame, $evt) = @_;
     if ($evt->IsChecked()) {
         if ($main::gkd_commentaar->{1} != 1) {
             my $historiek_gkd = $frame->{GKD_txt_1}->GetValue();            
             as400_gegevens->zet_history_gkd_in ($historiek_gkd);
             my $resultaat  = as400_gegevens->lees_history_gkd($frame);
             my $dbh = sql_toegang_agresso->setup_mssql_connectie;
             sql_toegang_agresso->ubtstatistics_insert_row($dbh,$main::klant->{Agresso_nummer},$main::klant->{Ziekenfonds},$historiek_gkd);
             sql_toegang_agresso->disconnect_mssql($dbh);
            }
        }else {
         #niets doen
        }     
    }
sub GKD_chk_2_clicked {
     my ($frame, $evt) = @_;
     if ($evt->IsChecked()) {
         if ($main::gkd_commentaar->{2} != 1) {
             my $historiek_gkd = $frame->{GKD_txt_2}->GetValue();         
             as400_gegevens->zet_history_gkd_in ($historiek_gkd);
             my $resultaat  = as400_gegevens->lees_history_gkd($frame);
             my $dbh = sql_toegang_agresso->setup_mssql_connectie;
             sql_toegang_agresso->ubtstatistics_insert_row($dbh,$main::klant->{Agresso_nummer},$main::klant->{Ziekenfonds},$historiek_gkd);
             sql_toegang_agresso->disconnect_mssql($dbh);
            }
        }else {
         #niets doen
        }     
    }
sub GKD_chk_3_clicked {
     my ($frame, $evt) = @_;
     if ($evt->IsChecked()) {
         if ($main::gkd_commentaar->{3} != 1) {
             my $historiek_gkd = $frame->{GKD_txt_3}->GetValue();            
             as400_gegevens->zet_history_gkd_in ($historiek_gkd);
             my $resultaat  = as400_gegevens->lees_history_gkd($frame);
             my $dbh = sql_toegang_agresso->setup_mssql_connectie;
             sql_toegang_agresso->ubtstatistics_insert_row($dbh,$main::klant->{Agresso_nummer},$main::klant->{Ziekenfonds},$historiek_gkd);
             sql_toegang_agresso->disconnect_mssql($dbh);
            }
        }else {
         #niets doen
        }     
    }
sub GKD_chk_4_clicked {
     my ($frame, $evt) = @_;
     if ($evt->IsChecked()) {
         if ($main::gkd_commentaar->{4} != 1) {
             my $historiek_gkd = $frame->{GKD_txt_4}->GetValue() ;           
             as400_gegevens->zet_history_gkd_in ($historiek_gkd);
             my $resultaat  = as400_gegevens->lees_history_gkd($frame);
             my $dbh = sql_toegang_agresso->setup_mssql_connectie;
             sql_toegang_agresso->ubtstatistics_insert_row($dbh,$main::klant->{Agresso_nummer},$main::klant->{Ziekenfonds},$historiek_gkd);
             sql_toegang_agresso->disconnect_mssql($dbh);
            }
        }else {
         #niets doen
        }     
    }
sub GKD_chk_5_clicked {
     my ($frame, $evt) = @_;
     if ($evt->IsChecked()) {
         if ($main::gkd_commentaar->{5} != 1) {
             my $historiek_gkd = $frame->{GKD_txt_5}->GetValue();            
             as400_gegevens->zet_history_gkd_in ($historiek_gkd);
             my $resultaat  = as400_gegevens->lees_history_gkd($frame);
             my $dbh = sql_toegang_agresso->setup_mssql_connectie;
             sql_toegang_agresso->ubtstatistics_insert_row($dbh,$main::klant->{Agresso_nummer},$main::klant->{Ziekenfonds},$historiek_gkd);
             sql_toegang_agresso->disconnect_mssql($dbh);
            }
        }else {
         #niets doen
        }     
    }

sub GKD_chk_6_clicked {
     my ($frame, $evt) = @_;
     if ($evt->IsChecked()) {
         if ($main::gkd_commentaar->{6} != 1) {
             my $historiek_gkd = $frame->{GKD_txt_6}->GetValue();                
             as400_gegevens->zet_history_gkd_in ($historiek_gkd);
             my $resultaat  = as400_gegevens->lees_history_gkd($frame);
             my $dbh = sql_toegang_agresso->setup_mssql_connectie;
             sql_toegang_agresso->ubtstatistics_insert_row($dbh,$main::klant->{Agresso_nummer},$main::klant->{Ziekenfonds},$historiek_gkd);
             sql_toegang_agresso->disconnect_mssql($dbh);
            }
        }else {
         #niets doen
        }     
    }
sub GKD_chk_7_clicked {
     my ($frame, $evt) = @_;
     if ($evt->IsChecked()) {
         if ($main::gkd_commentaar->{7} != 1) {
             my $historiek_gkd = $frame->{GKD_txt_7}->GetValue();            
             as400_gegevens->zet_history_gkd_in ($historiek_gkd);
             my $resultaat  = as400_gegevens->lees_history_gkd($frame);
             my $dbh = sql_toegang_agresso->setup_mssql_connectie;
             sql_toegang_agresso->ubtstatistics_insert_row($dbh,$main::klant->{Agresso_nummer},$main::klant->{Ziekenfonds},$historiek_gkd);
             sql_toegang_agresso->disconnect_mssql($dbh);
            }
        }else {
         #niets doen
        }     
    }
sub GKD_chk_8_clicked {
     my ($frame, $evt) = @_;
     if ($evt->IsChecked()) {
         if ($main::gkd_commentaar->{8} != 1) {
             my $historiek_gkd = $frame->{GKD_txt_8}->GetValue();              
             as400_gegevens->zet_history_gkd_in ($historiek_gkd);
             my $resultaat  = as400_gegevens->lees_history_gkd($frame);
             my $dbh = sql_toegang_agresso->setup_mssql_connectie;
             sql_toegang_agresso->ubtstatistics_insert_row($dbh,$main::klant->{Agresso_nummer},$main::klant->{Ziekenfonds},$historiek_gkd);
             sql_toegang_agresso->disconnect_mssql($dbh);
            }
        }else {
         #niets doen
        }     
    }
sub GKD_chk_9_clicked {
     my ($frame, $evt) = @_;
     if ($evt->IsChecked()) {
         if ($main::gkd_commentaar->{9} != 1) {
             my $historiek_gkd = $frame->{GKD_txt_9}->GetValue();               
             as400_gegevens->zet_history_gkd_in ($historiek_gkd);
             my $resultaat  = as400_gegevens->lees_history_gkd($frame);
             my $dbh = sql_toegang_agresso->setup_mssql_connectie;
             sql_toegang_agresso->ubtstatistics_insert_row($dbh,$main::klant->{Agresso_nummer},$main::klant->{Ziekenfonds},$historiek_gkd);
             sql_toegang_agresso->disconnect_mssql($dbh);
            }
        }else {
         #niets doen
        }     
    }
sub GKD_chk_10_clicked {
     my ($frame, $evt) = @_;
     if ($evt->IsChecked()) {
         if ($main::gkd_commentaar->{10} != 1) {
             my $historiek_gkd = $frame->{GKD_txt_10}->GetValue();             
             as400_gegevens->zet_history_gkd_in ($historiek_gkd);
             my $resultaat  = as400_gegevens->lees_history_gkd($frame);
             my $dbh = sql_toegang_agresso->setup_mssql_connectie;
             sql_toegang_agresso->ubtstatistics_insert_row($dbh,$main::klant->{Agresso_nummer},$main::klant->{Ziekenfonds},$historiek_gkd);
             sql_toegang_agresso->disconnect_mssql($dbh);
            }
        }else {
         #niets doen
        }     
    }
sub GKD_chk_11_clicked {
     my ($frame, $evt) = @_;
     if ($evt->IsChecked()) {
         if ($main::gkd_commentaar->{11} != 1) {
             my $historiek_gkd = $frame->{GKD_txt_11}->GetValue();            
             as400_gegevens->zet_history_gkd_in ($historiek_gkd);
             my $resultaat  = as400_gegevens->lees_history_gkd($frame);
             my $dbh = sql_toegang_agresso->setup_mssql_connectie;
             sql_toegang_agresso->ubtstatistics_insert_row($dbh,$main::klant->{Agresso_nummer},$main::klant->{Ziekenfonds},$historiek_gkd);
             sql_toegang_agresso->disconnect_mssql($dbh);
            }
        }else {
         #niets doen
        }     
    }
sub GKD_chk_12_clicked {
     my ($frame, $evt) = @_;
     if ($evt->IsChecked()) {
         if ($main::gkd_commentaar->{12} != 1) {
             my $historiek_gkd = $frame->{GKD_txt_12}->GetValue();               
             as400_gegevens->zet_history_gkd_in ($historiek_gkd);
             my $resultaat  = as400_gegevens->lees_history_gkd($frame);
             my $dbh = sql_toegang_agresso->setup_mssql_connectie;
             sql_toegang_agresso->ubtstatistics_insert_row($dbh,$main::klant->{Agresso_nummer},$main::klant->{Ziekenfonds},$historiek_gkd);
             sql_toegang_agresso->disconnect_mssql($dbh);
            }
        }else {
         #niets doen
        }     
    }
sub GKD_chk_13_clicked {
     my ($frame, $evt) = @_;
     if ($evt->IsChecked()) {
         if ($main::gkd_commentaar->{13} != 1) {
             my $historiek_gkd = $frame->{GKD_txt_13}->GetValue();                
             as400_gegevens->zet_history_gkd_in ($historiek_gkd);
             my $resultaat  = as400_gegevens->lees_history_gkd($frame);
             my $dbh = sql_toegang_agresso->setup_mssql_connectie;
             sql_toegang_agresso->ubtstatistics_insert_row($dbh,$main::klant->{Agresso_nummer},$main::klant->{Ziekenfonds},$historiek_gkd);
             sql_toegang_agresso->disconnect_mssql($dbh);
            
            }
        }else {
         #niets doen
        }     
    }
sub GKD_chk_14_clicked {
     my ($frame, $evt) = @_;
     if ($evt->IsChecked()) {
         if ($main::gkd_commentaar->{14} != 1) {
             my $historiek_gkd = $frame->{GKD_txt_14}->GetValue();                
             as400_gegevens->zet_history_gkd_in ($historiek_gkd);
             my $resultaat  = as400_gegevens->lees_history_gkd($frame);
             my $dbh = sql_toegang_agresso->setup_mssql_connectie;
             sql_toegang_agresso->ubtstatistics_insert_row($dbh,$main::klant->{Agresso_nummer},$main::klant->{Ziekenfonds},$historiek_gkd);
             sql_toegang_agresso->disconnect_mssql($dbh);
            
            }
        }else {
         #niets doen
        }     
    }
sub GKD_chk_15_clicked {
     my ($frame, $evt) = @_;
     if ($evt->IsChecked()) {
         if ($main::gkd_commentaar->{15} != 1) {
             my $historiek_gkd = $frame->{GKD_txt_15}->GetValue();                
             as400_gegevens->zet_history_gkd_in ($historiek_gkd);
             my $resultaat  = as400_gegevens->lees_history_gkd($frame);
             my $dbh = sql_toegang_agresso->setup_mssql_connectie;
             sql_toegang_agresso->ubtstatistics_insert_row($dbh,$main::klant->{Agresso_nummer},$main::klant->{Ziekenfonds},$historiek_gkd);
             sql_toegang_agresso->disconnect_mssql($dbh);
            
            }
        }else {
         #niets doen
        }     
    }
sub GKD_chk_16_clicked {
     my ($frame, $evt) = @_;
     if ($evt->IsChecked()) {
         if ($main::gkd_commentaar->{16} != 1) {
             my $historiek_gkd = $frame->{GKD_txt_16}->GetValue();                
             as400_gegevens->zet_history_gkd_in ($historiek_gkd);
             my $resultaat  = as400_gegevens->lees_history_gkd($frame);
             my $dbh = sql_toegang_agresso->setup_mssql_connectie;
             sql_toegang_agresso->ubtstatistics_insert_row($dbh,$main::klant->{Agresso_nummer},$main::klant->{Ziekenfonds},$historiek_gkd);
             sql_toegang_agresso->disconnect_mssql($dbh);
            
            }
        }else {
         #niets doen
        }     
    }
sub GKD_chk_17_clicked {
     my ($frame, $evt) = @_;
     if ($evt->IsChecked()) {
         if ($main::gkd_commentaar->{17} != 1) {
             my $historiek_gkd = $frame->{GKD_txt_17}->GetValue();                
             as400_gegevens->zet_history_gkd_in ($historiek_gkd);
             my $resultaat  = as400_gegevens->lees_history_gkd($frame);
             my $dbh = sql_toegang_agresso->setup_mssql_connectie;
             sql_toegang_agresso->ubtstatistics_insert_row($dbh,$main::klant->{Agresso_nummer},$main::klant->{Ziekenfonds},$historiek_gkd);
             sql_toegang_agresso->disconnect_mssql($dbh);
            
            }
        }else {
         #niets doen
        }     
    }
sub GKD_chk_18_clicked {
     my ($frame, $evt) = @_;
     if ($evt->IsChecked()) {
         if ($main::gkd_commentaar->{18} != 1) {
             my $historiek_gkd = $frame->{GKD_txt_18}->GetValue();                
             as400_gegevens->zet_history_gkd_in ($historiek_gkd);
             my $resultaat  = as400_gegevens->lees_history_gkd($frame);
             my $dbh = sql_toegang_agresso->setup_mssql_connectie;
             sql_toegang_agresso->ubtstatistics_insert_row($dbh,$main::klant->{Agresso_nummer},$main::klant->{Ziekenfonds},$historiek_gkd);
             sql_toegang_agresso->disconnect_mssql($dbh);
            }
        }else {
         #niets doen
        }     
    }
sub GKD_chk_19_clicked {
     my ($frame, $evt) = @_;
     if ($evt->IsChecked()) {
         if ($main::gkd_commentaar->{19} != 1) {
             my $historiek_gkd = $frame->{GKD_txt_19}->GetValue();                
             as400_gegevens->zet_history_gkd_in ($historiek_gkd);
             my $resultaat  = as400_gegevens->lees_history_gkd($frame);
             my $dbh = sql_toegang_agresso->setup_mssql_connectie;
             sql_toegang_agresso->ubtstatistics_insert_row($dbh,$main::klant->{Agresso_nummer},$main::klant->{Ziekenfonds},$historiek_gkd);
             sql_toegang_agresso->disconnect_mssql($dbh);
            }
        }else {
         #niets doen
        }     
    }
sub GKD_chk_20_clicked {
     my ($frame, $evt) = @_;
     if ($evt->IsChecked()) {
         if ($main::gkd_commentaar->{20} != 1) {
             my $historiek_gkd = $frame->{GKD_txt_20}->GetValue();                
             as400_gegevens->zet_history_gkd_in ($historiek_gkd);
             my $resultaat  = as400_gegevens->lees_history_gkd($frame);
             my $dbh = sql_toegang_agresso->setup_mssql_connectie;
             sql_toegang_agresso->ubtstatistics_insert_row($dbh,$main::klant->{Agresso_nummer},$main::klant->{Ziekenfonds},$historiek_gkd);
             sql_toegang_agresso->disconnect_mssql($dbh);
            }
        }else {
         #niets doen
        }     
    }
sub GKD_chk_21_clicked {
     my ($frame, $evt) = @_;
     if ($evt->IsChecked()) {
         if ($main::gkd_commentaar->{21} != 1) {
             my $historiek_gkd = $frame->{GKD_txt_21}->GetValue();                
             as400_gegevens->zet_history_gkd_in ($historiek_gkd);
             my $resultaat  = as400_gegevens->lees_history_gkd($frame);
             my $dbh = sql_toegang_agresso->setup_mssql_connectie;
             sql_toegang_agresso->ubtstatistics_insert_row($dbh,$main::klant->{Agresso_nummer},$main::klant->{Ziekenfonds},$historiek_gkd);
             sql_toegang_agresso->disconnect_mssql($dbh);
            }
        }else {
         #niets doen
        }     
    }
sub GKD_chk_22_clicked {
     my ($frame, $evt) = @_;
     if ($evt->IsChecked()) {
         if ($main::gkd_commentaar->{22} != 1) {
             my $historiek_gkd = $frame->{GKD_txt_22}->GetValue();                
             as400_gegevens->zet_history_gkd_in ($historiek_gkd);
             my $resultaat  = as400_gegevens->lees_history_gkd($frame);
             my $dbh = sql_toegang_agresso->setup_mssql_connectie;
             sql_toegang_agresso->ubtstatistics_insert_row($dbh,$main::klant->{Agresso_nummer},$main::klant->{Ziekenfonds},$historiek_gkd);
             sql_toegang_agresso->disconnect_mssql($dbh);
            }
        }else {
         #niets doen
        }     
    }
sub GKD_chk_23_clicked {
     my ($frame, $evt) = @_;
     if ($evt->IsChecked()) {
         if ($main::gkd_commentaar->{23} != 1) {
             my $historiek_gkd = $frame->{GKD_txt_23}->GetValue();                
             as400_gegevens->zet_history_gkd_in ($historiek_gkd);
             my $resultaat  = as400_gegevens->lees_history_gkd($frame);
             my $dbh = sql_toegang_agresso->setup_mssql_connectie;
             sql_toegang_agresso->ubtstatistics_insert_row($dbh,$main::klant->{Agresso_nummer},$main::klant->{Ziekenfonds},$historiek_gkd);
             sql_toegang_agresso->disconnect_mssql($dbh);
            }
        }else {
         #niets doen
        }     
    }
sub set_values_gkd {
     my ($class,$frame);
     $frame->{GKD_chk_0}->SetValue($main::gkd_commentaar->{0});
     $frame->{GKD_chk_1}->SetValue($main::gkd_commentaar->{1});
     $frame->{GKD_chk_2}->SetValue($main::gkd_commentaar->{2});
     $frame->{GKD_chk_3}->SetValue($main::gkd_commentaar->{3});
     $frame->{GKD_chk_4}->SetValue($main::gkd_commentaar->{4});
     $frame->{GKD_chk_5}->SetValue($main::gkd_commentaar->{5});
     #aansluiting
     $frame->{GKD_chk_6}->SetValue($main::gkd_commentaar->{6} );
     $frame->{GKD_chk_7}->SetValue($main::gkd_commentaar->{7});
     $frame->{GKD_chk_8}->SetValue($main::gkd_commentaar->{8});
     $frame->{GKD_chk_9}->SetValue($main::gkd_commentaar->{9});
     $frame->{GKD_chk_10}->SetValue($main::gkd_commentaar->{10});
     #diverse
     $frame->{GKD_chk_11}->SetValue($main::gkd_commentaar->{11});
     $frame->{GKD_chk_12}->SetValue($main::gkd_commentaar->{12});
     $frame->{GKD_chk_13}->SetValue($main::gkd_commentaar->{13});
     
     $frame->{GKD_chk_14}->SetValue($main::gkd_commentaar->{14});
     $frame->{GKD_chk_15}->SetValue($main::gkd_commentaar->{15});
     $frame->{GKD_chk_16}->SetValue($main::gkd_commentaar->{16});
     
     $frame->{GKD_chk_17}->SetValue($main::gkd_commentaar->{17});
     $frame->{GKD_chk_18}->SetValue($main::gkd_commentaar->{18});
     $frame->{GKD_chk_19}->SetValue($main::gkd_commentaar->{19});
     
     $frame->{GKD_chk_20}->SetValue($main::gkd_commentaar->{20});
     $frame->{GKD_chk_21}->SetValue($main::gkd_commentaar->{21});
     $frame->{GKD_chk_22}->SetValue($main::gkd_commentaar->{22});
     $frame->{GKD_chk_23}->SetValue($main::gkd_commentaar->{23});
    }
1;