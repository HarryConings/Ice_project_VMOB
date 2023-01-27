#!/usr/bin/perl -w
use strict;

package OpnameData;

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
      $frame->{OPD_sizer_1} = Wx::FlexGridSizer->new(4,32, 10, 10);
      $frame->{OPD_Button_Begin_Opname}  = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1, _T("Begin opname"),wxDefaultPosition,wxSIZE(75,20));
      $frame->{OPD_Button_Eind_Opname}  = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1, _T("Eind opname"),wxDefaultPosition,wxSIZE(75,20));      
      $frame->{OPD_Button_Begin_Opname_1}  = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1, _T("Begin opname"),wxDefaultPosition,wxSIZE(75,20));
      $frame->{OPD_Button_Eind_Opname_1}  = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1, _T("Eind opname"),wxDefaultPosition,wxSIZE(75,20));      
      $frame->{OPD_Button_Begin_Opname_2}  = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1, _T("Begin opname"),wxDefaultPosition,wxSIZE(75,20));
      $frame->{OPD_Button_Eind_Opname_2}  = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1, _T("Eind opname"),wxDefaultPosition,wxSIZE(75,20));   
      $frame->{OPD_Button_Begin_Opname_3}  = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1, _T("Begin opname"),wxDefaultPosition,wxSIZE(75,20));
      $frame->{OPD_Button_Eind_Opname_3}  = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1, _T("Eind opname"),wxDefaultPosition,wxSIZE(75,20));
      $frame->{OPD_Button_Begin_Opname_4}  = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1, _T("Begin opname"),wxDefaultPosition,wxSIZE(75,20));
      $frame->{OPD_Button_Eind_Opname_4}  = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1, _T("Eind opname"),wxDefaultPosition,wxSIZE(75,20));
      $frame->{OPD_Button_Begin_Opname_5}  = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1, _T("Begin opname"),wxDefaultPosition,wxSIZE(75,20));
      $frame->{OPD_Button_Eind_Opname_5}  = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1, _T("Eind opname"),wxDefaultPosition,wxSIZE(75,20));
      $frame->{OPD_Button_Begin_Opname_6}  = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1, _T("Begin opname"),wxDefaultPosition,wxSIZE(75,20));
      $frame->{OPD_Button_Eind_Opname_6}  = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1, _T("Eind opname"),wxDefaultPosition,wxSIZE(75,20));
      $frame->{OPD_Button_Begin_Opname_7}  = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1, _T("Begin opname"),wxDefaultPosition,wxSIZE(75,20));
      $frame->{OPD_Button_Eind_Opname_7}  = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1, _T("Eind opname"),wxDefaultPosition,wxSIZE(75,20));    
      #kolom 1
      $frame->{OPD_Txt_0_Begin_Opname}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1, $main::klant->{opnames}->[0]->{begindatum},wxDefaultPosition,wxSIZE(75,20));
      $frame->{OPD_Txt_0_Eind_Opname}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1, $main::klant->{opnames}->[0]->{einddatum},wxDefaultPosition,wxSIZE(75,20));
      $frame->{OPD_chk_0_Begin_Opname}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1,$main::klant->{opnames}->[0]->{begin_select},wxDefaultPosition,wxSIZE(15,20));
      $frame->{OPD_chk_0_Eind_Opname}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1,$main::klant->{opnames}->[0]->{eind_select},wxDefaultPosition,wxSIZE(15,20));
      $frame->{OPD_Txt_1_Begin_Opname}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1, $main::klant->{opnames}->[1]->{begindatum},wxDefaultPosition,wxSIZE(75,20));
      $frame->{OPD_Txt_1_Eind_Opname}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1, $main::klant->{opnames}->[1]->{einddatum},wxDefaultPosition,wxSIZE(75,20));
      $frame->{OPD_chk_1_Begin_Opname}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1,$main::klant->{opnames}->[1]->{begin_select},wxDefaultPosition,wxSIZE(15,20));
      $frame->{OPD_chk_1_Eind_Opname}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1,$main::klant->{opnames}->[1]->{eind_select},wxDefaultPosition,wxSIZE(15,20));
      $frame->{OPD_Txt_2_Begin_Opname}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1, $main::klant->{opnames}->[2]->{begindatum},wxDefaultPosition,wxSIZE(75,20));
      $frame->{OPD_Txt_2_Eind_Opname}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1, $main::klant->{opnames}->[2]->{einddatum},wxDefaultPosition,wxSIZE(75,20));
      $frame->{OPD_chk_2_Begin_Opname}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1,$main::klant->{opnames}->[2]->{begin_select},wxDefaultPosition,wxSIZE(15,20));
      $frame->{OPD_chk_2_Eind_Opname}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1,$main::klant->{opnames}->[2]->{eind_select},wxDefaultPosition,wxSIZE(15,20));
      #kolom2
      $frame->{OPD_Txt_3_Begin_Opname}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1, $main::klant->{opnames}->[3]->{begindatum},wxDefaultPosition,wxSIZE(75,20));
      $frame->{OPD_Txt_3_Eind_Opname}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1, $main::klant->{opnames}->[3]->{einddatum},wxDefaultPosition,wxSIZE(75,20));
      $frame->{OPD_chk_3_Begin_Opname}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1,$main::klant->{opnames}->[3]->{begin_select},wxDefaultPosition,wxSIZE(15,20));
      $frame->{OPD_chk_3_Eind_Opname}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1,$main::klant->{opnames}->[3]->{eind_select},wxDefaultPosition,wxSIZE(15,20));
      $frame->{OPD_Txt_4_Begin_Opname}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1, $main::klant->{opnames}->[4]->{begindatum},wxDefaultPosition,wxSIZE(75,20));
      $frame->{OPD_Txt_4_Eind_Opname}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1, $main::klant->{opnames}->[4]->{einddatum},wxDefaultPosition,wxSIZE(75,20));
      $frame->{OPD_chk_4_Begin_Opname}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1,$main::klant->{opnames}->[4]->{begin_select},wxDefaultPosition,wxSIZE(15,20));
      $frame->{OPD_chk_4_Eind_Opname}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1,$main::klant->{opnames}->[4]->{eind_select},wxDefaultPosition,wxSIZE(15,20));
      $frame->{OPD_Txt_5_Begin_Opname}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1, $main::klant->{opnames}->[5]->{begindatum},wxDefaultPosition,wxSIZE(75,20));
      $frame->{OPD_Txt_5_Eind_Opname}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1, $main::klant->{opnames}->[5]->{einddatum},wxDefaultPosition,wxSIZE(75,20));
      $frame->{OPD_chk_5_Begin_Opname}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1,$main::klant->{opnames}->[5]->{begin_select},wxDefaultPosition,wxSIZE(15,20));
      $frame->{OPD_chk_5_Eind_Opname}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1,$main::klant->{opnames}->[5]->{eind_select},wxDefaultPosition,wxSIZE(15,20));
      #kolom 3      
      $frame->{OPD_Txt_6_Begin_Opname}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1, $main::klant->{opnames}->[6]->{begindatum},wxDefaultPosition,wxSIZE(75,20));
      $frame->{OPD_Txt_6_Eind_Opname}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1, $main::klant->{opnames}->[6]->{einddatum},wxDefaultPosition,wxSIZE(75,20));
      $frame->{OPD_chk_6_Begin_Opname}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1,$main::klant->{opnames}->[6]->{begin_select},wxDefaultPosition,wxSIZE(15,20));
      $frame->{OPD_chk_6_Eind_Opname}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1,$main::klant->{opnames}->[6]->{eind_select},wxDefaultPosition,wxSIZE(15,20));
      $frame->{OPD_Txt_7_Begin_Opname}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1, $main::klant->{opnames}->[7]->{begindatum},wxDefaultPosition,wxSIZE(75,20));
      $frame->{OPD_Txt_7_Eind_Opname}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1, $main::klant->{opnames}->[7]->{einddatum},wxDefaultPosition,wxSIZE(75,20));
      $frame->{OPD_chk_7_Begin_Opname}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1,$main::klant->{opnames}->[7]->{begin_select},wxDefaultPosition,wxSIZE(15,20));
      $frame->{OPD_chk_7_Eind_Opname}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1,$main::klant->{opnames}->[7]->{eind_select},wxDefaultPosition,wxSIZE(15,20));
      $frame->{OPD_Txt_8_Begin_Opname}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1, $main::klant->{opnames}->[8]->{begindatum},wxDefaultPosition,wxSIZE(75,20));
      $frame->{OPD_Txt_8_Eind_Opname}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1, $main::klant->{opnames}->[8]->{einddatum},wxDefaultPosition,wxSIZE(75,20));
      $frame->{OPD_chk_8_Begin_Opname}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1,$main::klant->{opnames}->[8]->{begin_select},wxDefaultPosition,wxSIZE(15,20));
      $frame->{OPD_chk_8_Eind_Opname}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1,$main::klant->{opnames}->[8]->{eind_select},wxDefaultPosition,wxSIZE(15,20));
      #kolom 4
      $frame->{OPD_Txt_9_Begin_Opname}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1, $main::klant->{opnames}->[9]->{begindatum},wxDefaultPosition,wxSIZE(75,20));
      $frame->{OPD_Txt_9_Eind_Opname}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1, $main::klant->{opnames}->[9]->{einddatum},wxDefaultPosition,wxSIZE(75,20));
      $frame->{OPD_chk_9_Begin_Opname}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1,$main::klant->{opnames}->[9]->{begin_select},wxDefaultPosition,wxSIZE(15,20));
      $frame->{OPD_chk_9_Eind_Opname}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1,$main::klant->{opnames}->[9]->{eind_select},wxDefaultPosition,wxSIZE(15,20));
      $frame->{OPD_Txt_10_Begin_Opname}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1, $main::klant->{opnames}->[10]->{begindatum},wxDefaultPosition,wxSIZE(75,20));
      $frame->{OPD_Txt_10_Eind_Opname}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1, $main::klant->{opnames}->[10]->{einddatum},wxDefaultPosition,wxSIZE(75,20));
      $frame->{OPD_chk_10_Begin_Opname}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1,$main::klant->{opnames}->[10]->{begin_select},wxDefaultPosition,wxSIZE(15,20));
      $frame->{OPD_chk_10_Eind_Opname}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1,$main::klant->{opnames}->[10]->{eind_select},wxDefaultPosition,wxSIZE(15,20));
      $frame->{OPD_Txt_11_Begin_Opname}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1, $main::klant->{opnames}->[11]->{begindatum},wxDefaultPosition,wxSIZE(75,20));
      $frame->{OPD_Txt_11_Eind_Opname}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1, $main::klant->{opnames}->[11]->{einddatum},wxDefaultPosition,wxSIZE(75,20));
      $frame->{OPD_chk_11_Begin_Opname}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1,$main::klant->{opnames}->[11]->{begin_select},wxDefaultPosition,wxSIZE(15,20));
      $frame->{OPD_chk_11_Eind_Opname}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1,$main::klant->{opnames}->[11]->{eind_select},wxDefaultPosition,wxSIZE(15,20));
      #kolom 5
      $frame->{OPD_Txt_12_Begin_Opname}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1, $main::klant->{opnames}->[12]->{begindatum},wxDefaultPosition,wxSIZE(75,20));
      $frame->{OPD_Txt_12_Eind_Opname}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1, $main::klant->{opnames}->[12]->{einddatum},wxDefaultPosition,wxSIZE(75,20));
      $frame->{OPD_chk_12_Begin_Opname}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1,$main::klant->{opnames}->[12]->{begin_select},wxDefaultPosition,wxSIZE(15,20));
      $frame->{OPD_chk_12_Eind_Opname}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1,$main::klant->{opnames}->[12]->{eind_select},wxDefaultPosition,wxSIZE(15,20));
      $frame->{OPD_Txt_13_Begin_Opname}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1, $main::klant->{opnames}->[13]->{begindatum},wxDefaultPosition,wxSIZE(75,20));
      $frame->{OPD_Txt_13_Eind_Opname}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1, $main::klant->{opnames}->[13]->{einddatum},wxDefaultPosition,wxSIZE(75,20));
      $frame->{OPD_chk_13_Begin_Opname}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1,$main::klant->{opnames}->[13]->{begin_select},wxDefaultPosition,wxSIZE(15,20));
      $frame->{OPD_chk_13_Eind_Opname}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1,$main::klant->{opnames}->[13]->{eind_select},wxDefaultPosition,wxSIZE(15,20));
      $frame->{OPD_Txt_14_Begin_Opname}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1, $main::klant->{opnames}->[14]->{begindatum},wxDefaultPosition,wxSIZE(75,20));
      $frame->{OPD_Txt_14_Eind_Opname}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1, $main::klant->{opnames}->[14]->{einddatum},wxDefaultPosition,wxSIZE(75,20));
      $frame->{OPD_chk_14_Begin_Opname}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1,$main::klant->{opnames}->[14]->{begin_select},wxDefaultPosition,wxSIZE(15,20));
      $frame->{OPD_chk_14_Eind_Opname}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1,$main::klant->{opnames}->[14]->{eind_select},wxDefaultPosition,wxSIZE(15,20));
      #kolom 6
      $frame->{OPD_Txt_15_Begin_Opname}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1, $main::klant->{opnames}->[15]->{begindatum},wxDefaultPosition,wxSIZE(75,20));
      $frame->{OPD_Txt_15_Eind_Opname}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1, $main::klant->{opnames}->[15]->{einddatum},wxDefaultPosition,wxSIZE(75,20));
      $frame->{OPD_chk_15_Begin_Opname}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1,$main::klant->{opnames}->[15]->{begin_select},wxDefaultPosition,wxSIZE(15,20));
      $frame->{OPD_chk_15_Eind_Opname}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1,$main::klant->{opnames}->[15]->{eind_select},wxDefaultPosition,wxSIZE(15,20));
      $frame->{OPD_Txt_16_Begin_Opname}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1, $main::klant->{opnames}->[16]->{begindatum},wxDefaultPosition,wxSIZE(75,20));
      $frame->{OPD_Txt_16_Eind_Opname}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1, $main::klant->{opnames}->[16]->{einddatum},wxDefaultPosition,wxSIZE(75,20));
      $frame->{OPD_chk_16_Begin_Opname}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1,$main::klant->{opnames}->[16]->{begin_select},wxDefaultPosition,wxSIZE(15,20));
      $frame->{OPD_chk_16_Eind_Opname}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1,$main::klant->{opnames}->[16]->{eind_select},wxDefaultPosition,wxSIZE(15,20));
      $frame->{OPD_Txt_17_Begin_Opname}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1, $main::klant->{opnames}->[17]->{begindatum},wxDefaultPosition,wxSIZE(75,20));
      $frame->{OPD_Txt_17_Eind_Opname}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1, $main::klant->{opnames}->[17]->{einddatum},wxDefaultPosition,wxSIZE(75,20));
      $frame->{OPD_chk_17_Begin_Opname}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1,$main::klant->{opnames}->[17]->{begin_select},wxDefaultPosition,wxSIZE(15,20));
      $frame->{OPD_chk_17_Eind_Opname}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1,$main::klant->{opnames}->[17]->{eind_select},wxDefaultPosition,wxSIZE(15,20));
      #kolom 7
      $frame->{OPD_Txt_18_Begin_Opname}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1, $main::klant->{opnames}->[18]->{begindatum},wxDefaultPosition,wxSIZE(75,20));
      $frame->{OPD_Txt_18_Eind_Opname}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1, $main::klant->{opnames}->[18]->{einddatum},wxDefaultPosition,wxSIZE(75,20));
      $frame->{OPD_chk_18_Begin_Opname}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1,$main::klant->{opnames}->[18]->{begin_select},wxDefaultPosition,wxSIZE(15,20));
      $frame->{OPD_chk_18_Eind_Opname}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1,$main::klant->{opnames}->[18]->{eind_select},wxDefaultPosition,wxSIZE(15,20));
      $frame->{OPD_Txt_19_Begin_Opname}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1, $main::klant->{opnames}->[19]->{begindatum},wxDefaultPosition,wxSIZE(75,20));
      $frame->{OPD_Txt_19_Eind_Opname}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1, $main::klant->{opnames}->[19]->{einddatum},wxDefaultPosition,wxSIZE(75,20));
      $frame->{OPD_chk_19_Begin_Opname}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1,$main::klant->{opnames}->[19]->{begin_select},wxDefaultPosition,wxSIZE(15,20));
      $frame->{OPD_chk_19_Eind_Opname}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1,$main::klant->{opnames}->[19]->{eind_select},wxDefaultPosition,wxSIZE(15,20));
      $frame->{OPD_Txt_20_Begin_Opname}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1, $main::klant->{opnames}->[20]->{begindatum},wxDefaultPosition,wxSIZE(75,20));
      $frame->{OPD_Txt_20_Eind_Opname}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1, $main::klant->{opnames}->[20]->{einddatum},wxDefaultPosition,wxSIZE(75,20));
      $frame->{OPD_chk_20_Begin_Opname}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1,$main::klant->{opnames}->[20]->{begin_select},wxDefaultPosition,wxSIZE(15,20));
      $frame->{OPD_chk_20_Eind_Opname}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1,$main::klant->{opnames}->[20]->{eind_select},wxDefaultPosition,wxSIZE(15,20));
      #kolom 8
      $frame->{OPD_Txt_21_Begin_Opname}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1, $main::klant->{opnames}->[21]->{begindatum},wxDefaultPosition,wxSIZE(75,20));
      $frame->{OPD_Txt_21_Eind_Opname}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1, $main::klant->{opnames}->[21]->{einddatum},wxDefaultPosition,wxSIZE(75,20));
      $frame->{OPD_chk_21_Begin_Opname}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1,$main::klant->{opnames}->[21]->{begin_select},wxDefaultPosition,wxSIZE(15,20));
      $frame->{OPD_chk_21_Eind_Opname}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1,$main::klant->{opnames}->[21]->{eind_select},wxDefaultPosition,wxSIZE(15,20));
      $frame->{OPD_Txt_22_Begin_Opname}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1, $main::klant->{opnames}->[22]->{begindatum},wxDefaultPosition,wxSIZE(75,20));
      $frame->{OPD_Txt_22_Eind_Opname}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1, $main::klant->{opnames}->[22]->{einddatum},wxDefaultPosition,wxSIZE(75,20));
      $frame->{OPD_chk_22_Begin_Opname}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1,$main::klant->{opnames}->[22]->{begin_select},wxDefaultPosition,wxSIZE(15,20));
      $frame->{OPD_chk_22_Eind_Opname}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1,$main::klant->{opnames}->[22]->{eind_select},wxDefaultPosition,wxSIZE(15,20));
      $frame->{OPD_Txt_23_Begin_Opname}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1, $main::klant->{opnames}->[23]->{begindatum},wxDefaultPosition,wxSIZE(75,20));
      $frame->{OPD_Txt_23_Eind_Opname}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1, $main::klant->{opnames}->[23]->{einddatum},wxDefaultPosition,wxSIZE(75,20));
      $frame->{OPD_chk_23_Begin_Opname}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1,$main::klant->{opnames}->[23]->{begin_select},wxDefaultPosition,wxSIZE(15,20));
      $frame->{OPD_chk_23_Eind_Opname}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_OPD}, -1,$main::klant->{opnames}->[23]->{eind_select},wxDefaultPosition,wxSIZE(15,20));
     
     $frame->{OPD_panel_2} = Wx::Panel->new($frame->{MainFrameNotebookBoven_pane_OPD},-1,wxDefaultPosition,wxSIZE(15,20));
     $frame->{OPD_panel_1} = Wx::Panel->new($frame->{MainFrameNotebookBoven_pane_OPD},-1,wxDefaultPosition,wxSIZE(15,20));
     #RIJ1
     #kolom 1  (1+2+3+4)
     $frame->{OPD_sizer_1}->Add($frame->{OPD_panel_2}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{OPD_sizer_1}->Add($frame->{OPD_Button_Begin_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{OPD_sizer_1}->Add($frame->{OPD_Button_Eind_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{OPD_sizer_1}->Add($frame->{OPD_panel_2}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     #RIJ1
     #kolom 2  (5+6+7+8)
     $frame->{OPD_sizer_1}->Add($frame->{OPD_panel_2}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{OPD_sizer_1}->Add($frame->{OPD_Button_Begin_Opname_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{OPD_sizer_1}->Add($frame->{OPD_Button_Eind_Opname_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{OPD_sizer_1}->Add($frame->{OPD_panel_2}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     #RIJ1
     #kolom 3  (9+10+11+12}
     $frame->{OPD_sizer_1}->Add($frame->{OPD_panel_2}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{OPD_sizer_1}->Add($frame->{OPD_Button_Begin_Opname_2}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{OPD_sizer_1}->Add($frame->{OPD_Button_Eind_Opname_2}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{OPD_sizer_1}->Add($frame->{OPD_panel_2}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     #RIJ1
     #kolom 4  (13+14+15+16)
     $frame->{OPD_sizer_1}->Add($frame->{OPD_panel_2}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{OPD_sizer_1}->Add($frame->{OPD_Button_Begin_Opname_3}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{OPD_sizer_1}->Add($frame->{OPD_Button_Eind_Opname_3}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{OPD_sizer_1}->Add($frame->{OPD_panel_2}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     #RIJ1
     #kolom 5  (17+18+19+20)
     $frame->{OPD_sizer_1}->Add($frame->{OPD_panel_2}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{OPD_sizer_1}->Add($frame->{OPD_Button_Begin_Opname_4}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{OPD_sizer_1}->Add($frame->{OPD_Button_Eind_Opname_4}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{OPD_sizer_1}->Add($frame->{OPD_panel_2}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     #RIJ1
     #kolom 6  (21+22+23+24)
     $frame->{OPD_sizer_1}->Add($frame->{OPD_panel_2}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{OPD_sizer_1}->Add($frame->{OPD_Button_Begin_Opname_5}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{OPD_sizer_1}->Add($frame->{OPD_Button_Eind_Opname_5}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{OPD_sizer_1}->Add($frame->{OPD_panel_2}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     #RIJ1
     #kolom 7 (25+26+27+28)
     $frame->{OPD_sizer_1}->Add($frame->{OPD_panel_2}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{OPD_sizer_1}->Add($frame->{OPD_Button_Begin_Opname_6}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{OPD_sizer_1}->Add($frame->{OPD_Button_Eind_Opname_6}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{OPD_sizer_1}->Add($frame->{OPD_panel_2}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     #RIJ1
     #kolom 8 (27+28+29+30)
     $frame->{OPD_sizer_1}->Add($frame->{OPD_panel_2}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{OPD_sizer_1}->Add($frame->{OPD_Button_Begin_Opname_7}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{OPD_sizer_1}->Add($frame->{OPD_Button_Eind_Opname_7}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{OPD_sizer_1}->Add($frame->{OPD_panel_2}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     #RIJ2
     #kolom 1 (1+2+3+4)
     $frame->{OPD_sizer_1}->Add($frame->{OPD_chk_0_Begin_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{OPD_sizer_1}->Add($frame->{OPD_Txt_0_Begin_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{OPD_sizer_1}->Add($frame->{OPD_Txt_0_Eind_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{OPD_sizer_1}->Add($frame->{OPD_chk_0_Eind_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     #RIJ2
     #kolom 2 (5+6+7+8)
     $frame->{OPD_sizer_1}->Add($frame->{OPD_chk_1_Begin_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{OPD_sizer_1}->Add($frame->{OPD_Txt_1_Begin_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{OPD_sizer_1}->Add($frame->{OPD_Txt_1_Eind_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{OPD_sizer_1}->Add($frame->{OPD_chk_1_Eind_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     #RIJ2
     #kolom 3 (9+10+11+12)
     $frame->{OPD_sizer_1}->Add($frame->{OPD_chk_2_Begin_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{OPD_sizer_1}->Add($frame->{OPD_Txt_2_Begin_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{OPD_sizer_1}->Add($frame->{OPD_Txt_2_Eind_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{OPD_sizer_1}->Add($frame->{OPD_chk_2_Eind_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     #RIJ2
     #kolom 4 (13+14+15+16)
     $frame->{OPD_sizer_1}->Add($frame->{OPD_chk_3_Begin_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{OPD_sizer_1}->Add($frame->{OPD_Txt_3_Begin_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{OPD_sizer_1}->Add($frame->{OPD_Txt_3_Eind_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{OPD_sizer_1}->Add($frame->{OPD_chk_3_Eind_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     #RIJ2
     #kolom 5 (17+18+19+20)
     $frame->{OPD_sizer_1}->Add($frame->{OPD_chk_4_Begin_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{OPD_sizer_1}->Add($frame->{OPD_Txt_4_Begin_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{OPD_sizer_1}->Add($frame->{OPD_Txt_4_Eind_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{OPD_sizer_1}->Add($frame->{OPD_chk_4_Eind_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     #RIJ2
     #kolom 6 (21+22+23+24)
     $frame->{OPD_sizer_1}->Add($frame->{OPD_chk_5_Begin_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{OPD_sizer_1}->Add($frame->{OPD_Txt_5_Begin_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{OPD_sizer_1}->Add($frame->{OPD_Txt_5_Eind_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{OPD_sizer_1}->Add($frame->{OPD_chk_5_Eind_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     #RIJ2
     #kolom 7 (25+26+27+28)
     $frame->{OPD_sizer_1}->Add($frame->{OPD_chk_6_Begin_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{OPD_sizer_1}->Add($frame->{OPD_Txt_6_Begin_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{OPD_sizer_1}->Add($frame->{OPD_Txt_6_Eind_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{OPD_sizer_1}->Add($frame->{OPD_chk_6_Eind_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     #RIJ2
     #kolom 8 (29+30+31+32
     $frame->{OPD_sizer_1}->Add($frame->{OPD_chk_7_Begin_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{OPD_sizer_1}->Add($frame->{OPD_Txt_7_Begin_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{OPD_sizer_1}->Add($frame->{OPD_Txt_7_Eind_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{OPD_sizer_1}->Add($frame->{OPD_chk_7_Eind_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     
     #RIJ3
     #kolom 1 (1+2+3+4)
     $frame->{OPD_sizer_1}->Add($frame->{OPD_chk_8_Begin_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{OPD_sizer_1}->Add($frame->{OPD_Txt_8_Begin_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{OPD_sizer_1}->Add($frame->{OPD_Txt_8_Eind_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{OPD_sizer_1}->Add($frame->{OPD_chk_8_Eind_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     #RIJ3
     #kolom 2 (5+6+7+8)
     $frame->{OPD_sizer_1}->Add($frame->{OPD_chk_9_Begin_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{OPD_sizer_1}->Add($frame->{OPD_Txt_9_Begin_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{OPD_sizer_1}->Add($frame->{OPD_Txt_9_Eind_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{OPD_sizer_1}->Add($frame->{OPD_chk_9_Eind_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     #RIJ3
     #kolom 3 (9+10+11+12)
     $frame->{OPD_sizer_1}->Add($frame->{OPD_chk_10_Begin_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{OPD_sizer_1}->Add($frame->{OPD_Txt_10_Begin_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{OPD_sizer_1}->Add($frame->{OPD_Txt_10_Eind_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{OPD_sizer_1}->Add($frame->{OPD_chk_10_Eind_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     #RIJ3
     #kolom 4 (13+14+15+16)
     $frame->{OPD_sizer_1}->Add($frame->{OPD_chk_11_Begin_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{OPD_sizer_1}->Add($frame->{OPD_Txt_11_Begin_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{OPD_sizer_1}->Add($frame->{OPD_Txt_11_Eind_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{OPD_sizer_1}->Add($frame->{OPD_chk_11_Eind_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     #RIJ3
     #kolom 5 (17+18+19+20)
     $frame->{OPD_sizer_1}->Add($frame->{OPD_chk_12_Begin_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{OPD_sizer_1}->Add($frame->{OPD_Txt_12_Begin_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{OPD_sizer_1}->Add($frame->{OPD_Txt_12_Eind_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{OPD_sizer_1}->Add($frame->{OPD_chk_12_Eind_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     #RIJ3
     #kolom 6 (21+22+23+24)
     $frame->{OPD_sizer_1}->Add($frame->{OPD_chk_13_Begin_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{OPD_sizer_1}->Add($frame->{OPD_Txt_13_Begin_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{OPD_sizer_1}->Add($frame->{OPD_Txt_13_Eind_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{OPD_sizer_1}->Add($frame->{OPD_chk_13_Eind_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     #RIJ3
     #kolom 7 (25+26+27+28)
     $frame->{OPD_sizer_1}->Add($frame->{OPD_chk_14_Begin_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{OPD_sizer_1}->Add($frame->{OPD_Txt_14_Begin_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{OPD_sizer_1}->Add($frame->{OPD_Txt_14_Eind_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{OPD_sizer_1}->Add($frame->{OPD_chk_14_Eind_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     #RIJ3
     #kolom 8 (29+30+31+32)
     $frame->{OPD_sizer_1}->Add($frame->{OPD_chk_15_Begin_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{OPD_sizer_1}->Add($frame->{OPD_Txt_15_Begin_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{OPD_sizer_1}->Add($frame->{OPD_Txt_15_Eind_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{OPD_sizer_1}->Add($frame->{OPD_chk_15_Eind_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
       
     #RIJ4
     #kolom 1 (1+2+3+4)
     $frame->{OPD_sizer_1}->Add($frame->{OPD_chk_16_Begin_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{OPD_sizer_1}->Add($frame->{OPD_Txt_16_Begin_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{OPD_sizer_1}->Add($frame->{OPD_Txt_16_Eind_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{OPD_sizer_1}->Add($frame->{OPD_chk_16_Eind_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     #RIJ4
     #kolom 2 (5+6+7+8)
     $frame->{OPD_sizer_1}->Add($frame->{OPD_chk_17_Begin_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{OPD_sizer_1}->Add($frame->{OPD_Txt_17_Begin_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{OPD_sizer_1}->Add($frame->{OPD_Txt_17_Eind_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{OPD_sizer_1}->Add($frame->{OPD_chk_17_Eind_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     #RIJ4
     #kolom 3 (9+10+11+12)
     $frame->{OPD_sizer_1}->Add($frame->{OPD_chk_18_Begin_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{OPD_sizer_1}->Add($frame->{OPD_Txt_18_Begin_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{OPD_sizer_1}->Add($frame->{OPD_Txt_18_Eind_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{OPD_sizer_1}->Add($frame->{OPD_chk_18_Eind_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     #RIJ4
     #kolom 4 (13+14+15+16)
     $frame->{OPD_sizer_1}->Add($frame->{OPD_chk_19_Begin_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{OPD_sizer_1}->Add($frame->{OPD_Txt_19_Begin_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{OPD_sizer_1}->Add($frame->{OPD_Txt_19_Eind_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{OPD_sizer_1}->Add($frame->{OPD_chk_19_Eind_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     #RIJ4
     #kolom 5 (17+18+19+20)
     $frame->{OPD_sizer_1}->Add($frame->{OPD_chk_20_Begin_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{OPD_sizer_1}->Add($frame->{OPD_Txt_20_Begin_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{OPD_sizer_1}->Add($frame->{OPD_Txt_20_Eind_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{OPD_sizer_1}->Add($frame->{OPD_chk_20_Eind_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     #RIJ4
     #kolom 6 (21+22+23+24)
     $frame->{OPD_sizer_1}->Add($frame->{OPD_chk_21_Begin_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{OPD_sizer_1}->Add($frame->{OPD_Txt_21_Begin_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{OPD_sizer_1}->Add($frame->{OPD_Txt_21_Eind_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{OPD_sizer_1}->Add($frame->{OPD_chk_21_Eind_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     #RIJ4
     #kolom 7 (25+26+27+28)
     $frame->{OPD_sizer_1}->Add($frame->{OPD_chk_22_Begin_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{OPD_sizer_1}->Add($frame->{OPD_Txt_22_Begin_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{OPD_sizer_1}->Add($frame->{OPD_Txt_22_Eind_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{OPD_sizer_1}->Add($frame->{OPD_chk_22_Eind_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     #RIJ4
     #kolom 8 (29+30+31+32)
     $frame->{OPD_sizer_1}->Add($frame->{OPD_chk_23_Begin_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{OPD_sizer_1}->Add($frame->{OPD_Txt_23_Begin_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{OPD_sizer_1}->Add($frame->{OPD_Txt_23_Eind_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{OPD_sizer_1}->Add($frame->{OPD_chk_23_Eind_Opname}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     
     
     #Wx::Event::EVT_CHECKBOX ($frame,$frame->{OPD_chk_0_Begin_Opname},\&checkbox_Begin_clicked($frame,0));
     Wx::Event::EVT_CHECKBOX($frame,$frame->{OPD_chk_0_Begin_Opname}, \&checkbox_0_Begin_clicked);
     Wx::Event::EVT_CHECKBOX($frame,$frame->{OPD_chk_1_Begin_Opname}, \&checkbox_1_Begin_clicked);
     Wx::Event::EVT_CHECKBOX($frame,$frame->{OPD_chk_2_Begin_Opname}, \&checkbox_2_Begin_clicked);
     Wx::Event::EVT_CHECKBOX($frame,$frame->{OPD_chk_3_Begin_Opname}, \&checkbox_3_Begin_clicked);
     Wx::Event::EVT_CHECKBOX($frame,$frame->{OPD_chk_4_Begin_Opname}, \&checkbox_4_Begin_clicked);
     Wx::Event::EVT_CHECKBOX($frame,$frame->{OPD_chk_5_Begin_Opname}, \&checkbox_5_Begin_clicked);
     Wx::Event::EVT_CHECKBOX($frame,$frame->{OPD_chk_6_Begin_Opname}, \&checkbox_6_Begin_clicked);
     Wx::Event::EVT_CHECKBOX($frame,$frame->{OPD_chk_7_Begin_Opname}, \&checkbox_7_Begin_clicked);
     Wx::Event::EVT_CHECKBOX($frame,$frame->{OPD_chk_8_Begin_Opname}, \&checkbox_8_Begin_clicked);
     Wx::Event::EVT_CHECKBOX($frame,$frame->{OPD_chk_9_Begin_Opname}, \&checkbox_9_Begin_clicked);
     Wx::Event::EVT_CHECKBOX($frame,$frame->{OPD_chk_10_Begin_Opname}, \&checkbox_10_Begin_clicked);
     Wx::Event::EVT_CHECKBOX($frame,$frame->{OPD_chk_11_Begin_Opname}, \&checkbox_11_Begin_clicked);
     Wx::Event::EVT_CHECKBOX($frame,$frame->{OPD_chk_12_Begin_Opname}, \&checkbox_12_Begin_clicked);
     Wx::Event::EVT_CHECKBOX($frame,$frame->{OPD_chk_13_Begin_Opname}, \&checkbox_13_Begin_clicked);
     Wx::Event::EVT_CHECKBOX($frame,$frame->{OPD_chk_14_Begin_Opname}, \&checkbox_14_Begin_clicked);
     Wx::Event::EVT_CHECKBOX($frame,$frame->{OPD_chk_15_Begin_Opname}, \&checkbox_15_Begin_clicked);
     Wx::Event::EVT_CHECKBOX($frame,$frame->{OPD_chk_16_Begin_Opname}, \&checkbox_16_Begin_clicked);
     Wx::Event::EVT_CHECKBOX($frame,$frame->{OPD_chk_17_Begin_Opname}, \&checkbox_17_Begin_clicked);
     Wx::Event::EVT_CHECKBOX($frame,$frame->{OPD_chk_18_Begin_Opname}, \&checkbox_18_Begin_clicked);
     Wx::Event::EVT_CHECKBOX($frame,$frame->{OPD_chk_19_Begin_Opname}, \&checkbox_19_Begin_clicked);
     Wx::Event::EVT_CHECKBOX($frame,$frame->{OPD_chk_20_Begin_Opname}, \&checkbox_20_Begin_clicked);
     Wx::Event::EVT_CHECKBOX($frame,$frame->{OPD_chk_21_Begin_Opname}, \&checkbox_21_Begin_clicked);
     Wx::Event::EVT_CHECKBOX($frame,$frame->{OPD_chk_22_Begin_Opname}, \&checkbox_22_Begin_clicked);
     Wx::Event::EVT_CHECKBOX($frame,$frame->{OPD_chk_23_Begin_Opname}, \&checkbox_23_Begin_clicked);
     
      #Wx::Event::EVT_CHECKBOX ($frame,$frame->{OPD_chk_0_Eind_Opname},\&checkbox_Eind_clicked($frame,0));
     Wx::Event::EVT_CHECKBOX($frame,$frame->{OPD_chk_0_Eind_Opname}, \&checkbox_0_Eind_clicked);
     Wx::Event::EVT_CHECKBOX($frame,$frame->{OPD_chk_1_Eind_Opname}, \&checkbox_1_Eind_clicked);
     Wx::Event::EVT_CHECKBOX($frame,$frame->{OPD_chk_2_Eind_Opname}, \&checkbox_2_Eind_clicked);
     Wx::Event::EVT_CHECKBOX($frame,$frame->{OPD_chk_3_Eind_Opname}, \&checkbox_3_Eind_clicked);
     Wx::Event::EVT_CHECKBOX($frame,$frame->{OPD_chk_4_Eind_Opname}, \&checkbox_4_Eind_clicked);
     Wx::Event::EVT_CHECKBOX($frame,$frame->{OPD_chk_5_Eind_Opname}, \&checkbox_5_Eind_clicked);
     Wx::Event::EVT_CHECKBOX($frame,$frame->{OPD_chk_6_Eind_Opname}, \&checkbox_6_Eind_clicked);
     Wx::Event::EVT_CHECKBOX($frame,$frame->{OPD_chk_7_Eind_Opname}, \&checkbox_7_Eind_clicked);
     Wx::Event::EVT_CHECKBOX($frame,$frame->{OPD_chk_8_Eind_Opname}, \&checkbox_8_Eind_clicked);
     Wx::Event::EVT_CHECKBOX($frame,$frame->{OPD_chk_9_Eind_Opname}, \&checkbox_9_Eind_clicked);
     Wx::Event::EVT_CHECKBOX($frame,$frame->{OPD_chk_10_Eind_Opname}, \&checkbox_10_Eind_clicked);
     Wx::Event::EVT_CHECKBOX($frame,$frame->{OPD_chk_11_Eind_Opname}, \&checkbox_11_Eind_clicked);
     Wx::Event::EVT_CHECKBOX($frame,$frame->{OPD_chk_12_Eind_Opname}, \&checkbox_12_Eind_clicked);
     Wx::Event::EVT_CHECKBOX($frame,$frame->{OPD_chk_13_Eind_Opname}, \&checkbox_13_Eind_clicked);
     Wx::Event::EVT_CHECKBOX($frame,$frame->{OPD_chk_14_Eind_Opname}, \&checkbox_14_Eind_clicked);
     Wx::Event::EVT_CHECKBOX($frame,$frame->{OPD_chk_15_Eind_Opname}, \&checkbox_15_Eind_clicked);
     Wx::Event::EVT_CHECKBOX($frame,$frame->{OPD_chk_16_Eind_Opname}, \&checkbox_16_Eind_clicked);
     Wx::Event::EVT_CHECKBOX($frame,$frame->{OPD_chk_17_Eind_Opname}, \&checkbox_17_Eind_clicked);
     Wx::Event::EVT_CHECKBOX($frame,$frame->{OPD_chk_18_Eind_Opname}, \&checkbox_18_Eind_clicked);
     Wx::Event::EVT_CHECKBOX($frame,$frame->{OPD_chk_19_Eind_Opname}, \&checkbox_19_Eind_clicked);
     Wx::Event::EVT_CHECKBOX($frame,$frame->{OPD_chk_20_Eind_Opname}, \&checkbox_20_Eind_clicked);
     Wx::Event::EVT_CHECKBOX($frame,$frame->{OPD_chk_21_Eind_Opname}, \&checkbox_21_Eind_clicked);
     Wx::Event::EVT_CHECKBOX($frame,$frame->{OPD_chk_22_Eind_Opname}, \&checkbox_22_Eind_clicked);
     Wx::Event::EVT_CHECKBOX($frame,$frame->{OPD_chk_23_Eind_Opname}, \&checkbox_23_Eind_clicked);
     }
sub checkbox_0_Eind_clicked {
     my ($frame, $evt) = @_;
     if ($evt->IsChecked()) {
         for (my $i=0; $i < 24; $i++) {
              $frame->{"OPD_chk_$i\_Eind_Opname"}->SetValue(0);
              $main::klant->{opnames}->[$i]->{eind_select} = 0;
         }
         $main::klant->{opnames}->[0]->{eind_select} = 1;
         $frame->{"OPD_chk_0_Eind_Opname"}->SetValue (1);
         my $opnamedatum = $main::klant->{opnames}->[0]->{einddatum};
         my $jaar = substr ($opnamedatum,0,4 );
         my $maand = substr ($opnamedatum,4,2);
         my $dag = substr ($opnamedatum,6,2);
         #$main::einddatum_opname = "$dag/$maand/$jaar";
         $main::einddatum_opname = $opnamedatum;
         $frame->{lov_Txt_0_Eind_Opname}->SetValue($main::einddatum_opname);
        }else {
         $main::klant->{opnames}->[0]->{eind_select} = 0;
         $main::einddatum_opname = "";
         $frame->{lov_Txt_0_Eind_Opname}->SetValue($main::einddatum_opname);
        }     
    }
sub checkbox_1_Eind_clicked {
     my ($frame, $evt) = @_;
     if ($evt->IsChecked()) {
         for (my $i=0; $i < 24; $i++) {
              $frame->{"OPD_chk_$i\_Eind_Opname"}->SetValue(0);
              $main::klant->{opnames}->[$i]->{eind_select} = 0;
         }
         $main::klant->{opnames}->[1]->{eind_select} = 1;
         $frame->{"OPD_chk_1_Eind_Opname"}->SetValue (1);
         my $opnamedatum = $main::klant->{opnames}->[1]->{einddatum};
         my $jaar = substr ($opnamedatum,0,4 );
         my $maand = substr ($opnamedatum,4,2);
         my $dag = substr ($opnamedatum,6,2);
         #$main::einddatum_opname = "$dag/$maand/$jaar";
         $main::einddatum_opname = $opnamedatum;
         $frame->{lov_Txt_0_Eind_Opname}->SetValue($main::einddatum_opname);
        }else {
         $main::klant->{opnames}->[1]->{eind_select} = 0;
         $main::einddatum_opname = "";
         $frame->{lov_Txt_0_Eind_Opname}->SetValue($main::einddatum_opname);
        }     
    }
sub checkbox_2_Eind_clicked {
     my ($frame, $evt) = @_;
     if ($evt->IsChecked()) {
         for (my $i=0; $i < 24; $i++) {
              $frame->{"OPD_chk_$i\_Eind_Opname"}->SetValue(0);
              $main::klant->{opnames}->[$i]->{eind_select} = 0;
         }
         $main::klant->{opnames}->[2]->{eind_select} = 1;
         $frame->{"OPD_chk_2_Eind_Opname"}->SetValue (1);
         my $opnamedatum = $main::klant->{opnames}->[2]->{einddatum};
         my $jaar = substr ($opnamedatum,0,4 );
         my $maand = substr ($opnamedatum,4,2);
         my $dag = substr ($opnamedatum,6,2);
         #$main::einddatum_opname = "$dag/$maand/$jaar";
         $main::einddatum_opname = $opnamedatum;
         $frame->{lov_Txt_0_Eind_Opname}->SetValue($main::einddatum_opname);
        }else {
         $main::klant->{opnames}->[2]->{eind_select} = 0;
         $main::einddatum_opname = "";
         $frame->{lov_Txt_0_Eind_Opname}->SetValue($main::einddatum_opname);
        }     
    }
sub checkbox_3_Eind_clicked {
     my ($frame, $evt) = @_;
     if ($evt->IsChecked()) {
         for (my $i=0; $i < 24; $i++) {
              $frame->{"OPD_chk_$i\_Eind_Opname"}->SetValue(0);
              $main::klant->{opnames}->[$i]->{eind_select} = 0;
         }
         $main::klant->{opnames}->[3]->{eind_select} = 1;
         $frame->{"OPD_chk_3_Eind_Opname"}->SetValue (1);
         my $opnamedatum = $main::klant->{opnames}->[3]->{einddatum};
         my $jaar = substr ($opnamedatum,0,4 );
         my $maand = substr ($opnamedatum,4,2);
         my $dag = substr ($opnamedatum,6,2);
         #$main::einddatum_opname = "$dag/$maand/$jaar";
         $main::einddatum_opname = $opnamedatum;
         $frame->{lov_Txt_0_Eind_Opname}->SetValue($main::einddatum_opname);
        }else {
         $main::klant->{opnames}->[3]->{eind_select} = 0;
         $main::einddatum_opname = "";
         $frame->{lov_Txt_0_Eind_Opname}->SetValue($main::einddatum_opname);
        }     
    }
sub checkbox_4_Eind_clicked {
     my ($frame, $evt) = @_;
     if ($evt->IsChecked()) {
         for (my $i=0; $i < 24; $i++) {
              $frame->{"OPD_chk_$i\_Eind_Opname"}->SetValue(0);
              $main::klant->{opnames}->[$i]->{eind_select} = 0;
         }
         $main::klant->{opnames}->[4]->{eind_select} = 1;
         $frame->{"OPD_chk_4_Eind_Opname"}->SetValue (1);
         my $opnamedatum = $main::klant->{opnames}->[4]->{einddatum};
         my $jaar = substr ($opnamedatum,0,4 );
         my $maand = substr ($opnamedatum,4,2);
         my $dag = substr ($opnamedatum,6,2);
         #$main::einddatum_opname = "$dag/$maand/$jaar";
         $main::einddatum_opname = $opnamedatum;
         $frame->{lov_Txt_0_Eind_Opname}->SetValue($main::einddatum_opname);
        }else {
         $main::klant->{opnames}->[4]->{eind_select} = 0;
         $main::einddatum_opname = "";
         $frame->{lov_Txt_0_Eind_Opname}->SetValue($main::einddatum_opname);
        }     
    }
sub checkbox_5_Eind_clicked {
     my ($frame, $evt) = @_;
     if ($evt->IsChecked()) {
         for (my $i=0; $i < 24; $i++) {
              $frame->{"OPD_chk_$i\_Eind_Opname"}->SetValue(0);
              $main::klant->{opnames}->[$i]->{eind_select} = 0;
         }
         $main::klant->{opnames}->[5]->{eind_select} = 1;
         $frame->{"OPD_chk_5_Eind_Opname"}->SetValue (1);
         my $opnamedatum = $main::klant->{opnames}->[5]->{einddatum};
         my $jaar = substr ($opnamedatum,0,4 );
         my $maand = substr ($opnamedatum,4,2);
         my $dag = substr ($opnamedatum,6,2);
         #$main::einddatum_opname = "$dag/$maand/$jaar";
         $main::einddatum_opname = $opnamedatum;
         $frame->{lov_Txt_0_Eind_Opname}->SetValue($main::einddatum_opname);
        }else {
         $main::klant->{opnames}->[5]->{eind_select} = 0;
         $main::einddatum_opname = "";
         $frame->{lov_Txt_0_Eind_Opname}->SetValue($main::einddatum_opname);
        }     
    }
sub checkbox_6_Eind_clicked {
     my ($frame, $evt) = @_;
     if ($evt->IsChecked()) {
         for (my $i=0; $i < 24; $i++) {
              $frame->{"OPD_chk_$i\_Eind_Opname"}->SetValue(0);
              $main::klant->{opnames}->[$i]->{eind_select} = 0;
         }
         $main::klant->{opnames}->[6]->{eind_select} = 1;
         $frame->{"OPD_chk_6_Eind_Opname"}->SetValue (1);
         my $opnamedatum = $main::klant->{opnames}->[6]->{einddatum};
         my $jaar = substr ($opnamedatum,0,4 );
         my $maand = substr ($opnamedatum,4,2);
         my $dag = substr ($opnamedatum,6,2);
         #$main::einddatum_opname = "$dag/$maand/$jaar";
         $main::einddatum_opname = $opnamedatum;
         $frame->{lov_Txt_0_Eind_Opname}->SetValue($main::einddatum_opname);
        }else {
         $main::klant->{opnames}->[6]->{eind_select} = 0;
         $main::einddatum_opname = "";
         $frame->{lov_Txt_0_Eind_Opname}->SetValue($main::einddatum_opname);
        }     
    }
sub checkbox_7_Eind_clicked {
     my ($frame, $evt) = @_;
     if ($evt->IsChecked()) {
         for (my $i=0; $i < 24; $i++) {
              $frame->{"OPD_chk_$i\_Eind_Opname"}->SetValue(0);
              $main::klant->{opnames}->[$i]->{eind_select} = 0;
         }
         $main::klant->{opnames}->[7]->{eind_select} = 1;
         $frame->{"OPD_chk_7_Eind_Opname"}->SetValue (1);
         my $opnamedatum = $main::klant->{opnames}->[7]->{einddatum};
         my $jaar = substr ($opnamedatum,0,4 );
         my $maand = substr ($opnamedatum,4,2);
         my $dag = substr ($opnamedatum,6,2);
         #$main::einddatum_opname = "$dag/$maand/$jaar";
         $main::einddatum_opname = $opnamedatum;
         $frame->{lov_Txt_0_Eind_Opname}->SetValue($main::einddatum_opname);
        }else {
         $main::klant->{opnames}->[7]->{eind_select} = 0;
         $main::einddatum_opname = "";
         $frame->{lov_Txt_0_Eind_Opname}->SetValue($main::einddatum_opname);
        }     
    }
sub checkbox_8_Eind_clicked {
     my ($frame, $evt) = @_;
     if ($evt->IsChecked()) {
         for (my $i=0; $i < 24; $i++) {
              $frame->{"OPD_chk_$i\_Eind_Opname"}->SetValue(0);
              $main::klant->{opnames}->[$i]->{eind_select} = 0;
         }
         $main::klant->{opnames}->[8]->{eind_select} = 1;
         $frame->{"OPD_chk_8_Eind_Opname"}->SetValue (1);
         my $opnamedatum = $main::klant->{opnames}->[8]->{einddatum};
         my $jaar = substr ($opnamedatum,0,4 );
         my $maand = substr ($opnamedatum,4,2);
         my $dag = substr ($opnamedatum,6,2);
         #$main::einddatum_opname = "$dag/$maand/$jaar";
         $main::einddatum_opname = $opnamedatum;
         $frame->{lov_Txt_0_Eind_Opname}->SetValue($main::einddatum_opname);
        }else {
         $main::klant->{opnames}->[8]->{eind_select} = 0;
         $main::einddatum_opname = "";
         $frame->{lov_Txt_0_Eind_Opname}->SetValue($main::einddatum_opname);
        }     
    }
sub checkbox_9_Eind_clicked {
     my ($frame, $evt) = @_;
     if ($evt->IsChecked()) {
         for (my $i=0; $i < 24; $i++) {
              $frame->{"OPD_chk_$i\_Eind_Opname"}->SetValue(0);
              $main::klant->{opnames}->[$i]->{eind_select} = 0;
         }
         $main::klant->{opnames}->[9]->{eind_select} = 1;
         $frame->{"OPD_chk_9_Eind_Opname"}->SetValue (1);
         my $opnamedatum = $main::klant->{opnames}->[9]->{einddatum};
         my $jaar = substr ($opnamedatum,0,4 );
         my $maand = substr ($opnamedatum,4,2);
         my $dag = substr ($opnamedatum,6,2);
         #$main::einddatum_opname = "$dag/$maand/$jaar";
         $main::einddatum_opname = $opnamedatum;
         $frame->{lov_Txt_0_Eind_Opname}->SetValue($main::einddatum_opname);
        }else {
         $main::klant->{opnames}->[9]->{eind_select} = 0;
         $main::einddatum_opname = "";
         $frame->{lov_Txt_0_Eind_Opname}->SetValue($main::einddatum_opname);
        }     
    }
sub checkbox_10_Eind_clicked {
     my ($frame, $evt) = @_;
     if ($evt->IsChecked()) {
         for (my $i=0; $i < 24; $i++) {
              $frame->{"OPD_chk_$i\_Eind_Opname"}->SetValue(0);
              $main::klant->{opnames}->[$i]->{eind_select} = 0;
         }
         $main::klant->{opnames}->[10]->{eind_select} = 1;
         $frame->{"OPD_chk_10_Eind_Opname"}->SetValue (1);
         my $opnamedatum = $main::klant->{opnames}->[10]->{einddatum};
         my $jaar = substr ($opnamedatum,0,4 );
         my $maand = substr ($opnamedatum,4,2);
         my $dag = substr ($opnamedatum,6,2);
         #$main::einddatum_opname = "$dag/$maand/$jaar";
         $main::einddatum_opname = $opnamedatum;
         $frame->{lov_Txt_0_Eind_Opname}->SetValue($main::einddatum_opname);
        }else {
         $main::klant->{opnames}->[10]->{eind_select} = 0;
         $main::einddatum_opname = "";
         $frame->{lov_Txt_0_Eind_Opname}->SetValue($main::einddatum_opname);
        }     
    }
sub checkbox_11_Eind_clicked {
     my ($frame, $evt) = @_;
     if ($evt->IsChecked()) {
         for (my $i=0; $i < 24; $i++) {
              $frame->{"OPD_chk_$i\_Eind_Opname"}->SetValue(0);
              $main::klant->{opnames}->[$i]->{eind_select} = 0;
         }
         $main::klant->{opnames}->[11]->{eind_select} = 1;
         $frame->{"OPD_chk_11_Eind_Opname"}->SetValue (1);
         my $opnamedatum = $main::klant->{opnames}->[11]->{einddatum};
         my $jaar = substr ($opnamedatum,0,4 );
         my $maand = substr ($opnamedatum,4,2);
         my $dag = substr ($opnamedatum,6,2);
         #$main::einddatum_opname = "$dag/$maand/$jaar";
         $main::einddatum_opname = $opnamedatum;
         $frame->{lov_Txt_0_Eind_Opname}->SetValue($main::einddatum_opname);
        }else {
         $main::klant->{opnames}->[11]->{eind_select} = 0;
         $main::einddatum_opname = "";
         $frame->{lov_Txt_0_Eind_Opname}->SetValue($main::einddatum_opname);
        }     
    }
sub checkbox_12_Eind_clicked {
     my ($frame, $evt) = @_;
     if ($evt->IsChecked()) {
         for (my $i=0; $i < 24; $i++) {
              $frame->{"OPD_chk_$i\_Eind_Opname"}->SetValue(0);
              $main::klant->{opnames}->[$i]->{eind_select} = 0;
         }
         $main::klant->{opnames}->[12]->{eind_select} = 1;
         $frame->{"OPD_chk_12_Eind_Opname"}->SetValue (1);
         my $opnamedatum = $main::klant->{opnames}->[12]->{einddatum};
         my $jaar = substr ($opnamedatum,0,4 );
         my $maand = substr ($opnamedatum,4,2);
         my $dag = substr ($opnamedatum,6,2);
         #$main::einddatum_opname = "$dag/$maand/$jaar";
         $main::einddatum_opname = $opnamedatum;
         $frame->{lov_Txt_0_Eind_Opname}->SetValue($main::einddatum_opname);
        }else {
         $main::klant->{opnames}->[12]->{eind_select} = 0;
         $main::einddatum_opname = "";
         $frame->{lov_Txt_0_Eind_Opname}->SetValue($main::einddatum_opname);
        }     
    }
sub checkbox_13_Eind_clicked {
     my ($frame, $evt) = @_;
     if ($evt->IsChecked()) {
         for (my $i=0; $i < 24; $i++) {
              $frame->{"OPD_chk_$i\_Eind_Opname"}->SetValue(0);
              $main::klant->{opnames}->[$i]->{eind_select} = 0;
         }
         $main::klant->{opnames}->[13]->{eind_select} = 1;
         $frame->{"OPD_chk_13_Eind_Opname"}->SetValue (1);
         my $opnamedatum = $main::klant->{opnames}->[13]->{einddatum};
         my $jaar = substr ($opnamedatum,0,4 );
         my $maand = substr ($opnamedatum,4,2);
         my $dag = substr ($opnamedatum,6,2);
         #$main::einddatum_opname = "$dag/$maand/$jaar";
         $main::einddatum_opname = $opnamedatum;
         $frame->{lov_Txt_0_Eind_Opname}->SetValue($main::einddatum_opname);
        }else {
         $main::klant->{opnames}->[13]->{eind_select} = 0;
         $main::einddatum_opname = "";
         $frame->{lov_Txt_0_Eind_Opname}->SetValue($main::einddatum_opname);
        }     
    }
sub checkbox_14_Eind_clicked {
     my ($frame, $evt) = @_;
     if ($evt->IsChecked()) {
         for (my $i=0; $i < 24; $i++) {
              $frame->{"OPD_chk_$i\_Eind_Opname"}->SetValue(0);
              $main::klant->{opnames}->[$i]->{eind_select} = 0;
         }
         $main::klant->{opnames}->[14]->{eind_select} = 1;
         $frame->{"OPD_chk_14_Eind_Opname"}->SetValue (1);
         my $opnamedatum = $main::klant->{opnames}->[14]->{einddatum};
         my $jaar = substr ($opnamedatum,0,4 );
         my $maand = substr ($opnamedatum,4,2);
         my $dag = substr ($opnamedatum,6,2);
         #$main::einddatum_opname = "$dag/$maand/$jaar";
         $main::einddatum_opname = $opnamedatum;
         $frame->{lov_Txt_0_Eind_Opname}->SetValue($main::einddatum_opname);
        }else {
         $main::klant->{opnames}->[14]->{eind_select} = 0;
         $main::einddatum_opname = "";
         $frame->{lov_Txt_0_Eind_Opname}->SetValue($main::einddatum_opname);
        }     
    }
sub checkbox_15_Eind_clicked {
     my ($frame, $evt) = @_;
     if ($evt->IsChecked()) {
         for (my $i=0; $i < 24; $i++) {
              $frame->{"OPD_chk_$i\_Eind_Opname"}->SetValue(0);
              $main::klant->{opnames}->[$i]->{eind_select} = 0;
         }
         $main::klant->{opnames}->[15]->{eind_select} = 1;
         $frame->{"OPD_chk_15_Eind_Opname"}->SetValue (1);
         my $opnamedatum = $main::klant->{opnames}->[15]->{einddatum};
         my $jaar = substr ($opnamedatum,0,4 );
         my $maand = substr ($opnamedatum,4,2);
         my $dag = substr ($opnamedatum,6,2);
         #$main::einddatum_opname = "$dag/$maand/$jaar";
         $main::einddatum_opname = $opnamedatum;
         $frame->{lov_Txt_0_Eind_Opname}->SetValue($main::einddatum_opname);
        }else {
         $main::klant->{opnames}->[15]->{eind_select} = 0;
         $main::einddatum_opname = "";
         $frame->{lov_Txt_0_Eind_Opname}->SetValue($main::einddatum_opname);
        }     
    }
sub checkbox_16_Eind_clicked {
     my ($frame, $evt) = @_;
     if ($evt->IsChecked()) {
         for (my $i=0; $i < 24; $i++) {
              $frame->{"OPD_chk_$i\_Eind_Opname"}->SetValue(0);
              $main::klant->{opnames}->[$i]->{eind_select} = 0;
         }
         $main::klant->{opnames}->[16]->{eind_select} = 1;
         $frame->{"OPD_chk_16_Eind_Opname"}->SetValue (1);
         my $opnamedatum = $main::klant->{opnames}->[16]->{einddatum};
         my $jaar = substr ($opnamedatum,0,4 );
         my $maand = substr ($opnamedatum,4,2);
         my $dag = substr ($opnamedatum,6,2);
         #$main::einddatum_opname = "$dag/$maand/$jaar";
         $main::einddatum_opname = $opnamedatum;
         $frame->{lov_Txt_0_Eind_Opname}->SetValue($main::einddatum_opname);
        }else {
         $main::klant->{opnames}->[16]->{eind_select} = 0;
         $main::einddatum_opname = "";
         $frame->{lov_Txt_0_Eind_Opname}->SetValue($main::einddatum_opname);
        }     
    }
sub checkbox_17_Eind_clicked {
     my ($frame, $evt) = @_;
     if ($evt->IsChecked()) {
         for (my $i=0; $i < 24; $i++) {
              $frame->{"OPD_chk_$i\_Eind_Opname"}->SetValue(0);
              $main::klant->{opnames}->[$i]->{eind_select} = 0;
         }
         $main::klant->{opnames}->[17]->{eind_select} = 1;
         $frame->{"OPD_chk_17_Eind_Opname"}->SetValue (1);
         my $opnamedatum = $main::klant->{opnames}->[17]->{einddatum};
         my $jaar = substr ($opnamedatum,0,4 );
         my $maand = substr ($opnamedatum,4,2);
         my $dag = substr ($opnamedatum,6,2);
         #$main::einddatum_opname = "$dag/$maand/$jaar";
         $main::einddatum_opname = $opnamedatum;
         $frame->{lov_Txt_0_Eind_Opname}->SetValue($main::einddatum_opname);
        }else {
         $main::klant->{opnames}->[17]->{eind_select} = 0;
         $main::einddatum_opname = "";
         $frame->{lov_Txt_0_Eind_Opname}->SetValue($main::einddatum_opname);
        }     
    }
sub checkbox_18_Eind_clicked {
     my ($frame, $evt) = @_;
     if ($evt->IsChecked()) {
         for (my $i=0; $i < 24; $i++) {
              $frame->{"OPD_chk_$i\_Eind_Opname"}->SetValue(0);
              $main::klant->{opnames}->[$i]->{eind_select} = 0;
         }
         $main::klant->{opnames}->[18]->{eind_select} = 1;
         $frame->{"OPD_chk_18_Eind_Opname"}->SetValue (1);
         my $opnamedatum = $main::klant->{opnames}->[18]->{einddatum};
         my $jaar = substr ($opnamedatum,0,4 );
         my $maand = substr ($opnamedatum,4,2);
         my $dag = substr ($opnamedatum,6,2);
         #$main::einddatum_opname = "$dag/$maand/$jaar";
         $main::einddatum_opname = $opnamedatum;
         $frame->{lov_Txt_0_Eind_Opname}->SetValue($main::einddatum_opname);
        }else {
         $main::klant->{opnames}->[18]->{eind_select} = 0;
         $main::einddatum_opname = "";
         $frame->{lov_Txt_0_Eind_Opname}->SetValue($main::einddatum_opname);
        }     
    }
sub checkbox_19_Eind_clicked {
     my ($frame, $evt) = @_;
     if ($evt->IsChecked()) {
         for (my $i=0; $i < 24; $i++) {
              $frame->{"OPD_chk_$i\_Eind_Opname"}->SetValue(0);
              $main::klant->{opnames}->[$i]->{eind_select} = 0;
         }
         $main::klant->{opnames}->[19]->{eind_select} = 1;
         $frame->{"OPD_chk_19_Eind_Opname"}->SetValue (1);
         my $opnamedatum = $main::klant->{opnames}->[19]->{einddatum};
         my $jaar = substr ($opnamedatum,0,4 );
         my $maand = substr ($opnamedatum,4,2);
         my $dag = substr ($opnamedatum,6,2);
         #$main::einddatum_opname = "$dag/$maand/$jaar";
         $main::einddatum_opname = $opnamedatum;
         $frame->{lov_Txt_0_Eind_Opname}->SetValue($main::einddatum_opname);
        }else {
         $main::klant->{opnames}->[19]->{eind_select} = 0;
         $main::einddatum_opname = "";
         $frame->{lov_Txt_0_Eind_Opname}->SetValue($main::einddatum_opname);
        }     
    }
sub checkbox_20_Eind_clicked {
     my ($frame, $evt) = @_;
     if ($evt->IsChecked()) {
         for (my $i=0; $i < 24; $i++) {
              $frame->{"OPD_chk_$i\_Eind_Opname"}->SetValue(0);
              $main::klant->{opnames}->[$i]->{eind_select} = 0;
         }
         $main::klant->{opnames}->[20]->{eind_select} = 1;
         $frame->{"OPD_chk_20_Eind_Opname"}->SetValue (1);
         my $opnamedatum = $main::klant->{opnames}->[20]->{einddatum};
         my $jaar = substr ($opnamedatum,0,4 );
         my $maand = substr ($opnamedatum,4,2);
         my $dag = substr ($opnamedatum,6,2);
         #$main::einddatum_opname = "$dag/$maand/$jaar";
         $main::einddatum_opname = $opnamedatum;
         $frame->{lov_Txt_0_Eind_Opname}->SetValue($main::einddatum_opname);
        }else {
         $main::klant->{opnames}->[20]->{eind_select} = 0;
         $main::einddatum_opname = "";
         $frame->{lov_Txt_0_Eind_Opname}->SetValue($main::einddatum_opname);
        }     
    }
sub checkbox_21_Eind_clicked {
     my ($frame, $evt) = @_;
     if ($evt->IsChecked()) {
         for (my $i=0; $i < 24; $i++) {
              $frame->{"OPD_chk_$i\_Eind_Opname"}->SetValue(0);
              $main::klant->{opnames}->[$i]->{eind_select} = 0;
         }
         $main::klant->{opnames}->[21]->{eind_select} = 1;
         $frame->{"OPD_chk_21_Eind_Opname"}->SetValue (1);
         my $opnamedatum = $main::klant->{opnames}->[21]->{einddatum};
         my $jaar = substr ($opnamedatum,0,4 );
         my $maand = substr ($opnamedatum,4,2);
         my $dag = substr ($opnamedatum,6,2);
         #$main::einddatum_opname = "$dag/$maand/$jaar";
         $main::einddatum_opname = $opnamedatum;
         $frame->{lov_Txt_0_Eind_Opname}->SetValue($main::einddatum_opname);
        }else {
         $main::klant->{opnames}->[21]->{eind_select} = 0;
         $main::einddatum_opname = "";
         $frame->{lov_Txt_0_Eind_Opname}->SetValue($main::einddatum_opname);
        }     
    }
sub checkbox_22_Eind_clicked {
     my ($frame, $evt) = @_;
     if ($evt->IsChecked()) {
         for (my $i=0; $i < 24; $i++) {
              $frame->{"OPD_chk_$i\_Eind_Opname"}->SetValue(0);
              $main::klant->{opnames}->[$i]->{eind_select} = 0;
         }
         $main::klant->{opnames}->[22]->{eind_select} = 1;
         $frame->{"OPD_chk_22_Eind_Opname"}->SetValue (1);
         my $opnamedatum = $main::klant->{opnames}->[22]->{einddatum};
         my $jaar = substr ($opnamedatum,0,4 );
         my $maand = substr ($opnamedatum,4,2);
         my $dag = substr ($opnamedatum,6,2);
         #$main::einddatum_opname = "$dag/$maand/$jaar";
         $main::einddatum_opname = $opnamedatum;
         $frame->{lov_Txt_0_Eind_Opname}->SetValue($main::einddatum_opname);
        }else {
         $main::klant->{opnames}->[22]->{eind_select} = 0;
         $main::einddatum_opname = "";
         $frame->{lov_Txt_0_Eind_Opname}->SetValue($main::einddatum_opname);
        }     
    }
sub checkbox_23_Eind_clicked {
     my ($frame, $evt) = @_;
     if ($evt->IsChecked()) {
         for (my $i=0; $i < 24; $i++) {
              $frame->{"OPD_chk_$i\_Eind_Opname"}->SetValue(0);
              $main::klant->{opnames}->[$i]->{eind_select} = 0;
         }
         $main::klant->{opnames}->[23]->{eind_select} = 1;
         $frame->{"OPD_chk_23_Eind_Opname"}->SetValue (1);
         my $opnamedatum = $main::klant->{opnames}->[22]->{einddatum};
         my $jaar = substr ($opnamedatum,0,4 );
         my $maand = substr ($opnamedatum,4,2);
         my $dag = substr ($opnamedatum,6,2);
         #$main::einddatum_opname = "$dag/$maand/$jaar";
         $main::einddatum_opname = $opnamedatum;
         $frame->{lov_Txt_0_Eind_Opname}->SetValue($main::einddatum_opname);
        }else {
         $main::klant->{opnames}->[23]->{eind_select} = 0;
         $main::einddatum_opname = "";
         $frame->{lov_Txt_0_Eind_Opname}->SetValue($main::einddatum_opname);
        }     
    }

#BEGIN

sub checkbox_0_Begin_clicked {
     my ($frame, $evt) = @_;
     if ($evt->IsChecked()) {
         for (my $i=0; $i < 24; $i++) {
              $frame->{"OPD_chk_$i\_Begin_Opname"}->SetValue(0);
              $main::klant->{opnames}->[$i]->{begin_select} = 0;
         }
         $main::klant->{opnames}->[0]->{begin_select} = 1;
         $frame->{"OPD_chk_0_Begin_Opname"}->SetValue (1);
         my $opnamedatum = $main::klant->{opnames}->[0]->{begindatum};
         my $jaar = substr ($opnamedatum,0,4 );
         my $maand = substr ($opnamedatum,4,2);
         my $dag = substr ($opnamedatum,6,2);
         #$main::begindatum_opname = "$dag/$maand/$jaar";
         $main::begindatum_opname = $opnamedatum;
         $frame->{lov_Txt_0_Begin_Opname}->SetValue($main::begindatum_opname);
        }else {
         $main::klant->{opnames}->[0]->{begin_select} = 0;
         $main::begindatum_opname = "";
         $frame->{lov_Txt_0_Begin_Opname}->SetValue($main::begindatum_opname);
        }     
    }
sub checkbox_1_Begin_clicked {
     my ($frame, $evt) = @_;
     if ($evt->IsChecked()) {
         for (my $i=0; $i < 24; $i++) {
              $frame->{"OPD_chk_$i\_Begin_Opname"}->SetValue(0);
              $main::klant->{opnames}->[$i]->{begin_select} = 0;
         }
         $main::klant->{opnames}->[1]->{begin_select} = 1;
         $frame->{"OPD_chk_1_Begin_Opname"}->SetValue (1);
         my $opnamedatum = $main::klant->{opnames}->[1]->{begindatum};
         my $jaar = substr ($opnamedatum,0,4 );
         my $maand = substr ($opnamedatum,4,2);
         my $dag = substr ($opnamedatum,6,2);
         $main::begindatum_opname = $opnamedatum;
         $frame->{lov_Txt_0_Begin_Opname}->SetValue($main::begindatum_opname);
        }else {
         $main::klant->{opnames}->[1]->{begin_select} = 0;
         $main::begindatum_opname = "";
         $frame->{lov_Txt_0_Begin_Opname}->SetValue($main::begindatum_opname);
        }     
    }
sub checkbox_2_Begin_clicked {
     my ($frame, $evt) = @_;
     if ($evt->IsChecked()) {
         for (my $i=0; $i < 24; $i++) {
              $frame->{"OPD_chk_$i\_Begin_Opname"}->SetValue(0);
              $main::klant->{opnames}->[$i]->{begin_select} = 0;
         }
         $main::klant->{opnames}->[2]->{begin_select} = 1;
         $frame->{"OPD_chk_2_Begin_Opname"}->SetValue (1);
         my $opnamedatum = $main::klant->{opnames}->[2]->{begindatum};
         my $jaar = substr ($opnamedatum,0,4 );
         my $maand = substr ($opnamedatum,4,2);
         my $dag = substr ($opnamedatum,6,2);
         $main::begindatum_opname = $opnamedatum;
         $frame->{lov_Txt_0_Begin_Opname}->SetValue($main::begindatum_opname);
        }else {
         $main::klant->{opnames}->[2]->{begin_select} = 0;
         $main::begindatum_opname = "";
         $frame->{lov_Txt_0_Begin_Opname}->SetValue($main::begindatum_opname);
        }     
    }
sub checkbox_3_Begin_clicked {
     my ($frame, $evt) = @_;
     if ($evt->IsChecked()) {
         for (my $i=0; $i < 24; $i++) {
              $frame->{"OPD_chk_$i\_Begin_Opname"}->SetValue(0);
              $main::klant->{opnames}->[$i]->{begin_select} = 0;
         }
         $main::klant->{opnames}->[3]->{begin_select} = 1;
         $frame->{"OPD_chk_3_Begin_Opname"}->SetValue (1);
         my $opnamedatum = $main::klant->{opnames}->[3]->{begindatum};
         my $jaar = substr ($opnamedatum,0,4 );
         my $maand = substr ($opnamedatum,4,2);
         my $dag = substr ($opnamedatum,6,2);
         $main::begindatum_opname = $opnamedatum;
         $frame->{lov_Txt_0_Begin_Opname}->SetValue($main::begindatum_opname);
        }else {
         $main::klant->{opnames}->[3]->{begin_select} = 0;
         $main::begindatum_opname = "";
         $frame->{lov_Txt_0_Begin_Opname}->SetValue($main::begindatum_opname);
        }     
    }
sub checkbox_4_Begin_clicked {
     my ($frame, $evt) = @_;
     if ($evt->IsChecked()) {
         for (my $i=0; $i < 24; $i++) {
              $frame->{"OPD_chk_$i\_Begin_Opname"}->SetValue(0);
              $main::klant->{opnames}->[$i]->{begin_select} = 0;
         }
         $main::klant->{opnames}->[4]->{begin_select} = 1;
         $frame->{"OPD_chk_4_Begin_Opname"}->SetValue (1);
         my $opnamedatum = $main::klant->{opnames}->[4]->{begindatum};
         my $jaar = substr ($opnamedatum,0,4 );
         my $maand = substr ($opnamedatum,4,2);
         my $dag = substr ($opnamedatum,6,2);
         $main::begindatum_opname = $opnamedatum;
         $frame->{lov_Txt_0_Begin_Opname}->SetValue($main::begindatum_opname);
        }else {
         $main::klant->{opnames}->[4]->{begin_select} = 0;
         $main::begindatum_opname = "";
         $frame->{lov_Txt_0_Begin_Opname}->SetValue($main::begindatum_opname);
        }     
    }
sub checkbox_5_Begin_clicked {
     my ($frame, $evt) = @_;
     if ($evt->IsChecked()) {
         for (my $i=0; $i < 24; $i++) {
              $frame->{"OPD_chk_$i\_Begin_Opname"}->SetValue(0);
              $main::klant->{opnames}->[$i]->{begin_select} = 0;
         }
         $main::klant->{opnames}->[5]->{begin_select} = 1;
         $frame->{"OPD_chk_5_Begin_Opname"}->SetValue (1);
         my $opnamedatum = $main::klant->{opnames}->[5]->{begindatum};
         my $jaar = substr ($opnamedatum,0,4 );
         my $maand = substr ($opnamedatum,4,2);
         my $dag = substr ($opnamedatum,6,2);
         $main::begindatum_opname = $opnamedatum;
         $frame->{lov_Txt_0_Begin_Opname}->SetValue($main::begindatum_opname);
        }else {
         $main::klant->{opnames}->[5]->{begin_select} = 0;
         $main::begindatum_opname = "";
         $frame->{lov_Txt_0_Begin_Opname}->SetValue($main::begindatum_opname);
        }     
    }
sub checkbox_6_Begin_clicked {
     my ($frame, $evt) = @_;
     if ($evt->IsChecked()) {
         for (my $i=0; $i < 24; $i++) {
              $frame->{"OPD_chk_$i\_Begin_Opname"}->SetValue(0);
              $main::klant->{opnames}->[$i]->{begin_select} = 0;
         }
         $main::klant->{opnames}->[6]->{begin_select} = 1;
         $frame->{"OPD_chk_6_Begin_Opname"}->SetValue (1);
         my $opnamedatum = $main::klant->{opnames}->[6]->{begindatum};
         my $jaar = substr ($opnamedatum,0,4 );
         my $maand = substr ($opnamedatum,4,2);
         my $dag = substr ($opnamedatum,6,2);
         $main::begindatum_opname = $opnamedatum;
         $frame->{lov_Txt_0_Begin_Opname}->SetValue($main::begindatum_opname);
        }else {
         $main::klant->{opnames}->[6]->{begin_select} = 0;
         $main::begindatum_opname = "";
         $frame->{lov_Txt_0_Begin_Opname}->SetValue($main::begindatum_opname);
        }     
    }
sub checkbox_7_Begin_clicked {
     my ($frame, $evt) = @_;
     if ($evt->IsChecked()) {
         for (my $i=0; $i < 24; $i++) {
              $frame->{"OPD_chk_$i\_Begin_Opname"}->SetValue(0);
              $main::klant->{opnames}->[$i]->{begin_select} = 0;
         }
         $main::klant->{opnames}->[7]->{begin_select} = 1;
         $frame->{"OPD_chk_7_Begin_Opname"}->SetValue (1);
         my $opnamedatum = $main::klant->{opnames}->[7]->{begindatum};
         my $jaar = substr ($opnamedatum,0,4 );
         my $maand = substr ($opnamedatum,4,2);
         my $dag = substr ($opnamedatum,6,2);
         $main::begindatum_opname = $opnamedatum;
         $frame->{lov_Txt_0_Begin_Opname}->SetValue($main::begindatum_opname);
        }else {
         $main::klant->{opnames}->[7]->{begin_select} = 0;
         $main::begindatum_opname = "";
         $frame->{lov_Txt_0_Begin_Opname}->SetValue($main::begindatum_opname);
        }     
    }
sub checkbox_8_Begin_clicked {
     my ($frame, $evt) = @_;
     if ($evt->IsChecked()) {
         for (my $i=0; $i < 24; $i++) {
              $frame->{"OPD_chk_$i\_Begin_Opname"}->SetValue(0);
              $main::klant->{opnames}->[$i]->{begin_select} = 0;
         }
         $main::klant->{opnames}->[8]->{begin_select} = 1;
         $frame->{"OPD_chk_8_Begin_Opname"}->SetValue (1);
         my $opnamedatum = $main::klant->{opnames}->[8]->{begindatum};
         my $jaar = substr ($opnamedatum,0,4 );
         my $maand = substr ($opnamedatum,4,2);
         my $dag = substr ($opnamedatum,6,2);
         $main::begindatum_opname = $opnamedatum;
         $frame->{lov_Txt_0_Begin_Opname}->SetValue($main::begindatum_opname);
        }else {
         $main::klant->{opnames}->[8]->{begin_select} = 0;
         $main::begindatum_opname = "";
         $frame->{lov_Txt_0_Begin_Opname}->SetValue($main::begindatum_opname);
        }     
    }
sub checkbox_9_Begin_clicked {
     my ($frame, $evt) = @_;
     if ($evt->IsChecked()) {
         for (my $i=0; $i < 24; $i++) {
              $frame->{"OPD_chk_$i\_Begin_Opname"}->SetValue(0);
              $main::klant->{opnames}->[$i]->{begin_select} = 0;
         }
         $main::klant->{opnames}->[9]->{begin_select} = 1;
         $frame->{"OPD_chk_9_Begin_Opname"}->SetValue (1);
         my $opnamedatum = $main::klant->{opnames}->[9]->{begindatum};
         my $jaar = substr ($opnamedatum,0,4 );
         my $maand = substr ($opnamedatum,4,2);
         my $dag = substr ($opnamedatum,6,2);
         $main::begindatum_opname = $opnamedatum;
         $frame->{lov_Txt_0_Begin_Opname}->SetValue($main::begindatum_opname);
        }else {
         $main::klant->{opnames}->[9]->{begin_select} = 0;
         $main::begindatum_opname = "";
         $frame->{lov_Txt_0_Begin_Opname}->SetValue($main::begindatum_opname);
        }     
    }
sub checkbox_10_Begin_clicked {
     my ($frame, $evt) = @_;
     if ($evt->IsChecked()) {
         for (my $i=0; $i < 24; $i++) {
              $frame->{"OPD_chk_$i\_Begin_Opname"}->SetValue(0);
              $main::klant->{opnames}->[$i]->{begin_select} = 0;
         }
         $main::klant->{opnames}->[10]->{begin_select} = 1;
         $frame->{"OPD_chk_10_Begin_Opname"}->SetValue (1);
         my $opnamedatum = $main::klant->{opnames}->[10]->{begindatum};
         my $jaar = substr ($opnamedatum,0,4 );
         my $maand = substr ($opnamedatum,4,2);
         my $dag = substr ($opnamedatum,6,2);
         $main::begindatum_opname = $opnamedatum;
         $frame->{lov_Txt_0_Begin_Opname}->SetValue($main::begindatum_opname);
        }else {
         $main::klant->{opnames}->[10]->{begin_select} = 0;
         $main::begindatum_opname = "";
         $frame->{lov_Txt_0_Begin_Opname}->SetValue($main::begindatum_opname);
        }     
    }
sub checkbox_11_Begin_clicked {
     my ($frame, $evt) = @_;
     if ($evt->IsChecked()) {
         for (my $i=0; $i < 24; $i++) {
              $frame->{"OPD_chk_$i\_Begin_Opname"}->SetValue(0);
              $main::klant->{opnames}->[$i]->{begin_select} = 0;
         }
         $main::klant->{opnames}->[11]->{begin_select} = 1;
         $frame->{"OPD_chk_11_Begin_Opname"}->SetValue (1);
         my $opnamedatum = $main::klant->{opnames}->[11]->{begindatum};
         my $jaar = substr ($opnamedatum,0,4 );
         my $maand = substr ($opnamedatum,4,2);
         my $dag = substr ($opnamedatum,6,2);
         $main::begindatum_opname = $opnamedatum;
         $frame->{lov_Txt_0_Begin_Opname}->SetValue($main::begindatum_opname);
        }else {
         $main::klant->{opnames}->[11]->{begin_select} = 0;
         $main::begindatum_opname = "";
         $frame->{lov_Txt_0_Begin_Opname}->SetValue($main::begindatum_opname);
        }     
    }
sub checkbox_12_Begin_clicked {
     my ($frame, $evt) = @_;
     if ($evt->IsChecked()) {
         for (my $i=0; $i < 24; $i++) {
              $frame->{"OPD_chk_$i\_Begin_Opname"}->SetValue(0);
              $main::klant->{opnames}->[$i]->{begin_select} = 0;
         }
         $main::klant->{opnames}->[12]->{begin_select} = 1;
         $frame->{"OPD_chk_12_Begin_Opname"}->SetValue (1);
         my $opnamedatum = $main::klant->{opnames}->[12]->{begindatum};
         my $jaar = substr ($opnamedatum,0,4 );
         my $maand = substr ($opnamedatum,4,2);
         my $dag = substr ($opnamedatum,6,2);
         $main::begindatum_opname = $opnamedatum;
         $frame->{lov_Txt_0_Begin_Opname}->SetValue($main::begindatum_opname);
        }else {
         $main::klant->{opnames}->[12]->{begin_select} = 0;
         $main::begindatum_opname = "";
         $frame->{lov_Txt_0_Begin_Opname}->SetValue($main::begindatum_opname);
        }     
    }
sub checkbox_13_Begin_clicked {
     my ($frame, $evt) = @_;
     if ($evt->IsChecked()) {
         for (my $i=0; $i < 24; $i++) {
              $frame->{"OPD_chk_$i\_Begin_Opname"}->SetValue(0);
              $main::klant->{opnames}->[$i]->{begin_select} = 0;
         }
         $main::klant->{opnames}->[13]->{begin_select} = 1;
         $frame->{"OPD_chk_13_Begin_Opname"}->SetValue (1);
         my $opnamedatum = $main::klant->{opnames}->[13]->{begindatum};
         my $jaar = substr ($opnamedatum,0,4 );
         my $maand = substr ($opnamedatum,4,2);
         my $dag = substr ($opnamedatum,6,2);
         $main::begindatum_opname = $opnamedatum;
         $frame->{lov_Txt_0_Begin_Opname}->SetValue($main::begindatum_opname);
        }else {
         $main::klant->{opnames}->[13]->{begin_select} = 0;
         $main::begindatum_opname = "";
         $frame->{lov_Txt_0_Begin_Opname}->SetValue($main::begindatum_opname);
        }     
    }
sub checkbox_14_Begin_clicked {
     my ($frame, $evt) = @_;
     if ($evt->IsChecked()) {
         for (my $i=0; $i < 24; $i++) {
              $frame->{"OPD_chk_$i\_Begin_Opname"}->SetValue(0);
              $main::klant->{opnames}->[$i]->{begin_select} = 0;
         }
         $main::klant->{opnames}->[14]->{begin_select} = 1;
         $frame->{"OPD_chk_14_Begin_Opname"}->SetValue (1);
         my $opnamedatum = $main::klant->{opnames}->[14]->{begindatum};
         my $jaar = substr ($opnamedatum,0,4 );
         my $maand = substr ($opnamedatum,4,2);
         my $dag = substr ($opnamedatum,6,2);
         $main::begindatum_opname = $opnamedatum;
         $frame->{lov_Txt_0_Begin_Opname}->SetValue($main::begindatum_opname);
        }else {
         $main::klant->{opnames}->[14]->{begin_select} = 0;
         $main::begindatum_opname = "";
         $frame->{lov_Txt_0_Begin_Opname}->SetValue($main::begindatum_opname);
        }     
    }
sub checkbox_15_Begin_clicked {
     my ($frame, $evt) = @_;
     if ($evt->IsChecked()) {
         for (my $i=0; $i < 24; $i++) {
              $frame->{"OPD_chk_$i\_Begin_Opname"}->SetValue(0);
              $main::klant->{opnames}->[$i]->{begin_select} = 0;
         }
         $main::klant->{opnames}->[15]->{begin_select} = 1;
         $frame->{"OPD_chk_15_Begin_Opname"}->SetValue (1);
         my $opnamedatum = $main::klant->{opnames}->[15]->{begindatum};
         my $jaar = substr ($opnamedatum,0,4 );
         my $maand = substr ($opnamedatum,4,2);
         my $dag = substr ($opnamedatum,6,2);
         $main::begindatum_opname = $opnamedatum;
         $frame->{lov_Txt_0_Begin_Opname}->SetValue($main::begindatum_opname);
        }else {
         $main::klant->{opnames}->[15]->{begin_select} = 0;
         $main::begindatum_opname = "";
         $frame->{lov_Txt_0_Begin_Opname}->SetValue($main::begindatum_opname);
        }     
    }
sub checkbox_16_Begin_clicked {
     my ($frame, $evt) = @_;
     if ($evt->IsChecked()) {
         for (my $i=0; $i < 24; $i++) {
              $frame->{"OPD_chk_$i\_Begin_Opname"}->SetValue(0);
              $main::klant->{opnames}->[$i]->{begin_select} = 0;
         }
         $main::klant->{opnames}->[16]->{begin_select} = 1;
         $frame->{"OPD_chk_16_Begin_Opname"}->SetValue (1);
         my $opnamedatum = $main::klant->{opnames}->[16]->{begindatum};
         my $jaar = substr ($opnamedatum,0,4 );
         my $maand = substr ($opnamedatum,4,2);
         my $dag = substr ($opnamedatum,6,2);
         $main::begindatum_opname = $opnamedatum;
         $frame->{lov_Txt_0_Begin_Opname}->SetValue($main::begindatum_opname);
        }else {
         $main::klant->{opnames}->[16]->{begin_select} = 0;
         $main::begindatum_opname = "";
         $frame->{lov_Txt_0_Begin_Opname}->SetValue($main::begindatum_opname);
        }     
    }
sub checkbox_17_Begin_clicked {
     my ($frame, $evt) = @_;
     if ($evt->IsChecked()) {
         for (my $i=0; $i < 24; $i++) {
              $frame->{"OPD_chk_$i\_Begin_Opname"}->SetValue(0);
              $main::klant->{opnames}->[$i]->{begin_select} = 0;
         }
         $main::klant->{opnames}->[17]->{begin_select} = 1;
         $frame->{"OPD_chk_17_Begin_Opname"}->SetValue (1);
         my $opnamedatum = $main::klant->{opnames}->[17]->{begindatum};
         my $jaar = substr ($opnamedatum,0,4 );
         my $maand = substr ($opnamedatum,4,2);
         my $dag = substr ($opnamedatum,6,2);
         $main::begindatum_opname = $opnamedatum;
         $frame->{lov_Txt_0_Begin_Opname}->SetValue($main::begindatum_opname);
        }else {
         $main::klant->{opnames}->[17]->{begin_select} = 0;
         $main::begindatum_opname = "";
         $frame->{lov_Txt_0_Begin_Opname}->SetValue($main::begindatum_opname);
        }     
    }
sub checkbox_18_Begin_clicked {
     my ($frame, $evt) = @_;
     if ($evt->IsChecked()) {
         for (my $i=0; $i < 24; $i++) {
              $frame->{"OPD_chk_$i\_Begin_Opname"}->SetValue(0);
              $main::klant->{opnames}->[$i]->{begin_select} = 0;
         }
         $main::klant->{opnames}->[18]->{begin_select} = 1;
         $frame->{"OPD_chk_18_Begin_Opname"}->SetValue (1);
         my $opnamedatum = $main::klant->{opnames}->[18]->{begindatum};
         my $jaar = substr ($opnamedatum,0,4 );
         my $maand = substr ($opnamedatum,4,2);
         my $dag = substr ($opnamedatum,6,2);
         $main::begindatum_opname = $opnamedatum;
         $frame->{lov_Txt_0_Begin_Opname}->SetValue($main::begindatum_opname);
        }else {
         $main::klant->{opnames}->[18]->{begin_select} = 0;
         $main::begindatum_opname = "";
         $frame->{lov_Txt_0_Begin_Opname}->SetValue($main::begindatum_opname);
        }     
    }
sub checkbox_19_Begin_clicked {
     my ($frame, $evt) = @_;
     if ($evt->IsChecked()) {
         for (my $i=0; $i < 24; $i++) {
              $frame->{"OPD_chk_$i\_Begin_Opname"}->SetValue(0);
              $main::klant->{opnames}->[$i]->{begin_select} = 0;
         }
         $main::klant->{opnames}->[19]->{begin_select} = 1;
         $frame->{"OPD_chk_19_Begin_Opname"}->SetValue (1);
         my $opnamedatum = $main::klant->{opnames}->[19]->{begindatum};
         my $jaar = substr ($opnamedatum,0,4 );
         my $maand = substr ($opnamedatum,4,2);
         my $dag = substr ($opnamedatum,6,2);
         $main::begindatum_opname = $opnamedatum;
         $frame->{lov_Txt_0_Begin_Opname}->SetValue($main::begindatum_opname);
        }else {
         $main::klant->{opnames}->[19]->{begin_select} = 0;
         $main::begindatum_opname = "";
         $frame->{lov_Txt_0_Begin_Opname}->SetValue($main::begindatum_opname);
        }     
    }
sub checkbox_20_Begin_clicked {
     my ($frame, $evt) = @_;
     if ($evt->IsChecked()) {
         for (my $i=0; $i < 24; $i++) {
              $frame->{"OPD_chk_$i\_Begin_Opname"}->SetValue(0);
              $main::klant->{opnames}->[$i]->{begin_select} = 0;
         }
         $main::klant->{opnames}->[20]->{begin_select} = 1;
         $frame->{"OPD_chk_20_Begin_Opname"}->SetValue (1);
         my $opnamedatum = $main::klant->{opnames}->[20]->{begindatum};
         my $jaar = substr ($opnamedatum,0,4 );
         my $maand = substr ($opnamedatum,4,2);
         my $dag = substr ($opnamedatum,6,2);
         $main::begindatum_opname = $opnamedatum;
         $frame->{lov_Txt_0_Begin_Opname}->SetValue($main::begindatum_opname);
        }else {
         $main::klant->{opnames}->[20]->{begin_select} = 0;
         $main::begindatum_opname = "";
         $frame->{lov_Txt_0_Begin_Opname}->SetValue($main::begindatum_opname);
        }     
    }
sub checkbox_21_Begin_clicked {
     my ($frame, $evt) = @_;
     if ($evt->IsChecked()) {
         for (my $i=0; $i < 24; $i++) {
              $frame->{"OPD_chk_$i\_Begin_Opname"}->SetValue(0);
              $main::klant->{opnames}->[$i]->{begin_select} = 0;
         }
         $main::klant->{opnames}->[21]->{begin_select} = 1;
         $frame->{"OPD_chk_21_Begin_Opname"}->SetValue (1);
         my $opnamedatum = $main::klant->{opnames}->[21]->{begindatum};
         my $jaar = substr ($opnamedatum,0,4 );
         my $maand = substr ($opnamedatum,4,2);
         my $dag = substr ($opnamedatum,6,2);
         $main::begindatum_opname = $opnamedatum;
         $frame->{lov_Txt_0_Begin_Opname}->SetValue($main::begindatum_opname);
        }else {
         $main::klant->{opnames}->[21]->{begin_select} = 0;
         $main::begindatum_opname = "";
         $frame->{lov_Txt_0_Begin_Opname}->SetValue($main::begindatum_opname);
        }     
    }
sub checkbox_22_Begin_clicked {
     my ($frame, $evt) = @_;
     if ($evt->IsChecked()) {
         for (my $i=0; $i < 24; $i++) {
              $frame->{"OPD_chk_$i\_Begin_Opname"}->SetValue(0);
              $main::klant->{opnames}->[$i]->{begin_select} = 0;
         }
         $main::klant->{opnames}->[22]->{begin_select} = 1;
         $frame->{"OPD_chk_22_Begin_Opname"}->SetValue (1);
         my $opnamedatum = $main::klant->{opnames}->[22]->{begindatum};
         my $jaar = substr ($opnamedatum,0,4 );
         my $maand = substr ($opnamedatum,4,2);
         my $dag = substr ($opnamedatum,6,2);
         $main::begindatum_opname = $opnamedatum;
         $frame->{lov_Txt_0_Begin_Opname}->SetValue($main::begindatum_opname);
        }else {
         $main::klant->{opnames}->[22]->{begin_select} = 0;
         $main::begindatum_opname = "";
         $frame->{lov_Txt_0_Begin_Opname}->SetValue($main::begindatum_opname);
        }     
    }
sub checkbox_23_Begin_clicked {
     my ($frame, $evt) = @_;
     if ($evt->IsChecked()) {
         for (my $i=0; $i < 24; $i++) {
              $frame->{"OPD_chk_$i\_Begin_Opname"}->SetValue(0);
              $main::klant->{opnames}->[$i]->{begin_select} = 0;
         }
         $main::klant->{opnames}->[23]->{begin_select} = 1;
         $frame->{"OPD_chk_23_Begin_Opname"}->SetValue (1);
         my $opnamedatum = $main::klant->{opnames}->[22]->{begindatum};
         my $jaar = substr ($opnamedatum,0,4 );
         my $maand = substr ($opnamedatum,4,2);
         my $dag = substr ($opnamedatum,6,2);
         $main::begindatum_opname = $opnamedatum;
         $frame->{lov_Txt_0_Begin_Opname}->SetValue($main::begindatum_opname);
        }else {
         $main::klant->{opnames}->[23]->{begin_select} = 0;
         $main::begindatum_opname = "";
         $frame->{lov_Txt_0_Begin_Opname}->SetValue($main::begindatum_opname);
        }     
    }
1;