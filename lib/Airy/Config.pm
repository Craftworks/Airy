package Airy::Config;

use strict;
use warnings;
use File::Spec;
use Airy::Util;

our $Loader  = __PACKAGE__;
our $Loaded  = 0;
our $ConfDir = 'conf';
our $Vars;

sub get {
    my ( $class, $caller ) = @_;
    unless ( $Loaded ) {
        $Vars = $class->load($caller);
        $Loaded = 1;
    }
    $Vars->{ $caller };
}

sub load {
    my ( $class, $caller ) = @_;

    my $loader_class = $ENV{'AIRY_CONFIG_LOADER'} || $Loader;
    unless ( Airy::Util::is_class_loaded($loader_class) ) {
        Airy::Util::load_class($loader_class);
    }

    my $config_path = File::Spec->catfile($caller->root_dir, $ConfDir);
    $loader_class->load_config($config_path);
}

sub load_config {
    my ( $class, $config_path ) = @_;

    require Hash::Merge;

    my $behavior = Hash::Merge::get_behavior();
    Hash::Merge::specify_behavior({
        'SCALAR' => {
            'SCALAR' => sub { $_[1] },
            'ARRAY'  => sub { die 'Cannot merge SCALAR and ARRAY' },
            'HASH'   => sub { die 'Cannot merge SCALAR and HASH'  },
        },
        'ARRAY'  => {
            'SCALAR' => sub { die 'Cannot merge ARRAY and SCALAR' },
            'ARRAY'  => sub { $_[1] },
            'HASH'   => sub { die 'Cannot merge ARRAY and HASH'   },
        },
        'HASH'   => {
            'SCALAR' => sub { die 'Cannot merge HASH and SCALAR'  },
            'ARRAY'  => sub { die 'Cannot merge HASH and ARRAY'   },
            'HASH'   => sub { Hash::Merge::_merge_hashes( $_[0], $_[1] ) },
        },
    }, 'Airy Behavior' );

    my $env = $ENV{'AIRY_ENV'} || $ENV{'PLACK_ENV'} || 'development';

    my $config = {};
    for my $name ( ('base', $env) ) {
        my $path = File::Spec->catfile($config_path, "$name.pl");
        my $hash = do $path or die qq{Couldn't load configuration file "$path"};
        $config = Hash::Merge::merge($config, $hash);
    }

    Hash::Merge::set_behavior($behavior);

    return $config;
}

1;
