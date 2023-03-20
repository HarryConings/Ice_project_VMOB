#!/usr/bin/perl -w
#use strict;
#use Net::SFTP::Foreign;
#use Net::SSH::Any;
#use Net::FTP;
use File::Copy;
use Date::Manip;
use Win32::OLE;
use Win32::OLE::Const;
use Win32::OLE::Variant;
use File::Basename;
use File::Path qw( make_path );
use File::Copy;
our $vandaag = ParseDate("today");
print "Begin: $vandaag\n";
$vandaag = substr($vandaag,0,8);
$jaarmaand  = substr($vandaag,0,6);
our $host = "193.104.8.155";
our $user = "hplftp742";
our $password = 'tai4Thech5baifei';
our $local_dir = 'P:\OGV\ASSURCARD_SFTP';
our $local_dir_upload_backup="$local_dir\\backup_upload";
#
#203
our $ftp_dir_Forgotten = "/Hplftp742/Forgotten";
our $ftp_dir_Hospitalisations = "/Hplftp742/Hospitalisations";
our $ftp_dir_Invoices = '/Hplftp742/Invoices';
our $ftp_dir_medForm = "/Hplftp742/medForm";
our $ftp_dir_Reporting = "/Hplftp742/Reporting";
our $ftp_dir_Updates = "/Hplftp742/Updates";
our $ftp_dir_upload= "/Hplftp742/upload";
our $ftp_dir_upload_InError= "/Hplftp742/upload.InError";
our $ftp_dir_upload_processed= "/Hplftp742/upload.processed";
our $ftp_dir_upload_toModify= "/Hplftp742/upload.toModify";


our $local_dir_Forgotten = "$local_dir\\Forgotten";
our $local_dir_Hospitalisations = "$local_dir\\Hospitalisations";
our $local_dir_Invoices = "$local_dir\\Invoices";
our $local_dir_medForm = "$local_dir\\medForm";
our $local_dir_Reporting = "$local_dir\\Reporting";
our $local_dir_Updates = "$local_dir\\/Updates";
our $local_dir_upload= "$local_dir\\upload";
our $local_dir_upload_InError= "$local_dir\\upload.InError";
our $local_dir_upload_processed= "$local_dir\\upload.processed";
our $local_dir_upload_toModify= "$local_dir\\upload.toModify";
our $local_dir_Archive = "$local_dir\\Archive";
#setup sftp
Win32::OLE->Initialize(Win32::OLE::COINIT_OLEINITIALIZE);
use constant
{
    TRUE  => Variant(VT_BOOL, 1),
    FALSE => Variant(VT_BOOL, 0)
};
my $session = Win32::OLE->new('WinSCP.Session'); 
my $consts = Win32::OLE::Const->Load($session); 
my $sessionOptions = Win32::OLE->new('WinSCP.SessionOptions'); 
$sessionOptions->{'Protocol'} = $consts->{'Protocol_Sftp'};
$sessionOptions->{'HostName'} = $host;
$sessionOptions->{'UserName'} = $user;
$sessionOptions->{'Password'} = $password;
$sessionOptions->{'SshHostKeyFingerprint'} = "ssh-ed25519 255 f7oWFd9z3+Df+CAHp7eS+qX7yL3Wb7Fu1W6Y7xhgsfA=";
$session->Open( $sessionOptions);
my $transferOptions = Win32::OLE->new('WinSCP.TransferOptions');
$transferOptions->{'TransferMode'} = $consts->{'TransferMode_Binary'};


  print "Connected\n";
  print "\n GET FILES !!\n";
  #203  
  my $ok = &getfiles ($local_dir_Invoices,$ftp_dir_Invoices,$session,$transferOptions);
  print "ok ->$ok $ftp_dir_Invoices -> $local_dir_Invoices\n";
                                    #&move_archive_files ($local_dir_Invoices, $local_dir_Archive);
                                    #$ok = &getfiles ($local_dir_Forgotten,$ftp_dir_Forgotten);
                                    #print "ok ->$ok ,$ftp_dir_Forgotten-> $local_dir_Forgotten\n";
                                    #$ok = &getfiles ($local_dir_Reporting,$ftp_dir_Reporting);
                                    #print "ok ->$ok ,$ftp_dir_Reporting-> $local_dir_Reporting\n";
                                    #$ok = &getfiles ($local_dir_upload_InError,$ftp_dir_upload_InError);
                                    #print "ok ->$ok ,$ftp_dir_upload_InError-> $local_dir_upload_InError\n";
                                     #$ok = &getfiles ($local_dir_upload_processed,$ftp_dir_upload_processed);
                                    #print "ok ->$ok ,$ftp_dir_upload_processed-> $local_dir_upload_processed\n";
  $ok = &getfiles ($local_dir_upload_toModify,$ftp_dir_upload_toModify,$session,$transferOptions);
  print "ok ->$ok ,$ftp_dir_upload_toModify-> $local_dir_upload_toModify\n";
  $ok = &getfiles ($local_dir_Hospitalisations,$ftp_dir_Hospitalisations,$session,$transferOptions);
  print "ok ->$ok ,$ftp_dir_Hospitalisations-> $local_dir_Hospitalisations\n";
  print "\n GET GEDAAN \n";
  print "\n PUT FILES \n";
  $ok = &putfiles ($local_dir_upload,$ftp_dir_upload,$session,$transferOptions);
  print "\nputfiles ok = $ok ($local_dir_upload -> $ftp_dir_upload\n";
  
  #
