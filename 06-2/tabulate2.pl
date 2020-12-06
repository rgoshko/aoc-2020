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
	my $groupCount = 0;
	my $lineCount = 0;
	my $total = 0;

#---------------------------------------------------------------------------
sub processGroup(@) {
#---------------------------------------------------------------------------
	my $data = $_[0];
	my $size = $_[1];
	my $count = 0;
	$groupCount++;
	printf( "Group %3d (%3d): %s\n", $groupCount, $size, $data ) if ( $debug );

	my @chars = split //, $data;
	my @sortedChar = sort @chars;
	my @results;

	print "-- " if ($debug );

	my $lastChar = "";
	my $charCount = 0;

	foreach my $char (@sortedChar) {
		print $char if ($debug );

		if ( $char ne $lastChar ) {
			if ( $lastChar ne "" ) {
	    		push @results, $charCount;
			}
    		print "+ " if ($debug );
			$lastChar = $char;
    		$charCount = 0;
		}
   		$charCount++;
		print " " if ($debug );
	}
	print "\n	" if ($debug );
	push @results, $charCount;
	print "-- ", @results, "\n" if ( $debug );

	foreach my $check (@results) {
		if ( $check == $size ) {
			$count++;
		}
	}

	return $count;
}

#---------------------------------------------------------------------------
# Main
#---------------------------------------------------------------------------

if ( @ARGV > 0 ) {

    print( " Data: ", $ARGV[0], "\n\n" );
    my $file = $ARGV[0];
    open( my $fh, $file );
    my @lines = <$fh>;

	my $groupData = "";
	my $groupSize = 0;

	foreach my $line (@lines) {
		$line =~ s/\R\z//;
		$lineCount++;

		if ( $line eq "" ) {
			#Process Group
			$total += processGroup( $groupData, $groupSize );
			$groupData = "";
			$groupSize=0;
		} else {
			$groupData .= $line;
			$groupSize++;
		}
	}
	close($fh);

	$total += processGroup( $groupData, $groupSize );

	print "Line Count: ", $lineCount, "\n";
	print "Group Count: ", $groupCount, "\n";
	print "Total: ", $total, "\n";

} else {
    print( "Usage:\n\n");
    print( "     seat-check.pl <data file>\n" )
}
