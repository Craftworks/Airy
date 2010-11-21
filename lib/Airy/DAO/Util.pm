package Airy::DAO::Util;

use Airy;
use Carp;
use Scalar::Util 'blessed';

sub join_tables {
    shift if ( blessed $_[0] || !ref $_[0] );
    my ($left, $right, $lkey, $rkey) = @_;
    $rkey ||= $lkey;

    croak 'not enough arguments' unless $left && $right;

    eval {
        my %right;
        for my $row (@$right) {
            $right{ $row->{$rkey} } = $row;
        }

        for my $row (@$left) {
            my $key = $row->{$lkey};
            if ( $right{ $key } ) {
                %$row = ( %{ $right{ $key } }, %$row );
            }
        }
    };
    croak $@ unless !$@;

    return $left;
}

1;
