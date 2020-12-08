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
    my @code;
    my $accum = 0;

#---------------------------------------------------------------------------
sub loadCode(@) {
#---------------------------------------------------------------------------
    my $line = $_[0];
    my @inst = split /\ /, $line;
    @inst[1] *= 1;
    push @inst, 0;
    foreach my $item (@inst) {
        #print "- ", $item, " " if ( $debug );
    }
    #print "\n" if ( $debug );
    push @code, [ @inst ];
}

#---------------------------------------------------------------------------
sub brocess {
#---------------------------------------------------------------------------

    my $codePos = 0;
    my $break = 0;

    printf( "Code Lines: %d\n", scalar @code );
    while ( $break == 0 ) {
        printf( "%3d: %s %5d (%d) - %d\n",$codePos, $code[$codePos][0], $code[$codePos][1], $code[$codePos][2], $accum );
        if ( $code[$codePos][2] == 0 ) {
            $code[$codePos][2]++;
            if ( $code[$codePos][0] eq "acc" ) {
                $accum += $code[$codePos][1];
                $codePos++;
            }
            if ( $code[$codePos][0] eq "jmp" ) {
                my $newCodePos = $codePos + $code[$codePos][1];
                if  ( ( $newCodePos < 0 ) || ( $newCodePos > scalar @code ) ) {
                    printf( "jmp out of bounds at %d (%s %d). Accumulator = %d\n", $codePos, $code[$codePos][0], $code[$codePos][1], $accum );
                    $break++;
                } else {
                    $codePos = $newCodePos;
                }

            }
            if ( $code[$codePos][0] eq "nop" ) {
                $codePos++;
            }

            if ( $codePos > scalar @code ) {
                printf( "Run complete. Accumulator = %d\n", $accum );
                $break++;
            }
        } else {
            printf( "Infinite Loop Detected. Instruction %d (%s) being run twice.  Accumulator = %d\n", $codePos, $code[$codePos][0], $accum );
            $break++;
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
        #printf( "%4d: %s\n", $dataLineCount, $line ) if ( $debug );

        # do the needful
        loadCode( $ line );
    }

    close( $fh );
    printf( "Data Lines Loaded: %d\n\n", $dataLineCount );

    brocess();

} else {
    my $programName = $0;
    $programName =~ s/.*\///;
    print( "Usage:\n\n");
    print( "     $programName <data file>\n")
}
