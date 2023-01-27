#!/usr/bin/perl -w
use strict;
use DBI;
use DBD::ODBC;

package sql_toegang_agresso;
#sql_toegang_agresso->setup_mssql_connectie;
#use strict;

#our $dbh_mssql;

sub setup_mssql_connectie {
     my $database;
     if ($main::mode eq 'TEST') {
         $database = 'agraccept';
     }elsif  ($main::mode eq 'PROG') {
        $database = 'agrprod'
     }else {
          die;
     }
      
     my $dbh_mssql;
     my $dsn_mssql = join "", (
         "dbi:ODBC:",
         "Driver={SQL Server};",
         #"Server=S998XXLSQL01.CPC998.BE\\i200;",
         "Server=S000WP1XXLSQL01.mutworld.be\\i200;", # nieuwe database server 2016 05 S000WP1XXLSQL01.mutworld.be\i200
         "UID=HOSPIPLUS;",
         "PWD=ihuho4sdxn;",
         "Database=$database",        
        );
      my $user = 'HOSPIPLUS';
      my $passwd = 'ihuho4sdxn';
     
      my $db_options = {
         PrintError => 1,
         RaiseError => 1,
         AutoCommit => 1, #0 werkt niet in
         LongReadLen =>2000,

        };
     #
     # connect to database
     #
     $dbh_mssql = DBI->connect($dsn_mssql, $user, $passwd, $db_options) or exit_msg("Can't connect: $DBI::errstr");
     return ($dbh_mssql)
    }

