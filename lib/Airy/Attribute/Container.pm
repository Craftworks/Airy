package Airy::Attribute::Container;

use strict;
use warnings;
use parent 'Class::Data::Inheritable';

__PACKAGE__->mk_classdata('attributes');
__PACKAGE__->mk_classdata('classes');
__PACKAGE__->attributes({});
__PACKAGE__->classes({});

sub set {
    my ($class, $package, $code, @attrs) = @_;

    push @{ $class->attributes->{ $package } }, +{
        'code'  => $code,
        'attrs' => \@attrs,
    };

    for my $attr ( @attrs ) {
        $attr =~ /^(\w+)/o;
        $class->classes->{ $1 }++;
    }
}

1;
