package Airy::Config;

use strict;
use warnings;
use File::Spec;

my $vars = +{};
my $app_class = '';

sub app_class {
    my ( $class, $name ) = @_;
    $name ? $app_class = $name : $app_class;
}

sub load {
    my ( $class ) = @_;

    my $env  = $ENV{'AIRY_ENV'} || $ENV{'PLACK_ENV'} || 'base';
    my $home = $ENV{'AIRY_HOME'} || '.';
    my $conf = $ENV{'AIRY_CONFIG_PATH'} || 'conf';
    my $path = File::Spec->catfile($home, $conf, "$env.pl");

    $vars = do $path or die qq{Couldn't load configuration file "$path"};
}

sub get_all {
    $vars;
}

sub get {
    my ( $class, $caller ) = @_;
    $caller =~ s/^$app_class\:://o;
    $vars->{ $caller };
}

1;
