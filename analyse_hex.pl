#!/usr/bin/perl
use strict;
open my $hex_file, "<", "$ARGV[0]";
while (!eof $hex_file){
    my $header = <$hex_file>;
    my $hex_string = <$hex_file>;
    chomp $hex_file;
    my @string = split " ", $hex_string;
    my @new_string = join_regular_hex(@string);
    print $header; 
    print join " ",@new_string;
    print "\n";
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
            $string[$i] =~ m/^([GHMA])(\d{1,2})/;
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
            $string[$i] =~ m/^([GHMA])(\d{1,2})/;
            my $f1 = $1;
            my $f2 = $2;
            #continue chain
            if ( $f1 eq 'G'){
                $f1 = $str_p{'fr_l'};
                $f2 = $str_p{'cur_N'} + 1;
            }
            if ($str_p{'fr_l'} eq 'G' and $f1 ne 'G'){
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
                }   
            }
        }
    }



    return @translated_string
}










