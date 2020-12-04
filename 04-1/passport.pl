#!/usr/bin/perl -w
use locale;
use strict;

#---------------------------------------------------------------------------
# Load modules
#---------------------------------------------------------------------------


#---------------------------------------------------------------------------
# Config
#---------------------------------------------------------------------------

my $ppCount=0;
my $ppValid=0;

#---------------------------------------------------------------------------
sub validate(@) {
#---------------------------------------------------------------------------

    my $data = $_[0];
    my $valid = 0;
    my $fieldCheck = 0;

    for ( $data ) {
        if ( /byr/ ) {   # (Birth Year)
            $fieldCheck++;
        }
        if ( /iyr/ ) {   # (Issue Year)
            $fieldCheck++;
        }
        if ( /eyr/ ) {   # (Expiration Year)
            $fieldCheck++;
        }
        if ( /hgt/ ) {   # (Height)
            $fieldCheck++;
        }
        if ( /hcl/ ) {   # (Hair Color)
            $fieldCheck++;
        }
        if ( /ecl/ ) {   # (Eye Color)
            $fieldCheck++;
        }
        if ( /pid/ ) {   # (Passport ID)
            $fieldCheck++;
        }
        #if ( /cid/ ) {   # (Country ID)
        #    $fieldCheck++;
        #}
    }

    if ( $fieldCheck >= 7 ) {
        $valid++;
    }

    return $valid;

}

#---------------------------------------------------------------------------
# Main
#---------------------------------------------------------------------------

if ( @ARGV > 0 ) {

    print( " Data: ", $ARGV[0], "\n\n" );
    my $file = $ARGV[0];
    open( my $fh, $file );
    my @lines = <$fh>;
    my $ppData = "";

    foreach my $line (@lines) {
        # Strip CR/LF
        $line =~ s/\R\z//;

        if ( $line eq "" ) {
            $ppCount++;

            if ( validate($ppData) ) {
                $ppValid++;
            }
            printf( "Passport %3d: %s\n", $ppCount, $ppData );

            $ppData = "";

        } else {
            if ( $ppData ne "" ) {
                $ppData .= " ";
            }
            $ppData .= $line
        }
    }

    if ( $ppData ne "" ) {
        $ppCount++;

        if ( validate($ppData) ) {
            $ppValid++;
        }
        printf( "Passport %3d: %s\n", $ppCount, $ppData );

        $ppData = "";

    }

    print "Passports: ", $ppCount, "\n";
    print "    Valid: ", $ppValid, "\n";

} else {
    print( "Usage:\n\n");
    print( "     passport.pl <data file>")
}
