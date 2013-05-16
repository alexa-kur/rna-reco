#!/usr/bin/perl
use strict;
open my $code_file,"<","../reference/hexG.x";
my %codes;
while(<$code_file>){
    chomp;
    my @a = split "\t", $_;
    $codes{$a[1]} = $a[0]
    }

open my $csfasta_file,"<","$ARGV[0]";
while (!eof $csfasta_file){
    my $header = <$csfasta_file>;
    my $string = <$csfasta_file>;

    print $header;
    print join " ", translate_string($string);
    print "\n";
}

sub translate_string {
    my $string = $_[0];
    chomp $string;
    $string =~ s/^[AGCTN]//;

    #foreach (keys %codes){
    #    $string =~s/$_/ $codes{$_} /g;
    #}
    #    print $header,$string
    my @string_letters = split "", $string;
    my @result_string = ();
    for (my $i = 0; $i < scalar(@string_letters) - 5; $i++){
        my $ok_flag = 0;
        my $read_hex = join "", @string_letters[$i..($i+5)];
        foreach (keys %codes){
            if ($read_hex eq $_){
                push @result_string, $codes{$_};
                $ok_flag = 1
            }
        }
            if ($ok_flag == 0){
                push @result_string, $read_hex
            }

    }
    return @result_string;
}
