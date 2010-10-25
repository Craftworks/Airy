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

    my $env  = $ENV{'AIRY_ENV'} || $ENV{'PLACK_ENV'} || '';
    my $home = $ENV{'AIRY_HOME'} || '.';
    my $conf = $ENV{'AIRY_CONFIG_PATH'} || 'conf';
    my $path = File::Spec->catfile($home, $conf, "$env.pl");

    if ( length $env ) {
        $vars = do $path or die qq{Couldn't load configuration file "$path"};
    }
    else {
        warn 'configuration file was not specified';
        return;
    }
}

sub get_all {
    $vars;
}

sub get {
    my ( $class, $caller ) = @_;
    $caller =~ s/^$app_class\:://;
    $vars->{ $caller };
}

sub set {
    my $class = shift;
    @_ == 2 ? ( $vars->{ $_[0] } = $_[1] ) : ( $vars = $_[0] );
}

1;
