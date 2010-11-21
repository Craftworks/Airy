use strict;
use warnings;
use Test::More;
use Test::Fatal;

BEGIN {
    use_ok('Airy::DAO::Util');
}

my $util = 'Airy::DAO::Util';

subtest 'join_tables' => sub {
    ok(exception { $util->join_tables }, 'no args');
    ok(exception { $util->join_tables({}) }, 'not enough');
    ok(exception { $util->join_tables({}, {}) }, 'invalid');
    ok(exception { $util->join_tables([], {}) }, 'invalid');
    ok(exception { $util->join_tables([], {}) }, 'invalid');

    is_deeply($util->join_tables([
        { 'id' => 1, 'col1' => 'a', },
        { 'id' => 2, 'col1' => 'b', },
    ], [
        { 'id' => 1, 'col2' => 'a', },
        { 'id' => 2, 'col2' => 'b', },
    ], 'id'), [
        { 'id' => 1, 'col1' => 'a', 'col2' => 'a', },
        { 'id' => 2, 'col1' => 'b', 'col2' => 'b', },
    ], 'join by same key');

    is_deeply($util->join_tables([
        { 'id' => 1, 'col1' => 'a', },
        { 'id' => 2, 'col1' => 'b', },
    ], [
        { 'code' => 1, 'col2' => 'a', },
        { 'code' => 2, 'col2' => 'b', },
    ], 'id' => 'code'), [
        { 'id' => 1, 'code' => 1, 'col1' => 'a', 'col2' => 'a', },
        { 'id' => 2, 'code' => 2, 'col1' => 'b', 'col2' => 'b', },
    ], 'join by not same key');
};

done_testing;
