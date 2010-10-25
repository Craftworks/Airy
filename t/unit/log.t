use strict;
use warnings;
use Test::More;

BEGIN {
    use_ok('Airy::Log');
}

{
    package My::App;
    use Airy -app => ( 'config' => {
        'Log::Dispatch' => {
            'outputs' => [ [ 'Screen', 'min_level' => 'debug' ] ],
        },
    });

    package My::App::API;
    use Airy;
}

subtest 'class has logger' => sub {
    my $app = My::App->new;
    my $api = $app->get('My::App::API');
    can_ok($api, 'log');
    my $logger = $api->log;
    isa_ok($logger, 'Log::Dispatch');
    can_ok($logger, qw(debug info notice warn error critical alert fatal));
};

done_testing;
