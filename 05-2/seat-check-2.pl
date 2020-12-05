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

#---------------------------------------------------------------------------
sub getSeat(@) {
#---------------------------------------------------------------------------

	my $seatID = substr( $_[0], 7, 3 );
	my $seat = -1;
	my $min = 0;
	my $max = 7;
	print "-- ", $seatID, "\n" if ( $debug );

    for ( my $loop = 0; $loop < 3; $loop++ ) {
    	my $check = substr( $seatID, $loop, 1 );
    	my $half = ( $max - $min + 1 ) /2;
    	if ( $check eq "L" ) {
    		$max -= $half;
    	} else {
    		$min += $half;
    	}
    	printf( "  -- %s - Half: %2d - Min: %3d - Max: %3d\n", $check, $half, $min, $max ) if ( $debug );
    }

	if ( $min == $max ) {
		$seat = $min;
	}

	print " - ", $seat, "\n" if ( $debug );
    return $seat;
}

#---------------------------------------------------------------------------
sub getRow(@) {
#---------------------------------------------------------------------------

	my $rowID = substr( $_[0], 0, 7 );
	my $row = -1;
	my $min = 0;
	my $max = 127;
	print "-- ", $rowID, "\n" if ( $debug );

    for ( my $loop = 0; $loop < 7; $loop++ ) {
    	my $check = substr( $rowID, $loop, 1 );
    	my $half = ( $max - $min + 1 ) /2;
    	if ( $check eq "F" ) {
    		$max -= $half;
    	} else {
    		$min += $half;
    	}
    	printf( "  -- %s - Half: %2d - Min: %3d - Max: %3d\n", $check, $half, $min, $max ) if ( $debug );
    }

	if ( $min == $max ) {
		$row = $min;
	}

	print " - ", $row, "\n" if ( $debug );
    return $row;
}

#---------------------------------------------------------------------------
# Main
#---------------------------------------------------------------------------

if ( @ARGV > 0 ) {

    print( " Data: ", $ARGV[0], "\n\n" );
    my $file = $ARGV[0];
    open( my $fh, $file );
    my @lines = <$fh>;
	my $seatCount = 0;
	my $maxCheck = -1;
	my @rows;

	for ( my $loop = 0; $loop < 128; $loop++ ){
		$rows[$loop][0] = "........";
		$rows[$loop][1] = 0;
	}

	foreach my $line (@lines) {

		$line =~ s/\R\z//;
		$seatCount++;
		my $row = getRow( $line );
		my $seat = getSeat( $line );
		my $check = ( $row * 8 ) + $seat;
		printf( "Bording Pass: %s - Row %3d - Seat %1d - Check %d\n", $line, $row, $seat, $check );

		my $str = $rows[$row][0];
		substr( $str, $seat, 1 ) = "X";
		$rows[$row][0] = $str;

		$rows[$row][1] += 1;

		if ( $check > $maxCheck ) {
			$maxCheck = $check;
		}
	}

	close($fh);
	print "Seats Checked: ", $seatCount, "\n";
	print "    Max Check: ", $maxCheck, "\n";

	for ( my $loop = 0; $loop < 128; $loop++ ) {
		if ( $rows[$loop][1] < 8 ) {
			printf( "%3d - %s\n", $loop, $rows[$loop][0] );
		}
	}

} else {
    print( "Usage:\n\n");
    print( "     seat-check.pl <data file>\n" )
}

