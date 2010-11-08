use strict;
use warnings;
use Test::More;

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
    can_ok($dao, qw(sql dbh mode run txn));
    isa_ok($dao->sql, 'SQL::Abstract::Limit');
    is($dao->sql->{'limit_dialect'}, 'LimitOffset', 'set option');
    isa_ok($dao->dbh, 'DBI::db', 'dbh');
};

done_testing;
