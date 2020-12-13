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

#---------------------------------------------------------------------------
sub getShipDir() {
#---------------------------------------------------------------------------
	my $dir = " ";
	$dir = "N" if ( $ship[0] == 0 );
	$dir = "E" if ( $ship[0] == 90 );
	$dir = "S" if ( $ship[0] == 180 );
	$dir = "W" if ( $ship[0] == 270 );
	return $dir;
}

#---------------------------------------------------------------------------
sub turn(@) {
#---------------------------------------------------------------------------
	my $dir = $_[0];
	my $deg = $_[1];

	printf( "%s, %3d: [%3d]", $dir, $deg, $ship[0] ) if ( $debug );
	if ( $dir eq "R" ) {
		$ship[0] += $deg;
	} elsif ( $dir eq "L" ) {
		$ship[0] -= $deg;
	}
	if ( $ship[0] >= 360 ) {
		$ship[0] -= 360;
	}
	if ( $ship[0] < 0 ) {
		$ship[0] += 360;
	}
	printf( " -> %3d\n", $ship[0] ) if ( $debug );
}

#---------------------------------------------------------------------------
sub move(@) {
#---------------------------------------------------------------------------
	my $dir  = $_[0];
	my $dist = $_[1];

	if ( $dir eq "F" ) {
		printf( "%s -> ", $dir );
		$dir = getShipDir();
	}
	printf( "%s, %3d: [%4d, %4d]", $dir, $dist, $ship[1], $ship[2] ) if ( $debug );
	# North/south - y axis movement
	if ( $dir eq "N" ) {
		$ship[2] += $dist;
	}
	if ( $dir eq "S" ) {
		$ship[2] -= $dist;
	}
	# East/west - x axis movement
	if ( $dir eq "E" ) {
		$ship[1] += $dist;
	}
	if ( $dir eq "W" ) {
		$ship[1] -= $dist;
	}
	printf( " -> %4d, %4d\n", $ship[1], $ship[2] ) if ( $debug );

}

#---------------------------------------------------------------------------
sub navigate() {
#---------------------------------------------------------------------------

	# Action N means to move north by the given value.
	# Action S means to move south by the given value.
	# Action E means to move east by the given value.
	# Action W means to move west by the given value.
	# Action F means to move forward by the given value in the direction the ship is currently facing.
	# Action L means to turn left the given number of degrees.
	# Action R means to turn right the given number of degrees.

	for ( my $loop = 0; $loop < $dataLineCount; $loop++ ) {

		if ( ( $navData[ $loop ][0] eq "L") || ( $navData[ $loop ][0] eq "R") ) {
			turn( $navData[ $loop ][0], $navData[ $loop ][1] );
		} else {
			move( $navData[ $loop ][0], $navData[ $loop ][1] );
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
