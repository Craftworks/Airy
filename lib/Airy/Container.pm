package Airy::Container;

use strict;
use warnings;
use Airy::Util;

my $constructor = +{};
my $instance    = +{};

sub get {
    my ( $class, $package, @args ) = @_;

    unless ( $instance->{ $package } ) {
        unless ( Airy::Util::is_class_loaded($package) ) {
            Airy::Util::load_class($package);
        }
        $instance->{ $package } = $constructor->{ $package }
            ? $constructor->{ $package }->($package, @args)
            : $package->new(@args);
    }

    return $instance->{ $package };
}

sub register {
    my ( $class, $package, $code ) = @_;
    delete $instance->{ $package };
    $constructor->{ $package } = $code;
}

1;
