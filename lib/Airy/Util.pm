package Airy::Util;

use strict;
use warnings;
use Carp;
use File::Spec;
use UNIVERSAL::require;

my $app_class;

sub app_class {
    my ($class, $name) = @_;
    $name ? $app_class = $name : $app_class;
}

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

{
    my $loaded;
    sub load_class {
        my $class = shift;
        return $class if $loaded->{ $class }++;
        $class->use or confess $@;
    }
}

1;
