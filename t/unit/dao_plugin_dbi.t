use strict;
use warnings;
use Test::More;
use Test::Fatal;
use FindBin;

BEGIN {
    $ENV{'AIRY_HOME'} = "$FindBin::Bin/..";
    $ENV{'AIRY_ENV'}  = 'base';
}

{
    package My::App;
    use Airy -app => (
        'DOD::DBI' => {
            'datasource' => [ 'dbi:File:', '', '', +{} ],
            'limit_dialect' => 'LimitOffset',
        }
    );
    package My::App::DOD::DBI;
    use parent 'Airy::DOD::DBI';
    package My::App::DAO::Foo;
    use Airy;
    use parent 'Airy::DAO';
    use Airy::DAO::Plugin::DBI;
}

subtest 'export' => sub {
    my $dao = My::App->new->get('My::App::DAO::Foo');
    can_ok($dao, qw(sql dbh mode run txn placeholders));
    isa_ok($dao->sql, 'SQL::Abstract::Limit');
    is($dao->sql->{'limit_dialect'}, 'LimitOffset', 'set option');
    isa_ok($dao->dbh, 'DBI::db', 'dbh');
};

subtest 'placeholders' => sub {
    my $dao = My::App->new->get('My::App::DAO::Foo');
    is($dao->placeholders(1 .. 3), '?, ?, ?', 'method style');
    is(My::App::DAO::Foo::placeholders(1 .. 3), '?, ?, ?', 'func style');
    ok(exception { $dao->placeholders }, 'not enough args');
};

done_testing;
