#!/usr/bin/perl -w
use locale;
use strict;

#---------------------------------------------------------------------------
# Load modules
#---------------------------------------------------------------------------

use Data::Dumper;

#---------------------------------------------------------------------------
# Config
#---------------------------------------------------------------------------

    my $debug = 1;
    my $dataLineCount = 0;
    my %memory;
    my $mask = "";

#---------------------------------------------------------------------------
sub bin2dec {
#---------------------------------------------------------------------------
    my $binVal = $_[0];
    my $len = ( length $binVal ) - 1;
    my $value = 0;
    for (my $loop = 0; $loop <= $len; $loop++) {
        if ( substr( $binVal, $loop, 1 ) eq "1" ) {
#            printf( "%d - %d = %d -- 2^%d = %d\n",$len, $loop, $len - $loop, $len - $loop, ( 2**( $len - $loop ) ) );
            $value += ( 2**( $len - $loop ) );
        }
    }
    return $value;
}

#---------------------------------------------------------------------------
sub applyMask(@) {
#---------------------------------------------------------------------------

    my $value = $_[0];
    my $bin_value = sprintf( "%036b", $value );
    my $bin_mask_val = "";

    printf( "%10d -> %s\n", $value, $bin_value ) if ( $debug );
    printf( "      Mask -> %s\n", $mask ) if ( $debug );
    for ( my $loop = 0; $loop < length $mask ; $loop++ ) {
        my $bit = substr( $bin_value, $loop, 1 );
        if ( substr( $mask, $loop, 1 ) eq "X" ) {
            $bit = 'X';
        } else {
#            if ( ( substr( $mask, $loop, 1 ) eq "0" ) && ( $bit eq "1" ) ) {
#                    $bit = "0";
#            }
            if ( ( substr( $mask, $loop, 1 ) eq "1" ) && ( $bit eq "0" ) ) {
                    $bit = "1";
            }
        }
        $bin_mask_val .= $bit;
    }
#    $value = oct("0b".$bin_mask_val);
    printf( "           -> %s\n", $bin_mask_val ) if ( $debug );
    return $bin_mask_val;
}

#---------------------------------------------------------------------------
sub buildMemList(@) {
#---------------------------------------------------------------------------
    my $keyMask = $_[0];
    my $wiggleBit = () = $keyMask =~ /X/g;
    my @memaddr = ();
    my $maxWiggleLen = length( sprintf( "%b", ( 2 ** $wiggleBit ) - 1 ) );
    for (my $wiggleLoop = 0; $wiggleLoop < ( 2 ** $wiggleBit ); $wiggleLoop++) {
        my $maskBits = substr( sprintf( "%036b", $wiggleLoop ), 36 - $maxWiggleLen );
        # printf( "[%6d]: (%d) %s\n", $wiggleLoop, $maxWiggleLen, $maskBits ) if ( $debug );
        my $tempAddr = $keyMask;
        for (my $bitLoop = 0; $bitLoop < $maxWiggleLen; $bitLoop++) {
            my $bit = substr( $maskBits, $bitLoop, 1 );
            $tempAddr =~ s/X/${bit}/;
        }
        # printf( "              %s -> %s\n", $keyMask, $tempAddr ) if ( $debug );
        push @memaddr, $tempAddr
    }
    #print Dumper(\@memaddr), "\n" if ( $debug );

    return @memaddr;
}
#---------------------------------------------------------------------------
sub writeToMem(@) {
#---------------------------------------------------------------------------

    my $key   = $_[0];
    my $value = $_[1];

    my $key_mask = applyMask( $key );
    #$memory{ $key } = $value;

    if ( $key_mask =~ m/X/ ) {
        # 1 or more wiggly bits
        my $wiggleBit = () = $key_mask =~ /X/g;
        printf( "Wiggly Bit -> %d\n", $wiggleBit ) if ( $debug );
        my @addrList = buildMemList( $key_mask );
        foreach my $binAddr (@addrList) {
            $key = bin2dec( $binAddr );
            $memory{ $key } = $value;
        }
    } else {
        # Single write, no wiggly bit
        $key = bin2dec( $key_mask );
        $memory{ $key } = $value;
    }

}

#---------------------------------------------------------------------------
sub process(@) {
#---------------------------------------------------------------------------

    my $line = $_[0];

    if ( $line =~ m/^mask/ ) {
        my $temp = $line;
        $temp =~ s/.*\ //;
        $mask = $temp;
        printf( "    Set MASK: %s\n", $mask ) if ( $debug );
    }
    if ( $line =~ m/^mem/ ) {
        my $key = $line;
        $key =~ s/^mem\[//;
        $key =~ s/\].*//;
        my $value = $line;
        $value =~ s/.*\ =\ //;
        $value *= 1;
        printf( "MEM [%6s]: %d\n", $key, $value ) if ( $debug );
        writeToMem( $key, $value );
    }

}

#---------------------------------------------------------------------------
# Main
#---------------------------------------------------------------------------

my $programName = $0;
$programName =~ s/.*\///;
print( "$programName -- Docking -- AoC Day 14 -- Part 1\n\n");

if ( @ARGV > 0 ) {

    my $file = $ARGV[0];
    printf( "Source Data File: %s\n", $file );

    open( my $fh, $file );
    my @lines = <$fh>;

    foreach my $line (@lines) {
        # Strip CR/LF
        chomp($line);

        $dataLineCount++;
#        printf( "%4d: %s\n", $dataLineCount, $line ) if ( $debug );

        # do the needful
        process( $line );
    }

    close( $fh );
    printf( "Data Lines Loaded: %d\n\n", $dataLineCount );

#    print Dumper(\%memory), "\n";

    my $output = 0;
    foreach my $key ( keys %memory) {
        $output += $memory{$key};
    }
    print "Total: ", $output, "\n";
} else {
    print( "Usage:\n\n");
    print( "     $programName <data file>\n")
}
