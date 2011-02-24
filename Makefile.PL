use inc::Module::Install;

name     'Airy';
all_from 'lib/Airy.pm';
author   'Craftworks <craftwork at cpan org>';
license  'perl';

requires 'parent';
requires 'UNIVERSAL::require';
requires 'Class::Inspector';
requires 'Hash::Merge::Simple';
requires 'Hash::MoreUtils';
requires 'Exporter::Lite';
requires 'Log::Dispatch' => 2.26;
requires 'DBIx::Connector';
requires 'SQL::Abstract::Limit';
requires 'SQL::Abstract::Plugin::InsertMulti';

test_requires 'Test::More' => 0.96;
test_requires 'Test::Fatal';

tests 't/*.t t/*/*.t';

auto_install;

WriteAll;
