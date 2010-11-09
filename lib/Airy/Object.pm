package Airy::Object;

use strict;
use warnings;
use Airy::Config;
use Airy::Log;

sub new {
    my $class = shift;
    my %args  = ( @_ == 1 && ref $_[0] eq 'HASH' ) ? %{ +shift } : @_;

    my $self = bless \%args, $class;

    $self->initialize(@_) if $self->can('initialize');

    return $self;
}

sub config {
    my $self = shift;
    Airy::Config->get(ref $self);
}

sub log {
    Airy::Log->logger;
}

1;
