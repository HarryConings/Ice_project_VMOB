#!/usr/bin/perl -w
use strict;
use Win32::GuiTest qw(PushButton FindWindowLike SetForegroundWindow SendKeys SendMouse WaitWindow IsWindow IsKeyPressed);
my $teller = 0;
my $naarvoor =0;
my  @windows = FindWindowLike(undef,"MOBICOON Milestone 6");  #zoek het mobicoon venster
until ($teller > 20) {
     if (@windows and $naarvoor == 0) {
         SetForegroundWindow($windows[0]);
         $naarvoor =1;
         $teller = 21;
        }elsif ($naarvoor == 0 and !@windows)  {
         sleep 1;
         @windows = FindWindowLike(undef,"MOBICOON Milestone 6");
         $teller +=1;
         print " $teller ..";
        }
    }


print "";
