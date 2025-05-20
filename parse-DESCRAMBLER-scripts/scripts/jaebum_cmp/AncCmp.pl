#!/usr/bin/perl

use strict;
use warnings;
use FindBin qw($Bin);

my $res = shift;    # Resolution ex: 300000
my $pname = shift;  # Parent name
my $pdir = shift;   # Parent directory
my $cname = shift;  # Child name
my $cdir = shift;   # Child directory 
my $out_dir = shift;	# Output directory  
	
`mkdir -p $out_dir`;

`$Bin/compare_apcfs.cmp.pl $pdir $cdir $out_dir > $out_dir/Final_id_map.txt`;
`$Bin/merge_new_apcf.cmp.pl $pname $cname $out_dir/Ancestor.APCF.map $out_dir/new_block_list.txt $out_dir/Final_id_map.txt $out_dir/Ancestor.APCF.merged.map $out_dir/breakflanking_block_size.txt`;
`$Bin/extract_apcf_conf.cmp.pl $out_dir/Ancestor.APCF.merged.map > $out_dir/Ancestor.APCF.merged.conf`;
`$Bin/create_anc_map.pl $pname $cname $out_dir > $out_dir/APCF_$cname.map`;
`$Bin/merge_pos.pl $res $pname $cname $out_dir/APCF_$cname.map > $out_dir/APCF_$cname.merged.map`;
`$Bin/create_dbfile.pl $pname $cname $res $out_dir/APCF_$cname.merged.map > $out_dir/dbfile.txt`;


