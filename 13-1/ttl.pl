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
	my $startTime = 0;
	my @buses;

#---------------------------------------------------------------------------
sub loadBuses(@) {
#---------------------------------------------------------------------------
	my @list = split /\,/, $_[0];
	foreach my $bus (@list) {
		if ( $bus ne "x") {
			printf( "%s\n", $bus ) if ( $debug );
			$bus *= 1;
			push @buses, $bus;
		}
	}
}

#---------------------------------------------------------------------------
sub process() {
#---------------------------------------------------------------------------
	my $leaveTime = 0;
	my $leaveBus  = 0;
	my $value     = 0;
	my $time      = $startTime;

	if ( $debug ) {
		printf( "Time / Bus  " );
		foreach my $bus (@buses) {
			printf ( " %4d ", $bus );
		}
		print "\n";
	}

	while ( $leaveTime == 0 ) {
		printf( "%10d: ", $time ) if ( $debug );
		foreach my $bus (@buses) {
			if ( ( $time % $bus ) == 0 ) {
				print "    D " if ( $debug );
				$leaveTime = $time if ( $leaveTime == 0 );
				$leaveBus  = $bus  if ( $leaveBus == 0 )
			} else {
				print "    . " if ( $debug );
			}
		}
		print "\n";
		$time++;
	}

	$value = ( $leaveTime - $startTime ) * $leaveBus if ( $leaveTime );

	return $value;
}

#---------------------------------------------------------------------------
# Main
#---------------------------------------------------------------------------

my $programName = $0;
$programName =~ s/.*\///;
print( "$programName -- Time To Leave -- AoC Day 13 -- Part 1\n\n");

if ( @ARGV > 0 ) {

    my $file = $ARGV[0];
    printf( "Source Data File: %s\n", $file );

    open( my $fh, $file );
    my @lines = <$fh>;

    foreach my $line (@lines) {
        # Strip CR/LF
        chomp($line);

        $dataLineCount++;
        printf( "%4d: %s\n", $dataLineCount, $line ) if ( $debug );

        # do the needful
        if ( $dataLineCount == 1 ) {
        	$startTime = $line * 1;
        } else {
        	loadBuses($line);
        }
    }

    close( $fh );
    printf( "Data Lines Loaded: %d\n\n", $dataLineCount );

	my $value = process();
	printf( "%d is the value\n", $value );

} else {
    print( "Usage:\n\n");
    print( "     $programName <data file>\n")
}
