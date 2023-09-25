#!/usr/bin/perl -w
use strict;


package BestaandeAandoening_ErnstigeZiekte;
     use Wx qw[:everything];
     use base qw(Wx::Frame);
     #use Data::Dumper
     use strict;
     use Wx::Locale gettext => '_T';
     sub new {
         my ($class, $frame) = @_;
         $frame->{BA_EZ_sizer_1} = Wx::FlexGridSizer->new(4,14, 10, 10);
         # $frame->{lov_label_1}  = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1, _T("Agresso Nummer:"),wxDefaultPosition,wxSIZE(75,20));
         $frame->{BA_Button_Bestaande_Aandoening}  = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1, _T("Bestaande Aandoening"),wxDefaultPosition,wxSIZE(300,20));
         $frame->{BA_Button_BeginDatum}  = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1, _T("BeginDatum"),wxDefaultPosition,wxSIZE(75,20));
         $frame->{BA_Button_EindDatum}  = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1, _T("EindDatum"),wxDefaultPosition,wxSIZE(75,20));
         $frame->{BA_Button_Verzekering}  = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1, _T("Verzekering"),wxDefaultPosition,wxSIZE(125,20));
         $frame->{BA_Button_Bestaande_Aandoening_1}  = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1, _T("Bestaande Aandoening"),wxDefaultPosition,wxSIZE(300,20));
         $frame->{BA_Button_BeginDatum_1}  = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1, _T("BeginDatum"),wxDefaultPosition,wxSIZE(75,20));
         $frame->{BA_Button_EindDatum_1}  = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1, _T("EindDatum"),wxDefaultPosition,wxSIZE(75,20));
         $frame->{BA_Button_Verzekering_1}  = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1, _T("Verzekering"),wxDefaultPosition,wxSIZE(125,20));
         $frame->{BA_Button_Bestaande_Aandoening_2}  = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1, _T("Bestaande Aandoening"),wxDefaultPosition,wxSIZE(300,20));
         $frame->{BA_Button_BeginDatum_2}  = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1, _T("BeginDatum"),wxDefaultPosition,wxSIZE(75,20));
         $frame->{BA_Button_EindDatum_2}  = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1, _T("EindDatum"),wxDefaultPosition,wxSIZE(75,20));
         $frame->{BA_Button_Verzekering_2}  = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1, _T("Verzekering"),wxDefaultPosition,wxSIZE(125,20));
         #  $frame->{lov_label_4}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_lov}, -1,($main::klant->{naam}), wxDefaultPosition,wxSIZE(300,20));
         $frame->{BA_Txt_0_aandoening}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1, $main::klant->{aandoeningen}->[0]->{aandoening},wxDefaultPosition,wxSIZE(300,20));
         $frame->{BA_Txt_0_begindatum}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1, $main::klant->{aandoeningen}->[0]->{begindatum}, wxDefaultPosition,wxSIZE(75,20));
         $frame->{BA_Txt_0_einddatum}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1, $main::klant->{aandoeningen}->[0]->{einddatum}, wxDefaultPosition,wxSIZE(75,20));
         $frame->{BA_Txt_0_verzekering}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1, $main::klant->{aandoeningen}->[0]->{verzekering},wxDefaultPosition,wxSIZE(125,20));
         $frame->{BA_Txt_1_aandoening}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1, $main::klant->{aandoeningen}->[1]->{aandoening},wxDefaultPosition,wxSIZE(300,20));
         $frame->{BA_Txt_1_begindatum}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1, $main::klant->{aandoeningen}->[1]->{begindatum}, wxDefaultPosition,wxSIZE(75,20));
         $frame->{BA_Txt_1_einddatum}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1, $main::klant->{aandoeningen}->[1]->{einddatum}, wxDefaultPosition,wxSIZE(75,20));
         $frame->{BA_Txt_1_verzekering}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1, $main::klant->{aandoeningen}->[1]->{verzekering},wxDefaultPosition,wxSIZE(125,20));
         $frame->{BA_Txt_2_aandoening}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1, $main::klant->{aandoeningen}->[2]->{aandoening},wxDefaultPosition,wxSIZE(300,20));
         $frame->{BA_Txt_2_begindatum}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1, $main::klant->{aandoeningen}->[2]->{begindatum}, wxDefaultPosition,wxSIZE(75,20));
         $frame->{BA_Txt_2_einddatum}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1, $main::klant->{aandoeningen}->[2]->{einddatum}, wxDefaultPosition,wxSIZE(75,20));
         $frame->{BA_Txt_2_verzekering}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1, $main::klant->{aandoeningen}->[2]->{verzekering},wxDefaultPosition,wxSIZE(125,20));
         $frame->{BA_Txt_3_aandoening}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1, $main::klant->{aandoeningen}->[3]->{aandoening},wxDefaultPosition,wxSIZE(300,20));
         $frame->{BA_Txt_3_begindatum}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1, $main::klant->{aandoeningen}->[3]->{begindatum}, wxDefaultPosition,wxSIZE(75,20));
         $frame->{BA_Txt_3_einddatum}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1, $main::klant->{aandoeningen}->[3]->{einddatum}, wxDefaultPosition,wxSIZE(75,20));
         $frame->{BA_Txt_3_verzekering}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1, $main::klant->{aandoeningen}->[3]->{verzekering},wxDefaultPosition,wxSIZE(125,20));
         $frame->{BA_Txt_4_aandoening}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1, $main::klant->{aandoeningen}->[4]->{aandoening},wxDefaultPosition,wxSIZE(300,20));
         $frame->{BA_Txt_4_begindatum}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1, $main::klant->{aandoeningen}->[4]->{begindatum}, wxDefaultPosition,wxSIZE(75,20));
         $frame->{BA_Txt_4_einddatum}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1, $main::klant->{aandoeningen}->[4]->{einddatum}, wxDefaultPosition,wxSIZE(75,20));
         $frame->{BA_Txt_4_verzekering}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1, $main::klant->{aandoeningen}->[4]->{verzekering},wxDefaultPosition,wxSIZE(125,20));
         $frame->{BA_Txt_5_aandoening}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1, $main::klant->{aandoeningen}->[5]->{aandoening},wxDefaultPosition,wxSIZE(300,20));
         $frame->{BA_Txt_5_begindatum}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1, $main::klant->{aandoeningen}->[5]->{begindatum}, wxDefaultPosition,wxSIZE(75,20));
         $frame->{BA_Txt_5_einddatum}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1, $main::klant->{aandoeningen}->[5]->{einddatum}, wxDefaultPosition,wxSIZE(75,20));
         $frame->{BA_Txt_5_verzekering}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1, $main::klant->{aandoeningen}->[5]->{verzekering},wxDefaultPosition,wxSIZE(125,20));
         $frame->{BA_Txt_6_aandoening}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1, $main::klant->{aandoeningen}->[6]->{aandoening},wxDefaultPosition,wxSIZE(300,20));
         $frame->{BA_Txt_6_begindatum}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1, $main::klant->{aandoeningen}->[6]->{begindatum}, wxDefaultPosition,wxSIZE(75,20));
         $frame->{BA_Txt_6_einddatum}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1, $main::klant->{aandoeningen}->[6]->{einddatum}, wxDefaultPosition,wxSIZE(75,20));
         $frame->{BA_Txt_6_verzekering}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1, $main::klant->{aandoeningen}->[6]->{verzekering},wxDefaultPosition,wxSIZE(125,20));
         $frame->{BA_Txt_7_aandoening}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1, $main::klant->{aandoeningen}->[7]->{aandoening},wxDefaultPosition,wxSIZE(300,20));
         $frame->{BA_Txt_7_begindatum}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1, $main::klant->{aandoeningen}->[7]->{begindatum}, wxDefaultPosition,wxSIZE(75,20));
         $frame->{BA_Txt_7_einddatum}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1, $main::klant->{aandoeningen}->[7]->{einddatum}, wxDefaultPosition,wxSIZE(75,20));
         $frame->{BA_Txt_7_verzekering}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1, $main::klant->{aandoeningen}->[7]->{verzekering},wxDefaultPosition,wxSIZE(125,20));
         $frame->{BA_Txt_8_aandoening}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1, $main::klant->{aandoeningen}->[8]->{aandoening},wxDefaultPosition,wxSIZE(300,20));
         $frame->{BA_Txt_8_begindatum}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1, $main::klant->{aandoeningen}->[8]->{begindatum}, wxDefaultPosition,wxSIZE(75,20));
         $frame->{BA_Txt_8_einddatum}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1, $main::klant->{aandoeningen}->[8]->{einddatum}, wxDefaultPosition,wxSIZE(75,20));
         $frame->{BA_Txt_8_verzekering}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_BA_EZ}, -1, $main::klant->{aandoeningen}->[8]->{verzekering},wxDefaultPosition,wxSIZE(125,20));
         
          #BA_EZ  MainFrameNotebookBoven_pane_BA_EZ
         #Rij1
         #kolom 1 +2+3+4
         $frame->{BA_panel_1} = Wx::Panel->new($frame->{MainFrameNotebookBoven_pane_BA_EZ},-1,wxDefaultPosition,wxSIZE(15,20));
         #$frame->{BA_EZ_sizer_1}->Add($frame->{BA_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_Button_Bestaande_Aandoening}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_Button_BeginDatum}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);  
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_Button_EindDatum}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);  
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_Button_Verzekering}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);  
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_Button_Bestaande_Aandoening_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_Button_BeginDatum_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);  
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_Button_EindDatum_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);  
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_Button_Verzekering_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_Button_Bestaande_Aandoening_2}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_Button_BeginDatum_2}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);  
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_Button_EindDatum_2}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);  
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_Button_Verzekering_2}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         #Rij2
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_Txt_0_aandoening} , 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_Txt_0_begindatum} , 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);  
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_Txt_0_einddatum} , 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_Txt_0_verzekering} , 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_Txt_3_aandoening} , 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_Txt_3_begindatum} , 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);  
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_Txt_3_einddatum} , 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_Txt_3_verzekering} , 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_Txt_6_aandoening} , 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_Txt_6_begindatum} , 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);  
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_Txt_6_einddatum} , 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_Txt_6_verzekering} , 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         #rij3
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_Txt_1_aandoening} , 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_Txt_1_begindatum} , 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);  
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_Txt_1_einddatum} , 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_Txt_1_verzekering} , 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_Txt_4_aandoening} , 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_Txt_4_begindatum} , 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);  
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_Txt_4_einddatum} , 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_Txt_4_verzekering} , 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_Txt_7_aandoening} , 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_Txt_7_begindatum} , 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);  
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_Txt_7_einddatum} , 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_Txt_7_verzekering} , 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         #
         #rij4
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_Txt_2_aandoening} , 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_Txt_2_begindatum} , 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);  
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_Txt_2_einddatum} , 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_Txt_2_verzekering} , 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_Txt_5_aandoening} , 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_Txt_5_begindatum} , 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);  
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_Txt_5_einddatum} , 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_Txt_5_verzekering} , 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_Txt_8_aandoening} , 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_Txt_8_begindatum} , 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);  
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_Txt_8_einddatum} , 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         $frame->{BA_EZ_sizer_1}->Add($frame->{BA_Txt_8_verzekering} , 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
         #
        }
1;