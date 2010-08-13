use inc::Module::Install;

name     'Airy';
all_from 'lib/Airy.pm';
author   'Craftworks <craftwork at cpan org>';
license  'perl';

build_requires 'Test::More';

auto_install;

WriteAll;
