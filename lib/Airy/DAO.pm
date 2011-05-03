package Airy::DAO;

use Airy -base;
use Airy::Container;

sub dao {
    my ($self, $name) = @_;
    Airy::Container->get("$Airy::APP_CLASS\::DAO::$name");
}

sub dod {
    my ($self, $name) = @_;
    Airy::Container->get("$Airy::APP_CLASS\::DOD::$name");
}

1;
