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
	my $count = 0;
	$groupCount++;
	printf( "Group %3d: %s\n", $groupCount, $data ) if ( $debug );

	my @chars = split //, $data;
	my @sortedChar = sort @chars;

	print "-- " if ($debug );

	my $lastChar = "";
	foreach my $char (@sortedChar) {
		print $char if ($debug );
		if ( $char ne $lastChar ) {
			$count++;
			$lastChar = $char;
    		print "+" if ($debug );
		}
		print " " if ($debug );
	}
	print "\n	" if ($debug );

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

	foreach my $line (@lines) {
		$line =~ s/\R\z//;
		$lineCount++;

		if ( $line eq "" ) {
			#Process Group
			$total += processGroup( $groupData );
			$groupData = "";
		} else {
			$groupData .= $line;
		}
	}
	close($fh);

	$total += processGroup( $groupData );

	print "Line Count: ", $lineCount, "\n";
	print "Group Count: ", $groupCount, "\n";
	print "Total: ", $total, "\n";

} else {
    print( "Usage:\n\n");
    print( "     seat-check.pl <data file>\n" )
}
