use strict;
use warnings;
use Test::More;
use Cwd;

is($My::App::API::RootDir, getcwd, 'class2dir');
my $obj = new_ok('My::App::API');
isa_ok($obj, 'Airy::Base');

done_testing;

{
    package My::App::API;
    BEGIN {
        $INC{'My::App::API.pm'} = __FILE__;
    }
    use Airy -base;
}
