#!/usr/bin/perl -w
use locale;
use strict;

#---------------------------------------------------------------------------
# Load modules
#---------------------------------------------------------------------------


#---------------------------------------------------------------------------
# Config
#---------------------------------------------------------------------------

    my $debug = 0;
    my $dataLineCount = 0;
    my @data;
    my $pointer = 25;
    my $target;

#---------------------------------------------------------------------------
sub getMinMax(@) {
#---------------------------------------------------------------------------

    my $min = $_[0];
    my $max = $_[1];
    my @check;
    my @sorted_check;
    my $end = -1;
    my $total;

    for (my $loop = $min; $loop <= $max; $loop++) {
        $end++;
        my $value = $data[ $loop ] * 1;
        push @check, ( $value );
        printf( "[%4d] %d\n", $end,  $data[ $loop ] ) if ( $debug );
    }
    @sorted_check = sort { $a <=> $b } @check;
    if ( $debug ) {
        foreach my $value (@sorted_check) {
            printf( "%15d\n", $value );
        }
    }
    $total = $sorted_check[0] + $sorted_check[$end];
    printf( "Min %d + Max %d = %d\n", $sorted_check[0], $sorted_check[$end], $total );
}

#---------------------------------------------------------------------------
sub findRange() {
#---------------------------------------------------------------------------

    my $start = 0;
    my $end   = $pointer-1;
    my $found = 0;
    my $total = 0;

    while ( $found == 0 ) {
        $total = 0;
        for (my $loop = $start; $loop < $end; $loop++) {
            $total += $data[ $loop ];
            if ( $total == $target ) {
                $found = $loop;
            } elsif ( $total > $target ) {
                $loop = $end;
            }
        }
        if ( not $found ) {
            $start++;
            if ( $start == $end ) {
                $found = -1;
            }
        }
    }

    if ( $found > 0 ) {
        printf( "Sequnce Range %d thru %d = %d\n", $start, $found, $target );
        getMinMax( $start, $found );
    } else {
        printf( "NO SEQUENCE FOUND!\n" );
    }

}

#---------------------------------------------------------------------------
sub check(@) {
#---------------------------------------------------------------------------
    my $value = $_[0];
    my $good  = 0;

    for (my $outer = $pointer-25; $outer < $pointer-1; $outer++) {
        for (my $inner = $pointer-24; $inner < $pointer; $inner++) {
            if ( ( $value - $data[$outer] ) == $data[$inner] ) {
                $good = 1;
            }
        }
    }
    return $good;
}

#---------------------------------------------------------------------------
sub process() {
#---------------------------------------------------------------------------

    my $value;
    my $break = 0;
    while ( ( $break == 0) && ( $pointer < scalar @data ) ) {
        $value = $data[$pointer];
        printf( "[%4d] %15d - ", $pointer, $value );
        if ( check( $value) ) {
            printf("Good\n");
            $pointer++;
        } else {
            printf("Bad\n");
            $target = $value;
            $break=1;
        }
    }
}

#---------------------------------------------------------------------------
# Main
#---------------------------------------------------------------------------

if ( @ARGV > 0 ) {

    my $file = $ARGV[0];
    printf( "Source Data File: %s\n", $file );

    open( my $fh, $file );
    my @lines = <$fh>;

    foreach my $line (@lines) {
        # Strip CR/LF
        chomp($line);

        $dataLineCount++;
        # printf( "%4d: %s\n", $dataLineCount, $line ) if ( $debug );

        # do the needful
        push @data, $line;
    }

    close( $fh );
    printf( "Data Lines Loaded: %d\n\n", $dataLineCount );

    process();
    if ( $target ) {
        findRange();
    }

} else {
    my $programName = $0;
    $programName =~ s/.*\///;
    print( "Usage:\n\n");
    print( "     $programName <data file>\n")
}