sub disconnect_mssql {
     my ($class,$dbh_mssql) = @_;
     $dbh_mssql->disconnect;
}
sub insert_invoice_in_zgt_mark_invoices { #facturen kan je niet meer zien als completed op 1 staat completed is anders binair mat een 1  en vijf plaatsen erachter voor verzekering
     my ($class,$dbh,$voucher_no,$ext_inv_ref,$apar_id,$verzprod2,$verzprod3,$verzprod4,$verzprod5) =  @_;
     my $client ='VMOB';
     # completed 0 stadium is verwerk factuur aangevinkt 1 = asuurcard verkoopsorder gemaakt 2 ass verkooporder en hospi credit aangemaakt
     my $last_update = "20141024"; #datum ophalen in sql
     my $voucher_type = 'BZ';
     my $zetin = "insert into zgt_mark_invoices (voucher_no,ext_inv_ref,apar_id,completed,client,verzprod1,verzprod2,verzprod3,verzprod4,verzprod5,last_update,voucher_type)
     values ($voucher_no,'$ext_inv_ref','$apar_id',0,'VMOB','ASSURCARD','$verzprod2','$verzprod3','$verzprod4','$verzprod5',getdate(),'BZ')";
     my $sth= $dbh ->prepare($zetin);
     $sth -> execute();
     $sth -> finish();    
     return ($zetin);
}
sub update_completed_assurcard_verkoopsorder_gemaakt { #
      my ($class,$dbh,$voucher_no,$ext_inv_ref,$apar_id) =  @_;
      my $last_update = "GETDATE ( )";
      my $verzprod1a = 'ASSURCARD'; #factuur naar assurcard
      my $client ='VMOB';
      # my $updatethis = $dbh_mssql ->do("UPDATE zgt_log_assurcard set feedback = 'YES' WHERE ext_inv_ref = '$invoice_nr'");
      my $updatethis = $dbh ->do("UPDATE zgt_mark_invoices set completed= 110000,last_update  = getdate()
                                 WHERE client= '$client' and voucher_no = $voucher_no and verzprod1 = '$verzprod1a'
                                 and ext_inv_ref = '$ext_inv_ref' and apar_id = '$apar_id'");
      
      print "";
      my ($completed,$verzprod1,$verzprod2,$verzprod3,$verzprod4,$verzprod5 ) = $dbh->selectrow_array("SELECT completed,verzprod1,verzprod2,verzprod3,verzprod4,verzprod5 FROM zgt_mark_invoices WHERE voucher_no = $voucher_no 
                                           and ext_inv_ref = '$ext_inv_ref' and apar_id = $apar_id");
      my $completed_moet_zijn = 110000;
      my  $completed_moet_zijn_plus = 0;
      $completed_moet_zijn_plus = 1000 if (defined $verzprod2 and $verzprod2 ne '' );
      $completed_moet_zijn_plus = 100 if (defined $verzprod3 and $verzprod3 ne '' );
      $completed_moet_zijn_plus = 10 if (defined $verzprod4 and $verzprod4 ne '' );
      $completed_moet_zijn_plus = 1 if (defined $verzprod5 and $verzprod5 ne '' );
      $completed_moet_zijn =$completed_moet_zijn + $completed_moet_zijn_plus;
      $completed = 1 if ($completed eq $completed_moet_zijn);
      if ($completed == 1 ) {
         $updatethis = $dbh ->do("UPDATE zgt_mark_invoices set completed = 1
                                 WHERE client= '$client' and voucher_no = $voucher_no and verzprod1 = '$verzprod1a'
                                 and ext_inv_ref = '$ext_inv_ref' and apar_id = '$apar_id'");
        }
      
      
      return ('ok');
}

sub update_completed_hospi_verkoopsorder_gemaakt {
      my ($class,$dbh,$voucher_no,$ext_inv_ref,$apar_id,$verzprod) =  @_;
     
      my $client ='VMOB';
      #zoek welk product
      my ($completed,$verzprod1,$verzprod2,$verzprod3,$verzprod4,$verzprod5 ) = $dbh->selectrow_array("SELECT completed,verzprod1,verzprod2,verzprod3,verzprod4,verzprod5 FROM zgt_mark_invoices WHERE voucher_no = $voucher_no 
                                           and ext_inv_ref = '$ext_inv_ref' and apar_id = $apar_id");
      my $completed_start = 100000;
      my $completed_code = 0;
      
      $completed_code = 10000 if (uc $verzprod1 eq uc $verzprod );
      $completed_code = 1000 if (uc $verzprod2 eq uc $verzprod );
      $completed_code = 100 if (uc $verzprod3 eq uc $verzprod );
      $completed_code = 10 if (uc $verzprod4 eq uc $verzprod );
      $completed_code = 1 if (uc $verzprod5 eq uc $verzprod );
      if ($completed eq '') {
         return ('completed eq ');#code
      }elsif ($completed == 0)  {    
         $completed = $completed_start + $completed_code ;
      }else {
         $completed = $completed + $completed_code ;
      }
      my $completed_moet_zijn = 110000;
      my  $completed_moet_zijn_plus = 0;
      $completed_moet_zijn_plus += 1000 if (defined $verzprod2 and $verzprod2 ne '' );
      $completed_moet_zijn_plus += 100 if (defined $verzprod3 and $verzprod3 ne '' );
      $completed_moet_zijn_plus += 10 if (defined $verzprod4 and $verzprod4 ne '' );
      $completed_moet_zijn_plus += 1 if (defined $verzprod5 and $verzprod5 ne '' );
      $completed_moet_zijn =$completed_moet_zijn + $completed_moet_zijn_plus;
      $completed = 1 if ($completed eq $completed_moet_zijn);
      
      my $updatethis = $dbh ->do("UPDATE zgt_mark_invoices set completed = $completed,last_update = getdate() 
                                 WHERE client= '$client' and voucher_no = $voucher_no and 
                                 ext_inv_ref = '$ext_inv_ref' and apar_id = '$apar_id'");
      print "";
      return ('ok');
}
sub update_completed_to_one {
      my ($class,$dbh,$ext_inv_ref) = @_;
      my $updatethis = $dbh ->do("UPDATE zgt_mark_invoices set completed = 1,last_update = getdate()
                                 WHERE ext_inv_ref = '$ext_inv_ref'");
      return ('ok');
}
sub check_off_line_exists {
     my ($class,$dbh,$voucher_no,$ext_inv_ref,$apar_id) =  @_;
     my $client ='VMOB';
     my ($completed,$last_update,$voucher_no_db) = $dbh->selectrow_array("SELECT completed,last_update,voucher_no FROM zgt_mark_invoices WHERE voucher_no = $voucher_no 
                                           and ext_inv_ref = '$ext_inv_ref' and apar_id = $apar_id and client = '$client'");
     return ($completed,$last_update,$voucher_no_db);
}
sub check_what_is_completed {
     my ($class,$dbh,$voucher_no,$ext_inv_ref,$apar_id) =  @_;
     my $client ='VMOB';
     my @completed = $dbh->selectrow_array("SELECT completed,verzprod1,verzprod2,verzprod3,verzprod4,verzprod5 FROM zgt_mark_invoices WHERE voucher_no = $voucher_no 
                                           and ext_inv_ref = '$ext_inv_ref' and apar_id = $apar_id and client = 'VMOB'");
     return (@completed);
}
sub set_last_update_to_today {
     my ($class,$dbh,$voucher_no,$ext_inv_ref,$apar_id) =  @_;
     my $client ='VMOB';
     # my $updatethis = $dbh_mssql ->do("UPDATE zgt_log_assurcard set feedback = 'YES' WHERE ext_inv_ref = '$invoice_nr'");
     my $updatethis = $dbh ->do("UPDATE zgt_mark_invoices set last_update = getdate() 
                                 WHERE client = '$client' and voucher_no = $voucher_no  
                                 and ext_inv_ref = '$ext_inv_ref' and apar_id = '$apar_id'");
     print "";
}
sub get_row_number_VMOBVZNZ {
      my ($class,$dbh,$apar_id) =  @_;
      my $row = $dbh->selectrow_array("select max(line_no)+1 as lijnnr from afxvmobvznz where dim_value = '$apar_id' and client = 'VMOB' ");
      print "VMOBVZNZ -> $row\n";
      return ($row);
}
sub get_row_number_VMOBAMBU {
     my ($class,$dbh,$apar_id) =  @_;
     my $row = $dbh->selectrow_array("select max(line_no)+1 as lijnnr from afxvmobambu where dim_value = '$apar_id' and client = 'VMOB' ");
     print "VMOBAMBU -> $row\n";
     return ($row);
}
sub ubtstatistics_insert_row { #statistieken wat men allemaal doet 
            my ($class,$dbh,$apar_id,$zkf_nr,$gkd_tekst) = @_;
            my $client ='VMOB';
            my $zetin = "insert into ubtstatistics (client,apar_id,zkf_nr,stat_text,date_insert,stat_counter)
                     values ('$client','$apar_id',$zkf_nr,'$gkd_tekst',getdate(),1)";
            my $sth= $dbh ->prepare($zetin);
            $sth -> execute();
            $sth -> finish();
            print "";
          }
sub add_card_lost {
      my ($class,$dbh,$apar_id) =  @_;
      my $client ='VMOB';
      my $updatethis = $dbh ->do("UPDATE afxvmobalg1 SET aantal_kaarten_fx = aantal_kaarten_fx+1 WHERE  client='$client' and Dim_Value= $apar_id");
      print "";
}
sub Get_to_Blockcustassurcard {
      my ($class,$dbh) =  @_;
      my $sql =("SELECT Apar_Id,Ext_Apar_Ref,Action,Apar_Name,Product,Start_Date,End_date,Birth_Date,Gender   FROM Blockcustassurcard WHERE Client ='VMOB'");
      my $sth = $dbh->prepare( $sql );
      $sth->execute();
      my $BlockedContracts ;
      while(my @mijnrij=$sth->fetchrow_array)  {
           $BlockedContracts->{$mijnrij[1]} ={
                AssurCardIdentifier => $mijnrij[1],
                Apar_Id => $mijnrij[0],
                Action => $mijnrij[2],
                Apar_Name=> $mijnrij[3],
                Ext_Apar_Ref => $mijnrij[1],
                Product=> $mijnrij[4],
                Start_Date=> $mijnrij[5],
                End_date=> $mijnrij[6],
                BirthDate=> $mijnrij[7],
                Gender=> $mijnrij[8],
               }   ;          
          }
      return ($BlockedContracts);
     }
sub Delete_Blockcustassurcard {
      my ($class,$dbh,$Ext_Apar_Ref) =  @_;
      my $delete_this = $dbh ->do("DELETE FROM Blockcustassurcard WHERE Ext_Apar_Ref = '$Ext_Apar_Ref'");
      print "";
      return($delete_this);
     }
sub get_contracts_by_type {
        my ($class,$dbh,$type,$startdatum) =  @_;
        $startdatum = "$startdatum";
       #0 agrtid
       #1 attribute_id
       #2 client
       #3 contract_nr
       #4 date_from
       #5 date_to
       #6 dim_value
       #7 einddatum
       #8 info
       #9 last_update
       #10 line_no
       #11 product
       #12 startdatum
       #13 user_id
       #14 wachtdatum
       #15 zkf_nr
       #16 zkf_nr_datum_tot
       #17 zkf_nr_datum_van
        #my $sql =("SELECT * FROM afxvmobcontrbu  WHERE product ='$type' and client = 'VMOB' ");  
        #my $sth = $dbh->prepare( $sql );
        #$sth->execute();
        # while(my @rij =$sth->fetchrow_array)  {
        #   print"@rij\n";
        #  }
        my $contracten;
        my $contracteller =0;
        my $sql =("SELECT dim_value,product,contract_nr,startdatum,wachtdatum,einddatum,zkf_nr FROM afxvmobcontract WHERE product ='$type'
                  and client = 'VMOB' and startdatum < '$startdatum' order by dim_value,startdatum ");  
        my $sth = $dbh->prepare( $sql );
        $sth->execute();
         while(my @rij =$sth->fetchrow_array)  {
           #print"@rij\n";
           $contracten->{$rij[0]}->{contract_nr}=$rij[2];
           $contracten->{$rij[0]}->{contract_naam}=$rij[1];
           $contracten->{$rij[0]}->{begin_datum}=substr($rij[3],0,10);
           $contracten->{$rij[0]}->{wacht_datum}=substr($rij[4],0,10);
           $contracten->{$rij[0]}->{eind_datum}=substr($rij[5],0,10);
           $contracten->{$rij[0]}->{zkf}=$rij[6];
            $contracteller +=1;
          }
      print '';
      return ($contracten, $contracteller);
}
sub enter_maf_payment_info {
        #Create table afschriftoverzicht
        #  ( 
        #  client varchar(25) NOT NULL, VMOB
        #  apar_id varchar(25) NOT NULL,  Debiteur ID
        #  afschriftjaar int NOT NULL,
        #  afleverjaar  int NOT NULL,
        #  uitbetaaljaar int NOT NULL,
        #  klantbedrag decimal (28,3) NOT NULL,
        #  vmobbedrag decimal (28,3) NOT NULL
        #  )
        my ($class,$dbh,$apar_id,$afschriftjaar,$afleverjaar,$uitbetaaljaar,$klantbedrag,$vmobbedrag) = @_;
        my $client ='VMOB';
        my $zetin = "insert into afschriftoverzicht (client,apar_id,afschriftjaar,afleverjaar,uitbetaaljaar,klantbedrag,vmobbedrag)
                     values ('$client','$apar_id',$afschriftjaar,$afleverjaar,$uitbetaaljaar,$klantbedrag,$vmobbedrag)";
        my $sth= $dbh ->prepare($zetin);
        $sth -> execute();
        $sth -> finish();
        print "";  
}
sub enter_tandplus_payment_info {
        
        #Create table TandPlusAfschriftoverzicht
        #  ( 
        #  client varchar(25) NOT NULL, VMOB
        #  apar_id varchar(25) NOT NULL,  Debiteur ID
        #  afschriftjaar int NOT NULL,
        #  afleverjaar  int NOT NULL,
        #  uitbetaaljaar int NOT NULL,
        #  klantbedrag decimal (28,3) NOT NULL,
        #  vmobbedrag decimal (28,3) NOT NULL
        #  )
        my ($class,$dbh,$apar_id,$afschriftjaar,$afleverjaar,$uitbetaaljaar,$klantbedrag,$vmobbedrag) = @_;
        my $client ='VMOB';
        my $zetin = "insert into TandplusAfschriftoverzicht (client,apar_id,afschriftjaar,afleverjaar,uitbetaaljaar,klantbedrag,vmobbedrag)
                     values ('$client','$apar_id',$afschriftjaar,$afleverjaar,$uitbetaaljaar,$klantbedrag,$vmobbedrag)";
        my $sth= $dbh ->prepare($zetin);
        $sth -> execute();
        $sth -> finish();
        print "";  
}
sub get_maf_payment_info {
       my ($class,$dbh,$apar_id,$eerstejaar,$tweedejaar,$derdejaar) = @_;
       my $afschriftjaren = "$eerstejaar,$tweedejaar,$derdejaar";
       my $sql =("SELECT client,apar_id,afschriftjaar,afleverjaar,uitbetaaljaar,klantbedrag,vmobbedrag FROM
                   afschriftoverzicht WHERE apar_id =$apar_id AND afschriftjaar IN ($afschriftjaren)");
       my $sth = $dbh->prepare( $sql );
       $sth->execute();
       my $al_betaald ;
         while(my @rij =$sth->fetchrow_array)  {
                my $jaar_span = "$rij[2]-$rij[3]";
                $al_betaald->{$jaar_span}->{vmobbedrag}= $rij[6];
                $al_betaald->{$jaar_span}->{klantbedrag}= $rij[5];
                $al_betaald->{$jaar_span}->{uitbetaaljaar}= $rij[4];
                $al_betaald->{$jaar_span}->{afschriftjaar}= $rij[2];
                $al_betaald->{$jaar_span}->{afleverjaar}= $rij[3];
                $al_betaald->{$rij[2]} += $rij[6];
          }
         return ($al_betaald);
     }
1;