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
    my @adapters;
    my $adapterMax = 0;

#---------------------------------------------------------------------------
sub walkTheChain() {
#---------------------------------------------------------------------------

    my @joltDiff = qw/ 0 0 1 /; # our target can take 3 jolts diff from the last adapter ;) so 1 extra 3 JD
    my $currJolt = 0;
    my $loop;

    for ( $loop = 0; $loop < $adapterMax; $loop++) {
        my $currDiff = $adapters[$loop] - $currJolt;
        printf( "[%4d] %4d - CJ: %4d - DJ: %d\n", $loop, $adapters[$loop], $currJolt, $currDiff ) if ( $debug );
        if ( $currDiff <= 3 ) {
            $currDiff -= 1;
            $joltDiff[ $currDiff ]++;
            $currJolt = $adapters[$loop];
        } else {
            printf("OVER JOLTAGE!\n");
            $loop += ( $adapterMax * 2 );
        }
    }

    if ( $loop == $adapterMax ) {
        for ($loop = 0; $loop < 3; $loop++) {
            printf( "[%4d] %3d %d Jolt Differences\n", $loop, $joltDiff[$loop], $loop+1 );
        }
        printf( "%3d (1 JD) x %3d (3 JD) = %d\n", $joltDiff[0], $joltDiff[2], ($joltDiff[0] * $joltDiff[2]) );
    }
}

#---------------------------------------------------------------------------
sub dumpAdapters() {
#---------------------------------------------------------------------------
    for (my $loop = 0; $loop <= $adapterMax; $loop++) {
        printf( "[%4d] %4d\n", $loop, $adapters[$loop] );
    }
}

#---------------------------------------------------------------------------
# Main
#---------------------------------------------------------------------------

my $programName = $0;
$programName =~ s/.*\///;
print( "$programName -- Jolt Chain -- AoC Day 10 -- Part 1\n\n");

if ( @ARGV > 0 ) {

    my $file = $ARGV[0];
    printf( "Source Data File: %s\n", $file );

    open( my $fh, $file );
    my @lines = <$fh>;
    my @temp;

    foreach my $line (@lines) {
        # Strip CR/LF
        chomp($line);

        $dataLineCount++;
        printf( "%4d: %s\n", $dataLineCount, $line ) if ( $debug );

        # do the needful
        $line *= 1;
        push @temp, $line;
        $adapterMax++;

    }
    close( $fh );
    printf( "Data Lines Loaded: %d\n\n", $dataLineCount );
    @adapters = sort { $a <=> $b } @temp;

    dumpAdapters() if ( $debug );
    walkTheChain();

} else {
    print( "Usage:\n\n");
    print( "     $programName <data file>\n")
}
