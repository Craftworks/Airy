use strict;
use warnings;
use Test::More;
use Data::Dumper;

my $container = 'Airy::Container';

use_ok($container);

{ # return object
    isa_ok($container->get('Foo'), 'Foo');
}

{ # register constructor
    my $constructor = sub {
        my ( $class, @args ) = @_;
        return $class->new('foo' => 'foo');
    };
    isa_ok($container->get('Foo'), 'Foo');
    isa_ok($container->register('Foo', $constructor), 'CODE');
    is($container->get('Foo')->{'foo'}, 'foo');
}

done_testing;

{
    package Foo;
    sub new {
        my $class = shift;
        bless { @_ }, $class;
    }
}
