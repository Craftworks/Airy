package Airy::DAO::Plugin::DBI;

use Airy;

sub import {
    my $class  = shift;
    my $caller = caller 0;

    no strict 'refs';

    *{"$caller\::sql"} = sub {
        shift->dod('DBI')->{'sql'};
    };

    for my $method (qw(dbh mode run txn svp)) {
        *{"$caller\::$method"} = sub {
            shift->dod('DBI')->{'dbi'}->$method(@_);
        };
    }
}

1;
