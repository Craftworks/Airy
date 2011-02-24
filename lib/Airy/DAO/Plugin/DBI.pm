package Airy::DAO::Plugin::DBI;

use Airy;
use Carp;

sub import {
    my $class  = shift;
    my $caller = caller 0;

    no strict 'refs';

    *{"$caller\::sql"} = sub {
        shift->dod('DBI')->{'sql'};
    };

    *{"$caller\::placeholders"} = sub {
        shift if ref $_[0];
        @_ = @{$_[0]} if ref $_[0] eq 'ARRAY';
        croak 'not enough arguments' unless @_;
        join q{, }, (('?') x @_);
    };

    for my $method (qw(dbh mode run txn svp)) {
        *{"$caller\::$method"} = sub {
            shift->dod('DBI')->{'dbi'}->$method(@_);
        };
    }
}

1;
