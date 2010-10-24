use strict;
use warnings;
use Test::More;

local $ENV{'AIRY_HOME'} = 't';

use_ok('Airy::Config');

subtest 'load' => sub {
    local $ENV{'AIRY_ENV'} = 'base';
    is_deeply(Airy::Config->get_all, +{}, 'before load');
    Airy::Config->load;
    is_deeply(Airy::Config->get_all, +{ 'name' => 'My::App' }, 'after load');
};

subtest 'load specified env' => sub {
    local $ENV{'AIRY_ENV'} = 'devel';
    Airy::Config->load;
    is_deeply(Airy::Config->get_all, +{ 'env' => 'devel' });
};

subtest 'get' => sub {
    local $ENV{'AIRY_ENV'} = 'get';
    Airy::Config->app_class('My::App');
    Airy::Config->load;
    is_deeply(Airy::Config->get('My::App::API'), 'api', 'API');
    is_deeply(Airy::Config->get('My::App::API::Foo'), 'foo', 'API::Foo');
};

done_testing;
