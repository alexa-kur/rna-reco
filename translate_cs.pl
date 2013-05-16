#!/usr/bin/perl
use strict;


open my $csfasta_file,"<","$ARGV[0]";
while (!eof $csfasta_file){
    my $header = <$csfasta_file>;
    my $string = <$csfasta_file>;
    if ($string =~ m/\./){next};
        print $header;
        my @str = translate_string($string);
        print join " ",remove_adaptor(join_regular_hex(error_correction(@str))); 
        print "\n";
}

sub translate_string {
    open my $code_file,"<","../reference/hexG.x";
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
            if ($read_hex eq $_){
                push @result_string, $codes{$_};
                $ok_flag = 1
        }}
        if ($ok_flag == 0){
            push @result_string, $read_hex
    }}
    return @result_string;
}

sub join_regular_hex {
    my %g_block = (
        'G1' , 'H65_H88',
        'G3' , 'H25_M88',
        'G2' , 'H66_H80_H89', 
        'G4' , 'H26_M89',
        'G5' , 'M53_A13', 
        'G6' , 'H67_H81', 
        'G7' , 'M33_M46', 
        'G11' ,'H33_H85', 
        'G9' , 'H11_H46',
        'G10' , 'H14_M44', 
        'G8' , 'H10_H45',
    );
    my @string = @_;
    my @translated_string = ();
    
    my %str_p;
    $str_p{'fr_l'} = '';
    $str_p{'fr_N'} = 0;
    $str_p{'cur_N'} = 0;

    for (my $i = 0; $i < scalar (@string);$i++){
        
        #if unknown hexamer
        if ($string[$i] =~ m/^\d{6}$/) {
            
            #push collected string
            if ($str_p{'fr_l'} ne ''){
                my $out_string = $str_p{'fr_l'}.$str_p{'fr_N'}."-".$str_p{'cur_N'};
                push (@translated_string, $out_string);
                $str_p{'fr_l'} = '';
                $str_p{'fr_N'} = 0;
                $str_p{'cur_N'} = 0;
            }
            
            #push current hexamer
            push (@translated_string, $string[$i]);
        }
        
        #if known hexamer, but new in chain
        elsif ($str_p{'fr_l'} eq ''){
            $string[$i] =~ m/^([GHMA]{1,2})(\d{1,2})/;
            $str_p{'fr_l'} = $1;
            $str_p{'fr_N'} = $2;
            $str_p{'cur_N'} = $2;
            #check if last cycle
            if ($i == scalar(@string) -1){
                my $out_string = $str_p{'fr_l'}.$str_p{'fr_N'}."-".$str_p{'cur_N'};
                push (@translated_string, $out_string);
             }   
        }
        #if new hexamer and chain exists
        elsif ($str_p{'fr_l'} ne ''){
            $string[$i] =~ m/^([GHMA]{1,2})(\d{1,2})/;
            my $f1 = $1;
            my $f2 = $2;
            #continue chain
            if ( $f1 =~ /G/){
                $f1 = $str_p{'fr_l'};
                $f2 = $str_p{'cur_N'} + 1;
            }
            if ($str_p{'fr_l'} =~ /G/ and $f1 !=~ /G/){
                $str_p{'fr_l'} = $f1;
                $str_p{'fr_N'} = $f2 - ($str_p{'cur_N'}-$str_p{'fr_N'}+1);
                $str_p{'cur_N'} =$f2 -1;
            }



            if ($f1 eq $str_p{'fr_l'} and $f2 == 1+$str_p{'cur_N'}){
                $str_p{'cur_N'} = $f2;

                if ($i == scalar(@string) -1){
                    my $out_string = $str_p{'fr_l'}.$str_p{'fr_N'}."-".$str_p{'cur_N'};
                    push (@translated_string, $out_string);
                }   
            }
            #stop chain
            else {
                my $out_string = $str_p{'fr_l'}.$str_p{'fr_N'}."-".$str_p{'cur_N'};
                push (@translated_string, $out_string);
                $str_p{'fr_l'} = $1;
                $str_p{'fr_N'} = $2;
                $str_p{'cur_N'} = $2;
                if ($i == scalar(@string) -1){
                    my $out_string = $str_p{'fr_l'}.$str_p{'fr_N'}."-".$str_p{'cur_N'};
                    push (@translated_string, $out_string);
    }}}}
    return @translated_string
}

sub error_correction {
    ##This subroutine is made for some error corrections with one color mismatch
    #input is @translated_string from join_regular_hex
    #output can be used for join_regular_hex
    open my $code_file,"<","../reference/hexG.x";
    my %codes;
    while(<$code_file>){
        chomp;
        my @a = split "\t", $_;
        $codes{$a[0]} = $a[1]
    }
    my @hexes = @_;
    for (my $i = 0;$i < scalar(@hexes);$i++){
        if ($i > 1 and $hexes[$i] =~m/\d{6}/ and $hexes[$i-1] =~m/([AMHG])(\d{1,2})/){
            my $let = $1;
            my $num = $2+1;
            my $scan = $let.$num;
            my $hd = hd($hexes[$i], $codes{$scan});
            $hexes[$i] = $scan if $hd ==1;
            $hexes[$i] = $1.$scan if $hd ==2;

    }}
    for (my $i = scalar(@hexes)-1;$i>-1;$i--){
        if ($i < scalar(@hexes)-2 and $hexes[$i] =~m/\d{6}/ and $hexes[$i+1] =~m/([AMHG])(\d{1,2})/){
            my $let = $1;
            my $num = $2-1;
            my $scan = $let.$num;
            my $hd = hd($hexes[$i], $codes{$scan});
            $hexes[$i] = $scan if $hd ==1;
            $hexes[$i] = $1.$scan if $hd ==2;

    }}
    return @hexes;
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

sub remove_adaptor {
    my @string =@_;
    for (my $i = 0;$i < scalar @string;$i++){
        if ($string[$i] =~m/A{1,2}(\d+)-(\d+)/ and ($2 -$1) > 3){
            @string = @string[0..($i-1)];
            last
        }
        if ($string[$i] =~m/A/ and ($string[$i+1] =~m/A/ or $string[$i+2] =~m/A/)){
            @string = @string[0..($i-1)];
            last
    }}
    return @string
}

