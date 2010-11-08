use strict;
use warnings;
use Test::More;
use Test::Fatal;
use Airy::Config;
use Airy::Util;

BEGIN {
    use_ok('Airy::DOD::DBI');
    Airy::Util->app_class('Airy');
}

{
    package My::App::DOD::DBI;
    use Airy;
    use parent 'Airy::DOD::DBI';
}

{
    Airy::Config->set({
        'DOD::DBI' => {
            'datasource' => [ 'dbi:File:', '', '', +{} ],
        },
    });
}

subtest 'instances' => sub {
    my $dod = new_ok('Airy::DOD::DBI');
    isa_ok($dod, 'Airy::DOD');
    can_ok($dod, qw(dbi sql datasource));
    my $dbi = $dod->dbi;
    isa_ok($dbi, 'DBIx::Connector');
    isa_ok($dbi->dbh, 'DBI::db');
};

subtest 'inheritance' => sub {
    my $dod = new_ok('Airy::DOD::DBI');
    isa_ok($dod, 'Airy::DOD::DBI');
    is($Airy::DOD::DBI::ISA[0], 'Airy::DOD', 'single inheritance');
};

subtest 'datasource' => sub {
    Airy::Config->set({});
    isnt(exception { Airy::DOD::DBI->new }, undef, 'no config');

    Airy::Config->set({ 'DOD::DBI' => { 'datasource' => [qw/db:foo/] }});
    isnt(exception { Airy::DOD::DBI->new }, undef, 'invalid config');

    Airy::Config->set({ 'DOD::DBI' => {
        'datasources' => {
            'file' => [qw/dbi:File:/],
        },
        'datasource_key' => 'file',
    }});
    is_deeply(Airy::DOD::DBI->new->datasource, [ 'dbi:File:' ], 'datasource key');
};

done_testing;
