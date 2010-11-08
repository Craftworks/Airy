use strict;
use warnings;
use Test::More;

BEGIN {
    use_ok('Airy::DAO');
}

{
    package My::App;
    use Airy -app => (
        'DOD::DBI' => { 'datasource' => ['dbi:File'] }
    );
    package My::App::DAO;
    use Airy;
    use parent 'Airy::DAO';
    package My::App::DOD::DBI;
    use Airy;
    use parent 'Airy::DOD::DBI';
}

subtest 'instances' => sub {
    my $app = My::App->new();
    my $dao = $app->get('My::App::DAO');
    isa_ok($dao, 'Airy::DAO');
    can_ok($dao, 'dod');
    isa_ok($dao->dod('DBI'), 'Airy::DOD');
};

subtest 'inheritance' => sub {
    is($My::App::DAO::ISA[0], 'Airy::DAO', 'single inheritance');
};

done_testing;
