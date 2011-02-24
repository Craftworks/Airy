package Airy::Object;

use strict;
use warnings;
use Airy::Config;
use Airy::Log;
use Airy::Attribute::Container;

sub new {
    my $class = shift;
    my %args  = ( @_ == 1 && ref $_[0] eq 'HASH' ) ? %{ +shift } : @_;

    my $self = bless \%args, $class;

    $self->initialize(@_) if $self->can('initialize');

    return $self;
}

sub config {
    my $self  = shift;
    my $class = ref $self || $self;

    @_
        ? Airy::Config->add($class => shift)
        : Airy::Config->get($class);
}

sub log {
    Airy::Log->logger;
}

sub MODIFY_CODE_ATTRIBUTES {
    my ($pkg, $ref, @attrs) = @_;
    Airy::Attribute::Container->set($pkg, $ref, @attrs);
    return;
}

1;
