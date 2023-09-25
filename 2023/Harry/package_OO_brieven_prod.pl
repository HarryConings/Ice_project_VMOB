#!/usr/bin/perl -w
use strict;

package OO_brieven;

use Wx qw[:everything];
use base qw(Wx::Frame);
#use Data::Dumper
use strict;
use Wx::Locale gettext => '_T';
use Wx::Event qw(EVT_CHECKBOX);
use Wx::Event qw(EVT_MENU EVT_CLOSE);
use Wx::FS;
use DateTime::Format::Strptime;
use DateTime;
sub new {
     my ($class, $frame) = @_;
     $frame->{brieven_sizer_1} = Wx::FlexGridSizer->new(4,9, 10, 10);
     $frame->{brieven_Button_MaakBrieven}  = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_brieven}, -1, _T("Kies een Verzekering en maak een Brief"),wxDefaultPosition,wxSIZE(250,20));
     $frame->{brieven_Button_Verzekering}  = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_brieven}, -1, _T("Verzekering"),wxDefaultPosition,wxSIZE(200,20));
     $frame->{brieven_Button_Begin}  = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_brieven}, -1, _T("Begin"),wxDefaultPosition,wxSIZE(80,20));
     $frame->{brieven_Button_Eind}  = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_brieven}, -1, _T("Eind"),wxDefaultPosition,wxSIZE(80,20));
     $frame->{brieven_Button_Wacht}  = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_brieven}, -1, _T("Wacht"),wxDefaultPosition,wxSIZE(80,20));
     $frame->{brieven_Button_ZKF}  = Wx::Button->new($frame->{MainFrameNotebookBoven_pane_brieven}, -1, _T("ZKF/GKD"),wxDefaultPosition,wxSIZE(50,20));
     $frame->{brieven_Txt_0_contracten_naam}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_brieven}, -1,$main::klant->{contracten}->[0]->{naam},wxDefaultPosition,wxSIZE(200,20));
     $frame->{brieven_Txt_0_contracten_startdatum}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_brieven}, -1,$main::klant->{contracten}->[0]->{startdatum},wxDefaultPosition,wxSIZE(80,20));
     $frame->{brieven_Txt_0_contracten_einddatum}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_brieven}, -1,$main::klant->{contracten}->[0]->{einddatum},wxDefaultPosition,wxSIZE(80,20));
     $frame->{brieven_Txt_1_contracten_naam}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_brieven}, -1,$main::klant->{contracten}->[1]->{naam},wxDefaultPosition,wxSIZE(200,20));
     $frame->{brieven_Txt_1_contracten_startdatum}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_brieven}, -1,$main::klant->{contracten}->[1]->{startdatum},wxDefaultPosition,wxSIZE(80,20));
     $frame->{brieven_Txt_1_contracten_einddatum}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_brieven}, -1,$main::klant->{contracten}->[1]->{einddatum},wxDefaultPosition,wxSIZE(80,20));
     $frame->{brieven_Txt_2_contracten_naam}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_brieven}, -1,$main::klant->{contracten}->[2]->{naam},wxDefaultPosition,wxSIZE(200,20));
     $frame->{brieven_Txt_2_contracten_startdatum}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_brieven}, -1,$main::klant->{contracten}->[2]->{startdatum},wxDefaultPosition,wxSIZE(80,20));
     $frame->{brieven_Txt_2_contracten_einddatum}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_brieven}, -1,$main::klant->{contracten}->[2]->{einddatum},wxDefaultPosition,wxSIZE(80,20));
     $frame->{brieven_Txt_0_contracten_wachtdatum}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_brieven}, -1,$main::klant->{contracten}->[0]->{wachtdatum},wxDefaultPosition,wxSIZE(80,20));
     $frame->{brieven_Txt_1_contracten_wachtdatum}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_brieven}, -1,$main::klant->{contracten}->[1]->{wachtdatum},wxDefaultPosition,wxSIZE(80,20));
     $frame->{brieven_Txt_2_contracten_wachtdatum}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_brieven}, -1,$main::klant->{contracten}->[2]->{wachtdatum},wxDefaultPosition,wxSIZE(80,20));
     $frame->{brieven_Txt_0_contracten_zkfnr}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_brieven}, -1,$main::klant->{contracten}->[0]->{zkf_nr},wxDefaultPosition,wxSIZE(50,20));
     $frame->{brieven_Txt_1_contracten_zkfnr}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_brieven}, -1,$main::klant->{contracten}->[1]->{zkf_nr},wxDefaultPosition,wxSIZE(50,20));
     $frame->{brieven_Txt_2_contracten_zkfnr}  = Wx::TextCtrl->new($frame->{MainFrameNotebookBoven_pane_brieven}, -1,$main::klant->{contracten}->[2]->{zkf_nr},wxDefaultPosition,wxSIZE(50,20));
     $frame->{brieven_chk_0_Contract}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_brieven}, -1,$main::contracts_check[0],wxDefaultPosition,wxSIZE(15,20));
     $frame->{brieven_chk_1_Contract}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_brieven}, -1,$main::contracts_check[1],wxDefaultPosition,wxSIZE(15,20));
     $frame->{brieven_chk_2_Contract}  = Wx::CheckBox->new($frame->{MainFrameNotebookBoven_pane_brieven}, -1,$main::contracts_check[2],wxDefaultPosition,wxSIZE(15,20));
     #RIJ1  1+2+3+4+5+6+7
     $frame->{brieven_panel_1} = Wx::Panel->new($frame->{MainFrameNotebookBoven_pane_brieven},-1,wxDefaultPosition,wxSIZE(20,20));
     $frame->{brieven_panel_2} = Wx::Panel->new($frame->{MainFrameNotebookBoven_pane_brieven},-1,wxDefaultPosition,wxSIZE(250,20));
     $frame->{brieven_sizer_1}->Add($frame->{brieven_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{brieven_sizer_1}->Add($frame->{brieven_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{brieven_sizer_1}->Add($frame->{brieven_Button_Verzekering}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{brieven_sizer_1}->Add($frame->{brieven_Button_Begin}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{brieven_sizer_1}->Add($frame->{brieven_Button_Eind}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{brieven_sizer_1}->Add($frame->{brieven_Button_Wacht}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{brieven_sizer_1}->Add($frame->{brieven_Button_ZKF}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{brieven_sizer_1}->Add($frame->{brieven_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{brieven_sizer_1}->Add($frame->{brieven_panel_2}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     #RIJ2  1+2+3+4+5
     $frame->{brieven_sizer_1}->Add($frame->{brieven_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{brieven_sizer_1}->Add($frame->{brieven_chk_0_Contract}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{brieven_sizer_1}->Add($frame->{brieven_Txt_0_contracten_naam}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{brieven_sizer_1}->Add($frame->{brieven_Txt_0_contracten_startdatum}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{brieven_sizer_1}->Add($frame->{brieven_Txt_0_contracten_einddatum}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{brieven_sizer_1}->Add($frame->{brieven_Txt_0_contracten_wachtdatum}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{brieven_sizer_1}->Add($frame->{brieven_Txt_0_contracten_zkfnr}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{brieven_sizer_1}->Add($frame->{brieven_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{brieven_sizer_1}->Add($frame->{brieven_panel_2}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     #RIJ3  1+2+3+4+5
     $frame->{brieven_sizer_1}->Add($frame->{brieven_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{brieven_sizer_1}->Add($frame->{brieven_chk_1_Contract}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{brieven_sizer_1}->Add($frame->{brieven_Txt_1_contracten_naam}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{brieven_sizer_1}->Add($frame->{brieven_Txt_1_contracten_startdatum}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{brieven_sizer_1}->Add($frame->{brieven_Txt_1_contracten_einddatum}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{brieven_sizer_1}->Add($frame->{brieven_Txt_1_contracten_wachtdatum}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{brieven_sizer_1}->Add($frame->{brieven_Txt_1_contracten_zkfnr}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{brieven_sizer_1}->Add($frame->{brieven_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{brieven_sizer_1}->Add($frame->{brieven_Button_MaakBrieven}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     #RIJ4  1+2+3+4+5
     $frame->{brieven_sizer_1}->Add($frame->{brieven_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{brieven_sizer_1}->Add($frame->{brieven_chk_2_Contract}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{brieven_sizer_1}->Add($frame->{brieven_Txt_2_contracten_naam}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{brieven_sizer_1}->Add($frame->{brieven_Txt_2_contracten_startdatum}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{brieven_sizer_1}->Add($frame->{brieven_Txt_2_contracten_einddatum}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{brieven_sizer_1}->Add($frame->{brieven_Txt_2_contracten_wachtdatum}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{brieven_sizer_1}->Add($frame->{brieven_Txt_2_contracten_zkfnr}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{brieven_sizer_1}->Add($frame->{brieven_panel_1}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     $frame->{brieven_sizer_1}->Add($frame->{brieven_panel_2}, 0, wxALIGN_BOTTOM|wxALIGN_RIGHT);
     
      Wx::Event::EVT_BUTTON($frame,$frame->{brieven_Button_MaakBrieven},\&Maak_Brief);
      Wx::Event::EVT_CHECKBOX($frame,$frame->{brieven_chk_0_Contract}, \&checkbox_0_Contract_clicked);
      Wx::Event::EVT_CHECKBOX($frame,$frame->{brieven_chk_1_Contract}, \&checkbox_1_Contract_clicked);
      Wx::Event::EVT_CHECKBOX($frame,$frame->{brieven_chk_2_Contract}, \&checkbox_2_Contract_clicked);
    }
sub checkbox_0_Contract_clicked {
     my ($frame, $evt) = @_;
     if ($evt->IsChecked()) {
         for (my $i=0; $i < 4; $i++) {
              $frame->{"brieven_chk_$i\_Contract"}->SetValue(0);
              $main::contracts_brieven_check[$i] = 0;
         }
         $main::contracts_brieven_check[0] = 1;
         $frame->{"brieven_chk_0_Contract"}->SetValue (1);
         
        }else {
          for (my $i=0; $i < 4; $i++) {
              $frame->{"brieven_chk_$i\_Contract"}->SetValue(0);
              $main::contracts_brieven_check[$i] = 0;
            }
        }
     
    }
sub checkbox_1_Contract_clicked {
     my ($frame, $evt) = @_;
     if ($evt->IsChecked()) {
         for (my $i=0; $i < 3; $i++) {
              $frame->{"brieven_chk_$i\_Contract"}->SetValue(0);
              $main::contracts_brieven_check[$i] = 0;
         }
         $main::contracts_brieven_check[1] = 1;
         $frame->{"brieven_chk_1_Contract"}->SetValue (1);
         
        }else {
          for (my $i=0; $i < 3; $i++) {
              $frame->{"brieven_chk_$i\_Contract"}->SetValue(0);
              $main::contracts_brieven_check[$i] = 0;
            }
        }     
    }
sub checkbox_2_Contract_clicked {
     my ($frame, $evt) = @_;
     if ($evt->IsChecked()) {
         for (my $i=0; $i < 3; $i++) {
              $frame->{"brieven_chk_$i\_Contract"}->SetValue(0);
              $main::contracts_brieven_check[$i] = 0;
         }
         $main::contracts_brieven_check[2] = 1;
         $frame->{"brieven_chk_2_Contract"}->SetValue (1);
         
        }else {
          for (my $i=0; $i < 3; $i++) {
              $frame->{"brieven_chk_$i\_Contract"}->SetValue(0);
              $main::contracts_brieven_check[$i] = 0;
            }
        }     
    }
sub Maak_Brief {
     my ($frame) = @_;
     my $ext_nr = $main::klant->{ExternNummer};
     my $rrn_nr = $main::klant->{Rijksreg_Nr};
     my $zkf = $main::klant->{Ziekenfonds};
     my @test = @main::contracts_brieven_check;
     if (!defined $ext_nr or !defined $zkf) {
         Wx::MessageBox( _T("Je moet een persoon opzoeken\nom een brief te maken !"), 
              _T("Brieven Maken"), 
              wxOK|wxCENTRE, 
             $frame
            );
        }else {
         my $volgnr_contract = '';
         for (my $i=0; $i < 3; $i++) {
             my $is_checked = $main::contracts_brieven_check[$i];
             $volgnr_contract = $i if ($is_checked == 1);   
            }
         if ($volgnr_contract eq '') {
             Wx::MessageBox( _T("Gelieve een verzekering te kiezen"), 
                 _T("Brieven Maken"), 
                 wxOK|wxCENTRE, 
                 $frame
                );
            }else {
             # Open a filedialog where a file can be opened
             my $naam_contract = $main::klant->{contracten}->[$volgnr_contract]->{naam};
             my $wachtdatum = $main::klant->{contracten}->[$volgnr_contract]->{wachtdatum};
             my $filedlg = Wx::FileDialog->new(  $frame,         # parent
                                        'Open File',   # Caption
                                        '',            # Default directory
                                        '',            # Default file
                                        "Openoffice (*.od)|*.od*", # wildcard
                                        wxFD_OPEN);        # style
             # If the user really selected one
             if ($filedlg->ShowModal==wxID_OK)   {
                 my $filename = $filedlg->GetPath;
                 maak_brief->maak_oodoc_variabelen($ext_nr,$rrn_nr,$zkf,$naam_contract,$wachtdatum,$filename);
                 print "";
                 # do something useful
                }
            }
        }
     
    }
1;