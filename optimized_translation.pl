#!/usr/bin/perl

open my $csfasta_file,"<","$ARGV[0]";
while (!eof $csfasta_file){
    my $header = <$csfasta_file>;
    my $string = <$csfasta_file>;
    if ($string =~ m/\./){next};
        print $header;
        my @str = translate_string($string);
        print join "",@str;
        print "\n";
}
sub hd  { #subroutine for calculate Hamming distance
    my ($k,$l) = @_;
    my $mismatch_num = 0;
    my $len = length($k);
    for (my $i = 0;$i<$len;$i++){
        ++$mismatch_num if substr($k,$i, 1) ne substr($l,$i,1);
    }
    return $mismatch_num
}

sub translate_string {
    open my $code_file,"<","../reference/hexG2.x";
    my %codes;
    while(<$code_file>){
        chomp;
        my @a = split "\t", $_;
        $codes{$a[1]} = $a[0]
    }
    my $string = $_[0];
    chomp $string;
    $string =~ s/^[AGCTN]//;
    my @string_letters = split "", $string;
    my @result_string = ();
    for (my $i = 0; $i < scalar(@string_letters) - 5; $i++){
        my $ok_flag = 0;
        my $read_hex = join "", @string_letters[$i..($i+5)];
        foreach (keys %codes){
            if (hd($read_hex,$_)< 1){
                push @result_string, $codes{$_};
                $ok_flag = 1
        }}
        if ($ok_flag == 0){
            push @result_string, "."
    }}
    return @result_string;
}
