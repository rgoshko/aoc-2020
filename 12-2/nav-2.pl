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
	my @navData;
	my @ship = qw/ 90 0 0 /; # Ship facing east, coordinates 0,0 (x,y)
	my @waypoint = qw/ 10 1 /; # Waypoint coordinates 10 east, 1 north 10,1 (x,y)

#---------------------------------------------------------------------------
sub rotateWaypoint(@) {
#---------------------------------------------------------------------------
	my $dir = $_[0];
	my $deg = $_[1];

	printf( "%s, %3d: [%3d,%3d]", $dir, $deg, $waypoint[0], $waypoint[1] ) if ( $debug );
	if ( $dir eq "R" ) {
		for ( my $loop = 0; $loop < $deg; $loop += 90 ) {
			my $tempX = $waypoint[0] * -1;
			$waypoint[0] = $waypoint[1];
			$waypoint[1] = $tempX;
		}
	} elsif ( $dir eq "L" ) {
		for ( my $loop = 0; $loop < $deg; $loop += 90 ) {
			my $tempY = $waypoint[1] * -1;
			$waypoint[1] = $waypoint[0];
			$waypoint[0] = $tempY;
		}
	}
	printf( " -> %3d,%3d\n", $waypoint[0], $waypoint[1] ) if ( $debug );
}

#---------------------------------------------------------------------------
sub moveWaypoint(@) {
#---------------------------------------------------------------------------
	my $dir  = $_[0];
	my $dist = $_[1];

	printf( "%s, %3d: [%3d,%3d]", $dir, $dist, $waypoint[0], $waypoint[1] ) if ( $debug );
	# North/south - y axis movement
	if ( $dir eq "N" ) {
		$waypoint[1] += $dist;
	}
	if ( $dir eq "S" ) {
		$waypoint[1] -= $dist;
	}
	# East/west - x axis movement
	if ( $dir eq "E" ) {
		$waypoint[0] += $dist;
	}
	if ( $dir eq "W" ) {
		$waypoint[0] -= $dist;
	}
	printf( " -> %3d,%3d\n", $waypoint[0], $waypoint[1] ) if ( $debug );

}

#---------------------------------------------------------------------------
sub moveShip(@) {
#---------------------------------------------------------------------------
	my $dir  = $_[0];
	my $dist = $_[1];

	printf( "%s, %3d: W[%4d, %4d] S[%4d, %4d]", $dir, $dist, $waypoint[0], $waypoint[1], $ship[1], $ship[2] ) if ( $debug );

	$ship[1] += ( $waypoint[0] * $dist );
	$ship[2] += ( $waypoint[1] * $dist );

	printf( " -> S[%4d, %4d]\n", $ship[1], $ship[2] ) if ( $debug );

}

#---------------------------------------------------------------------------
sub navigate() {
#---------------------------------------------------------------------------

	# Action N means to move the waypoint north by the given value.
	# Action S means to move the waypoint south by the given value.
	# Action E means to move the waypoint east by the given value.
	# Action W means to move the waypoint west by the given value.
	# Action L means to rotate the waypoint around the ship left (counter-clockwise) the given number of degrees.
	# Action R means to rotate the waypoint around the ship right (clockwise) the given number of degrees.
	# Action F means to move forward to the waypoint a number of times equal to the given value.

	for ( my $loop = 0; $loop < $dataLineCount; $loop++ ) {

		if ( ( $navData[ $loop ][0] eq "L" ) || ( $navData[ $loop ][0] eq "R" ) ) {
			rotateWaypoint( $navData[ $loop ][0], $navData[ $loop ][1] );
		} elsif ( $navData[ $loop ][0] eq "F" ){
			moveShip( $navData[ $loop ][0], $navData[ $loop ][1] );
		} else {
			moveWaypoint( $navData[ $loop ][0], $navData[ $loop ][1] );
		}
	}

}

#---------------------------------------------------------------------------
# Main
#---------------------------------------------------------------------------

my $programName = $0;
$programName =~ s/.*\///;
print( "$programName -- Navigate -- AoC Day 12 -- Part 1\n\n");

if ( @ARGV > 0 ) {

    my $file = $ARGV[0];
    printf( "Source Data File: %s\n", $file );

    open( my $fh, $file );
    my @lines = <$fh>;

    foreach my $line (@lines) {
        # Strip CR/LF
        chomp($line);

        printf( "[%4d]: %s", $dataLineCount, $line ) if ( $debug );

        # do the needful
        my $cmd = substr $line, 0, 1;
        my $dist = ( substr $line, 1 ) * 1;
        printf( " -- %s -> %d\n" , $cmd, $dist ) if ( $debug );

		$navData[ $dataLineCount ][0] = $cmd;
		$navData[ $dataLineCount ][1] = $dist;
        $dataLineCount++;
    }

    close( $fh );
    printf( "Data Lines Loaded: %d\n\n", $dataLineCount );

	navigate();

} else {
    print( "Usage:\n\n");
    print( "     $programName <data file>\n")
}
