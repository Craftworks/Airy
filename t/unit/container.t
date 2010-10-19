use strict;
use warnings;
use Test::More;
use Airy::Util;

my $container = 'Airy::Container';

use_ok($container);

subtest 'delay loading' => sub {
    # FileHandle was first released with perl 5
    $container->register('FileHandle', sub { FileHandle->new });
    ok(!Airy::Util::is_class_loaded('FileHandle'), 'not load yet');
    $container->get('FileHandle');
    ok(Airy::Util::is_class_loaded('FileHandle'), 'delayed loading');
};

subtest 'get object' => sub {
    isa_ok($container->get('FileHandle'), 'FileHandle');
    isa_ok($container->get('Foo'), 'Foo');
};

subtest 'register constructor' => sub {
    my $constructor = sub {
        shift->new('foo' => 'foo');
    };
    is($container->get('Foo')->{'foo'}, undef, 'not set');
    isa_ok($container->register('Foo', $constructor), 'CODE');
    is($container->get('Foo')->{'foo'}, 'foo', 'instance variable');
};

subtest 'other name' => sub {
    $container->register('Foo', sub { Foo->instance });
    isa_ok($container->get('Foo'), 'Foo');
};

done_testing;

{
    package Foo;

    sub new {
        my $class = shift;
        bless { @_ }, $class;
    }

    sub instance {
        my $class = shift;
        bless { @_ }, $class;
    }
}
