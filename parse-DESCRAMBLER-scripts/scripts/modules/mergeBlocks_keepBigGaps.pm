package MergeBlocks;
use strict;
use warnings;
use Data::Dumper;
 
use Exporter qw(import);
 
our @EXPORT_OK = qw(mergeBlocks);
 
sub mergeBlocks {
    my ($inFile, $resolution)=@_;
    my %data;
    my $line = 0;
    open (IN, $inFile) or die "Couldn't open $inFile";
    my $count = `wc -l $inFile`;
    #print "$count\n\n\n";
    while (<IN>){
        #chomp;
        if ($_ eq "\n"){
	       print "Empty line\n";
        }
        else {
            #print "$line\n"; ### HERE!!!!
            my @t = split(",", $_);
            #print Dumper @t;
            @{$data{"l${line}"}}=@t;
            $line++;
        }
    }
    close IN;

    my @sorted_keys=();
    for my $key ( sort { $data{$a}[1] cmp $data{$b}[1] || $data{$a}[2] <=> $data{$b}[2] } keys %data ) {
        push(@sorted_keys, $key);  
    }

    open (OUT, ">${inFile}.merged") or die "Couldn't create ${inFile}.merged";
    my $add;
    START: for ( my $k = 0; $k <= scalar (@sorted_keys); $k += $add){ #for each line in file ordered by ref chr and ref start
        #print "$k\t$sorted_keys[$k]\n";
        my ($label11, $chr1, $chrS1, $chrE1, $carS1, $carE1, $carOr1, $label21, $carI1) = @{$data{$sorted_keys[$k]}};
        my ($bstart, $bend, $cstart, $cend)=($chrS1, $chrE1, $carS1, $carE1);
        GO: for (my $i = 1; $i <= scalar (@sorted_keys) ; $i ++){
	        #print scalar(@sorted_keys)." ".($k+$i)."\n";
            #if (($k+$i)<scalar (@sorted_keys)) {
            #if (! exists $data{$sorted_keys[$k+$i]}){ 
	        if (($k+$i) == scalar(@sorted_keys)) { #if last line of file
                if ($bstart < 0) { $bstart = 0; }
                print OUT "$label11,$chr1,$bstart,$bend,$cstart,$cend,$carOr1,${label21},$carI1,$carI1\n";
                last START;
            }
            my ($label12, $chr2, $chrS2, $chrE2, $carS2, $carE2, $carOr2, $label22, $carI2) = @{$data{$sorted_keys[$k+$i]}};
      
            if ($carOr1 eq "+1" && $chr1 eq $chr2 && $carI1 eq $carI2 && $carOr1 eq $carOr2){ ## IF BOTH BLOCKS + ORIENTATION
                if ( $cend == $carS2 ){ ##IF SUCCESSIVE MERGE
                    $bend = $chrE2;
                    $cend = $carE2;
                    next GO;
                }
                my $gap = $cend - $carS2; # calculate gap in target species (end of 1st block - start of 2nd block)
                if ($gap > 0){ ## NOT SUCCESSIVE -> BREAK (start of 2nd block will be smaller than end of 1st block)
                    #print "+1 $carI2 $gap\n";
                    if ($carS2 < $cend && $carS2 > $cstart && $carE2 > $cstart){ #except if overlapping at begginig of second block, then merge
                        print "Found ++ overlap $carI1 $cstart $cend $carS2 $carE2 in chr $chr1\n"; 
                        $bend = $chrE2;
                        $cend = $carE2;
                        next GO;
                    } else{      
                        if ($bstart < 0) { $bstart = 0; }
                        print OUT "$label11,$chr1,$bstart,$bend,$cstart,$cend,$carOr1,${label21},$carI1,$carI1\n";
                        $add = $i;
                        next START;
                    }
                }
                if ( $gap < 0 && abs($gap) > $resolution ){ ## MAY BE LACK OF ALIGNMENT -> CHECK FOR BLOCKS IN GAP REGION
                    my $flag = "True";
                    # my $flag = "False";
                    # for (my $j = 1; $j < scalar (@sorted_keys) ; $j ++){
                    #     my @array = ($k .. $k+$i);
                    #     if ( ! grep (/$j/, @array) ){
                    #         my ($label13, $chr3, $chrS3, $chrE3, $carS3, $carE3, $carOr3, $label23, $carI3) = @{$data{$sorted_keys[$j]}};
                    #         if ( $carI2 eq $carI3 && $cend <= $carE3 && $carS3 <= $carS2 ){  $flag = "True"; } # OVERLAP FOUND
                    #     }             
                    # }
                    if ($flag eq "True"){ ## IF OVERLAP FOUND -> BREAK
                        if ($bstart < 0) { $bstart = 0; }
                        print OUT "$label11,$chr1,$bstart,$bend,$cstart,$cend,$carOr1,${label21},$carI1,$carI1\n";
                        $add = $i;
                        next START;
                    }
                    #else{ ## IF NO OVERLAP -> MERGE
                    #     $bend = $chrE2;
                    #     $cend = $carE2;
                    #     next GO;
                    # }
                }
                if ( $gap < 0 && abs($gap) <= $resolution ){ ## IF GAP < RESOLUTION -> MERGE
                    $bend = $chrE2;
                    $cend = $carE2;
                    next GO;
                }
            }
            if ($carOr1 eq "-1" && $chr1 eq $chr2 && $carI1 eq $carI2 && $carOr1 eq $carOr2){ ## IF BOTH BLOCKS INVERTED 
                if ($cstart == $carE2){ ## IF BLOCKS ARE CONSECUTIVE MERGE
                    $bend = $chrE2;
                    $cstart = $carS2;
                    next GO;
                }
                my $gap = $carE2 - $cstart; ## GAP LENGTH
                if ($gap > 0){ ## IF GAP > 0: 2 INDEPENDENT INVERTIONS -> BREAK
                    if($carE2 > $cstart && $cend > $carS2 && $cend > $carE2){ # except if overlapping
                        print "Found -- overlap $carI1 $cstart $cend $carS2 $carE2 in chr $chr1\n";
                        $bend = $chrE2;
                        $cstart = $carS2;
                        next GO;
                    } else{
                        if ($bstart < 0) { $bstart = 0; }
                        print OUT "$label11,$chr1,$bstart,$bend,$cstart,$cend,$carOr1,${label21},$carI1,$carI1\n";
                        $add = $i;
                        next START;
                    }
                }
                if ($gap < 0 && abs($gap) > $resolution){ ## IF GAP < 0: MAY BE LACK OF ALIGNMENT -> CHECK FOR OTHER BLOCKS IN GAP
                    my $flag = "True";
                    # my ($gapStart, $gapEnd)=($carE2, $cstart);
                    # my $flag = "False";
                    # for (my $j = 1; $j < scalar (@sorted_keys) ; $j ++){
                    #     my @array = ($k .. $k+$i);
                    #     if ( ! grep (/$j/, @array) ){
                    #         my ($label13, $chr3, $chrS3, $chrE3, $carS3, $carE3, $carOr3, $label23, $carI3) = @{$data{$sorted_keys[$j]}};
                    #         if ( $carI3 eq $carI2 && $gapStart <= $carE3 && $carS3 <= $gapEnd ){ $flag = "True"; } ##OVERLAP FOUND
                    #     }             
                    # }
                    if ($flag eq "True"){ ## IF OVERLAP FOUND -> BREAK
                        if ($bstart < 0) { $bstart = 0; }
                        print OUT "$label11,$chr1,$bstart,$bend,$cstart,$cend,$carOr1,${label21},$carI1,$carI1\n";
                        $add = $i;
                        next START;
                    }
                    # else{ # OTHERWISE MERGE
                    #     $bend = $chrE2;
                    #     $cstart = $carS2;
                    #     next GO;
                    # }
                }
                if ($gap < 0 && abs($gap) <= $resolution ){ ## IF GAP LOWER THAN RESOLUTION -> MERGE
                    $bend = $chrE2;
                    $cstart = $carS2;
                    next GO;
                }  
            }
            if ($chr1 ne $chr2 || $carI1 ne $carI2 || $carOr1 ne $carOr2){
                if ($bstart < 0) { $bstart = 0; }
                print OUT "$label11,$chr1,$bstart,$bend,$cstart,$cend,$carOr1,${label21},$carI1,$carI1\n";
                $add = $i;
                next START;
            }
        }
    }
    #}
    close OUT;    
}
  
1;