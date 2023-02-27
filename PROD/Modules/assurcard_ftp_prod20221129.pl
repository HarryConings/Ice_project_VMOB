#!/usr/bin/perl -w
#use strict;
use Net::FTP;
use File::Copy;
use Date::Manip;
our $vandaag = ParseDate("today");
print "Begin: $vandaag\n";
$vandaag = substr($vandaag,0,8);
our $host = "193.104.8.155";
our $user = "hplftp742";
our $password = '2fc32uHp';
our $local_dir_upload_backup="/home/assurcard/assurcard/backup_upload";
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


our $local_dir_Forgotten = "/home/assurcard/assurcard/Forgotten";
our $local_dir_Hospitalisations = "/home/assurcard/assurcard/Hospitalisations";
our $local_dir_Invoices = "/home/assurcard/assurcard/Invoices";
our $local_dir_medForm = "/home/assurcard/assurcard/medForm";
our $local_dir_Reporting = "/home/assurcard/assurcard/Reporting";
our $local_dir_Updates = "/home/assurcard/assurcard//Updates";
our $local_dir_upload= "/home/assurcard/assurcard//upload";
our $local_dir_upload_InError= "/home/assurcard/assurcard/upload.InError";
our $local_dir_upload_processed= "/home/assurcard/assurcard/upload.processed";
our $local_dir_upload_toModify= "/home/assurcard/assurcard/upload.toModify";
our $local_dir_Archive = "/home/assurcard/assurcard/Archive";
#setup ftp

my $ftp = Net::FTP->new("$host", Debug => 1) or die "Cannot connect to some.host.name: $@";
$ftp->login("$user","$password") or die "Cannot login ", $ftp->message;
$ftp->binary();
$ftp->pasv;
  print "Connected\n";
  print "\n GET FILES !!\n";
  #203
  #$ok = &putfiles ($sftpdir203_local_out,$sftpdir203_out);
  my $ok = &getfiles ($local_dir_Invoices,$ftp_dir_Invoices);
  print "ok ->$ok $ftp_dir_Invoices -> $local_dir_Invoices\n";
  &move_archive_files ($local_dir_Invoices, $local_dir_Archive);
  #$ok = &getfiles ($local_dir_Forgotten,$ftp_dir_Forgotten);
  #print "ok ->$ok ,$ftp_dir_Forgotten-> $local_dir_Forgotten\n";
  #$ok = &getfiles ($local_dir_Reporting,$ftp_dir_Reporting);
  #print "ok ->$ok ,$ftp_dir_Reporting-> $local_dir_Reporting\n";
  #$ok = &getfiles ($local_dir_upload_InError,$ftp_dir_upload_InError);
  #print "ok ->$ok ,$ftp_dir_upload_InError-> $local_dir_upload_InError\n";
   #$ok = &getfiles ($local_dir_upload_processed,$ftp_dir_upload_processed);
  #print "ok ->$ok ,$ftp_dir_upload_processed-> $local_dir_upload_processed\n";
   $ok = &getfiles ($local_dir_upload_toModify,$ftp_dir_upload_toModify);
  print "ok ->$ok ,$ftp_dir_upload_toModify-> $local_dir_upload_toModify\n";
   $ok = &getfiles ($local_dir_Hospitalisations,$ftp_dir_Hospitalisations);
  print "ok ->$ok ,$ftp_dir_Hospitalisations-> $local_dir_Hospitalisations\n";
  print "\n GET GEDAAN \n";
  print "\n PUT FILES \n";
  $ok = &putfiles ($local_dir_upload,$ftp_dir_upload);
  print "\nputfiles ok = $ok ($local_dir_upload -> $ftp_dir_upload\n";
  if ($ok == 0) {
   &createdir ("$local_dir_upload_backup/$vandaag");
   &movefiles ($local_dir_upload,"$local_dir_upload_backup/$vandaag");
  }
  #
$vandaag = ParseDate("today");
print "Einde $vandaag\n"; 
print "Einde\n";
#put the files naar assurcard
sub putfiles {
 my $directory_local = shift @_;
 my $directory_remote = shift @_;
 #my @files = <$directory_local/*>;
 opendir(DIR,$directory_local);
 my @files = grep(/\.xml$/,readdir(DIR));
 my $file_name="";
 my $file_short_name ="";
 my $error_put = 0;
 foreach $file_name (@files) {
   print "file $file_name\n$directory_local/$file_name";
   $file_short_name = $file_name;
   $file_short_name =~ s%$directory_local/%%;
   print "file short $file_short_name\n";
   if (!$ftp -> put("$directory_local/$file_name","$directory_remote/$file_short_name")) {
    print "Failed to Transfer: ".$ftp->error;
    $error_put = 1;
   }else { 
    print "$directory_local Transfer Done!!\n"; 
   }
 }
 return ($error_put);
}
##get de files van assurcard
sub getfiles {
 my $directory_local = shift @_;
 my $directory_remote = shift @_;
 my @my_file_names =();
 my $error_get = 0;
 print "remotev $directory_remote\n";
 $ftp->cwd($directory_remote) or die "Can't change directory ($directory_remote):$ftp->message; ";

 my @files  = $ftp ->ls ;
 #or die "unable to list remote $directory_remote:";
 my $error_put = 0;
 print "$_\n" for @files;
 foreach my $file_name (@files){
  if ($file_name =~ m/^\./) {
     print "naam-$file_name-\n";
    }else {
      print "naamelse-$file_name-\n";
      print "$directory_remote/$file_name->$directory_local/$file_name\n";
      if (!$ftp -> get("$directory_remote/$file_name","$directory_local/$file_name")) {
         print "Failed to Transfer: ".$ftp->error;
         $error_put = 1;
        }else { 
         print "$directory_local Transfer Done!!\n";
         print "delete $directory_remote/$file_name\n";
         if (!$ftp->delete("$directory_remote/$file_name")) {
             print "Failed delete: ".$ftp->error;
           }
        }
    }
 }
return ($error_put);
}
##maak een backup directory aan
sub createdir {
   my $Dir = shift @_ || die "Syntax: $0 <Dir>";
   my $Result = 1;
   my  $Root;
   my $Path;
   ( $Root, $Path ) = ( $Dir =~ /^(\w:\\?|\\\\.+?\\.+?\\|\\)?(.*)$/ );
   print "Creating directory $Dir'...\n";
   if( -d $Dir ){
      print "Directory already exists.\n";
      #exit;
    }else {
      my @DirList = split( /\\/, $Path );
      $Path = $Root;
      while( $Result && scalar @DirList ){
        $Path .= ( shift @DirList ) . "\\";
        next if( -d $Path );
        $Path =~ s%\\%%;
        print "pad:$Path'..\n";
        $Result = mkdir( $Path, 0777 );
      }
    }
    if ($Result == 1) {
         print "Success\n";#code
    }else {
          print "Failure (Error: $!)\n";
    }

  }
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


