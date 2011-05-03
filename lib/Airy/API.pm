package Airy::API;

use Airy -base;
use Airy::Container;

sub api {
    my ($self, $name) = @_;
    Airy::Container->get("$Airy::APP_CLASS\::API::$name");
}

sub dao {
    my ($self, $name) = @_;
    Airy::Container->get("$Airy::APP_CLASS\::DAO::$name");
}

1;
