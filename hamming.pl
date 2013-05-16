sub hd  {
    my ($k,$l) = @_;
    my $mismatch_num = 0;
    my $len = length($k);
    for (my $i = 0;$i<$len;$i++){
        ++$mismatch_num if substr($k,$i, 1) ne substr($l,$i,1);
    }
    return $mismatch_num
}

