#!/usr/bin/perl -w
use strict;

package MainFrameNotebookBoven;
     use Wx qw[:everything];
     use base qw(Wx::Frame);
     #use Data::Dumper
     use strict;
     use Wx::Locale gettext => '_T';
     sub new {
         my ($class, $frame) = @_;
         $frame->{MainFrameNotebookBoven} = Wx::Notebook->new($frame, wxID_ANY, wxDefaultPosition, wxDefaultSize, 0);
         $frame->{MainFrameNotebookBoven_pane_lov} = Wx::Panel->new($frame->{MainFrameNotebookBoven}, wxID_ANY, wxDefaultPosition, wxDefaultSize, );         
         $frame->{MainFrameNotebookBoven_pane_AZ} = Wx::Panel->new($frame->{MainFrameNotebookBoven}, wxID_ANY, wxDefaultPosition, wxDefaultSize, );        
         $frame->{MainFrameNotebookBoven_pane_BA_EZ} = Wx::Panel->new($frame->{MainFrameNotebookBoven}, wxID_ANY, wxDefaultPosition, wxDefaultSize, );
         $frame->{MainFrameNotebookBoven_pane_EZ} = Wx::Panel->new($frame->{MainFrameNotebookBoven}, wxID_ANY, wxDefaultPosition, wxDefaultSize, );
         $frame->{MainFrameNotebookBoven_pane_OPD} = Wx::Panel->new($frame->{MainFrameNotebookBoven}, wxID_ANY, wxDefaultPosition, wxDefaultSize, );
         $frame->{MainFrameNotebookBoven_pane_CT} = Wx::Panel->new($frame->{MainFrameNotebookBoven}, wxID_ANY, wxDefaultPosition, wxDefaultSize, );   
         $frame->{MainFrameNotebookBoven_pane_GKD} = Wx::Panel->new($frame->{MainFrameNotebookBoven}, wxID_ANY, wxDefaultPosition, wxDefaultSize, );        
         $frame->{MainFrameNotebookBoven}->AddPage($frame->{MainFrameNotebookBoven_pane_lov}, _T("Lid, Opname, Verzekering"));
         $frame->{MainFrameNotebookBoven}->AddPage($frame->{MainFrameNotebookBoven_pane_AZ}, _T("Assurcard, Ziekenfonds"));
         $frame->{MainFrameNotebookBoven}->AddPage($frame->{MainFrameNotebookBoven_pane_BA_EZ}, _T("Bestaande Aandoening"));
         $frame->{MainFrameNotebookBoven}->AddPage($frame->{MainFrameNotebookBoven_pane_EZ}, _T("Ernstige Ziekten"));
         $frame->{MainFrameNotebookBoven}->AddPage($frame->{MainFrameNotebookBoven_pane_OPD}, _T("Opname Data"));
         $frame->{MainFrameNotebookBoven}->AddPage($frame->{MainFrameNotebookBoven_pane_CT}, _T("Commentaar"));
         $frame->{MainFrameNotebookBoven}->AddPage($frame->{MainFrameNotebookBoven_pane_GKD}, _T("GKD"));
         #$frame->{MainFrameNotebookBoven}->AddPage($frame->{MainFrameNotebookBoven_pane_brieven}, _T("Brieven Maken"));
         my $frame1 = Lid_Opname_Verzekering->new($frame);
         my $frame2 = Assurcard_Ziekenfonds->new($frame);       
         my $frame3 = BestaandeAandoening_ErnstigeZiekte->new($frame);
         my $frame4 = ErnstigeZiekte->new($frame);
         my $frame5 = OpnameData->new($frame);
         my $frame6 = Commentaar_tab->new($frame);
         my $frame7 = gkd_tab->new($frame);
         #my $frame8 = OO_brieven->new($frame);
         $frame->{MainFrameNotebookBoven}->SetBackgroundColour(Wx::Colour->new(204, 204, 255));
         #$frame->{MainFrameNotebookBoven}->SetBackgroundColour(Wx::Colour->new(239, 243, 255)); #licht grijs
         #$frame->{MainFrameNotebookBoven_pane_lov}->SetBackgroundColour(Wx::Colour->new(239, 243, 255));
         #$frame->{MainFrameNotebookBoven_pane_AZ}->SetBackgroundColour(Wx::Colour->new(239, 200, 200));
         #$frame->{MainFrameNotebookBoven_pane_BA_EZ}->SetBackgroundColour(Wx::Colour->new(239, 180, 180));
         #$frame->{MainFrameNotebookBoven_pane_EZ}->SetBackgroundColour(Wx::Colour->new(239, 150, 150));
         #$frame->{MainFrameNotebookBoven_pane_OPD}->SetBackgroundColour(Wx::Colour->new(239, 130, 130));
         #$frame->{MainFrameNotebookBoven_pane_CT}->SetBackgroundColour(Wx::Colour->new(239, 110, 110));
         #$frame->{MainFrameNotebookBoven_pane_GKD}->SetBackgroundColour(Wx::Colour->new(239, 90, 90));
         return ($frame);
        }
1;
