package Airy::App;

use strict;
use warnings;
use parent 'Airy::Object';
use UNIVERSAL::require;
use Airy::Util;
use Airy::Container;
use Airy::Config;
use Airy::Log;

my @args;
my $app_class;

*config = *Airy::Config::get_all;
*get    = *Airy::Container::get;

sub setup {
    my $class  = shift;
    my %config = @_;

    $app_class = Airy::Util->app_class($class);
    my $root_dir  = Airy::Util::class2dir($app_class);
    {
        no strict 'refs';
        *{"$class\::root_dir"} = sub { $root_dir };
    }

    Airy::Config->load;
    if ( %config ) {
        Airy::Config->add(%config);
    }

    Airy::Log->setup;
}

sub new {
    my $class = shift;
    Airy::Config->add(@_);
    bless {}, $class;
}

sub api {
    my ($self, $name) = @_;
    Airy::Container->get("$app_class\::API::$name");
}

sub handler {
    my ($self, $name) = @_;
    my $web_class = "$app_class\::Web::$name";
    $web_class->use or die $@;
    $web_class->setup($name)->handler;
}

1;
