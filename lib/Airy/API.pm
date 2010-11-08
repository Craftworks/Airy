package Airy::API;

use Airy -base;
use Airy::Util;
use Airy::Container;

sub api {
    my ($self, $name) = @_;
    my $app_class = Airy::Util->app_class;
    Airy::Container->get("$app_class\::API::$name");
}

sub dao {
    my ($self, $name) = @_;
    my $app_class = Airy::Util->app_class;
    Airy::Container->get("$app_class\::DAO::$name");
}

1;
