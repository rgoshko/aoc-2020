#!/usr/bin/perl -w
use locale;
use strict;

#---------------------------------------------------------------------------
# Load modules
#---------------------------------------------------------------------------

use Data::Dumper;

#---------------------------------------------------------------------------
# Config
#---------------------------------------------------------------------------

    my $debug = 1;
    my $dataLineCount = 0;
    my %numbers;
    my %prior;

#---------------------------------------------------------------------------
sub numSaid(@) {
#---------------------------------------------------------------------------

    my $turn    = $_[0];
    my $numSaid = $_[1];

    my $says = $numbers{ $numSaid };
    if ( defined $says ) {
        $prior{ $numSaid } = $numbers{ $numSaid };
    } else {
        $prior{ $numSaid } = -1;
    }

    $numbers{ $numSaid } = $turn;

#    print Dumper(\@says), "\n" if ( $debug );

}

#---------------------------------------------------------------------------
# Main
#---------------------------------------------------------------------------

my $programName = $0;
$programName =~ s/.*\///;
print( "$programName -- Number Game -- AoC Day 15 -- Part 1\n\n");

if ( @ARGV > 0 ) {

    my $data = $ARGV[0];
    my $loopMax = $ARGV[1];
    my $loop = 0;
    printf( "Source Data: %s\n", $data );
    printf( "  Max Loops: %d\n", $loopMax );

    my $say = 0;
    my $last = 0;

    foreach my $num ( split( ",", $data ) ) {
        $loop++;
        $num *= 1;
        printf ( "[%4d]: %d\n", $loop, $num );
        #my @said;
        #push @said, -1;
        #push @said, $loop;
        #$numbers{ $num } = $said;
        numSaid( $loop, $num );
        $last = $num;
    }

    print Dumper(\%numbers), "\n" if ( $debug );

    # whole f'n step for the last number befor the loop can start
    $loop ++;
    numSaid( $loop, 0 );
    print "Say 0 to start after initial list and count it as a turn\n";
    $loop ++;

    while ( $loop <= $loopMax ) {
        printf( "[%4d]: Last said %d, ", $loop, $say ) if ( ( $loop % $loopMax ) == 0 );
        my $check = $numbers{ $say };
        if ( ! defined $check ) {
            printf( "%d has never been said before, say 0\n", $say ) if ( ( $loop % $loopMax ) == 0 );
            $say = 0;
        } else {
            if ( $prior{ $say } == -1 ) {
                printf( "%d has never been said before, say 0\n", $say ) if ( ( $loop % $loopMax ) == 0 );
                $say = 0;
            } else {
                my $nextSay = $numbers{ $say } - $prior{ $say };
                printf( "%d last said on turn %d - %d", $say, $numbers{ $say }, $prior{ $say } ) if ( ( $loop % $loopMax ) == 0 );
                printf( ", say %d\n", $nextSay ) if ( ( $loop % $loopMax ) == 0 );
                $say = $nextSay;
            }
        }
        numSaid( $loop, $say );
        $loop++;
    }

    # print Dumper(\%numbers), "\n" if ( $debug );

} else {
    print( "Usage:\n\n");
    print( "     $programName <data> <max Loops>\n")
}
