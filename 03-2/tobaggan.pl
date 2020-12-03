#!/usr/bin/perl -w
use locale;
use strict;

#---------------------------------------------------------------------------
# Load modules
#---------------------------------------------------------------------------


#---------------------------------------------------------------------------
# Config
#---------------------------------------------------------------------------

    my $over = 1;
    my $down = 1;
    my $file = "-";
    my $treeCount = 0;
    my $vPos = 1;
    my $hPos = 1;
    my $hMax = -1;

#---------------------------------------------------------------------------
# Main
#---------------------------------------------------------------------------

if ( @ARGV > 0 ) {

    print( " Over: ", $ARGV[0], "\n" );
    print( " Down: ", $ARGV[1], "\n" );
    print( " Data: ", $ARGV[2], "\n\n" );
    $over = $ARGV[0];
    $down = $ARGV[1];
    $file = $ARGV[2];
    open( my $fh, $file );
    my @lines = <$fh>;
    #print @lines;
    print( "Lines: ", $#lines, "\n" );
    #print( " Last: ", $lines[-1], "\n");
    $hMax = length( $lines[-1] );
    print( " hMax: ", $hMax, "\n\n");

    for ( $vPos = 0; $vPos <= $#lines; $vPos+=$down ) {
        my $currLine = $lines[ $vPos ];
        $currLine =~ s/\R\z//;
        my $currLineSave = $currLine;
        # $currLine .= $currLine;
        my $currPos = substr( $currLine, ( $hPos - 1 ), 1 );
        my $currSave = $currPos;
        if ( $currPos eq '#' ) {
            $currPos = 'X';
            $treeCount += 1;
        } else {
            $currPos = 'O';
        }
        if ( $hPos == 1 ) {
            $currLine = $currPos . substr( $lines[ $vPos ], $hPos, ( $hMax - $hPos ) );
        } else {
            $currLine = substr( $lines[ $vPos ], 0, ( $hPos - 1 ) ) . $currPos . substr( $lines[ $vPos ], $hPos, ( $hMax - $hPos ) );
        }
        #print( $vPos, ",", $hPos, " - ", $currLine, "\n" );
        #printf "%3d           %s\n", $vPos, $currLineSave;
        printf "%3d,%3d - %s - %s\n", $vPos, $hPos, $currSave, $currLine;
        $hPos += $over;
        if ( $hPos > $hMax ) {
            $hPos -= $hMax;
        }
    }

    print( "Trees: ", $treeCount, "\n");

} else {
    print( "Usage:\n\n");
    print( "     tobaggan.pl <h move> <v move> <data file>")
}