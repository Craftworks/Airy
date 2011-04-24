package Airy::Config;

use strict;
use warnings;
use Sys::Hostname;
use File::Spec;
use Airy::Util;
use Hash::Merge::Simple;

my $vars = +{};

sub load {
    my ( $class ) = @_;

    my $env  = $ENV{'AIRY_ENV'} || $ENV{'PLACK_ENV'} || '';
    my $home = $ENV{'AIRY_HOME'} || '.';
    my $conf = $ENV{'AIRY_CONFIG_PATH'} || 'conf';

    if ( length $env ) {
        my $path = File::Spec->catfile($home, $conf, "$env.pl");
        $vars = do $path
            or die qq{Couldn't load configuration file "$path": $!};
    }
    elsif ( my $hostname = (hostname() =~ /([a-zA-Z]+)/)[0] ) {
        my $path = File::Spec->catfile($home, $conf, "$hostname.pl");
        return unless -r $path;
        $vars = do $path
            or die qq{Couldn't load configuration file "$path": $!};
    }
    else {
        warn qq{configuration file was not specified\n}
            unless $ENV{'HARNESS_ACTIVE'};
        return;
    }
}

sub get_all {
    $vars;
}

sub get {
    my ( $class, $caller ) = @_;
    my $app_class = Airy::Util->app_class;
    $caller =~ s/^$app_class\:://;
    $vars->{ $caller };
}

sub set {
    my $class = shift;
    @_ == 2 ? ( $vars->{ $_[0] } = $_[1] ) : ( $vars = $_[0] );
}

sub add {
    my $class = shift;
    my %args  = @_ == 1 ? %{ +shift } : @_;
    my %config;

    my $app_class = Airy::Util->app_class;
    while ( my ($caller, $var) = each %args ) {
        $caller =~ s/^$app_class\:://;
        $config{ $caller } = $var;
    }

    $vars = Hash::Merge::Simple::merge($vars, \%config);
}

1;
