#!/usr/bin/perl -w
use locale;
use strict;

#---------------------------------------------------------------------------
# Load modules
#---------------------------------------------------------------------------


#---------------------------------------------------------------------------
# Config
#---------------------------------------------------------------------------

    my $debug = 1;
    my $dataLineCount = 0;
    my @seats;
    my @priorSeats;
    my $maxWidth  = 0;
    my $maxHeight = 0;

#---------------------------------------------------------------------------
sub dumpSeats() {
#---------------------------------------------------------------------------

    for (my $row = 0; $row < $maxHeight; $row++) {
        my $tempPrior ="";
        my $tempCurr  ="";

        for (my $seat = 0; $seat < $maxWidth; $seat++) {
            $tempPrior .= $priorSeats[ $row ][ $seat ];
            $tempCurr  .= $seats[ $row ][ $seat ];
        }
        printf( "[%2d] P:%s  C:%s\n", $row, $tempPrior, $tempCurr );
    }
}

#---------------------------------------------------------------------------
sub countSeats() {
#---------------------------------------------------------------------------

    my $count = 0;
    for (my $row = 0; $row < $maxHeight; $row++) {
        for (my $seat = 0; $seat < $maxWidth; $seat++) {
            $count++ if( $seats[ $row ][ $seat ] eq "#" );
        }
    }
    return $count;
}

#---------------------------------------------------------------------------
sub countOccupied(@) {
#---------------------------------------------------------------------------

    my $row   = $_[0];
    my $seat  = $_[1];
    my $count = 0;

    my $priorRow = $row - 1;
    $priorRow = $maxHeight - 1 if ( $priorRow < 0 );
    my $nextRow  = $row + 1;
    $nextRow = 0 if ( $nextRow >= $maxHeight );
    my $priorSeat = $seat - 1;
    $priorSeat = $maxWidth - 1 if ( $priorSeat < 0 );
    my $nextSeat = $seat + 1;
    $nextSeat = 0 if ( $nextSeat >= $maxWidth );

    #printf ( "[%2d]: %2d %2d %2d | [%2d]: %2d %2d %2d | [%2d]: %2d %2d %2d\n", $priorRow, $priorSeat, $seat, $nextSeat, $row, , $priorSeat, $seat, $nextSeat, $nextRow, $priorSeat, $seat, $nextSeat);
    # prior row checks
    if ( $priorRow < $row ) {
        if ( $priorSeat < $seat ) {
            $count++ if ( $priorSeats[ $priorRow ][ $priorSeat ] eq "#" );
        }
        $count++ if ( $priorSeats[ $priorRow ][ $seat ] eq "#" );
        if ( $nextSeat > $seat ) {
            $count++ if ( $priorSeats[ $priorRow ][ $nextSeat ] eq "#" );
        }
    }
    # current row checks
    if ( $priorSeat < $seat ) {
        $count++ if ( $priorSeats[ $row ][ $priorSeat ] eq "#" );
    }
    if ( $nextSeat > $seat ) {
        $count++ if ( $priorSeats[ $row ][ $nextSeat ] eq "#" );
    }
    # next row checks
    if ( $nextRow > $row ) {
        if ( $priorSeat < $seat ) {
            $count++ if ( $priorSeats[ $nextRow ][ $priorSeat ] eq "#" );
        }
        $count++ if ( $priorSeats[ $nextRow ][ $seat ] eq "#" );
        if ( $nextSeat > $seat ) {
            $count++ if ( $priorSeats[ $nextRow ][ $nextSeat ] eq "#" );
        }
    }
    return $count;
}

