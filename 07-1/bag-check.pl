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
    my $lineCount = 0;
    my %rules;
    my %parents;
    my $target = "";
    my %containers;
    my %checked;
    my $level = 0;

#---------------------------------------------------------------------------
sub addRule(@) {
#---------------------------------------------------------------------------

    my $rule = $_[0];
    my $key;
    my $data;
    my @values;

    ($key, $data) = split /\ contain\ /, $rule;
    # Remove bag(s) from the end of the key, they are all bags
    $key =~ s/\ bag.*//;
    printf( "-- %s: %s\n", $key, $data) if ( $debug );
    @values = split /\,/, $data;
    print "---- ", scalar @values, ": ", @values, "\n" if ( $debug );
    $rules{ $key } = [ @values ];
    foreach my $child (@values) {
        $child =~ s/^\s+|\s+$//g;
        $child =~ s/^[0-9]*\ //;
        $child =~ s/\ bag.*$//;
        printf( " - %s is child of %s\n", $child, $key ) if ( $debug );
        my @list;
        my $add = 1;
        if ( exists( $parents{ $child } ) ) {
            for my $loop ( 0 .. $#{ $parents{ $child } } ) {
                push @list, $parents{$child}[$loop];
                # if ( $parents{$child}[$loop] eq $key ) {
                #     $add = 0;
                # }
            }
        }
        if ( $add ) {
            push @list, $key;
            $parents{ $child } = [ @list ];
        }
    }
    print "\n" if ( $debug );
}

#---------------------------------------------------------------------------
sub dumpRules() {
#---------------------------------------------------------------------------

    for my $rule ( keys %rules ) {
        print ( "Rule: ", $rule );
        for my $value ( 0 .. $#{ $rules{ $rule } } ) {
            print " $value = $rules{$rule}[$value]";
        }
        print "\n";
    }
}

#---------------------------------------------------------------------------
sub dumpParents() {
#---------------------------------------------------------------------------

    my $count = 0;
    for my $child ( keys %parents ) {
        print ( "Child: ", $child );
        for my $value ( 0 .. $#{ $parents{ $child } } ) {
            print " $value = $parents{$child}[$value]";
        }
        print "\n";
        $count++;
    }
    print "Children: ", $count, "\n\n";
}

#---------------------------------------------------------------------------
sub dumpChecked() {
#---------------------------------------------------------------------------

    my $count=0;
    for my $check ( keys %checked ) {
        print ( "Check Value: ", $check );
        # for my $loop ( 0 .. $#{ $checked{ $check } } ) {
        #     print " $loop = $checked{$check}[$loop]";
        # }
        print "\n";
        $count++;
    }
    print "Check List Size: ", $count, "\n";
}

#---------------------------------------------------------------------------
sub getContainer(@) {
#---------------------------------------------------------------------------

    my $check = $_[0];
    my $count = 0;
    if ( exists($parents{ $check }) ) {
        for my $loop ( 0 .. $#{ $parents{ $check } } ) {
            printf("%-*s - %3d: %s (%d)\n", ( $level * 2 ) + 1, " ", $loop, $parents{$check}[$loop], $count );
            if ( not exists($checked{ $parents{$check}[$loop] }) ) {
                $count++;
                $level++;
                $count += getContainer($parents{$check}[$loop]);
                $level--;
                $checked{ $parents{$check}[$loop] } = [ $check ];
            } else {
                printf("%-*s - %3d: ALREADY CHECKED %s (%d)\n", ( $level * 2 ) + 1, " ", $loop, $parents{$check}[$loop], $count );
            }
        }

    } else {
        printf( "%-*s   - No parents for %s\n", ( $level * 2 ) + 1, " ", $check);
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
        $line =~ s/\R\z//;
        $line =~ s/\.$//;

        printf( "%3d: %s\n", $lineCount, $line ) if ( $debug );
        addRule( $line );
        $lineCount++;

    }

    print "Data Lines Loaded: ", $lineCount, "\n";

    #dumpRules() if ( $debug );
    #dumpParents() if ( $debug );

    my $bagCount = getContainer( $target);
    print "Possible Parents: ", $bagCount, "\n";
    dumpChecked();

} else {
    print( "Usage:\n\n");
    print( "     bag-check.pl <data file> <bag colour>\n")
}
