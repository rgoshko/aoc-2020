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
    my $lineCount = 0;
    my %rules;
    my $target = "";
    my $level = 0;

    sub getContents(@); # Recursive sub

#---------------------------------------------------------------------------
sub addRule(@) {
#---------------------------------------------------------------------------

    my $rule = $_[0];
    my $key;
    my $data;
    my @values;
    my @list;

    ($key, $data) = split /\ contain\ /, $rule;
    # Remove bag(s) from the end of the key, they are all bags
    $key =~ s/\ bag.*//;
    printf( "-- %s: %s\n", $key, $data) if ( $debug );
    @values = split /\,/, $data;
    print "---- ", scalar @values, ": ", @values, "\n" if ( $debug );
    foreach my $value (@values) {
        $value =~ s/^\s+|\s+$//g;
        $value =~ s/\ bag.*$//;
        my $count = $value;
        my $item = $value;
        if ( $value ne "no other" ) {
            $count =~ s/\ .*$//g;
            $count *= 1;
        } else {
            $count = 0;
        }
        $item =~ s/^[0-9]*\ //;
        printf( " - contains %d %s bags\n", $count, $item ) if ( $debug );
        push @list, [ $count, $item ];
    }
    for ( my $loop = 0; $loop < scalar @list; $loop++ ) {
        printf ( "    - %d: %d, %s\n", $loop, $list[$loop][0],$list[$loop][1]) if ( $debug );
    }
    $rules{ $key } = [ @list ];
    print "\n" if ( $debug );
}

#---------------------------------------------------------------------------
sub dumpRules() {
#---------------------------------------------------------------------------

    for my $rule ( keys %rules ) {
        print ( "Rule: ", $rule, "\n" );
        for my $loop ( 0 .. $#{ $rules{ $rule } } ) {
            print " - Loop: ", $loop;
            my @list = $rules{$rule}[$loop];
            for ( my $loop2 = 0; $loop2 < scalar @list; $loop2++ ) {
                printf ( " - %d: %s\n", $list[$loop2][0], $list[$loop2][1] );
            }
        }
        print "\n";
    }
}

#---------------------------------------------------------------------------
sub getContents(@) {
#---------------------------------------------------------------------------

    my $count = 0;
    my $number = $_[0];
    my $check = $_[1];

    printf ( "%-*s%s\n", ( $level * 2 ) + 1, " ", $check ) if ( $debug );
    for my $loop ( 0 .. $#{ $rules{ $check } } ) {
        my @list = $rules{ $check }[ $loop ];
        for ( my $loop2 = 0; $loop2 < scalar @list; $loop2++ ) {
            printf ( "%-*s - %d: %s = + %d bags\n", ( $level * 2 ) + 1, " ", $list[$loop2][0], $list[$loop2][1], $list[$loop2][0] * $number) if ( $debug );
            if ( $list[$loop2][0] > 0 ) {
                $count += ( $list[$loop2][0] * $number );
                printf ( "%-*s - %d * %d = %d\n", ( $level * 2 ) + 1, " ", $list[$loop2][0], $number, $count ) if ( $debug );
                $level++;
                $count += ( $number * getContents( $list[$loop2][0], $list[$loop2][1] ) );
                $level--;
                printf ( "%-*s - Total: %d\n", ( $level * 2 ) + 1, " ", $count ) if ( $debug );
            }
        }
    }

    return $count;
}

#---------------------------------------------------------------------------
# Main
#---------------------------------------------------------------------------

if ( @ARGV > 1 ) {

    my $file = $ARGV[0];
    $target = lc $ARGV[1];
    printf( "            Rules: %s\n", $file );
    printf( "Target Bag Colour: %s\n\n", $target );

    open( my $fh, $file );
    my @lines = <$fh>;

    foreach my $line (@lines) {
        # Strip CR/LF
        chomp($line);
        # remove trailing period
        $line =~ s/\.$//;

        printf( "%3d: %s\n", $lineCount, $line ) if ( $debug );
        addRule( $line );
        $lineCount++;

    }

    print "Data Lines Loaded: ", $lineCount, "\n\n";

    dumpRules() if ( $debug );

    my $bagContents = getContents( 1, $target );

    printf( "\n%s contains %d bags\n", $target, $bagContents );

} else {
    print( "Usage:\n\n");
    print( "     bag-check-2.pl <data file> <bag colour>\n")
}
