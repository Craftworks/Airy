use strict;
use warnings;
use Test::More;
use Test::Fatal;
use File::Spec;
use FindBin;
use Airy::Util;

{
    package Foo;
    use Airy;
}

subtest 'class2dir' => sub {
    local $INC{'My/App/API.pm'} = 't/lib/My/App/API.pm';
    my $expected = File::Spec->rel2abs('t');
    is(Airy::Util::class2dir('My::App::API'), $expected, 'class2dir');
};

subtest 'is_class_loaded' => sub {
    ok(Airy::Util::is_class_loaded('Foo'), 'is_class_loaded without pm');
    ok(Airy::Util::is_class_loaded('Airy'), 'is_class_loaded with pm');
    ok(!Airy::Util::is_class_loaded('Unknown'), 'is_class_loaded not loaded yet');
};

subtest 'load_class' => sub {
    ok(!$INC{'Data/Dumper.pm'}, 'not loaded yet');
    is(
        exception { Airy::Util::load_class('Data::Dumper') },
        undef,
        'load class'
    );
    ok($INC{'Data/Dumper.pm'}, 'loaded');
    isnt(
        exception { Airy::Util::load_class('Doesnt::Exists') },
        undef,
        'failed to load class'
    );
};

done_testing;
