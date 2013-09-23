#!/usr/bin/perl
open my $csfile, "<","$ARGV[0]";
open my $qualfile, "<","$ARGV[1]";
open my $outfile, ">","../filtered3.csfasta";
while (!eof $csfile){
    my @string = [];
    
    for (my $i = 0;$i <2;$i++){
        $string[$i] = <$csfile>
    }
    for (my $i = 2;$i < 4;$i++){
        $string[$i] = <$qualfile>
    }

    next if ($string[1] =~ /\./);
    chomp $string[3];
    
    my @qual_string = split ' ', $string[3];
    my $sum;
    foreach (@qual_string){$sum +=$_}
    $sum =$sum/scalar(@qual_string);

    if ($sum > 28){
        output_cs($string[0],$string[1])
    }
}

sub output_cs {
    print $_[0],$_[1];
    1
}
sub output_qual {
    open my $outfile, ">", "$_[0]";
    print $outfile $_[1],$_[2];
    1
}


