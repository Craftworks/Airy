use strict;
use warnings;
use Test::More;
use Airy::Config;

BEGIN {
    use_ok('Airy::DOD::DBI');
}

{
    Airy::Config->set({
        'Airy::DOD::DBI' => {
            'connect_info' => [ 'dbi:File:', '', '', +{} ],
        },
    });
}

subtest 'instances' => sub {
    my $dod = new_ok('Airy::DOD::DBI');
    isa_ok($dod, 'Airy::DOD');
    my $dbi = $dod->dbi;
    isa_ok($dbi, 'DBIx::Connector');
    isa_ok($dbi->dbh, 'DBI::db');
    isa_ok($dod->dbh, 'DBI::db');
};

done_testing;