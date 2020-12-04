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
sub validateYear(@) {
#---------------------------------------------------------------------------

    my $data  = $_[0];
    my $min   = $_[1];
    my $max   = $_[2];
    my $valid = 0;

    if ( length($data) == 4 ) {
        if ( ( $data >= $min ) && ( $data <= $max ) ) {
            $valid++;
        }
    }

    return $valid;
}

#---------------------------------------------------------------------------
sub fieldValidate(@) {
#---------------------------------------------------------------------------

    my @fields = split( /\ /, $_[0] );
    my $valid = 0;

    foreach my $field (@fields) {
        #print $field, "\n";
        my ( $name, $data ) = split( /:/, $field );
        print "-- ", $name, ": ", $data;
        if ( $name eq "byr" ) {
            if ( validateYear($data,1920,2002) ) {
                $valid++;
                print " - Good";
            } else {
                print " - BAD";
            }
        }
        if ( $name eq "iyr" ) {
            if ( validateYear($data,2010,2020) ) {
                $valid++;
                print " - Good";
            } else {
                print " - BAD";
            }
        }
        if ( $name eq "eyr" ) {
            if ( validateYear($data,2020,2030) ) {
                $valid++;
                print " - Good";
            } else {
                print " - BAD";
            }
        }
        # Height
        if ( $name eq "hgt" ) {
            for ( $data ) {
                if ( /cm/ ) {
                    $data =~ s/cm//;
                    if ( ( $data >= 150 ) && ( $data <= 193 ) ) {
                        $valid++;
                        print " - Good";
                    } else {
                        print " - BAD";
                    }
                }
                if ( /in/ ) {
                    $data =~ s/in//;
                    if ( ( $data >= 59 ) && ( $data <= 76 ) ) {
                        $valid++;
                        print " - Good";
                    } else {
                        print " - BAD";
                    }
                }
            }
        }
        # Hair Colour
        if ( $name eq "hcl" ) {
            for ( $data ) {
                if ( /#[A-Fa-f0-9]{6}/ ) {
                    $valid++;
                    print " - Good";
                } else {
                    print " - BAD";
                }
            }
        }
        # Eye Colour
        if ( $name eq "ecl" ) {
            if ( ( $data eq "amb" ) || ( $data eq "blu" ) || ( $data eq "brn" ) || ( $data eq "gry" ) || ( $data eq "grn" ) || ( $data eq "hzl" ) || ( $data eq "oth" ) ) {
                $valid++;
                print " - Good";
            } else {
                print " - BAD";
            }
        }
        # Passport ID
        if ( $name eq "pid" ) {
            if ( length( $data ) == 9 ) {
                for ( $data ) {
                    if ( /^[0-9]*$/ ) {
                        $valid++;
                        print " - Good";
                    } else {
                        print " - BAD";
                    }
                }
            } else {
                print " - BAD";
            }
        }
        print "\n";
    }
    return $valid;
}

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
                if ( fieldValidate($ppData) == 7 ) {
                    $ppValid++;
                }
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
            if ( fieldValidate($ppData) == 7 ) {
                $ppValid++;
            }
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
