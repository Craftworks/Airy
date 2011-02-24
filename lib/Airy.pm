package Airy;

use strict;
use warnings;
use UNIVERSAL::require;
use Airy::Object;
use Airy::Util;
use Airy::Container;
use Airy::Config;
use Airy::Log;

our $VERSION = '0.001';
$VERSION = eval $VERSION;
our $AUTHORITY = 'cpan:CRAFTWORK';

sub import {
    my $class  = shift;
    my $caller = caller 0;

    my @warnings = split /[=,]/o, $ENV{'AIRY_WARNINGS'} || '';

    strict->import;
    warnings->import(@warnings);

    if ( 0 < @_ && ( $_[0] eq '-base' || $_[0] eq '-app' ) ) {
        no strict 'refs';
        unshift @{"$caller\::ISA"}, 'Airy::Object';
    }

    if ( 0 < @_ && $_[0] eq '-app' ) {
        shift;

        Airy::Util->app_class($caller);
        my $root_dir = Airy::Util::class2dir($caller);

        no strict 'refs';
        *{"$caller\::new"} = sub {
            my $class = shift;
            Airy::Config->add(@_);
            bless {}, $class;
        };

        *{"$caller\::root_dir"} = sub { $root_dir };
        *{"$caller\::config"} = *Airy::Config::get_all;
        *{"$caller\::get"} = *Airy::Container::get;
        *{"$caller\::api"} = sub {
            my ($self, $name) = @_;
            Airy::Container->get("$caller\::API::$name");
        };
        *{"$caller\::handler"} = sub {
            my ($self, $name) = @_;
            my $web_class = "$caller\::Web::$name";
            $web_class->use or die $@;
            $web_class->setup($name)->handler;
        };

        my %config = @_;
        Airy::Config->load;
        if ( %config ) {
            Airy::Config->add(%config);
        }

        Airy::Log->setup;

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
