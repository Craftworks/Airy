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

subtest 'app_class' => sub {
    is(Airy::Util->app_class, undef, 'not set yet');
    Airy::Util->app_class('My::App');
    is(Airy::Util->app_class, 'My::App', 'set');
};

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
    ok(!$INC{'Benchmark.pm'}, 'not loaded yet');
    is(
        exception { Airy::Util::load_class('Benchmark') },
        undef,
        'load class'
    );
    ok($INC{'Benchmark.pm'}, 'loaded');
    isnt(
        exception { Airy::Util::load_class('Doesnt::Exists') },
        undef,
        'failed to load class'
    );
};

done_testing;
