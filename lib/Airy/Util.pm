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

sub is_class_loaded {
    my $class = shift;
    no strict 'refs';
    return 1 if ( defined ${"$class\::VERSION"} || @{"$class\::ISA"} );
    for ( keys %{"$class\::"} ) {
        next if substr $_, -2, 2 eq '::';
        return 1 if defined &{"$class\::$_"};
    }
    $class =~ s{::}{/}go;
    return defined $INC{"$class.pm"};
}

sub load_class {
    my $class = shift;
    eval "require $class" or die $@;
    $class->import;
}

1;