#---------------------------------------------------------------------------
sub processRow(@) {
#---------------------------------------------------------------------------

    my $row = $_[0];
    my $changeFlag = 0;

    #printf("[%2d]:", $row );
    for (my $seat = 0; $seat < $maxWidth; $seat++) {
        if ( $seats[ $row ][ $seat ] ne "." ) { # floor, no change
            my $count = countOccupied( $row, $seat );
            #my $count = 0;
            #printf(" %2d", $seat );
            if ( ( $seats[ $row ][ $seat ] eq "L" ) && ( $count == 0 ) ) {
                $seats[ $row ][ $seat ] = "#";
                $changeFlag += 1;
            } elsif ( ( $seats[ $row ][ $seat ] eq "#" ) && ( $count >= 4 ) ) {
                $seats[ $row ][ $seat ] = "L";
                $changeFlag += 1;
            }
        }
    }
    #print "\n";
    return $changeFlag;
}

#---------------------------------------------------------------------------
sub setPriorSeats() {
#---------------------------------------------------------------------------

    @priorSeats = ();
    for (my $row = 0; $row < $maxHeight; $row++) {
        for (my $seat = 0; $seat < $maxWidth; $seat++) {
            $priorSeats[ $row ][ $seat ] = $seats[ $row ][ $seat ];
        }
    }

}

#---------------------------------------------------------------------------
sub shiftSeats() {
#---------------------------------------------------------------------------

    my $changeFlag = 0;
    setPriorSeats();

    for (my $row = 0; $row < $maxHeight; $row++) {
        $changeFlag += processRow( $row );
        #printf("[%2d]: %d\n", $row, $changeFlag );
    }
    return $changeFlag;
#    return 0;
}


#---------------------------------------------------------------------------
sub process() {
#---------------------------------------------------------------------------

    my $changeFlag = 1;
    my $iterations = 0;
    while ( $changeFlag != 0 ) {
        $changeFlag = shiftSeats();
        $iterations++;
        printf( "[%5d]: %d\n", $iterations, $changeFlag );
        # dumpSeats();
    }

    return $iterations;
}

#---------------------------------------------------------------------------
sub loadSeats(@) {
#---------------------------------------------------------------------------

    my $row  = $_[0];
    my $data = $_[1];

    printf( "[%3d]: ", $row ) if ( $debug );

    for (my $seat = 0; $seat < length( $data ); $seat++) {
        $seats[ $row ][ $seat ] = substr $data, $seat, 1;
        print $seats[ $row ][ $seat ] if ( $debug );
    }
    if ( length( $data ) - 1 > $maxWidth ) {
        $maxWidth = length( $data ) - 1;
    }
    print "\n"  if ( $debug );
}

#---------------------------------------------------------------------------
# Main
#---------------------------------------------------------------------------

my $programName = $0;
$programName =~ s/.*\///;
print( "$programName -- Game of Seats -- AoC Day 11 -- Part 1\n\n");

if ( @ARGV > 0 ) {

    my $file = $ARGV[0];
    printf( "Source Data File: %s\n", $file );

    open( my $fh, $file );
    my @lines = <$fh>;

    foreach my $line (@lines) {
        # Strip CR/LF
        chomp($line);

        $dataLineCount++;
        #printf( "[%3d]: %s\n", $dataLineCount, $line ) if ( $debug );

        # do the needful
        loadSeats( $dataLineCount-1, $line );
    }

    close( $fh );
    printf( "Data Lines Loaded: %d\n\n", $dataLineCount );

    $maxHeight = $dataLineCount;

    printf ( " Max Width: %d\n", $maxWidth );
    printf ( "Max Height: %d\n", $maxHeight );

    printf ( "0,0: %s - 0,%d: %s\n", $seats[0][0], $maxWidth-1, $seats[0][$maxWidth-1] );
    printf ( "%d,0: %s - %d,%d: %s\n", $maxHeight-1, $seats[$maxHeight-1][0], $maxHeight-1, $maxWidth-1, $seats[$maxHeight-1][$maxWidth-1] );

    my $loopCount = process();
    printf ( "Iterations: %d\n", $loopCount );
    my $occupiedCount = countSeats();
    printf ( "  Occupied: %d\n", $occupiedCount );

} else {
    print( "Usage:\n\n");
    print( "     $programName <data file>\n")
}
