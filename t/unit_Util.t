use strict;
use warnings;
use Test::More;
use Cwd;

is($My::App::API::RootDir, getcwd, 'class2dir');
my $obj = new_ok('My::App::API');
isa_ok($obj, 'Airy::Base');

# is_class_loaded
{
    ok(Airy::Util::is_class_loaded('Airy'), 'is_class_loaded with pm');
    ok(Airy::Util::is_class_loaded('Airy::Base'), 'is_class_loaded without pm');
    ok(!Airy::Util::is_class_loaded('Unknown'), 'is_class_loaded not loaded yet');
}

done_testing;

{
    package My::App::API;
    BEGIN {
        $INC{'My::App::API.pm'} = __FILE__;
    }
    use Airy -base;
}
