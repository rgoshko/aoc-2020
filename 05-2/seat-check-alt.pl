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
sub strToDec(@) {
#---------------------------------------------------------------------------
	my $src   = reverse $_[0];
	my $on    = $_[1];
	my $value = 0;

	print "-- ", $_[0], " -> ", $src if ( $debug );

	for ( my $loop = 0; $loop < length( $src ); $loop++ ) {
		if ( substr( $src, $loop, 1 ) eq $on ) {
			print " - ", $loop, " = ", 2 ** $loop if ( $debug );
			$value += 2 ** $loop;
		}
	}
	print "\n" if ( $debug );

	return $value;
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
		my $row = strToDec( substr( $line, 0, 7 ), "B" );
		my $seat = strToDec( substr( $line, 7, 3 ), "R" );
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
		if ( $rows[$loop][1] == 7 ) {
			printf( "%3d - %s\n", $loop, $rows[$loop][0] );
			for ( my $loop2 = 0; $loop2 < length( $rows[$loop][0] ); $loop2++ ) {
				if ( substr( $rows[$loop][0], $loop2, 1) eq "." ) {
					print "My Seat ID = ", ( $loop * 8 ) + $loop2, "\n";
				}
			}
		}
	}

} else {
    print( "Usage:\n\n");
    print( "     seat-check.pl <data file>\n" )
}
