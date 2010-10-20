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

{
    package My::App;
    use Airy -app;
}

use_ok('Airy');

subtest 'import' => sub {
    my ($hints, $bitmask) = Foo->context;
    is($hints, 0x00000602, 'import strict');
    is($bitmask, 'UUUUUUUUUUUU', 'import warnings');
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

done_testing;
