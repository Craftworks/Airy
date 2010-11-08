use strict;
use warnings;
use Test::More;
use Airy::Util;

local $ENV{'AIRY_HOME'} = 't';

BEGIN {
    use_ok('Airy::Config');
    Airy::Util->app_class('My::App');
}

my $config = 'Airy::Config';

subtest 'set' => sub {
    is_deeply($config->get_all, +{}, 'before set');
    $config->set({ 'foo' => 1 });
    is_deeply($config->get_all, +{ 'foo' => 1 }, 'after set');

    $config->set('Foo' => { 'foo' => 2 });
    is_deeply($config->get('Foo'), +{ 'foo' => 2 }, 'set with name');
};

subtest 'add' => sub {
    $config->add('Bar' => 'bar');
    is_deeply($config->get('Bar'), 'bar', 'add config');
    is_deeply($config->get('Foo'), +{ 'foo' => 2 }, 'config merged');
    $config->add('Foo' => +{ 'bar' => 3 });
    is_deeply($config->get('Foo'), +{ 'foo' => 2, 'bar' => 3 }, 'config merged');
};

subtest 'load' => sub {
    local $ENV{'AIRY_ENV'} = 'base';
    $config->set(+{});
    is_deeply($config->get_all, +{}, 'before load');
    $config->load;
    is_deeply($config->get_all, +{ 'name' => 'My::App' }, 'after load');
};

subtest 'load specified env' => sub {
    local $ENV{'AIRY_ENV'} = 'devel';
    $config->load;
    is_deeply($config->get_all, +{ 'env' => 'devel' });
};

subtest 'get' => sub {
    local $ENV{'AIRY_ENV'} = 'get';
    $config->load;
    is_deeply($config->get('My::App::API'), 'api', 'API');
    is_deeply($config->get('My::App::API::Foo'), 'foo', 'API::Foo');
};

done_testing;
