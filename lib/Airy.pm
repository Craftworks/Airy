package Airy;

use strict;
use warnings;
use Airy::Object;
use Airy::App;

our $VERSION = '0.001';
$VERSION = eval $VERSION;
our $AUTHORITY = 'cpan:CRAFTWORK';

sub import {
    my $class  = shift;
    my $caller = caller 0;

    my @warnings = split /[=,]/o, $ENV{'AIRY_WARNINGS'} || '';

    strict->import;
    warnings->import(@warnings);

    if ( 0 < @_ && $_[0] eq '-base' ) {
        no strict 'refs';
        unshift @{"$caller\::ISA"}, 'Airy::Object';
    }
    elsif ( 0 < @_ && $_[0] eq '-app' ) {
        no strict 'refs';
        unshift @{"$caller\::ISA"}, 'Airy::App';
        $caller->setup(@_[1 .. $#_]);
    }
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
