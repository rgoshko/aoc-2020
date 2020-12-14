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
	my $startTime = 0;
	my @buses;
	my $totalBusCount = 0;

#---------------------------------------------------------------------------
sub loadBuses(@) {
#---------------------------------------------------------------------------
	my @list = split /\,/, $_[0];
	foreach my $bus (@list) {
		if ( $bus ne "x") {
			printf( "%s\n", $bus ) if ( $debug );
			$bus *= 1;
			$totalBusCount++;
		}
		push @buses, $bus;
	}
	printf( "Total Buses: %d\n", $totalBusCount ) if ( $debug );
}

#---------------------------------------------------------------------------
sub process() {
#---------------------------------------------------------------------------
	my $leaveTime = 0;
	my $leaveBus  = 0;
	my $value     = 0;
	my $time      = $startTime;
	my $departSeq = 0;
	my @cascade;
	my $max = ( scalar @buses ) - 1;

	if ( $debug ) {
		printf( "Time / Bus  " );
		foreach my $bus (@buses) {
			printf ( " %4d ", $bus ) if ( $bus ne "x" );
		}
		print "\n";
	}

	for ( my $loop = 0; $loop <= $max; $loop++ ) {
		$cascade[0][ $loop ] = 0;
		$cascade[1][ $loop ] = 0;
	}

	while ( $departSeq < $totalBusCount ) {
		my $busSeq = 0;
		printf( "%10d: ", $time ) if ( $debug );
		my $trip = 0;
		for ( my $loop = 0; $loop <= $max; $loop++ ) {
			my $bus = $buses[ $loop ];
			if ( $bus ne "x" ) {
				$busSeq++;
				if ( ( $time < $bus ) && ( $loop == $time ) ) {
					print "    * " if ( $debug );
					$cascade[1][ $loop ] = $time;
				} elsif ( ( $time >= $bus ) && ( ( $time % $bus ) == 0 ) ) {
					print "    D " if ( $debug );
					$cascade[1][ $loop ] = $time;
				} else {
					print "    . " if ( $debug );
				}
			} else {
				$cascade[1][ $loop ] = $time;
			}
		}
#		if ( $debug ) {
#			printf( " -" );
#			for ( my $loop = 0; $loop <= $max; $loop++ ) {
#				printf ( " %d", $cascade[1][$loop] );
#			}
#		}
		print "\n" if ( $debug );

		# check
		if ( ( $cascade[1][ $max ] - $cascade[0][0] ) == $max ) {
			my $done = 1;
			for ( my $loop = 1; $loop < $max; $loop++ ) {
				if ( $buses[ $loop ] ne "x" ) {
					if ( ( $cascade[1][$loop] - $cascade[0][0] ) == $loop ) {
					} else {
						$done = 0;
					}
				}
			}
			if ( $done == 1 ) {
				$departSeq = $totalBusCount;
				$value = $cascade[0][0];
			}
		}

		# copy curr to previous
		for ( my $loop = 0; $loop <= $max; $loop++ ) {
			$cascade[0][ $loop ] = $cascade[1][ $loop ];
		}

		$time++;

		if ( not $debug ) {
			if ( ( $time % 100000 ) == 0 ) {
				printf( "%d\n", $time );
			}
		}

	}

	return $value;
}

#---------------------------------------------------------------------------
# Main
#---------------------------------------------------------------------------

my $programName = $0;
$programName =~ s/.*\///;
print( "$programName -- Find the Cascade -- AoC Day 13 -- Part 2\n\n");

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
