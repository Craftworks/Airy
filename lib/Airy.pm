package Airy;

use strict;
use warnings;
use Airy::Util;
use Airy::Container;
use Airy::Config;

our $VERSION = '0.001';

sub import {
    my $class  = shift;
    my $caller = caller 0;

    strict->import;
    warnings->import;

    no strict 'refs';
    unshift @{"$caller\::ISA"}, 'Airy::Base';

    my $root_dir = Airy::Util::class2dir($caller);
    *{"$caller\::root_dir"} = sub { $root_dir };

    if ( 0 < @_ && $_[0] eq '-app' ) {
        *{"$caller\::app_class"} = sub { $caller };
        *{"$caller\::get"} = *Airy::Container::get;
    }
}

package Airy::Base;

sub new {
    my $class = shift;
    my %args = @_ == 1 ? %{ +shift } : @_;
    if ( $class->can('app_class') ) {
        Airy::Config->app_class($class->app_class);
        Airy::Config->load;
    }
    bless \%args, $class;
}

sub config {
    my $self = shift;
    Airy::Config->get(ref $self);
}

1;

=head1 NAME

Airy - The lightweight application framework

=head1 AUTHOR

Craftworks, C<< <craftwork at cpan org> >>

=head1 COPYRIGHT & LICENSE

Copyright 2010 Craftworks, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
