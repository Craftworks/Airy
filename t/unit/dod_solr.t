use strict;
use warnings;
use Test::More;
use Test::Fatal;
use Test::TCP;
use FindBin;
use Plack::Loader;
use Airy::Config;
use Airy::Util;

BEGIN {
    eval 'require WWW::Curl::Easy';
    plan skip_all => 'this test requires WWW::Curl::Easy' if $@;
    $ENV{'AIRY_HOME'} = "$FindBin::Bin/..";
    $ENV{'AIRY_ENV'}  = 'base';
}

use ok 'Airy::DOD::Solr';

{
    package MyApp;
    use Airy -app;
}

subtest 'instances' => sub {

    Airy::DOD::Solr->config({});
    isnt(exception { Airy::DOD::Solr->new; }, undef, 'empty config');

    Airy::DOD::Solr->config({ 'datasource' => 'localhost:9999' });
    isnt(exception { Airy::DOD::Solr->new; }, undef, 'invalid config');

    my $server = sub {
        my $port = shift;
        Plack::Loader->auto('port' => $port)->run(sub {
            [ 200, [ 'Content-Type' => 'text/plain' ], [ '' ] ]
        });
    };

    my $client = sub {
        my $port = shift;
        Airy::DOD::Solr->config({ 'datasource' => "localhost:$port" });
        my $dod = new_ok('Airy::DOD::Solr');
        isa_ok($dod, 'Airy::DOD');
    };

    test_tcp('server' => $server, 'client' => $client);

};

done_testing;
