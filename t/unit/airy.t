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
    package My::App::API::Foo;
    use Airy;
    use parent 'Airy::API';
}

subtest 'import' => sub {
    my ($hints, $bitmask) = Foo->context;
    is($hints, 0x00000602, 'import strict');
};

subtest 'context' => sub {
    my $app = My::App->new;
    can_ok($app, qw(root_dir config get api));
    my $api = $app->get('Foo');
    can_ok($api, qw(root_dir config));
};

subtest 'application class' => sub {
    is(Airy::Util->app_class, 'My::App');
};

subtest 'specify config' => sub {
    is_deeply(Airy::Config->get_all, +{ 'Foo' => 'foo' });
};

subtest 'api' => sub {
    my $app = My::App->new;
    isa_ok($app->api('Foo'), 'Airy::API');
};

done_testing;