$vandaag = ParseDate("today");
print "Einde $vandaag\n"; 
print "Einde\n";
#put the files naar assurcard
sub putfiles {
    my $directory_local = shift @_;
    my $directory_remote = shift @_;
    my $session = shift @_;
    my $transferOptions = shift @_;
    my $error_put = 0;
    my $transferResult = $session->PutFiles("$directory_local\\*.xml", "$directory_remote/", FALSE, $transferOptions);
    $error_put = $transferResult->Check();
    my $items = Win32::OLE::Enum->new($transferResult->{'Transfers'});
    my $item;
    while (defined($item = $items->Next))
    {
        print $item->{'FileName'} . "\n";
        my $sftpfile = $item->{'FileName'};
        my $sftpfile_basename = basename($sftpfile);
        my $backupdir = "P:\\OGV\\ASSURCARD_SFTP\\backup_upload\\$vandaag";
        if (-d $backupdir) {
            move("$directory_local\\$sftpfile_basename","$backupdir\\$sftpfile_basename");            
        }else {
            make_path($backupdir);
            move("$directory_local\\$sftpfile_basename","$backupdir\\$sftpfile_basename"); 
        }        
    }
    return ($error_put);    
}
##get de files van assurcard
sub getfiles {
    my $directory_local = shift @_;
    my $directory_remote = shift @_;
    my $session  = shift @_;
    my $transferOptions = shift @_; 
    my $error_get = 0;
    print "remotev $directory_remote\n";
    my $transferResult = $session->GetFiles("$directory_remote/*", "$directory_local\\", FALSE, $transferOptions);
    $error_get = $transferResult->Check();
    my $items = Win32::OLE::Enum->new($transferResult->{'Transfers'});
    my $item;
    while (defined($item = $items->Next))
    {
        print $item->{'FileName'} . "\n";
        my $sftpfile = $item->{'FileName'};
        my $sftpfile_basename = basename($sftpfile);
        if (-e "$directory_local\\$sftpfile_basename") {          
            my $deleteResult = $session->RemoveFiles($sftpfile);
        }
    }
return ($error_get);
}
##maak een backup directory aan

##verplaats files 
sub movefiles {
     my $directory_local = shift @_;
     my $directory_old = shift @_;
     print " $directory_local oud $directory_old\n";
     #my @files = <$directory_local/*>;
     opendir(DIR,$directory_local);
     my @files = grep(/\.xml$/,readdir(DIR));
     my $error_put = 0;
     foreach my $file_name (@files) {
         print "file verpl $directory_local/$file_name\n";
         my $file_short_name = $file_name;
         $file_short_name =~ s%$directory_local/%%;
         print "file short verpl $file_short_name\n";
         move("$directory_local/$file_name","$directory_old/$file_short_name");
        }
    }
sub move_archive_files {
   my $search_dir = shift @_;
   my $archive_dir = shift @_;
   print "[archive] files from  $search_dir to $archive_dir\n";
   opendir(DIR,$search_dir);
   my @files = grep(/^\[archive\]/,readdir(DIR));
   foreach my $file_name (@files) {
      #print "file $search_dir/$file_name\n";
      my $file_short_name = $file_name;
      $file_short_name =~ s%$$search_dir/%%;
      #print "file short verpl $file_short_name\n";
      move("$search_dir/$file_name","$archive_dir/$file_short_name");
      print "move $search_dir/$file_name to $archive_dir/$file_short_name\n";
    }
   
}
sub deleteverwerktefiles {
      my $directory_local = shift @_;

}
#   
sub session_Events()
{
    my ($obj, $event, @args) = @_;
    print "event\n";
    #given ($event)
    #{
    #    when ('FileTransferred')
    #    {
    #        my ($sender, $e) = @args;
    #        printf "%s => %s\n", ( $e->{'FileName'}, $e->{'Destination'} );
    #    }
    #}
}

