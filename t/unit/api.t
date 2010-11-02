use strict;
use warnings;
use Test::More;

BEGIN {
    use_ok('Airy::API');
}

{
    package My::App;
    use Airy -app;
    package My::App::API::Foo;
    use Airy;
    use parent 'Airy::API';
    package My::App::DAO::Foo;
    use Airy;
    use parent 'Airy::DAO';
}

subtest 'instances' => sub {
    my $app = My::App->new;
    my $api = $app->get('My::App::API::Foo');
    isa_ok($api, 'Airy::API');
    can_ok($api, qw(api dao));
    isa_ok($api->api('Foo'), 'Airy::API');
    isa_ok($api->dao('Foo'), 'Airy::DAO');
};

done_testing;
