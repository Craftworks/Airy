use strict;
use warnings;
use Test::More;

BEGIN {
    use_ok('Airy::Log');
    $ENV{'AIRY_LOG'} = 1;
}

{
    package My::App;
    use Airy -app;
    package My::App::API;
    use Airy;
    use parent 'Airy::API';
}

subtest 'class has logger' => sub {
    my $api = My::App->new->get('My::App::API');
    can_ok($api, 'log');
    my $logger = $api->log;
    my @methods = qw(debug info notice warn error critical alert fatal dump);
    can_ok($logger, @methods);
};

subtest 'logger config' => sub {
    my $logger = My::App->new->get('My::App::API')->log;
    isa_ok($logger, 'Log::Dispatch');
    my %config = %$logger;
    isa_ok($logger->output('_anon_0'), 'Log::Dispatch::Screen');
};

subtest 'logger outputs' => sub {
    my $logger = My::App->new->get('My::App::API')->log;

    local *STDERR;
    open my $fh, '>', \my $buffer;
    *STDERR = $fh;

    $logger->info('foobarbaz');
    like($buffer, qr/\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} \[info\] foobarbaz\n/, 'output');

    $logger->dump($fh);
    like($buffer, qr/\\\*{'::\$fh'}/, 'dump');
};

done_testing;
