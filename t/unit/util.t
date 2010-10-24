use strict;
use warnings;
use Test::More;
use Test::Exception;
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
    lives_ok { Airy::Util::load_class('Data::Dumper') } 'load class';
    ok($INC{'Data/Dumper.pm'}, 'loaded');
};

done_testing;
