use strict;
use warnings;
use Test::More;
use FindBin;

is(My::App::API->root_dir, $FindBin::Bin, 'class2dir');
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
        $INC{'My/App/API.pm'} = 't/lib/My/App/API.pm';
    }
    use Airy -base;
}
