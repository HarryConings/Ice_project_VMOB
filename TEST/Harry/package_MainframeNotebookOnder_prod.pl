#!/usr/bin/perl -w
use strict;


package MainFrameNotebookOnder;
     use Wx qw[:everything];
     use base qw(Wx::Frame);
     #use Data::Dumper
     use strict;
     use Wx::Locale gettext => '_T';
    
     sub new {
         my ($class, $frame) = @_;
         $frame->{MainframeNotebookOnder} = Wx::Notebook->new($frame, wxID_ANY, wxDefaultPosition, wxDefaultSize, 0);
         $frame->{MainframeNotebookOnder_pane_Overzicht} = Wx::Panel->new($frame->{MainframeNotebookOnder}, wxID_ANY, wxDefaultPosition, wxDefaultSize, );
         #$frame->{MainframeNotebookOnder_pane_Detail} = Wx::Panel->new($frame->{MainframeNotebookOnder}, wxID_ANY, wxDefaultPosition, wxDefaultSize, );
         $frame->{MainframeNotebookOnder}->AddPage($frame->{MainframeNotebookOnder_pane_Overzicht}, _T("Overzicht"));
         my $teller=1;
         foreach my $nom_clatuur (@main::nomenclaturen) {
             $main::page_nr{"$nom_clatuur"} = $teller;
             $teller +=1;
             #print "MainframeNotebookOnder_pane_Detail$nom_clatuur\n";
             if ($nom_clatuur != 9999999) { #totaal =999999
                 $frame->{"MainframeNotebookOnder_pane_Detail$nom_clatuur"} = Wx::Panel->new($frame->{MainframeNotebookOnder}, wxID_ANY, wxDefaultPosition, wxDefaultSize, );
                 $frame->{MainframeNotebookOnder}->AddPage($frame->{"MainframeNotebookOnder_pane_Detail$nom_clatuur"}, _T("$nom_clatuur"));#code
             }
             
             
            }
         $frame->{MainframeNotebookOnder}->SetBackgroundColour(Wx::Colour->new(239, 243, 255));
         my $test = $frame->{MainframeNotebookOnder}->GetSelection();
         #my $test1 = $frame->{MainframeNotebookOnder}->ChangeSelection(2);
         #$test = $frame->{MainframeNotebookOnder}->GetSelection();
         return ($class, $frame);
        }
     sub change_tab {
         my ($class,$nomenclatuur) =  @_ ;
         my $page = $main::page_nr{"$nomenclatuur"};
         my $test1 = $main::frame->{MainframeNotebookOnder}->ChangeSelection($page);
       
         print"";
     }
     sub delete_all_pages {
         my ($class) =  @_ ;
         my $bool = $main::frame->{MainframeNotebookOnder}->DeleteAllPages();
         print"";
     }
     sub refresh {
         my ($class, $frame) = @_;
         $frame->{MainframeNotebookOnder_pane_Overzicht} = Wx::Panel->new($frame->{MainframeNotebookOnder}, wxID_ANY, wxDefaultPosition, wxDefaultSize, );
         #$frame->{MainframeNotebookOnder_pane_Detail} = Wx::Panel->new($frame->{MainframeNotebookOnder}, wxID_ANY, wxDefaultPosition, wxDefaultSize, );
         $frame->{MainframeNotebookOnder}->AddPage($frame->{MainframeNotebookOnder_pane_Overzicht}, _T("Overzicht"));
         my $teller=1;
         foreach my $nom_clatuur (@main::nomenclaturen) {
             $main::page_nr{"$nom_clatuur"} = $teller;
             $teller +=1;
             #print "MainframeNotebookOnder_pane_Detail$nom_clatuur\n";
             if ($nom_clatuur != 9999999) { #totaal =999999
                 $frame->{"MainframeNotebookOnder_pane_Detail$nom_clatuur"} = Wx::Panel->new($frame->{MainframeNotebookOnder}, wxID_ANY, wxDefaultPosition, wxDefaultSize, );
                 $frame->{MainframeNotebookOnder}->AddPage($frame->{"MainframeNotebookOnder_pane_Detail$nom_clatuur"}, _T("$nom_clatuur"));#code
             }
             
             
            }
         $frame->{MainframeNotebookOnder}->SetBackgroundColour(Wx::Colour->new(239, 243, 255));
         #my $test = $frame->{MainframeNotebookOnder}->GetSelection();
         #my $test1 = $frame->{MainframeNotebookOnder}->ChangeSelection(2);
         #$test = $frame->{MainframeNotebookOnder}->GetSelection();
         return ($class, $frame);
     }
1;