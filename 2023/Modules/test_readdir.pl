#!/usr/bin/perl -w
use strict;
use Net::SMTP;
use Date::Manip::DM5 ;
use Date::Calc qw(:all);
use utf8;
use Text::Unidecode;
our $mail = "VERSLAG KLANTENSYNCHRONISATE MET AGRESSO TEST\n-----------------------------------------\n\n";
our $aantal_blokken = 0;
our $file_agresso = "\\\\S200WP1XXL01.mutworld.be\\AgressoFiles235\\VMOB\\Data Import\\Klanten" ;
our $vandaag = ParseDate("today");
$vandaag = substr ($vandaag,0,8);
#&zoek_verzekeringen;
opendir my $dir, $file_agresso or &error_unc_not_open  ;
my @files_unc = readdir $dir;
$mail = "$mail.\nFiles in Agresso\n____________________\n@files_unc\n";
&mail_bericht;
sub error_unc_not_open {
     $mail = "$mail.\n !!!!!!!!!!!!!!\n Kan $file_agresso niet openen !!!!!!!!!!!!!!!!!!!!!!";
     &mail_bericht;
}
sub mail_bericht {
     #print "mail-start\n";
     my $aan = "harry\@ice.be,jeroencoenaerts\@hospiplus.be";
     my @aan_lijst = split (/\,/,$aan);
     my $van = 'harry.conings@vnz.be';
     my $vandaag = ParseDate("today");
     $vandaag = substr ($vandaag,0,8);  # vandaag in YYYYMMDD
     $vandaag = sprintf "%04d-%02d-%02d",substr ($vandaag,0,4),substr ($vandaag,4,2),substr ($vandaag,6,2);
     foreach my $geadresseerde (@aan_lijst) {
         my $smtp = Net::SMTP->new('mailservices.m-team.be',
                    Hello => 'mail.vnz.be',
                    Timeout => 60);
         #$smtp->auth('mailprogrammas','pleintje203');
         $smtp->mail($van);
         $smtp->to($geadresseerde);
         #$smtp->cc('informatica.mail@vnz.be');
         #$smtp->bcc("bar@blah.net");
         $smtp->data;
         $smtp->datasend("From: harry.conings");
         $smtp->datasend("\n");
         $smtp->datasend("To: Kaartbeheerders");
         $smtp->datasend("\n");
         $smtp->datasend("Subject: Agresso klanten synchronisatie $vandaag");
         $smtp->datasend("\n");
         $smtp->datasend("$mail\nvriendelijke groeten\nHarry Conings");
         $smtp->dataend;
         $smtp->quit;
         print "mail aan $geadresseerde  gezonden\n";
        }
    }
1;