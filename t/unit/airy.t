use strict;
use warnings;
use Test::More;

local $ENV{'AIRY_HOME'} = 't';

{
    no strict;
    no warnings;

    package Foo;
    use Airy;

    sub context  { _context() }
    sub _context { (caller(0))[8,9] }
}

use_ok('Airy');

{
    package My::App;
    use Airy -app => ( 'config' => +{
        'Foo' => 'foo',
    });
}

subtest 'import' => sub {
    my ($hints, $bitmask) = Foo->context;
    is($hints, 0x00000602, 'import strict');
};

subtest 'context' => sub {
    my $app = My::App->new;
    can_ok($app, 'root_dir');
    can_ok($app, 'config');
    can_ok($app, 'get');
    my $api = $app->get('Foo');
    can_ok($api, 'root_dir');
    can_ok($api, 'config');
};

subtest 'specify config' => sub {
    is_deeply(Airy::Config->get_all, +{ 'Foo' => 'foo' });
};

done_testing;
