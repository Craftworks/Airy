use strict;
use warnings;
use Test::More;
use Test::Fatal;

local $ENV{'AIRY_HOME'} = 't';

{
    no strict;
    no warnings;

    package Foo;
    use Airy -base;

    sub context  { _context() }
    sub _context { (caller(0))[8,9] }
}

use_ok('Airy');

{
    package My::App;
    use Airy -app => ('Foo' => 'foo');
    package My::App::API::Foo;
    use Airy;
    use parent 'Airy::API';
    our $foo;
    sub initialize {
        $foo = 1;
    }
    package My::App::API::Bar;
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
    can_ok($api, qw(config log));
};

subtest 'application class' => sub {
    is(Airy::Util->app_class, 'My::App');
};

subtest 'specify config' => sub {
    my $app = My::App->new;
    is_deeply(Airy::Config->get_all, +{ 'Foo' => 'foo' });
    is_deeply($app->config, +{ 'Foo' => 'foo' }, 'app class config');
};

subtest 'add config' => sub {
    my $app = My::App->new('Bar' => 'bar');
    is_deeply($app->config, +{ 'Foo' => 'foo', 'Bar' => 'bar' }, 'merged');
};

subtest 'run initializer' => sub {
    my $app = My::App->new;
    is(exception { $app->api('Bar') }, undef, 'live');
    ok(!$My::App::API::Foo::foo, 'undef yet');
    is(exception { $app->api('Foo') }, undef, 'live');
    ok($My::App::API::Foo::foo, 'run initializer');
};

subtest 'api' => sub {
    my $app = My::App->new;
    isa_ok($app->api('Foo'), 'Airy::API');
};

done_testing;
