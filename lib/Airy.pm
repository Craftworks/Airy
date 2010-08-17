package Airy;

use strict;
use warnings;
use Airy::Util;

our $VERSION = '0.001';

sub import {
    my $class  = shift;
    my $caller = caller 0;

    strict->import;
    warnings->import;

    if ( 0 < @_ && $_[0] eq '-base' ) {

        no strict 'refs';
        unshift @{"$caller\::ISA"}, 'Airy::Base';

        my $root_dir = Airy::Util::class2dir($caller);
        *{"$caller\::root_dir"} = sub { $root_dir };
    }
}

package Airy::Base;

sub new {
    my $class = shift;
    bless { 'config' => {}, @_ }, $class;
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
