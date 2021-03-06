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

#---------------------------------------------------------------------------
# Main
#---------------------------------------------------------------------------

my $programName = $0;
$programName =~ s/.*\///;
print( "$programName -- [name]] -- AoC Day xx -- Part 1/2\n\n");

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
    }

    close( $fh );
    printf( "Data Lines Loaded: %d\n\n", $dataLineCount );

} else {
    print( "Usage:\n\n");
    print( "     $programName <data file>\n")
}
