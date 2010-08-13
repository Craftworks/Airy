package Airy::Util;

use strict;
use warnings;
use File::Spec;

sub class2dir($) {
    my $class = shift;
    $class =~ s{::}{/}go;
    if ( my $path = $INC{"$class.pm"} ) {
        $path =~ s{(?:blib/)?lib/+$class\.pm$}{}o;
        File::Spec->rel2abs($path || '.');
    }
    else {
        File::Spec->rel2abs('.');
    }
}

1;
