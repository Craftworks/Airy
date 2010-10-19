use strict;
use warnings;
use Test::More;

{
    package My::App::API;
    BEGIN {
        $INC{'My/App/API.pm'} = 't/lib/My/App/API.pm';
    }
    use Airy -base;
}

{
    my $obj = new_ok('My::App::API');
    is($obj->config->{'config_loader'}, 'bundle', 'load config');
    is($obj->config->{'override'}, 'development', 'override');
}

{
    {
        package MyApp::ConfigLoader;
        sub load_config { +{ 'My::App::API' => 'my_loader' } }
    }
    local $ENV{'AIRY_CONFIG_LOADER'} = 'MyApp::ConfigLoader';
    local $Airy::Config::Loaded = 0;
    my $obj = new_ok('My::App::API');
    is($obj->config, 'my_loader', 'using original');
}

done_testing;
