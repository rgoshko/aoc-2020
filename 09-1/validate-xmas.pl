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
    my @data;
    my $pointer = 25;

#---------------------------------------------------------------------------
sub check(@) {
#---------------------------------------------------------------------------
    my $value = $_[0];
    my $good  = 0;

    for (my $outer = $pointer-25; $outer < $pointer-1; $outer++) {
        for (my $inner = $pointer-24; $inner < $pointer; $inner++) {
            if ( ( $value - $data[$outer] ) == $data[$inner] ) {
                $good = 1;
            }
        }
    }
    return $good;
}

#---------------------------------------------------------------------------
sub process() {
#---------------------------------------------------------------------------

    my $value;
    my $break = 0;
    while ( ( $break == 0) && ( $pointer < scalar @data ) ) {
        $value = $data[$pointer];
        printf( "[%4d] %15d - ", $pointer, $value );
        if ( check( $value) ) {
            printf("Good\n");
            $pointer++;
        } else {
            printf("Bad\n");
            $break=1;
        }
    }
}
#---------------------------------------------------------------------------
# Main
#---------------------------------------------------------------------------

if ( @ARGV > 0 ) {

    my $file = $ARGV[0];
    printf( "Source Data File: %s\n", $file );

    open( my $fh, $file );
    my @lines = <$fh>;

    foreach my $line (@lines) {
        # Strip CR/LF
        chomp($line);

        $dataLineCount++;
        # printf( "%4d: %s\n", $dataLineCount, $line ) if ( $debug );

        # do the needful
        push @data, $line;
    }

    close( $fh );
    printf( "Data Lines Loaded: %d\n\n", $dataLineCount );

    process();

} else {
    my $programName = $0;
    $programName =~ s/.*\///;
    print( "Usage:\n\n");
    print( "     $programName <data file>\n")
}
