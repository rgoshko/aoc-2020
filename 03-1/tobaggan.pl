#!/usr/bin/perl -w
use locale;
use strict;

#---------------------------------------------------------------------------
# Load modules
#---------------------------------------------------------------------------


#---------------------------------------------------------------------------
# Config
#---------------------------------------------------------------------------

    my $over = 3;
    my $down = 1;
    my $treeCount = 0;
    my $vPos = 1;
    my $hPos = 1;
    my $hMax = -1;

#---------------------------------------------------------------------------
# Main
#---------------------------------------------------------------------------

    my @lines = <>;
    #print @lines;
    print( "Lines: ", $#lines, "\n" );
    print( " Last: ", $lines[-1], "\n");
    $hMax = length( $lines[-1] );
    print( " hMax: ", $hMax, "\n");

    for ( $vPos = 0; $vPos <= $#lines; $vPos++ ) {
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
        $hPos = $hPos + 3;
        if ( $hPos > $hMax ) {
            $hPos -= $hMax;
        }
    }

    print( "Trees: ", $treeCount, "\n");
